-- ==============================================================================
-- 🍋 ZEST Admin: Seed First Super Admin Script
-- Run this in your Supabase Project Dashboard -> SQL Editor
-- ==============================================================================

-- 1. If you haven't created your user in Supabase Auth yet, create one under:
--    Supabase Dashboard -> Authentication -> Users -> Add User (Send invite or set password)
--    Then copy your User's UUID.

-- 2. Replace 'YOUR_USER_UUID_HERE' with your auth.users id:
DO $$
DECLARE
    v_user_id UUID := 'YOUR_USER_UUID_HERE'::UUID; -- <--- REPLACE THIS WITH YOUR USER ID
    v_admin_name TEXT := 'Campus Super Admin';      -- <--- REPLACE WITH YOUR NAME
BEGIN
    -- Insert or update admin_profiles with super_admin role
    INSERT INTO public.admin_profiles (id, name, role, department_id, created_at, updated_at)
    VALUES (
        v_user_id,
        v_admin_name,
        'super_admin',
        NULL, -- NULL means campus-wide (all departments)
        NOW(),
        NOW()
    )
    ON CONFLICT (id) DO UPDATE
    SET role = 'super_admin',
        name = EXCLUDED.name,
        updated_at = NOW();

    RAISE NOTICE 'Successfully granted super_admin role to user % (%)', v_user_id, v_admin_name;
END $$;
