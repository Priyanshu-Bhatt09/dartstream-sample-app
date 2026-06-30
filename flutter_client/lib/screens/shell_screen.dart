import 'package:flutter/material.dart';

import '../state/session.dart';
import '../ui/retro_style.dart';
import 'experience_screen.dart';
import 'feature_flags_screen.dart';
import 'home_screen.dart';
import 'persistence_screen.dart';
import 'profile_screen.dart';
import 'reactive_screen.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key, required this.session});
  final Session session;

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _index = 0;

  late final List<_Feature> _features = [
    _Feature(label: 'Dashboard', icon: Icons.dashboard_outlined, selectedIcon: Icons.dashboard, builder: () => HomeScreen(session: widget.session)),
    _Feature(label: 'Profile', icon: Icons.account_circle_outlined, selectedIcon: Icons.account_circle, builder: () => ProfileScreen(session: widget.session)),
    _Feature(label: 'Platform', icon: Icons.flag_outlined, selectedIcon: Icons.flag, builder: () => FeatureFlagsScreen(session: widget.session)),
    _Feature(label: 'Experience', icon: Icons.person_outline, selectedIcon: Icons.person, builder: () => ExperienceScreen(session: widget.session)),
    _Feature(label: 'Reactive', icon: Icons.bolt_outlined, selectedIcon: Icons.bolt, builder: () => ReactiveScreen(session: widget.session)),
    _Feature(label: 'Persistence', icon: Icons.storage_outlined, selectedIcon: Icons.storage, builder: () => PersistenceScreen(session: widget.session)),
  ];

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    final wide = MediaQuery.sizeOf(context).width >= 760;
    final body = IndexedStack(index: _index, children: [for (final f in _features) f.builder()]);

    return RetroBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Northstar - ${_features[_index].label}'),
          actions: [
            if (session.email != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Center(child: Text(session.email!)),
              ),
            IconButton(
              tooltip: 'Sign out',
              icon: const Icon(Icons.logout),
              onPressed: session.signOut,
            ),
          ],
        ),
        body: wide
            ? Row(
                children: [
                  NavigationRail(
                    selectedIndex: _index,
                    onDestinationSelected: (i) => setState(() => _index = i),
                    labelType: NavigationRailLabelType.all,
                    destinations: [
                      for (final f in _features)
                        NavigationRailDestination(
                          icon: Icon(f.icon),
                          selectedIcon: Icon(f.selectedIcon),
                          label: Text(f.label),
                        ),
                    ],
                  ),
                  const VerticalDivider(width: 1, thickness: 2),
                  Expanded(child: body),
                ],
              )
            : body,
        bottomNavigationBar: wide
            ? null
            : NavigationBar(
                selectedIndex: _index,
                onDestinationSelected: (i) => setState(() => _index = i),
                destinations: [
                  for (final f in _features)
                    NavigationDestination(
                      icon: Icon(f.icon),
                      selectedIcon: Icon(f.selectedIcon),
                      label: f.label,
                    ),
                ],
              ),
      ),
    );
  }
}

class _Feature {
  _Feature({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.builder,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final Widget Function() builder;
}
