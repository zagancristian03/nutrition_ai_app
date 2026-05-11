import 'package:flutter/foundation.dart';

import '../services/ai_api_service.dart';

/// State for the AI coaching layer.
///
///   * Onboarding: loads the current [AiProfile] so screens can gate on
///     `onboardingCompleted`.
///   * Chat: multiple persisted threads per user; [threads] lists them and
///     [threadId] is the active conversation. Threads can be renamed and
///     grouped into [folders].
class AiProvider extends ChangeNotifier {
  AiProvider({AiApiService? api}) : _api = api ?? AiApiService();

  final AiApiService _api;

  String? _userId;

  AiProfile? _profile;
  bool _profileLoading = false;

  int? _threadId;
  final List<AiChatMessage> _messages = [];
  bool _historyLoading = false;
  bool _sending = false;
  String? _lastError;

  List<AiChatThreadSummary> _threads = [];
  bool _threadsLoading = false;

  List<AiChatFolder> _folders = [];
  bool _foldersLoading = false;

  /// After [moveThreadToFolder], the drawer can expand this folder once.
  int? _pendingExpandFolderId;

  // ----------------------------------------------------------------------- //
  // Getters                                                                 //
  // ----------------------------------------------------------------------- //

  AiProfile? get profile => _profile;
  bool get profileLoading => _profileLoading;
  bool get onboardingDone => _profile?.onboardingCompleted ?? false;

  int? get threadId => _threadId;
  List<AiChatMessage> get messages => List.unmodifiable(_messages);
  bool get historyLoading => _historyLoading;
  bool get sending => _sending;
  String? get lastError => _lastError;

  List<AiChatThreadSummary> get threads => List.unmodifiable(_threads);
  bool get threadsLoading => _threadsLoading;

  List<AiChatFolder> get folders => List.unmodifiable(_folders);
  bool get foldersLoading => _foldersLoading;

  /// Non-null briefly after a successful move into a folder (for drawer UX).
  int? get pendingExpandFolderId => _pendingExpandFolderId;

  /// Title of the active thread for the app bar (falls back to generic label).
  String get activeThreadTitle {
    final id = _threadId;
    if (id == null) return 'AI Coach';
    for (final t in _threads) {
      if (t.id == id) return t.displayTitle;
    }
    return 'Chat #$id';
  }

  // ----------------------------------------------------------------------- //
  // Auth                                                                    //
  // ----------------------------------------------------------------------- //

  Future<void> setUser(String? userId) async {
    if (_userId == userId) return;
    _userId = userId;
    _profile = null;
    _threadId = null;
    _messages.clear();
    _threads.clear();
    _folders.clear();
    _pendingExpandFolderId = null;
    _lastError = null;
    notifyListeners();

    if (userId != null) {
      await Future.wait<void>([
        loadProfile(),
        loadThreads(),
        loadFolders(),
        loadHistory(),
      ]);
    }
  }

  // ----------------------------------------------------------------------- //
  // Onboarding                                                              //
  // ----------------------------------------------------------------------- //

  Future<void> loadProfile() async {
    final uid = _userId;
    if (uid == null) return;

    _profileLoading = true;
    notifyListeners();
    try {
      _profile = await _api.getProfile(uid);
    } finally {
      _profileLoading = false;
      notifyListeners();
    }
  }

  /// Save onboarding answers. Pass `markCompleted: false` for partial saves.
  Future<bool> saveOnboarding(
    Map<String, dynamic> answers, {
    bool markCompleted = true,
  }) async {
    final uid = _userId;
    if (uid == null) return false;

    final saved = await _api.saveOnboarding(
      userId: uid,
      answers: answers,
      markCompleted: markCompleted,
    );
    if (saved != null) {
      _profile = saved;
      notifyListeners();
      return true;
    }
    return false;
  }

  // ----------------------------------------------------------------------- //
  // Folders                                                                 //
  // ----------------------------------------------------------------------- //

  Future<void> loadFolders() async {
    final uid = _userId;
    if (uid == null) return;

    _foldersLoading = true;
    notifyListeners();
    try {
      _folders = await _api.listFolders(userId: uid);
    } finally {
      _foldersLoading = false;
      notifyListeners();
    }
  }

  /// Creates a folder (empty until you move chats into it).
  Future<bool> createFolder(String name) async {
    final uid = _userId;
    if (uid == null) return false;
    final trimmed = name.trim();
    if (trimmed.isEmpty) return false;
    final f = await _api.createFolder(userId: uid, name: trimmed);
    if (f == null) return false;
    await loadFolders();
    return true;
  }

  Future<bool> renameFolder(int folderId, String name) async {
    final uid = _userId;
    if (uid == null) return false;
    final trimmed = name.trim();
    if (trimmed.isEmpty) return false;
    final f = await _api.renameFolder(
      userId: uid,
      folderId: folderId,
      name: trimmed,
    );
    if (f == null) return false;
    await loadFolders();
    return true;
  }

  /// Deletes the folder; chats inside become unfiled (server sets folder_id null).
  Future<bool> deleteFolder(int folderId) async {
    final uid = _userId;
    if (uid == null) return false;
    final ok = await _api.deleteFolder(userId: uid, folderId: folderId);
    if (!ok) return false;
    await Future.wait<void>([loadFolders(), loadThreads()]);
    return true;
  }

