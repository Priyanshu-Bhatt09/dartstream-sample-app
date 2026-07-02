import 'package:flutter/foundation.dart';
import 'package:openfeature_provider_intellitoggle/openfeature_provider_intellitoggle.dart';

import '../config.dart';

class IntelliToggle {
  IntelliToggle._();

  static final IntelliToggle instance = IntelliToggle._();

  bool _registered = false;
  FeatureProvider? _provider;
  final ValueNotifier<List<String>> logs = ValueNotifier<List<String>>(const []);
  Map<String, dynamic> _targeting = const {};

  bool get isConfigured => AppConfig.hasIntelliToggle;
  bool get isReady => _registered && _provider != null;
  FeatureProvider? get provider => _provider;

  String get apiUrl => AppConfig.intelliToggleApiUrl;
  String get clientId => AppConfig.intelliToggleClientId;
  String get tenantId => AppConfig.intelliToggleTenantId;
  String get projectId => AppConfig.intelliToggleProjectId;
  String get environment => AppConfig.intelliToggleEnvironment;
  String get flagKey => AppConfig.intelliToggleFlagKey.isNotEmpty
      ? AppConfig.intelliToggleFlagKey
      : 'enabledarkmode';

  Future<void> register({Map<String, dynamic>? targeting}) async {
    if (!isConfigured) {
      throw StateError(
        'Missing IntelliToggle credentials. Set INTELLITOGGLE_CLIENT_ID, '
        'INTELLITOGGLE_CLIENT_SECRET, and INTELLITOGGLE_TENANT_ID.',
      );
    }
    if (_registered) {
      applyTargeting(targeting ?? _targeting);
      return;
    }

    final provider = IntelliToggleProvider(
      clientId: AppConfig.intelliToggleClientId,
      clientSecret: AppConfig.intelliToggleClientSecret,
      tenantId: AppConfig.intelliToggleTenantId,
      options: IntelliToggleOptions.production(
        baseUri: Uri.parse(
          AppConfig.intelliToggleApiUrl.isNotEmpty
              ? AppConfig.intelliToggleApiUrl
              : 'https://api.intellitoggle.com',
        ),
      ),
    );

    await OpenFeatureAPI().setProvider(provider);
    _provider = provider;
    _registered = true;
    applyTargeting(targeting ?? _targeting);
  }

  Future<void> reconnect({Map<String, dynamic>? targeting}) async {
    _registered = false;
    _provider = null;
    await register(targeting: targeting ?? _targeting);
  }

  void applyTargeting(Map<String, dynamic> targeting) {
    final next = Map<String, dynamic>.from(targeting);
    if (!next.containsKey('targetingKey') && !next.containsKey('key')) {
      final seed = next['userId'] ?? next['email'] ?? next['tenantId'] ?? 'guest';
      next['targetingKey'] = '$seed';
    }
    _targeting = next;
    OpenFeatureAPI().setGlobalContext(OpenFeatureEvaluationContext(_targeting));
    _rebuildClient();
  }

  void _rebuildClient() {
    final provider = _provider;
    if (provider == null) return;
    final client = OpenFeatureAPI().getClient('intellitoggle');
    client.addHook(ConsoleLoggingHook(
      printContext: true,
      domain: 'intellitoggle',
      logger: _appendLog,
    ));
    client.addHook(IntelliToggleTelemetryHook());
  }

  void _appendLog(String message) {
    final next = List<String>.from(logs.value)..add(message);
    if (next.length > 120) next.removeRange(0, next.length - 120);
    logs.value = next;
  }

  void clearLogs() => logs.value = const [];

  Future<FlagEvaluationResult<bool>> getBoolean(
    String flagKey, {
    bool defaultValue = false,
    Map<String, dynamic>? context,
  }) async {
    final provider = _provider;
    if (provider == null) {
      throw StateError('IntelliToggle provider is not ready.');
    }
    return provider.getBooleanFlag(
      flagKey,
      defaultValue,
      context: context ?? _targeting,
    );
  }

  Future<FlagEvaluationResult<String>> getString(
    String flagKey, {
    String defaultValue = '',
    Map<String, dynamic>? context,
  }) async {
    final provider = _provider;
    if (provider == null) {
      throw StateError('IntelliToggle provider is not ready.');
    }
    return provider.getStringFlag(
      flagKey,
      defaultValue,
      context: context ?? _targeting,
    );
  }

  Future<void> track(
    String eventName, {
    num? value,
    Map<String, dynamic> attributes = const {},
  }) async {
    final provider = _provider;
    if (provider == null) {
      throw StateError('IntelliToggle provider is not ready.');
    }
    await provider.track(
      eventName,
      evaluationContext: _targeting,
      trackingDetails:
          TrackingEventDetails(value: value?.toDouble(), attributes: attributes),
    );
  }
}
