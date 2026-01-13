import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/food_item.dart';
import '../../models/food_entry.dart';
import '../../providers/daily_log_provider.dart';

class FoodDetailScreen extends StatefulWidget {
  final FoodItem food;

  const FoodDetailScreen({
    super.key,
    required this.food,
  });

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  final _servingSizeController = TextEditingController(text: '100');
  final _servingsController = TextEditingController(text: '1.0');
  String _selectedMealType = 'Breakfast';

  final List<String> _mealTypes = [
    'Breakfast',
    'Lunch',
    'Dinner',
    'Snack',
  ];

  double _servingSize = 100.0;
  double _servings = 1.0;

  @override
  void initState() {
    super.initState();
    _servingSizeController.addListener(_updateCalculations);
    _servingsController.addListener(_updateCalculations);
  }

  @override
  void dispose() {
    _servingSizeController.dispose();
    _servingsController.dispose();
    super.dispose();
  }

  void _updateCalculations() {
    final servingSize = double.tryParse(_servingSizeController.text) ?? 0.0;
    final servings = double.tryParse(_servingsController.text) ?? 0.0;

    setState(() {
      _servingSize = servingSize;
      _servings = servings;
    });
  }

  double get _totalGrams => _servingSize * _servings;
  double get _totalCalories => widget.food.caloriesFor(_totalGrams);
  double get _totalProtein => widget.food.proteinFor(_totalGrams);
  double get _totalCarbs => widget.food.carbsFor(_totalGrams);
  double get _totalFat => widget.food.fatFor(_totalGrams);

  void _handleAddToDiary() {
    if (_servingSize <= 0 || _servings <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid serving size and servings'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final entry = FoodEntry(
      foodId: widget.food.id,
      foodName: widget.food.name,
      mealType: _selectedMealType,
      servingSize: _servingSize,
      servings: _servings,
      totalCalories: _totalCalories,
      totalProtein: _totalProtein,
      totalCarbs: _totalCarbs,
      totalFat: _totalFat,
    );

    // Add entry via provider
    final provider = Provider.of<DailyLogProvider>(context, listen: false);
    provider.addEntry(entry);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Food added to diary!'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.food.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Meal type dropdown
            DropdownButtonFormField<String>(
              value: _selectedMealType,
              decoration: const InputDecoration(
                labelText: 'Meal Type',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.restaurant),
              ),
              items: _mealTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedMealType = value;
                  });
                }
              },
            ),
            const SizedBox(height: 24),
            // Serving size input
            TextFormField(
              controller: _servingSizeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Serving Size (${widget.food.unit})',
                hintText: 'e.g., 100',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.scale),
              ),
            ),
            const SizedBox(height: 16),
            // Number of servings input
            TextFormField(
              controller: _servingsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Number of Servings',
                hintText: 'e.g., 1.0',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.numbers),
              ),
            ),
            const SizedBox(height: 24),
            // Macro summary card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nutrition Summary',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildMacroRow(
                      'Total Amount',
                      '${_totalGrams.toStringAsFixed(1)} ${widget.food.unit}',
                      Colors.blue,
                    ),
                    const Divider(),
                    _buildMacroRow(
                      'Calories',
                      _totalCalories.toStringAsFixed(1),
                      Colors.orange,
                    ),
                    const SizedBox(height: 8),
                    _buildMacroRow(
                      'Protein',
                      '${_totalProtein.toStringAsFixed(1)}g',
                      Colors.red,
                    ),
                    const SizedBox(height: 8),
                    _buildMacroRow(
                      'Carbs',
                      '${_totalCarbs.toStringAsFixed(1)}g',
                      Colors.blue,
                    ),
                    const SizedBox(height: 8),
                    _buildMacroRow(
                      'Fat',
                      '${_totalFat.toStringAsFixed(1)}g',
                      Colors.green,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Add to diary button
            ElevatedButton(
              onPressed: _handleAddToDiary,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue,
              ),
              child: const Text(
                'Add to Diary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
      ],
    );
  }
}
