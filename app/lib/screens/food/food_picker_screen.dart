import 'package:flutter/material.dart';
import 'dart:async';
import '../../models/food_item.dart';
import '../../services/food_search_service.dart';
import 'food_result_tile.dart';

class FoodPickerScreen extends StatefulWidget {
  const FoodPickerScreen({super.key});

  @override
  State<FoodPickerScreen> createState() => _FoodPickerScreenState();
}

class _FoodPickerScreenState extends State<FoodPickerScreen> {
  final _searchController = TextEditingController();
  final _foodSearchService = FoodSearchService();
  final _debounceTimer = Debouncer(milliseconds: 500);

  List<FoodItem> _searchResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) {
      _debounceTimer.cancel();
      setState(() {
        _searchResults = [];
        _hasSearched = false;
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _hasSearched = true;
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Food'),
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16.0),
            color: cs.surfaceContainerHighest,
            child: TextField(
              controller: _searchController,
              autofocus: true,
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
                            _hasSearched = false;
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
          // Search results
          Expanded(
            child: _buildResults(cs),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(ColorScheme cs) {
    if (!_hasSearched) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: cs.outlineVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Search for food to add',
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: cs.outlineVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontSize: 16,
              ),
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
            Navigator.pop(context, food);
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
