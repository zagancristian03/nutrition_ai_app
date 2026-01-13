import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

    if (result != null) {
      // Show dialog to enter serving size
      final servingSize = await showDialog<double>(
        context: context,
        builder: (context) => _ServingSizeDialog(),
      );

      if (servingSize != null && servingSize > 0) {
        setState(() {
          _items.add(
            saved_recipe.SavedRecipeItem(
              foodId: result.id,
              foodName: result.name,
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
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _saveRecipe() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a recipe name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one ingredient'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final servings = int.tryParse(_servingsController.text) ?? 1;
    if (servings <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid number of servings'),
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
      const SnackBar(
        content: Text('Recipe saved successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
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
        title: const Text('Create Recipe'),
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
                    decoration: const InputDecoration(
                      labelText: 'Recipe Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.book),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _servingsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Number of Servings',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.people),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Ingredients',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      ElevatedButton.icon(
                        onPressed: _addFoodItem,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Ingredient'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_items.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text('No ingredients added yet'),
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
                            '${item.servingSize}g • '
                            '${item.totalCalories.toStringAsFixed(1)} cal',
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
                              'Total Nutrition (${servings} servings)',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text('Total Calories: ${totalCalories.toStringAsFixed(1)}'),
                            Text('Total Protein: ${totalProtein.toStringAsFixed(1)}g'),
                            Text('Total Carbs: ${totalCarbs.toStringAsFixed(1)}g'),
                            Text('Total Fat: ${totalFat.toStringAsFixed(1)}g'),
                            const Divider(),
                            Text(
                              'Per Serving',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            Text('Calories: ${(totalCalories / servings).toStringAsFixed(1)}'),
                            Text('Protein: ${(totalProtein / servings).toStringAsFixed(1)}g'),
                            Text('Carbs: ${(totalCarbs / servings).toStringAsFixed(1)}g'),
                            Text('Fat: ${(totalFat / servings).toStringAsFixed(1)}g'),
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
              child: const Text('Save Recipe'),
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
    return AlertDialog(
      title: const Text('Enter Amount'),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Amount (g)',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final size = double.tryParse(_controller.text);
            if (size != null && size > 0) {
              Navigator.pop(context, size);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
