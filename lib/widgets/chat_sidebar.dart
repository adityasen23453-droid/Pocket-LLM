import 'package:flutter/material.dart';
import '../models/chat_session.dart';
import '../theme/app_theme.dart';

class ChatSidebar extends StatelessWidget {
  final List<ChatSession> sessions;
  final String activeSessionId;
  final ValueChanged<String> onSelectSession;
  final VoidCallback onNewChat;
  final ValueChanged<String>? onDeleteSession;
  final VoidCallback? onBackToLanding;

  const ChatSidebar({
    super.key,
    required this.sessions,
    required this.activeSessionId,
    required this.onSelectSession,
    required this.onNewChat,
    this.onDeleteSession,
    this.onBackToLanding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final sidebarBg = isDark ? const Color(0xFF141417) : const Color(0xFFF9F9FA);
    final borderColor = isDark ? const Color(0xFF242429) : const Color(0xFFE8E8EC);
    final textPrimary = isDark ? Colors.white : Colors.black;
    final textSecondary = isDark ? const Color(0xFF8E8E98) : const Color(0xFF6B6B76);
    final activeItemBg = isDark ? const Color(0xFF222228) : const Color(0xFFEBEBF0);

    return Container(
      width: 270,
      decoration: BoxDecoration(
        color: sidebarBg,
        border: Border(
          right: BorderSide(color: borderColor, width: 1),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header / App title
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
              child: InkWell(
                onTap: onBackToLanding,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white : Colors.black,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.all_inclusive,
                            size: 20,
                            color: isDark ? const Color(0xFF121212) : Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'PocketLLM',
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // New Chat Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: InkWell(
                onTap: onNewChat,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF222227) : const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark ? const Color(0xFF2E2E36) : const Color(0xFFDCDCE2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_rounded,
                        size: 18,
                        color: textPrimary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'New Chat',
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // History Label
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Text(
                'CHAT HISTORY',
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ),

            // Chat History List
            Expanded(
              child: sessions.isEmpty
                  ? Center(
                      child: Text(
                        'No chats yet',
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: sessions.length,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      itemBuilder: (context, index) {
                        final session = sessions[index];
                        final isActive = session.id == activeSessionId;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          child: InkWell(
                            onTap: () => onSelectSession(session.id),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                              decoration: BoxDecoration(
                                color: isActive ? activeItemBg : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.chat_bubble_outline_rounded,
                                    size: 16,
                                    color: isActive ? textPrimary : textSecondary,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      session.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: isActive ? textPrimary : (isDark ? const Color(0xFFCCCCCC) : const Color(0xFF333333)),
                                        fontSize: 13.5,
                                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  if (onDeleteSession != null && sessions.length > 1)
                                    IconButton(
                                      icon: Icon(
                                        Icons.close_rounded,
                                        size: 15,
                                        color: textSecondary.withValues(alpha: 0.7),
                                      ),
                                      onPressed: () => onDeleteSession!(session.id),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                                      splashRadius: 14,
                                      tooltip: 'Delete chat',
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            Divider(height: 1, color: borderColor),

            // Footer Actions
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onBackToLanding != null) ...[
                    InkWell(
                      onTap: onBackToLanding,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1B1B20) : const Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark ? const Color(0xFF28282E) : const Color(0xFFE2E2E6),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.arrow_back_rounded,
                              size: 16,
                              color: textPrimary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Landing Page',
                                style: TextStyle(
                                  color: textPrimary,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  ValueListenableBuilder<ThemeMode>(
                valueListenable: themeController,
                builder: (context, currentTheme, _) {
                  final isDarkTheme = currentTheme == ThemeMode.dark;
                  return InkWell(
                    onTap: () => themeController.toggleTheme(),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1B1B20) : const Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark ? const Color(0xFF28282E) : const Color(0xFFE2E2E6),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isDarkTheme ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                            size: 18,
                            color: textPrimary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              isDarkTheme ? 'Light Theme (White+Black)' : 'Dark Theme (Charcoal)',
                              style: TextStyle(
                                color: textPrimary,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
        ),
      ),
    );
  }
}
