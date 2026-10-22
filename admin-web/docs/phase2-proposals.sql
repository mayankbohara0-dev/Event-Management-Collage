-- ==============================================================================
-- 🍋 ZEST Admin: Phase 2 Proposals (DRAFT - DO NOT APPLY DIRECTLY)
-- These proposals require schema extensions and are guarded by lib/flags.ts
-- ==============================================================================

-- ── 1. Announcements & Push Notifications Edge Function Dispatch ──────────────
-- Proposal to allow targeted mass notification broadcasts from ZEST Admin
CREATE TABLE IF NOT EXISTS broadcast_announcements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_id UUID REFERENCES events(id) ON DELETE SET NULL,
    audience_type TEXT NOT NULL CHECK (audience_type IN ('all_students', 'event_registrants', 'event_approved', 'event_attended')),
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    sent_by UUID REFERENCES admin_profiles(id),
    recipient_count INTEGER DEFAULT 0,
    sent_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS: Only admins can view and insert broadcast announcements
ALTER TABLE broadcast_announcements ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Admins can manage broadcast announcements"
    ON broadcast_announcements FOR ALL
    USING (EXISTS (SELECT 1 FROM admin_profiles WHERE admin_profiles.id = auth.uid()));

-- ── 2. Volunteer / Scan-Only Role & Gate Check-in Scopes ───────────────────────
-- Add 'volunteer' role to user_role ENUM:
-- ALTER TYPE user_role ADD VALUE IF NOT EXISTS 'volunteer';

-- ── 3. Event Scheduling, Archival, Templates, Co-organizers ───────────────────
-- ALTER TABLE events ADD COLUMN IF NOT EXISTS is_template BOOLEAN DEFAULT FALSE;
-- ALTER TABLE events ADD COLUMN IF NOT EXISTS scheduled_publish_at TIMESTAMPTZ;
-- ALTER TABLE events ADD COLUMN IF NOT EXISTS co_organizers UUID[];

-- ── 4. Audit Log for Manual Admin XP Adjustments ──────────────────────────────
CREATE TABLE IF NOT EXISTS student_xp_audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID NOT NULL REFERENCES student_profiles(id) ON DELETE CASCADE,
    adjusted_by UUID NOT NULL REFERENCES admin_profiles(id),
    delta_points INTEGER NOT NULL,
    reason TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
