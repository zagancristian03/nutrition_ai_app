import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/ai_provider.dart';

/// Guided onboarding flow. Captures structured answers the backend persists
/// in `user_ai_profiles`. Prioritizes detail + flexibility:
///   * main goals are MULTI-select (body recomp = lose_weight + gain_muscle)
///   * each section has a free-text note for anything the chips don't cover
///   * dedicated Training and Lifestyle sections so the coach can reason
///     about activity level, recovery, cravings, etc.
class AiOnboardingScreen extends StatefulWidget {
  const AiOnboardingScreen({super.key});

  @override
  State<AiOnboardingScreen> createState() => _AiOnboardingScreenState();
}

class _AiOnboardingScreenState extends State<AiOnboardingScreen> {
  // ---------------------------------------------------------------- Goals
  final Set<String> _mainGoals = {};
  final _mainGoalNoteCtrl = TextEditingController();
  String? _approachStyle;

  // ---------------------------------------------------------------- Diet
  String? _dietaryPattern;
  final _dietaryPatternNoteCtrl = TextEditingController();
  final _allergiesCtrl          = TextEditingController();
  final _dislikedCtrl           = TextEditingController();
  final _favoritesCtrl          = TextEditingController();
  final _cuisinesCtrl           = TextEditingController();
  String? _eatingOutFrequency;
  String? _budgetSensitivity;
  String? _cookingPreference;
  int?    _mealFrequency;

  // ------------------------------------------------------ Training / activity
  int?              _trainingFrequencyPerWeek;
  final Set<String> _trainingTypes = {};
  String?           _trainingIntensity;
  final _trainingNotesCtrl = TextEditingController();
  String? _jobActivity;
  String? _stepsPerDayBand;

  // ------------------------------------------------------- Lifestyle / recovery
  String? _sleepHoursBand;
  String? _stressLevel;
  String? _waterIntake;
  String? _alcoholFrequency;

  // ---------------------------------------------------------- Behavioral
  final Set<String> _biggestStruggles = {};
  final _biggestStruggleNoteCtrl = TextEditingController();
  String? _struggleTiming;
  String? _motivationLevel;
  String? _structurePreference;

  // ---------------------------------------------------------------- Tone
  String _coachTone = 'balanced';

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = context.read<AiProvider>().profile;
    if (p == null) return;

    _mainGoals.addAll(p.mainGoals);
    _mainGoalNoteCtrl.text = p.mainGoalNote ?? '';
    _approachStyle = p.approachStyle;

    _dietaryPattern = p.dietaryPattern;
    _dietaryPatternNoteCtrl.text = p.dietaryPatternNote ?? '';
    _allergiesCtrl.text  = p.allergies      ?? '';
    _dislikedCtrl.text   = p.dislikedFoods  ?? '';
    _favoritesCtrl.text  = p.favoriteFoods  ?? '';
    _cuisinesCtrl.text   = p.cuisinesEnjoyed ?? '';
    _eatingOutFrequency  = p.eatingOutFrequency;
    _budgetSensitivity   = p.budgetSensitivity;
    _cookingPreference   = p.cookingPreference;
    _mealFrequency       = p.mealFrequency;

    _trainingFrequencyPerWeek = p.trainingFrequencyPerWeek;
    _trainingTypes.addAll(p.trainingTypes);
    _trainingIntensity = p.trainingIntensity;
    _trainingNotesCtrl.text = p.trainingNotes ?? '';
    _jobActivity      = p.jobActivity;
    _stepsPerDayBand  = p.stepsPerDayBand;

    _sleepHoursBand   = p.sleepHoursBand;
    _stressLevel      = p.stressLevel;
    _waterIntake      = p.waterIntake;
    _alcoholFrequency = p.alcoholFrequency;

    _biggestStruggles.addAll(p.biggestStruggles);
    _biggestStruggleNoteCtrl.text = p.biggestStruggleNote ?? '';
    _struggleTiming      = p.struggleTiming;
    _motivationLevel     = p.motivationLevel;
    _structurePreference = p.structurePreference;

