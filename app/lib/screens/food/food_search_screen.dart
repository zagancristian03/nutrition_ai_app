import 'package:flutter/material.dart';
import 'dart:async';

import 'package:provider/provider.dart';

import '../../models/food_item.dart';
import '../../models/recent_logged_food.dart';
import '../../providers/daily_log_provider.dart';
import '../../services/diary_api_service.dart';
import '../../services/food_search_service.dart';
import 'food_result_tile.dart';
import 'food_detail_screen.dart';
import 'manual_food_entry_screen.dart';
import '../meals/my_meals_screen.dart';
import '../recipes/my_recipes_screen.dart';

class FoodSearchScreen extends StatefulWidget {
  /// Optional: when the Add tab becomes active from another tab, parent bumps
  /// this notifier so we refresh "Recently logged".
  final ValueNotifier<int>? addTabActivationCount;

  /// Meal type when opened from the diary's "+" button (not used from main Add tab).
  final String? initialMealType;

  const FoodSearchScreen({
    super.key,
    this.addTabActivationCount,
    this.initialMealType,
  });

  @override
  State<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen> {
  final _searchController = TextEditingController();
  final _foodSearchService = FoodSearchService();
  final _diaryApi = DiaryApiService();
  final _debounceTimer = Debouncer(milliseconds: 500);

  List<FoodItem> _searchResults = [];
  bool _isSearching = false;
  bool _hasActiveSearch = false;

  List<RecentLoggedFood> _recentFoods = [];
  bool _loadingRecent = false;

  static const _mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];

  @override
  void initState() {
    super.initState();
    widget.addTabActivationCount?.addListener(_onAddTabBumped);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRecentFoods());
  }

  void _onAddTabBumped() {
    if (!mounted) return;
    _loadRecentFoods();
  }

  @override
  void dispose() {
    widget.addTabActivationCount?.removeListener(_onAddTabBumped);
    _searchController.dispose();
    _debounceTimer.dispose();
    super.dispose();
  }

  Future<void> _loadRecentFoods() async {
    final uid = context.read<DailyLogProvider>().userId;
    if (uid == null) return;
    setState(() => _loadingRecent = true);
    final raw = await _diaryApi.listRecentDistinctFoodsRaw(userId: uid, limit: 40);
    if (!mounted) return;
    setState(() {
      _recentFoods = raw.map(RecentLoggedFood.fromLogJson).toList();
      _loadingRecent = false;
    });
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) {
      _debounceTimer.cancel();
      setState(() {
        _searchResults = [];
        _hasActiveSearch = false;
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _hasActiveSearch = true;
    });

    final q = query.trim();
    _debounceTimer.run(() async {
      final results = await _foodSearchService.search(q);
      if (!mounted) return;
      if (_searchController.text.trim() != q) return;
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    });
  }

  Future<void> _pickMealAndQuickAdd(RecentLoggedFood recent) async {
    final meal = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                'Log "${recent.foodName}" to',
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            const Divider(height: 1),
            ..._mealTypes.map(
              (m) => ListTile(
                title: Text(m),
                leading: Icon(_mealIcon(m)),
                onTap: () => Navigator.of(ctx).pop(m),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (!mounted || meal == null) return;

    final provider = context.read<DailyLogProvider>();
    final g = recent.grams;
    final s = recent.servings;
    if (g == null && s == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No portion saved for this item — tap the row to set amount.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final created = await provider.addEntryForFood(
      foodId:   recent.foodId,
      mealType: meal,
      grams:    g,
      servings: s,
    );

    if (!mounted) return;

    if (created != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added to $meal'),
          backgroundColor: Colors.green,
        ),
      );
      await _loadRecentFoods();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not log — check connection and try again.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  static IconData _mealIcon(String m) {
    switch (m) {
      case 'Breakfast':
        return Icons.wb_sunny_outlined;
      case 'Lunch':
        return Icons.restaurant_outlined;
      case 'Dinner':
        return Icons.dinner_dining_outlined;
      default:
        return Icons.cookie_outlined;
    }
  }

  String _shortDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}'
        '/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('Add Food'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => ManualFoodEntryScreen(
                    initialMealType: widget.initialMealType,
                  ),
                ),
              ).then((_) => _loadRecentFoods());
            },
            tooltip: 'Add manually',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            color: cs.surfaceContainerLow,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MyMealsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.restaurant_menu),
                    label: const Text('My Meals'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MyRecipesScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.book),
                    label: const Text('My Recipes'),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            color: cs.surfaceContainerHighest,
            child: TextField(
              controller: _searchController,
              autofocus: false,
              decoration: InputDecoration(
                hintText: 'Search for food...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _debounceTimer.cancel();
                          _searchController.clear();
                          setState(() {
                            _searchResults = [];
                            _hasActiveSearch = false;
                            _isSearching = false;
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: cs.surface,
              ),
              onChanged: (value) {
                setState(() {});
                _performSearch(value);
              },
            ),
          ),
          if (!_hasActiveSearch) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
              child: Row(
                children: [
                  Text(
                    'Recently logged',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cs.onSurfaceVariant,
                        ),
                  ),
                  const Spacer(),
                  if (_loadingRecent)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 20),
                      tooltip: 'Refresh',
                      onPressed: _loadRecentFoods,
                    ),
                ],
              ),
            ),
          ],
          Expanded(
            child: _hasActiveSearch ? _buildSearchResults(cs) : _buildRecentList(cs),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentList(ColorScheme cs) {
    if (_recentFoods.isEmpty && !_loadingRecent) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Foods you log will appear here — newest first — '
            'use + to log again and pick a meal.',
            textAlign: TextAlign.center,
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 15),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: _recentFoods.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final recent = _recentFoods[index];
        final g = recent.grams;
        final portion = g != null && g > 0
            ? '${g == g.roundToDouble() ? g.toInt().toString() : g.toStringAsFixed(1)} g'
            : (recent.servings != null
                ? '${recent.servings} × serving'
                : '—');
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          leading: CircleAvatar(
            backgroundColor: cs.primaryContainer,
            child: Icon(Icons.history, color: cs.onPrimaryContainer, size: 20),
          ),
          title: Text(
            recent.foodName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            '$portion · ${_shortDate(recent.lastLoggedAt)}',
            style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
          ),
          trailing: IconButton.filledTonal(
            icon: const Icon(Icons.add),
            tooltip: 'Log again',
            onPressed: () => _pickMealAndQuickAdd(recent),
          ),
          onTap: () {
            final food = recent.asFoodItem;
            Navigator.of(context, rootNavigator: true).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => FoodDetailScreen(
                  food: food,
                  initialMealType: widget.initialMealType,
                ),
              ),
            ).then((_) => _loadRecentFoods());
          },
        );
      },
    );
  }

  Widget _buildSearchResults(ColorScheme cs) {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: cs.outlineVariant),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final food = _searchResults[index];
        return FoodResultTile(
          food: food,
          onTap: () {
            Navigator.of(context, rootNavigator: true).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => FoodDetailScreen(
                  food: food,
                  initialMealType: widget.initialMealType,
                ),
              ),
            ).then((_) => _loadRecentFoods());
          },
        );
      },
    );
  }
}

/// Debouncer utility class for delaying function calls
class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void cancel() => _timer?.cancel();

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() {
    _timer?.cancel();
  }
}
