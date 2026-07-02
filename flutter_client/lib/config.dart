import 'package:dartstream_client/dartstream_client.dart';

/// Runtime config for the Flappy Bird Game Flutter app.
///
/// `FIREBASE_API_KEY` is a public web key for the Firebase project trusted by
/// DartStream. It is injected at build time through `--dart-define`.
class AppConfig {
  static const firebaseApiKey =
      String.fromEnvironment('FIREBASE_API_KEY');
  static const marketingDemoSeed =
      bool.fromEnvironment('MARKETING_DEMO_SEED', defaultValue: false);
  static const intelliToggleApiUrl =
      String.fromEnvironment('INTELLITOGGLE_API_URL');
  static const intelliToggleTokenUrl =
      String.fromEnvironment('INTELLITOGGLE_TOKEN_URL');
  static const intelliToggleClientId =
      String.fromEnvironment('INTELLITOGGLE_CLIENT_ID');
  static const intelliToggleClientSecret =
      String.fromEnvironment('INTELLITOGGLE_CLIENT_SECRET');
  static const intelliToggleTenantId =
      String.fromEnvironment('INTELLITOGGLE_TENANT_ID');
  static const intelliToggleProjectId =
      String.fromEnvironment('INTELLITOGGLE_PROJECT_ID');
  static const intelliToggleEnvironment =
      String.fromEnvironment('INTELLITOGGLE_ENVIRONMENT');
  static const intelliToggleFlagKey =
      String.fromEnvironment('INTELLITOGGLE_FLAG_KEY');

  /// Whether a key was actually injected; the login flow surfaces this.
  static bool get hasFirebaseApiKey => firebaseApiKey.isNotEmpty;
  static bool get hasMarketingDemoSeed => marketingDemoSeed;
  static bool get hasIntelliToggle =>
      intelliToggleClientId.isNotEmpty &&
      intelliToggleClientSecret.isNotEmpty &&
      intelliToggleTenantId.isNotEmpty;

  static DartStreamConfig get dartStreamConfig =>
      DartStreamConfig.dev(firebaseApiKey: firebaseApiKey);
}
