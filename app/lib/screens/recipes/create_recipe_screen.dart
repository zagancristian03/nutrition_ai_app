import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/l10n/app_localizations.dart';

import '../../providers/saved_items_provider.dart';
import '../../models/saved_recipe.dart';
import '../../models/saved_recipe.dart' as saved_recipe;
import '../food/food_picker_screen.dart';
import '../../models/food_item.dart';

class CreateRecipeScreen extends StatefulWidget {
  const CreateRecipeScreen({super.key});

  @override
  State<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends State<CreateRecipeScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _servingsController = TextEditingController(text: '1');
  final List<saved_recipe.SavedRecipeItem> _items = [];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _servingsController.dispose();
    super.dispose();
  }

  Future<void> _addFoodItem() async {
    final result = await Navigator.push<FoodItem>(
      context,
      MaterialPageRoute(
        builder: (_) => const FoodPickerScreen(),
      ),
    );

    if (!mounted) return;
    if (result == null) return;

    // Show dialog to enter serving size
    final servingSize = await showDialog<double>(
      context: context,
      builder: (context) => _ServingSizeDialog(),
    );

    if (!mounted) return;
    if (servingSize != null && servingSize > 0) {
      setState(() {
        _items.add(
          saved_recipe.SavedRecipeItem(
            foodId: result.id,
            foodName: result.primaryLabel,
            servingSize: servingSize,
            caloriesPer100g: result.caloriesPer100g,
            proteinPer100g: result.proteinPer100g,
            carbsPer100g: result.carbsPer100g,
            fatPer100g: result.fatPer100g,
          ),
        );
      });
    }
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _saveRecipe() {
    final loc = AppLocalizations.of(context)!;
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.recipeSnackNameRequired),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.recipeSnackIngredientsRequired),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final servings = int.tryParse(_servingsController.text) ?? 1;
    if (servings <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.recipeSnackServingsInvalid),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final recipe = SavedRecipe(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      items: _items,
      servings: servings,
    );

    final provider = Provider.of<SavedItemsProvider>(context, listen: false);
    provider.addRecipe(recipe);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(loc.recipeSnackSaved),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;

    for (final item in _items) {
      totalCalories += item.totalCalories;
      totalProtein += item.totalProtein;
      totalCarbs += item.totalCarbs;
      totalFat += item.totalFat;
    }

    final servings = int.tryParse(_servingsController.text) ?? 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.createRecipeTitle),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: loc.recipeNameLabel,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.book),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: loc.recipeDescriptionLabel,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.description),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _servingsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: loc.recipeServingsLabel,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.people),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        loc.recipeIngredientsHeader,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      ElevatedButton.icon(
                        onPressed: _addFoodItem,
                        icon: const Icon(Icons.add),
                        label: Text(loc.recipeAddIngredient),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_items.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(loc.recipeEmptyIngredients),
                      ),
                    )
                  else
                    ..._items.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(item.foodName),
                          subtitle: Text(
                            loc.recipeIngredientSubtitle(
                              item.servingSize.toString(),
                              item.totalCalories.toStringAsFixed(1),
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _removeItem(index),
                          ),
                        ),
                      );
                    }),
                  if (_items.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loc.recipeTotalNutritionServings('$servings'),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(loc.recipeTotalCaloriesLine(
                              totalCalories.toStringAsFixed(1),
                            )),
                            Text(loc.recipeTotalProteinLine(
                              totalProtein.toStringAsFixed(1),
                            )),
                            Text(loc.recipeTotalCarbsLine(
                              totalCarbs.toStringAsFixed(1),
                            )),
                            Text(loc.recipeTotalFatLine(
                              totalFat.toStringAsFixed(1),
                            )),
                            const Divider(),
                            Text(
                              loc.recipePerServingHeader,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            Text(loc.recipePerServingCalories(
                              (totalCalories / servings).toStringAsFixed(1),
                            )),
                            Text(loc.recipePerServingProtein(
                              (totalProtein / servings).toStringAsFixed(1),
                            )),
                            Text(loc.recipePerServingCarbs(
                              (totalCarbs / servings).toStringAsFixed(1),
                            )),
                            Text(loc.recipePerServingFat(
                              (totalFat / servings).toStringAsFixed(1),
                            )),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _saveRecipe,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(loc.recipeSaveButton),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServingSizeDialog extends StatefulWidget {
  @override
  State<_ServingSizeDialog> createState() => _ServingSizeDialogState();
}

class _ServingSizeDialogState extends State<_ServingSizeDialog> {
  final _controller = TextEditingController(text: '100');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(loc.createRecipeEnterAmountTitle),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: loc.mealServingAmountG,
          border: const OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(loc.commonCancel),
        ),
        TextButton(
          onPressed: () {
            final size = double.tryParse(_controller.text);
            if (size != null && size > 0) {
              Navigator.pop(context, size);
            }
          },
          child: Text(loc.mealRecipeDialogAdd),
        ),
      ],
    );
  }
}
