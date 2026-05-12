import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/l10n/app_localizations.dart';

import '../../providers/saved_items_provider.dart';
import '../../models/saved_meal.dart';
import '../../models/saved_meal.dart' as saved_meal;
import '../food/food_picker_screen.dart';
import '../../models/food_item.dart';

class CreateMealScreen extends StatefulWidget {
  const CreateMealScreen({super.key});

  @override
  State<CreateMealScreen> createState() => _CreateMealScreenState();
}

class _CreateMealScreenState extends State<CreateMealScreen> {
  final _nameController = TextEditingController();
  final List<saved_meal.SavedMealItem> _items = [];

  @override
  void dispose() {
    _nameController.dispose();
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
          saved_meal.SavedMealItem(
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

  void _saveMeal() {
    final loc = AppLocalizations.of(context)!;
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.createMealSnackNameRequired),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.createMealSnackItemsRequired),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final meal = SavedMeal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      items: _items,
    );

    final provider = Provider.of<SavedItemsProvider>(context, listen: false);
    provider.addMeal(meal);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(loc.createMealSnackSaved),
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

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.createMealTitle),
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
                      labelText: loc.createMealNameLabel,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.restaurant_menu),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        loc.createMealFoodItemsHeader,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      ElevatedButton.icon(
                        onPressed: _addFoodItem,
                        icon: const Icon(Icons.add),
                        label: Text(loc.createMealAddFoodButton),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_items.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(loc.createMealEmptyItems),
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
                            loc.createMealItemSubtitle(
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
                              loc.createMealTotalNutrition,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(loc.nutritionTotalCalories(
                              totalCalories.toStringAsFixed(1),
                            )),
                            Text(loc.nutritionTotalProtein(
                              totalProtein.toStringAsFixed(1),
                            )),
                            Text(loc.nutritionTotalCarbs(
                              totalCarbs.toStringAsFixed(1),
                            )),
                            Text(loc.nutritionTotalFat(
                              totalFat.toStringAsFixed(1),
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
              onPressed: _saveMeal,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(loc.createMealSaveButton),
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
      title: Text(loc.mealServingDialogTitle),
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
