import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/saved_items_provider.dart';
import '../../models/saved_meal.dart';
import '../../models/food_entry.dart';
import '../../providers/daily_log_provider.dart';
import 'create_meal_screen.dart';

class MyMealsScreen extends StatelessWidget {
  const MyMealsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Meals'),
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
            tooltip: 'Create Meal',
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
                    'No saved meals yet',
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
                    label: const Text('Create Your First Meal'),
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
                    '${meal.totalCalories.toInt()} cal • '
                    'P: ${meal.totalProtein.toStringAsFixed(1)}g • '
                    'C: ${meal.totalCarbs.toStringAsFixed(1)}g • '
                    'F: ${meal.totalFat.toStringAsFixed(1)}g',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add_circle),
                        onPressed: () => _addMealToDiary(context, meal),
                        tooltip: 'Add to Diary',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteMeal(context, provider, meal),
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

  void _addMealToDiary(BuildContext context, SavedMeal meal) {
    final dailyProvider = Provider.of<DailyLogProvider>(context, listen: false);
    
    // Add each item in the meal as a separate entry
    for (final item in meal.items) {
      final entry = FoodEntry(
        foodId: item.foodId,
        foodName: item.foodName,
        mealType: 'Lunch', // Default, user can edit later
        servingSize: item.servingSize,
        servings: 1.0,
        totalCalories: item.totalCalories,
        totalProtein: item.totalProtein,
        totalCarbs: item.totalCarbs,
        totalFat: item.totalFat,
      );
      dailyProvider.addEntry(entry);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${meal.name} added to diary!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _deleteMeal(
    BuildContext context,
    SavedItemsProvider provider,
    SavedMeal meal,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Meal'),
        content: Text('Are you sure you want to delete "${meal.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.removeMeal(meal);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
