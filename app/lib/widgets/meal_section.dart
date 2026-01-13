import 'package:flutter/material.dart';

class MealSection extends StatelessWidget {
  final String mealName;
  final List<Map<String, dynamic>> foods;
  final int totalCalories;
  final VoidCallback onAddFood;
  final Function(int)? onDeleteFood;
  final Function(dynamic)? onEditFood;

  const MealSection({
    super.key,
    required this.mealName,
    required this.foods,
    required this.totalCalories,
    required this.onAddFood,
    this.onDeleteFood,
    this.onEditFood,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  mealName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  '$totalCalories cal',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[700],
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (foods.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'No foods added yet',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                ),
              )
            else
              ...foods.asMap().entries.map((entry) {
                final index = entry.key;
                final food = entry.value;
                final foodEntry = food['entry'];
                return InkWell(
                  onTap: foodEntry != null && onEditFood != null
                      ? () => onEditFood!(foodEntry)
                      : null,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            food['name'] ?? '',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${food['calories'] ?? 0} cal',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                            if (onDeleteFood != null) ...[
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 20),
                                color: Colors.red,
                                onPressed: () => onDeleteFood!(index),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onAddFood,
                icon: const Icon(Icons.add),
                label: const Text('Add food'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
