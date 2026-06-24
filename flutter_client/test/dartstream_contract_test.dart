import 'dart:convert';

import 'package:dartstream_client/dartstream_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  const session = DartStreamSession(
    idToken: 'token',
    userId: 'user-123',
    tenantId: 'tenant-456',
    raw: {},
  );

  test('saveCloudSave wraps payload and scope query parameters', () async {
    final client = DartStreamClient(
      config: DartStreamConfig.dev(),
      httpClient: MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.host, 'dev-apiexperience.dartstream.io');
        expect(request.url.path,
            '/api/v1/experience/cloud-save/snapshot');
        expect(request.url.queryParameters, {
          'userId': 'user-123',
          'tenantId': 'tenant-456',
          'projectId': 'northstar',
          'environmentId': 'development',
          'slotKey': 'flappy',
        });
        expect(request.headers['authorization'], 'Bearer token');
        expect(request.headers['x-tenant-id'], 'tenant-456');
        expect(request.headers['content-type'], 'application/json');
        expect(jsonDecode(request.body), {
          'payload': {
            'score': 19,
            'hardMode': true,
          },
        });
        return http.Response(jsonEncode({'ok': true}), 200);
      }),
    );

    final response = await client.experience.saveCloudSave(
      session,
      scope: const DartStreamScope(
        projectId: 'northstar',
        environmentId: 'development',
      ),
      slotKey: 'flappy',
      payload: const {
        'score': 19,
        'hardMode': true,
      },
    );

    expect(response['ok'], isTrue);
  });

  test('trackEvent sends the reactive event envelope', () async {
    final client = DartStreamClient(
      config: DartStreamConfig.dev(),
      httpClient: MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.host, 'dev-apireactive.dartstream.io');
        expect(request.url.path, '/api/v1/reactive/events/log');
        expect(request.headers['authorization'], 'Bearer token');
        expect(request.headers['x-tenant-id'], 'tenant-456');
        expect(request.headers['content-type'], 'application/json');
        expect(jsonDecode(request.body), {
          'event_type': 'flappy.game_over',
          'payload': {
            'score': 21,
            'hardMode': false,
          },
        });
        return http.Response(jsonEncode({'ok': true}), 200);
      }),
    );

    await client.trackEvent(
      session,
      eventType: 'flappy.game_over',
      payload: const {
        'score': 21,
        'hardMode': false,
      },
    );
  });
}
