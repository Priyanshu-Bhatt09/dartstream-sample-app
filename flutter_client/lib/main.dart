import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'screens/shell_screen.dart';
import 'state/session.dart';

void main() => runApp(const DartstreamApp());

class DartstreamApp extends StatefulWidget {
  const DartstreamApp({super.key});

  @override
  State<DartstreamApp> createState() => _DartstreamAppState();
}

class _DartstreamAppState extends State<DartstreamApp> {
  final Session _session = Session();

  @override
  void initState() {
    super.initState();
    _session.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF1B6EF3),
      brightness: Brightness.light,
    );
    return MaterialApp(
      title: 'Northstar',
      theme: ThemeData(
        colorScheme: scheme,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6F8FC),
        appBarTheme: AppBarTheme(
          backgroundColor: scheme.surface,
          surfaceTintColor: scheme.surface,
          foregroundColor: scheme.onSurface,
          centerTitle: false,
        ),
      ),
      home: _session.status == SessionStatus.signedIn
          ? ShellScreen(session: _session)
          : LoginScreen(session: _session),
    );
  }
}
