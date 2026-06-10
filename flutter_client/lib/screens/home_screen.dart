import 'package:flutter/material.dart';
import 'package:flame/game.dart';

import '../api/dartstream.dart';
import '../game/flappy_bird_game.dart';
import '../state/session.dart';

/// Simple dashboard: one bootstrap that loads the live session plus the six
/// service snapshots this app is built around.
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

  late final FlappyBirdGame _game;
  bool _loading = true;
  Object? _error;
  Map<String, dynamic>? _authMe;
  Map<String, dynamic>? _profile;
  Map<String, dynamic>? _featureFlags;
  Map<String, dynamic>? _inventory;
  List<dynamic> _channels = const [];

  @override
  void initState() {
    super.initState();
    _game = FlappyBirdGame(onChanged: _syncGameUi);
    _load();
  }

  void _syncGameUi() {
    if (mounted) {
      setState(() {});
    }
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
        _api.featureFlags(tenantId: _tenantId),
        _api.inventory(userId: _userId, tenantId: _tenantId),
        _api.streamingChannels(tenantId: _tenantId),
      ]);

      if (!mounted) return;
      setState(() {
        _authMe = results[0] as Map<String, dynamic>;
        _profile = results[1] as Map<String, dynamic>;
        _featureFlags = results[2] as Map<String, dynamic>;
        _inventory = results[3] as Map<String, dynamic>;
        _channels = results[4] as List<dynamic>;
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
              'A clean, simple dashboard that boots one session and shows the '
              'live services behind it.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text(widget.session.email ?? 'signed-in user')),
                Chip(label: Text('services: 6')),
                Chip(label: Text('session live')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _gameCard() {
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
                        'Tap to jump. Avoid pipes. Score and high score save locally.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    Chip(label: Text('Score: ${_game.score}')),
                    Chip(label: Text('Best: ${_game.highScore}')),
                    if (_game.isGameOver)
                      Chip(
                        label: const Text('Game over'),
                        backgroundColor:
                            Theme.of(context).colorScheme.errorContainer,
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    GameWidget(game: _game),
                    Positioned(
                      left: 12,
                      bottom: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.82),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          _game.isGameOver
                              ? 'Tap anywhere or press restart'
                              : 'Tap anywhere to jump',
                        ),
                      ),
                    ),
                    if (_game.isGameOver)
                      Positioned(
                        right: 12,
                        bottom: 12,
                        child: FilledButton(
                          onPressed: _game.restart,
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
      ('Flags', _featureFlags == null ? 'loading' : '${_flagCount()}'),
      ('Inventory', _inventory == null ? 'loading' : '${_itemCount()}'),
      ('Channels', '$_channelCount'),
      ('Session', '${widget.session.status.name}'),
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
    final parts = <String>[];
    for (final key in const ['displayName', 'providerKey', 'mode']) {
      if (profile[key] != null) {
        parts.add('$key: ${profile[key]}');
      }
    }
    return parts.isEmpty ? _profile.toString() : parts.join('\n');
  }

  String _featureFlagsSummary() {
    final flags = _featureFlags?['flags'];
    if (flags is List && flags.isNotEmpty) {
      return flags.take(8).map((f) => '- $f').join('\n');
    }
    return 'No feature flags returned yet.';
  }

  String _inventorySummary() {
    final inv = (_inventory?['inventory'] is Map)
        ? _inventory!['inventory'] as Map
        : (_inventory ?? const {});
    final items = inv['items'];
    if (items is List && items.isNotEmpty) {
      return items.take(8).map((item) => '- ${item.toString()}').join('\n');
    }
    return 'No inventory items returned yet.';
  }

  int _flagCount() {
    final flags = _featureFlags?['flags'];
    return flags is List ? flags.length : 0;
  }

  int _itemCount() {
    final inv = (_inventory?['inventory'] is Map)
        ? _inventory!['inventory'] as Map
        : (_inventory ?? const {});
    final items = inv['items'];
    return items is List ? items.length : 0;
  }

  int get _channelCount => _channels.length;
}
