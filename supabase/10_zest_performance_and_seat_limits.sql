-- ==============================================================================
-- 🍋 Zest Migration 10: Performance Indexes, Feedback/Notification Tables & Seat Limits
-- Self-healing: Creates any missing tables/columns before adding indexes & triggers
-- ==============================================================================

-- ── 0. Ensure Required Columns on Profiles ───────────────────────────────────
ALTER TABLE student_profiles ADD COLUMN IF NOT EXISTS avatar_url TEXT;
ALTER TABLE admin_profiles ADD COLUMN IF NOT EXISTS avatar_url TEXT;

ALTER TABLE student_profiles ADD COLUMN IF NOT EXISTS fcm_token TEXT;
ALTER TABLE admin_profiles ADD COLUMN IF NOT EXISTS fcm_token TEXT;

ALTER TABLE student_profiles ADD COLUMN IF NOT EXISTS points INTEGER DEFAULT 60;

-- ── 1. Ensure Notifications Table Exists ──────────────────────────────────────
CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    type TEXT NOT NULL,
    is_read BOOLEAN DEFAULT false,
    link_id UUID,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'notifications' AND policyname = 'Users can view their own notifications') THEN
        CREATE POLICY "Users can view their own notifications" ON notifications FOR SELECT USING (auth.uid() = user_id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'notifications' AND policyname = 'Users can update their own notifications') THEN
        CREATE POLICY "Users can update their own notifications" ON notifications FOR UPDATE USING (auth.uid() = user_id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'notifications' AND policyname = 'Admins can view all notifications') THEN
        CREATE POLICY "Admins can view all notifications" ON notifications FOR SELECT USING (EXISTS (SELECT 1 FROM admin_profiles WHERE admin_profiles.id = auth.uid()));
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'notifications' AND policyname = 'Admins can insert notifications') THEN
        CREATE POLICY "Admins can insert notifications" ON notifications FOR INSERT WITH CHECK (EXISTS (SELECT 1 FROM admin_profiles WHERE admin_profiles.id = auth.uid()));
    END IF;
END $$;

-- ── 2. Ensure Event Feedback Table Exists ─────────────────────────────────────
CREATE TABLE IF NOT EXISTS event_feedback (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    student_id UUID NOT NULL REFERENCES student_profiles(id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    review TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE (event_id, student_id)
);

ALTER TABLE event_feedback ENABLE ROW LEVEL SECURITY;

DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'event_feedback' AND policyname = 'Students can insert their own feedback') THEN
        CREATE POLICY "Students can insert their own feedback" ON event_feedback FOR INSERT WITH CHECK (auth.uid() = student_id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'event_feedback' AND policyname = 'Anyone can view feedback') THEN
        CREATE POLICY "Anyone can view feedback" ON event_feedback FOR SELECT USING (true);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'event_feedback' AND policyname = 'Admins can view all feedback') THEN
        CREATE POLICY "Admins can view all feedback" ON event_feedback FOR SELECT USING (EXISTS (SELECT 1 FROM admin_profiles WHERE admin_profiles.id = auth.uid()));
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'event_feedback' AND policyname = 'Admins can delete feedback') THEN
        CREATE POLICY "Admins can delete feedback" ON event_feedback FOR DELETE USING (EXISTS (SELECT 1 FROM admin_profiles WHERE admin_profiles.id = auth.uid()));
    END IF;
END $$;

-- ── 3. High Performance Indexes ───────────────────────────────────────────────
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

-- ── 4. Concurrency-Safe Seat Limit Enforcement Trigger ────────────────────────
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

-- ── 5. Zest Helper View: Fast Event Availability ──────────────────────────────
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
