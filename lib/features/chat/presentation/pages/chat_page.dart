import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../domain/entities/chat_turn.dart';
import '../../domain/exceptions/chat_failure.dart';
import '../../domain/usecases/send_chat_message_usecase.dart';
import '../../infrastructure/datasources/chat_history_datasource.dart';
import '../../infrastructure/repositories/chat_repository_impl.dart';
import '../../../../core/session/chat_session_manager.dart';
import '../../../profile/presentation/pages/emergency_contacts_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../widgets/animated_typing_indicator.dart';
import '../widgets/chat_drawer.dart';

const _inputBarHeight = 48.0;
const _inputBarGap = 8.0;
const _bottomNavHeight = 68.0;
const _bottomNavBottomGap = 10.0;

enum _ChatMessageKind { user, botTyping, bot }

class _ChatMessage {
  const _ChatMessage({
    required this.kind,
    this.text,
    this.typingId,
  });

  final _ChatMessageKind kind;
  final String? text;
  final String? typingId;

  factory _ChatMessage.user(String text) =>
      _ChatMessage(kind: _ChatMessageKind.user, text: text);

  factory _ChatMessage.typing(String typingId) => _ChatMessage(
        kind: _ChatMessageKind.botTyping,
        typingId: typingId,
      );

  factory _ChatMessage.bot(String text) =>
      _ChatMessage(kind: _ChatMessageKind.bot, text: text);
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.user});

  final AppUser user;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  static const _minTypingDuration = Duration(milliseconds: 1400);

  final _messageController = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _drawerKey = GlobalKey<ChatDrawerState>();
  final _scrollController = ScrollController();
  final _sendChatMessage = SendChatMessageUseCase(ChatRepositoryImpl());
  final _historyDatasource = ChatHistoryDatasource();
  final List<_ChatMessage> _messages = [];
  int _typingCounter = 0;
  String? _sessionId;
  bool _isSending = false;

  bool get _hasConversation => _messages.isNotEmpty;

  double _bottomChromeHeight(bool keyboardOpen) {
    if (keyboardOpen) {
      return _inputBarHeight + _inputBarGap + 16;
    }
    return _inputBarHeight +
        _inputBarGap +
        _bottomNavHeight +
        _bottomNavBottomGap +
        16;
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _openDrawer() async {
    await _drawerKey.currentState?.reloadSessions();
    if (!mounted) return;
    _scaffoldKey.currentState?.openDrawer();
  }

  void _openProfile() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProfilePage(user: widget.user),
      ),
    );
  }

  void _openEmergencyContacts() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const EmergencyContactsPage(),
      ),
    );
  }

  void _startNewChat() {
    ChatSessionManager.clearActiveSession();
    setState(() {
      _sessionId = null;
      _messages.clear();
      _isSending = false;
      _messageController.clear();
    });
  }

  Future<void> _loadSession(String sessionId) async {
    final stored = await _historyDatasource.getMessages(sessionId);
    if (!mounted) return;

    ChatSessionManager.setActiveSession(sessionId);
    setState(() {
      _sessionId = sessionId;
      _messages
        ..clear()
        ..addAll(
          stored.map(
            (m) => m.isUser
                ? _ChatMessage.user(m.content)
                : _ChatMessage.bot(m.content),
          ),
        );
    });
    _scrollToBottom();
  }

  Future<String> _ensureSession(String firstUserMessage) async {
    if (_sessionId != null) return _sessionId!;

    final sessionId = await _historyDatasource.createSession(
      userId: widget.user.id,
      title: firstUserMessage,
    );
    ChatSessionManager.setActiveSession(sessionId);
    _sessionId = sessionId;
    return sessionId;
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  List<ChatTurn> _historyBeforeTyping(String typingId) {
    final typingIndex = _messages.indexWhere((m) => m.typingId == typingId);
    if (typingIndex <= 1) return [];

    final history = <ChatTurn>[];
    for (var i = 0; i < typingIndex - 1; i++) {
      final message = _messages[i];
      if (message.kind == _ChatMessageKind.botTyping || message.text == null) {
        continue;
      }
      final role =
          message.kind == _ChatMessageKind.user ? 'user' : 'assistant';
      history.add(ChatTurn(role: role, content: message.text!));
    }
    return history;
  }

  Future<void> _deliverBotReply(
    String typingId,
    String userText,
    String sessionId,
  ) async {
    String reply;
    try {
      final apiFuture = _sendChatMessage(
        userMessage: userText,
        history: _historyBeforeTyping(typingId),
      );
      final results = await Future.wait<dynamic>([
        apiFuture,
        Future<void>.delayed(_minTypingDuration),
      ]);
      reply = results.first as String;
    } on ChatFailure catch (e) {
      await Future<void>.delayed(_minTypingDuration);
      reply = e.message;
    } catch (_) {
      await Future<void>.delayed(_minTypingDuration);
      reply =
          'Unable to reach Respondi right now. Check your internet and try again.';
    }

    await _historyDatasource.insertMessage(
      sessionId: sessionId,
      role: 'assistant',
      content: reply,
    );

    if (!mounted) return;

    setState(() {
      _isSending = false;
      final typingIndex =
          _messages.indexWhere((m) => m.typingId == typingId);
      if (typingIndex != -1) {
        _messages[typingIndex] = _ChatMessage.bot(reply);
      }
    });
    _scrollToBottom();
    await _drawerKey.currentState?.reloadSessions();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    final typingId = 'typing-${_typingCounter++}';
    setState(() => _isSending = true);

    final sessionId = await _ensureSession(text);
    await _historyDatasource.insertMessage(
      sessionId: sessionId,
      role: 'user',
      content: text,
    );

    if (!mounted) return;

    setState(() {
      _messages.add(_ChatMessage.user(text));
      _messages.add(_ChatMessage.typing(typingId));
      _messageController.clear();
    });
    _scrollToBottom();
    await _drawerKey.currentState?.reloadSessions();
    await _deliverBotReply(typingId, text, sessionId);
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final keyboardOpen = viewInsets.bottom > 0;
    final inputBottom = keyboardOpen
        ? viewInsets.bottom
        : _bottomNavHeight + _bottomNavBottomGap;

    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      drawer: ChatDrawer(
        key: _drawerKey,
        userId: widget.user.id,
        onSessionSelected: _loadSession,
        onNewChat: _startNewChat,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.chatGradientTop,
              AppColors.chatGradientBottom,
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Column(
                children: [
                  _ChatHeader(onMenuPressed: _openDrawer),
                  Expanded(
                    child: _hasConversation
                        ? _ChatMessageList(
                            messages: _messages,
                            scrollController: _scrollController,
                            bottomPadding: _bottomChromeHeight(keyboardOpen),
                          )
                        : Padding(
                            padding: EdgeInsets.only(
                              bottom: _bottomChromeHeight(keyboardOpen),
                            ),
                            child: const _ChatWelcomeMessage(),
                          ),
                  ),
                ],
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: inputBottom,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: _inputBarGap),
                  child:               _ChatInputBar(
                controller: _messageController,
                enabled: !_isSending,
                onSend: () => _sendMessage(),
              ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: _bottomNavBottomGap),
                    child: _ChatBottomNav(
                      onProfileTap: _openProfile,
                      onContactsTap: _openEmergencyContacts,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatWelcomeMessage extends StatelessWidget {
  const _ChatWelcomeMessage();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Text(
          'Hi! How can i help you Today',
          textAlign: TextAlign.center,
          style: AppTextStyles.chatWelcome,
        ),
      ),
    );
  }
}

class _ChatMessageList extends StatelessWidget {
  const _ChatMessageList({
    required this.messages,
    required this.scrollController,
    required this.bottomPadding,
  });

  final List<_ChatMessage> messages;
  final ScrollController scrollController;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController,
      padding: EdgeInsets.fromLTRB(16, 8, 16, bottomPadding),
      children: [
        const Center(child: _TodayPill()),
        const SizedBox(height: 16),
        for (final message in messages)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: switch (message.kind) {
              _ChatMessageKind.user =>
                _UserMessageBubble(text: message.text!),
              _ChatMessageKind.botTyping =>
                const AnimatedTypingIndicator(),
              _ChatMessageKind.bot => _BotMessageBubble(text: message.text!),
            },
          ),
      ],
    );
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader({required this.onMenuPressed});

  final VoidCallback onMenuPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 12, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: onMenuPressed,
            icon: const Icon(Icons.menu, color: AppColors.black, size: 28),
          ),
          const Spacer(),
          Image.asset(
            AppAssets.logo,
            width: 44,
            height: 44,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}

