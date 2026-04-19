import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/user_profile.dart';
import '../../models/weight_entry.dart';
import '../../providers/daily_log_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../utils/nutrition_math.dart';
import '../profile/edit_profile_screen.dart';

/// Progress tab — tracks weight, shows TDEE/BMI, and summarises today's
/// intake vs targets. Pulls all data from [UserProfileProvider] and
/// [DailyLogProvider] so everything stays fresh across app restarts.
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileProv = context.watch<UserProfileProvider>();
    final diaryProv   = context.watch<DailyLogProvider>();

    final profile = profileProv.profile;
    final weights = profileProv.weights;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: profileProv.isLoading ? null : () => profileProv.refresh(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: profileProv.refresh,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            _ProfileSummaryCard(profile: profile),
            const SizedBox(height: 12),

            _WeightCard(
              weights: weights,
              profile: profile,
              onAddWeight: () => _openLogWeightSheet(context, profile),
            ),
            const SizedBox(height: 12),

            _TodayCard(
              profile: profile,
              selectedDate: diaryProv.selectedDate,
              consumedCalories: diaryProv.totalCalories,
              calorieGoal:      diaryProv.calorieGoal,
              consumedProtein:  diaryProv.totalProtein,
              proteinGoal:      diaryProv.proteinGoal,
              consumedCarbs:    diaryProv.totalCarbs,
              carbsGoal:        diaryProv.carbsGoal,
              consumedFat:      diaryProv.totalFat,
              fatGoal:          diaryProv.fatGoal,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openLogWeightSheet(BuildContext context, UserProfile? profile) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _LogWeightSheet(initialKg: profile?.currentWeightKg),
    );
  }
}

// ============================================================================
// Profile summary card
// ============================================================================

class _ProfileSummaryCard extends StatelessWidget {
  final UserProfile? profile;
  const _ProfileSummaryCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final name    = profile?.displayName?.trim();
    final hasData = profile?.sex != null || profile?.currentWeightKg != null;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.primary.withValues(alpha: 0.4)),
      ),
      color: cs.primary.withValues(alpha: 0.06),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: cs.primary.withValues(alpha: 0.15),
              child: Icon(Icons.person, size: 30, color: cs.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (name == null || name.isEmpty) ? 'Your profile' : name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasData
                        ? _profileSubtitle(profile!)
                        : 'Tell us a bit about yourself to unlock personalised targets.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.tonalIcon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              ),
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Edit'),
            ),
          ],
        ),
      ),
    );
  }

  static String _profileSubtitle(UserProfile p) {
    final parts = <String>[];
    if (p.sex != null)         parts.add(p.sex!.label);
    if (p.ageYears != null)    parts.add('${p.ageYears} yr');
    if (p.heightCm != null)    parts.add('${p.heightCm!.round()} cm');
    if (p.currentWeightKg != null) {
      parts.add('${p.currentWeightKg!.toStringAsFixed(1)} kg');
    }
    if (p.goalType != null)    parts.add(p.goalType!.label.toLowerCase());
    return parts.isEmpty ? '' : parts.join(' · ');
  }
}

// ============================================================================
// Weight card (current / target / chart / history)
// ============================================================================

class _WeightCard extends StatelessWidget {
  final List<WeightEntry> weights;
  final UserProfile? profile;
  final VoidCallback onAddWeight;

  const _WeightCard({
    required this.weights,
    required this.profile,
    required this.onAddWeight,
  });

