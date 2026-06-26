# DS-SAMPLE APP

DS-SAMPLE APP is a Flutter web sample app built on the public DartStream client
SDK, with Firebase Email/Password auth as the upstream identity source for the
dev backend.

It includes:

- Firebase sign up / sign in
- a post-login shell with live service screens
- a Flappy Bird clone powered by live DartStream state
- headless Dart smoke/deep-dive harnesses for the backend contracts

## What is already wired

- The Flutter client uses the public `dartstream_client` package.
- There is one auth path in the app: Firebase Email/Password through
  `DartStreamClient.signIn` / `signUp`, which bootstraps a live DartStream
  session.
- The game is driven by live DartStream feature flags, cloud-save, and reactive
  telemetry.
- Cloud-save and event envelope contract tests are present in
  `flutter_client/test/`.
- CI runs analysis, tests, and a fresh web build with a dummy define.

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
- `state/session.dart` owns auth state, surfaces typed errors, and clears the
  session on `401`.
- `api/dartstream.dart` wraps the public `dartstream_client` SDK and forwards
  unauthorized failures to the session layer.
- `screens/` contains the UI for the dashboard and service views.
- `game/flappy_bird_game.dart` contains the Flappy Bird clone and its
  integration with cloud-save, feature flags, and reactive telemetry.

## How the game uses DartStream

The Flappy Bird clone is not standalone anymore.

- Feature flags change the gameplay settings.
- Cloud save restores and stores the best score using the required
  `{'payload': ...}` envelope.
- Reactive logging records milestone and game-over events with snake_case
  `event_type`.

## Requirements

- Dart SDK `>=3.12.0`
- A current stable Flutter SDK that can build the web client
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
flutter test
flutter build web --dart-define=FIREBASE_API_KEY=dummy
```

## CI

The repo includes `.github/workflows/ci.yml` for:

- `dart analyze bin`
- `flutter analyze`
- `flutter test`
- `flutter build web --dart-define=FIREBASE_API_KEY=dummy`

## Notes

- The Flutter app now uses the public `dartstream_client` package.
- The game saves the high score locally and in DartStream cloud-save.
- The Flutter client includes contract tests for the save and event payloads.
- The app uses one client SDK path and one session bootstrap path.
- The dashboard is intentionally simple so the architecture stays clear.

## License

[MIT](LICENSE)
