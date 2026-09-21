import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChatInput extends StatefulWidget {
  final Function(String text) onSend;
  final bool isBusy;

  const ChatInput({
    super.key,
    required this.onSend,
    this.isBusy = false,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final FocusNode _keyboardFocusNode = FocusNode();
  bool _hasContent = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _hasContent) {
        setState(() {
          _hasContent = hasText;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
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

    final containerBg = isDark ? const Color(0xFF19191D) : const Color(0xFFF7F7F9);
    final borderColor = isDark ? const Color(0xFF2E2E36) : const Color(0xFFE2E2E7);
    final hintColor = isDark ? const Color(0xFF888890) : const Color(0xFF8E8E93);
    final textColor = isDark ? Colors.white : Colors.black;
    final sendBtnBg = isDark ? Colors.white : Colors.black;
    final sendBtnFg = isDark ? const Color(0xFF121212) : Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF222227) : const Color(0xFFEEEEF0),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            decoration: BoxDecoration(
              color: containerBg,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: borderColor, width: 1),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: KeyboardListener(
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
                      maxLines: 5,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _handleSend(),
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14.5,
                        height: 1.4,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Message PocketLLM...',
                        hintStyle: TextStyle(
                          color: hintColor,
                          fontSize: 14.5,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _hasContent && !widget.isBusy
                          ? sendBtnBg
                          : (isDark ? const Color(0xFF28282F) : const Color(0xFFE4E4E8)),
                    ),
                    child: IconButton(
                      icon: widget.isBusy
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            )
                          : Icon(
                              Icons.arrow_upward_rounded,
                              size: 19,
                              color: _hasContent && !widget.isBusy
                                  ? sendBtnFg
                                  : (isDark ? const Color(0xFF6E6E78) : const Color(0xFF99999F)),
                            ),
                      onPressed: _hasContent && !widget.isBusy ? _handleSend : null,
                      padding: EdgeInsets.zero,
                      tooltip: 'Send message',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
