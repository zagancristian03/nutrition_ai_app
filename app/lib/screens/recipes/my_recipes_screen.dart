import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/saved_items_provider.dart';
import '../../models/saved_recipe.dart';
import '../../models/food_entry.dart';
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

  void _addRecipeToDiary(BuildContext context, SavedRecipe recipe) {
    final dailyProvider = Provider.of<DailyLogProvider>(context, listen: false);
    
    // Add each item in the recipe as a separate entry (per serving)
    for (final item in recipe.items) {
      final entry = FoodEntry(
        foodId: item.foodId,
        foodName: item.foodName,
        mealType: 'Dinner', // Default, user can edit later
        servingSize: item.servingSize / recipe.servings, // Per serving
        servings: 1.0,
        totalCalories: item.totalCalories / recipe.servings,
        totalProtein: item.totalProtein / recipe.servings,
        totalCarbs: item.totalCarbs / recipe.servings,
        totalFat: item.totalFat / recipe.servings,
      );
      dailyProvider.addEntry(entry);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${recipe.name} (1 serving) added to diary!'),
        backgroundColor: Colors.green,
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
