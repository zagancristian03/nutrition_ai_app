import 'package:flutter/material.dart';
import 'package:app/l10n/ai_onboarding_options.dart';
import 'package:app/l10n/app_localizations.dart';
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
    final loc = AppLocalizations.of(context)!;
    if (markCompleted && !_requiredFilled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.aiOnboardingSnackRequiredFields)),
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
        SnackBar(content: Text(loc.aiOnboardingSnackSaveFailed)),
      );
      return;
    }

    if (markCompleted) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.aiOnboardingSnackDraftSaved)),
      );
    }
  }

  // ----------------------------------------------------------------------- //
  // Build                                                                   //
  // ----------------------------------------------------------------------- //

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.aiOnboardingAppBarTitle),
        actions: [
          TextButton(
            onPressed: _saving ? null : () => _save(markCompleted: false),
            child: Text(loc.aiOnboardingSaveDraft),
          ),
        ],
      ),
      body: AbsorbPointer(
        absorbing: _saving,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
          children: [
            Text(
              loc.aiOnboardingIntro,
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 16),

            // ---------------------------------------------------- GOALS
            _Section(
              title: loc.aiOnboardingSectionGoalsTitle,
              subtitle: loc.aiOnboardingSectionGoalsSubtitle,
            ),
            _MultiChipGroup(
              values: _mainGoals,
              options: aiOnboardingMainGoals(loc),
              onChanged: () => setState(() {}),
            ),
            const SizedBox(height: 8),
            _NoteField(
              label: loc.aiOnboardingNoteMainGoalLabel,
              hint: loc.aiOnboardingNoteMainGoalHint,
              controller: _mainGoalNoteCtrl,
            ),

            const _Spacer(),
            _Section(title: loc.aiOnboardingSectionApproachTitle),
            _SingleChipGroup(
              value: _approachStyle,
              options: aiOnboardingApproach(loc),
              onChanged: (v) => setState(() => _approachStyle = v),
            ),

            // ------------------------------------------------- TRAINING
            const _Spacer(),
            _Section(
              title: loc.aiOnboardingSectionTrainingTitle,
              subtitle: loc.aiOnboardingSectionTrainingSubtitle,
            ),
            _SingleChipGroup(
              label: loc.aiOnboardingLabelTrainingSessionsPerWeek,
              value: _trainingFrequencyPerWeek?.toString(),
              options: aiOnboardingTrainingSessions(loc),
              onChanged: (v) => setState(
                () => _trainingFrequencyPerWeek =
                    v == null ? null : int.tryParse(v),
              ),
            ),
            const SizedBox(height: 10),
            _MultiChipGroup(
              label: loc.aiOnboardingLabelTrainingTypes,
              values: _trainingTypes,
              options: aiOnboardingTrainingTypes(loc),
              onChanged: () => setState(() {}),
            ),
            const SizedBox(height: 10),
            _SingleChipGroup(
              label: loc.aiOnboardingLabelSessionIntensity,
              value: _trainingIntensity,
              options: aiOnboardingIntensity(loc),
              onChanged: (v) => setState(() => _trainingIntensity = v),
            ),
            const SizedBox(height: 10),
            _SingleChipGroup(
              label: loc.aiOnboardingLabelJobActivity,
              value: _jobActivity,
              options: aiOnboardingJobActivity(loc),
              onChanged: (v) => setState(() => _jobActivity = v),
            ),
            const SizedBox(height: 10),
            _SingleChipGroup(
              label: loc.aiOnboardingLabelDailySteps,
              value: _stepsPerDayBand,
              options: aiOnboardingSteps(loc),
              onChanged: (v) => setState(() => _stepsPerDayBand = v),
            ),
            const SizedBox(height: 8),
            _NoteField(
              label: loc.aiOnboardingNoteTrainingLabel,
              hint: loc.aiOnboardingNoteTrainingHint,
              controller: _trainingNotesCtrl,
            ),

            // -------------------------------------------------- DIET
            const _Spacer(),
            _Section(title: loc.aiOnboardingSectionDietTitle),
            _SingleChipGroup(
              value: _dietaryPattern,
              options: aiOnboardingDietPattern(loc),
              onChanged: (v) => setState(() => _dietaryPattern = v),
            ),
            const SizedBox(height: 8),
            _NoteField(
              label: loc.aiOnboardingNoteDietaryLabel,
              hint: loc.aiOnboardingNoteDietaryHint,
              controller: _dietaryPatternNoteCtrl,
            ),
            const SizedBox(height: 10),
            _NoteField(
              label: loc.aiOnboardingLabelAllergies,
              hint: loc.aiOnboardingHintAllergies,
              controller: _allergiesCtrl,
            ),
            const SizedBox(height: 10),
            _NoteField(
              label: loc.aiOnboardingLabelDisliked,
              hint: loc.aiOnboardingHintDisliked,
              controller: _dislikedCtrl,
            ),
            const SizedBox(height: 10),
            _NoteField(
              label: loc.aiOnboardingLabelFavorites,
              hint: loc.aiOnboardingHintFavorites,
              controller: _favoritesCtrl,
            ),
            const SizedBox(height: 10),
            _NoteField(
              label: loc.aiOnboardingLabelCuisines,
              hint: loc.aiOnboardingHintCuisines,
              controller: _cuisinesCtrl,
            ),
            const SizedBox(height: 10),
            _SingleChipGroup(
              label: loc.aiOnboardingLabelEatingOut,
              value: _eatingOutFrequency,
              options: aiOnboardingEatingOut(loc),
              onChanged: (v) => setState(() => _eatingOutFrequency = v),
            ),

            const _Spacer(),
            _Section(title: loc.aiOnboardingSectionCookingTitle),
            _SingleChipGroup(
              label: loc.aiOnboardingLabelCookingPreference,
              value: _cookingPreference,
              options: aiOnboardingCooking(loc),
              onChanged: (v) => setState(() => _cookingPreference = v),
            ),
            const SizedBox(height: 8),
            _SingleChipGroup(
              label: loc.aiOnboardingLabelBudget,
              value: _budgetSensitivity,
              options: aiOnboardingBudget(loc),
              onChanged: (v) => setState(() => _budgetSensitivity = v),
            ),
            const SizedBox(height: 8),
            _SingleChipGroup(
              label: loc.aiOnboardingLabelMealsPerDay,
              value: _mealFrequency?.toString(),
              options: aiOnboardingMealsPerDay(loc),
              onChanged: (v) => setState(
                () => _mealFrequency = v == null ? null : int.tryParse(v),
              ),
            ),

            // -------------------------------------------------- LIFESTYLE
            const _Spacer(),
            _Section(
              title: loc.aiOnboardingSectionLifestyleTitle,
              subtitle: loc.aiOnboardingSectionLifestyleSubtitle,
            ),
            _SingleChipGroup(
              label: loc.aiOnboardingLabelSleep,
              value: _sleepHoursBand,
              options: aiOnboardingSleep(loc),
              onChanged: (v) => setState(() => _sleepHoursBand = v),
            ),
            const SizedBox(height: 8),
            _SingleChipGroup(
              label: loc.aiOnboardingLabelStress,
              value: _stressLevel,
              options: aiOnboardingStress(loc),
              onChanged: (v) => setState(() => _stressLevel = v),
            ),
            const SizedBox(height: 8),
            _SingleChipGroup(
              label: loc.aiOnboardingLabelWater,
              value: _waterIntake,
              options: aiOnboardingWater(loc),
              onChanged: (v) => setState(() => _waterIntake = v),
            ),
            const SizedBox(height: 8),
            _SingleChipGroup(
              label: loc.aiOnboardingLabelAlcohol,
              value: _alcoholFrequency,
              options: aiOnboardingAlcohol(loc),
              onChanged: (v) => setState(() => _alcoholFrequency = v),
            ),

            // -------------------------------------------------- STRUGGLES
            const _Spacer(),
            _Section(title: loc.aiOnboardingSectionStrugglesTitle),
            _MultiChipGroup(
              label: loc.aiOnboardingLabelBiggestStruggles,
              values: _biggestStruggles,
              options: aiOnboardingStruggles(loc),
              onChanged: () => setState(() {}),
            ),
            const SizedBox(height: 8),
            _NoteField(
              label: loc.aiOnboardingNoteStruggleLabel,
              hint: loc.aiOnboardingNoteStruggleHint,
              controller: _biggestStruggleNoteCtrl,
            ),
            const SizedBox(height: 10),
            _SingleChipGroup(
              label: loc.aiOnboardingLabelStruggleWhen,
              value: _struggleTiming,
              options: aiOnboardingStruggleTiming(loc),
              onChanged: (v) => setState(() => _struggleTiming = v),
            ),

            const _Spacer(),
            _Section(title: loc.aiOnboardingSectionMotivationTitle),
            _SingleChipGroup(
              label: loc.aiOnboardingLabelMotivation,
              value: _motivationLevel,
              options: aiOnboardingMotivation(loc),
              onChanged: (v) => setState(() => _motivationLevel = v),
            ),
            const SizedBox(height: 8),
            _SingleChipGroup(
              label: loc.aiOnboardingLabelStructure,
              value: _structurePreference,
              options: aiOnboardingStructure(loc),
              onChanged: (v) => setState(() => _structurePreference = v),
            ),

            const _Spacer(),
            _Section(title: loc.aiOnboardingSectionCoachToneTitle),
            _SingleChipGroup(
              value: _coachTone,
              allowNull: false,
              options: aiOnboardingCoachTone(loc),
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
                    : Text(loc.aiOnboardingFinishButton),
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
  final List<AiOnboardingChip> options;
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
  final List<AiOnboardingChip> options;
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
