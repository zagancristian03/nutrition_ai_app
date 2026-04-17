import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/saved_items_provider.dart';
import '../../models/saved_recipe.dart';
import '../../providers/daily_log_provider.dart';
import 'create_recipe_screen.dart';

class MyRecipesScreen extends StatelessWidget {
  const MyRecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Recipes'),
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
            tooltip: 'Create Recipe',
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
                    'No saved recipes yet',
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
                    label: const Text('Create Your First Recipe'),
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
                    '${recipe.caloriesPerServing.toInt()} cal/serving • '
                    '${recipe.servings} servings • '
                    'P: ${recipe.proteinPerServing.toStringAsFixed(1)}g',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add_circle),
                        onPressed: () => _addRecipeToDiary(context, recipe),
                        tooltip: 'Add to Diary',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteRecipe(context, provider, recipe),
                        tooltip: 'Delete',
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
    final dailyProvider = Provider.of<DailyLogProvider>(context, listen: false);

    int added = 0;
    int failed = 0;

    // Add each item in the recipe as a separate entry (per serving).
    for (final item in recipe.items) {
      final gramsPerServing = item.servingSize / recipe.servings;
      final entry = await dailyProvider.addEntryForFood(
        foodId:   item.foodId,
        mealType: 'Dinner',
        grams:    gramsPerServing,
        servings: 1.0,
      );
      if (entry != null) {
        added++;
      } else {
        failed++;
      }
    }

    if (!context.mounted) return;

    final ok = failed == 0 && added > 0;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok
            ? '${recipe.name} (1 serving) added to diary!'
            : 'Added $added / ${recipe.items.length} items '
              '(${failed} failed — those foods may no longer exist).'),
        backgroundColor: ok ? Colors.green : Colors.orange,
      ),
    );
  }

  void _deleteRecipe(
    BuildContext context,
    SavedItemsProvider provider,
    SavedRecipe recipe,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Recipe'),
        content: Text('Are you sure you want to delete "${recipe.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.removeRecipe(recipe);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
