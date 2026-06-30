import 'package:flutter/material.dart';

class RetroPalette {
  static const bg = Color(0xFF101814);
  static const panel = Color(0xFF1A2A23);
  static const panelAlt = Color(0xFF22372D);
  static const border = Color(0xFF5DF2B7);
  static const borderSoft = Color(0xFF2D6E57);
  static const accent = Color(0xFFFFD166);
  static const text = Color(0xFFF4FFE9);
  static const textMuted = Color(0xFFB6CBB8);
  static const danger = Color(0xFFFF6B6B);
}

ThemeData buildRetroTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: RetroPalette.accent,
    brightness: Brightness.dark,
    surface: RetroPalette.panel,
  ).copyWith(
    primary: RetroPalette.accent,
    secondary: RetroPalette.border,
    surface: RetroPalette.panel,
    error: RetroPalette.danger,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: RetroPalette.bg,
    canvasColor: RetroPalette.bg,
    appBarTheme: const AppBarTheme(
      backgroundColor: RetroPalette.bg,
      foregroundColor: RetroPalette.text,
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontFamily: 'monospace', color: RetroPalette.text, fontWeight: FontWeight.w900),
      headlineMedium: TextStyle(fontFamily: 'monospace', color: RetroPalette.text, fontWeight: FontWeight.w900),
      headlineSmall: TextStyle(fontFamily: 'monospace', color: RetroPalette.text, fontWeight: FontWeight.w800),
      titleLarge: TextStyle(fontFamily: 'monospace', color: RetroPalette.text, fontWeight: FontWeight.w800),
      titleMedium: TextStyle(fontFamily: 'monospace', color: RetroPalette.text, fontWeight: FontWeight.w700),
      bodyLarge: TextStyle(fontFamily: 'monospace', color: RetroPalette.text),
      bodyMedium: TextStyle(fontFamily: 'monospace', color: RetroPalette.text),
      bodySmall: TextStyle(fontFamily: 'monospace', color: RetroPalette.textMuted),
    ),
    cardTheme: const CardThemeData(
      color: RetroPalette.panel,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: RetroPalette.borderSoft, width: 2),
      ),
      margin: EdgeInsets.zero,
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: RetroPalette.panel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: RetroPalette.border, width: 2),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: RetroPalette.panelAlt,
      labelStyle: TextStyle(fontFamily: 'monospace', color: RetroPalette.textMuted),
      hintStyle: TextStyle(fontFamily: 'monospace', color: RetroPalette.textMuted),
      helperStyle: TextStyle(fontFamily: 'monospace', color: RetroPalette.textMuted),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: RetroPalette.borderSoft, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: RetroPalette.borderSoft, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: RetroPalette.border, width: 2),
      ),
    ),
    chipTheme: const ChipThemeData(
      backgroundColor: RetroPalette.panelAlt,
      labelStyle: TextStyle(fontFamily: 'monospace', color: RetroPalette.text),
      side: BorderSide(color: RetroPalette.borderSoft, width: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: RetroPalette.bg.withValues(alpha: 0.92),
      indicatorColor: RetroPalette.accent.withValues(alpha: 0.18),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(
          fontFamily: 'monospace',
          color: RetroPalette.text,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    navigationRailTheme: const NavigationRailThemeData(
      backgroundColor: RetroPalette.bg,
      selectedIconTheme: IconThemeData(color: RetroPalette.accent),
      unselectedIconTheme: IconThemeData(color: RetroPalette.textMuted),
      selectedLabelTextStyle: TextStyle(fontFamily: 'monospace', color: RetroPalette.accent, fontWeight: FontWeight.w700),
      unselectedLabelTextStyle: TextStyle(fontFamily: 'monospace', color: RetroPalette.textMuted),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: RetroPalette.accent,
        foregroundColor: Colors.black,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: Colors.black, width: 2),
        ),
        textStyle: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w800),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: RetroPalette.text,
        side: const BorderSide(color: RetroPalette.border, width: 2),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        textStyle: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w700),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: RetroPalette.border,
        textStyle: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w700),
      ),
    ),
  );
}

class RetroBackdrop extends StatelessWidget {
  const RetroBackdrop({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF101814), Color(0xFF13231B), Color(0xFF0D120F)],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _PixelPatternPainter())),
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.04),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.08),
                    ],
                  ),
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class RetroPanel extends StatelessWidget {
  const RetroPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: RetroPalette.panel.withValues(alpha: 0.96),
        border: Border.all(color: RetroPalette.borderSoft, width: 2),
      ),
      child: child,
    );
  }
}

class _PixelPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF5DF2B7).withValues(alpha: 0.05);
    for (double y = 0; y < size.height; y += 18) {
      for (double x = (y ~/ 18).isEven ? 0 : 9; x < size.width; x += 18) {
        canvas.drawRect(Rect.fromLTWH(x, y, 4, 4), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
