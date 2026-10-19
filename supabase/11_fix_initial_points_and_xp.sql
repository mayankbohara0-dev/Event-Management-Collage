-- ==============================================================================
-- 🍋 Zest Migration 11: Fix Initial Points Default & Auto Attendance Reward
-- Points must be earned through real actions, not given on registration!
-- ==============================================================================

-- 1. Ensure default points for any student profile is 0 (Level 1 Fresher)
ALTER TABLE student_profiles ALTER COLUMN points SET DEFAULT 0;

-- 2. Reset unearned legacy default 60 points to 0 for users who have not attended any events
UPDATE student_profiles
SET points = 0
WHERE (points = 60 OR points IS NULL)
  AND id NOT IN (SELECT student_id FROM attendance);

-- 3. Trigger to automatically credit +80 XP to student profile on gate check-in
CREATE OR REPLACE FUNCTION reward_attendance_xp()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE student_profiles
    SET points = COALESCE(points, 0) + 80
    WHERE id = NEW.student_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_reward_attendance_xp ON attendance;
CREATE TRIGGER trg_reward_attendance_xp
AFTER INSERT ON attendance
FOR EACH ROW
EXECUTE FUNCTION reward_attendance_xp();

-- 4. Trigger to automatically credit +10 XP to student profile on event feedback
CREATE OR REPLACE FUNCTION reward_feedback_xp()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE student_profiles
    SET points = COALESCE(points, 0) + 10
    WHERE id = NEW.student_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_reward_feedback_xp ON event_feedback;
CREATE TRIGGER trg_reward_feedback_xp
AFTER INSERT ON event_feedback
FOR EACH ROW
EXECUTE FUNCTION reward_feedback_xp();
