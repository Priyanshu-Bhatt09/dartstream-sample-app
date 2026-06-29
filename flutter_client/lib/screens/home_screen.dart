import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../api/dartstream.dart';
import '../game/flappy_bird_game.dart';
import '../state/session.dart';

/// Clean dashboard: one bootstrap that loads the live session, a Flappy Bird
/// clone powered by DartStream, and the core service snapshots this app is
/// built around.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.session});
  final Session session;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DartstreamApi get _api => widget.session.api!;
  String get _userId => widget.session.userId!;
  String get _tenantId => widget.session.tenantId!;

  bool _loading = true;
  Object? _error;
  Map<String, dynamic>? _authMe;
  Map<String, dynamic>? _profile;
  List<dynamic> _flags = const [];
  List<dynamic> _inventory = const [];
  List<dynamic> _channels = const [];
  Map<String, dynamic>? _cloudSave;
  FlappyBirdGame? _game;
  FlappyBirdGameSettings _gameSettings =
      const FlappyBirdGameSettings(
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
        _api.me(),
        _api.profile(userId: _userId, tenantId: _tenantId),
        _api.listFeatureFlags(tenantId: _tenantId),
        _api.inventory(userId: _userId, tenantId: _tenantId),
        _api.streamingChannels(tenantId: _tenantId),
        _api.loadSnapshot(userId: _userId, tenantId: _tenantId, slotKey: 'flappy'),
      ]);

      final flags = results[2] as List<dynamic>;
      final settings = FlappyBirdGameSettings.fromFlags(flags);
      if (!mounted) return;

      setState(() {
        _authMe = results[0] as Map<String, dynamic>;
        _profile = results[1] as Map<String, dynamic>;
        _flags = flags;
        _inventory = ((results[3] as Map<String, dynamic>)['inventory'] is Map)
            ? ((results[3] as Map<String, dynamic>)['inventory'] as Map)['items'] as List<dynamic>? ?? const []
            : const [];
        _channels = results[4] as List<dynamic>;
        _cloudSave = results[5] as Map<String, dynamic>?;
        _gameSettings = settings;
        _game = FlappyBirdGame(
          api: _api,
          userId: _userId,
          tenantId: _tenantId,
          settings: settings,
          onChanged: () {
            if (mounted) setState(() {});
          },
        );
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
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Could not load the dashboard:\n$_error',
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
          _heroCard(),
          const SizedBox(height: 12),
          _gameCard(),
          const SizedBox(height: 12),
          _metricsRow(),
          const SizedBox(height: 12),
          _section(
            title: 'Live bootstrap',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Signed in as ${widget.session.email ?? 'unknown'}'),
                Text('User id: $_userId'),
                Text('Tenant id: $_tenantId'),
                Text('Firebase token verified by DartStream'),
              ],
            ),
          ),
          _section(title: 'Cloud save', child: Text(_cloudSaveSummary())),
          _section(title: 'Profile snapshot', child: Text(_profileSummary())),
          _section(
            title: 'Platform flags',
            child: Text(_featureFlagsSummary()),
          ),
          _section(title: 'Inventory', child: Text(_inventorySummary())),
          _section(
            title: 'Streaming channels',
            child: _channels.isEmpty
                ? const Text('No channels returned yet.')
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final c in _channels.take(6))
                        Text('- ${c.toString()}'),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _heroCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Workspace ready',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'A clean dashboard plus a live Flappy Bird clone powered by '
              'DartStream features.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text(widget.session.email ?? 'signed-in user')),
                Chip(label: Text('services: 6')),
                Chip(label: Text(_gameSettings.hardMode ? 'hard mode' : 'normal mode')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _gameCard() {
    final game = _game;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Flappy Bird Clone',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap to jump. Avoid pipes. Score and high score save locally and in DartStream.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    Chip(label: Text('Score: ${game?.score ?? 0}')),
                    Chip(label: Text('Best: ${game?.highScore ?? 0}')),
                    Chip(label: Text(_gameSettings.hardMode ? 'Hard' : 'Normal')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: game == null
                    ? const ColoredBox(
                        color: Color(0xFFEAF3FF),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : Stack(
                        fit: StackFit.expand,
                        children: [
                          GameWidget(game: game),
                          Positioned(
                            left: 12,
                            bottom: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.84),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                game.isGameOver
                                    ? 'Tap to restart'
                                    : 'Tap anywhere to jump',
                              ),
                            ),
                          ),
                          if (game.isGameOver)
                            Positioned(
                              right: 12,
                              bottom: 12,
                              child: FilledButton(
                                onPressed: game.restart,
                                child: const Text('Restart'),
                              ),
                            ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricsRow() {
    final cards = [
      ('Auth', _authMe == null ? 'loading' : 'ok'),
      ('Profile', _profile == null ? 'loading' : 'ok'),
      ('Flags', '${_flags.length}'),
      ('Inventory', '${_inventory.length}'),
      ('Channels', '$_channelCount'),
      ('Session', widget.session.status.name),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final cols = width > 1100
            ? 6
            : width > 800
                ? 3
                : 2;
        final cardWidth = (width - (cols - 1) * 12) / cols;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final card in cards)
              SizedBox(
                width: cardWidth,
                child: _metricCard(card.$1, card.$2),
              ),
          ],
        );
      },
    );
  }

  Widget _metricCard(String label, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }

  Widget _section({required String title, required Widget child}) {
    return Card(
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
  }

  String _profileSummary() {
    final profile = (_profile?['profile'] is Map)
        ? _profile!['profile'] as Map
        : (_profile ?? const {});
    final session = widget.session.sdkSession;
    final parts = <String>[];
    for (final key in const ['displayName', 'providerKey', 'mode', 'id']) {
      final value = profile[key] ?? _profile?[key];
      if (value != null) {
        parts.add('$key: $value');
      }
    }
    if (parts.isEmpty && session != null) {
      parts.add('displayName: ${widget.session.email ?? session.email ?? 'unknown'}');
      parts.add('providerKey: ${session.raw['providerKey'] ?? session.raw['provider_type'] ?? 'session'}');
      parts.add('mode: ${session.raw['mode'] ?? 'live'}');
      parts.add('id: ${session.userId}');
    }
    return parts.isEmpty ? _profile.toString() : parts.join('\n');
  }

  String _featureFlagsSummary() {
    if (_flags.isNotEmpty) {
      return _flags.take(8).map((f) => '- $f').join('\n');
    }
    return 'No feature flags returned yet.';
  }

  String _inventorySummary() {
    if (_inventory.isNotEmpty) {
      return _inventory.take(8).map((item) => '- ${item.toString()}').join('\n');
    }
    return 'No inventory items returned yet.';
  }

  String _cloudSaveSummary() {
    if (_cloudSave == null) return 'No cloud save returned yet.';
    final payload = _cloudSave?['snapshot'] is Map
        ? (_cloudSave!['snapshot'] as Map)['payload']
        : _cloudSave?['payload'];
    return payload == null ? _cloudSave.toString() : payload.toString();
  }

  int get _channelCount => _channels.length;
}
