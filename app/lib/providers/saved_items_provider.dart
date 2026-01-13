import 'package:flutter/foundation.dart';
import '../models/saved_meal.dart';
import '../models/saved_recipe.dart';

class SavedItemsProvider extends ChangeNotifier {
  final List<SavedMeal> _savedMeals = [];
  final List<SavedRecipe> _savedRecipes = [];

  List<SavedMeal> get savedMeals => _savedMeals;
  List<SavedRecipe> get savedRecipes => _savedRecipes;

  /// Add a saved meal
  void addMeal(SavedMeal meal) {
    _savedMeals.add(meal);
    notifyListeners();
  }

  /// Remove a saved meal
  void removeMeal(SavedMeal meal) {
    _savedMeals.remove(meal);
    notifyListeners();
  }

  /// Update a saved meal
  void updateMeal(SavedMeal oldMeal, SavedMeal newMeal) {
    final index = _savedMeals.indexOf(oldMeal);
    if (index != -1) {
      _savedMeals[index] = newMeal;
      notifyListeners();
    }
  }

  /// Add a saved recipe
  void addRecipe(SavedRecipe recipe) {
    _savedRecipes.add(recipe);
    notifyListeners();
  }

  /// Remove a saved recipe
  void removeRecipe(SavedRecipe recipe) {
    _savedRecipes.remove(recipe);
    notifyListeners();
  }

  /// Update a saved recipe
  void updateRecipe(SavedRecipe oldRecipe, SavedRecipe newRecipe) {
    final index = _savedRecipes.indexOf(oldRecipe);
    if (index != -1) {
      _savedRecipes[index] = newRecipe;
      notifyListeners();
    }
  }
}
