import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/ai_provider.dart';
import '../../services/ai_api_service.dart';
import 'ai_onboarding_screen.dart';

int _compareThreadsByRecent(AiChatThreadSummary a, AiChatThreadSummary b) {
  final ta = a.updatedAt;
  final tb = b.updatedAt;
  if (ta == null && tb == null) return b.id.compareTo(a.id);
  if (ta == null) return 1;
  if (tb == null) return -1;
  final c = tb.compareTo(ta);
  if (c != 0) return c;
  return b.id.compareTo(a.id);
}

List<AiChatThreadSummary> _inboxThreads(
  List<AiChatThreadSummary> all,
  Set<int> knownFolderIds,
) {
  final list = all.where((t) {
    final fid = t.folderId;
    if (fid == null) return true;
    return !knownFolderIds.contains(fid);
  }).toList();
  list.sort(_compareThreadsByRecent);
  return list;
}

List<AiChatThreadSummary> _threadsForFolder(
  List<AiChatThreadSummary> all,
  int folderId,
) {
  final list = all.where((t) => t.folderId == folderId).toList();
  list.sort(_compareThreadsByRecent);
  return list;
}

Future<void> _renameChatDialog(BuildContext context, AiChatThreadSummary thread) async {
  final ctrl = TextEditingController(text: thread.title ?? '');
  try {
    final save = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename chat'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLength: 120,
          decoration: const InputDecoration(
            labelText: 'Name',
            hintText: 'e.g. Meal planning',
          ),
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (save == true && context.mounted) {
      final ok = await context.read<AiProvider>().renameThread(thread.id, ctrl.text);
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not rename chat.')),
        );
      }
    }
  } finally {
    ctrl.dispose();
  }
}

Future<void> _newFolderDialog(BuildContext context) async {
  final ctrl = TextEditingController();
  try {
    final save = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New folder'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLength: 120,
          decoration: const InputDecoration(
            labelText: 'Folder name',
          ),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    if (save == true && context.mounted) {
      final ok = await context.read<AiProvider>().createFolder(ctrl.text);
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not create folder.')),
        );
      }
    }
  } finally {
    ctrl.dispose();
  }
}

Future<void> _renameFolderDialog(BuildContext context, AiChatFolder folder) async {
  final ctrl = TextEditingController(text: folder.name);
  try {
    final save = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename folder'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLength: 120,
          decoration: const InputDecoration(
            labelText: 'Name',
          ),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (save == true && context.mounted) {
      final ok = await context.read<AiProvider>().renameFolder(folder.id, ctrl.text);
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not rename folder.')),
        );
      }
    }
  } finally {
    ctrl.dispose();
  }
}

Future<void> _confirmDeleteFolder(BuildContext context, AiChatFolder folder) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Delete folder?'),
      content: Text(
        '“${folder.name}” will be removed. Chats inside move to Unfiled.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  if (ok == true && context.mounted) {
    final success = await context.read<AiProvider>().deleteFolder(folder.id);
    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not delete folder.')),
      );
    }
  }
}

