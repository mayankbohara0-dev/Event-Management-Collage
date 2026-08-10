-- ========================================================
-- 1. Create Notifications Table
-- ========================================================
CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL, -- The user this notification is for
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    type TEXT NOT NULL, -- e.g., 'event_update', 'registration_update', 'admin_alert'
    is_read BOOLEAN DEFAULT false,
    link_id UUID, -- Optional ID for linking (e.g., event_id or registration_id)
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ========================================================
-- 2. Row Level Security (RLS)
-- ========================================================
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own notifications"
    ON notifications FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own notifications (e.g. mark read)"
    ON notifications FOR UPDATE
    USING (auth.uid() = user_id);

-- Admins can insert/view all notifications
CREATE POLICY "Admins can view all notifications"
    ON notifications FOR SELECT
    USING (EXISTS (SELECT 1 FROM admin_profiles WHERE admin_profiles.id = auth.uid()));

CREATE POLICY "Admins can insert notifications"
    ON notifications FOR INSERT
    WITH CHECK (EXISTS (SELECT 1 FROM admin_profiles WHERE admin_profiles.id = auth.uid()));

-- ========================================================
-- 3. Notification Triggers (Automation)
-- ========================================================

-- Trigger 3A: When Registration Status Changes
CREATE OR REPLACE FUNCTION notify_registration_status_change()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.status IS DISTINCT FROM NEW.status THEN
        INSERT INTO notifications (user_id, title, message, type, link_id)
        VALUES (
            NEW.student_id,
            'Registration ' || initcap(NEW.status),
            'Your registration for event ID ' || NEW.event_id || ' is now ' || NEW.status || '.',
            'registration_update',
            NEW.event_id
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_notify_registration_status ON registrations;
CREATE TRIGGER trigger_notify_registration_status
    AFTER UPDATE ON registrations
    FOR EACH ROW
    EXECUTE FUNCTION notify_registration_status_change();


-- Trigger 3B: When a Student Registers (Notify Admins)
-- Note: This will notify ALL admins.
CREATE OR REPLACE FUNCTION notify_admins_new_registration()
RETURNS TRIGGER AS $$
DECLARE
    admin_rec RECORD;
BEGIN
    FOR admin_rec IN SELECT id FROM admin_profiles LOOP
        INSERT INTO notifications (user_id, title, message, type, link_id)
        VALUES (
            admin_rec.id,
            'New Registration',
            'A new registration (' || NEW.registration_number || ') was submitted.',
            'admin_alert',
            NEW.event_id
        );
    END LOOP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_notify_admins_new_reg ON registrations;
CREATE TRIGGER trigger_notify_admins_new_reg
    AFTER INSERT ON registrations
    FOR EACH ROW
    EXECUTE FUNCTION notify_admins_new_registration();


-- Trigger 3C: When an Event is Published (Notify all Students)
-- Only when visibility changes to 'published'
CREATE OR REPLACE FUNCTION notify_students_new_event()
RETURNS TRIGGER AS $$
DECLARE
    student_rec RECORD;
BEGIN
    IF OLD.visibility IS DISTINCT FROM NEW.visibility AND NEW.visibility = 'published' THEN
        FOR student_rec IN SELECT id FROM student_profiles LOOP
            INSERT INTO notifications (user_id, title, message, type, link_id)
            VALUES (
                student_rec.id,
                'New Event: ' || NEW.title,
                'A new event has been published! Check it out.',
                'event_update',
                NEW.id
            );
        END LOOP;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_notify_students_new_event ON events;
CREATE TRIGGER trigger_notify_students_new_event
    AFTER UPDATE ON events
    FOR EACH ROW
    EXECUTE FUNCTION notify_students_new_event();
