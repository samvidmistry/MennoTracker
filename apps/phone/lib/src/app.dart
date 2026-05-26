import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/history_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/today_screen.dart';
import 'screens/workout_screen.dart';

class MennoTrackerApp extends ConsumerWidget {
  const MennoTrackerApp({super.key});

  static const _seedColor = Color(0xFF1E88E5);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'MennoTracker',
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.dark,
        ),
      ),
      initialRoute: TodayRoute.path,
      routes: {
        TodayRoute.path: (_) => const HomeScaffold(initialIndex: 0),
        WorkoutRoute.path: (_) => const HomeScaffold(initialIndex: 1),
        HistoryRoute.path: (_) => const HomeScaffold(initialIndex: 2),
        SettingsRoute.path: (_) => const HomeScaffold(initialIndex: 3),
      },
    );
  }
}

class TodayRoute {
  static const path = '/today';
}

class WorkoutRoute {
  static const path = '/workout';
}

class HistoryRoute {
  static const path = '/history';
}

class SettingsRoute {
  static const path = '/settings';
}

class HomeScaffold extends StatefulWidget {
  const HomeScaffold({super.key, required this.initialIndex});

  final int initialIndex;

  @override
  State<HomeScaffold> createState() => _HomeScaffoldState();
}

class _HomeScaffoldState extends State<HomeScaffold> {
  late int _selectedIndex;

  static const _tabs = [
    _HomeTab(
      route: TodayRoute.path,
      label: 'Today',
      icon: Icons.today_outlined,
      selectedIcon: Icons.today,
      child: TodayScreen(),
    ),
    _HomeTab(
      route: WorkoutRoute.path,
      label: 'Workout',
      icon: Icons.fitness_center_outlined,
      selectedIcon: Icons.fitness_center,
      child: WorkoutStartPrompt(),
    ),
    _HomeTab(
      route: HistoryRoute.path,
      label: 'History',
      icon: Icons.history_outlined,
      selectedIcon: Icons.history,
      child: HistoryScreen(),
    ),
    _HomeTab(
      route: SettingsRoute.path,
      label: 'Settings',
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      child: SettingsScreen(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  void didUpdateWidget(covariant HomeScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      _selectedIndex = widget.initialIndex;
    }
  }

  void _selectTab(int index) {
    if (index == _selectedIndex) {
      return;
    }
    setState(() => _selectedIndex = index);
    Navigator.of(context).pushReplacementNamed(_tabs[index].route);
  }

  @override
  Widget build(BuildContext context) {
    final tab = _tabs[_selectedIndex];

    return Scaffold(
      appBar: AppBar(title: Text(tab.label)),
      body: IndexedStack(
        index: _selectedIndex,
        children: [for (final tab in _tabs) tab.child],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _selectTab,
        destinations: [
          for (final tab in _tabs)
            NavigationDestination(
              icon: Icon(tab.icon),
              selectedIcon: Icon(tab.selectedIcon),
              label: tab.label,
            ),
        ],
      ),
    );
  }
}

class _HomeTab {
  const _HomeTab({
    required this.route,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.child,
  });

  final String route;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final Widget child;
}
