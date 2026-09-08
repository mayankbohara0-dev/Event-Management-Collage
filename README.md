# Event Collage

**Event Collage** is a college event-management platform that brings campus discovery, registration, attendance tracking, notifications, and organizer administration into one experience.

## What it supports

- Students can discover events, search and filter listings, submit custom registration forms, view registrations, receive notifications, and use QR-based attendance flows.
- Administrators can create events, upload posters, manage forms and registrations, manage users, send notifications, scan check-ins, and review feedback.
- Supabase Row Level Security separates student and administrator access.
- Firebase Cloud Messaging and a Supabase Edge Function support push notifications.

## Technology stack

| Area | Technology |
| --- | --- |
| Client | Flutter and Dart |
| State and navigation | Riverpod and GoRouter |
| Backend | Supabase Auth, Postgres, Storage, RLS, and Edge Functions |
| Notifications | Firebase Cloud Messaging |
| Interaction | QR Flutter, Mobile Scanner, File Picker, and Image Picker |
| Web | HTML, CSS, and static assets in [`landing_page/`](./landing_page) |

## Getting started

```bash
git clone https://github.com/mayankbohara0-dev/Event-Management-Collage.git
cd Event-Management-Collage/event_app
flutter pub get
flutter run
```

Apply the SQL files in [`supabase/`](./supabase) only after reviewing their dependency order, policies, seed data, storage rules, and notification configuration. Keep service-role keys and Firebase service-account credentials server-side.

Useful checks:

```bash
flutter analyze
flutter test
flutter build apk --release
```

An Android build is also available from the [v1.0.1 release](https://github.com/mayankbohara0-dev/Event-Management-Collage/releases/tag/v1.0.1).

## Status

Event Collage is an active public project. Automated coverage, environment-specific configuration, and deployment documentation are ongoing areas for improvement.

## Author

Maintained by [Mayank Bohara](https://github.com/mayankbohara0-dev).
