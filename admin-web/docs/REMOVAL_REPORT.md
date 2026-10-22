# ZEST Flutter App — Admin Removal Inventory & Plan (Stage 1)

This inventory document catalogs all admin-related and organizer-related code, screens, routes, providers, packages, permissions, and assets in `event_app/` before executing Stage 2–5 deletions.

> **Status:** Stage 1 Complete (Inventory only — NO files deleted yet).

---

## 1. Screens & Presentation Files

| Item Path | Found Matches / Functionality | Classification | Reason / Notes |
|---|---|---|---|
| `lib/features/admin/auth/presentation/login_screen.dart` | Admin login screen (`AdminLoginScreen`), email/password sign-in with `admin_profiles` check | **DELETE** | Used only for admin/organizer authentication. Student login is in `features/auth/presentation/login_screen.dart`. |
| `lib/features/admin/dashboard/presentation/dashboard_screen.dart` | Admin metrics, quick stats, event count cards, upcoming check-ins | **DELETE** | Admin-only dashboard screen. |
| `lib/features/admin/dashboard/presentation/dashboard_layout.dart` | Desktop/tablet collapsible sidebar, admin navigation shell (`DashboardLayout`) | **DELETE** | Shell for `/admin/*` routes. Students use `FloatingPillNavBar` in `features/home/presentation/home_screen.dart`. |
| `lib/features/admin/dashboard/presentation/widgets/analytics_charts.dart` | Chart widgets using `fl_chart` | **DELETE** | Used solely in `dashboard_screen.dart`. Students do not use `fl_chart`. |
| `lib/features/admin/events/presentation/events_table_screen.dart` | Admin table of all events, draft/publish toggles, delete action, edit link | **DELETE** | Admin event management. Students use `features/home/presentation/explore_tab.dart` and `event_details_screen.dart`. |
| `lib/features/admin/events/presentation/event_create_screen.dart` | Event creation & editor (`EventCreateScreen`), uploads to `event-banners` storage bucket | **DELETE** | Creation of events moves to ZEST Admin web. |
| `lib/features/admin/events/presentation/form_builder_screen.dart` | Dynamic drag-and-drop / list form question builder (`FormBuilderScreen`) | **DELETE** | Admin form builder moves to ZEST Admin web. Student registration form screen (`registration_form_screen.dart`) is KEPT. |
| `lib/features/admin/events/presentation/event_responses_screen.dart` | Admin view of attendee responses and CSV export (`_exportCSV`) | **DELETE** | Admin response viewer moves to ZEST Admin web. |
| `lib/features/admin/events/presentation/scanner_screen.dart` | Gate check-in camera viewfinder using `mobile_scanner`, inserts to `attendance` | **DELETE** | Replaced by the web-based PWA scanner in ZEST Admin. |
| `lib/features/admin/events/presentation/event_feedback_screen.dart` | Admin feedback overview with ratings and reviews | **DELETE** | Moved to web admin `/feedback`. Student rating dialog (`feedback_dialog.dart`) is KEPT. |
| `lib/features/admin/registrations/presentation/registrations_screen.dart` | Admin registrations table, approve/reject buttons | **DELETE** | Moved to web admin `/registrations`. |
| `lib/features/admin/users/presentation/users_screen.dart` | Admin student management table | **DELETE** | Moved to web admin `/students`. |
| `lib/features/admin/notifications/presentation/admin_notifications_screen.dart` | Broadcast announcement creator for organizers | **DELETE** | Moved to web admin `/announcements`. Student inbox (`features/notifications/presentation/notifications_screen.dart`) is KEPT. |
| `lib/features/admin/admin_colors.dart` | Dark-mode admin tokens (`kAdminBg`, `kAdminCard`, `kAdminPrimary`) | **DELETE** | Admin theme tokens unused anywhere in student code. |
| `lib/features/admin/events/presentation/admin_events_provider.dart` | Admin events riverpod provider | **DELETE** | Admin-specific data fetching. |
| `lib/count_events.dart` | One-off admin/developer script in lib | **DELETE** | Ad-hoc script. |
| `lib/delete_events.dart` | One-off admin/developer script in lib | **DELETE** | Ad-hoc script. |

---

## 2. Shared Screens & Widgets (Explicitly KEPT)

