# Flappy Bird game

DartStream is a Flutter web app that uses Firebase for authentication and a
DartStream backend for the signed-in workspace.

The app has three main parts:

- a Firebase login screen
- a live dashboard that loads session, profile, inventory, flags, and channels
- a simple Flappy Bird game with score, game over, and local high score

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
│   ├── lib/state/session.dart
│   ├── lib/api/firebase_auth.dart
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
├── .env.example
└── README.md
```

## How it works

1. The user signs in or creates an account with Firebase.
2. Firebase returns an ID token.
3. The app sends that token to DartStream.
4. DartStream verifies the token and returns the app user and tenant IDs.
5. The shell opens and the dashboard loads live backend data.
6. The Flappy Bird game runs inside the dashboard and saves the best score
   locally in the browser.

## What the dashboard shows

The main dashboard bootstraps these live views:

- auth session summary
- experience profile
- platform feature flags
- inventory
- streaming channels
- Flappy Bird score and high score

The app keeps the dashboard intentionally simple so the important parts are
easy to understand.

## Requirements

- Dart SDK `^3.12`
- Flutter `3.44+`
- Chrome for the web client
- A Firebase project with Email/Password authentication enabled
- DartStream backend endpoints that trust the same Firebase project

## Configuration

Copy the example environment file and fill it in:

```powershell
Copy-Item .env.example .env
```

Environment values used by the repo:

- `FIREBASE_API_KEY` - Firebase web API key
- `TEST_EMAIL` / `TEST_PASSWORD` - credentials for the smoke CLI
- `API_AUTH` - auth service host
- `API_PLATFORM` - platform service host
- `API_EXPERIENCE` - experience service host
- `API_REACTIVE` - reactive service host
- `API_PERSISTENCE` - persistence service host

For the Flutter web client, pass the Firebase key at build time:

```powershell
--dart-define=FIREBASE_API_KEY=YOUR_KEY
```

## Run the smoke CLI

From the repo root:

```powershell
dart pub get
dart run bin/smoke.dart
```

The smoke CLI signs in with Firebase, calls the auth backend, and then checks
the live service endpoints.

## Run the Flutter web client

From the repo root:

```powershell
cd flutter_client
flutter pub get
flutter run -d chrome --web-port=3000 --dart-define=FIREBASE_API_KEY=YOUR_KEY
```

If you use PowerShell, set `FIREBASE_API_KEY` in the current session before
running Flutter, or paste the key directly into `--dart-define`.

## Screens

- `LoginScreen` - create account / sign in with Firebase
- `ShellScreen` - post-login navigation
- `HomeScreen` - dashboard plus Flappy Bird clone
- `ProfileScreen` - user profile and sessions
- `FeatureFlagsScreen` - feature flags
- `ExperienceScreen` - experience service views
- `ReactiveScreen` - reactive events and resources
- `PersistenceScreen` - persistence resources

## Notes

- The app is designed around a live backend, not mocks.
- High score for the Flappy Bird game is stored locally in the browser.
- The dashboard is intentionally minimal so it feels like a real app rather
  than a demo shell.

## License

[MIT](LICENSE)
