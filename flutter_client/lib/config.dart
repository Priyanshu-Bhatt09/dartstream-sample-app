import 'package:dartstream_client/dartstream_client.dart';

/// Runtime config for the Northstar Flutter app.
///
/// `FIREBASE_API_KEY` is a public web key for the Firebase project trusted by
/// DartStream. It is injected at build time through `--dart-define`.
class AppConfig {
  static const firebaseApiKey =
      String.fromEnvironment('FIREBASE_API_KEY');

  /// Whether a key was actually injected; the login flow surfaces this.
  static bool get hasFirebaseApiKey => firebaseApiKey.isNotEmpty;

  static DartStreamConfig get dartStreamConfig =>
      DartStreamConfig.dev(firebaseApiKey: firebaseApiKey);
}
