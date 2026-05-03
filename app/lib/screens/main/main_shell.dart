import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/daily_log_provider.dart';
import '../ai/ai_coach_screen.dart';
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

class _MainShellState extends State<MainShell> with WidgetsBindingObserver {
  static const int _dashboardIndex = 0;

  int _selectedIndex = _dashboardIndex;

  AppLifecycleState? _lastLifecycle;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  final ValueNotifier<int> _addTabBump = ValueNotifier(0);

  @override
  void dispose() {
    _addTabBump.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final wasPaused = _lastLifecycle == AppLifecycleState.paused;
    _lastLifecycle = state;

    if (state != AppLifecycleState.resumed || !mounted) return;
    if (!wasPaused) return;

    final diary = context.read<DailyLogProvider>();
    if (diary.userId != null) {
      diary.refresh();
    }
  }

  void _onItemTapped(int index) {
    final prev = _selectedIndex;
    setState(() => _selectedIndex = index);
    if (index == 2 && prev != 2) {
      _addTabBump.value++;
    }
  }

  List<Widget> _stackChildren() => [
        const DashboardScreen(),
        const DiaryScreen(),
        FoodSearchScreen(addTabActivationCount: _addTabBump),
        const ProgressScreen(),
        const MoreScreen(),
      ];

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
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.error,
                foregroundColor: Theme.of(ctx).colorScheme.onError,
              ),
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
          children: _stackChildren(),
        ),
        // Persistent AI coach entry point, available from every tab.
        // Uses `endFloat` so it sits above the bottom nav bar, not over it.
        floatingActionButton: FloatingActionButton(
          heroTag: 'ai_coach_fab',
          tooltip: 'AI Coach',
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AiCoachScreen()),
          ),
          child: const Icon(Icons.auto_awesome),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
