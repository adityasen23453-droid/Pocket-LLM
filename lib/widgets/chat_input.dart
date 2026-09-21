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

class _ChatInputState extends State<ChatInput> with SingleTickerProviderStateMixin {
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

    final pillBg = isDark ? const Color(0xFF1E1F24) : const Color(0xFFF0F4F9);
    final hintColor = isDark ? const Color(0xFF8E8E98) : const Color(0xFF70757A);
    final textColor = isDark ? const Color(0xFFE3E3E8) : const Color(0xFF1F1F1F);
    final iconColor = isDark ? const Color(0xFF8E8E98) : const Color(0xFF70757A);

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      color: Colors.transparent,
      child: SafeArea(
        top: false,
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 680),
            decoration: BoxDecoration(
              color: pillBg,
              borderRadius: BorderRadius.circular(28),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // + Button (attachment / image gen)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6, left: 4),
                  child: InkWell(
                    onTap: () => _showAddMenu(context, isDark),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? const Color(0xFF2A2B31) : const Color(0xFFE2E5EA),
                      ),
                      child: Icon(
                        Icons.add,
                        size: 22,
                        color: isDark ? const Color(0xFFBBBBC3) : const Color(0xFF444746),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 4),

                // Text field
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
                        fontSize: 16,
                        height: 1.35,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Ask PocketLLM',
                        hintStyle: TextStyle(
                          color: hintColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 4),

                // Mic icon
                if (!_hasContent)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          Icons.mic_none_rounded,
                          size: 24,
                          color: iconColor,
                        ),
                      ),
                    ),
                  ),

                // Send / Waveform button
                Padding(
                  padding: const EdgeInsets.only(bottom: 6, right: 2),
                  child: _buildActionButton(isDark),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(bool isDark) {
    if (widget.isBusy) {
      return Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Color(0xFF4FC3F7), Color(0xFF7C4DFF), Color(0xFFFF4081)],
          ),
        ),
        child: const Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    if (_hasContent) {
      return InkWell(
        onTap: _handleSend,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? Colors.white : const Color(0xFF1F1F1F),
          ),
          child: Icon(
            Icons.arrow_upward_rounded,
            size: 22,
            color: isDark ? Colors.black : Colors.white,
          ),
        ),
      );
    }

    // Waveform bars button (PocketLLM style) when idle
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFF2952E3), Color(0xFF6D3BF5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: _WaveformIcon(),
      ),
    );
  }

  void _showAddMenu(BuildContext context, bool isDark) {
    final menuBg = isDark ? const Color(0xFF1E1F24) : const Color(0xFFF0F4F9);
    final menuText = isDark ? const Color(0xFFE3E3E8) : const Color(0xFF1F1F1F);
    final menuIcon = isDark ? const Color(0xFF8AB4F8) : const Color(0xFF1A73E8);

    showModalBottomSheet(
      context: context,
      backgroundColor: menuBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF3C3D44) : const Color(0xFFDADCE0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                _menuItem(Icons.auto_awesome_rounded, 'Generate Image', menuIcon, menuText, () {
                  Navigator.pop(ctx);
                  widget.onSend('Generate an image');
                }),
                _menuItem(Icons.photo_library_outlined, 'Add Photo', menuIcon, menuText, () {
                  Navigator.pop(ctx);
                }),
                _menuItem(Icons.attach_file_rounded, 'Add File', menuIcon, menuText, () {
                  Navigator.pop(ctx);
                }),
                _menuItem(Icons.camera_alt_outlined, 'Camera', menuIcon, menuText, () {
                  Navigator.pop(ctx);
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _menuItem(IconData icon, String label, Color iconColor, Color textColor, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: iconColor, size: 24),
      title: Text(
        label,
        style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
    );
  }
}

/// PocketLLM-style waveform icon (ı|ı)
class _WaveformIcon extends StatelessWidget {
  const _WaveformIcon();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _bar(3, 10),
        const SizedBox(width: 2.5),
        _bar(3, 16),
        const SizedBox(width: 2.5),
        _bar(3, 10),
      ],
    );
  }

  Widget _bar(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(1.5),
      ),
    );
  }
}
