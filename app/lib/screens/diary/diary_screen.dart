import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/meal_section.dart';
import '../../providers/daily_log_provider.dart';
import '../../models/food_entry.dart';
import '../food/food_search_screen.dart';
import '../food/edit_food_entry_screen.dart';

class DiaryScreen extends StatelessWidget {
  const DiaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DailyLogProvider>(
      builder: (context, provider, child) {
        final entriesByMeal = provider.entriesByMealType;

        // Define meal types in order (matching FoodDetailScreen)
        const mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];

        return Scaffold(
          appBar: AppBar(
            title: const Text('Diary'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: mealTypes.map((mealType) {
                final entries = entriesByMeal[mealType] ?? [];
                final totalCalories = entries.fold(
                  0.0,
                  (sum, entry) => sum + entry.totalCalories,
                );

                // Convert FoodEntry to Map for MealSection
                final foods = entries.map((entry) => {
                      'name': entry.foodName,
                      'calories': entry.totalCalories.toInt(),
                      'entry': entry, // Store entry for deletion
                    }).toList();

                return MealSection(
                  mealName: mealType,
                  foods: foods,
                  totalCalories: totalCalories.toInt(),
                  onAddFood: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FoodSearchScreen(),
                      ),
                    );
                  },
                  onDeleteFood: (index) {
                    if (index >= 0 && index < foods.length) {
                      final entry = foods[index]['entry'] as FoodEntry;
                      provider.removeEntry(entry);
                    }
                  },
                  onEditFood: (entry) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditFoodEntryScreen(entry: entry as FoodEntry),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
