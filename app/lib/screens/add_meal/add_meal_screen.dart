import 'package:flutter/material.dart';
import '../../models/food_item.dart';
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
    'Snacks',
  ];

  @override
  void initState() {
    super.initState();
    _selectedMealType = widget.initialMealType ?? _mealTypes[0];
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

    final results = await _foodApiService.searchFood(query);

    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  void _selectFood(FoodItem food) {
    setState(() {
      _foodNameController.text = food.name;
      _caloriesController.text = food.calories.toInt().toString();
      _proteinController.text = food.protein.toStringAsFixed(1);
      _carbsController.text = food.carbs.toStringAsFixed(1);
      _fatsController.text = food.fat.toStringAsFixed(1);
      _showSearchResults = false;
      _searchController.clear();
      _searchResults = [];
    });
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final mealData = {
        'foodName': _foodNameController.text.trim(),
        'calories': int.tryParse(_caloriesController.text) ?? 0,
        'protein': double.tryParse(_proteinController.text) ?? 0.0,
        'carbs': double.tryParse(_carbsController.text) ?? 0.0,
        'fats': double.tryParse(_fatsController.text) ?? 0.0,
        'mealType': _selectedMealType,
      };

      // Print to console as placeholder
      print('Meal data: $mealData');

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Meal added successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Meal'),
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
                    labelText: 'Search for food',
                    hintText: 'e.g., rice, chicken, apple',
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
                            'No results found',
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
                          title: Text(food.name),
                          subtitle: Text(
                            '${food.calories.toInt()} cal • '
                            'P: ${food.protein.toStringAsFixed(1)}g • '
                            'C: ${food.carbs.toStringAsFixed(1)}g • '
                            'F: ${food.fat.toStringAsFixed(1)}g',
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
                    // Food name
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
                    // Calories
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
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Protein
                    TextFormField(
                      controller: _proteinController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Protein (g)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.fitness_center),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter protein amount';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Carbs
                    TextFormField(
                      controller: _carbsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Carbs (g)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.grain),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter carbs amount';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Fats
                    TextFormField(
                      controller: _fatsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Fats (g)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.opacity),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter fats amount';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
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
                      child: const Text(
                        'Add Meal',
                        style: TextStyle(fontSize: 16),
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
