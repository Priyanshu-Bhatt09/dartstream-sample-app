# Northstar App

This repo is a starter template for a Flutter app that uses:

- Firebase for sign up / sign in
- DartStream as the backend
- a simple authenticated shell with backend-connected screens

The goal is to give you the architecture and wiring you need first, without any game or extra product logic.

## What is included

- `bin/smoke.dart` - headless smoke test for the backend contracts
- `bin/auth_deepdive.dart` - deeper auth coverage
- `bin/platform_deepdive.dart` - platform service coverage
- `bin/experience_deepdive.dart` - experience service coverage
- `bin/reactive_deepdive.dart` - reactive service coverage
- `bin/persistence_deepdive.dart` - persistence service coverage
- `flutter_client/` - Flutter web starter app

## Flutter app architecture

The Flutter client is split into a few small layers:

- `main.dart` - app bootstrap and signed-in / signed-out switch
- `state/session.dart` - auth state, session ids, and API client setup
- `api/firebase_auth.dart` - Firebase login and sign up through Identity Toolkit
- `api/dartstream.dart` - typed DartStream API client
- `screens/login_screen.dart` - create account / sign in form
- `screens/shell_screen.dart` - post-login navigation
- `screens/home_screen.dart` - dashboard that proves Firebase and DartStream are connected
- `screens/profile_screen.dart` - user profile and session management
- `screens/feature_flags_screen.dart` - platform feature-flag CRUD
- `screens/experience_screen.dart` - experience data views
- `screens/reactive_screen.dart` - event and subscription CRUD
- `screens/persistence_screen.dart` - persistence CRUD

## First-time setup

1. Create a Firebase project for your app.
2. Add a web app in Firebase and copy the web API key.
3. Configure DartStream to trust that Firebase project.
4. Copy `.env.example` to `.env` and fill in the values.
5. Run the Flutter client with the Firebase key injected at build time.

## Environment variables

From `.env.example`:

- `FIREBASE_API_KEY` - Firebase web API key
- `TEST_EMAIL` / `TEST_PASSWORD` - smoke test credentials
- `API_AUTH` - auth service host
- `API_PLATFORM` - platform service host
- `API_EXPERIENCE` - experience service host
- `API_REACTIVE` - reactive service host
- `API_PERSISTENCE` - persistence service host

## Run the Flutter client

```sh
set -a && source .env && set +a
cd flutter_client
flutter pub get
flutter run -d chrome --web-port=3000 --dart-define=FIREBASE_API_KEY=$FIREBASE_API_KEY
```

On Windows PowerShell, use the equivalent environment loading for your shell.

## How the app works

1. The user signs up or signs in with Firebase.
2. Firebase returns an ID token.
3. The Flutter client sends that token to DartStream.
4. DartStream verifies the token and returns the app user and tenant ids.
5. The app opens the shell and starts loading backend data.

## Why this layout is useful

This starter keeps the important boundaries separate:

- UI code stays in `screens/`
- auth state stays in `state/`
- Firebase logic stays in one auth adapter
- DartStream requests stay in one typed API client

That makes it easy to add your own screens later without rewriting the auth flow.

## Extending it

Add your own product features by creating a new screen and calling the relevant
DartStream endpoint from `api/dartstream.dart`.

## License

[MIT](LICENSE)
