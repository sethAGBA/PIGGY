# Repository Guidelines

## Project Structure & Module Organization
- `lib/` contains the Flutter app source (`main.dart` is the entry point).
- `test/` holds widget and unit tests (example: `test/widget_test.dart`).
- Platform scaffolding lives in `android/`, `ios/`, `web/`, `macos/`, `linux/`, and `windows/`.
- `pubspec.yaml` defines dependencies, assets, and app metadata.

## Build, Test, and Development Commands
- `flutter pub get` installs Dart/Flutter dependencies.
- `flutter run` launches the app on a connected device or simulator.
- `flutter test` runs the test suite in `test/`.
- `flutter analyze` runs the static analyzer with `flutter_lints`.
- `flutter build <platform>` produces release builds (e.g., `flutter build apk`).

## Coding Style & Naming Conventions
- Use Dart formatting (`dart format .`) and follow `flutter_lints` in `analysis_options.yaml`.
- Prefer lower_snake_case for file names and lowerCamelCase for variables/functions.
- Keep widgets in `lib/` small and composable; name widgets with UpperCamelCase.

## Testing Guidelines
- Tests live under `test/` and use `flutter_test`.
- Name test files with `_test.dart` (example: `widget_test.dart`).
- Run targeted tests with `flutter test test/widget_test.dart`.

## Commit & Pull Request Guidelines
- No Git history is available in this checkout, so no commit message convention is documented.
- For new work, use short, imperative commit messages (e.g., "Add onboarding screen").
- PRs should include a summary, testing notes, and screenshots for UI changes.

## Configuration & Assets
- Register new assets or fonts in `pubspec.yaml` under `flutter:`.
- Keep platform-specific configuration in the respective platform directories.
