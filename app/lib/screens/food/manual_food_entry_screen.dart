import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/l10n/meal_labels.dart';

import '../../providers/daily_log_provider.dart';
import '../../services/food_api_service.dart';

class ManualFoodEntryScreen extends StatefulWidget {
  /// Meal type to pre-select in the dropdown (usually forwarded from the
  /// diary's "+" button via [FoodSearchScreen]).
  final String? initialMealType;

  const ManualFoodEntryScreen({super.key, this.initialMealType});

  @override
  State<ManualFoodEntryScreen> createState() => _ManualFoodEntryScreenState();
}

class _ManualFoodEntryScreenState extends State<ManualFoodEntryScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController        = TextEditingController();
  final _brandController       = TextEditingController();
  final _servingSizeController = TextEditingController(text: '100');
  final _servingsController    = TextEditingController(text: '1');
  final _caloriesController    = TextEditingController();
  final _proteinController     = TextEditingController();
  final _carbsController       = TextEditingController();
  final _fatController         = TextEditingController();

  late String _selectedMealType;
  bool _isSaving = false;

  final _foodApi = FoodApiService();

  static const _mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];

  @override
  void initState() {
    super.initState();
    _selectedMealType = _normalizedMealKey(widget.initialMealType);
  }

  String _normalizedMealKey(String? m) {
    if (m == null || m.isEmpty) return 'Breakfast';
    if (m == 'Snacks') return 'Snack';
    return _mealTypes.contains(m) ? m : 'Breakfast';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _servingSizeController.dispose();
    _servingsController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  Future<void> _handleAdd() async {
    final loc = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    if (_isSaving) return;

    final name = _nameController.text.trim();
    final brandText = _brandController.text.trim();
    final brand = brandText.isEmpty ? null : brandText;

    final servingSize = _parse(_servingSizeController.text, fallback: 100.0);
    final servings    = _parse(_servingsController.text,    fallback: 1.0);
    final calories    = _parse(_caloriesController.text,    fallback: 0.0);
    final protein     = _parse(_proteinController.text,     fallback: 0.0);
    final carbs       = _parse(_carbsController.text,       fallback: 0.0);
    final fat         = _parse(_fatController.text,         fallback: 0.0);

    // Form is expressed per-serving; the backend stores per-100g.
    final double safeServing = servingSize > 0 ? servingSize : 100.0;
    final factor = 100.0 / safeServing;
    final caloriesPer100g = calories * factor;
    final proteinPer100g  = protein  * factor;
    final carbsPer100g    = carbs    * factor;
    final fatPer100g      = fat      * factor;

    setState(() => _isSaving = true);

    final result = await _foodApi.createFoodWithDiagnostics(
      name: name,
      brand: brand,
      caloriesPer100g: caloriesPer100g,
      proteinPer100g: proteinPer100g,
      carbsPer100g: carbsPer100g,
      fatPer100g: fatPer100g,
      servingSizeG: servingSize,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (result.food == null) {
      final raw = result.errorMessage;
      final msg = (raw != null && raw.isNotEmpty)
          ? raw
          : loc.foodManualSaveFailedGeneric;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg, maxLines: 3, overflow: TextOverflow.ellipsis),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    final created = result.food!;

    final totalGrams = servingSize * servings;
    final outcome = await context.read<DailyLogProvider>().addEntryForFood(
          foodId:   created.id,
          mealType: _selectedMealType,
          grams:    totalGrams,
          servings: servings,
          foodDisplayName: created.primaryLabel,
        );

    if (!mounted) return;

    final ok = outcome.entry != null;
    final err = outcome.failureMessage?.trim();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? loc.foodManualSavedAndLoggedSnack
              : (err != null && err.isNotEmpty
                  ? err
                  : loc.foodManualSavedLogFailedSnack),
          maxLines: 5,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: ok ? Colors.green : Colors.orange,
        duration: const Duration(seconds: 4),
      ),
    );

    Navigator.pop(context);
  }

  double _parse(String raw, {required double fallback}) {
    final cleaned = raw.replaceAll(',', '.').trim();
    return double.tryParse(cleaned) ?? fallback;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(loc.foodManualTitle),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SectionCard(
                title: loc.foodManualSectionBasics,
                children: [
                  DropdownButtonFormField<String>(
                    key: ValueKey(_selectedMealType),
                    initialValue: _selectedMealType,
                    decoration: InputDecoration(
                      labelText: loc.foodDetailMealTypeLabel,
                      prefixIcon: const Icon(Icons.restaurant),
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: _mealTypes
                        .map((t) => DropdownMenuItem(
                              value: t,
                              child: Text(mealTypeLabel(loc, t)),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedMealType = v);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: loc.foodManualFoodNameLabel,
                      prefixIcon: const Icon(Icons.fastfood),
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty)
                            ? loc.foodManualValidationName
                            : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _brandController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: loc.foodManualBrandLabel,
                      prefixIcon: const Icon(Icons.local_offer_outlined),
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: loc.foodManualSectionPortion,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _numField(
                          controller: _servingSizeController,
                          label: loc.foodManualServingSizeG,
                          icon: Icons.scale,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _numField(
                          controller: _servingsController,
                          label: loc.foodDetailServingsLabel,
                          icon: Icons.numbers,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: loc.foodManualSectionNutrition,
                children: [
                  _numField(
                    controller: _caloriesController,
                    label: loc.foodEditCaloriesLabel,
                    icon: Icons.local_fire_department,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty)
                            ? loc.foodManualValidationCalories
                            : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _numField(
                          controller: _proteinController,
                          label: loc.foodEditProteinLabel,
                          icon: Icons.fitness_center,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _numField(
                          controller: _carbsController,
                          label: loc.foodEditCarbsLabel,
                          icon: Icons.grain,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _numField(
                    controller: _fatController,
                    label: loc.foodEditFatLabel,
                    icon: Icons.opacity,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 54,
                child: FilledButton.icon(
                  onPressed: _isSaving ? null : _handleAdd,
                  icon: _isSaving
                      ? SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        )
                      : const Icon(Icons.check),
                  label: Text(
                    _isSaving ? loc.foodManualSaving : loc.foodManualAddToDiary,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
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
      ),
    );
  }

  Widget _numField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      validator: validator,
    );
  }
}

// ======================================================================= //
// Section card wrapper                                                    //
// ======================================================================= //
class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}
