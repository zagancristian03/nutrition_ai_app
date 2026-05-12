import 'package:app/l10n/app_localizations.dart';

/// Value sent to the backend; [label] is localized for the chip.
class AiOnboardingChip {
  final String value;
  final String label;
  const AiOnboardingChip(this.value, this.label);
}

List<AiOnboardingChip> aiOnboardingMainGoals(AppLocalizations l) => [
      AiOnboardingChip('lose_weight', l.aiOnboardingGoalLoseWeight),
      AiOnboardingChip('gain_muscle', l.aiOnboardingGoalGainMuscle),
      AiOnboardingChip('maintain', l.aiOnboardingGoalMaintain),
      AiOnboardingChip('eat_healthier', l.aiOnboardingGoalEatHealthier),
      AiOnboardingChip('improve_energy', l.aiOnboardingGoalImproveEnergy),
      AiOnboardingChip('improve_performance', l.aiOnboardingGoalImprovePerformance),
      AiOnboardingChip('improve_consistency', l.aiOnboardingGoalImproveConsistency),
    ];

List<AiOnboardingChip> aiOnboardingApproach(AppLocalizations l) => [
      AiOnboardingChip('aggressive', l.aiOnboardingApproachAggressive),
      AiOnboardingChip('balanced', l.aiOnboardingApproachBalanced),
      AiOnboardingChip('flexible', l.aiOnboardingApproachFlexible),
      AiOnboardingChip('sustainable', l.aiOnboardingApproachSustainable),
    ];

List<AiOnboardingChip> aiOnboardingTrainingSessions(AppLocalizations l) => [
      const AiOnboardingChip('0', '0'),
      const AiOnboardingChip('1', '1'),
      const AiOnboardingChip('2', '2'),
      const AiOnboardingChip('3', '3'),
      const AiOnboardingChip('4', '4'),
      const AiOnboardingChip('5', '5'),
      const AiOnboardingChip('6', '6'),
      AiOnboardingChip('7', l.aiOnboardingTrainingSessions7Plus),
    ];

List<AiOnboardingChip> aiOnboardingTrainingTypes(AppLocalizations l) => [
      AiOnboardingChip('lifting', l.aiOnboardingTrainingLifting),
      AiOnboardingChip('cardio', l.aiOnboardingTrainingCardio),
      AiOnboardingChip('hiit', l.aiOnboardingTrainingHiit),
      AiOnboardingChip('sports', l.aiOnboardingTrainingSports),
      AiOnboardingChip('running', l.aiOnboardingTrainingRunning),
      AiOnboardingChip('cycling', l.aiOnboardingTrainingCycling),
      AiOnboardingChip('swimming', l.aiOnboardingTrainingSwimming),
      AiOnboardingChip('yoga_flexibility', l.aiOnboardingTrainingYoga),
      AiOnboardingChip('walking', l.aiOnboardingTrainingWalking),
      AiOnboardingChip('none', l.aiOnboardingTrainingNone),
    ];

List<AiOnboardingChip> aiOnboardingIntensity(AppLocalizations l) => [
      AiOnboardingChip('light', l.aiOnboardingIntensityLight),
      AiOnboardingChip('moderate', l.aiOnboardingIntensityModerate),
      AiOnboardingChip('hard', l.aiOnboardingIntensityHard),
      AiOnboardingChip('very_hard', l.aiOnboardingIntensityVeryHard),
    ];

List<AiOnboardingChip> aiOnboardingJobActivity(AppLocalizations l) => [
      AiOnboardingChip('desk', l.aiOnboardingJobDesk),
      AiOnboardingChip('mostly_seated', l.aiOnboardingJobMostlySeated),
      AiOnboardingChip('on_feet', l.aiOnboardingJobOnFeet),
      AiOnboardingChip('physical_labor', l.aiOnboardingJobPhysicalLabor),
    ];

List<AiOnboardingChip> aiOnboardingSteps(AppLocalizations l) => [
      AiOnboardingChip('under_5k', l.aiOnboardingStepsUnder5k),
      AiOnboardingChip('5k_7k', l.aiOnboardingSteps5k7k),
      AiOnboardingChip('7k_10k', l.aiOnboardingSteps7k10k),
      AiOnboardingChip('10k_15k', l.aiOnboardingSteps10k15k),
      AiOnboardingChip('over_15k', l.aiOnboardingStepsOver15k),
    ];

List<AiOnboardingChip> aiOnboardingDietPattern(AppLocalizations l) => [
      AiOnboardingChip('omnivore', l.aiOnboardingDietOmnivore),
      AiOnboardingChip('vegetarian', l.aiOnboardingDietVegetarian),
      AiOnboardingChip('vegan', l.aiOnboardingDietVegan),
      AiOnboardingChip('pescatarian', l.aiOnboardingDietPescatarian),
      AiOnboardingChip('other', l.aiOnboardingDietOther),
    ];

List<AiOnboardingChip> aiOnboardingEatingOut(AppLocalizations l) => [
      AiOnboardingChip('rarely', l.aiOnboardingEatingOutRarely),
      AiOnboardingChip('weekly', l.aiOnboardingEatingOutWeekly),
      AiOnboardingChip('often', l.aiOnboardingEatingOutOften),
      AiOnboardingChip('daily', l.aiOnboardingEatingOutDaily),
    ];

