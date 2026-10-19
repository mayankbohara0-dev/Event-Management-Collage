# ZEST — Add some zest to your campus life. 🍋⚡

<p align="center">
  <img src="zest_app_icon.png" width="120" height="120" alt="ZEST App Icon" style="border-radius: 28px;" />
</p>

<p align="center">
  <strong>The Neo-Bold, Gen-Z campus event platform for students, clubs, and universities.</strong>
</p>

<p align="center">
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-3.29+-02569B?logo=flutter&logoColor=white" alt="Flutter" /></a>
  <a href="https://dart.dev"><img src="https://img.shields.io/badge/Dart-3.7+-0175C2?logo=dart&logoColor=white" alt="Dart" /></a>
  <a href="https://supabase.com"><img src="https://img.shields.io/badge/Supabase-Auth%20%7C%20Postgres%20%7C%20Storage-3ECF8E?logo=supabase&logoColor=white" alt="Supabase" /></a>
  <a href="https://firebase.google.com"><img src="https://img.shields.io/badge/Firebase-FCM%20Push-FFCA28?logo=firebase&logoColor=black" alt="Firebase" /></a>
  <a href="https://github.com/mayankbohara0-dev/Event-Management-Collage/releases"><img src="https://img.shields.io/badge/Release-v2.0.0-B8FF1A?labelColor=141416" alt="Release" /></a>
</p>

---

## ✨ Features & Visual Highlights

### 📱 Student App Experience
- **🎨 Neo-Bold & Gen-Z Aesthetic**: Custom dark theme (`#141416` Ink, `#1D1D22` Card surface), Neon Lime accents (`#B8FF1A` & `#C2FF3A → #7DFF2A` gradient), and tight Bricolage Grotesque typography.
- **🏠 Home Feed**:
  - Lime gradient header with date, personal greeting, unread alert counter, and instant search pill.
  - **Journey Card** overlapping the header with big **56sp lime points counter**, live level progression, and watermark.
  - **Featured Spotlight Carousel**: 250×290 solid accent cards with category pills, 64sp emoji, and circular lime arrow buttons.
  - **Fresh Event Rows**: 60px rounded thumbnails, date & venue tags, and responsive "Register" / "Going ✓" buttons.
- **🧭 Dedicated Explore Tab**: Full-screen discovery with real-time search, category chips, and live seat capacity progress bars.
- **🎟️ Interactive Ticket Passes**:
  - Distinctive lime-colored pass with side punch-out notches and dashed divider.
  - **128px QR Code with an animated sweeping laser scan line** for gate check-in.
  - "Upcoming Passes" vs "Attended Events" filter with certificates and XP rewards.
- **🏆 Live Campus Leaderboard**:
  - Top 3 Podium (Gold 👑, Silver 🥈, Bronze 🥉) with custom elevation cards.
  - Weekly vs All-Time filters with animated score bars.
- **👤 Profile & Identity**:
  - 104px avatar with lime-gradient ring and edit badge.
  - Bento stat tiles for XP, Level, and attendance.
  - Verified PRN / Roll number tags and custom notification toggle.
- **📄 Event Details**:
  - 300px banner (bottom radius 42), countdown timer card, seats remaining indicator, and calendar sync (`add_2_calendar`).
  - Sticky bottom register bar featuring press-squish **ZestButton** that transforms into `"You're in! ✓"`.
- **🛸 Floating Pill Navigation**: 5-tab icon navigation with a 48px lime circle indicator that slides with an elastic spring curve.

### 🛡️ Admin & Organizer Suite
- **📊 Real-time Dashboard**: Live registration tracking, check-in analytics, and department breakdown.
- **✏️ Event & Form Builder**: Dynamic question builder (text, dropdown, file upload, roll number, etc.) with auto-approval controls.
- **📷 QR Scanner**: Instant attendee verification with live camera feed and duplicate entry prevention.
- **📥 CSV & Reports**: Export student attendance and responses for university reporting.

---

## 🛠️ Technology Stack

| Component | Technology |
|---|---|
| **Framework** | [Flutter](https://flutter.dev) (iOS, Android, Web) |
| **Language** | [Dart](https://dart.dev) |
| **State Management** | [Riverpod](https://riverpod.dev) |
| **Navigation & Routing** | [GoRouter](https://pub.dev/packages/go_router) |
| **Backend & Database** | [Supabase](https://supabase.com) (PostgreSQL, RLS, Storage) |
| **Push Notifications** | [Firebase Cloud Messaging (FCM)](https://firebase.google.com/docs/cloud-messaging) |
| **Typography** | Bricolage Grotesque (Display) & Inter (UI/Body) |
| **Animations** | Flutter Animation Controllers & `flutter_animate` |
| **QR & Scanning** | `qr_flutter` & `mobile_scanner` |

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.29 or later)
- Android Studio / Xcode
- A Supabase project (apply schemas in `supabase/`)

### Setup Instructions

1. **Clone the repository:**
   ```bash
   git clone https://github.com/mayankbohara0-dev/Event-Management-Collage.git
   cd Event-Management-Collage
   ```

2. **Install Flutter dependencies:**
   ```bash
   cd event_app
   flutter pub get
   ```

3. **Configure Environment:**
   Update your Supabase credentials in `event_app/lib/core/env.dart` or `.env`:
   ```dart
   class Env {
     static const String supabaseUrl = 'YOUR_SUPABASE_URL';
     static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
   }
   ```

4. **Run the App:**
   ```bash
   flutter run
   ```

---

## 📦 Building for Release

### Android APK
```bash
cd event_app
flutter build apk --release
```
The generated APK will be at:
`event_app/build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (Play Store)
```bash
flutter build appbundle --release
```

### GitHub Automated Release
Pushing a version tag automatically triggers GitHub Actions to build the release APK and attach it to a new GitHub Release:
```bash
git tag -a v2.0.0 -m "Release v2.0.0: Complete Zest Gen-Z Redesign"
git push origin v2.0.0
```

---

## 📂 Project Structure

```
Event-Management-Collage/
├── .github/
│   └── workflows/
│       └── release.yml          # Automated APK Build & GitHub Release
├── event_app/                   # Main Flutter application
│   ├── assets/                  # Brand logos, fonts, icons
│   └── lib/
│       ├── core/                # Theme, radius, typography, router, widgets
│       │   ├── theme/           # AppColors, AppRadius, AppTextStyles, AppTheme
│       │   └── widgets/         # ZestButton, FloatingPillNavBar, HeroEventCard, etc.
│       └── features/
│           ├── landing/         # Animated Splash & Marketing Hero
│           ├── auth/            # Student Login & Password Reset
│           ├── home/            # 5-Tab Shell (Feed, Explore, Passes, Leaderboard, Profile)
│           ├── events/          # Event Details, Custom Forms, Registration
│           ├── admin/           # Admin Dashboard, Tables, Scanner, Form Builder
│           └── notifications/   # Campus Activity & Feedback Dialogs
├── landing_page/                # Web marketing site
└── supabase/                    # SQL migrations, RLS policies, schemas
```

---

## 👨‍💻 Author & Maintainer

Maintained by **[Mayank Bohara](https://github.com/mayankbohara0-dev)**.
Contributions and feedback are welcome!
