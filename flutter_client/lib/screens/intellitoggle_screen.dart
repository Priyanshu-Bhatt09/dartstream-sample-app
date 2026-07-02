import 'package:flutter/material.dart';

import '../intellitoggle/flag_aware.dart';
import '../intellitoggle/intellitoggle.dart';
import '../state/session.dart';
import '../ui/app_theme_controller.dart';

class IntelliToggleScreen extends StatefulWidget {
  const IntelliToggleScreen({super.key, required this.session});
  final Session session;

  @override
  State<IntelliToggleScreen> createState() => _IntelliToggleScreenState();
}

class _AttrRow {
  _AttrRow(this.keyText, this.valueText)
      : keyCtl = TextEditingController(text: keyText),
        valueCtl = TextEditingController(text: valueText);
  final String keyText;
  final String valueText;
  final TextEditingController keyCtl;
  final TextEditingController valueCtl;
  void dispose() {
    keyCtl.dispose();
    valueCtl.dispose();
  }
}

class _IntelliToggleScreenState extends State<IntelliToggleScreen> {
  bool _initializing = true;
  Object? _error;
  final _flagKey = TextEditingController(text: 'enabledarkmode');
  final _trackName = TextEditingController(text: 'screen_opened');
  final _trackValue = TextEditingController();
  final List<_AttrRow> _rows = [];
  String? _evaluation;
  bool _busy = false;
  bool _evaluationIsError = false;
  bool _darkMode = false;
  int _widgetTick = 0;

  @override
  void initState() {
    super.initState();
    final s = widget.session;
    _rows.add(_AttrRow('targetingKey', s.userId ?? s.email ?? 'guest'));
    if (s.email != null) _rows.add(_AttrRow('email', s.email!));
    if (s.tenantId != null) _rows.add(_AttrRow('tenantId', s.tenantId!));
    _rows.add(_AttrRow('plan', 'premium'));
    _bootstrap();
  }

  @override
  void dispose() {
    _flagKey.dispose();
    _trackName.dispose();
    _trackValue.dispose();
    for (final row in _rows) {
      row.dispose();
    }
    super.dispose();
  }

