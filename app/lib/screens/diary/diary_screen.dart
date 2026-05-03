import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/food_entry.dart';
import '../../providers/daily_log_provider.dart';
import '../../providers/preferences_provider.dart';
import '../../services/ai_service.dart';
import '../../widgets/diary_day_controls.dart';
import '../../widgets/meal_section.dart';
import '../food/edit_food_entry_screen.dart';
import '../food/food_search_screen.dart';

class DiaryScreen extends StatelessWidget {
  const DiaryScreen({super.key});

  static Future<void> _openFoodSearch(BuildContext context, String mealType) {
    return Navigator.of(context, rootNavigator: true).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => FoodSearchScreen(initialMealType: mealType),
      ),
    );
  }

  static Future<void> _openEditEntry(BuildContext context, FoodEntry entry) {
    return Navigator.of(context, rootNavigator: true).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => EditFoodEntryScreen(entry: entry),
      ),
    );
  }

  Future<bool> _confirmRemove(BuildContext context, String foodName) async {
    final cs = Theme.of(context).colorScheme;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove from diary?'),
        content: Text('“$foodName” will be removed from this day.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: cs.error,
              foregroundColor: cs.onError,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DailyLogProvider>(
      builder: (context, provider, child) {
        final entriesByMeal = provider.entriesByMealType;
        const mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];
        final cs = Theme.of(context).colorScheme;
        final prefs = context.watch<PreferencesProvider>();

        final insights = NutritionInsights.build(
          selectedDate: provider.selectedDate,
          isLoading: provider.isLoading,
          entryCount: provider.entries.length,
          calorieGoal: provider.calorieGoal,
          calories: provider.totalCalories,
          proteinGoal: provider.proteinGoal,
          protein: provider.totalProtein,
          carbsGoal: provider.carbsGoal,
          carbs: provider.totalCarbs,
          fatGoal: provider.fatGoal,
          fat: provider.totalFat,
        );

        final goal = provider.calorieGoal <= 0 ? 1.0 : provider.calorieGoal;
        final calProgress = (provider.totalCalories / goal).clamp(0.0, 1.0);

        return Scaffold(
          backgroundColor: cs.surface,
          appBar: AppBar(
            title: DiaryDayControls(
              selectedDate: provider.selectedDate,
              onDateChanged: provider.setSelectedDate,
            ),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (provider.isLoading)
                const LinearProgressIndicator(minHeight: 2),
              if (provider.diaryLoadError != null)
                Material(
                  color: cs.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.cloud_off_outlined,
                          color: cs.onErrorContainer,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            provider.diaryLoadError!,
                            style: TextStyle(color: cs.onErrorContainer),
                          ),
                        ),
                        TextButton(
                          onPressed: () => provider.clearDiaryLoadError(),
                          child: const Text('Dismiss'),
                        ),
                        TextButton(
                          onPressed: () => provider.refresh(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => provider.refresh(),
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        sliver: SliverToBoxAdapter(
                          child: _DaySummaryCard(
                            consumed: provider.totalCalories,
                            goal: provider.calorieGoal,
                            progress: calProgress,
                            protein: provider.totalProtein,
                            proteinGoal: provider.proteinGoal,
                            carbs: provider.totalCarbs,
                            carbsGoal: provider.carbsGoal,
                            fat: provider.totalFat,
                            fatGoal: provider.fatGoal,
                          ),
                        ),
                      ),
                      if (prefs.showCoachTips && insights.isNotEmpty)
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                          sliver: SliverToBoxAdapter(
                            child: Card(
                              elevation: 0,
                              color: cs.surfaceContainerHighest,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.auto_awesome,
                                          size: 18,
                                          color: cs.primary,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Insights',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    for (final line in insights)
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 6),
                                        child: Text(
                                          line,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (provider.entries.isEmpty &&
                          !provider.isLoading &&
                          provider.diaryLoadError == null)
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                          sliver: SliverToBoxAdapter(
                            child: Card(
                              elevation: 0,
                              color: cs.primaryContainer.withValues(alpha: 0.45),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.touch_app_outlined,
                                      color: cs.primary,
                                      size: 28,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Nothing logged for this day yet. '
                                        'Scroll down and tap Add food under any meal.',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: cs.onSurface,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final mealType = mealTypes[index];
                              final entries = entriesByMeal[mealType] ?? [];
                              final totalCalories = entries.fold(
                                0.0,
                                (sum, e) => sum + e.totalCalories,
                              );
                              final foods = entries
                                  .map(
                                    (e) => {
                                      'name': e.foodName,
                                      'calories': e.totalCalories.toInt(),
                                      'entry': e,
                                    },
                                  )
                                  .toList();

                              return MealSection(
                                mealName: mealType,
                                foods: foods,
                                totalCalories: totalCalories.toInt(),
                                onAddFood: () {
                                  prefs.hapticSelect();
                                  _openFoodSearch(context, mealType);
                                },
                                onDeleteFood: (i) async {
                                  if (i < 0 || i >= foods.length) return;
                                  final entry =
                                      foods[i]['entry'] as FoodEntry;
                                  if (prefs.confirmDelete) {
                                    final ok = await _confirmRemove(
                                      context,
                                      entry.foodName,
                                    );
                                    if (!ok) return;
                                  }
                                  prefs.hapticLight();
                                  await provider.removeEntry(entry);
                                },
                                onEditFood: (entry) {
                                  prefs.hapticSelect();
                                  _openEditEntry(
                                    context,
                                    entry as FoodEntry,
                                  );
                                },
                              );
                            },
                            childCount: mealTypes.length,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DaySummaryCard extends StatelessWidget {
  const _DaySummaryCard({
    required this.consumed,
    required this.goal,
    required this.progress,
    required this.protein,
    required this.proteinGoal,
    required this.carbs,
    required this.carbsGoal,
    required this.fat,
    required this.fatGoal,
  });

  final double consumed;
  final double goal;
  final double progress;
  final double protein;
  final double proteinGoal;
  final double carbs;
  final double carbsGoal;
  final double fat;
  final double fatGoal;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      color: cs.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This day', style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  consumed.round().toString(),
                  style: tt.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.primary,
                  ),
                ),
                Text(
                  ' / ${goal.round()} kcal',
                  style: tt.titleMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: cs.outlineVariant.withValues(alpha: 0.5),
                color: cs.primary,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _MiniMacro(
                  label: 'P',
                  value: protein,
                  goal: proteinGoal,
                  color: cs.error,
                ),
                _MiniMacro(
                  label: 'C',
                  value: carbs,
                  goal: carbsGoal,
                  color: cs.tertiary,
                ),
                _MiniMacro(
                  label: 'F',
                  value: fat,
                  goal: fatGoal,
                  color: cs.secondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniMacro extends StatelessWidget {
  const _MiniMacro({
    required this.label,
    required this.value,
    required this.goal,
    required this.color,
  });

  final String label;
  final double value;
  final double goal;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final g = goal <= 0 ? 1.0 : goal;
    final pct = (value / g * 100).clamp(0.0, 999.0);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        '$label ${value.round()} / ${goal.round()} g (${pct.round()}%)',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
      ),
    );
  }
}