  @override
  Widget build(BuildContext context) {
    final latest = weights.isNotEmpty
        ? weights.last.weightKg
        : profile?.currentWeightKg;
    final target = profile?.targetWeightKg;

    double? delta;
    if (weights.length >= 2) {
      delta = weights.last.weightKg - weights.first.weightKg;
    }

    double? toGo;
    if (latest != null && target != null) toGo = target - latest;

    return _SectionCard(
      icon: Icons.monitor_weight_outlined,
      title: 'Weight',
      trailing: FilledButton.icon(
        onPressed: onAddWeight,
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Log'),
      ),
      children: [
        Row(
          children: [
            Expanded(child: _StatBlock(
              label: 'Current',
              value: latest == null ? '—' : '${latest.toStringAsFixed(1)} kg',
              color: Theme.of(context).colorScheme.primary,
            )),
            const SizedBox(width: 8),
            Expanded(child: _StatBlock(
              label: 'Target',
              value: target == null ? '—' : '${target.toStringAsFixed(1)} kg',
              color: Theme.of(context).colorScheme.tertiary,
            )),
            const SizedBox(width: 8),
            Expanded(child: _StatBlock(
              label: toGo == null
                  ? 'Change'
                  : (toGo.abs() < 0.05 ? 'On target' : 'To go'),
              value: _deltaLabel(delta: delta, toGo: toGo),
              color: _deltaColor(toGo: toGo, delta: delta),
            )),
          ],
        ),
        const SizedBox(height: 12),
        if (weights.isEmpty)
          Container(
            height: 160,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Text(
              'No weight logged yet.\nTap "Log" to add your first measurement.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          )
        else
          SizedBox(
            height: 180,
            child: _WeightChart(
              entries: weights,
              targetKg: target,
            ),
          ),
        if (weights.isNotEmpty) ...[
          const SizedBox(height: 12),
          _HistoryList(weights: weights),
        ],
      ],
    );
  }

  static String _deltaLabel({double? delta, double? toGo}) {
    if (toGo != null) {
      if (toGo.abs() < 0.05) return '0.0 kg';
      final sign = toGo > 0 ? '+' : '';
      return '$sign${toGo.toStringAsFixed(1)} kg';
    }
    if (delta == null) return '—';
    final sign = delta > 0 ? '+' : '';
    return '$sign${delta.toStringAsFixed(1)} kg';
  }

  static Color _deltaColor({double? toGo, double? delta}) {
    final v = toGo ?? delta;
    if (v == null) return Colors.blueGrey;
    if (v.abs() < 0.05) return Colors.green;
    return Colors.orange;
  }
}

// ============================================================================
// Today's intake card
// ============================================================================

class _TodayCard extends StatelessWidget {
  final UserProfile? profile;
  final DateTime selectedDate;
  final double consumedCalories, calorieGoal;
  final double consumedProtein, proteinGoal;
  final double consumedCarbs, carbsGoal;
  final double consumedFat, fatGoal;

  const _TodayCard({
    required this.profile,
    required this.selectedDate,
    required this.consumedCalories,
    required this.calorieGoal,
    required this.consumedProtein,
    required this.proteinGoal,
    required this.consumedCarbs,
    required this.carbsGoal,
    required this.consumedFat,
    required this.fatGoal,
  });

  @override
  Widget build(BuildContext context) {
    final tdee = profile != null ? NutritionMath.tdee(profile!) : null;
    final bmi  = profile != null ? NutritionMath.bmi(profile!)  : null;
    final now = DateTime.now();
    final day = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final today = DateTime(now.year, now.month, now.day);
    final title = day == today
        ? 'Intake · today'
        : 'Intake · ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}';

    return _SectionCard(
      icon: Icons.today_outlined,
      title: title,
      children: [
        _ProgressRow(
          label: 'Calories',
          value: consumedCalories,
          goal:  calorieGoal,
          unit:  'kcal',
          color: Colors.deepOrange,
        ),
        const SizedBox(height: 10),
        _ProgressRow(
          label: 'Protein',
          value: consumedProtein,
          goal:  proteinGoal,
          unit:  'g',
          color: Colors.red,
        ),
        const SizedBox(height: 10),
        _ProgressRow(
          label: 'Carbs',
          value: consumedCarbs,
          goal:  carbsGoal,
          unit:  'g',
          color: Colors.amber.shade700,
        ),
        const SizedBox(height: 10),
        _ProgressRow(
          label: 'Fat',
          value: consumedFat,
          goal:  fatGoal,
          unit:  'g',
          color: Colors.green,
        ),
        if (tdee != null || bmi != null) ...[
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),
          Row(
            children: [
              if (tdee != null) Expanded(
                child: _MiniStat(
                  label: 'Estimated TDEE',
                  value: '${tdee.round()} kcal',
                  icon:  Icons.bolt,
                  color: Colors.blueGrey,
                ),
              ),
              if (bmi != null) Expanded(
                child: _MiniStat(
                  label: 'BMI · ${NutritionMath.bmiCategory(bmi)}',
                  value: bmi.toStringAsFixed(1),
                  icon:  Icons.insights_outlined,
                  color: Colors.indigo,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final String label;
  final double value;
  final double goal;
  final String unit;
  final Color color;

  const _ProgressRow({
    required this.label,
    required this.value,
    required this.goal,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final safeGoal = goal <= 0 ? 1.0 : goal;
    final pct = (value / safeGoal).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
            Text(
              '${value.round()} / ${goal.round()} $unit',
              style: TextStyle(color: Colors.grey[700], fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 8,
            backgroundColor: color.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// Bottom sheet — log a weight
// ============================================================================

class _LogWeightSheet extends StatefulWidget {
  final double? initialKg;
  const _LogWeightSheet({this.initialKg});

  @override
  State<_LogWeightSheet> createState() => _LogWeightSheetState();
}

class _LogWeightSheetState extends State<_LogWeightSheet> {
  late final TextEditingController _weightCtrl;
  late final TextEditingController _noteCtrl;
  DateTime _date = DateTime.now();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _weightCtrl = TextEditingController(
      text: widget.initialKg == null ? '' : widget.initialKg!.toStringAsFixed(1),
    );
    _noteCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    final raw = _weightCtrl.text.trim().replaceAll(',', '.');
    final kg = double.tryParse(raw);
    if (kg == null || kg <= 0 || kg > 500) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid weight (0–500 kg)')),
      );
      return;
    }

    setState(() => _saving = true);
    final saved = await context.read<UserProfileProvider>().logWeight(
          weightKg: kg,
          loggedOn: _date,
          note:     _noteCtrl.text,
        );
    if (!mounted) return;
    setState(() => _saving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(saved != null ? 'Weight logged' : 'Could not save. Try again.'),
        backgroundColor: saved != null ? Colors.green : Colors.red,
      ),
    );
    if (saved != null) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + insets),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Log weight',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  )),
          const SizedBox(height: 12),
          TextField(
            controller: _weightCtrl,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            decoration: const InputDecoration(
              labelText: 'Weight',
              suffixText: 'kg',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.monitor_weight_outlined),
            ),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(8),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Date',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today_outlined),
                suffixIcon: Icon(Icons.arrow_drop_down),
              ),
              child: Text(
                '${_date.day.toString().padLeft(2, '0')}/'
                '${_date.month.toString().padLeft(2, '0')}/'
                '${_date.year}',
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _noteCtrl,
            decoration: const InputDecoration(
              labelText: 'Note (optional)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.edit_note),
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.check),
            label: Text(_saving ? 'Saving…' : 'Save'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Chart
// ============================================================================

class _WeightChart extends StatelessWidget {
  final List<WeightEntry> entries;
  final double? targetKg;

  const _WeightChart({required this.entries, required this.targetKg});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _WeightChartPainter(
        entries: entries,
        targetKg: targetKg,
        lineColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

class _WeightChartPainter extends CustomPainter {
  final List<WeightEntry> entries;
  final double? targetKg;
  final Color lineColor;

  _WeightChartPainter({
    required this.entries,
    required this.targetKg,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.isEmpty) return;

    const padLeft = 36.0;
    const padRight = 12.0;
    const padTop = 10.0;
    const padBottom = 22.0;

    final chartW = size.width  - padLeft - padRight;
    final chartH = size.height - padTop  - padBottom;

    // Y range — include target in extents if set.
    final weightValues = entries.map((e) => e.weightKg).toList();
    double minY = weightValues.reduce(math.min);
    double maxY = weightValues.reduce(math.max);
    if (targetKg != null) {
      minY = math.min(minY, targetKg!);
      maxY = math.max(maxY, targetKg!);
    }
    if (minY == maxY) {
      minY -= 1;
      maxY += 1;
    } else {
      final pad = (maxY - minY) * 0.15;
      minY -= pad;
      maxY += pad;
    }

    // X range by date (days since first entry).
    final firstDay = entries.first.loggedOn;
    final lastDay  = entries.last.loggedOn;
    final totalDays = math.max(1, lastDay.difference(firstDay).inDays);

    Offset toOffset(WeightEntry e) {
      final dx = totalDays == 0
          ? 0.0
          : e.loggedOn.difference(firstDay).inDays / totalDays;
      final dy = (e.weightKg - minY) / (maxY - minY);
      return Offset(padLeft + dx * chartW, padTop + (1 - dy) * chartH);
    }

    final gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;
    final axisStyle = TextStyle(color: Colors.grey[600], fontSize: 10);

    // Gridlines (4 rows).
    for (var i = 0; i <= 4; i++) {
      final y = padTop + chartH * i / 4;
      canvas.drawLine(Offset(padLeft, y), Offset(padLeft + chartW, y), gridPaint);
      final value = maxY - (maxY - minY) * i / 4;
      _drawText(canvas, value.toStringAsFixed(1), Offset(0, y - 6), axisStyle);
    }

    // Target line.
    if (targetKg != null) {
      final y = padTop + (1 - (targetKg! - minY) / (maxY - minY)) * chartH;
      final tp = Paint()
        ..color = Colors.deepPurple.withValues(alpha: 0.7)
        ..strokeWidth = 1.2;
      // Dashed stroke.
      const dash = 6.0, gap = 4.0;
      double x = padLeft;
      while (x < padLeft + chartW) {
        canvas.drawLine(Offset(x, y), Offset(math.min(x + dash, padLeft + chartW), y), tp);
        x += dash + gap;
      }
      _drawText(
        canvas,
        'target',
        Offset(padLeft + chartW - 32, y - 12),
        const TextStyle(fontSize: 10, color: Colors.deepPurple,
            fontWeight: FontWeight.w600),
      );
    }

    // X-axis start/end labels.
    _drawText(canvas, _shortDate(firstDay),
        Offset(padLeft - 4, padTop + chartH + 4), axisStyle);
    if (totalDays > 0) {
      _drawText(
        canvas,
        _shortDate(lastDay),
        Offset(padLeft + chartW - 32, padTop + chartH + 4),
        axisStyle,
      );
    }

    // Line + area.
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final areaPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [lineColor.withValues(alpha: 0.35), lineColor.withValues(alpha: 0)],
      ).createShader(Rect.fromLTWH(padLeft, padTop, chartW, chartH));

    final linePath = Path();
    final areaPath = Path();
    final points = entries.map(toOffset).toList();

    for (var i = 0; i < points.length; i++) {
      if (i == 0) {
        linePath.moveTo(points[i].dx, points[i].dy);
        areaPath.moveTo(points[i].dx, padTop + chartH);
        areaPath.lineTo(points[i].dx, points[i].dy);
      } else {
        linePath.lineTo(points[i].dx, points[i].dy);
        areaPath.lineTo(points[i].dx, points[i].dy);
      }
    }
    areaPath.lineTo(points.last.dx, padTop + chartH);
    areaPath.close();

    canvas.drawPath(areaPath, areaPaint);
    canvas.drawPath(linePath, linePaint);

    // Dots.
    final dotPaint = Paint()..color = lineColor;
    final dotRing = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (final p in points) {
      canvas.drawCircle(p, 3.2, dotPaint);
      canvas.drawCircle(p, 3.2, dotRing);
    }
  }

  void _drawText(Canvas canvas, String text, Offset offset, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  static String _shortDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';

  @override
  bool shouldRepaint(covariant _WeightChartPainter old) =>
      old.entries != entries ||
      old.targetKg != targetKg ||
      old.lineColor != lineColor;
}

// ============================================================================
// History list
// ============================================================================

class _HistoryList extends StatelessWidget {
  final List<WeightEntry> weights;
  const _HistoryList({required this.weights});

  @override
  Widget build(BuildContext context) {
    // Show newest first, max 10 rows.
    final recent = [...weights.reversed].take(10).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 4),
        Text('History',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                )),
        const SizedBox(height: 6),
        ...recent.map((e) => _HistoryRow(entry: e)),
      ],
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final WeightEntry entry;
  const _HistoryRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('weight-${entry.id ?? entry.loggedOn.toIso8601String()}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        color: Colors.red.withValues(alpha: 0.15),
        child: const Icon(Icons.delete_outline, color: Colors.red),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Delete entry?'),
                content: Text(
                  'Remove the weight log for '
                  '${entry.loggedOn.day}/${entry.loggedOn.month}/${entry.loggedOn.year}?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (_) {
        context.read<UserProfileProvider>().deleteWeight(entry);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            const Icon(Icons.scale_outlined, size: 18, color: Colors.blueGrey),
            const SizedBox(width: 10),
            Text(
              '${entry.loggedOn.day.toString().padLeft(2, '0')}/'
              '${entry.loggedOn.month.toString().padLeft(2, '0')}/'
              '${entry.loggedOn.year}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            Text(
              '${entry.weightKg.toStringAsFixed(1)} kg',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Shared widgets (local copies to keep the screen self-contained)
// ============================================================================

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final List<Widget> children;

  const _SectionCard({
    required this.icon,
    required this.title,
    this.trailing,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatBlock({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600, color: color)),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(fontSize: 11, color: Colors.grey[700])),
              Text(value,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }
}
