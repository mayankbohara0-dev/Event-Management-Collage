-- ========================================================
-- 1. Create Event Feedback Table
-- ========================================================
CREATE TABLE IF NOT EXISTS event_feedback (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    student_id UUID NOT NULL REFERENCES student_profiles(id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    review TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    -- A student can only submit feedback once per event
    UNIQUE (event_id, student_id)
);

-- ========================================================
-- 2. Row Level Security (RLS)
-- ========================================================
ALTER TABLE event_feedback ENABLE ROW LEVEL SECURITY;

-- Students can insert feedback for themselves
CREATE POLICY "Students can insert their own feedback"
    ON event_feedback FOR INSERT
    WITH CHECK (auth.uid() = student_id);

-- Students can view feedback for events they attended (optional, we'll allow public view for average calculation)
CREATE POLICY "Anyone can view feedback"
    ON event_feedback FOR SELECT
    USING (true);

-- Admins can view all feedback
CREATE POLICY "Admins can view all feedback"
    ON event_feedback FOR SELECT
    USING (EXISTS (SELECT 1 FROM admin_profiles WHERE admin_profiles.id = auth.uid()));

-- Admins can delete feedback if it's inappropriate
CREATE POLICY "Admins can delete feedback"
    ON event_feedback FOR DELETE
    USING (EXISTS (SELECT 1 FROM admin_profiles WHERE admin_profiles.id = auth.uid()));

-- ========================================================
-- 3. Add Request Feedback helper function
-- ========================================================
-- This function can be called by admins to send 'feedback_request' notifications
-- to all students who actually attended the event (i.e. are in the attendance table)
CREATE OR REPLACE FUNCTION request_event_feedback(p_event_id UUID)
RETURNS void AS $$
DECLARE
    att_rec RECORD;
    v_event_title TEXT;
BEGIN
    -- Only admins should call this, but we'll secure the RPC from the client side too.
    
    -- Get event title
    SELECT title INTO v_event_title FROM events WHERE id = p_event_id;
    
    -- Insert a notification for every student who attended
    FOR att_rec IN SELECT student_id FROM attendance WHERE event_id = p_event_id LOOP
        INSERT INTO notifications (user_id, title, message, type, link_id)
        VALUES (
            att_rec.student_id,
            'Rate ' || v_event_title,
            'We hope you enjoyed the event! Please leave a quick rating and review.',
            'feedback_request',
            p_event_id
        );
    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