| Item Path | Usages | Classification | Reason / Notes |
|---|---|---|---|
| `lib/features/events/presentation/event_details_screen.dart` | Student event details, countdown, seat limits, calendar sync | **KEEP** | Core student experience. |
| `lib/features/events/presentation/registration_form_screen.dart` | Student dynamic form renderer, answers submission | **KEEP** | Student registration flow depends on this. |
| `lib/features/events/presentation/feedback_dialog.dart` | Star rating + review dialog for students | **KEEP** | Awards +10 XP to students via DB trigger. |
| `lib/features/home/presentation/passes_tab.dart` | Shows dynamic QR code pass with sweeping laser | **KEEP** | Used by student to present pass at gate. |
| `lib/features/home/presentation/home_screen.dart` | 5-tab student navigation shell | **KEEP** | Core student app navigation. |
| `lib/features/notifications/presentation/notifications_screen.dart` | Student alerts & notifications feed | **KEEP** | Student alerts. |
| `lib/shared/widgets/zest_mascot.dart` | Mascot widget, blinks, moods | **KEEP** | Used across student app and dev gallery. |
| `lib/shared/widgets/zest_blob_logo.dart` | App icon / logo widget | **KEEP** | Brand identity. |

---

## 3. Routes & Guards in `lib/core/router.dart`

| Route / Guard | Current Implementation | Action |
|---|---|---|
| `/admin/login` | Routes to `admin_auth.AdminLoginScreen()` | **DELETE** route |
| `/admin/events/create` | Routes to `EventCreateScreen()` | **DELETE** route |
| `/admin/events/:eventId/edit` | Routes to `EventCreateScreen(eventId: ...)` | **DELETE** route |
| `/admin/events/:id/scanner` | Routes to `ScannerScreen(eventId: ...)` | **DELETE** route |
| `/admin/events/:id/feedback` | Routes to `EventFeedbackScreen(eventId: ...)` | **DELETE** route |
| `/admin/events/:eventId/builder` | Routes to `FormBuilderScreen(eventId: ...)` | **DELETE** route |
| `/admin/events/:eventId/responses` | Routes to `EventResponsesScreen(eventId: ...)` | **DELETE** route |
| ShellRoute (`/admin/dashboard`, `/admin/events`, `/admin/registrations`, `/admin/users`, `/admin/notifications`) | Wrapped in `DashboardLayout` | **DELETE** entire ShellRoute and nested routes |
| Unauthenticated public routes list | Contains `'/admin/login'` | Remove `'/admin/login'` from allowed public routes |

---

## 4. Auth & Startup Flow in `lib/features/landing/presentation/landing_screen.dart`

| Section | Current Implementation | Planned Change |
|---|---|---|
| `_checkAuth()` `Future.wait` | Queries `student_profiles` and `admin_profiles` in parallel | Remove `admin_profiles` query completely. Keep 2.5s minimum splash duration. If `student_profiles` has name $\to$ `/student/home`, else $\to$ `/student/onboarding`. |
| FCM Token Setup | Checks `adminRes != null ? 'admin_profiles' : null` | Only update token on `student_profiles`. |
| `_AuthLanding` Hero Button | Secondary button "Admin & Organizer Suite 🛡️" (`/admin/login`) | Remove the button. Only "Enter as Student ⚡" remains. |

---

## 5. Dependencies in `pubspec.yaml`

| Package | Used By | Planned Action |
|---|---|---|
| `mobile_scanner: ^7.4.0` | Exclusively by `scanner_screen.dart` | **REMOVE** from `pubspec.yaml` |
| `csv: ^8.0.0` | Exclusively by `event_responses_screen.dart` | **REMOVE** from `pubspec.yaml` |
| `fl_chart: ^1.2.0` | Exclusively by `analytics_charts.dart` | **REMOVE** from `pubspec.yaml` |
| `universal_html: ^2.3.0` | Exclusively by `event_responses_screen.dart` for web download | **REMOVE** from `pubspec.yaml` |
| `qr_flutter: ^4.1.0` | `passes_tab.dart` (Student QR rendering) | **KEEP** |
| `image_picker: ^1.2.3` | `profile_onboarding_screen.dart` (Student avatar from gallery) | **KEEP** |
| `file_picker: ^11.0.3` | `registration_form_screen.dart` (Form file upload) | **KEEP** |
| `add_2_calendar: ^3.1.1` | `event_details_screen.dart` (Add event to phone calendar) | **KEEP** |
| `firebase_core`, `firebase_messaging` | Push notifications | **KEEP** |
| `supabase_flutter`, `flutter_riverpod`, `go_router` | Core architecture | **KEEP** |

---

## 6. Permissions & Manifest

| File | Permission / Feature | Status / Rationale |
|---|---|---|
| `android/app/src/main/AndroidManifest.xml` | `android.permission.CAMERA`, `android.hardware.camera`, `android.hardware.camera.autofocus` | **REMOVE** in Stage 4. Student avatar picking uses `ImageSource.gallery`. No student feature uses the camera directly. |
| `ios/Runner/Info.plist` | Camera usage descriptions | Verify and remove `NSCameraUsageDescription` if camera is not used by student. |

---

## 7. Deliverables & Next Steps

This concludes Stage 1 (Inventory). Stage 2–5 will be performed once the web admin panel's check-in page is verified.
