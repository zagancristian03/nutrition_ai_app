import 'package:flutter/foundation.dart';

import '../services/ai_api_service.dart';

/// State for the AI coaching layer.
///
///   * Onboarding: loads the current [AiProfile] so screens can gate on
///     `onboardingCompleted`.
///   * Chat: holds the active thread + message list, with optimistic appends.
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

  // ----------------------------------------------------------------------- //
  // Getters                                                                 //
  // ----------------------------------------------------------------------- //

  AiProfile? get profile         => _profile;
  bool       get profileLoading  => _profileLoading;
  bool       get onboardingDone  => _profile?.onboardingCompleted ?? false;

  int?               get threadId        => _threadId;
  List<AiChatMessage> get messages       => List.unmodifiable(_messages);
  bool               get historyLoading  => _historyLoading;
  bool               get sending         => _sending;
  String?            get lastError       => _lastError;

  // ----------------------------------------------------------------------- //
  // Auth                                                                    //
  // ----------------------------------------------------------------------- //

  Future<void> setUser(String? userId) async {
    if (_userId == userId) return;
    _userId = userId;
    _profile = null;
    _threadId = null;
    _messages.clear();
    _lastError = null;
    notifyListeners();

    if (userId != null) {
      await Future.wait<void>([
        loadProfile(),
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
  // Chat                                                                    //
  // ----------------------------------------------------------------------- //

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

  /// Start a fresh thread on the next chat send.
  void startNewThread() {
    _threadId = null;
    _messages.clear();
    _lastError = null;
    notifyListeners();
  }

  Future<bool> sendMessage(String text) async {
    final uid = _userId;
    final trimmed = text.trim();
    if (uid == null || trimmed.isEmpty || _sending) return false;

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
      threadId: _threadId,
    );

    _sending = false;

    if (reply == null) {
      _lastError =
          "The coach couldn't reply right now. Check your connection and try again.";
      notifyListeners();
      return false;
    }

    _threadId = reply.threadId;
    _messages.add(AiChatMessage(
      role: 'assistant',
      content: reply.reply,
      createdAt: DateTime.now(),
    ));
    notifyListeners();
    return true;
  }

  void clearError() {
    if (_lastError == null) return;
    _lastError = null;
    notifyListeners();
  }
}
