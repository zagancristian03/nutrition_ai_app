import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../dashboard/dashboard_screen.dart';
import '../diary/diary_screen.dart';
import '../food/food_search_screen.dart';
import '../progress/progress_screen.dart';
import '../more/more_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  static const int _dashboardIndex = 0;

  int _selectedIndex = _dashboardIndex;

  final List<Widget> _screens = const [
    DashboardScreen(),
    DiaryScreen(),
    FoodSearchScreen(),
    ProgressScreen(),
    MoreScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  /// Android/iOS system-back handler.
  /// - Not on Dashboard → jump to Dashboard (no exit).
  /// - On Dashboard      → ask the user to confirm exit.
  Future<void> _handleSystemBack(bool didPop, Object? _) async {
    if (didPop) return; // framework already popped the route

    if (_selectedIndex != _dashboardIndex) {
      setState(() => _selectedIndex = _dashboardIndex);
      return;
    }

    final shouldExit = await _confirmExit();
    if (shouldExit == true) {
      // Close the app cleanly. On Android this backs out; iOS ignores it.
      await SystemNavigator.pop();
    }
  }

  Future<bool?> _confirmExit() {
    return showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Exit app?'),
          content: const Text('Are you sure you want to close the app?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Exit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // PopScope (Flutter 3.12+) replaces the deprecated WillPopScope.
    // We always prevent the framework from popping this route and take over
    // the behavior in [_handleSystemBack].
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _handleSystemBack,
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book),
              label: 'Diary',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle),
              label: 'Add',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.show_chart),
              label: 'Progress',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.more_horiz),
              label: 'More',
            ),
          ],
        ),
      ),
    );
  }
}
