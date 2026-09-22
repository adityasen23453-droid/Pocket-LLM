import 'package:flutter/material.dart';
import '../models/chat_session.dart';
import '../theme/app_theme.dart';

/// Redesigned ChatSidebar matching the Forest Emerald & Warm Cream theme (Starting Page):
/// - 3D Liquid Chrome "C" Logo + Forest Emerald "PocketLLM"
/// - "AI 2.0" emerald badge
/// - Sleek Landing Page card with emerald home icon
/// - Forest Emerald "New Chat Session" CTA button
/// - Sage green active session card with delete action
/// - Clean bottom workspace profile strip with PRO badge & theme toggle
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

    // Forest Emerald & Warm Cream theme tokens matching landing page
    final bg = isDark ? const Color(0xFF101211) : const Color(0xFFFAF7F0);
    final cardBg = isDark ? const Color(0xFF181B19) : Colors.white;
    final textPrimary = isDark ? const Color(0xFFF7F4EE) : const Color(0xFF14261A);
    final textSecondary = isDark ? const Color(0xFFACAFAB) : const Color(0xFF555955);
    final emeraldAccent = isDark ? const Color(0xFF8BB596) : const Color(0xFF172C1E);
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.12) : const Color(0x35DFCDBC);

    return Container(
      width: 310,
      decoration: BoxDecoration(
        color: bg,
        border: Border(
          right: BorderSide(color: borderColor, width: 1.0),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Drawer Header: 3D PocketLLM "P" Logo, PocketLLM Wordmark & Close Button
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 14, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 3D PocketLLM Emerald & Platinum "P" Logo Icon
                  Image.asset(
                    'assets/images/pocketllm_logo.png',
                    width: 30,
                    height: 30,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: emeraldAccent.withValues(alpha: 0.2),
                      ),
                      child: Center(
                        child: Text(
                          'P',
                          style: TextStyle(
                            color: emeraldAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Brand Wordmark + AI Badge
                  Expanded(
                    child: Row(
                      children: [
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'sans-serif',
                              letterSpacing: -0.4,
                            ),
                            children: [
                              TextSpan(
                                text: 'Pocket',
                                style: TextStyle(color: textPrimary),
                              ),
                              TextSpan(
                                text: 'LLM',
                                style: TextStyle(color: emeraldAccent),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E2821) : const Color(0xFFEBF4EE),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark ? const Color(0xFF3F6649) : const Color(0xFFA6D4B0),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                size: 10,
                                color: emeraldAccent,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                'AI 2.0',
                                style: TextStyle(
                                  color: emeraldAccent,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Floating Circular Close Button with 44dp touch target
                  Tooltip(
                    message: 'Close drawer',
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(22),
                      child: SizedBox(
                        width: 44,
                        height: 44,
                        child: Center(
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: cardBg,
                              border: Border.all(color: borderColor, width: 1.0),
                              boxShadow: [
                                BoxShadow(
                                  color: isDark ? Colors.black.withValues(alpha: 0.3) : const Color(0xFF735C4A).withValues(alpha: 0.06),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                Icons.close_rounded,
                                size: 18,
                                color: textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Landing Page Navigation Card
            if (onBackToLanding != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: InkWell(
                  onTap: onBackToLanding,
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 14),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: borderColor, width: 1.0),
                      boxShadow: [
                        BoxShadow(
                          color: isDark ? Colors.black.withValues(alpha: 0.2) : const Color(0xFF735C4A).withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark ? const Color(0xFF1E2821) : const Color(0xFFEBF4EE),
                            border: Border.all(
                              color: isDark ? const Color(0xFF3F6649) : const Color(0xFFA6D4B0),
                              width: 0.8,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.home_rounded,
                              size: 17,
                              color: emeraldAccent,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Landing Page',
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.1,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 6),

            // 3. New Chat Session Primary Action Button (Forest Emerald Theme)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Tooltip(
                message: 'Start new chat session',
                child: InkWell(
                  onTap: onNewChat,
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    height: 46,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? const [Color(0xFF2D4D36), Color(0xFF1B3824)]
                            : const [Color(0xFF172C1E), Color(0xFF2A5338)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_rounded,
                          size: 20,
                          color: Color(0xFFF7F4EE),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'New Chat Session',
                          style: TextStyle(
                            color: Color(0xFFF7F4EE),
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // 4. Section Label: Recent Conversations
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Text(
                'RECENT CONVERSATIONS',
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ),

            const SizedBox(height: 4),

            // 5. Chat History Sessions List
            Expanded(
              child: sessions.isEmpty
                  ? Center(
                      child: Text(
                        'No chat history yet',
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: sessions.length,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      itemBuilder: (context, index) {
                        final session = sessions[index];
                        final isActive = session.id == activeSessionId;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          child: InkWell(
                            onTap: () => onSelectSession(session.id),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? (isDark ? const Color(0xFF1E2821) : const Color(0xFFEBF4EE))
                                    : cardBg,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isActive
                                      ? (isDark ? const Color(0xFF3F6649) : const Color(0xFFA6D4B0))
                                      : borderColor,
                                  width: isActive ? 1.2 : 0.8,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Active or Inactive Icon
                                  if (isActive)
                                    Container(
                                      width: 24,
                                      height: 24,
                                      margin: const EdgeInsets.only(right: 10),
                                      child: Image.asset(
                                        'assets/images/emerald_bubble_avatar.png',
                                        width: 24,
                                        height: 24,
                                        fit: BoxFit.contain,
                                        errorBuilder: (context, error, stackTrace) => Icon(
                                          Icons.chat_bubble_rounded,
                                          size: 16,
                                          color: emeraldAccent,
                                        ),
                                      ),
                                    )
                                  else
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: Icon(
                                        Icons.chat_bubble_outline_rounded,
                                        size: 17,
                                        color: textSecondary,
                                      ),
                                    ),

                                  // Session Title
                                  Expanded(
                                    child: Text(
                                      session.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: isActive ? textPrimary : textSecondary,
                                        fontSize: 13.5,
                                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                                        letterSpacing: -0.1,
                                      ),
                                    ),
                                  ),

                                  // Delete Session Action with comfortable touch target
                                  if (onDeleteSession != null && sessions.length > 1)
                                    Tooltip(
                                      message: 'Delete conversation',
                                      child: InkWell(
                                        onTap: () => onDeleteSession!(session.id),
                                        borderRadius: BorderRadius.circular(12),
                                        child: SizedBox(
                                          width: 38,
                                          height: 38,
                                          child: Center(
                                            child: Icon(
                                              Icons.delete_outline_rounded,
                                              size: 17,
                                              color: textSecondary.withValues(alpha: 0.8),
                                            ),
                                          ),
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

            // 6. Bottom Profile & Settings Strip
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              decoration: BoxDecoration(
                color: cardBg,
                border: Border(
                  top: BorderSide(color: borderColor, width: 1.0),
                ),
              ),
              child: Row(
                children: [
                  // User Avatar with Emerald Border
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: emeraldAccent,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/emerald_bubble_avatar.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: emeraldAccent.withValues(alpha: 0.15),
                              child: Center(
                                child: Icon(
                                  Icons.person_rounded,
                                  size: 20,
                                  color: emeraldAccent,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 11,
                          height: 11,
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: cardBg,
                              width: 2.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),

                  // Workspace Name & PRO PLAN Badge
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PocketLLM Workspace',
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E2821) : const Color(0xFFEBF4EE),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isDark ? const Color(0xFF3F6649) : const Color(0xFFA6D4B0),
                                  width: 0.6,
                                ),
                              ),
                              child: Text(
                                'PRO PLAN',
                                style: TextStyle(
                                  color: emeraldAccent,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Theme Toggle Button with 44dp hit area
                  ValueListenableBuilder<ThemeMode>(
                    valueListenable: themeController,
                    builder: (context, mode, child) {
                      return Tooltip(
                        message: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                        child: InkWell(
                          onTap: () => themeController.toggleTheme(),
                          borderRadius: BorderRadius.circular(22),
                          child: SizedBox(
                            width: 44,
                            height: 44,
                            child: Center(
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: bg,
                                  border: Border.all(color: borderColor, width: 0.8),
                                ),
                                child: Center(
                                  child: Icon(
                                    isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                                    size: 18,
                                    color: textSecondary,
                                  ),
                                ),
                              ),
                            ),
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
