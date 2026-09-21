import 'dart:math';
import 'package:flutter/material.dart';
import '../models/chat_message.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (message.isUser) {
      return _buildUserBubble(context, isDark);
    }
    return _buildAiBubble(context, isDark);
  }

  Widget _buildUserBubble(BuildContext context, bool isDark) {
    final bgColor = isDark ? const Color(0xFF25272C) : const Color(0xFFE8EBF0);
    final textColor = isDark ? Colors.white : const Color(0xFF1F1F1F);

    return Padding(
      padding: const EdgeInsets.only(left: 52, right: 16, top: 6, bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: SelectableText(
                message.text,
                style: TextStyle(
                  color: textColor,
                  fontSize: 15,
                  height: 1.45,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiBubble(BuildContext context, bool isDark) {
    final textColor = isDark ? const Color(0xFFE3E3E8) : const Color(0xFF1F1F1F);
    final secondaryColor = isDark ? const Color(0xFF8E8E98) : const Color(0xFF70757A);

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 52, top: 6, bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vibrant Infinity Logo Avatar
          Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.only(right: 10, top: 2),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                'assets/images/vibrant_infinity_logo.png',
                width: 28,
                height: 28,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF4FC3F7), Color(0xFFAB47BC), Color(0xFFFF7043)],
                    ),
                  ),
                  child: const Icon(Icons.all_inclusive, size: 16, color: Colors.white),
                ),
              ),
            ),
          ),

          // Message Content
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image generation card
                if (message.isImageGeneration && message.imageUrl != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    constraints: const BoxConstraints(maxWidth: 300),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? const Color(0xFF2C2D33) : const Color(0xFFDADCE0),
                        width: 0.5,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        message.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 200,
                          color: isDark ? const Color(0xFF1E1F24) : const Color(0xFFF0F4F9),
                          child: Center(
                            child: Icon(
                              Icons.image_outlined,
                              size: 40,
                              color: secondaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                // Text content
                if (message.text.isNotEmpty)
                  SelectableText(
                    message.text,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                      height: 1.55,
                      letterSpacing: 0.1,
                    ),
                  ),

                const SizedBox(height: 10),

                // Action row (PocketLLM style)
                _buildActionRow(context, isDark, secondaryColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(BuildContext context, bool isDark, Color iconColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _actionIcon(Icons.thumb_up_off_alt_outlined, iconColor, 'Like', () {}),
        const SizedBox(width: 4),
        _actionIcon(Icons.thumb_down_off_alt_outlined, iconColor, 'Dislike', () {}),
        const SizedBox(width: 4),
        _actionIcon(Icons.content_copy_rounded, iconColor, 'Copy', () {}),
        const SizedBox(width: 4),
        _actionIcon(Icons.share_outlined, iconColor, 'Share', () {}),
        const SizedBox(width: 4),
        _actionIcon(Icons.refresh_rounded, iconColor, 'Retry', () {}),
        const Spacer(),
        _actionIcon(Icons.more_vert_rounded, iconColor, 'More', () {}),
      ],
    );
  }

  Widget _actionIcon(IconData icon, Color color, String tooltip, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}

/// A pulsing shimmer animation for the thinking state (PocketLLM Nano style)
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
      duration: const Duration(milliseconds: 1500),
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

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 52, top: 6, bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.only(right: 10, top: 2),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                'assets/images/vibrant_infinity_logo.png',
                width: 28,
                height: 28,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF4FC3F7), Color(0xFFAB47BC), Color(0xFFFF7043)],
                    ),
                  ),
                  child: const Icon(Icons.all_inclusive, size: 16, color: Colors.white),
                ),
              ),
            ),
          ),
          // Shimmer dots
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) {
                  final delay = i * 0.2;
                  final t = (_controller.value + delay) % 1.0;
                  final opacity = 0.3 + 0.7 * sin(t * pi);
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (isDark ? const Color(0xFF8AB4F8) : const Color(0xFF1A73E8))
                          .withValues(alpha: opacity),
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }
}
