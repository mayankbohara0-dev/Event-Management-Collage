-- ==============================================================================
-- 🍋 Zest Migration 12: Fix Admin Auth RLS, Event Visibility & Registration Forms
-- ==============================================================================

-- 1. Ensure events have both max_seats and max_capacity columns in sync
ALTER TABLE events ADD COLUMN IF NOT EXISTS max_seats INTEGER DEFAULT 100;
ALTER TABLE events ADD COLUMN IF NOT EXISTS max_capacity INTEGER DEFAULT 100;

UPDATE events SET max_capacity = COALESCE(max_seats, 100) WHERE max_capacity IS NULL;
UPDATE events SET max_seats = COALESCE(max_capacity, 100) WHERE max_seats IS NULL;

-- 2. Ensure RLS on events allows public and student access to published events
DROP POLICY IF EXISTS "Anyone can view published events" ON events;
CREATE POLICY "Anyone can view published events" ON events FOR SELECT 
USING (visibility = 'published' OR is_admin());

DROP POLICY IF EXISTS "Admins can manage events" ON events;
CREATE POLICY "Admins can manage events" ON events FOR ALL 
USING (is_admin());

-- 3. Ensure RLS on admin_profiles allows self-registration and self-view
DROP POLICY IF EXISTS "Admins can view admins" ON admin_profiles;
CREATE POLICY "Admins can view admins" ON admin_profiles FOR SELECT 
USING (auth.uid() = id OR is_admin());

DROP POLICY IF EXISTS "Users can insert their own admin profile" ON admin_profiles;
CREATE POLICY "Users can insert their own admin profile" ON admin_profiles FOR INSERT 
WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "Admins can update their own admin profile" ON admin_profiles;
CREATE POLICY "Admins can update their own admin profile" ON admin_profiles FOR UPDATE 
USING (auth.uid() = id OR is_super_admin());

-- 4. Ensure RLS on registration_forms allows all users to read
DROP POLICY IF EXISTS "Anyone can view forms" ON registration_forms;
CREATE POLICY "Anyone can view forms" ON registration_forms FOR SELECT USING (true);

-- 5. Auto-create registration_forms row for every event so registration is always possible
INSERT INTO registration_forms (event_id, auto_approval)
SELECT id, true FROM events
WHERE id NOT IN (SELECT event_id FROM registration_forms WHERE event_id IS NOT NULL)
ON CONFLICT (event_id) DO NOTHING;

CREATE OR REPLACE FUNCTION auto_create_event_registration_form()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO registration_forms (event_id, auto_approval)
    VALUES (NEW.id, true)
    ON CONFLICT (event_id) DO NOTHING;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_auto_create_registration_form ON events;
CREATE TRIGGER trg_auto_create_registration_form
AFTER INSERT ON events
FOR EACH ROW
EXECUTE FUNCTION auto_create_event_registration_form();

-- 6. Ensure notifications trigger when event is published on INSERT or UPDATE
CREATE OR REPLACE FUNCTION notify_students_new_event()
RETURNS TRIGGER AS $$
DECLARE
    student_rec RECORD;
    is_publishing BOOLEAN := FALSE;
BEGIN
    IF TG_OP = 'INSERT' AND NEW.visibility = 'published' THEN
        is_publishing := TRUE;
    ELSIF TG_OP = 'UPDATE' AND (OLD.visibility IS DISTINCT FROM NEW.visibility) AND NEW.visibility = 'published' THEN
        is_publishing := TRUE;
    END IF;

    IF is_publishing THEN
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
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trigger_notify_students_new_event ON events;
CREATE TRIGGER trigger_notify_students_new_event
    AFTER INSERT OR UPDATE ON events
    FOR EACH ROW
    EXECUTE FUNCTION notify_students_new_event();
