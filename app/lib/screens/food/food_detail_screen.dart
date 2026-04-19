import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/food_item.dart';
import '../../providers/daily_log_provider.dart';

class FoodDetailScreen extends StatefulWidget {
  final FoodItem food;

  /// Meal type the user was adding to (e.g. when tapping "+" in the Lunch
  /// section of the diary). Defaults to Breakfast if not provided.
  final String? initialMealType;

  const FoodDetailScreen({
    super.key,
    required this.food,
    this.initialMealType,
  });

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  late final TextEditingController _servingSizeController;
  late final TextEditingController _servingsController;

  late String _selectedMealType;

  static const _mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];

  double _servingSize = 100.0;
  double _servings = 1.0;

  @override
  void initState() {
    super.initState();
    _selectedMealType = _mealTypes.contains(widget.initialMealType)
        ? widget.initialMealType!
        : 'Breakfast';

    // Default serving comes from the food row if the catalog knows one.
    final defaultServing = widget.food.servingSizeG ?? 100.0;
    _servingSize = defaultServing;
    _servings = 1.0;

    _servingSizeController = TextEditingController(
      text: defaultServing.toStringAsFixed(
        defaultServing == defaultServing.roundToDouble() ? 0 : 1,
      ),
    );
    _servingsController = TextEditingController(text: '1');

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
    setState(() {
      _servingSize = double.tryParse(_servingSizeController.text) ?? 0.0;
      _servings = double.tryParse(_servingsController.text) ?? 0.0;
    });
  }

  double get _totalGrams    => _servingSize * _servings;
  double get _totalCalories => widget.food.caloriesFor(_totalGrams);
  double get _totalProtein  => widget.food.proteinFor(_totalGrams);
  double get _totalCarbs    => widget.food.carbsFor(_totalGrams);
  double get _totalFat      => widget.food.fatFor(_totalGrams);

  bool _saving = false;

  Future<void> _handleAddToDiary() async {
    if (_servingSize <= 0 || _servings <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid serving size and servings'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _saving = true);
    final provider = context.read<DailyLogProvider>();
    final created = await provider.addEntryForFood(
      foodId:   widget.food.id,
      mealType: _selectedMealType,
      grams:    _totalGrams,
      servings: _servings,
    );

    if (!mounted) return;
    setState(() => _saving = false);

    if (created == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save to diary. Please check your connection.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

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
    final food = widget.food;
    final title = _titleCase(food.name);
    final brand = food.brand?.trim();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Food details'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(title: title, brand: brand),
            const SizedBox(height: 16),
            _Per100gCard(food: food),
            const SizedBox(height: 16),
            _PortionCard(
              mealType: _selectedMealType,
              onMealTypeChanged: (v) => setState(() => _selectedMealType = v),
              mealTypes: _mealTypes,
              servingSizeController: _servingSizeController,
              servingsController: _servingsController,
              unit: food.unit,
            ),
            const SizedBox(height: 16),
            _TotalsCard(
              totalGrams: _totalGrams,
              totalCalories: _totalCalories,
              totalProtein: _totalProtein,
              totalCarbs: _totalCarbs,
              totalFat: _totalFat,
              unit: food.unit,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 54,
              child: FilledButton.icon(
                onPressed: _saving ? null : _handleAddToDiary,
                icon: _saving
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      )
                    : const Icon(Icons.add),
                label: Text(
                  _saving ? 'Saving…' : 'Add to diary',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _titleCase(String s) {
    if (s.isEmpty) return s;
    return s
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }
}

// ======================================================================= //
// Header                                                                  //
// ======================================================================= //
class _Header extends StatelessWidget {
  final String title;
  final String? brand;
  const _Header({required this.title, required this.brand});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
        if (brand != null && brand!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            brand!,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ],
    );
  }
}

// ======================================================================= //
// Per-100 g macro card                                                    //
// ======================================================================= //
class _Per100gCard extends StatelessWidget {
  final FoodItem food;
  const _Per100gCard({required this.food});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle('Per 100 g'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _MacroStat(
                label: 'Calories',
                value: food.caloriesPer100g,
                suffix: ' kcal',
                color: Colors.orange,
              )),
              Expanded(child: _MacroStat(
                label: 'Protein',
                value: food.proteinPer100g,
                suffix: ' g',
                color: Colors.red,
              )),
              Expanded(child: _MacroStat(
                label: 'Carbs',
                value: food.carbsPer100g,
                suffix: ' g',
                color: Colors.blueAccent,
              )),
              Expanded(child: _MacroStat(
                label: 'Fat',
                value: food.fatPer100g,
                suffix: ' g',
                color: Colors.green,
              )),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroStat extends StatelessWidget {
  final String label;
  final double value;
  final String suffix;
  final Color color;

  const _MacroStat({
    required this.label,
    required this.value,
    required this.suffix,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final shown = value <= 0
        ? '—'
        : (value >= 10 ? value.round().toString() : value.toStringAsFixed(1));
    return Column(
      children: [
        Text(
          value <= 0 ? '—' : '$shown$suffix',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
        ),
      ],
    );
  }
}

// ======================================================================= //
// Portion / meal selection                                                //
// ======================================================================= //
class _PortionCard extends StatelessWidget {
  final String mealType;
  final ValueChanged<String> onMealTypeChanged;
  final List<String> mealTypes;
  final TextEditingController servingSizeController;
  final TextEditingController servingsController;
  final String unit;

  const _PortionCard({
    required this.mealType,
    required this.onMealTypeChanged,
    required this.mealTypes,
    required this.servingSizeController,
    required this.servingsController,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _CardTitle('Portion'),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: mealType,
            decoration: const InputDecoration(
              labelText: 'Meal type',
              prefixIcon: Icon(Icons.restaurant),
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: mealTypes
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: (v) {
              if (v != null) onMealTypeChanged(v);
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: servingSizeController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Serving size ($unit)',
                    prefixIcon: const Icon(Icons.scale),
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: servingsController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Servings',
                    prefixIcon: Icon(Icons.numbers),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ======================================================================= //
// Totals card                                                             //
// ======================================================================= //
class _TotalsCard extends StatelessWidget {
  final double totalGrams;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final String unit;

  const _TotalsCard({
    required this.totalGrams,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const _CardTitle('Totals'),
              Text(
                '${totalGrams.toStringAsFixed(totalGrams == totalGrams.roundToDouble() ? 0 : 1)} $unit',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
              ),
            ],
          ),
          const Divider(height: 24),
          _totalRow('Calories', totalCalories, ' kcal', Colors.orange),
          const SizedBox(height: 8),
          _totalRow('Protein',  totalProtein,  ' g',    Colors.red),
          const SizedBox(height: 8),
          _totalRow('Carbs',    totalCarbs,    ' g',    Colors.blueAccent),
          const SizedBox(height: 8),
          _totalRow('Fat',      totalFat,      ' g',    Colors.green),
        ],
      ),
    );
  }

  Widget _totalRow(String label, double value, String suffix, Color color) {
    final shown = value >= 10 ? value.round().toString() : value.toStringAsFixed(1);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        Text(
          '$shown$suffix',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ======================================================================= //
// Shared small helpers                                                    //
// ======================================================================= //
class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _CardTitle extends StatelessWidget {
  final String text;
  const _CardTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
    );
  }
}