  // ----------------------------------------------------------------------- //
  // Threads & chat                                                          //
  // ----------------------------------------------------------------------- //

  Future<void> loadThreads() async {
    final uid = _userId;
    if (uid == null) return;

    _threadsLoading = true;
    notifyListeners();
    try {
      _threads = await _api.listThreads(userId: uid);
    } finally {
      _threadsLoading = false;
      notifyListeners();
    }
  }

  /// Opens the most recently updated thread and its messages (backend default).
  Future<void> loadHistory() async {
    final uid = _userId;
    if (uid == null) return;

    _historyLoading = true;
    notifyListeners();
    try {
      final hist = await _api.getChatHistory(userId: uid);
      if (hist != null) {
        _threadId = hist.threadId;
        _messages
          ..clear()
          ..addAll(hist.messages);
      }
    } finally {
      _historyLoading = false;
      notifyListeners();
    }
  }

  /// Switch to another saved conversation.
  ///
  /// Returns false if a message is still being sent (avoid mixing replies).
  Future<bool> selectThread(int threadId) async {
    final uid = _userId;
    if (uid == null) return false;
    if (_sending) return false;

    _lastError = null;
    _historyLoading = true;
    _messages.clear();
    notifyListeners();
    try {
      final hist = await _api.getChatHistory(userId: uid, threadId: threadId);
      if (hist != null) {
        _threadId = hist.threadId;
        _messages.addAll(hist.messages);
      }
    } finally {
      _historyLoading = false;
      notifyListeners();
    }
    return true;
  }

  /// Creates an empty thread on the server and makes it active.
  /// [folderId] — optional folder to file the new chat under.
  ///
  /// Does nothing if a message is in flight (keeps thread/reply state consistent).
  Future<bool> createNewChat({int? folderId}) async {
    final uid = _userId;
    if (uid == null) return false;
    if (_sending) return false;

    _lastError = null;
    final t = await _api.createChatThread(
      userId: uid,
      folderId: folderId,
    );
    if (t == null) {
      _lastError =
          "Couldn't start a new chat. Check your connection and try again.";
      notifyListeners();
      return false;
    }
    await loadThreads();
    _threadId = t.id;
    _messages.clear();
    notifyListeners();
    return true;
  }

  /// Backwards-compatible alias.
  Future<void> startNewThread() async {
    await createNewChat();
  }

  Future<bool> renameThread(int threadId, String title) async {
    final uid = _userId;
    if (uid == null) return false;
    final t = title.trim();
    final row = await _api.patchChatThread(
      userId: uid,
      threadId: threadId,
      patch: {'title': t.isEmpty ? null : t},
    );
    if (row == null) return false;
    await loadThreads();
    notifyListeners();
    return true;
  }

  /// [folderId] `null` moves the chat to **Unfiled**.
  Future<bool> moveThreadToFolder(int threadId, int? folderId) async {
    final uid = _userId;
    if (uid == null) return false;
    final row = await _api.patchChatThread(
      userId: uid,
      threadId: threadId,
      patch: {'folder_id': folderId},
    );
    if (row == null) return false;
    if (folderId != null) {
      _pendingExpandFolderId = folderId;
    }
    await loadThreads();
    _reconcileThreadAfterMove(threadId, row);
    notifyListeners();
    return true;
  }

  /// If GET /threads still lacks `folder_id` (e.g. list fell back before schema
  /// existed), keep the PATCH response as source of truth for this row.
  void _reconcileThreadAfterMove(int threadId, AiChatThreadSummary patched) {
    final i = _threads.indexWhere((t) => t.id == threadId);
    if (i < 0) return;
    if (_threads[i].folderId != patched.folderId) {
      _threads = List<AiChatThreadSummary>.from(_threads);
      _threads[i] = patched;
    }
  }

  /// Call from the drawer after expanding a folder for [pendingExpandFolderId].
  void clearPendingExpandFolder() {
    if (_pendingExpandFolderId == null) return;
    _pendingExpandFolderId = null;
    notifyListeners();
  }

  Future<bool> sendMessage(String text) async {
    final uid = _userId;
    final trimmed = text.trim();
    if (uid == null || trimmed.isEmpty || _sending) return false;

    /// Thread the user was viewing when this send started. If they open another
    /// chat before the HTTP response returns, we must not append this reply here.
    final int? threadWhenSendStarted = _threadId;

    _sending = true;
    _lastError = null;
    _messages.add(AiChatMessage(
      role: 'user',
      content: trimmed,
      createdAt: DateTime.now(),
    ));
    notifyListeners();

    final reply = await _api.sendChat(
      userId: uid,
      message: trimmed,
      threadId: threadWhenSendStarted,
    );

    _sending = false;

    if (reply == null) {
      _lastError =
          "The coach couldn't reply right now. Check your connection and try again.";
      notifyListeners();
      return false;
    }

    final stillOnSameThread = _threadId == threadWhenSendStarted;
    if (!stillOnSameThread) {
      // Reply is persisted on the server for the thread we sent from; refresh list only.
      await loadThreads();
      notifyListeners();
      return true;
    }

    _threadId = reply.threadId;
    _messages.add(AiChatMessage(
      role: 'assistant',
      content: reply.reply,
      createdAt: DateTime.now(),
    ));
    notifyListeners();

    await loadThreads();
    return true;
  }

  void clearError() {
    if (_lastError == null) return;
    _lastError = null;
    notifyListeners();
  }
}