void _showMoveChatSheet(BuildContext context, AiChatThreadSummary thread) {
  final ai = context.read<AiProvider>();
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                'Move “${thread.displayTitle}”',
                style: Theme.of(ctx).textTheme.titleSmall,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.inbox_outlined),
              title: const Text('Unfiled'),
              onTap: () async {
                Navigator.pop(ctx);
                final ok = await ai.moveThreadToFolder(thread.id, null);
                if (!ok && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Could not move chat. Check your connection and try again.'),
                    ),
                  );
                }
              },
            ),
            ...ai.folders.map(
              (f) => ListTile(
                leading: const Icon(Icons.folder_outlined),
                title: Text(f.name),
                onTap: () async {
                  Navigator.pop(ctx);
                  final ok = await ai.moveThreadToFolder(thread.id, f.id);
                  if (!ok && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Could not move chat. Check your connection and try again.'),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

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

  Future<void> _newChat({int? folderId}) async {
    await context.read<AiProvider>().createNewChat(folderId: folderId);
    if (!mounted) return;
    _scrollToBottom();
  }

  Future<void> _pickThread(int threadId) async {
    await context.read<AiProvider>().selectThread(threadId);
    if (!mounted) return;
    _scrollToBottom();
  }

  /// Close the drawer first, then run async work on the next frame so
  /// [ChangeNotifier] updates do not fire while drawer InheritedWidgets dismount
  /// (avoids `'_dependents.isEmpty': is not true`).
  void _closeDrawerThen(Future<void> Function() body) {
    Navigator.of(context).pop();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await body();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ai = context.watch<AiProvider>();

    return Scaffold(
      drawer: ai.onboardingDone
          ? _ChatsDrawer(
              ai: ai,
              onNewChat: ({int? folderId}) =>
                  _closeDrawerThen(() => _newChat(folderId: folderId)),
              onSelectThread: (id) => _closeDrawerThen(() => _pickThread(id)),
            )
          : null,
      appBar: AppBar(
        title: Text(ai.onboardingDone ? ai.activeThreadTitle : 'AI Coach'),
        actions: [
          if (ai.onboardingDone)
            IconButton(
              tooltip: 'New chat',
              icon: const Icon(Icons.add_comment_outlined),
              onPressed: () => _newChat(),
            ),
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
        if (ai.messages.isEmpty && !ai.sending && !ai.historyLoading)
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
// Chats drawer (thread list)                                                  //
// --------------------------------------------------------------------------- //

class _ChatsDrawer extends StatelessWidget {
  final AiProvider ai;
  final void Function({int? folderId}) onNewChat;
  final void Function(int threadId) onSelectThread;

  const _ChatsDrawer({
    required this.ai,
    required this.onNewChat,
    required this.onSelectThread,
  });

  static String _threadSubtitle(AiChatThreadSummary t) {
    final parts = <String>[];
    if (t.messageCount > 0) {
      parts.add(t.messageCount == 1 ? '1 message' : '${t.messageCount} messages');
    }
    final u = t.updatedAt;
    if (u != null) parts.add(_formatRelative(u));
    return parts.join(' · ');
  }

  static String _formatRelative(DateTime t) {
    final now = DateTime.now();
    final diff = now.difference(t);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${t.day}/${t.month}/${t.year}';
  }

  Widget _threadTile(
    BuildContext context,
    AiProvider ai,
    AiChatThreadSummary t,
  ) {
    final cs = Theme.of(context).colorScheme;
    final active = t.id == ai.threadId;
    final sub = _threadSubtitle(t);
    return ListTile(
      leading: Icon(
        active ? Icons.chat_bubble : Icons.chat_bubble_outline,
        color: active ? cs.primary : cs.onSurfaceVariant,
      ),
      title: Text(
        t.displayTitle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: active ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
      subtitle: sub.isEmpty
          ? null
          : Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: PopupMenuButton<String>(
        icon: Icon(Icons.more_vert, color: cs.onSurfaceVariant),
        onSelected: (value) async {
          switch (value) {
            case 'rename':
              await _renameChatDialog(context, t);
            case 'move':
              if (context.mounted) _showMoveChatSheet(context, t);
          }
        },
        itemBuilder: (ctx) => [
          const PopupMenuItem(value: 'rename', child: Text('Rename')),
          const PopupMenuItem(value: 'move', child: Text('Move to folder…')),
        ],
      ),
      selected: active,
      selectedTileColor: cs.primaryContainer.withValues(alpha: 0.45),
      onTap: () => onSelectThread(t.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final folderIds = ai.folders.map((f) => f.id).toSet();
    final inbox = _inboxThreads(ai.threads, folderIds);
    final loadingLists =
        ai.threadsLoading && ai.threads.isEmpty && ai.foldersLoading && ai.folders.isEmpty;

    List<Widget> folderTiles() {
      return ai.folders.map((folder) {
        final inFolder = _threadsForFolder(ai.threads, folder.id);
        final n = inFolder.length;
        final hasActive = inFolder.any((t) => t.id == ai.threadId);
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          clipBehavior: Clip.antiAlias,
          child: ExpansionTile(
            key: ValueKey<int>(folder.id),
            initiallyExpanded: hasActive,
            leading: CircleAvatar(
              backgroundColor: cs.primaryContainer,
              foregroundColor: cs.onPrimaryContainer,
              child: const Icon(Icons.folder_outlined, size: 22),
            ),
            title: Text(
              folder.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              n == 0 ? 'Empty — tap to open' : '$n ${n == 1 ? 'chat' : 'chats'}',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12.5),
            ),
            childrenPadding: const EdgeInsets.only(bottom: 4),
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    showModalBottomSheet<void>(
                      context: context,
                      showDragHandle: true,
                      builder: (ctx) => SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.edit_outlined),
                              title: const Text('Rename folder'),
                              onTap: () {
                                Navigator.pop(ctx);
                                _renameFolderDialog(context, folder);
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.delete_outline, color: cs.error),
                              title: Text(
                                'Delete folder',
                                style: TextStyle(color: cs.error),
                              ),
                              onTap: () {
                                Navigator.pop(ctx);
                                _confirmDeleteFolder(context, folder);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.tune, size: 18),
                  label: const Text('Folder options'),
                ),
              ),
              ListTile(
                dense: true,
                leading: Icon(Icons.add_comment_outlined, size: 22, color: cs.primary),
                title: const Text('New chat in this folder'),
                onTap: () => onNewChat(folderId: folder.id),
              ),
              if (inFolder.isEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Text(
                    'Move a chat here from the inbox, or start a new one above.',
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13, height: 1.35),
                  ),
                )
              else
                ...inFolder.map((t) => _threadTile(context, ai, t)),
            ],
          ),
        );
      }).toList();
    }

    List<Widget> inboxSection() {
      return [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Inbox',
                style: tt.labelLarge?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Only chats that are not in a folder. Move one into a folder to remove it from here.',
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12, height: 1.3),
              ),
            ],
          ),
        ),
        if (inbox.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              ai.folders.isEmpty
                  ? 'No chats yet. Start a new one above.'
                  : 'No unfiled chats — open a folder above to see the rest.',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13, height: 1.35),
            ),
          )
        else
          ...inbox.map((t) => _threadTile(context, ai, t)),
      ];
    }

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 4, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Coach chats',
                          style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Folders keep chats out of the inbox until you expand them.',
                          style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12.5, height: 1.3),
                        ),
                        const SizedBox(height: 10),
                        FilledButton.tonalIcon(
                          onPressed: () => onNewChat(),
                          icon: const Icon(Icons.add),
                          label: const Text('New chat'),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'New folder',
                    icon: const Icon(Icons.create_new_folder_outlined),
                    onPressed: () => _newFolderDialog(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            if (loadingLists)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (ai.threads.isEmpty && ai.folders.isEmpty)
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'No chats yet.\nTap “New chat” or create a folder.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: cs.onSurfaceVariant, height: 1.4),
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(top: 4, bottom: 16),
                  children: [
                    if (ai.folders.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 2),
                        child: Text(
                          'Folders',
                          style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      ...folderTiles(),
                      const SizedBox(height: 8),
                      const Divider(height: 1),
                    ],
                    ...inboxSection(),
                  ],
                ),
              ),
          ],
        ),
      ),
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
