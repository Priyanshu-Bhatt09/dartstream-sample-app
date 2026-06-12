import 'package:dartstream_client/dartstream_client.dart' as ds;
import 'package:flutter/foundation.dart';

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
      );
      email = connection.session.email;
      userId = connection.session.userId;
      tenantId = connection.session.tenantId;
      status = SessionStatus.signedIn;
    } catch (e) {
      status = SessionStatus.error;
      errorMessage = _readable(e);
    }
    notifyListeners();
  }

  String _readable(Object e) {
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
}
