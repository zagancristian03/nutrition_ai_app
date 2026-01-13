import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/macro_ring.dart';
import '../../providers/daily_log_provider.dart';
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
        final isToday = selectedDate.year == DateTime.now().year &&
            selectedDate.month == DateTime.now().month &&
            selectedDate.day == DateTime.now().day;

        return Scaffold(
          appBar: AppBar(
            title: GestureDetector(
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (pickedDate != null) {
                  provider.setSelectedDate(pickedDate);
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(isToday ? 'Today' : _formatDate(selectedDate)),
                  const SizedBox(width: 4),
                  const Icon(Icons.calendar_today, size: 18),
                ],
              ),
            ),
            actions: [
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
                // Daily calorie summary (tappable)
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
                    label: 'Calories',
                    value: '$consumedCalories / $goalCalories',
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 24),
                // Macro indicators
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
                      color: Colors.red,
                    ),
                    MacroRing(
                      label: 'Carbs',
                      consumed: carbsConsumed,
                      goal: carbsGoal,
                      color: Colors.blue,
                    ),
                    MacroRing(
                      label: 'Fats',
                      consumed: fatsConsumed,
                      goal: fatsGoal,
                      color: Colors.orange,
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference == -1) {
      return 'Tomorrow';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
