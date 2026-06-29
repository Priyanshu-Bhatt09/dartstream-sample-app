import 'package:dartstream_client/dartstream_client.dart' as ds;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/dartstream.dart';
import '../config.dart';

enum SessionStatus { signedOut, signingIn, signedIn, error }

class Session extends ChangeNotifier {
  SessionStatus status = SessionStatus.signedOut;
  String? email;
  String? userId;
  String? tenantId;
  String? errorMessage;
  DartstreamApi? api;
  ds.DartStreamClient? sdkClient;
  ds.DartStreamSession? sdkSession;

  /// Create a new account, then bootstrap the DartStream session.
  Future<void> signUp(String email, String password) =>
      _authenticate(() => ds.DartStreamClient.signUp(
            config: AppConfig.dartStreamConfig,
            email: email,
            password: password,
          ));

  /// Sign in to an existing account, then sync the DartStream session.
  Future<void> signIn(String email, String password) =>
      _authenticate(() => ds.DartStreamClient.signIn(
            config: AppConfig.dartStreamConfig,
            email: email,
            password: password,
          ));

  Future<void> _authenticate(
    Future<ds.DartStreamConnection> Function() auth,
  ) async {
    status = SessionStatus.signingIn;
    errorMessage = null;
    notifyListeners();
    try {
      final connection = await auth();
      sdkClient = connection.client;
      sdkSession = connection.session;
      api = DartstreamApi(
        client: connection.client,
        session: connection.session,
        onUnauthorized: signOut,
      );
      email = connection.session.email;
      userId = connection.session.userId;
      tenantId = connection.session.tenantId;
      await _maybeSeedMarketingDemoData();
      status = SessionStatus.signedIn;
    } catch (e) {
      status = SessionStatus.error;
      errorMessage = _readable(e);
    }
    notifyListeners();
  }

  String _readable(Object e) {
    if (e is ds.DartStreamApiException) {
      return 'HTTP ${e.statusCode}: ${e.body}';
    }
    final s = e.toString();
    return s.startsWith('DartStreamFirebaseAuthException: ')
        ? s.substring('DartStreamFirebaseAuthException: '.length)
        : s;
  }

  void signOut() {
    status = SessionStatus.signedOut;
    email = null;
    userId = null;
    tenantId = null;
    errorMessage = null;
    api = null;
    sdkClient = null;
    sdkSession = null;
    notifyListeners();
  }

  Future<void> _maybeSeedMarketingDemoData() async {
    if (!AppConfig.hasMarketingDemoSeed || api == null) return;
    if (tenantId == null || userId == null) return;

    final marker = 'marketing-demo-seeded:$tenantId:$userId';
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(marker) == true) return;

    try {
      await Future.wait([
        api!.createFeatureFlag(
          tenantId: tenantId!,
          key: 'marketing-demo-mode',
          name: 'Marketing demo mode',
          description: 'Keeps the sample app looking alive for screenshots.',
          enabled: true,
        ),
        api!.logEvent(
          tenantId: tenantId!,
          eventType: 'marketing.demo.launch',
          payload: {
            'source': 'sample-app',
            'surface': 'home',
            'kind': 'screenshot-seed',
          },
        ),
        api!.logEvent(
          tenantId: tenantId!,
          eventType: 'marketing.demo.session_ready',
          payload: {
            'source': 'sample-app',
            'surface': 'experience',
            'kind': 'screenshot-seed',
          },
        ),
        api!.persistenceCreate(
          tenantId: tenantId!,
          subpath: '/logging/entries',
          body: {
            'level': 'info',
            'message': 'Marketing demo seed: dashboard warmed up.',
            'source': 'sample-app',
          },
        ),
        api!.persistenceCreate(
          tenantId: tenantId!,
          subpath: '/logging/entries',
          body: {
            'level': 'info',
            'message': 'Marketing demo seed: screenshots can show live data.',
            'source': 'sample-app',
          },
        ),
      ]);
      await prefs.setBool(marker, true);
    } catch (_) {
      // Demo seeding is best-effort; auth should still succeed if it fails.
    }
  }
}
