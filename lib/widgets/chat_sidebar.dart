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
    final bg = isDark ? const Color(0xFF0D0E11) : const Color(0xFFFFFFFF);
    final textPrimary = isDark ? const Color(0xFFE3E3E8) : const Color(0xFF1F1F1F);
    final textSecondary = isDark ? const Color(0xFF8E8E98) : const Color(0xFF70757A);
    final activeItemBg = isDark ? const Color(0xFF1E1F24) : const Color(0xFFE8F0FE);

    return Container(
      width: 300,
      color: bg,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header: "PocketLLM" title + close button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'PocketLLM',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: 24, color: textPrimary),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),

            // New Chat pill button (highlighted)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: InkWell(
                onTap: onNewChat,
                borderRadius: BorderRadius.circular(28),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2A2B31) : const Color(0xFFF0F4F9),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        size: 20,
                        color: isDark ? const Color(0xFF8AB4F8) : const Color(0xFF1A73E8),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'New chat',
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Navigation items (PocketLLM style)
            _navItem(Icons.search, 'Search chats', textPrimary, textSecondary, () {}),
            _navItem(Icons.auto_awesome_outlined, 'Images', textPrimary, textSecondary, () {}),
            _navItem(Icons.smart_display_outlined, 'Videos', textPrimary, textSecondary, () {}),
            _navItem(Icons.grid_view_rounded, 'Library', textPrimary, textSecondary, () {}),

            const SizedBox(height: 16),

            // Notebooks section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Text(
                'Notebooks',
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            _navItem(Icons.add, 'New notebook', textPrimary, textSecondary, () {}),

            const SizedBox(height: 16),

            // Recent section label
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Text(
                'Recent',
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // Chat History List
            Expanded(
              child: sessions.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Text(
                        'No results found',
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: sessions.length,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      itemBuilder: (context, index) {
                        final session = sessions[index];
                        final isActive = session.id == activeSessionId;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 2),
                          child: InkWell(
                            onTap: () => onSelectSession(session.id),
                            borderRadius: BorderRadius.circular(28),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: isActive ? activeItemBg : Colors.transparent,
                                borderRadius: BorderRadius.circular(28),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      session.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: isActive
                                            ? textPrimary
                                            : (isDark ? const Color(0xFFBBBBC3) : const Color(0xFF444746)),
                                        fontSize: 14,
                                        fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  if (onDeleteSession != null && sessions.length > 1)
                                    InkWell(
                                      onTap: () => onDeleteSession!(session.id),
                                      borderRadius: BorderRadius.circular(12),
                                      child: Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: Icon(
                                          Icons.close_rounded,
                                          size: 16,
                                          color: textSecondary.withValues(alpha: 0.6),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Bottom Profile Card (PocketLLM style)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 12, 16),
              child: Row(
                children: [
                  // Profile avatar with glowing ring
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF1A73E8),
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.asset(
                        'assets/images/pratik_avatar.png',
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 36,
                          height: 36,
                          color: isDark ? const Color(0xFF2A2B31) : const Color(0xFFF0F4F9),
                          child: Icon(Icons.person, size: 20, color: textSecondary),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pratik Sharma',
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          'PLUS',
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.settings_outlined, size: 22, color: textSecondary),
                    onPressed: () {},
                    tooltip: 'Settings',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, Color primaryColor, Color secondaryColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 22, color: primaryColor),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                color: primaryColor,
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