List<AiOnboardingChip> aiOnboardingCooking(AppLocalizations l) => [
      AiOnboardingChip('none', l.aiOnboardingCookingNone),
      AiOnboardingChip('simple', l.aiOnboardingCookingSimple),
      AiOnboardingChip('enjoys', l.aiOnboardingCookingEnjoys),
    ];

List<AiOnboardingChip> aiOnboardingBudget(AppLocalizations l) => [
      AiOnboardingChip('low', l.aiOnboardingBudgetLow),
      AiOnboardingChip('medium', l.aiOnboardingBudgetMedium),
      AiOnboardingChip('high', l.aiOnboardingBudgetHigh),
    ];

List<AiOnboardingChip> aiOnboardingMealsPerDay(AppLocalizations l) => [
      const AiOnboardingChip('2', '2'),
      const AiOnboardingChip('3', '3'),
      const AiOnboardingChip('4', '4'),
      const AiOnboardingChip('5', '5'),
      const AiOnboardingChip('6', '6'),
    ];

List<AiOnboardingChip> aiOnboardingSleep(AppLocalizations l) => [
      AiOnboardingChip('under_5', l.aiOnboardingSleepUnder5),
      AiOnboardingChip('5_6', l.aiOnboardingSleep5to6),
      AiOnboardingChip('6_7', l.aiOnboardingSleep6to7),
      AiOnboardingChip('7_8', l.aiOnboardingSleep7to8),
      AiOnboardingChip('over_8', l.aiOnboardingSleepOver8),
    ];

List<AiOnboardingChip> aiOnboardingStress(AppLocalizations l) => [
      AiOnboardingChip('low', l.aiOnboardingStressLow),
      AiOnboardingChip('medium', l.aiOnboardingStressMedium),
      AiOnboardingChip('high', l.aiOnboardingStressHigh),
    ];

List<AiOnboardingChip> aiOnboardingWater(AppLocalizations l) => [
      AiOnboardingChip('low', l.aiOnboardingWaterLow),
      AiOnboardingChip('medium', l.aiOnboardingWaterMedium),
      AiOnboardingChip('high', l.aiOnboardingWaterHigh),
    ];

List<AiOnboardingChip> aiOnboardingAlcohol(AppLocalizations l) => [
      AiOnboardingChip('none', l.aiOnboardingAlcoholNone),
      AiOnboardingChip('occasional', l.aiOnboardingAlcoholOccasional),
      AiOnboardingChip('weekly', l.aiOnboardingAlcoholWeekly),
      AiOnboardingChip('frequent', l.aiOnboardingAlcoholFrequent),
    ];

List<AiOnboardingChip> aiOnboardingStruggles(AppLocalizations l) => [
      AiOnboardingChip('cravings', l.aiOnboardingStruggleCravings),
      AiOnboardingChip('consistency', l.aiOnboardingStruggleConsistency),
      AiOnboardingChip('late_night', l.aiOnboardingStruggleLateNight),
      AiOnboardingChip('emotional', l.aiOnboardingStruggleEmotional),
      AiOnboardingChip('boredom', l.aiOnboardingStruggleBoredom),
      AiOnboardingChip('time', l.aiOnboardingStruggleTime),
      AiOnboardingChip('social', l.aiOnboardingStruggleSocial),
      AiOnboardingChip('travel', l.aiOnboardingStruggleTravel),
      AiOnboardingChip('portion_size', l.aiOnboardingStrugglePortions),
      AiOnboardingChip('planning', l.aiOnboardingStrugglePlanning),
    ];

List<AiOnboardingChip> aiOnboardingStruggleTiming(AppLocalizations l) => [
      AiOnboardingChip('morning', l.aiOnboardingTimingMorning),
      AiOnboardingChip('afternoon', l.aiOnboardingTimingAfternoon),
      AiOnboardingChip('evening', l.aiOnboardingTimingEvening),
      AiOnboardingChip('night', l.aiOnboardingTimingNight),
      AiOnboardingChip('weekends', l.aiOnboardingTimingWeekends),
      AiOnboardingChip('stress', l.aiOnboardingTimingStress),
    ];

List<AiOnboardingChip> aiOnboardingMotivation(AppLocalizations l) => [
      AiOnboardingChip('low', l.aiOnboardingMotivationLow),
      AiOnboardingChip('medium', l.aiOnboardingMotivationMedium),
      AiOnboardingChip('high', l.aiOnboardingMotivationHigh),
    ];

List<AiOnboardingChip> aiOnboardingStructure(AppLocalizations l) => [
      AiOnboardingChip('low', l.aiOnboardingStructureLow),
      AiOnboardingChip('medium', l.aiOnboardingStructureMedium),
      AiOnboardingChip('high', l.aiOnboardingStructureHigh),
    ];

List<AiOnboardingChip> aiOnboardingCoachTone(AppLocalizations l) => [
      AiOnboardingChip('direct', l.aiOnboardingToneDirect),
      AiOnboardingChip('balanced', l.aiOnboardingToneBalanced),
      AiOnboardingChip('gentler', l.aiOnboardingToneGentler),
    ];
