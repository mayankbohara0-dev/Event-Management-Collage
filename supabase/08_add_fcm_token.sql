-- Add FCM token columns to store device tokens for Push Notifications
ALTER TABLE student_profiles ADD COLUMN IF NOT EXISTS fcm_token TEXT;
ALTER TABLE admin_profiles ADD COLUMN IF NOT EXISTS fcm_token TEXT;
