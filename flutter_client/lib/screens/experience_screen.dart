import 'package:flutter/material.dart';

import '../api/dartstream.dart';
import '../game/flappy_bird_game.dart';
import '../state/session.dart';

/// Game-focused live view: profile, active Flappy Bird settings, cloud save,
/// and gameplay telemetry. This screen intentionally avoids unrelated demo
/// concepts like inventory or connectors.
class ExperienceScreen extends StatefulWidget {
  const ExperienceScreen({super.key, required this.session});
  final Session session;

  @override
  State<ExperienceScreen> createState() => _ExperienceScreenState();
}

class _ExperienceScreenState extends State<ExperienceScreen> {
  DartstreamApi get _api => widget.session.api!;
  String get _userId => widget.session.userId!;
  String get _tenantId => widget.session.tenantId!;

  bool _loading = true;
  Object? _error;
  Map<String, dynamic>? _profile;
  Map<String, dynamic>? _cloudSave;
  List<dynamic> _flags = const [];
  List<dynamic> _events = const [];
  List<dynamic> _sessions = const [];
  FlappyBirdGameSettings _gameSettings = const FlappyBirdGameSettings(
    gravity: 920,
    pipeSpeed: 190,
    pipeGap: 170,
    spawnInterval: 1.45,
    hardMode: false,
  );

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _api.profile(userId: _userId, tenantId: _tenantId),
        _api.loadSnapshot(userId: _userId, tenantId: _tenantId, slotKey: 'flappy'),
        _api.listFeatureFlags(tenantId: _tenantId),
        _api.activeSessions(userId: _userId, tenantId: _tenantId),
      ]);

      final flags = results[2] as List<dynamic>;
      final settings = FlappyBirdGameSettings.fromFlags(flags);
      final snapshot = results[1] as Map<String, dynamic>?;

      if (!mounted) return;
      setState(() {
        _profile = results[0] as Map<String, dynamic>;
        _cloudSave = snapshot;
        _flags = flags;
        _sessions = results[3] as List<dynamic>;
        _gameSettings = settings;
        _events = const [];
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Could not load the game view:\n$_error',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              FilledButton(onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _profileCard(),
          _gameStateCard(),
          _cloudSaveCard(),
          _activityCard(),
        ],
      ),
    );
  }

  Widget _card(String title, Widget child) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              child,
            ],
          ),
        ),
      );

  Widget _profileCard() {
    final profile = (_profile?['profile'] is Map)
        ? _profile!['profile'] as Map
        : (_profile ?? const {});
    return _card(
      'Player profile',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Email: ${widget.session.email ?? 'unknown'}'),
          Text('User id: ${widget.session.userId ?? 'unknown'}'),
          Text('Tenant id: ${widget.session.tenantId ?? 'unknown'}'),
          Text('Display name: ${profile['displayName'] ?? profile['display_name'] ?? '—'}'),
        ],
      ),
    );
  }

  Widget _gameStateCard() {
    return _card(
      'Flappy Bird state',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hard mode: ${_gameSettings.hardMode ? 'on' : 'off'}'),
          Text('Gravity: ${_gameSettings.gravity}'),
          Text('Pipe speed: ${_gameSettings.pipeSpeed}'),
          Text('Pipe gap: ${_gameSettings.pipeGap}'),
          Text('Spawn interval: ${_gameSettings.spawnInterval}s'),
          Text('Feature flags loaded: ${_flags.length}'),
        ],
      ),
    );
  }

  Widget _cloudSaveCard() {
    final payload = _payloadOf(_cloudSave);
    final highScore = payload?['highScore'] ?? payload?['score'] ?? 0;
    final savedAt = payload?['savedAt'] ?? 'n/a';
    return _card(
      'Cloud save',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('High score: $highScore'),
          Text('Saved at: $savedAt'),
          const SizedBox(height: 8),
          Text(payload == null ? 'No cloud save returned yet.' : payload.toString()),
        ],
      ),
    );
  }

  Widget _activityCard() {
    return _card(
      'Game activity',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Active sessions: ${_sessions.length}'),
          const SizedBox(height: 4),
          if (_sessions.isEmpty)
            const Text('No active sessions returned yet.')
          else
            for (final s in _sessions.take(6)) Text('• ${_session(s)}'),
          const SizedBox(height: 12),
          Text('Recent gameplay events: ${_events.length}'),
          const Text(
            'Gameplay telemetry is written from the game itself, so this view stays focused on the Flappy Bird loop.',
          ),
        ],
      ),
    );
  }

  Map<String, dynamic>? _payloadOf(Map<String, dynamic>? snapshot) {
    final snap = snapshot?['snapshot'];
    if (snap is Map && snap['payload'] is Map<String, dynamic>) {
      return snap['payload'] as Map<String, dynamic>;
    }
    if (snap is Map && snap['payload'] is Map) {
      return Map<String, dynamic>.from(snap['payload'] as Map);
    }
    if (snapshot?['payload'] is Map<String, dynamic>) {
      return snapshot?['payload'] as Map<String, dynamic>;
    }
    if (snapshot?['payload'] is Map) {
      return Map<String, dynamic>.from(snapshot!['payload'] as Map);
    }
    return null;
  }

  String _session(dynamic s) {
    if (s is Map) {
      final id = s['sessionId'] ?? s['id'] ?? '?';
      final state = s['state'] ?? '';
      return '$id${state.toString().isEmpty ? '' : ' ($state)'}';
    }
    return s.toString();
  }
}