  Future<void> _bootstrap() async {
    setState(() {
      _initializing = true;
      _error = null;
    });
    try {
      await IntelliToggle.instance.register(targeting: _targetingMap());
      await _refreshDarkMode();
      if (mounted) setState(() => _initializing = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e;
          _initializing = false;
        });
      }
    }
  }

  Map<String, dynamic> _targetingMap() {
    final map = <String, dynamic>{};
    for (final row in _rows) {
      final key = row.keyCtl.text.trim();
      final value = row.valueCtl.text.trim();
      if (key.isNotEmpty) map[key] = value;
    }
    return map;
  }

  Future<void> _refreshDarkMode() async {
    try {
      final result = await IntelliToggle.instance.getBoolean(
        _flagKey.text.trim().isEmpty ? 'enabledarkmode' : _flagKey.text.trim(),
        defaultValue: false,
      );
      final next = result.value;
      if (!mounted) return;
      setState(() => _darkMode = next);
      AppThemeController.instance.syncDarkMode(next);
    } catch (_) {
      if (!mounted) return;
      setState(() => _darkMode = false);
      AppThemeController.instance.syncDarkMode(false);
    }
  }

  Future<void> _evaluate() async {
    final key = _flagKey.text.trim();
    if (key.isEmpty) return;
    setState(() {
      _busy = true;
      _evaluation = null;
      _evaluationIsError = false;
    });
    try {
      final details = await IntelliToggle.instance.getBoolean(key, defaultValue: false);
      final text = [
        'value: ${details.value}',
        'reason: ${details.reason}',
        if (details.variant != null) 'variant: ${details.variant}',
        if (details.reason == 'ERROR') 'errorCode: ${details.errorCode}',
        if (details.errorMessage != null) 'errorMessage: ${details.errorMessage}',
      ].join('\n');
      if (mounted) {
        setState(() {
          _evaluation = text;
          _evaluationIsError = details.reason == 'ERROR';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _evaluation = e.toString();
          _evaluationIsError = true;
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _track() async {
    final name = _trackName.text.trim();
    if (name.isEmpty) return;
    final rawValue = _trackValue.text.trim();
    final value = rawValue.isEmpty ? null : num.tryParse(rawValue);
    try {
      await IntelliToggle.instance.track(name, value: value);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tracked "$name"')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Track failed: $e')),
        );
      }
    }
  }

  void _applyTargeting() {
    IntelliToggle.instance.applyTargeting(_targetingMap());
    setState(() => _widgetTick++);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Targeting updated for IntelliToggle')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Could not initialize IntelliToggle:\n$_error',
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              const Text(
                'Flutter web reads IntelliToggle settings from --dart-define values, '
                'not from the local .env file at runtime.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              FilledButton(onPressed: _bootstrap, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _bootstrap,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _heroCard(),
          const SizedBox(height: 12),
          _statusCard(),
          const SizedBox(height: 12),
          _targetingCard(),
          const SizedBox(height: 12),
          _evaluatorCard(),
          const SizedBox(height: 12),
          _widgetCard(),
          const SizedBox(height: 12),
          _logsCard(),
        ],
      ),
    );
  }

  Widget _heroCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('IntelliToggle', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            const Text(
              'A dedicated control room for evaluating flags, updating targeting, '
              'and watching the live hook pipeline.',
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text(IntelliToggle.instance.isConfigured ? 'configured' : 'missing env')),
                Chip(label: Text('dark mode: ${_darkMode ? 'on' : 'off'}')),
                Chip(label: Text('project: ${IntelliToggle.instance.projectId.isEmpty ? 'n/a' : IntelliToggle.instance.projectId}')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusCard() {
    final provider = IntelliToggle.instance.provider;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Provider status', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                if (provider != null)
                  Chip(label: Text(provider.state.name))
                else
                  const Chip(label: Text('not-ready')),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _bootstrap,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Reconnect'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('API URL: ${IntelliToggle.instance.apiUrl.isEmpty ? 'n/a' : IntelliToggle.instance.apiUrl}'),
            Text('Tenant: ${IntelliToggle.instance.tenantId.isEmpty ? 'n/a' : IntelliToggle.instance.tenantId}'),
            Text('Environment: ${IntelliToggle.instance.environment.isEmpty ? 'n/a' : IntelliToggle.instance.environment}'),
            Text('Flag key: ${IntelliToggle.instance.flagKey}'),
          ],
        ),
      ),
    );
  }

  Widget _targetingCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Targeting context', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            const Text('Tune the audience that IntelliToggle evaluates against.'),
            const SizedBox(height: 12),
            for (int i = 0; i < _rows.length; i++) _row(i),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => setState(() => _rows.add(_AttrRow('', ''))),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add attribute'),
              ),
            ),
            const SizedBox(height: 4),
            FilledButton.icon(
              onPressed: _applyTargeting,
              icon: const Icon(Icons.tune, size: 18),
              label: const Text('Apply targeting'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(int index) {
    final row = _rows[index];
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: row.keyCtl,
              decoration: const InputDecoration(labelText: 'key', isDense: true),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextField(
              controller: row.valueCtl,
              decoration: const InputDecoration(labelText: 'value', isDense: true),
            ),
          ),
          IconButton(
            onPressed: () => setState(() {
              _rows.removeAt(index).dispose();
            }),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _evaluatorCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Evaluate flag', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _flagKey,
                    decoration: const InputDecoration(
                      labelText: 'Flag key',
                      hintText: 'enabledarkmode',
                    ),
                    onSubmitted: (_) => _evaluate(),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: _busy ? null : _evaluate,
                  child: Text(_busy ? 'Evaluating...' : 'Evaluate'),
                ),
              ],
            ),
            if (_evaluation != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _evaluationIsError
                      ? Theme.of(context).colorScheme.errorContainer
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(_evaluation!, style: const TextStyle(fontFamily: 'monospace')),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _widgetCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Flag-aware widgets', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ItFlagAware(
              key: ValueKey('flag-aware-$_widgetTick'),
              flagKey: 'enabledarkmode',
              onChild: const ListTile(
                leading: Icon(Icons.dark_mode),
                title: Text('Dark mode flag is ON'),
              ),
              offChild: const ListTile(
                leading: Icon(Icons.light_mode_outlined),
                title: Text('Dark mode flag is OFF'),
              ),
            ),
            const Divider(),
            ItExperiment(
              key: ValueKey('experiment-$_widgetTick'),
              flagKey: 'hero-variant',
              defaultVariant: 'calm',
              variants: const {
                'calm': ListTile(
                  leading: Icon(Icons.auto_awesome_outlined),
                  title: Text('Hero variant: calm'),
                ),
                'sharp': ListTile(
                  leading: Icon(Icons.auto_awesome),
                  title: Text('Hero variant: sharp'),
                ),
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _logsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Hook log', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                TextButton(
                  onPressed: IntelliToggle.instance.clearLogs,
                  child: const Text('Clear'),
                ),
              ],
            ),
            ValueListenableBuilder<List<String>>(
              valueListenable: IntelliToggle.instance.logs,
              builder: (context, logs, _) {
                if (logs.isEmpty) {
                  return const Text('No hook activity yet.');
                }
                final recent = logs.reversed.take(20).toList();
                return Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxHeight: 220),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      recent.join('\n'),
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _trackName,
                    decoration: const InputDecoration(labelText: 'Event name'),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 120,
                  child: TextField(
                    controller: _trackValue,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Value'),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _track,
                  icon: const Icon(Icons.analytics_outlined, size: 18),
                  label: const Text('Track'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
