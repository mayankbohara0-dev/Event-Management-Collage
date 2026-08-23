# Event Collage

**Event Collage** is a college event management platform that brings campus discovery, event registration, attendance tracking, and organizer administration into one experience. The repository contains a Flutter application, a lightweight promotional landing page, and the Supabase database and notification assets that support the platform.

The product is designed around two roles: **students**, who discover and join events, and **administrators**, who create events, manage registrations, verify attendance, and review event activity.

## Project snapshot

| Area | Details |
| --- | --- |
| Application name | Event Collage |
| Primary client | Flutter application in [`event_app/`](./event_app) |
| Promotional site | Static landing page in [`landing_page/`](./landing_page) |
| Backend | Supabase Auth, Postgres, Row Level Security, Storage, and database functions |
| Notifications | Firebase Cloud Messaging with a Supabase Edge Function |
| State and navigation | Riverpod and GoRouter |
| Available release | Android APK linked from the [`v1.0.1` release](https://github.com/mayankbohara0-dev/Event-Management-Collage/releases/tag/v1.0.1) |
| Repository status | Public project; the default branch is `main` |

## Features

### Student experience

Students can create and verify an account, complete or edit a profile, browse published campus events, search by title, filter by category, and open event details. They can submit custom registration forms, review their registrations, view attendance-based event rewards, receive in-app notifications, and access their profile from the bottom navigation.

### Administrator experience

Administrators have a dedicated dashboard with student, event, pending-registration, and total-registration metrics. They can create and edit events, upload event posters, build custom registration forms, review event responses, approve or reject registrations, manage users, send or review notifications, scan QR codes for check-in, and review feedback for an event.

### Platform capabilities

The application uses Supabase Row Level Security policies to separate student and administrator access. Event posters are stored in a public Supabase Storage bucket with administrator-only write access. Firebase Cloud Messaging tokens are stored for students and administrators, and the included Edge Function can notify registered devices when a new event is created.

## Technology stack

| Layer | Technologies used |
| --- | --- |
| Mobile and desktop client | Flutter and Dart |
| UI and app architecture | Material UI, Riverpod, GoRouter, Google Fonts, Shimmer |
| Backend and authentication | Supabase Flutter SDK, Supabase Auth, Postgres, Row Level Security |
| Event interaction | QR Flutter, Mobile Scanner, custom registration forms |
| Media and files | Image Picker, File Picker, Supabase Storage |
| Charts and data | FL Chart, CSV |
| Notifications | Firebase Core, Firebase Messaging, Supabase Edge Functions |
| Web landing page | HTML, CSS, and static assets |

The package dependencies are defined in [`event_app/pubspec.yaml`](./event_app/pubspec.yaml), while the main initialization and navigation flow live in [`event_app/lib/main.dart`](./event_app/lib/main.dart) and [`event_app/lib/core/router.dart`](./event_app/lib/core/router.dart).

## Repository structure

```text
.
├── event_app/
│   ├── android/                 Android project and release configuration
│   ├── ios/                     iOS project files
│   ├── lib/
│   │   ├── core/                App theme, environment, providers, and routing
│   │   └── features/            Auth, student, admin, event, profile, and notification flows
│   ├── test/                    Flutter widget-test placeholder
│   ├── pubspec.yaml             Dart package manifest and dependencies
│   └── web/, linux/, macos/, windows/
├── landing_page/                Static product landing page and APK download link
└── supabase/
    ├── *.sql                    Schema, seed data, RLS, storage, notification, and feedback scripts
    └── functions/send-fcm/      Supabase Edge Function for Firebase push notifications
```

## Getting started

### Prerequisites

Install the Flutter SDK, configure an Android or iOS development environment, and ensure that the Flutter command is available on your `PATH`. A configured Supabase project is required for authentication and application data. Firebase configuration is required if push notifications are enabled.

### Clone and install dependencies

```bash
git clone https://github.com/mayankbohara0-dev/Event-Management-Collage.git
cd Event-Management-Collage/event_app
flutter pub get
```

### Configure Supabase and Firebase

The application initializes Supabase in `lib/main.dart` using values from `lib/core/env.dart`. Provide the URL and public client key for the Supabase project that contains the application schema. Do not place a Supabase service-role key or any Firebase service-account private key in the Flutter client.

For Firebase, use the normal FlutterFire setup for the target platforms and verify the generated configuration in `lib/firebase_options.dart`, along with the platform-specific Firebase files already present in the project. Push notifications also depend on the Supabase Edge Function secrets described below.

### Create the database

Run the SQL scripts from the `supabase/` directory in a controlled Supabase environment. The scripts are intended to be applied in dependency order:

```text
01_schema.sql
02_add_avatars.sql
02_rls.sql
03_seed.sql
03_seed_demo_events.sql
05_add_notifications.sql
06_add_feedback.sql
07_storage_cleanup.sql
08_add_fcm_token.sql
09_create_webhook.sql
```

Review the scripts before applying them to production. They create the core event-management tables, access policies, seed data, feedback support, event-poster storage policies, device-token columns, and the database webhook used by the notification flow.

### Run the application

From the `event_app/` directory, choose a connected device or emulator and run:

```bash
flutter devices
flutter run
```

The application starts at the landing screen. Unauthenticated users can choose the student or administrator login flow; authenticated routes are handled by the GoRouter configuration.

## Build the Android release

To create a release APK locally:

```bash
cd event_app
flutter build apk --release
```

The generated artifact is normally written under `event_app/build/app/outputs/flutter-apk/`. A packaged Android build is also available from the [v1.0.1 GitHub release](https://github.com/mayankbohara0-dev/Event-Management-Collage/releases/tag/v1.0.1). The promotional page in [`landing_page/index.html`](./landing_page/index.html) links directly to the release APK.

## Push-notification deployment

The notification function is located at [`supabase/functions/send-fcm/index.ts`](./supabase/functions/send-fcm/index.ts). It expects the following Supabase project secrets:

| Secret | Purpose |
| --- | --- |
| `SUPABASE_URL` | Supabase project URL used by the Edge Function |
| `SUPABASE_SERVICE_ROLE_KEY` | Server-side Supabase access for reading device tokens |
| `FIREBASE_SERVICE_ACCOUNT` | Firebase service-account JSON used to obtain an FCM access token |

Keep these values in Supabase’s server-side secret store. The service-role key and Firebase service-account JSON must never be bundled into the Flutter application or committed to the repository.

## Testing and code quality

Run the available checks from the Flutter project directory:

```bash
flutter analyze
flutter test
```

The repository currently contains a placeholder widget test in [`event_app/test/widget_test.dart`](./event_app/test/widget_test.dart). Expanding this into authentication, registration, QR check-in, notification, and administrator-flow tests would be a valuable next step.

## Security notes

The repository contains client configuration and integration wiring for Supabase and Firebase. Public client configuration can be appropriate for a Flutter application when database access is protected by Row Level Security, but all credentials should still be reviewed before a production deployment. In particular, rotate any credential that was unintentionally exposed, keep service-role and service-account secrets server-side, and consider moving environment-specific values out of tracked source files.

Before applying database scripts to a live project, review the policies and webhook configuration in the `supabase/` directory. Test administrator actions, storage permissions, registration access, and notification delivery with separate student and administrator accounts.

## Roadmap ideas

Useful follow-up improvements include adding comprehensive automated tests, introducing environment-specific configuration, documenting administrator onboarding and seed-account setup, adding continuous integration for `flutter analyze` and `flutter test`, and separating destructive maintenance actions from the normal administrator dashboard.

## License

No license file is currently included in the repository. Add a `LICENSE` file if you want to define how others may use, modify, and distribute the project.

## Author

Created and maintained by [Mayank Bohara](https://github.com/mayankbohara0-dev).

## References

[1]: https://github.com/mayankbohara0-dev/Event-Management-Collage "Event Collage repository"
[2]: https://docs.flutter.dev/get-started/install "Install Flutter"
[3]: https://supabase.com/docs/guides/getting-started/quickstarts/flutter "Supabase Flutter quickstart"
[4]: https://firebase.google.com/docs/cloud-messaging/flutter/client "Firebase Cloud Messaging for Flutter"
[5]: https://riverpod.dev/ "Riverpod documentation"
[6]: https://pub.dev/packages/go_router "GoRouter package documentation"
