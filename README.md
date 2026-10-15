# Tasbih

A Flutter Tasbih counter and daily dhikr app with a cream and green interface.
Counts, targets, custom entries, session progress, and feedback preferences are
stored locally using `shared_preferences`.

## Features

- Tap-to-count Tasbih with progress display, undo, and reset confirmation.
- Personal targets of 33, 100, or a custom value from 1 to 10,000, plus free counting.
- A built-in dhikr library with Arabic text, transliteration, and meaning for its entries, plus custom dhikr.
- Daily dhikr sessions grouped by Fajr, Zuhr, Asr, Maghrib, and Isha, with completion tracking, custom entries, and session reset.
- Individual dhikr counters with completion and next-dhikr actions.
- Optional system click sound and vibration where supported by the device.

Daily sessions retain their progress until reset; the app does not calculate
prayer times or schedule notifications.

## Setup and run

1. Install Flutter with Dart 3.13.1 or later (below Dart 4). The committed dependency lockfile requires Flutter 3.44.0 or later.
2. Install the development tools for your target platform and run `flutter doctor` to check the environment.
3. Clone this repository and open its root directory.
4. Fetch the dependencies and run the app:

```sh
flutter pub get
flutter devices
flutter run -d <device-id>
```

For example, use `flutter run -d chrome` for web or `flutter run -d windows`
on a Windows machine with the Flutter desktop prerequisites installed.
Android, iOS, web, Windows, macOS, and Linux platform folders are included;
their presence does not imply that every platform has been tested.
iOS and macOS builds require macOS and Xcode.

Android configuration currently uses Java 17 and NDK `30.0.15729638`.
Install the matching Android SDK/NDK tooling for Android builds. Local SDK paths
and generated Flutter files are intentionally excluded from version control.

## Checks and builds

```sh
flutter analyze
flutter test
flutter build apk
```

Existing widget tests cover counting, target selection, daily dhikr progress,
reset behavior, and layouts at mobile screen sizes.

The Android release configuration currently uses debug signing and the example
application ID `com.example.tasbih_app`. Configure your own application ID and
release signing before distributing through an app store. Keep signing keys
and credentials outside version control.

## Project layout

- `lib/main.dart`: app theme, navigation, dhikr data, screens, and saved state.
- `lib/counter_widgets.dart`: reusable counter, target, reading, and feedback widgets.
- `assets/images/Icon.png`: source image used by the launcher icon configuration.
- `test/`: widget and mobile layout tests.
- `pubspec.yaml` and `pubspec.lock`: package configuration and locked dependencies.
- Platform folders: native runners, icons, and build configuration.

To regenerate launcher icons after changing the icon source:

```sh
dart run flutter_launcher_icons
```

## Flutter resources

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)
- [Flutter documentation](https://docs.flutter.dev/)
