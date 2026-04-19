import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/theme_mode_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../services/auth_service.dart';
import '../ai/ai_coach_screen.dart';
import '../goals/edit_goals_screen.dart';
import '../profile/edit_profile_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user    = FirebaseAuth.instance.currentUser;
    final email   = user?.email ?? 'No email';
    final profile = context.watch<UserProfileProvider>().profile;

    final name = (profile?.displayName?.trim().isNotEmpty ?? false)
        ? profile!.displayName!.trim()
        : (user?.displayName?.trim().isNotEmpty ?? false)
            ? user!.displayName!.trim()
            : _emailHandle(email);

    return Scaffold(
      appBar: AppBar(
        title: const Text('More'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          _ProfileHeader(name: name, email: email, profileSummary: _summary(profile)),
          const SizedBox(height: 16),

          const _AppearanceCard(),
          const SizedBox(height: 8),

          _ActionTile(
            icon: Icons.auto_awesome,
            title: 'AI Coach',
            subtitle: 'Chat, meal ideas, daily & weekly reviews',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AiCoachScreen()),
            ),
          ),
          _ActionTile(
            icon: Icons.person_outline,
            title: 'Edit profile',
            subtitle: 'Body stats, goal, activity level',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
            ),
          ),
          _ActionTile(
            icon: Icons.flag_outlined,
            title: 'Daily targets',
            subtitle: 'Calorie + macro goals',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const EditGoalsScreen()),
            ),
          ),

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                await AuthService().logout();
              },
              icon: Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
              label: Text(
                'Log out',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _emailHandle(String email) {
    final at = email.indexOf('@');
    return at > 0 ? email.substring(0, at) : email;
  }

  static String? _summary(dynamic profile) {
    if (profile == null) return null;
    final parts = <String>[];
    if (profile.sex != null) parts.add(profile.sex!.label as String);
    if (profile.ageYears != null) parts.add('${profile.ageYears} yr');
    if (profile.currentWeightKg != null) {
      parts.add('${profile.currentWeightKg!.toStringAsFixed(1)} kg');
    }
    if (profile.heightCm != null) parts.add('${profile.heightCm!.round()} cm');
    return parts.isEmpty ? null : parts.join(' · ');
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
              'Appearance',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
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

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String? profileSummary;
  const _ProfileHeader({
    required this.name,
    required this.email,
    required this.profileSummary,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.primary.withValues(alpha: 0.4)),
      ),
      color: cs.primary.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: cs.primary.withValues(alpha: 0.2),
              child: Icon(Icons.person, size: 34, color: cs.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          )),
                  const SizedBox(height: 2),
                  Text(email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
                  if (profileSummary != null) ...[
                    const SizedBox(height: 6),
                    Text(profileSummary!,
                        style: TextStyle(
                            color: cs.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.outlineVariant),
      ),
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: cs.primary.withValues(alpha: 0.12),
          child: Icon(icon, color: cs.primary),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.chevron_right, color: cs.outline),
      ),
    );
  }
}
