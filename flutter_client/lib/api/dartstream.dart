import 'package:dartstream_client/dartstream_client.dart' as ds;
import 'package:flutter/foundation.dart';

class DartstreamApiException implements Exception {
  DartstreamApiException(this.statusCode, this.body, {this.uri});
  final int statusCode;
  final String body;
  final Uri? uri;
  @override
  String toString() => 'DartstreamApiException($statusCode): $body';
}

class DartstreamApi {
  DartstreamApi({
    required this.client,
    required this.session,
    this.onUnauthorized,
  });

  final ds.DartStreamClient client;
  ds.DartStreamSession session;
  final VoidCallback? onUnauthorized;

  static const ds.DartStreamScope _scope = ds.DartStreamScope(
    projectId: 'northstar',
    environmentId: 'development',
  );

  Future<Map<String, dynamic>> me() =>
      _guard(() => client.me(session: session));

  Future<Map<String, dynamic>> getUser({
    required String userId,
    required String tenantId,
  }) async {
    final user = await _guard(() => client.auth.getUser(session, userId: userId));
    return {'user': user, 'tenantId': tenantId};
  }

  Future<Map<String, dynamic>> updateUser({
    required String userId,
    required String tenantId,
    required Map<String, dynamic> changes,
  }) async {
    final updated = await _guard(
      () => client.auth.updateUser(
        session,
        userId: userId,
        displayName: changes['displayName']?.toString(),
        photoUrl: changes['photoUrl']?.toString(),
        clearPhotoUrl: changes['photoUrl'] == null,
        customAttributes: changes['customAttributes'] is Map
            ? Map<String, String>.from(changes['customAttributes'] as Map)
            : null,
      ),
    );
    return {'user': updated, 'tenantId': tenantId};
  }

  Future<List<dynamic>> userSessions({
    required String userId,
    required String tenantId,
  }) =>
      _guard(() => client.auth.userSessions(session, userId: userId));

  Future<void> revokeSession({
    required String userId,
    required String tenantId,
    required String sessionId,
  }) async {
    await _guard(() => client.auth.revokeSession(session, sessionId, userId: userId));
  }

  Future<void> revokeAllSessions({
    required String userId,
    required String tenantId,
  }) async {
    await _guard(() => client.auth.revokeAllSessions(session, userId: userId));
  }

  Future<Uint8List?> avatarBytes({
    required String userId,
    required String tenantId,
  }) =>
      _guard(() => client.auth.avatarBytes(session, userId: userId));

  Future<void> uploadAvatar({
    required String userId,
    required String tenantId,
    required String imageDataUrl,
    required String contentType,
  }) => _guard(
        () => client.auth.uploadAvatar(
          session,
          userId: userId,
          image: imageDataUrl,
          contentType: contentType,
        ),
      );

  Future<void> deleteAvatar({
    required String userId,
    required String tenantId,
  }) async {
    await _guard(() => client.auth.deleteAvatar(session, userId: userId));
  }

  Future<Map<String, dynamic>> featureFlags({required String tenantId}) async {
    final flags = await _guard(() => client.platform.listFeatureFlags(session));
    return {'flags': flags};
  }

  Future<List<dynamic>> listFeatureFlags({required String tenantId}) =>
      _guard(() => client.platform.listFeatureFlags(session));

  Future<Map<String, dynamic>> createFeatureFlag({
    required String tenantId,
    required String key,
    required String name,
    String? description,
    bool enabled = true,
  }) =>
      _guard(() => client.platform.createFeatureFlag(
            session,
            flag: {
              'key': key,
              'name': name,
              if (description != null && description.isNotEmpty)
                'description': description,
              'enabled': enabled,
            },
          ));

  Future<Map<String, dynamic>> updateFeatureFlag({
    required String tenantId,
    required String flagKey,
    required Map<String, dynamic> changes,
  }) =>
      _guard(() => client.platform.updateFeatureFlag(
            session,
            flagKey,
            updates: changes,
          ));

  Future<void> deleteFeatureFlag({
    required String tenantId,
    required String flagKey,
  }) async {
    await _guard(() => client.platform.deleteFeatureFlag(session, flagKey));
  }

  Future<Map<String, dynamic>> profile({
    required String userId,
    required String tenantId,
  }) async {
    final profile = await _guard(
      () => client.experience.playerProfile(session, scope: _scope),
    );
    return {'profile': profile, 'userId': userId, 'tenantId': tenantId};
  }

  Future<Map<String, dynamic>> inventory({
    required String userId,
    required String tenantId,
  }) async {
    final items = await _guard(
      () => client.experience.inventoryItems(session, scope: _scope),
    );
    return {'inventory': {'items': items}, 'userId': userId, 'tenantId': tenantId};
  }

  Future<Map<String, dynamic>?> loadSnapshot({
    required String userId,
    required String tenantId,
    String slotKey = 'flame',
  }) =>
      _guard(
        () => client.experience.loadCloudSave(
          session,
          scope: _scope,
          slotKey: slotKey,
        ),
      );

  Future<Map<String, dynamic>> saveSnapshot({
    required String userId,
    required String tenantId,
    String slotKey = 'flame',
    required Map<String, dynamic> payload,
  }) =>
      _guard(() => client.experience.saveCloudSave(
            session,
            scope: _scope,
            slotKey: slotKey,
            payload: payload,
          ));

  Future<void> logEvent({
    required String tenantId,
    required String eventType,
    required Map<String, dynamic> payload,
  }) =>
      _guard(() => client.reactive.trackEvent(
            session,
            eventType: eventType,
            payload: payload,
          ));

  Future<List<dynamic>> streamingChannels({required String tenantId}) =>
      _guard(() => client.reactive.realtimeChannels(session));

  Future<List<dynamic>> activeSessions({
    required String userId,
    required String tenantId,
  }) =>
      _guard(() => client.experience.activeSessions(session, scope: _scope));

  Future<Map<String, dynamic>> connectors({required String tenantId}) async {
    final connectors =
        await _guard(() => client.experience.connectors(session));
    return {'connectorCategories': connectors};
  }

  Future<List<dynamic>> reactiveList({
    required String tenantId,
    required String subpath,
  }) =>
      _guard(() => client.reactive.list(session, subpath));

  Future<Map<String, dynamic>> reactiveCreate({
    required String tenantId,
    required String subpath,
    required Map<String, dynamic> body,
  }) =>
      _guard(() => client.reactive.create(session, subpath, body: body));

  Future<void> reactiveDelete({
    required String tenantId,
    required String subpath,
  }) async {
    await _guard(() => client.reactive.delete(session, subpath));
  }

  Future<List<dynamic>> persistenceList({
    required String tenantId,
    required String subpath,
  }) =>
      _guard(() => client.persistence.list(subpath, session: session));

  Future<Map<String, dynamic>> persistenceCreate({
    required String tenantId,
    required String subpath,
    required Map<String, dynamic> body,
  }) =>
      _guard(() => client.persistence.create(
            subpath,
            session: session,
            body: body,
          ));

  Future<void> persistenceDelete({
    required String tenantId,
    required String subpath,
  }) async {
    await _guard(() => client.persistence.delete(subpath, session: session));
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on ds.DartStreamApiException catch (e) {
      if (e.statusCode == 401) {
        onUnauthorized?.call();
      }
      throw DartstreamApiException(
        e.statusCode,
        e.body,
        uri: e.uri,
      );
    }
  }
}
