-- ==============================================================================
-- 🍋 Zest Migration 10: Performance Indexes & Seat Limit Concurrency Guard
-- ==============================================================================

-- 1. High Performance Indexes
CREATE INDEX IF NOT EXISTS idx_registrations_event_id ON registrations(event_id);
CREATE INDEX IF NOT EXISTS idx_registrations_student_id ON registrations(student_id);
CREATE INDEX IF NOT EXISTS idx_registrations_event_status ON registrations(event_id, status);
CREATE INDEX IF NOT EXISTS idx_registrations_qr ON registrations(qr_code_data);

CREATE INDEX IF NOT EXISTS idx_events_visibility_start_date ON events(visibility, start_date);
CREATE INDEX IF NOT EXISTS idx_events_category_id ON events(category_id);
CREATE INDEX IF NOT EXISTS idx_events_dept_id ON events(department_id);

CREATE INDEX IF NOT EXISTS idx_attendance_event_id ON attendance(event_id);
CREATE INDEX IF NOT EXISTS idx_attendance_student_id ON attendance(student_id);
CREATE INDEX IF NOT EXISTS idx_attendance_event_student ON attendance(event_id, student_id);

CREATE INDEX IF NOT EXISTS idx_notifications_user_unread ON notifications(user_id, is_read);
CREATE INDEX IF NOT EXISTS idx_event_feedback_event_id ON event_feedback(event_id);

-- 2. Concurrency-Safe Seat Limit Enforcement Trigger
-- Prevents overbooking race conditions when multiple students register simultaneously
CREATE OR REPLACE FUNCTION check_event_seat_limit()
RETURNS TRIGGER AS $$
DECLARE
    v_max_seats INTEGER;
    v_current_count INTEGER;
    v_allow_waitlist BOOLEAN;
BEGIN
    -- Lock the event row for the duration of this registration transaction
    SELECT max_seats INTO v_max_seats
    FROM events
    WHERE id = NEW.event_id
    FOR UPDATE;

    -- If no seat limit set, allow registration
    IF v_max_seats IS NULL OR v_max_seats <= 0 THEN
        RETURN NEW;
    END IF;

    -- Check if form allows waitlisting
    SELECT COALESCE(allow_waitlist, false) INTO v_allow_waitlist
    FROM registration_forms
    WHERE event_id = NEW.event_id;

    -- Count active registrations (approved or pending)
    SELECT COUNT(*) INTO v_current_count
    FROM registrations
    WHERE event_id = NEW.event_id
      AND status IN ('approved', 'pending');

    -- If seats are filled and waitlist is not enabled, block insert
    IF v_current_count >= v_max_seats AND NOT COALESCE(v_allow_waitlist, false) THEN
        RAISE EXCEPTION 'Event capacity reached (% seats). Registration is closed.', v_max_seats
            USING ERRCODE = 'P0001';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_check_event_seat_limit ON registrations;
CREATE TRIGGER trg_check_event_seat_limit
BEFORE INSERT ON registrations
FOR EACH ROW
EXECUTE FUNCTION check_event_seat_limit();

-- 3. Zest Helper View: Fast Event Availability
CREATE OR REPLACE VIEW event_availability_view AS
SELECT 
    e.id AS event_id,
    e.title,
    e.max_seats,
    COUNT(r.id) FILTER (WHERE r.status IN ('approved', 'pending')) AS registered_seats,
    CASE 
        WHEN e.max_seats IS NULL THEN 999999
        ELSE GREATEST(0, e.max_seats - COUNT(r.id) FILTER (WHERE r.status IN ('approved', 'pending')))
    END AS remaining_seats,
    CASE 
        WHEN e.max_seats IS NOT NULL AND COUNT(r.id) FILTER (WHERE r.status IN ('approved', 'pending')) >= e.max_seats THEN TRUE
        ELSE FALSE
    END AS is_full
FROM events e
LEFT JOIN registrations r ON e.id = r.event_id
GROUP BY e.id, e.title, e.max_seats;
