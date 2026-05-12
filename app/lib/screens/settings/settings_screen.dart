import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../providers/locale_controller.dart';
import '../../models/user_profile.dart';
import '../../providers/preferences_provider.dart';
import '../../providers/theme_mode_provider.dart';
import '../../services/auth_service.dart';
import '../../services/profile_api_service.dart';
import '../goals/edit_goals_screen.dart';
import '../profile/edit_profile_screen.dart';

/// Hub for the everyday settings a casual user expects:
/// theme, profile, goals, account actions, and about info.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final user = FirebaseAuth.instance.currentUser;
    final prefs = context.watch<PreferencesProvider>();
    final loc = AppLocalizations.of(context)!;
    final localeCtrl = context.watch<LocaleController>();

    return Scaffold(
      appBar: AppBar(title: Text(loc.settingsScreenTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          _SectionLabel(loc.settingsSectionAppearance),
          _AppearanceCard(loc: loc),
          const SizedBox(height: 18),

          _SectionLabel(loc.settingsSectionLanguage),
          _LanguageCard(
            loc: loc,
            localeCtrl: localeCtrl,
            userId: user?.uid,
          ),
          const SizedBox(height: 18),

          _SectionLabel(loc.settingsSectionProfileGoals),
          _Tile(
            icon: Icons.person_outline,
            title: loc.settingsEditProfileTitle,
            subtitle: loc.settingsEditProfileSubtitle,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
            ),
          ),
          _Tile(
            icon: Icons.flag_outlined,
            title: loc.settingsDailyTargetsTitle,
            subtitle: loc.settingsDailyTargetsSubtitle,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const EditGoalsScreen()),
            ),
          ),
          const SizedBox(height: 18),

          _SectionLabel(loc.settingsSectionPreferences),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: cs.outlineVariant),
            ),
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: cs.primary.withValues(alpha: 0.12),
                        child: Icon(Icons.straighten, color: cs.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(loc.settingsWeightUnitTitle,
                                style: const TextStyle(fontWeight: FontWeight.w600)),
                            Text(
                              loc.settingsWeightUnitSubtitle,
                              style: TextStyle(color: cs.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SegmentedButton<String>(
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment<String>(value: 'kg', label: Text(loc.settingsWeightUnitKg)),
                      ButtonSegment<String>(value: 'lb', label: Text(loc.settingsWeightUnitLb)),
                    ],
                    selected: {prefs.weightUnit},
                    onSelectionChanged: (s) =>
                        context.read<PreferencesProvider>().setWeightUnit(s.first),
                  ),
                ],
              ),
            ),
          ),
          _SwitchTile(
            icon: Icons.auto_awesome,
            title: loc.settingsCoachTipsTitle,
            subtitle: loc.settingsCoachTipsSubtitle,
            value: prefs.showCoachTips,
            onChanged: (v) =>
                context.read<PreferencesProvider>().setShowCoachTips(v),
          ),
          _SwitchTile(
            icon: Icons.delete_sweep_outlined,
            title: loc.settingsConfirmDeleteTitle,
            subtitle: loc.settingsConfirmDeleteSubtitle,
            value: prefs.confirmDelete,
            onChanged: (v) =>
                context.read<PreferencesProvider>().setConfirmDelete(v),
          ),
          _SwitchTile(
            icon: Icons.vibration,
            title: loc.settingsHapticsTitle,
            subtitle: loc.settingsHapticsSubtitle,
            value: prefs.haptics,
            onChanged: (v) {
              context.read<PreferencesProvider>().setHaptics(v);
              if (v) HapticFeedback.lightImpact();
            },
          ),
          const SizedBox(height: 18),

          _SectionLabel(loc.settingsSectionAccount),
          _Tile(
            icon: Icons.email_outlined,
            title: loc.settingsEmailTitle,
            subtitle: user?.email ?? loc.settingsEmailNotSignedIn,
          ),
          _Tile(
            icon: Icons.lock_reset,
            title: loc.settingsChangePasswordTitle,
            subtitle: user?.email == null
                ? loc.settingsChangePasswordSubtitleSignIn
                : loc.settingsChangePasswordSubtitle,
            onTap: user?.email == null
                ? null
                : () async {
                    final messenger = ScaffoldMessenger.of(context);
                    try {
                      await FirebaseAuth.instance
                          .sendPasswordResetEmail(email: user!.email!);
                      messenger.showSnackBar(
                        SnackBar(content: Text(loc.settingsSnackResetEmailSent)),
                      );
                    } catch (e) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            loc.settingsSnackResetFailed(e.toString()),
                          ),
                        ),
                      );
                    }
                  },
          ),
          _Tile(
            icon: Icons.logout,
            title: loc.settingsSignOutTitle,
            subtitle: loc.settingsSignOutSubtitle,
            iconColor: cs.error,
            onTap: () async {
              final navigator = Navigator.of(context, rootNavigator: true);
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(loc.authSignOutConfirmTitle),
                  content: Text(loc.authSignOutConfirmBody),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: Text(loc.commonCancel),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: cs.error,
                        foregroundColor: cs.onError,
                      ),
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: Text(loc.commonSignOut),
                    ),
                  ],
                ),
              );
              if (ok != true) return;
              await AuthService().logout();
              if (navigator.mounted) {
                navigator.popUntil((route) => route.isFirst);
              }
            },
          ),
          const SizedBox(height: 18),

          _SectionLabel(loc.settingsSectionHelp),
          _Tile(
            icon: Icons.help_outline,
            title: loc.settingsFeedbackTitle,
            subtitle: loc.settingsFeedbackSubtitle,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(loc.settingsFeedbackSnack)),
              );
            },
          ),
          _Tile(
            icon: Icons.star_outline,
            title: loc.settingsRateTitle,
            subtitle: loc.settingsRateSubtitle,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(loc.settingsRateSnack)),
              );
            },
          ),
          const SizedBox(height: 18),

          _SectionLabel(loc.settingsSectionAbout),
          _Tile(
            icon: Icons.info_outline,
            title: loc.settingsAboutAppTitle,
            subtitle: loc.settingsAboutVersionSubtitle,
          ),
          _Tile(
            icon: Icons.policy_outlined,
            title: loc.settingsPrivacyTitle,
            subtitle: loc.settingsPrivacySubtitle,
          ),
        ],
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.outlineVariant),
      ),
      margin: const EdgeInsets.only(bottom: 8),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        secondary: CircleAvatar(
          backgroundColor: cs.primary.withValues(alpha: 0.12),
          child: Icon(icon, color: cs.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: cs.onSurfaceVariant),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 0, 8),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({
    required this.loc,
    required this.localeCtrl,
    required this.userId,
  });

  final AppLocalizations loc;
  final LocaleController localeCtrl;
  final String? userId;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final api = ProfileApiService();

    Future<void> pick(Future<void> Function() apply) async {
      await apply();
      if (!context.mounted) return;
      await context.read<LocaleController>().commitLanguageSelection(api, userId);
    }

    void onLanguageChanged(int? v) {
      if (v == null) return;
      if (v == 0) {
        pick(() => localeCtrl.setSystemDefault());
        return;
      }
      final idx = v - 1;
      if (idx >= 0 && idx < kSupportedManualLanguageTags.length) {
        pick(() => localeCtrl.setManualLanguage(kSupportedManualLanguageTags[idx]));
      }
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.settingsLanguageTitle,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              loc.settingsLanguageSubtitle,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            RadioGroup<int>(
              groupValue: _languageGroupValue(localeCtrl),
              onChanged: onLanguageChanged,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RadioListTile<int>(
                    value: 0,
                    title: Text(loc.settingsLanguageSystemDefault),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  for (var i = 0; i < kSupportedManualLanguageTags.length; i++)
                    RadioListTile<int>(
                      value: i + 1,
                      title: Text(_manualLabel(loc, kSupportedManualLanguageTags[i])),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _manualLabel(AppLocalizations loc, String tag) {
    switch (tag) {
      case 'ro':
        return loc.settingsLanguageRomanian;
      case 'en':
      default:
        return loc.settingsLanguageEnglish;
    }
  }

  static int _languageGroupValue(LocaleController lc) {
    if (lc.mode == UserLocaleMode.system) return 0;
    final i = kSupportedManualLanguageTags.indexOf(
      (lc.preferredLocaleWire ?? '').trim(),
    );
    if (i < 0) return 1;
    return i + 1;
  }
}

class _AppearanceCard extends StatelessWidget {
  const _AppearanceCard({required this.loc});

  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeModeProvider>();
    final cs = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.settingsThemeTitle,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              loc.settingsThemeSubtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 12),
            SegmentedButton<ThemeMode>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.light,
                  icon: const Icon(Icons.light_mode_outlined, size: 18),
                  label: Text(loc.settingsThemeLight),
                ),
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.dark,
                  icon: const Icon(Icons.dark_mode_outlined, size: 18),
                  label: Text(loc.settingsThemeDark),
                ),
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.system,
                  icon: const Icon(Icons.brightness_auto_outlined, size: 18),
                  label: Text(loc.settingsThemeSystem),
                ),
              ],
              selected: {themeProv.themeMode},
              onSelectionChanged: (Set<ThemeMode> next) {
                context.read<ThemeModeProvider>().setThemeMode(next.first);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = iconColor ?? cs.primary;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.outlineVariant),
      ),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: cs.onSurfaceVariant),
        ),
        trailing: onTap != null
            ? Icon(Icons.chevron_right, color: cs.outline)
            : null,
      ),
    );
  }
}
