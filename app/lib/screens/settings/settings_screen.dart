import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/preferences_provider.dart';
import '../../providers/theme_mode_provider.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
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

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          _SectionLabel('Appearance'),
          const _AppearanceCard(),
          const SizedBox(height: 18),

          _SectionLabel('Profile & goals'),
          _Tile(
            icon: Icons.person_outline,
            title: 'Edit profile',
            subtitle: 'Body stats, goal, activity level',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
            ),
          ),
          _Tile(
            icon: Icons.flag_outlined,
            title: 'Daily targets',
            subtitle: 'Calorie + macro goals',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const EditGoalsScreen()),
            ),
          ),
          const SizedBox(height: 18),

          _SectionLabel('Preferences'),
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
                            const Text('Weight unit',
                                style: TextStyle(fontWeight: FontWeight.w600)),
                            Text(
                              'Used on the Progress and weight log screens',
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
                    segments: const [
                      ButtonSegment<String>(value: 'kg', label: Text('Kilograms (kg)')),
                      ButtonSegment<String>(value: 'lb', label: Text('Pounds (lb)')),
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
            title: 'Show coach tips',
            subtitle: 'Friendly insights on Dashboard and Diary',
            value: prefs.showCoachTips,
            onChanged: (v) =>
                context.read<PreferencesProvider>().setShowCoachTips(v),
          ),
          _SwitchTile(
            icon: Icons.delete_sweep_outlined,
            title: 'Confirm before deleting',
            subtitle: 'Ask before removing a logged food',
            value: prefs.confirmDelete,
            onChanged: (v) =>
                context.read<PreferencesProvider>().setConfirmDelete(v),
          ),
          _SwitchTile(
            icon: Icons.vibration,
            title: 'Haptic feedback',
            subtitle: 'Subtle vibration on actions',
            value: prefs.haptics,
            onChanged: (v) {
              context.read<PreferencesProvider>().setHaptics(v);
              if (v) HapticFeedback.lightImpact();
            },
          ),
          const SizedBox(height: 18),

          _SectionLabel('Account'),
          _Tile(
            icon: Icons.email_outlined,
            title: 'Email',
            subtitle: user?.email ?? 'Not signed in',
          ),
          _Tile(
            icon: Icons.lock_reset,
            title: 'Change password',
            subtitle: user?.email == null
                ? 'Sign in first'
                : 'Send a reset link to your email',
            onTap: user?.email == null
                ? null
                : () async {
                    final messenger = ScaffoldMessenger.of(context);
                    try {
                      await FirebaseAuth.instance
                          .sendPasswordResetEmail(email: user!.email!);
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Reset email sent')),
                      );
                    } catch (e) {
                      messenger.showSnackBar(
                        SnackBar(content: Text('Failed to send: $e')),
                      );
                    }
                  },
          ),
          _Tile(
            icon: Icons.logout,
            title: 'Sign out',
            subtitle: 'Return to the login screen',
            iconColor: cs.error,
            onTap: () async {
              final navigator = Navigator.of(context);
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Sign out?'),
                  content: const Text('You can sign back in any time.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: cs.error,
                        foregroundColor: cs.onError,
                      ),
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('Sign out'),
                    ),
                  ],
                ),
              );
              if (ok != true) return;
              await AuthService().logout();
              navigator.pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (_) => false,
              );
            },
          ),
          const SizedBox(height: 18),

          _SectionLabel('Help'),
          _Tile(
            icon: Icons.help_outline,
            title: 'Send feedback',
            subtitle: 'Tell us what you’d like to see next',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Thanks! Email feedback coming soon.')),
              );
            },
          ),
          _Tile(
            icon: Icons.star_outline,
            title: 'Rate this app',
            subtitle: 'A quick rating helps a lot',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Thanks for your support!')),
              );
            },
          ),
          const SizedBox(height: 18),

          _SectionLabel('About'),
          _Tile(
            icon: Icons.info_outline,
            title: 'Nutrition AI',
            subtitle: 'Version 1.0.0',
          ),
          _Tile(
            icon: Icons.policy_outlined,
            title: 'Privacy',
            subtitle: 'Your foods, goals and weights are stored securely.',
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

class _AppearanceCard extends StatelessWidget {
  const _AppearanceCard();

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
              'Theme',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Light, dark, or match your device',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 12),
            SegmentedButton<ThemeMode>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.light,
                  icon: Icon(Icons.light_mode_outlined, size: 18),
                  label: Text('Light'),
                ),
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.dark,
                  icon: Icon(Icons.dark_mode_outlined, size: 18),
                  label: Text('Dark'),
                ),
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.system,
                  icon: Icon(Icons.brightness_auto_outlined, size: 18),
                  label: Text('System'),
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
