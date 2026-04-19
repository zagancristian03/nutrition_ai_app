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
    final cs = Theme.of(context).colorScheme;
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
              backgroundColor: cs.primaryContainer,
              child: Icon(Icons.restaurant, color: cs.onPrimaryContainer, size: 22),
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
                        color: cs.onSurfaceVariant,
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
                        accent: cs.tertiary,
                      ),
                      _MacroChip(
                        label: 'P ${_fmt(food.proteinPer100g)}g',
                        accent: cs.error,
                      ),
                      _MacroChip(
                        label: 'C ${_fmt(food.carbsPer100g)}g',
                        accent: cs.primary,
                      ),
                      _MacroChip(
                        label: 'F ${_fmt(food.fatPer100g)}g',
                        accent: cs.secondary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: cs.outline),
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
  final Color accent;

  const _MacroChip({required this.label, required this.accent});

  @override
  Widget build(BuildContext context) {
    final onText = Theme.of(context).colorScheme.onSurface;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.4), width: 0.8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: onText.withValues(alpha: 0.9),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
