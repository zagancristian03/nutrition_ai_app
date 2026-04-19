import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/ai_provider.dart';
import '../../services/ai_api_service.dart';
import 'ai_onboarding_screen.dart';

/// Chat with the coach. Gated on `onboardingCompleted`:
///   * If onboarding isn't done, shows a CTA that opens [AiOnboardingScreen].
///   * Otherwise shows a regular chat UI with quick-action chips + composer.
class AiCoachScreen extends StatefulWidget {
  const AiCoachScreen({super.key});

  @override
  State<AiCoachScreen> createState() => _AiCoachScreenState();
}

class _AiCoachScreenState extends State<AiCoachScreen> {
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollCtrl.hasClients) return;
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send([String? preset]) async {
    final text = (preset ?? _inputCtrl.text).trim();
    if (text.isEmpty) return;
    _inputCtrl.clear();
    await context.read<AiProvider>().sendMessage(text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final ai = context.watch<AiProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Coach'),
        actions: [
          if (ai.onboardingDone)
            IconButton(
              tooltip: 'Edit onboarding',
              icon: const Icon(Icons.tune),
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AiOnboardingScreen()),
                );
              },
            ),
          if (ai.onboardingDone)
            IconButton(
              tooltip: 'New conversation',
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<AiProvider>().startNewThread();
              },
            ),
        ],
      ),
      body: _buildBody(context, ai),
    );
  }

  Widget _buildBody(BuildContext context, AiProvider ai) {
    if (ai.profileLoading && ai.profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!ai.onboardingDone) {
      return _OnboardingCta(
        onStart: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AiOnboardingScreen()),
          );
        },
      );
    }

    return Column(
      children: [
        if (ai.lastError != null)
          _ErrorBanner(
            message: ai.lastError!,
            onDismiss: () => context.read<AiProvider>().clearError(),
          ),
        Expanded(
          child: ai.historyLoading && ai.messages.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : _MessagesList(
                  scrollCtrl: _scrollCtrl,
                  messages: ai.messages,
                  sending: ai.sending,
                ),
        ),
        if (ai.messages.isEmpty && !ai.sending)
          _QuickActions(onTap: _send),
        _Composer(
          controller: _inputCtrl,
          enabled: !ai.sending,
          onSend: () => _send(),
        ),
      ],
    );
  }
}


// --------------------------------------------------------------------------- //
// Onboarding CTA                                                              //
// --------------------------------------------------------------------------- //

class _OnboardingCta extends StatelessWidget {
  final VoidCallback onStart;
  const _OnboardingCta({required this.onStart});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome, size: 56, color: cs.primary),
          const SizedBox(height: 16),
          Text(
            'Meet your nutrition coach',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Answer a few quick questions so the coach can tailor advice to '
            'your goal, food preferences, and habits.',
            style: TextStyle(color: cs.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              onPressed: onStart,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Start onboarding'),
            ),
          ),
        ],
      ),
    );
  }
}


// --------------------------------------------------------------------------- //
// Messages list                                                               //
// --------------------------------------------------------------------------- //

class _MessagesList extends StatelessWidget {
  final ScrollController scrollCtrl;
  final List<AiChatMessage> messages;
  final bool sending;

  const _MessagesList({
    required this.scrollCtrl,
    required this.messages,
    required this.sending,
  });

  @override
  Widget build(BuildContext context) {
    final itemCount = messages.length + (sending ? 1 : 0);

    return ListView.builder(
      controller: scrollCtrl,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      itemCount: itemCount,
      itemBuilder: (context, i) {
        if (sending && i == messages.length) {
          return const _TypingBubble();
        }
        final m = messages[i];
        return _MessageBubble(message: m);
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final AiChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isUser = message.isUser;

    final bg = isUser ? cs.primary : cs.surfaceContainerHighest;
    final fg = isUser ? cs.onPrimary : cs.onSurface;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.only(
            topLeft:     const Radius.circular(16),
            topRight:    const Radius.circular(16),
            bottomLeft:  Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
        ),
        child: SelectableText(
          message.content,
          style: TextStyle(color: fg, height: 1.35, fontSize: 14.5),
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: const BorderRadius.only(
            topLeft:     Radius.circular(16),
            topRight:    Radius.circular(16),
            bottomLeft:  Radius.circular(4),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: SizedBox(
          width: 32, height: 14,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(3, (i) => _Dot(delayMs: i * 150)),
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  final int delayMs;
  const _Dot({required this.delayMs});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return FadeTransition(
      opacity: Tween(begin: 0.25, end: 1.0).animate(_ctrl),
      child: Container(
        width: 8, height: 8,
        decoration: BoxDecoration(
          color: cs.onSurfaceVariant, shape: BoxShape.circle,
        ),
      ),
    );
  }
}


// --------------------------------------------------------------------------- //
// Quick actions                                                               //
// --------------------------------------------------------------------------- //

class _QuickActions extends StatelessWidget {
  final void Function(String preset) onTap;
  const _QuickActions({required this.onTap});

  static const _prompts = [
    ('How is my day going so far?',    'How is today going for my goal?'),
    ('Suggest something to eat',       "What should I eat next to stay on track?"),
    ('Review my week',                 'Give me a quick review of my last 7 days.'),
    ("I'm craving something sweet",    "I'm craving something sweet — what's a smart option?"),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _prompts.map((p) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ActionChip(
                avatar: const Icon(Icons.auto_awesome, size: 16),
                label: Text(p.$1),
                onPressed: () => onTap(p.$2),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}


// --------------------------------------------------------------------------- //
// Composer                                                                    //
// --------------------------------------------------------------------------- //

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool enabled;

  const _Composer({
    required this.controller,
    required this.onSend,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: cs.outlineVariant)),
        ),
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: enabled,
                minLines: 1,
                maxLines: 5,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: 'Ask your coach…',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: cs.surfaceContainerHighest,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            IconButton.filled(
              onPressed: enabled ? onSend : null,
              icon: const Icon(Icons.send_rounded),
            ),
          ],
        ),
      ),
    );
  }
}


// --------------------------------------------------------------------------- //
// Error banner                                                                //
// --------------------------------------------------------------------------- //

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;

  const _ErrorBanner({required this.message, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      color: cs.errorContainer,
      padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: cs.onErrorContainer, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: cs.onErrorContainer, fontSize: 13),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: cs.onErrorContainer),
            onPressed: onDismiss,
          ),
        ],
      ),
    );
  }
}
