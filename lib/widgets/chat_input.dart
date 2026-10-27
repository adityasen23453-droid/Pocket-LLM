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
  final VoidCallback? onStop;
  final VoidCallback? onAttachTap;
  final VoidCallback? onVoiceTap;
  final TextEditingController? controller;
  final String hintText;
  final String? stagedFileName;
  final int? stagedFileChunks;
  final VoidCallback? onRemoveStagedFile;

  const ChatInput({
    super.key,
    required this.onSend,
    this.isBusy = false,
    this.selectedModel = 'Smart',
    this.onModelTap,
    this.onStop,
    this.onAttachTap,
    this.onVoiceTap,
    this.controller,
    this.hintText = 'Ask me anything...',
    this.stagedFileName,
    this.stagedFileChunks,
    this.onRemoveStagedFile,
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
                    if (widget.stagedFileName != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E2822) : const Color(0xFFEAF4ED),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? const Color(0xFF8BB596).withValues(alpha: 0.3) : const Color(0xFF2A5338).withValues(alpha: 0.2),
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.description_rounded, size: 16, color: Color(0xFF4CAF50)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${widget.stagedFileName!} • ${widget.stagedFileChunks ?? 0} chunks ready',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? const Color(0xFFF7F4EE) : const Color(0xFF14261A),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (widget.onRemoveStagedFile != null)
                              InkWell(
                                onTap: widget.onRemoveStagedFile,
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Icon(Icons.close_rounded, size: 15, color: textMuted),
                                ),
                              ),
                          ],
                        ),
                      ),
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
                        textCapitalization: TextCapitalization.sentences,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _handleSend(),
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 15,
                          height: 1.45,
                          letterSpacing: -0.15,
                        ),
                        decoration: InputDecoration(
                          hintText: widget.hintText,
                          hintStyle: TextStyle(
                            color: textMuted,
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            letterSpacing: -0.15,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 4),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // B. Action Bar: Attachment (+) + Voice (🎤) + Primary Send (✈)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Tool / Attachment Action (Standard + with 44dp touch target)
                        Tooltip(
                          message: 'Add attachment or tools',
                          child: InkWell(
                            onTap: widget.onAttachTap ??
                                () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Attachments and tools coming soon'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                },
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
                                    color: buttonBg,
                                    border: Border.all(
                                      color: buttonBorder,
                                      width: 1.0,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isDark
                                            ? Colors.black.withValues(alpha: 0.2)
                                            : const Color(0xFF735C4A).withValues(alpha: 0.04),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.add_rounded,
                                    size: 20,
                                    color: isDark ? const Color(0xFFACAFAB) : const Color(0xFF424742),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Right Actions: [ 🎤 Voice ] and [ ✈ Send ]
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // [ 🎤 Voice ] Tactile Button with 44dp touch target
                            Tooltip(
                              message: 'Voice input',
                              child: InkWell(
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
                                child: SizedBox(
                                  height: 44,
                                  child: Center(
                                    child: Container(
                                      height: 36,
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      decoration: BoxDecoration(
                                        color: buttonBg,
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(
                                          color: buttonBorder,
                                          width: 1.0,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: isDark
                                                ? Colors.black.withValues(alpha: 0.2)
                                                : const Color(0xFF735C4A).withValues(alpha: 0.04),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.mic_none_rounded,
                                            size: 17,
                                            color: isDark
                                                ? const Color(0xFFACAFAB)
                                                : const Color(0xFF424742),
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            'Voice',
                                            style: TextStyle(
                                              color: textPrimary,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: -0.1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 8),

                            // [ ⏹ Stop / ✈ Send ] Primary Action
                            widget.isBusy
                                ? Tooltip(
                                    message: 'Stop response',
                                    child: InkWell(
                                      onTap: widget.onStop,
                                      borderRadius: BorderRadius.circular(19),
                                      child: SizedBox(
                                        height: 44,
                                        child: Center(
                                          child: Container(
                                            height: 38,
                                            padding: const EdgeInsets.symmetric(horizontal: 14),
                                            decoration: BoxDecoration(
                                              color: isDark ? const Color(0xFF381E1E) : const Color(0xFFFDE8E8),
                                              borderRadius: BorderRadius.circular(19),
                                              border: Border.all(
                                                color: isDark ? const Color(0xFFEF5350) : const Color(0xFFE53935),
                                                width: 1.2,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 10,
                                                  height: 10,
                                                  decoration: BoxDecoration(
                                                    color: isDark ? const Color(0xFFFF8A80) : const Color(0xFFD32F2F),
                                                    borderRadius: BorderRadius.circular(2),
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  'Stop',
                                                  style: TextStyle(
                                                    color: isDark ? const Color(0xFFFF8A80) : const Color(0xFFD32F2F),
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : Tooltip(
                                    message: 'Send message',
                                    child: AnimatedOpacity(
                                      duration: const Duration(milliseconds: 150),
                                      opacity: _hasContent ? 1.0 : 0.72,
                                      child: InkWell(
                                        onTap: _handleSend,
                                        borderRadius: BorderRadius.circular(19),
                                        child: SizedBox(
                                          height: 44,
                                          child: Center(
                                            child: Container(
                                              height: 38,
                                              padding: const EdgeInsets.symmetric(horizontal: 16),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: isDark
                                                      ? const [
                                                          Color(0xFF2D4D36),
                                                          Color(0xFF1B3824),
                                                        ]
                                                      : const [
                                                          Color(0xFF172C1E),
                                                          Color(0xFF2A5338),
                                                        ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                borderRadius: BorderRadius.circular(19),
                                              ),
                                              child: const Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.arrow_upward_rounded,
                                                    size: 16,
                                                    color: Colors.white,
                                                  ),
                                                  SizedBox(width: 6),
                                                  Text(
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
                                        ),
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
