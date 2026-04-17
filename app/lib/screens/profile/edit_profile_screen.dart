import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/user_profile.dart';
import '../../providers/daily_log_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../utils/nutrition_math.dart';

/// Full-featured Edit-Profile screen. Collects everything we need to compute
/// BMR / TDEE and give the user meaningful goal suggestions.
///
/// Layout (top-down):
///   1. "You" card            — name, sex, DOB
///   2. "Body stats" card     — height, current/target weight
///   3. "Lifestyle & goal"    — activity level, goal type, weekly rate
///   4. Suggested plan card   — TDEE + suggested calorie + macro targets
///                               with a "Use these as my daily targets" action
///
/// The screen is idempotent: opening, tapping Save with no changes, and
/// closing leaves state identical to before.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for numeric / text inputs.
  late final TextEditingController _nameCtrl;
  late final TextEditingController _heightCtrl;
  late final TextEditingController _weightCtrl;
  late final TextEditingController _targetWeightCtrl;
  late final TextEditingController _rateCtrl;

  Sex? _sex;
  DateTime? _dob;
  GoalType? _goal;
  ActivityLevel? _activity;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = context.read<UserProfileProvider>().profile;

    _nameCtrl         = TextEditingController(text: p?.displayName ?? '');
    _heightCtrl       = TextEditingController(text: _fmt(p?.heightCm));
    _weightCtrl       = TextEditingController(text: _fmt(p?.currentWeightKg));
    _targetWeightCtrl = TextEditingController(text: _fmt(p?.targetWeightKg));
    _rateCtrl         = TextEditingController(text: _fmt(p?.weeklyRateKg));

    _sex      = p?.sex;
    _dob      = p?.dateOfBirth;
    _goal     = p?.goalType;
    _activity = p?.activityLevel;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _targetWeightCtrl.dispose();
    _rateCtrl.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------------- //
  // Helpers                                                             //
  // ------------------------------------------------------------------- //

  static String _fmt(double? v) {
    if (v == null) return '';
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(1);
  }

  double? _parse(String s) {
    final clean = s.trim().replaceAll(',', '.');
    if (clean.isEmpty) return null;
    return double.tryParse(clean);
  }

  /// Build a live [UserProfile] reflecting the current form state without
  /// persisting anything. Used to show the suggested plan in real-time.
  UserProfile _previewProfile() {
    final uid = context.read<UserProfileProvider>().userId ?? '';
    return UserProfile(
      userId:          uid,
      displayName:     _nameCtrl.text.trim().isEmpty ? null : _nameCtrl.text.trim(),
      sex:             _sex,
      dateOfBirth:     _dob,
      heightCm:        _parse(_heightCtrl.text),
      currentWeightKg: _parse(_weightCtrl.text),
      targetWeightKg:  _parse(_targetWeightCtrl.text),
      goalType:        _goal,
      activityLevel:   _activity,
      weeklyRateKg:    _parse(_rateCtrl.text),
    );
  }

  Future<void> _pickDob() async {
    final now   = DateTime.now();
    final first = DateTime(now.year - 100, now.month, now.day);
    final last  = DateTime(now.year - 10,  now.month, now.day);
    final initial = _dob ?? DateTime(now.year - 25, now.month, now.day);

    final picked = await showDatePicker(
      context:     context,
      initialDate: initial,
      firstDate:   first,
      lastDate:    last,
      helpText:    'Select your date of birth',
    );
    if (picked != null) setState(() => _dob = picked);
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final profileProv = context.read<UserProfileProvider>();
    setState(() => _saving = true);

    final patched = _previewProfile();
    final ok = await profileProv.saveProfilePatch(
      displayName:     patched.displayName,
      sex:             patched.sex,
      dateOfBirth:     patched.dateOfBirth,
      heightCm:        patched.heightCm,
      currentWeightKg: patched.currentWeightKg,
      targetWeightKg:  patched.targetWeightKg,
      goalType:        patched.goalType,
      activityLevel:   patched.activityLevel,
      weeklyRateKg:    patched.weeklyRateKg,
    );

    if (!mounted) return;
    setState(() => _saving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok
            ? 'Profile saved'
            : 'Could not reach the server — check your connection.'),
        backgroundColor: ok ? Colors.green : Colors.orange,
      ),
    );
    if (ok) Navigator.of(context).pop();
  }

  Future<void> _applySuggestedGoals(MacroTargets targets) async {
    final dailyProv = context.read<DailyLogProvider>();
    final ok = await dailyProv.updateGoals(
      calorieGoal: targets.calories.roundToDouble(),
      proteinGoal: targets.protein.roundToDouble(),
      carbsGoal:   targets.carbs.roundToDouble(),
      fatGoal:     targets.fat.roundToDouble(),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok
            ? 'Daily targets updated from your profile.'
            : 'Saved locally — will sync when you\'re back online.'),
        backgroundColor: ok ? Colors.green : Colors.orange,
      ),
    );
  }

  // ------------------------------------------------------------------- //
  // Build                                                               //
  // ------------------------------------------------------------------- //

  @override
  Widget build(BuildContext context) {
    final preview = _previewProfile();
    final bmi     = NutritionMath.bmi(preview);
    final tdee    = NutritionMath.tdee(preview);
    final targets = NutritionMath.recommendedMacros(preview);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Form(
        key: _formKey,
        onChanged: () => setState(() {}), // live preview
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
          children: [
            _SectionCard(
              icon: Icons.person_outline,
              title: 'About you',
              children: [
                TextFormField(
                  controller: _nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Display name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<Sex>(
                  initialValue: _sex,
                  items: Sex.values
                      .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
                      .toList(),
                  onChanged: (v) => setState(() => _sex = v),
                  decoration: const InputDecoration(
                    labelText: 'Sex (for BMR calculation)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.wc_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                _DobField(
                  date: _dob,
                  onTap: _pickDob,
                ),
              ],
            ),
            const SizedBox(height: 12),

            _SectionCard(
              icon: Icons.straighten,
              title: 'Body stats',
              children: [
                _numericField(
                  controller: _heightCtrl,
                  label: 'Height',
                  suffix: 'cm',
                  icon: Icons.height,
                ),
                const SizedBox(height: 12),
                _numericField(
                  controller: _weightCtrl,
                  label: 'Current weight',
                  suffix: 'kg',
                  icon: Icons.monitor_weight_outlined,
                ),
                const SizedBox(height: 12),
                _numericField(
                  controller: _targetWeightCtrl,
                  label: 'Target weight',
                  suffix: 'kg',
                  icon: Icons.flag_outlined,
                ),
                if (bmi != null) ...[
                  const SizedBox(height: 12),
                  _BmiChip(bmi: bmi),
                ],
              ],
            ),
            const SizedBox(height: 12),

            _SectionCard(
              icon: Icons.directions_run,
              title: 'Lifestyle & goal',
              children: [
                DropdownButtonFormField<ActivityLevel>(
                  initialValue: _activity,
                  isExpanded: true,
                  items: ActivityLevel.values.map((a) {
                    return DropdownMenuItem(
                      value: a,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(a.label, maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text(
                            a.hint,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _activity = v),
                  decoration: const InputDecoration(
                    labelText: 'Activity level',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.bolt_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<GoalType>(
                  initialValue: _goal,
                  items: GoalType.values
                      .map((g) => DropdownMenuItem(value: g, child: Text(g.label)))
                      .toList(),
                  onChanged: (v) => setState(() => _goal = v),
                  decoration: const InputDecoration(
                    labelText: 'Primary goal',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.track_changes_outlined),
                  ),
                ),
                if (_goal != null && _goal != GoalType.maintain) ...[
                  const SizedBox(height: 12),
                  _numericField(
                    controller: _rateCtrl,
                    label: _goal == GoalType.lose
                        ? 'Target loss rate'
                        : 'Target gain rate',
                    suffix: 'kg / week',
                    icon: Icons.speed_outlined,
                    helper: _goal == GoalType.lose
                        ? '0.25–0.75 kg/week is a sustainable range'
                        : '0.1–0.5 kg/week supports lean gain',
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),

            _SuggestedPlanCard(
              profile:   preview,
              tdee:      tdee,
              targets:   targets,
              onApply:   targets == null ? null : () => _applySuggestedGoals(targets),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(_saving ? 'Saving…' : 'Save profile'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _numericField({
    required TextEditingController controller,
    required String label,
    required String suffix,
    required IconData icon,
    String? helper,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
      ],
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
        helperText: helper,
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return null;
        final parsed = _parse(v);
        if (parsed == null) return 'Enter a valid number';
        if (parsed < 0) return 'Must be positive';
        return null;
      },
    );
  }
}

// ============================================================================
// Internal widgets
// ============================================================================

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;

  const _SectionCard({
    required this.icon,
    required this.title,
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
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
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

class _DobField extends StatelessWidget {
  final DateTime? date;
  final VoidCallback onTap;

  const _DobField({required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final label = date == null
        ? 'Date of birth'
        : '${date!.day.toString().padLeft(2, '0')}/'
          '${date!.month.toString().padLeft(2, '0')}/'
          '${date!.year}';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Date of birth',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.cake_outlined),
          suffixIcon: Icon(Icons.arrow_drop_down),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: date == null ? Colors.grey[600] : null,
          ),
        ),
      ),
    );
  }
}

class _BmiChip extends StatelessWidget {
  final double bmi;

  const _BmiChip({required this.bmi});

  @override
  Widget build(BuildContext context) {
    final cat = NutritionMath.bmiCategory(bmi);
    final color = switch (cat) {
      'Healthy'    => Colors.green,
      'Overweight' => Colors.orange,
      'Obese'      => Colors.red,
      _            => Colors.blueGrey,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.insights_outlined, color: color, size: 18),
          const SizedBox(width: 8),
          Text('BMI ${bmi.toStringAsFixed(1)}',
              style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Text('· $cat', style: TextStyle(color: color)),
        ],
      ),
    );
  }
}

class _SuggestedPlanCard extends StatelessWidget {
  final UserProfile profile;
  final double? tdee;
  final MacroTargets? targets;
  final VoidCallback? onApply;

  const _SuggestedPlanCard({
    required this.profile,
    required this.tdee,
    required this.targets,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: cs.primary.withValues(alpha: 0.35)),
      ),
      color: cs.primary.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: cs.primary, size: 18),
                const SizedBox(width: 8),
                Text('Suggested plan',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: cs.primary,
                        )),
              ],
            ),
            const SizedBox(height: 10),
            if (!profile.isComplete || targets == null)
              Text(
                'Fill in your sex, date of birth, height, current weight, '
                'activity level and goal to see personalised recommendations.',
                style: TextStyle(color: Colors.grey[700]),
              )
            else ...[
              Row(
                children: [
                  Expanded(child: _StatTile(
                    label: 'TDEE',
                    value: '${tdee!.round()} kcal',
                    hint: 'Maintenance',
                    color: Colors.blueGrey,
                  )),
                  const SizedBox(width: 8),
                  Expanded(child: _StatTile(
                    label: 'Calories',
                    value: '${targets!.calories.round()} kcal',
                    hint: 'Per day',
                    color: Colors.deepOrange,
                  )),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _StatTile(
                    label: 'Protein',
                    value: '${targets!.protein.round()} g',
                    hint: '',
                    color: Colors.red,
                  )),
                  const SizedBox(width: 8),
                  Expanded(child: _StatTile(
                    label: 'Carbs',
                    value: '${targets!.carbs.round()} g',
                    hint: '',
                    color: Colors.amber.shade700,
                  )),
                  const SizedBox(width: 8),
                  Expanded(child: _StatTile(
                    label: 'Fat',
                    value: '${targets!.fat.round()} g',
                    hint: '',
                    color: Colors.green,
                  )),
                ],
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: onApply,
                icon: const Icon(Icons.flag_outlined),
                label: const Text('Use these as my daily targets'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final String hint;
  final Color color;

  const _StatTile({
    required this.label,
    required this.value,
    required this.hint,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          if (hint.isNotEmpty)
            Text(hint, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        ],
      ),
    );
  }
}
