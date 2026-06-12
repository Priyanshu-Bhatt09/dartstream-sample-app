# DS-SAMPLE APP

DS-SAMPLE APP is a Flutter web sample app built on Firebase authentication and the
DartStream client SDK.

It includes:

- Firebase sign up / sign in
- a post-login shell with live service screens
- a Flappy Bird clone powered by live DartStream state
- headless Dart smoke/deep-dive harnesses for the backend contracts

## What was added from the review

- Wired the game to DartStream flags, cloud-save, and reactive events
- Added the public `dartstream_client` package to the Flutter app
- Reintroduced CI for root analysis and Flutter analysis
- Kept the app branded as Northstar instead of the original sample name

## Project layout

```text
.
├── bin/
│   ├── smoke.dart
│   ├── auth_deepdive.dart
│   ├── platform_deepdive.dart
│   ├── experience_deepdive.dart
│   ├── reactive_deepdive.dart
│   └── persistence_deepdive.dart
├── flutter_client/
│   ├── lib/main.dart
│   ├── lib/config.dart
│   ├── lib/state/session.dart
│   ├── lib/api/dartstream.dart
│   ├── lib/screens/login_screen.dart
│   ├── lib/screens/shell_screen.dart
│   ├── lib/screens/home_screen.dart
│   ├── lib/screens/profile_screen.dart
│   ├── lib/screens/feature_flags_screen.dart
│   ├── lib/screens/experience_screen.dart
│   ├── lib/screens/reactive_screen.dart
│   ├── lib/screens/persistence_screen.dart
│   └── lib/game/flappy_bird_game.dart
├── .github/workflows/ci.yml
├── .env.example
└── README.md
```

## Architecture

- `main.dart` decides whether the app shows login or the signed-in shell.
- `state/session.dart` owns auth state and creates the DartStream session.
- `api/dartstream.dart` wraps the public `dartstream_client` SDK.
- `screens/` contains the UI for the dashboard and service views.
- `game/flappy_bird_game.dart` contains the Flappy Bird clone and its
  integration with cloud-save, feature flags, and reactive telemetry.

## How the game uses DartStream

The Flappy Bird clone is not standalone anymore.

- Feature flags change the gameplay settings
- Cloud save restores and stores the best score
- Reactive logging records milestone and game-over events

## Requirements

- Dart SDK `^3.6.0` for the root CLI harnesses
- Flutter `3.44+` for the web client
- A Firebase project with Email/Password enabled
- A DartStream backend configured to trust that Firebase project

## Configuration

Copy the template and fill in your local values:

```powershell
Copy-Item .env.example .env
```

Environment values:

- `FIREBASE_API_KEY` - Firebase web API key
- `TEST_EMAIL` / `TEST_PASSWORD` - credentials for the smoke CLI
- `API_AUTH` - auth service host
- `API_PLATFORM` - platform service host
- `API_EXPERIENCE` - experience service host
- `API_REACTIVE` - reactive service host
- `API_PERSISTENCE` - persistence service host

## Run the root smoke CLI

From the repo root:

```powershell
dart pub get
dart run bin/smoke.dart
```

## Run the Flutter client

From the repo root:

```powershell
cd flutter_client
flutter pub get
flutter run -d chrome --web-port=3000 --dart-define=FIREBASE_API_KEY=YOUR_KEY
```

## Run analysis

```powershell
dart analyze bin
cd flutter_client
flutter analyze
```

## CI

The repo includes `.github/workflows/ci.yml` for:

- `dart analyze bin`
- `flutter analyze`

## Notes

- The Flutter app now uses the public `dartstream_client` package.
- The game saves the high score locally and in DartStream cloud-save.
- The dashboard is intentionally simple so the architecture stays clear.

## License

[MIT](LICENSE)
