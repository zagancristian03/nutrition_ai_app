import 'package:flutter/material.dart';
import '../../models/food_item.dart';

/// A row in the food search results list.
///
/// Shows:
///   - Title capitalized for readability (backend stores lowercase).
///   - Brand on its own line (if present).
///   - Four compact macro chips (kcal / P / C / F per 100 g).
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
    final title = _titleCase(food.name);
    final brand = food.brand?.trim();

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.blue.shade50,
              child: const Icon(Icons.restaurant, color: Colors.blue, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  if (brand != null && brand.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      _titleCase(brand),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _MacroChip(
                        label: '${food.caloriesPer100g.round()} kcal',
                        color: Colors.orange,
                      ),
                      _MacroChip(
                        label: 'P ${_fmt(food.proteinPer100g)}g',
                        color: Colors.red,
                      ),
                      _MacroChip(
                        label: 'C ${_fmt(food.carbsPer100g)}g',
                        color: Colors.blueAccent,
                      ),
                      _MacroChip(
                        label: 'F ${_fmt(food.fatPer100g)}g',
                        color: Colors.green,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  static String _fmt(double v) {
    if (v <= 0) return '—';
    if (v >= 10) return v.round().toString();
    return v.toStringAsFixed(1);
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

class _MacroChip extends StatelessWidget {
  final String label;
  final Color color;

  const _MacroChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 0.8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color.shade900ish,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Small helper so we can pull a readable dark shade from a base MaterialColor,
/// falling back for non-MaterialColor values (like Colors.blueAccent).
extension on Color {
  Color get shade900ish {
    final c = this;
    if (c is MaterialColor) return c.shade700;
    return HSLColor.fromColor(c).withLightness(0.28).toColor();
  }
}
