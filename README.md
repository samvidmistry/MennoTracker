# MennoTracker

[![Status](https://img.shields.io/badge/status-CI%20coming%20soon-lightgrey)](#)

MennoTracker is a StrongLifts-style workout tracker for a 5-day bro split with compound maintenance. Version 1 focuses on set-by-set logging, rest timers with haptics, plate math, progression suggestions, and useful history graphs.

The app is designed for iPhone plus Apple Watch while staying friendly to development from Windows. Phone-side Flutter work, Dart business logic, persistence, and package tests can run locally on Windows; macOS-only iOS and watchOS builds are reserved for cloud CI or a borrowed Mac.

The data model keeps room for future program variants, but v1 exposes the 5-day bro split only. Adding another version later should be a data addition rather than an app rewrite.

## Repository layout

| Path | Purpose |
| --- | --- |
| `apps/phone/` | Flutter iOS and Android app. Android is the fast Windows dev loop; iOS hosts the Swift bridge and watch target. |
| `apps/phone/ios/Runner/` | iOS Flutter shell plus Swift bridge code. |
| `apps/phone/ios/MennoWatch/` | Native SwiftUI WatchKit app target bundled into the phone IPA. |
| `apps/phone/ios/MennoWatchTests/` | Watch app tests. |
| `packages/program/` | Pure Dart program definition for workouts, exercises, sets, reps, and rest guidance. |
| `packages/progression/` | Pure Dart autoregulation and progression engine with unit tests. |
| `packages/shared_models/` | Pure Dart shared workout/session models and JSON codecs. |
| `ci/fastlane/` | Fastlane lanes for unsigned iOS builds now and dormant paid-program lanes later. |
| `ci/scripts/` | CI helper scripts. |
| `.github/workflows/` | Dart, Flutter, and iOS build workflows. |
| `docs/` | Setup, install, migration, and program documentation. |

## Quick start on Windows

1. Install Flutter and Dart, then make sure `flutter` and `dart` are on `PATH`.
2. From the repository root, fetch workspace dependencies:
   ```powershell
   flutter pub get
   ```
3. Run phone tests:
   ```powershell
   Set-Location apps\phone
   flutter test
   ```
4. Use an Android emulator for the local development loop:
   ```powershell
   flutter run -d <android-emulator>
   ```

## Documentation

- [AltStore setup](docs/altstore-setup.md)
- [Installing the watch app](docs/installing-watch-app.md)
- [Migrating to the paid Apple Developer Program](docs/migrate-to-paid-program.md)
- [Program specification](docs/program.md)

## Status

CI runs Dart and Flutter checks on pushes and pull requests. iOS packaging is manual-only through the `iOS Package and Release` workflow, which builds an unsigned IPA for AltStore and attaches it to a GitHub release.