    _coachTone = p.coachTone;
  }

  @override
  void dispose() {
    _mainGoalNoteCtrl.dispose();
    _dietaryPatternNoteCtrl.dispose();
    _allergiesCtrl.dispose();
    _dislikedCtrl.dispose();
    _favoritesCtrl.dispose();
    _cuisinesCtrl.dispose();
    _trainingNotesCtrl.dispose();
    _biggestStruggleNoteCtrl.dispose();
    super.dispose();
  }

  bool get _requiredFilled =>
      _mainGoals.isNotEmpty &&
      _approachStyle != null &&
      _dietaryPattern != null;

  Future<void> _save({required bool markCompleted}) async {
    if (markCompleted && !_requiredFilled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(
          'Pick at least one goal, an approach, and a diet pattern to finish.',
        )),
      );
      return;
    }

    String? trimmedOrNull(TextEditingController c) {
      final s = c.text.trim();
      return s.isEmpty ? null : s;
    }

    final answers = <String, dynamic>{
      if (_mainGoals.isNotEmpty) 'main_goals': _mainGoals.toList(),
      if (trimmedOrNull(_mainGoalNoteCtrl) != null)
        'main_goal_note': trimmedOrNull(_mainGoalNoteCtrl),
      if (_approachStyle != null) 'approach_style': _approachStyle,

      if (_dietaryPattern != null) 'dietary_pattern': _dietaryPattern,
      if (trimmedOrNull(_dietaryPatternNoteCtrl) != null)
        'dietary_pattern_note': trimmedOrNull(_dietaryPatternNoteCtrl),
      if (trimmedOrNull(_allergiesCtrl) != null)
        'allergies': trimmedOrNull(_allergiesCtrl),
      if (trimmedOrNull(_dislikedCtrl) != null)
        'disliked_foods': trimmedOrNull(_dislikedCtrl),
      if (trimmedOrNull(_favoritesCtrl) != null)
        'favorite_foods': trimmedOrNull(_favoritesCtrl),
      if (trimmedOrNull(_cuisinesCtrl) != null)
        'cuisines_enjoyed': trimmedOrNull(_cuisinesCtrl),
      if (_eatingOutFrequency != null) 'eating_out_frequency': _eatingOutFrequency,
      if (_budgetSensitivity != null) 'budget_sensitivity': _budgetSensitivity,
      if (_cookingPreference != null) 'cooking_preference': _cookingPreference,
      if (_mealFrequency != null) 'meal_frequency': _mealFrequency,

      if (_trainingFrequencyPerWeek != null)
        'training_frequency_per_week': _trainingFrequencyPerWeek,
      if (_trainingTypes.isNotEmpty) 'training_types': _trainingTypes.toList(),
      if (_trainingIntensity != null) 'training_intensity': _trainingIntensity,
      if (trimmedOrNull(_trainingNotesCtrl) != null)
        'training_notes': trimmedOrNull(_trainingNotesCtrl),
      if (_jobActivity != null) 'job_activity': _jobActivity,
      if (_stepsPerDayBand != null) 'steps_per_day_band': _stepsPerDayBand,

      if (_sleepHoursBand != null) 'sleep_hours_band': _sleepHoursBand,
      if (_stressLevel != null) 'stress_level': _stressLevel,
      if (_waterIntake != null) 'water_intake': _waterIntake,
      if (_alcoholFrequency != null) 'alcohol_frequency': _alcoholFrequency,

      if (_biggestStruggles.isNotEmpty)
        'biggest_struggles': _biggestStruggles.toList(),
      if (trimmedOrNull(_biggestStruggleNoteCtrl) != null)
        'biggest_struggle_note': trimmedOrNull(_biggestStruggleNoteCtrl),
      if (_struggleTiming != null) 'struggle_timing': _struggleTiming,
      if (_motivationLevel != null) 'motivation_level': _motivationLevel,
      if (_structurePreference != null) 'structure_preference': _structurePreference,

      'coach_tone': _coachTone,
    };

    setState(() => _saving = true);
    final ok = await context
        .read<AiProvider>()
        .saveOnboarding(answers, markCompleted: markCompleted);
    if (!mounted) return;
    setState(() => _saving = false);

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(
          "Couldn't save. Check your connection and try again.",
        )),
      );
      return;
    }

    if (markCompleted) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Draft saved.')),
      );
    }
  }

  // ----------------------------------------------------------------------- //
  // Build                                                                   //
  // ----------------------------------------------------------------------- //

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Coach setup'),
        actions: [
          TextButton(
            onPressed: _saving ? null : () => _save(markCompleted: false),
            child: const Text('Save draft'),
          ),
        ],
      ),
      body: AbsorbPointer(
        absorbing: _saving,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
          children: [
            Text(
              'Answer what applies. You can combine goals (e.g. lose weight + '
              'gain muscle for body recomposition), and every section has a '
              'free-text box for anything the options don\'t cover.',
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 16),

            // ---------------------------------------------------- GOALS
            _Section(title: 'Your goals', subtitle: 'Pick one or more'),
            _MultiChipGroup(
              values: _mainGoals,
              options: const [
                _Opt('lose_weight',          'Lose weight'),
                _Opt('gain_muscle',          'Gain muscle'),
                _Opt('maintain',             'Maintain weight'),
                _Opt('eat_healthier',        'Eat healthier'),
                _Opt('improve_energy',       'More energy'),
                _Opt('improve_performance',  'Athletic performance'),
                _Opt('improve_consistency',  'Be consistent'),
              ],
              onChanged: () => setState(() {}),
            ),
            const SizedBox(height: 8),
            _NoteField(
              label: 'Any other goal or context?',
              hint: 'e.g. prep for a half-marathon in 12 weeks',
              controller: _mainGoalNoteCtrl,
            ),

            const _Spacer(),
            _Section(title: 'How do you want to approach it?'),
            _SingleChipGroup(
              value: _approachStyle,
              options: const [
                _Opt('aggressive',   'Aggressive'),
                _Opt('balanced',     'Balanced'),
                _Opt('flexible',     'Flexible'),
                _Opt('sustainable',  'Slow & sustainable'),
              ],
              onChanged: (v) => setState(() => _approachStyle = v),
            ),

            // ------------------------------------------------- TRAINING
            const _Spacer(),
            _Section(
              title: 'Training & activity',
              subtitle: 'Shapes calorie + protein targets',
            ),
            _SingleChipGroup(
              label: 'Training sessions per week',
              value: _trainingFrequencyPerWeek?.toString(),
              options: const [
                _Opt('0', '0'),
                _Opt('1', '1'),
                _Opt('2', '2'),
                _Opt('3', '3'),
                _Opt('4', '4'),
                _Opt('5', '5'),
                _Opt('6', '6'),
                _Opt('7', '7+'),
              ],
              onChanged: (v) => setState(
                () => _trainingFrequencyPerWeek =
                    v == null ? null : int.tryParse(v),
              ),
            ),
            const SizedBox(height: 10),
            _MultiChipGroup(
              label: 'Types of training (pick all that apply)',
              values: _trainingTypes,
              options: const [
                _Opt('lifting',          'Weight lifting'),
                _Opt('cardio',           'Cardio'),
                _Opt('hiit',             'HIIT / intervals'),
                _Opt('sports',           'Team sports'),
                _Opt('running',          'Running'),
                _Opt('cycling',          'Cycling'),
                _Opt('swimming',         'Swimming'),
                _Opt('yoga_flexibility', 'Yoga / mobility'),
                _Opt('walking',          'Walking'),
                _Opt('none',             'None currently'),
              ],
              onChanged: () => setState(() {}),
            ),
            const SizedBox(height: 10),
            _SingleChipGroup(
              label: 'Typical session intensity',
              value: _trainingIntensity,
              options: const [
                _Opt('light',      'Light'),
                _Opt('moderate',   'Moderate'),
                _Opt('hard',       'Hard'),
                _Opt('very_hard',  'Very hard'),
              ],
              onChanged: (v) => setState(() => _trainingIntensity = v),
            ),
            const SizedBox(height: 10),
            _SingleChipGroup(
              label: 'Daytime / job activity',
              value: _jobActivity,
              options: const [
                _Opt('desk',           'Mostly at a desk'),
                _Opt('mostly_seated',  'Seated with some movement'),
                _Opt('on_feet',        'On my feet a lot'),
                _Opt('physical_labor', 'Physical labor'),
              ],
              onChanged: (v) => setState(() => _jobActivity = v),
            ),
            const SizedBox(height: 10),
            _SingleChipGroup(
              label: 'Average daily steps',
              value: _stepsPerDayBand,
              options: const [
                _Opt('under_5k',  '< 5k'),
                _Opt('5k_7k',     '5-7k'),
                _Opt('7k_10k',    '7-10k'),
                _Opt('10k_15k',   '10-15k'),
                _Opt('over_15k',  '15k+'),
              ],
              onChanged: (v) => setState(() => _stepsPerDayBand = v),
            ),
            const SizedBox(height: 8),
            _NoteField(
              label: 'Training notes',
              hint: 'e.g. push/pull/legs split, long runs on Sunday',
              controller: _trainingNotesCtrl,
            ),

            // -------------------------------------------------- DIET
            const _Spacer(),
            _Section(title: 'Diet pattern'),
            _SingleChipGroup(
              value: _dietaryPattern,
              options: const [
                _Opt('omnivore',     'Omnivore'),
                _Opt('vegetarian',   'Vegetarian'),
                _Opt('vegan',        'Vegan'),
                _Opt('pescatarian',  'Pescatarian'),
                _Opt('other',        'Other'),
              ],
              onChanged: (v) => setState(() => _dietaryPattern = v),
            ),
            const SizedBox(height: 8),
            _NoteField(
              label: 'Dietary notes / restrictions',
              hint: 'e.g. low-FODMAP, halal, keto, diabetic, fasting schedule',
              controller: _dietaryPatternNoteCtrl,
            ),
            const SizedBox(height: 10),
            _NoteField(
              label: 'Allergies or intolerances',
              hint: 'e.g. peanuts, lactose, gluten',
              controller: _allergiesCtrl,
            ),
            const SizedBox(height: 10),
            _NoteField(
              label: 'Disliked foods',
              hint: 'e.g. mushrooms, liver, coriander',
              controller: _dislikedCtrl,
            ),
            const SizedBox(height: 10),
            _NoteField(
              label: 'Favorite foods',
              hint: 'e.g. chicken, rice, Greek yogurt, apples',
              controller: _favoritesCtrl,
            ),
            const SizedBox(height: 10),
            _NoteField(
              label: 'Cuisines you enjoy',
              hint: 'e.g. Italian, Japanese, Mexican, Lebanese',
              controller: _cuisinesCtrl,
            ),
            const SizedBox(height: 10),
            _SingleChipGroup(
              label: 'Eating out frequency',
              value: _eatingOutFrequency,
              options: const [
                _Opt('rarely',  'Rarely'),
                _Opt('weekly',  '1-2x / week'),
                _Opt('often',   '3-5x / week'),
                _Opt('daily',   'Daily'),
              ],
              onChanged: (v) => setState(() => _eatingOutFrequency = v),
            ),

            const _Spacer(),
            _Section(title: 'Cooking & budget'),
            _SingleChipGroup(
              label: 'Cooking preference',
              value: _cookingPreference,
              options: const [
                _Opt('none',    "I don't cook"),
                _Opt('simple',  'Simple meals only'),
                _Opt('enjoys',  'I enjoy cooking'),
              ],
              onChanged: (v) => setState(() => _cookingPreference = v),
            ),
            const SizedBox(height: 8),
            _SingleChipGroup(
              label: 'Budget sensitivity',
              value: _budgetSensitivity,
              options: const [
                _Opt('low',     'Not a concern'),
                _Opt('medium',  'Somewhat'),
                _Opt('high',    'Very tight'),
              ],
              onChanged: (v) => setState(() => _budgetSensitivity = v),
            ),
            const SizedBox(height: 8),
            _SingleChipGroup(
              label: 'Meals per day',
              value: _mealFrequency?.toString(),
              options: const [
                _Opt('2', '2'),
                _Opt('3', '3'),
                _Opt('4', '4'),
                _Opt('5', '5'),
                _Opt('6', '6'),
              ],
              onChanged: (v) => setState(
                () => _mealFrequency = v == null ? null : int.tryParse(v),
              ),
            ),

            // -------------------------------------------------- LIFESTYLE
            const _Spacer(),
            _Section(
              title: 'Lifestyle & recovery',
              subtitle: 'Affects energy, cravings, adherence',
            ),
            _SingleChipGroup(
              label: 'Average sleep',
              value: _sleepHoursBand,
              options: const [
                _Opt('under_5',  '< 5 h'),
                _Opt('5_6',      '5-6 h'),
                _Opt('6_7',      '6-7 h'),
                _Opt('7_8',      '7-8 h'),
                _Opt('over_8',   '8+ h'),
              ],
              onChanged: (v) => setState(() => _sleepHoursBand = v),
            ),
            const SizedBox(height: 8),
            _SingleChipGroup(
              label: 'Typical stress level',
              value: _stressLevel,
              options: const [
                _Opt('low',     'Low'),
                _Opt('medium',  'Medium'),
                _Opt('high',    'High'),
              ],
              onChanged: (v) => setState(() => _stressLevel = v),
            ),
            const SizedBox(height: 8),
            _SingleChipGroup(
              label: 'Water intake',
              value: _waterIntake,
              options: const [
                _Opt('low',     'Low'),
                _Opt('medium',  'Medium'),
                _Opt('high',    'High'),
              ],
              onChanged: (v) => setState(() => _waterIntake = v),
            ),
            const SizedBox(height: 8),
            _SingleChipGroup(
              label: 'Alcohol frequency',
              value: _alcoholFrequency,
              options: const [
                _Opt('none',        'None'),
                _Opt('occasional',  'Occasional'),
                _Opt('weekly',      '1-2x / week'),
                _Opt('frequent',    '3+ / week'),
              ],
              onChanged: (v) => setState(() => _alcoholFrequency = v),
            ),

            // -------------------------------------------------- STRUGGLES
            const _Spacer(),
            _Section(title: 'What tends to get in the way?'),
            _MultiChipGroup(
              label: 'Biggest struggles (pick any that apply)',
              values: _biggestStruggles,
              options: const [
                _Opt('cravings',      'Cravings'),
                _Opt('consistency',   'Staying consistent'),
                _Opt('late_night',    'Late-night eating'),
                _Opt('emotional',     'Emotional eating'),
                _Opt('boredom',       'Boredom eating'),
                _Opt('time',          'Lack of time'),
                _Opt('social',        'Social / eating out'),
                _Opt('travel',        'Travel'),
                _Opt('portion_size',  'Portion control'),
                _Opt('planning',      'Meal planning'),
              ],
              onChanged: () => setState(() {}),
            ),
            const SizedBox(height: 8),
            _NoteField(
              label: 'Anything else about what holds you back?',
              hint: 'e.g. shift work, kids\' leftovers, weekend events',
              controller: _biggestStruggleNoteCtrl,
            ),
            const SizedBox(height: 10),
            _SingleChipGroup(
              label: 'When does it hit hardest?',
              value: _struggleTiming,
              options: const [
                _Opt('morning',    'Morning'),
                _Opt('afternoon',  'Afternoon'),
                _Opt('evening',    'Evening'),
                _Opt('night',      'Late night'),
                _Opt('weekends',   'Weekends'),
                _Opt('stress',     'When stressed'),
              ],
              onChanged: (v) => setState(() => _struggleTiming = v),
            ),

            const _Spacer(),
            _Section(title: 'Motivation & structure'),
            _SingleChipGroup(
              label: 'Motivation level',
              value: _motivationLevel,
              options: const [
                _Opt('low',     'Low'),
                _Opt('medium',  'Medium'),
                _Opt('high',    'High'),
              ],
              onChanged: (v) => setState(() => _motivationLevel = v),
            ),
            const SizedBox(height: 8),
            _SingleChipGroup(
              label: 'How much structure do you want?',
              value: _structurePreference,
              options: const [
                _Opt('low',     'Loose guidance'),
                _Opt('medium',  'Balanced plan'),
                _Opt('high',    'Detailed plan'),
              ],
              onChanged: (v) => setState(() => _structurePreference = v),
            ),

            const _Spacer(),
            _Section(title: 'Coach tone'),
            _SingleChipGroup(
              value: _coachTone,
              allowNull: false,
              options: const [
                _Opt('direct',    'Direct'),
                _Opt('balanced',  'Balanced'),
                _Opt('gentler',   'Gentler'),
              ],
              onChanged: (v) => setState(() => _coachTone = v ?? 'balanced'),
            ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: _saving || !_requiredFilled
                    ? null
                    : () => _save(markCompleted: true),
                child: _saving
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Finish & start chatting'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// --------------------------------------------------------------------------- //
// Small helpers                                                               //
// --------------------------------------------------------------------------- //

class _Opt {
  final String value;
  final String label;
  const _Opt(this.value, this.label);
}

class _Spacer extends StatelessWidget {
  const _Spacer();
  @override
  Widget build(BuildContext context) => const SizedBox(height: 22);
}

class _Section extends StatelessWidget {
  final String title;
  final String? subtitle;
  const _Section({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                subtitle!,
                style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
              ),
            ),
        ],
      ),
    );
  }
}

