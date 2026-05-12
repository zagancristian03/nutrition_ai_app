import 'package:flutter/material.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/l10n/meal_labels.dart';
import 'package:provider/provider.dart';

import '../../models/food_item.dart';
import '../../providers/locale_controller.dart';
import '../../services/food_api_service.dart';

class AddMealScreen extends StatefulWidget {
  final String? initialMealType;

  const AddMealScreen({
    super.key,
    this.initialMealType,
  });

  @override
  State<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  final _formKey = GlobalKey<FormState>();
  final _searchController = TextEditingController();
  final _foodNameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatsController = TextEditingController();

  final _foodApiService = FoodApiService();
  List<FoodItem> _searchResults = [];
  bool _isSearching = false;
  bool _showSearchResults = false;

  String? _selectedMealType;

  final List<String> _mealTypes = [
    'Breakfast',
    'Lunch',
    'Dinner',
    'Snack',
  ];

  String _normalizeMealKey(String? m) {
    if (m == null || m.isEmpty) return _mealTypes[0];
    if (m == 'Snacks') return 'Snack';
    return _mealTypes.contains(m) ? m : _mealTypes[0];
  }

  @override
  void initState() {
    super.initState();
    _selectedMealType = _normalizeMealKey(widget.initialMealType);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _foodNameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatsController.dispose();
    super.dispose();
  }

  Future<void> _searchFood(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _showSearchResults = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _showSearchResults = true;
    });

    final lc = context.read<LocaleController>();
    final localeTag = lc.preferredLocaleForAi(
      WidgetsBinding.instance.platformDispatcher.locale,
    );
    final outcome = await _foodApiService.searchFoodWithOutcome(
      query,
      locale: localeTag,
    );

    if (!mounted) return;

    setState(() {
      _searchResults = outcome.items;
      _isSearching = false;
    });

    if (outcome.errorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(outcome.errorMessage!),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _selectFood(FoodItem food) {
    setState(() {
      _foodNameController.text = food.primaryLabel;
      _caloriesController.text = food.caloriesPer100g.toInt().toString();
      _proteinController.text = food.proteinPer100g.toStringAsFixed(1);
      _carbsController.text = food.carbsPer100g.toStringAsFixed(1);
      _fatsController.text = food.fatPer100g.toStringAsFixed(1);
      _showSearchResults = false;
      _searchController.clear();
      _searchResults = [];
    });
  }

  void _handleSubmit() {
    final loc = AppLocalizations.of(context)!;
    if (_formKey.currentState!.validate()) {
      final mealData = {
        'foodName': _foodNameController.text.trim(),
        'calories': int.tryParse(_caloriesController.text) ?? 0,
        'protein': double.tryParse(_proteinController.text) ?? 0.0,
        'carbs': double.tryParse(_carbsController.text) ?? 0.0,
        'fats': double.tryParse(_fatsController.text) ?? 0.0,
        'mealType': _selectedMealType,
      };

      debugPrint('[AddMealScreen] meal data: $mealData');

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.addMealSuccessSnack),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.addMealTitle),
      ),
      body: Column(
        children: [
          // Search section
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: loc.addMealSearchLabel,
                    hintText: loc.addMealSearchHint,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchResults = [];
                                _showSearchResults = false;
                              });
                            },
                          )
                        : null,
                  ),
                  onSubmitted: _searchFood,
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
                if (_isSearching)
                  const Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          ),
          // Search results
          if (_showSearchResults && !_isSearching)
            Expanded(
              child: _searchResults.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            loc.addMealNoResults,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final food = _searchResults[index];
                        return ListTile(
                          leading: const Icon(Icons.restaurant),
                          title: Text(food.primaryLabel),
                          subtitle: Text(
                            loc.addMealSearchResultLine(
                              food.caloriesPer100g.toInt().toString(),
                              food.proteinPer100g.toStringAsFixed(1),
                              food.carbsPer100g.toStringAsFixed(1),
                              food.fatPer100g.toStringAsFixed(1),
                            ),
                          ),
                          onTap: () => _selectFood(food),
                        );
                      },
                    ),
            ),
          // Form section
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Meal type dropdown
                    DropdownButtonFormField<String>(
                      key: ValueKey(_selectedMealType ?? ''),
                      initialValue: _selectedMealType,
                      decoration: InputDecoration(
                        labelText: loc.addMealMealTypeLabel,
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
                          return loc.addMealSelectMealType;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Food name
                    TextFormField(
                      controller: _foodNameController,
                      decoration: InputDecoration(
                        labelText: loc.addMealFoodNameLabel,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.fastfood),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return loc.addMealFoodNameRequired;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Calories
                    TextFormField(
                      controller: _caloriesController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: loc.addMealCaloriesLabel,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.local_fire_department),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return loc.addMealCaloriesRequired;
                        }
                        if (int.tryParse(value) == null) {
                          return loc.addMealCaloriesInvalid;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Protein
                    TextFormField(
                      controller: _proteinController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: loc.addMealProteinLabel,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.fitness_center),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return loc.addMealProteinRequired;
                        }
                        if (double.tryParse(value) == null) {
                          return loc.addMealProteinInvalid;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Carbs
                    TextFormField(
                      controller: _carbsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: loc.addMealCarbsLabel,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.grain),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return loc.addMealCarbsRequired;
                        }
                        if (double.tryParse(value) == null) {
                          return loc.addMealCarbsInvalid;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Fats
                    TextFormField(
                      controller: _fatsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: loc.addMealFatsLabel,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.opacity),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return loc.addMealFatsRequired;
                        }
                        if (double.tryParse(value) == null) {
                          return loc.addMealFatsInvalid;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    // Submit button
                    ElevatedButton(
                      onPressed: _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        loc.addMealSubmitButton,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
