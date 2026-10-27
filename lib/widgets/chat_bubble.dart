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
    final maxBubbleWidth = min(MediaQuery.of(context).size.width * 0.80, 440.0);

    return Padding(
      padding: const EdgeInsets.only(left: 48, right: 16, top: 4, bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (message.attachedFileName != null)
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E3525) : const Color(0xFFE5EFE7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? const Color(0xFF386844) : const Color(0xFF9DC7A6),
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.description_rounded,
                    size: 15,
                    color: isDark ? const Color(0xFF8BB596) : const Color(0xFF172C1E),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      message.attachedFileChunks != null && message.attachedFileChunks! > 0
                          ? '${message.attachedFileName} • ${message.attachedFileChunks} chunks'
                          : message.attachedFileName!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFF8BB596) : const Color(0xFF172C1E),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          Container(
            constraints: BoxConstraints(maxWidth: maxBubbleWidth),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? const [Color(0xFF2D4D36), Color(0xFF1B3824)]
                    : const [Color(0xFF172C1E), Color(0xFF2A5338)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(6),
              ),
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
                fontSize: 15,
                height: 1.48,
                letterSpacing: -0.15,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Text(
              timeStr,
              style: TextStyle(
                color: isDark ? const Color(0xFF8E928E) : const Color(0xFF6E736E),
                fontSize: 11,
                fontWeight: FontWeight.w500,
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
    final maxBubbleWidth = min(MediaQuery.of(context).size.width * 0.84, 480.0);

    final cardBg = isDark ? const Color(0xFF181B19) : Colors.white;
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0x35DFCDBC);
    final textPrimary = isDark ? const Color(0xFFF7F4EE) : const Color(0xFF14261A);
    final textMuted = isDark ? const Color(0xFF8E928E) : const Color(0xFF6E736E);
    final emeraldAccent = isDark ? const Color(0xFF8BB596) : const Color(0xFF172C1E);

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 36, top: 6, bottom: 8),
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

                if (message.sources != null && message.sources!.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: emeraldAccent.withValues(alpha: isDark ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: emeraldAccent.withValues(alpha: isDark ? 0.35 : 0.25),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_stories, size: 13, color: emeraldAccent),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            'Grounded in: ${message.sources!.join(", ")}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: emeraldAccent,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                if (message.text.isNotEmpty)
                  Container(
                    constraints: BoxConstraints(maxWidth: maxBubbleWidth),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(6),
                        topRight: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
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
                    child: TextbookFormattedText(
                      text: message.text,
                      textPrimary: textPrimary,
                      emeraldAccent: emeraldAccent,
                      isDark: isDark,
                    ),
                  ),

                const SizedBox(height: 2),

                // Action Row underneath AI Message: Timestamp + Comfortable Touch Action Icons
                Padding(
                  padding: const EdgeInsets.only(left: 4, right: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        timeStr,
                        style: TextStyle(
                          color: textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _actionIconButton(
                            context,
                            Icons.content_copy_rounded,
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
                          _actionIconButton(
                            context,
                            Icons.thumb_up_outlined,
                            'Good response',
                            () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Feedback saved'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            textMuted,
                          ),
                          _actionIconButton(
                            context,
                            Icons.volume_up_outlined,
                            'Read aloud',
                            () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Reading aloud...'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
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

  Widget _actionIconButton(
    BuildContext context,
    IconData icon,
    String tooltip,
    VoidCallback onTap,
    Color iconColor,
  ) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          width: 38,
          height: 38,
          child: Center(
            child: Icon(
              icon,
              size: 16,
              color: iconColor,
            ),
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
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
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

/// Textbook & Math Formatter: converts LaTeX math \[ ... \], inline math \( ... \),
/// Greek symbols, fractions, superscripts/subscripts, and markdown into clean textbook styling.
class TextbookFormattedText extends StatelessWidget {
  final String text;
  final Color textPrimary;
  final Color emeraldAccent;
  final bool isDark;

  const TextbookFormattedText({
    super.key,
    required this.text,
    required this.textPrimary,
    required this.emeraldAccent,
    required this.isDark,
  });

  static String cleanMath(String raw) {
    String s = raw.trim();

    if (s.startsWith(r'\[') && s.endsWith(r'\]')) {
      s = s.substring(2, s.length - 2).trim();
    } else if (s.startsWith(r'\(') && s.endsWith(r'\)')) {
      s = s.substring(2, s.length - 2).trim();
    } else if (s.startsWith(r'$$') && s.endsWith(r'$$')) {
      s = s.substring(2, s.length - 2).trim();
    } else if (s.startsWith(r'$') && s.endsWith(r'$') && s.length >= 2) {
      s = s.substring(1, s.length - 1).trim();
    }

    const greekMap = {
      r'\alpha': 'α',
      r'\beta': 'β',
      r'\gamma': 'γ',
      r'\Delta': 'Δ',
      r'\delta': 'δ',
      r'\epsilon': 'ε',
      r'\zeta': 'ζ',
      r'\eta': 'η',
      r'\theta': 'θ',
      r'\iota': 'ι',
      r'\kappa': 'κ',
      r'\lambda': 'λ',
      r'\mu': 'μ',
      r'\nu': 'ν',
      r'\xi': 'ξ',
      r'\pi': 'π',
      r'\rho': 'ρ',
      r'\sigma': 'σ',
      r'\tau': 'τ',
      r'\phi': 'φ',
      r'\chi': 'χ',
      r'\psi': 'ψ',
      r'\omega': 'ω',
      r'\Omega': 'Ω',
    };
    greekMap.forEach((k, v) {
      s = s.replaceAll(k, v);
    });

    const symbolMap = {
      r'\times': '×',
      r'\cdot': '·',
      r'\div': '÷',
      r'\pm': '±',
      r'\mp': '∓',
      r'\approx': '≈',
      r'\neq': '≠',
      r'\leq': '≤',
      r'\geq': '≥',
      r'\infty': '∞',
      r'\to': '→',
      r'\rightarrow': '→',
      r'\leftarrow': '←',
      r'\leftrightarrow': '↔',
      r'\degree': '°',
      r'^\circ': '°',
    };
    symbolMap.forEach((k, v) {
      s = s.replaceAll(k, v);
    });

    s = s.replaceAllMapped(RegExp(r'\\(text|mathrm|mathbf)\{([^{}]+)\}'), (m) => m.group(2) ?? '');

    // \frac{a}{b} -> a / b
    s = s.replaceAllMapped(RegExp(r'\\frac\{([^{}]+)\}\{([^{}]+)\}'), (m) {
      final num = m.group(1)?.trim() ?? '';
      final den = m.group(2)?.trim() ?? '';
      final cleanNum = (num.length <= 3 && !num.contains(' ')) ? num : '($num)';
      final cleanDen = (den.length <= 3 && !den.contains(' ')) ? den : '($den)';
      return '$cleanNum / $cleanDen';
    });

    // \sqrt[n]{x} and \sqrt{x}
    s = s.replaceAllMapped(RegExp(r'\\sqrt\[([0-9])\]\{([^{}]+)\}'), (m) {
      final n = m.group(1) ?? '';
      final x = m.group(2) ?? '';
      return '${_toSuperscript(n)}√($x)';
    });
    s = s.replaceAllMapped(RegExp(r'\\sqrt\{([^{}]+)\}'), (m) => '√(${m.group(1)})');

    // Superscripts
    s = s.replaceAllMapped(RegExp(r'\^\{([0-9a-zA-Z\+\-]+)\}'), (m) => _toSuperscript(m.group(1) ?? ''));
    s = s.replaceAllMapped(RegExp(r'\^([0-9n\+\-])'), (m) => _toSuperscript(m.group(1) ?? ''));

    // Subscripts
    s = s.replaceAllMapped(RegExp(r'_\{([0-9a-zA-Z]+)\}'), (m) => _toSubscript(m.group(1) ?? ''));
    s = s.replaceAllMapped(RegExp(r'_([0-9])'), (m) => _toSubscript(m.group(1) ?? ''));

    // Solitary backslash cleanup
    s = s.replaceAllMapped(RegExp(r'\\([a-zA-Z]+)'), (m) => m.group(1) ?? '');

    return s;
  }

  static String _toSuperscript(String str) {
    const map = {
      '0': '⁰', '1': '¹', '2': '²', '3': '³', '4': '⁴',
      '5': '⁵', '6': '⁶', '7': '⁷', '8': '⁸', '9': '⁹',
      '+': '⁺', '-': '⁻', '=': '⁼', '(': '⁽', ')': '⁾',
      'n': 'ⁿ', 'i': 'ⁱ', 'x': 'ˣ', 'y': 'ʸ',
    };
    return str.split('').map((c) => map[c] ?? c).join('');
  }

  static String _toSubscript(String str) {
    const map = {
      '0': '₀', '1': '₁', '2': '₂', '3': '₃', '4': '₄',
      '5': '₅', '6': '₆', '7': '₇', '8': '₈', '9': '₉',
      '+': '₊', '-': '₋', '=': '₌', '(': '₍', ')': '₎',
      'a': 'ₐ', 'e': 'ₑ', 'o': 'ₒ', 'x': 'ₓ', 'h': 'ₕ',
      'k': 'ₖ', 'l': 'ₗ', 'm': 'ₘ', 'n': 'ₙ', 'p': 'ₚ',
      's': 'ₛ', 't': 'ₜ',
    };
    return str.split('').map((c) => map[c] ?? c).join('');
  }

  List<TextSpan> _parseInlineSpans(String line) {
    final spans = <TextSpan>[];
    final tokenRegex = RegExp(r'(\*\*[^*]+\*\*|`[^`]+`|\\\(.*?\\\)|\$[^\$\n]+\$)');
    int lastEnd = 0;

    for (final match in tokenRegex.allMatches(line)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: line.substring(lastEnd, match.start)));
      }

      final rawToken = match.group(0)!;
      if (rawToken.startsWith('**') && rawToken.endsWith('**') && rawToken.length >= 4) {
        spans.add(
          TextSpan(
            text: rawToken.substring(2, rawToken.length - 2),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        );
      } else if (rawToken.startsWith('`') && rawToken.endsWith('`') && rawToken.length >= 2) {
        spans.add(
          TextSpan(
            text: rawToken.substring(1, rawToken.length - 1),
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 13.5,
              backgroundColor: isDark
                  ? const Color(0xFF26332A)
                  : const Color(0xFFE4ECE6),
              color: isDark ? const Color(0xFF98CBA3) : const Color(0xFF1B4D2B),
            ),
          ),
        );
      } else if (rawToken.startsWith(r'\(') && rawToken.endsWith(r'\)')) {
        spans.add(
          TextSpan(
            text: cleanMath(rawToken),
            style: TextStyle(
              fontFamily: 'serif',
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFA5D6AF) : const Color(0xFF144D25),
            ),
          ),
        );
      } else if (rawToken.startsWith(r'$') && rawToken.endsWith(r'$') && rawToken.length >= 2) {
        spans.add(
          TextSpan(
            text: cleanMath(rawToken),
            style: TextStyle(
              fontFamily: 'serif',
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFA5D6AF) : const Color(0xFF144D25),
            ),
          ),
        );
      } else {
        spans.add(TextSpan(text: rawToken));
      }

      lastEnd = match.end;
    }

    if (lastEnd < line.length) {
      spans.add(TextSpan(text: line.substring(lastEnd)));
    }

    return spans;
  }

  Widget _buildProse(String content) {
    final lines = content.split('\n');
    final children = <Widget>[];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.trim().isEmpty) {
        if (i < lines.length - 1) {
          children.add(const SizedBox(height: 5));
        }
        continue;
      }

      final isBullet = line.trimLeft().startsWith('- ') || line.trimLeft().startsWith('* ');
      final cleanLine = isBullet ? line.trimLeft().substring(2) : line;

      final spans = _parseInlineSpans(cleanLine);

      if (isBullet) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8, right: 8),
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: emeraldAccent,
                  ),
                ),
                Expanded(
                  child: SelectableText.rich(
                    TextSpan(children: spans),
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 15,
                      height: 1.48,
                      letterSpacing: -0.1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: SelectableText.rich(
              TextSpan(children: spans),
              style: TextStyle(
                color: textPrimary,
                fontSize: 15,
                height: 1.48,
                letterSpacing: -0.1,
              ),
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _buildFormulaCard(String formula) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF132218) : const Color(0xFFF0F6F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: emeraldAccent.withValues(alpha: isDark ? 0.35 : 0.25),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.functions_rounded, size: 14, color: emeraldAccent),
              const SizedBox(width: 5),
              Text(
                'FORMULA',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: emeraldAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SelectableText(
            cleanMath(formula),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textPrimary,
              fontSize: 16.5,
              fontWeight: FontWeight.w600,
              fontFamily: 'serif',
              letterSpacing: 0.5,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayMathRegex = RegExp(r'(\\\[[\s\S]*?\\\]|\$\$[\s\S]*?\$\$)');
    final matches = displayMathRegex.allMatches(text).toList();

    if (matches.isEmpty) {
      return _buildProse(text);
    }

    final widgets = <Widget>[];
    int lastEnd = 0;

    for (final match in matches) {
      if (match.start > lastEnd) {
        final prose = text.substring(lastEnd, match.start);
        if (prose.trim().isNotEmpty) {
          widgets.add(_buildProse(prose));
        }
      }

      widgets.add(_buildFormulaCard(match.group(0)!));
      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      final prose = text.substring(lastEnd);
      if (prose.trim().isNotEmpty) {
        widgets.add(_buildProse(prose));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
}
