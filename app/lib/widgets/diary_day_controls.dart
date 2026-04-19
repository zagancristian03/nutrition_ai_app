import 'package:flutter/material.dart';

/// Previous / next day + tappable title (opens calendar). Used on Dashboard and Diary.
class DiaryDayControls extends StatelessWidget {
  const DiaryDayControls({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
    this.firstDate,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;

  /// Earliest selectable day (defaults to 2020-01-01).
  final DateTime? firstDate;

  static DateTime _stripTime(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  Widget build(BuildContext context) {
    final today = _stripTime(DateTime.now());
    final current = _stripTime(selectedDate);
    final first = firstDate != null ? _stripTime(firstDate!) : DateTime(2020, 1, 1);
    final canGoBack = current.isAfter(first);
    final canGoForward = current.isBefore(today);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Previous day',
          onPressed: canGoBack
              ? () => onDateChanged(current.subtract(const Duration(days: 1)))
              : null,
          icon: const Icon(Icons.chevron_left),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 40),
        ),
        Flexible(
          child: InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: current,
                firstDate: first,
                lastDate: today,
              );
              if (picked != null) onDateChanged(_stripTime(picked));
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      _formatTitle(current, today),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.calendar_today,
                    size: 18,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
        IconButton(
          tooltip: 'Next day',
          onPressed: canGoForward
              ? () => onDateChanged(current.add(const Duration(days: 1)))
              : null,
          icon: const Icon(Icons.chevron_right),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 40),
        ),
      ],
    );
  }

  static String _formatTitle(DateTime day, DateTime today) {
    if (day == today) return 'Today';
    final y = day.difference(today).inDays;
    if (y == -1) return 'Yesterday';
    if (y == 1) return 'Tomorrow';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${day.day} ${months[day.month - 1]} ${day.year}';
  }
}
