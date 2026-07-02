# Flutter Client

This folder contains the Northstar Flutter web client.

It includes:

- Firebase sign up / sign in through the DartStream dev backend
- DartStream session bootstrapping
- a signed-in shell with backend-connected screens
- a Flappy Bird game on the dashboard
- a dedicated IntelliToggle screen for flags, targeting, and telemetry
- SDK contract tests for the cloud-save and reactive event envelopes

## Run

From this folder:

```powershell
flutter pub get
flutter run -d chrome --web-port=3000 `
  --dart-define=FIREBASE_API_KEY=YOUR_KEY `
  --dart-define=INTELLITOGGLE_API_URL=https://api.intellitoggle.com `
  --dart-define=INTELLITOGGLE_CLIENT_ID=YOUR_CLIENT_ID `
  --dart-define=INTELLITOGGLE_CLIENT_SECRET=YOUR_CLIENT_SECRET `
  --dart-define=INTELLITOGGLE_TENANT_ID=YOUR_TENANT_ID `
  --dart-define=INTELLITOGGLE_PROJECT_ID=YOUR_PROJECT_ID `
  --dart-define=INTELLITOGGLE_ENVIRONMENT=development `
  --dart-define=INTELLITOGGLE_FLAG_KEY=enabledarkmode
```

## What to expect

- The login screen uses Firebase Email/Password auth.
- After sign-in, the shell opens.
- The dashboard loads live backend data and shows the Flappy Bird game.
- The shell includes an IntelliToggle tab where you can inspect the provider,
  change targeting, evaluate flags, and watch hook logs.
- The game stores high score locally in the browser.
- The game also persists cloud-save and gameplay telemetry through DartStream.
