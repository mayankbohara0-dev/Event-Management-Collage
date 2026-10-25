-- ==============================================================================
-- 🍋 Zest Migration 14: Dashboard Performance Optimization & Fast Summary RPC
-- ==============================================================================

-- 1. High-Performance Indexes for Instant Aggregations & Sorting
CREATE INDEX IF NOT EXISTS idx_events_created_at_desc ON public.events (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_events_start_date_asc ON public.events (start_date ASC);
CREATE INDEX IF NOT EXISTS idx_events_visibility_start ON public.events (visibility, start_date);
CREATE INDEX IF NOT EXISTS idx_registrations_created_at_desc ON public.registrations (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_registrations_status ON public.registrations (status);
CREATE INDEX IF NOT EXISTS idx_student_profiles_id ON public.student_profiles (id);

-- 2. Fast Dashboard Summary RPC (Single-query aggregated JSON payload)
-- Replaces 9 separate HTTP REST queries with 1 single <10ms database function call
CREATE OR REPLACE FUNCTION public.get_dashboard_summary()
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_summary JSONB;
  v_now TIMESTAMPTZ := NOW();
  v_in30 TIMESTAMPTZ := NOW() + INTERVAL '30 days';
BEGIN
  SELECT jsonb_build_object(
    'totalEvents', (SELECT COUNT(*) FROM public.events),
    'publishedEvents', (SELECT COUNT(*) FROM public.events WHERE visibility = 'published'),
    'totalRegistrations', (SELECT COUNT(*) FROM public.registrations),
    'pendingRegistrations', (SELECT COUNT(*) FROM public.registrations WHERE status = 'pending'),
    'attendanceCount', (SELECT COUNT(*) FROM public.attendance),
    'totalStudents', (SELECT COUNT(*) FROM public.student_profiles),
    'recentEvents', (
      SELECT COALESCE(jsonb_agg(e_row), '[]'::jsonb)
      FROM (
        SELECT id, title, start_date, end_date, visibility, venue
        FROM public.events
        ORDER BY created_at DESC
        LIMIT 5
      ) e_row
    ),
    'upcomingEvents', (
      SELECT COALESCE(jsonb_agg(u_row), '[]'::jsonb)
      FROM (
        SELECT id, title, start_date, venue, visibility
        FROM public.events
        WHERE visibility = 'published'
          AND start_date >= v_now
          AND start_date <= v_in30
        ORDER BY start_date ASC
        LIMIT 6
      ) u_row
    ),
    'recentRegistrations', (
      SELECT COALESCE(jsonb_agg(r_row), '[]'::jsonb)
      FROM (
        SELECT 
          r.id, 
          r.status, 
          r.created_at, 
          r.student_id, 
          r.event_id,
          jsonb_build_object('title', e.title) AS events,
          jsonb_build_object('name', s.name, 'roll_number', s.roll_number) AS student_profiles
        FROM public.registrations r
        LEFT JOIN public.events e ON r.event_id = e.id
        LEFT JOIN public.student_profiles s ON r.student_id = s.id
        ORDER BY r.created_at DESC
        LIMIT 8
      ) r_row
    )
  ) INTO v_summary;

  RETURN v_summary;
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_dashboard_summary() TO authenticated, anon;

-- 3. Reload schema cache immediately
NOTIFY pgrst, 'reload schema';
