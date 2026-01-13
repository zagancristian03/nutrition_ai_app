import 'package:flutter/material.dart';
import '../../models/food_item.dart';

class FoodResultTile extends StatelessWidget {
  final FoodItem food;
  final VoidCallback onTap;

  const FoodResultTile({
    super.key,
    required this.food,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.restaurant, color: Colors.blue),
      title: Text(
        food.name,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        '${food.caloriesPer100g.toInt()} cal per 100g',
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}
