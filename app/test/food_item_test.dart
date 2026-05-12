import 'package:flutter_test/flutter_test.dart';

import 'package:app/models/food_item.dart';

void main() {
  test('FoodItem uses display_name for primaryLabel when present', () {
    final f = FoodItem.fromJson({
      'id': '1',
      'name': 'chicken breast, cooked',
      'display_name': 'Piept de pui',
      'canonical_name': 'chicken breast, cooked',
      'calories_per_100g': 165,
      'protein_per_100g': 31,
      'carbs_per_100g': 0,
      'fat_per_100g': 3.6,
    });
    expect(f.primaryLabel, 'Piept de pui');
    expect(f.name, 'chicken breast, cooked');
  });

  test('FoodItem falls back to name when display_name absent', () {
    final f = FoodItem.fromJson({
      'id': '1',
      'name': 'egg, whole',
      'calories_per_100g': 155,
      'protein_per_100g': 13,
      'carbs_per_100g': 1.1,
      'fat_per_100g': 11,
    });
    expect(f.primaryLabel, 'egg, whole');
  });
}
