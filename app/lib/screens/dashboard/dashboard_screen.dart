import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/daily_log_provider.dart';
import '../../providers/preferences_provider.dart';
import '../../services/ai_service.dart';
import '../../widgets/diary_day_controls.dart';
import '../../widgets/macro_ring.dart';
import '../../widgets/stat_card.dart';
import '../diary/diary_screen.dart';
import '../goals/edit_goals_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DailyLogProvider>(
      builder: (context, provider, child) {
        final consumedCalories = provider.totalCalories.toInt();
        final goalCalories = provider.calorieGoal.toInt();
        final proteinConsumed = provider.totalProtein;
        final proteinGoal = provider.proteinGoal;
        final carbsConsumed = provider.totalCarbs;
        final carbsGoal = provider.carbsGoal;
        final fatsConsumed = provider.totalFat;
        final fatsGoal = provider.fatGoal;

        final selectedDate = provider.selectedDate;
        final now = DateTime.now();
        final isToday = selectedDate.year == now.year &&
            selectedDate.month == now.month &&
            selectedDate.day == now.day;

        final cs = Theme.of(context).colorScheme;
        final showCoachTips = context.watch<PreferencesProvider>().showCoachTips;

        final insights = NutritionInsights.build(
          selectedDate: selectedDate,
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

        return Scaffold(
          appBar: AppBar(
            title: DiaryDayControls(
              selectedDate: selectedDate,
              onDateChanged: provider.setSelectedDate,
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Reload this day',
                onPressed: provider.isLoading ? null : () => provider.refresh(),
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EditGoalsScreen(),
                    ),
                  );
                },
                tooltip: 'Edit Goals',
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (provider.diaryLoadError != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Material(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: Theme.of(context).colorScheme.onErrorContainer,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                provider.diaryLoadError!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onErrorContainer,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => provider.refresh(),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (showCoachTips && insights.isNotEmpty) ...[
                  Card(
                    elevation: 0,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                size: 20,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Coach',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          for (final line in insights)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '• ',
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  Expanded(
                                    child: Text(
                                      line,
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DiaryScreen(),
                      ),
                    );
                  },
                  child: StatCard(
                    label: isToday ? 'Calories (today)' : 'Calories (${_shortDate(selectedDate)})',
                    value: '$consumedCalories / $goalCalories',
                    color: cs.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Macros',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    MacroRing(
                      label: 'Protein',
                      consumed: proteinConsumed,
                      goal: proteinGoal,
                      color: cs.error,
                    ),
                    MacroRing(
                      label: 'Carbs',
                      consumed: carbsConsumed,
                      goal: carbsGoal,
                      color: cs.tertiary,
                    ),
                    MacroRing(
                      label: 'Fats',
                      consumed: fatsConsumed,
                      goal: fatsGoal,
                      color: cs.secondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static String _shortDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }
}
