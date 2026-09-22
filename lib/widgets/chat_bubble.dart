import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/chat_message.dart';

/// Forest Emerald & Warm Cream chat bubbles matching the starting landing page:
/// - User: Solid Forest Emerald gradient pill with timestamp below
/// - AI: Miniature 3D emerald bubble avatar + warm editorial card with action icons row
class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({
    super.key,
    required this.message,
  });

  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    if (message.isUser) {
      return _buildUserBubble(context);
    }
    return _buildAiBubble(context);
  }

  Widget _buildUserBubble(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final timeStr = _formatTime(message.timestamp);

    return Padding(
      padding: const EdgeInsets.only(left: 48, right: 16, top: 6, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 580),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? const [Color(0xFF2D4D36), Color(0xFF1B3824)]
                    : const [Color(0xFF172C1E), Color(0xFF2A5338)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SelectableText(
              message.text,
              style: const TextStyle(
                color: Color(0xFFF7F4EE),
                fontSize: 14.5,
                height: 1.4,
                letterSpacing: -0.1,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Text(
              timeStr,
              style: TextStyle(
                color: isDark ? const Color(0xFF8BB596) : const Color(0xFF767B76),
                fontSize: 11.5,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiBubble(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final timeStr = _formatTime(message.timestamp);

    final cardBg = isDark ? const Color(0xFF181B19) : Colors.white;
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0x35DFCDBC);
    final textPrimary = isDark ? const Color(0xFFF7F4EE) : const Color(0xFF14261A);
    final textMuted = isDark ? const Color(0xFFACAFAB) : const Color(0xFF767B76);
    final emeraldAccent = isDark ? const Color(0xFF8BB596) : const Color(0xFF172C1E);

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 40, top: 8, bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 3D Emerald Glass Bubble Miniature Avatar
          Container(
            width: 34,
            height: 34,
            margin: const EdgeInsets.only(right: 10, top: 2),
            child: Image.asset(
              'assets/images/emerald_bubble_avatar.png',
              width: 34,
              height: 34,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: emeraldAccent.withValues(alpha: 0.18),
                  border: Border.all(color: emeraldAccent, width: 1),
                ),
                child: Icon(Icons.auto_awesome, size: 16, color: emeraldAccent),
              ),
            ),
          ),

          // Message Card Content
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message.isImageGeneration && message.imageUrl != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    constraints: const BoxConstraints(maxWidth: 320),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.1),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.asset(
                        message.imageUrl!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                if (message.text.isNotEmpty)
                  Container(
                    constraints: const BoxConstraints(maxWidth: 580),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: borderColor,
                        width: 0.8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withValues(alpha: 0.3)
                              : const Color(0xFF735C4A).withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: SelectableText(
                      message.text,
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 14.5,
                        height: 1.45,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ),

                const SizedBox(height: 6),

                // Action Row underneath AI Message: Timestamp + Copy/Like/Speaker icons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        timeStr,
                        style: TextStyle(
                          color: textMuted,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _actionIconButton(
                            context,
                            Icons.copy_rounded,
                            'Copy',
                            () {
                              Clipboard.setData(ClipboardData(text: message.text));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Copied to clipboard!'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            textMuted,
                          ),
                          const SizedBox(width: 8),
                          _actionIconButton(
                            context,
                            Icons.thumb_up_alt_outlined,
                            'Like',
                            () {},
                            textMuted,
                          ),
                          const SizedBox(width: 8),
                          _actionIconButton(
                            context,
                            Icons.volume_up_rounded,
                            'Read aloud',
                            () {},
                            textMuted,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionIconButton(BuildContext context, IconData icon, String tooltip, VoidCallback onTap, Color iconColor) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Tooltip(
        message: tooltip,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(
            icon,
            size: 15.5,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}

/// A pulsing animated emerald bubble indicator
class PocketLLMThinkingIndicator extends StatefulWidget {
  const PocketLLMThinkingIndicator({super.key});

  @override
  State<PocketLLMThinkingIndicator> createState() => _PocketLLMThinkingIndicatorState();
}

class _PocketLLMThinkingIndicatorState extends State<PocketLLMThinkingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF181B19) : Colors.white;
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0x35DFCDBC);
    final emeraldAccent = isDark ? const Color(0xFF8BB596) : const Color(0xFF172C1E);

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 52, top: 8, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 10),
            child: Image.asset(
              'assets/images/emerald_bubble_avatar.png',
              width: 32,
              height: 32,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: emeraldAccent.withValues(alpha: 0.2),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderColor, width: 0.8),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.25)
                      : const Color(0xFF735C4A).withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) {
                    final delay = i * 0.25;
                    final t = (_controller.value + delay) % 1.0;
                    final opacity = 0.25 + 0.75 * sin(t * pi);
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: emeraldAccent.withValues(alpha: opacity),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
