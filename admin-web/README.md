# ZEST Admin — Campus Event Control Panel 🍋🛡️

Standalone web control panel for campus event organizers and university administrators. Built with **Next.js 14 (App Router)**, **TypeScript**, **Tailwind CSS**, and **Supabase (Auth + Postgres + RLS + Realtime + Storage)**.

---

## 🚀 Quick Start (Local Development)

The `admin-web` application is completely isolated and self-contained within this folder.

```bash
cd admin-web
npm install
npm run dev
```

Visit [http://localhost:3001](http://localhost:3001) in your browser.  
To view the design system tokens, mascot states, and interactive primitives: [http://localhost:3001/dev/gallery](http://localhost:3001/dev/gallery).

---

## ⚙️ Environment Variables

Create `.env.local` inside `admin-web/` (this file is git-ignored):

```ini
# Supabase Configuration (Connected to the same project as the student app)
NEXT_PUBLIC_SUPABASE_URL="https://your-project-id.supabase.co"
NEXT_PUBLIC_SUPABASE_ANON_KEY="your-anon-key"

# Sensitive Server-Only Key (OPTIONAL / SERVER-SIDE ONLY - Never expose to client!)
# Used only in privileged server RPCs or edge admin scripts.
SUPABASE_SERVICE_ROLE_KEY="your-service-role-key"

# URLs
NEXT_PUBLIC_APP_URL="http://localhost:3001"
NEXT_PUBLIC_LANDING_URL="http://localhost:3000"
```

> **Security Rule**: `SUPABASE_SERVICE_ROLE_KEY` is strictly for server-side code and must NEVER be prefixed with `NEXT_PUBLIC_` or imported into client components.

---

## 🗄️ Supabase Database & First Super-Admin Seeding

ZEST Admin operates on the existing ZEST database schema without breaking student app compatibility.

### 1. Admin Profiles & Roles
The table `admin_profiles` stores organizer metadata and privileges:
- `super_admin`: Full access to events, settings, team invitations, and role management.
- `admin`: Standard event management, check-in gate scanner, and registration approval.

### 2. Seeding Your First Super-Admin
To grant an account super-admin status, run the following SQL query in the Supabase SQL Editor:

```sql
-- Step 1: Ensure user is signed up in Supabase Auth (or invite via Auth dashboard)
-- Step 2: Grant super_admin privileges in admin_profiles
INSERT INTO public.admin_profiles (id, email, name, role)
VALUES (
  'YOUR_AUTH_USER_UUID',
  'organizer@college.edu',
  'Lead Organizer',
  'super_admin'
)
ON CONFLICT (id) DO UPDATE SET
  role = 'super_admin',
  updated_at = NOW();
```

---

## ☁️ Vercel Deployment Guide

Deploy `admin-web` as a standalone project on Vercel:

1. **Import Git Repository**: Select this repository on Vercel.
2. **Project Settings**:
   - **Root Directory**: `admin-web`
   - **Framework Preset**: `Next.js`
   - **Build Command**: `npm run build`
   - **Output Directory**: `.next`
3. **Environment Variables on Vercel**:
   - `NEXT_PUBLIC_SUPABASE_URL`: Your Supabase URL
   - `NEXT_PUBLIC_SUPABASE_ANON_KEY`: Your Supabase Anon Public Key
   - `SUPABASE_SERVICE_ROLE_KEY`: (Mark as **Sensitive**)
   - `NEXT_PUBLIC_APP_URL`: Your production admin domain (e.g., `https://admin.zestcampus.app`)
   - `NEXT_PUBLIC_LANDING_URL`: Student portal / landing URL
4. **Ignored Build Step (Prevents Unnecessary Deployments)**:
   In Vercel Project Settings $\to$ **Git** $\to$ **Ignored Build Step**, select *Custom* and enter:
   ```bash
   git diff --quiet HEAD^ HEAD -- .
   ```
   *This ensures commits that only modify Flutter code (`event_app/`) or root docs skip the admin web deployment entirely.*

---

## 🧪 Available Scripts

Inside `admin-web/`:
- `npm run dev`: Start Next.js development server on port 3001.
- `npm run build`: Compile and optimize production build.
- `npm run start`: Start production server on port 3001.
- `npm run lint`: Run Next.js ESLint checks.
- `npm run typecheck`: Run TypeScript compilation check (`tsc --noEmit`).

---

## 🧩 Architectural Highlights

- **Designjoy Light Theme**: Crisp off-white canvas (`#F8FAFC`), white cards (`#FFFFFF`), subtle lines (`#E6EAF2`), and blue lemon blob branding.
- **Dynamic Form Builder**: Drag-and-drop registration question creator with 16 question types.
- **Gate Check-In PWA**: Real-time camera viewfinder & barcode scanner for lightning fast gate attendance.
- **Realtime Metrics**: Live attendee counters, capacity gauges, and CSV data export for accreditation.
