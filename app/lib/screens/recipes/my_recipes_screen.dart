import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/l10n/app_localizations.dart';

import '../../providers/saved_items_provider.dart';
import '../../models/saved_recipe.dart';
import '../../providers/daily_log_provider.dart';
import 'create_recipe_screen.dart';

class MyRecipesScreen extends StatelessWidget {
  const MyRecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.myRecipesScreenTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CreateRecipeScreen(),
                ),
              );
            },
            tooltip: loc.myRecipesCreateTooltip,
          ),
        ],
      ),
      body: Consumer<SavedItemsProvider>(
        builder: (context, provider, child) {
          if (provider.savedRecipes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.book,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    loc.myRecipesEmpty,
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
                          builder: (_) => const CreateRecipeScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: Text(loc.myRecipesCreateFirst),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: provider.savedRecipes.length,
            itemBuilder: (context, index) {
              final recipe = provider.savedRecipes[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(recipe.name),
                  subtitle: Text(
                    loc.myRecipesCardSubtitle(
                      '${recipe.caloriesPerServing.toInt()}',
                      '${recipe.servings}',
                      recipe.proteinPerServing.toStringAsFixed(1),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add_circle),
                        onPressed: () => _addRecipeToDiary(context, recipe),
                        tooltip: loc.myMealsAddToDiaryTooltip,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteRecipe(context, provider, recipe),
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

  Future<void> _addRecipeToDiary(BuildContext context, SavedRecipe recipe) async {
    final loc = AppLocalizations.of(context)!;
    final dailyProvider = Provider.of<DailyLogProvider>(context, listen: false);

    int added = 0;
    int failed = 0;
    String? lastFailure;

    // Add each item in the recipe as a separate entry (per serving).
    for (final item in recipe.items) {
      final gramsPerServing = item.servingSize / recipe.servings;
      final outcome = await dailyProvider.addEntryForFood(
        foodId:   item.foodId,
        mealType: 'Dinner',
        grams:    gramsPerServing,
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
        ? loc.myRecipesAddedSnack(recipe.name)
        : loc.myRecipesPartialSnack(
            '$added',
            '${recipe.items.length}',
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

  void _deleteRecipe(
    BuildContext context,
    SavedItemsProvider provider,
    SavedRecipe recipe,
  ) {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(loc.myRecipesDeleteTitle),
        content: Text(loc.myRecipesDeleteConfirm(recipe.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(loc.commonCancel),
          ),
          TextButton(
            onPressed: () {
              provider.removeRecipe(recipe);
              Navigator.pop(dialogContext);
            },
            child: Text(loc.commonDelete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
