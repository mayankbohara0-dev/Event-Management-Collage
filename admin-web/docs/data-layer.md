# ZEST Admin — Data Layer & Realtime Architecture

## 1. Supabase Client Strategy

- **Browser Client (`lib/supabase/client.ts`)**:
  - Uses `@supabase/ssr` with `createBrowserClient(NEXT_PUBLIC_SUPABASE_URL, NEXT_PUBLIC_SUPABASE_ANON_KEY)`
  - Singleton pattern for active React tree and Realtime channel subscriptions.
  - Safe for client components (never uses `SUPABASE_SERVICE_ROLE_KEY`).

- **Server Client (`lib/supabase/server.ts`)**:
  - Uses `@supabase/ssr` with `createServerClient` reading and writing cookies via Next.js `cookies()`.
  - Used in Server Components, Server Actions, and Route Handlers.
  - Enforces RLS with active user session.

- **Admin/Service Client (`lib/supabase/admin.ts`)**:
  - Uses `@supabase/supabase-js` with `SUPABASE_SERVICE_ROLE_KEY`.
  - Server-only (`import "server-only"`).
  - Used strictly for privileged tasks (e.g., `auth.admin.inviteUserByEmail` in `/api/team/invite`).

- **Middleware (`middleware.ts` & `lib/supabase/middleware.ts`)**:
  - Refreshes auth tokens on every request.
  - Enforces role checks: users without an active session or without a row in `admin_profiles` (role `admin` | `super_admin`) are redirected to `/login` or `/unauthorized`.

---

## 2. TanStack Query Keys & Invalidation Strategy

| Domain | Query Key | Trigger / Invalidation Event |
|---|---|---|
| Events List | `['events', { status, category, department, search }]` | Event created, updated, published, deleted |
| Event Detail | `['events', id]` | Event saved, form saved |
| Form Questions | `['forms', eventId, 'questions']` | Form question added, edited, reordered, deleted |
| Registrations | `['registrations', { eventId, status, search, page }]` | Status approved/rejected, new registration via Realtime |
| Attendance | `['attendance', eventId]` | QR scan check-in, manual check-in, Realtime insert |
| Students | `['students', { search, department, page }]` | Student profile update |
| Feedback | `['feedback', { eventId }]` | Realtime feedback insert |
| Stats/KPIs | `['dashboard', 'kpis', { range }]` | Periodic poll or Realtime event |
| Admin Profile | `['admin_profile', userId]` | Profile update |
| Team Members | `['team']` | Admin invited, role updated, admin removed |
| Departments | `['departments']` | Department added, renamed, status toggled |

---

## 3. Realtime Channel Subscriptions

- **Registrations Channel (`registrations_feed`)**:
  - Listens to `postgres_changes` on table `registrations` (INSERT / UPDATE).
  - Invalidate `['registrations']` query key and triggers subtle toast notifications.

- **Attendance Channel (`attendance_feed`)**:
  - Listens to `postgres_changes` on table `attendance` (INSERT).
  - Invalidate `['attendance']` and updates live gate metrics / ticker instantly.

- **Notifications Channel (`notifications_feed`)**:
  - Listens to `postgres_changes` on table `notifications` for user alerts.
