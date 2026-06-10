# Flutter Client

This folder contains the Northstar Flutter web client.

It includes:

- Firebase sign up / sign in
- DartStream session bootstrapping
- a signed-in shell with backend-connected screens
- a Flappy Bird game on the dashboard

## Run

From this folder:

```powershell
flutter pub get
flutter run -d chrome --web-port=3000 --dart-define=FIREBASE_API_KEY=YOUR_KEY
```

## What to expect

- The login screen uses Firebase Email/Password auth.
- After sign-in, the shell opens.
- The dashboard loads live backend data and shows the Flappy Bird game.
- The game stores high score locally in the browser.
