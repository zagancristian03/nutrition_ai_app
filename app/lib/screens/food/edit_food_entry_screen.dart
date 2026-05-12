import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/l10n/meal_labels.dart';

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
    _selectedMealType = _normalizeMealKey(widget.entry.mealType);
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

  static String _normalizeMealKey(String mealType) {
    if (mealType == 'Snacks') return 'Snack';
    const allowed = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];
    return allowed.contains(mealType) ? mealType : 'Breakfast';
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

  bool _saving = false;

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final newEntry = widget.entry.copyWith(
      foodName:      _foodNameController.text.trim(),
      mealType:      _selectedMealType!,
      servingSize:   double.tryParse(_servingSizeController.text) ?? 0.0,
      servings:      double.tryParse(_servingsController.text) ?? 1.0,
      totalCalories: double.tryParse(_caloriesController.text) ?? 0.0,
      totalProtein:  double.tryParse(_proteinController.text) ?? 0.0,
      totalCarbs:    double.tryParse(_carbsController.text) ?? 0.0,
      totalFat:      double.tryParse(_fatController.text) ?? 0.0,
    );

    setState(() => _saving = true);
    final provider = Provider.of<DailyLogProvider>(context, listen: false);
    final ok = await provider.updateEntry(widget.entry, newEntry);

    if (!mounted) return;
    setState(() => _saving = false);

    final loc = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? loc.foodEditUpdatedSnack : loc.foodEditSaveFailedSnack,
        ),
        backgroundColor: ok ? Colors.green : Colors.redAccent,
      ),
    );
    if (ok) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.foodEditTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                key: ValueKey(_selectedMealType ?? ''),
                initialValue: _selectedMealType,
                decoration: InputDecoration(
                  labelText: loc.foodEditMealTypeLabel,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.restaurant),
                ),
                items: _mealTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(mealTypeLabel(loc, type)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedMealType = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return loc.foodEditMealTypeRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _foodNameController,
                decoration: InputDecoration(
                  labelText: loc.foodEditFoodNameLabel,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.fastfood),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return loc.foodEditNameRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _servingSizeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: loc.foodEditServingSizeG,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.scale),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _servingsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: loc.foodEditServingsLabel,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.numbers),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _caloriesController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: loc.foodEditCaloriesLabel,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.local_fire_department),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return loc.foodEditCaloriesRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _proteinController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: loc.foodEditProteinLabel,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.fitness_center),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _carbsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: loc.foodEditCarbsLabel,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.grain),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fatController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: loc.foodEditFatLabel,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.opacity),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saving ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  _saving ? loc.foodEditSaving : loc.foodEditSaveButton,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
