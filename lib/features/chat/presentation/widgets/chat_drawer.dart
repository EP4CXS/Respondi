import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/session/chat_session_manager.dart';
import '../../domain/entities/chat_session_summary.dart';
import '../../infrastructure/datasources/chat_history_datasource.dart';

class ChatDrawer extends StatefulWidget {
  const ChatDrawer({
    super.key,
    required this.userId,
    required this.onSessionSelected,
    required this.onNewChat,
  });

  final String userId;
  final ValueChanged<String> onSessionSelected;
  final VoidCallback onNewChat;

  @override
  State<ChatDrawer> createState() => ChatDrawerState();
}

class ChatDrawerState extends State<ChatDrawer> {
  final _datasource = ChatHistoryDatasource();
  List<ChatSessionSummary> _sessions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    reloadSessions();
  }

  Future<void> reloadSessions() async {
    final sessions = await _datasource.listSessions(widget.userId);
    if (!mounted) return;
    setState(() {
      _sessions = sessions;
      _loading = false;
    });
  }

  void _logout(BuildContext context) {
    ChatSessionManager.clear();
    Navigator.pop(context);
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.landing,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupSessions(_sessions);

    return Drawer(
      width: MediaQuery.sizeOf(context).width * 0.72,
      backgroundColor: AppColors.chatDrawerBackground,
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.menu, color: AppColors.black, size: 28),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        _NewChatButton(
                          onPressed: () {
                            Navigator.pop(context);
                            widget.onNewChat();
                          },
                        ),
                        const SizedBox(height: 24),
                        const _SectionTitle('Recent'),
                        const SizedBox(height: 8),
                        if (grouped.recent.isEmpty)
                          const _EmptyHint('No recent chats')
                        else
                          ...grouped.recent.map(
                            (session) => _HistoryTile(
                              title: session.title,
                              onTap: () {
                                Navigator.pop(context);
                                widget.onSessionSelected(session.id);
                              },
                            ),
                          ),
                        const SizedBox(height: 28),
                        const _SectionTitle('Last Week'),
                        const SizedBox(height: 8),
                        if (grouped.lastWeek.isEmpty)
                          const _EmptyHint('No chats from last week')
                        else
                          ...grouped.lastWeek.map(
                            (session) => _HistoryTile(
                              title: session.title,
                              onTap: () {
                                Navigator.pop(context);
                                widget.onSessionSelected(session.id);
                              },
                            ),
                          ),
                      ],
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () => _logout(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.chatNavBar,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: Text(
                    'Log out',
                    style: GoogleFonts.spaceMono(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _GroupedSessions _groupSessions(List<ChatSessionSummary> sessions) {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final startOfLastWeek = startOfToday.subtract(const Duration(days: 7));

    final recent = <ChatSessionSummary>[];
    final lastWeek = <ChatSessionSummary>[];

    for (final session in sessions) {
      if (!session.updatedAt.isBefore(startOfToday)) {
        recent.add(session);
      } else if (!session.updatedAt.isBefore(startOfLastWeek)) {
        lastWeek.add(session);
      }
    }

    return _GroupedSessions(recent: recent, lastWeek: lastWeek);
  }
}

class _GroupedSessions {
  const _GroupedSessions({
    required this.recent,
    required this.lastWeek,
  });

  final List<ChatSessionSummary> recent;
  final List<ChatSessionSummary> lastWeek;
}

class _NewChatButton extends StatelessWidget {
  const _NewChatButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: AppColors.chatNewChatButton,
          foregroundColor: AppColors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: Text(
          'New chat',
          style: GoogleFonts.spaceMono(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.spaceMono(
        color: AppColors.black,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        text,
        style: GoogleFonts.spaceMono(
          color: AppColors.black.withValues(alpha: 0.55),
          fontSize: 12,
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    required this.title,
    required this.onTap,
  });

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.spaceMono(
                  color: AppColors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const Icon(Icons.more_horiz, color: AppColors.black, size: 22),
          ],
        ),
      ),
    );
  }
}