class _TodayPill extends StatelessWidget {
  const _TodayPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.chatTodayPill,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text('Today', style: AppTextStyles.chatTodayLabel),
    );
  }
}

class _BotAvatar extends StatelessWidget {
  const _BotAvatar();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppAssets.logo,
      width: 32,
      height: 32,
      fit: BoxFit.contain,
    );
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        color: AppColors.black,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.person, color: AppColors.white, size: 20),
    );
  }
}

class _UserMessageBubble extends StatelessWidget {
  const _UserMessageBubble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.chatUserBubble,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(text, style: AppTextStyles.chatMessageText),
          ),
        ),
        const SizedBox(width: 8),
        const _UserAvatar(),
      ],
    );
  }
}

class _BotMessageBubble extends StatelessWidget {
  const _BotMessageBubble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _BotAvatar(),
        const SizedBox(width: 8),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.chatBotBubble,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(text, style: AppTextStyles.chatMessageText),
          ),
        ),
      ],
    );
  }
}

class _ChatInputBar extends StatelessWidget {
  const _ChatInputBar({
    required this.controller,
    required this.onSend,
    this.enabled = true,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: _inputBarHeight,
        padding: const EdgeInsets.only(left: 18, right: 8),
        decoration: BoxDecoration(
          color: AppColors.chatInputFill,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: enabled,
                style: AppTextStyles.chatInputHint,
                textInputAction: TextInputAction.send,
                onSubmitted: enabled ? (_) => onSend() : null,
                decoration: InputDecoration(
                  hintText: 'Ask respondi here....',
                  hintStyle: AppTextStyles.chatInputHint.copyWith(
                    color: AppColors.black.withValues(alpha: 0.85),
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            IconButton(
              onPressed: enabled ? onSend : null,
              icon: const Icon(
                Icons.send_rounded,
                color: AppColors.black,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBottomNav extends StatelessWidget {
  const _ChatBottomNav({
    this.onProfileTap,
    this.onContactsTap,
  });

  final VoidCallback? onProfileTap;
  final VoidCallback? onContactsTap;

  @override
  Widget build(BuildContext context) {
    const barHeight = 56.0;
    const centerSize = 58.0;

    return SizedBox(
      height: _bottomNavHeight,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              height: barHeight,
              decoration: BoxDecoration(
                color: AppColors.chatNavBar,
                borderRadius: BorderRadius.circular(32),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    onPressed: onProfileTap,
                    icon: const Icon(
                      Icons.person_outline,
                      color: AppColors.black,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: centerSize),
                  IconButton(
                    onPressed: onContactsTap,
                    icon: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.chatNavCallCircle,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.phone,
                        color: AppColors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 6,
            child: Container(
              width: centerSize,
              height: centerSize,
              decoration: const BoxDecoration(
                color: AppColors.black,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.message_rounded,
                color: AppColors.white,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
