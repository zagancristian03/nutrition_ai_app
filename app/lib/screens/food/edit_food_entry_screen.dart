import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/food_entry.dart';
import '../../providers/daily_log_provider.dart';

class EditFoodEntryScreen extends StatefulWidget {
  final FoodEntry entry;

  const EditFoodEntryScreen({
    super.key,
    required this.entry,
  });

  @override
  State<EditFoodEntryScreen> createState() => _EditFoodEntryScreenState();
}

class _EditFoodEntryScreenState extends State<EditFoodEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _foodNameController;
  late TextEditingController _servingSizeController;
  late TextEditingController _servingsController;
  late TextEditingController _caloriesController;
  late TextEditingController _proteinController;
  late TextEditingController _carbsController;
  late TextEditingController _fatController;

  String? _selectedMealType;

  final List<String> _mealTypes = [
    'Breakfast',
    'Lunch',
    'Dinner',
    'Snack',
  ];

  @override
  void initState() {
    super.initState();
    _selectedMealType = widget.entry.mealType;
    _foodNameController = TextEditingController(text: widget.entry.foodName);
    _servingSizeController =
        TextEditingController(text: widget.entry.servingSize.toString());
    _servingsController =
        TextEditingController(text: widget.entry.servings.toString());
    _caloriesController =
        TextEditingController(text: widget.entry.totalCalories.toStringAsFixed(1));
    _proteinController =
        TextEditingController(text: widget.entry.totalProtein.toStringAsFixed(1));
    _carbsController =
        TextEditingController(text: widget.entry.totalCarbs.toStringAsFixed(1));
    _fatController =
        TextEditingController(text: widget.entry.totalFat.toStringAsFixed(1));
  }

  @override
  void dispose() {
    _foodNameController.dispose();
    _servingSizeController.dispose();
    _servingsController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      final newEntry = FoodEntry(
        foodId: widget.entry.foodId,
        foodName: _foodNameController.text.trim(),
        mealType: _selectedMealType!,
        servingSize: double.tryParse(_servingSizeController.text) ?? 0.0,
        servings: double.tryParse(_servingsController.text) ?? 1.0,
        totalCalories: double.tryParse(_caloriesController.text) ?? 0.0,
        totalProtein: double.tryParse(_proteinController.text) ?? 0.0,
        totalCarbs: double.tryParse(_carbsController.text) ?? 0.0,
        totalFat: double.tryParse(_fatController.text) ?? 0.0,
        timestamp: widget.entry.timestamp,
      );

      final provider = Provider.of<DailyLogProvider>(context, listen: false);
      provider.updateEntry(widget.entry, newEntry);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Food entry updated!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Food Entry'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                  setState(() {
                    _selectedMealType = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a meal type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _foodNameController,
                decoration: const InputDecoration(
                  labelText: 'Food Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.fastfood),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a food name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _servingSizeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Serving Size (g)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.scale),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _servingsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Number of Servings',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.numbers),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _caloriesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Calories',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.local_fire_department),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter calories';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _proteinController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Protein (g)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.fitness_center),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _carbsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Carbs (g)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.grain),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fatController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Fat (g)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.opacity),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _handleSave,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
