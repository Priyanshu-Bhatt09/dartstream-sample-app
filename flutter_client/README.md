# Flutter Client

This folder contains the Flutter web starter app for the DartStream sample.

It includes:

- Firebase sign up / sign in
- DartStream session bootstrapping
- a signed-in shell with backend-connected screens

Run it from this folder:

```sh
flutter pub get
flutter run -d chrome --web-port=3000 --dart-define=FIREBASE_API_KEY=<your-key>
```