class _SingleChipGroup extends StatelessWidget {
  final String? label;
  final String? value;
  final List<_Opt> options;
  final ValueChanged<String?> onChanged;
  final bool allowNull;

  const _SingleChipGroup({
    required this.value,
    required this.options,
    required this.onChanged,
    this.label,
    this.allowNull = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 6),
        ],
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: options.map((o) {
            final selected = o.value == value;
            return ChoiceChip(
              label: Text(o.label),
              selected: selected,
              onSelected: (isOn) {
                if (!isOn && !allowNull) return;
                onChanged(isOn ? o.value : null);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _MultiChipGroup extends StatelessWidget {
  final String? label;
  final Set<String> values;
  final List<_Opt> options;
  final VoidCallback onChanged;

  const _MultiChipGroup({
    required this.values,
    required this.options,
    required this.onChanged,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 6),
        ],
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: options.map((o) {
            final selected = values.contains(o.value);
            return FilterChip(
              label: Text(o.label),
              selected: selected,
              onSelected: (isOn) {
                if (isOn) {
                  values.add(o.value);
                } else {
                  values.remove(o.value);
                }
                onChanged();
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _NoteField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;

  const _NoteField({
    required this.label,
    required this.hint,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          minLines: 1,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: hint,
            isDense: true,
            border: const OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}
