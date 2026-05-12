import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/l10n/app_localizations.dart';

import '../../providers/saved_items_provider.dart';
import '../../models/saved_meal.dart';
import '../../providers/daily_log_provider.dart';
import 'create_meal_screen.dart';

class MyMealsScreen extends StatelessWidget {
  const MyMealsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.myMealsScreenTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CreateMealScreen(),
                ),
              );
            },
            tooltip: loc.myMealsCreateTooltip,
          ),
        ],
      ),
      body: Consumer<SavedItemsProvider>(
        builder: (context, provider, child) {
          if (provider.savedMeals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.restaurant_menu,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    loc.myMealsEmpty,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CreateMealScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: Text(loc.myMealsCreateFirst),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: provider.savedMeals.length,
            itemBuilder: (context, index) {
              final meal = provider.savedMeals[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(meal.name),
                  subtitle: Text(
                    loc.myMealsCardSubtitle(
                      '${meal.totalCalories.toInt()}',
                      meal.totalProtein.toStringAsFixed(1),
                      meal.totalCarbs.toStringAsFixed(1),
                      meal.totalFat.toStringAsFixed(1),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add_circle),
                        onPressed: () => _addMealToDiary(context, meal),
                        tooltip: loc.myMealsAddToDiaryTooltip,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteMeal(context, provider, meal),
                        tooltip: loc.myMealsDeleteTooltip,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _addMealToDiary(BuildContext context, SavedMeal meal) async {
    final loc = AppLocalizations.of(context)!;
    final dailyProvider = Provider.of<DailyLogProvider>(context, listen: false);

    int added = 0;
    int failed = 0;
    String? lastFailure;

    for (final item in meal.items) {
      final outcome = await dailyProvider.addEntryForFood(
        foodId:   item.foodId,
        mealType: 'Lunch',
        grams:    item.servingSize,
        servings: 1.0,
        foodDisplayName:
            item.foodName.trim().isNotEmpty ? item.foodName.trim() : null,
      );
      if (outcome.entry != null) {
        added++;
      } else {
        failed++;
        lastFailure ??= outcome.failureMessage;
      }
    }

    if (!context.mounted) return;

    final ok = failed == 0 && added > 0;
    var text = ok
        ? loc.myMealsAddedSnack(meal.name)
        : loc.myMealsPartialSnack(
            '$added',
            '${meal.items.length}',
            '$failed',
          );
    final err = lastFailure?.trim();
    if (!ok && err != null && err.isNotEmpty) {
      text = '$text\n$err';
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text, maxLines: 8),
        backgroundColor: ok ? Colors.green : Colors.orange,
      ),
    );
  }

  void _deleteMeal(
    BuildContext context,
    SavedItemsProvider provider,
    SavedMeal meal,
  ) {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(loc.myMealsDeleteTitle),
        content: Text(loc.myMealsDeleteConfirm(meal.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(loc.commonCancel),
          ),
          TextButton(
            onPressed: () {
              provider.removeMeal(meal);
              Navigator.pop(dialogContext);
            },
            child: Text(loc.commonDelete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
