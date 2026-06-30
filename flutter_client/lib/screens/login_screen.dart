import 'package:flutter/material.dart';

import '../config.dart';
import '../state/session.dart';
import '../ui/retro_style.dart';

enum AuthMode { signUp, signIn }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.session});
  final Session session;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  AuthMode _mode = AuthMode.signUp;
  String? _localError;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  bool get _isSignUp => _mode == AuthMode.signUp;

  void _setMode(AuthMode mode) {
    setState(() {
      _mode = mode;
      _localError = null;
    });
  }

  String? _validate() {
    final email = _email.text.trim();
    if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
      return 'Enter a valid email address.';
    }
    if (_password.text.length < 6) {
      return 'Password must be at least 6 characters.';
    }
    if (_isSignUp && _password.text != _confirm.text) {
      return 'Passwords do not match.';
    }
    return null;
  }

  void _submit() {
    final error = _validate();
    if (error != null) {
      setState(() => _localError = error);
      return;
    }
    setState(() => _localError = null);
    final email = _email.text.trim();
    final password = _password.text;
    if (_isSignUp) {
      widget.session.signUp(email, password);
    } else {
      widget.session.signIn(email, password);
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = widget.session.status == SessionStatus.signingIn;
    final hasKey = AppConfig.hasFirebaseApiKey;
    final error = _localError ?? widget.session.errorMessage;
    return RetroBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Northstar')),
        body: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: RetroPanel(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _isSignUp ? 'create your save file' : 'welcome back, player',
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Sign in to enter the live dashboard and manage your game world.',
                        textAlign: TextAlign.center,
                      ),
                      if (!hasKey) ...[
                        const SizedBox(height: 16),
                        _Banner(
                          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.22),
                          textColor: Theme.of(context).colorScheme.onError,
                          text: 'No Firebase API key injected. Use --dart-define=FIREBASE_API_KEY=<key>.',
                        ),
                      ],
                      const SizedBox(height: 20),
                      _PillRow(
                        labels: const [
                          'pixel retro ui',
                          'firebase auth',
                          'live dashboard',
                        ],
                      ),
                      const SizedBox(height: 20),
                      SegmentedButton<AuthMode>(
                        segments: const [
                          ButtonSegment(
                            value: AuthMode.signUp,
                            label: Text('Create'),
                            icon: Icon(Icons.person_add_alt),
                          ),
                          ButtonSegment(
                            value: AuthMode.signIn,
                            label: Text('Login'),
                            icon: Icon(Icons.login),
                          ),
                        ],
                        selected: {_mode},
                        onSelectionChanged: busy ? null : (s) => _setMode(s.first),
                      ),
                      const SizedBox(height: 18),
                      TextField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          hintText: 'you@example.com',
                        ),
                        enabled: !busy,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _password,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          helperText: 'At least 6 characters',
                        ),
                        obscureText: true,
                        enabled: !busy,
                        onSubmitted: (_) => _isSignUp ? null : _submit(),
                      ),
                      if (_isSignUp) ...[
                        const SizedBox(height: 12),
                        TextField(
                          controller: _confirm,
                          decoration: const InputDecoration(
                            labelText: 'Confirm password',
                          ),
                          obscureText: true,
                          enabled: !busy,
                          onSubmitted: (_) => _submit(),
                        ),
                      ],
                      const SizedBox(height: 22),
                      FilledButton(
                        onPressed: busy || !hasKey ? null : _submit,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            busy ? 'Please wait...' : _isSignUp ? 'Create Account' : 'Sign In',
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: busy
                            ? null
                            : () => _setMode(
                                  _isSignUp ? AuthMode.signIn : AuthMode.signUp,
                                ),
                        child: Text(
                          _isSignUp ? 'Already have an account? Sign in' : 'No account? Create one',
                        ),
                      ),
                      if (error != null) ...[
                        const SizedBox(height: 8),
                        _Banner(
                          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.22),
                          textColor: Theme.of(context).colorScheme.onError,
                          text: error,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PillRow extends StatelessWidget {
  const _PillRow({required this.labels});

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [for (final label in labels) Chip(label: Text(label))],
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({
    required this.color,
    required this.textColor,
    required this.text,
  });

  final Color color;
  final Color textColor;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.zero,
        border: Border.all(color: textColor.withValues(alpha: 0.45), width: 2),
      ),
      child: Text(
        text,
        style: TextStyle(color: textColor),
        textAlign: TextAlign.center,
      ),
    );
  }
}
