import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Forest Emerald & Warm Cream bottom input bar (Matching Landing Page):
/// - Champagne Gold & Emerald Sage iridescent gradient border
/// - Warm cream / deep obsidian card with "Ask me anything..." hint
/// - Left attachment button (🔗)
/// - Right: [ ✦ Voice ] pill button and solid Forest Emerald [ ✈ Send ] button
class ChatInput extends StatefulWidget {
  final Function(String text) onSend;
  final bool isBusy;
  final String selectedModel;
  final VoidCallback? onModelTap;
  final VoidCallback? onAttachTap;
  final VoidCallback? onVoiceTap;
  final TextEditingController? controller;

  const ChatInput({
    super.key,
    required this.onSend,
    this.isBusy = false,
    this.selectedModel = 'Smart',
    this.onModelTap,
    this.onAttachTap,
    this.onVoiceTap,
    this.controller,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  final FocusNode _keyboardFocusNode = FocusNode();
  bool _hasContent = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_handleTextChange);
  }

  void _handleTextChange() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _hasContent) {
      setState(() {
        _hasContent = hasText;
      });
    }
  }

  @override
  void didUpdateWidget(ChatInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != null && widget.controller != _controller) {
      _controller.removeListener(_handleTextChange);
      _controller = widget.controller!;
      _controller.addListener(_handleTextChange);
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_handleTextChange);
    }
    _focusNode.dispose();
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.isBusy) return;
    _controller.clear();
    widget.onSend(text);
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardBg = isDark ? const Color(0xFF181B19) : const Color(0xFFFAF7F0);
    final buttonBg = isDark ? const Color(0xFF222624) : Colors.white;
    final buttonBorder = isDark ? Colors.white.withValues(alpha: 0.12) : const Color(0x35DFCDBC);
    final textPrimary = isDark ? const Color(0xFFF7F4EE) : const Color(0xFF14261A);
    final textMuted = isDark ? const Color(0xFF7E827E) : const Color(0xFF767B76);
    final emeraldAccent = isDark ? const Color(0xFF8BB596) : const Color(0xFF172C1E);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
      color: Colors.transparent,
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            // 1. Luxury Champagne Gold & Emerald Sage Gradient Border Wrapper
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: LinearGradient(
                  colors: isDark
                      ? const [
                          Color(0xFF3F6649), // Deep Emerald
                          Color(0xFF10B981), // Luminous Mint
                          Color(0xFFD4AF37), // Champagne Gold
                          Color(0xFF8BB596), // Mint Sage
                          Color(0xFF3F6649),
                        ]
                      : const [
                          Color(0xFFA6D4B0), // Soft Mint
                          Color(0xFFD4AF37), // Champagne Gold
                          Color(0xFF8BB596), // Sage
                          Color(0xFF2E6F45), // Deep Emerald
                          Color(0xFFA6D4B0),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black.withValues(alpha: 0.35) : const Color(0xFF172C1E).withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(2.0), // Gradient border thickness
              // 2. Interior Warm Card
              child: Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(28),
                ),
                padding: const EdgeInsets.fromLTRB(16, 12, 12, 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // A. Text Field Area
                    KeyboardListener(
                      focusNode: _keyboardFocusNode,
                      onKeyEvent: (KeyEvent event) {
                        if (event is KeyDownEvent &&
                            event.logicalKey == LogicalKeyboardKey.enter &&
                            !HardwareKeyboard.instance.isShiftPressed) {
                          _handleSend();
                        }
                      },
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        minLines: 1,
                        maxLines: 4,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _handleSend(),
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 15.5,
                          height: 1.4,
                          letterSpacing: -0.2,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Ask me anything...',
                          hintStyle: TextStyle(
                            color: textMuted,
                            fontSize: 15.5,
                            fontWeight: FontWeight.w400,
                            letterSpacing: -0.2,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 4),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // B. Action Bar: Attachment Button + Voice Button + Send Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Attachment Button (🔗)
                        InkWell(
                          onTap: widget.onAttachTap ?? () {},
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: buttonBg,
                              border: Border.all(
                                color: buttonBorder,
                                width: 1.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isDark ? Colors.black.withValues(alpha: 0.2) : const Color(0xFF735C4A).withValues(alpha: 0.04),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                Icons.all_inclusive_rounded,
                                size: 18,
                                color: isDark ? const Color(0xFFACAFAB) : const Color(0xFF172C1E),
                              ),
                            ),
                          ),
                        ),

                        // Right Controls: [ ✦ Voice ] and [ ✈ Send ]
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // [ ✦ Voice ] Pill Button
                            InkWell(
                              onTap: widget.onVoiceTap ??
                                  () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Listening to voice input...'),
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  },
                              borderRadius: BorderRadius.circular(18),
                              child: Container(
                                height: 36,
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                decoration: BoxDecoration(
                                  color: buttonBg,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: buttonBorder,
                                    width: 1.0,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isDark ? Colors.black.withValues(alpha: 0.2) : const Color(0xFF735C4A).withValues(alpha: 0.04),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.auto_awesome_rounded,
                                      size: 15,
                                      color: emeraldAccent,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Voice',
                                      style: TextStyle(
                                        color: textPrimary,
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: -0.1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(width: 8),

                            // [ ✈ Send ] Deep Forest Emerald Button
                            InkWell(
                              onTap: _handleSend,
                              borderRadius: BorderRadius.circular(18),
                              child: Container(
                                height: 36,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: isDark
                                        ? const [
                                            Color(0xFF2D4D36), // Deep Forest Green
                                            Color(0xFF1B3824),
                                          ]
                                        : const [
                                            Color(0xFF172C1E), // Forest Emerald
                                            Color(0xFF2A5338),
                                          ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    widget.isBusy
                                        ? const SizedBox(
                                            width: 14,
                                            height: 14,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          )
                                        : const Icon(
                                            Icons.send_rounded,
                                            size: 15,
                                            color: Colors.white,
                                          ),
                                    const SizedBox(width: 6),
                                    const Text(
                                      'Send',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -0.1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
