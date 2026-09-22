import 'dart:async';
import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../models/chat_session.dart';
import '../theme/app_theme.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input.dart';
import '../widgets/chat_sidebar.dart';

/// Warm Editorial Cream & Forest Emerald Theme (Matching Starting Page):
/// - Warm Editorial Cream canvas (light) / Deep Forest Obsidian canvas (dark)
/// - Subtle travertine diamond lattice grid
/// - Top bar with circular menu / close button, 3D Emerald "P" logo, and theme toggle
/// - Two-tone Forest Emerald & Forest Charcoal bold headline
/// - 3D emerald crystal soap bubble with microphone & floor reflection
/// - Quick filter pills: [ Docs ], [ Images ], [ Sheets ], [ Code ]
/// - Emerald editorial gradient border input with [ ✦ Voice ] & [ ✈ Send ]
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final List<ChatSession> _sessions = [];
  late String _activeSessionId;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _inputController = TextEditingController();
  bool _isGenerating = false;

  final List<String> _models = ['Smart', 'PocketLLM Nano', 'Flash Extended', 'PocketLLM Pro'];
  final int _selectedModelIndex = 0;

  // Selected filter pill
  String _selectedFilter = 'Docs';

  final List<Map<String, dynamic>> _filterSources = [
    {'name': 'Docs', 'icon': Icons.description_outlined},
    {'name': 'Images', 'icon': Icons.image_outlined},
    {'name': 'Sheets', 'icon': Icons.table_chart_outlined},
    {'name': 'Code', 'icon': Icons.code_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _initDefaultSessions();
  }

  void _initDefaultSessions() {
    final now = DateTime.now();
    final defaultSession = ChatSession(
      id: 'session_1',
      title: 'New Chat',
      messages: [],
      lastModified: now,
    );

    final pastSession1 = ChatSession(
      id: 'session_2',
      title: 'Voice Assistant Features',
      messages: [
        ChatMessage(
          id: 'msg_2_1',
          text: 'Hi, can you help me?',
          isUser: true,
          timestamp: now.subtract(const Duration(hours: 1)),
        ),
        ChatMessage(
          id: 'msg_2_2',
          text: "Hello! 👋 Of course, I'm your AI voice assistant. How can I assist you today?",
          isUser: false,
          timestamp: now.subtract(const Duration(hours: 1, minutes: -1)),
        ),
        ChatMessage(
          id: 'msg_2_3',
          text: 'I want to know about voice features.',
          isUser: true,
          timestamp: now.subtract(const Duration(minutes: 45)),
        ),
        ChatMessage(
          id: 'msg_2_4',
          text: 'Sure! 🎤 With AI Voice Assistance, you can chat hands-free, send messages, and get instant replies.',
          isUser: false,
          timestamp: now.subtract(const Duration(minutes: 44)),
        ),
      ],
      lastModified: now.subtract(const Duration(hours: 1)),
    );

    _sessions.addAll([defaultSession, pastSession1]);
    _activeSessionId = defaultSession.id;
  }

  ChatSession get _activeSession {
    return _sessions.firstWhere(
      (s) => s.id == _activeSessionId,
      orElse: () => _sessions.first,
    );
  }

  bool get _isEmptyChat => _activeSession.messages.isEmpty;

  void _selectSession(String id) {
    setState(() {
      _activeSessionId = id;
    });
    _scrollToBottom();
  }

  void _startNewChat() {
    final newId = 'session_${DateTime.now().millisecondsSinceEpoch}';
    final newSession = ChatSession(
      id: newId,
      title: 'New Chat',
      messages: [],
      lastModified: DateTime.now(),
    );

    setState(() {
      _sessions.insert(0, newSession);
      _activeSessionId = newId;
    });
  }

  void _clearCurrentChat() {
    setState(() {
      _activeSession.messages.clear();
      _activeSession.title = 'New Chat';
    });
  }

  void _deleteSession(String id) {
    if (_sessions.length <= 1) return;
    setState(() {
      final index = _sessions.indexWhere((s) => s.id == id);
      _sessions.removeWhere((s) => s.id == id);
      if (_activeSessionId == id) {
        final newIndex = index >= _sessions.length ? _sessions.length - 1 : index;
        _activeSessionId = _sessions[newIndex].id;
      }
    });
  }

  void _handleSendMessage(String text) {
    final userMsg = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    final session = _activeSession;

    setState(() {
      session.messages.add(userMsg);
      session.lastModified = DateTime.now();
      if (session.title == 'New Chat' || session.title.isEmpty) {
        session.title = text.length > 28 ? '${text.substring(0, 28)}...' : text;
      }
      if (_sessions.indexOf(session) > 0) {
        _sessions.remove(session);
        _sessions.insert(0, session);
      }
      _isGenerating = true;
    });

    _scrollToBottom();

    Timer(const Duration(milliseconds: 1000), () {
      if (!mounted) return;

      String reply;
      final query = text.toLowerCase();
      if (query.contains('voice')) {
        reply = 'Sure! 🎤 With AI Voice Assistance, you can chat hands-free, send messages, and get instant replies.';
      } else if (query.contains('image')) {
        reply = 'I can generate high-fidelity images, diagrams, and visual concept art directly from your prompts.';
      } else if (query.contains('help')) {
        reply = "Hello! 👋 Of course, I'm your AI voice assistant. How can I assist you today?";
      } else {
        reply = "I'm ready to assist you with documents, images, sheets, and code analysis.";
      }

      final aiMsg = ChatMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        text: reply,
        isUser: false,
        timestamp: DateTime.now(),
      );

      setState(() {
        session.messages.add(aiMsg);
        session.lastModified = DateTime.now();
        _isGenerating = false;
      });

      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? const Color(0xFF101211) : const Color(0xFFF7F4EE);
    final drawerBg = isDark ? const Color(0xFF101211) : const Color(0xFFFAF7F0);

    final sidebarWidget = ChatSidebar(
      sessions: _sessions,
      activeSessionId: _activeSessionId,
      onSelectSession: (id) {
        _selectSession(id);
        Navigator.of(context).pop();
      },
      onNewChat: () {
        _startNewChat();
        Navigator.of(context).pop();
      },
      onDeleteSession: _deleteSession,
      onBackToLanding: () {
        Navigator.of(context).pop();
        Navigator.pushReplacementNamed(context, '/');
      },
    );

    return Scaffold(
      backgroundColor: scaffoldBg,
      drawer: Drawer(
        width: 310,
        backgroundColor: drawerBg,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
        ),
        child: sidebarWidget,
      ),
      body: Stack(
        children: [
          // 1. Subtle Diamond Lattice Background Pattern (Travertine / Forest Lattice)
          Positioned.fill(
            child: CustomPaint(
              painter: _DiamondGridPainter(isDark: isDark),
            ),
          ),

          // 2. Main Foreground Layout
          SafeArea(
            child: Column(
              children: [
                // Top Bar with theme toggle
                _buildTopBar(context, isDark),

                // Main Content: Empty Assistant State OR Active Chat Stream
                Expanded(
                  child: _isEmptyChat
                      ? _buildEmptyState(context, isDark)
                      : _buildChatList(context),
                ),

                // Filter Pills brought down close to chat box
                if (_isEmptyChat)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: _buildFilterPills(isDark),
                  ),

                // Emerald Editorial Border Bottom Chat Input
                ChatInput(
                  controller: _inputController,
                  onSend: _handleSendMessage,
                  isBusy: _isGenerating,
                  selectedModel: _models[_selectedModelIndex],
                  onVoiceTap: () {
                    _inputController.text = 'I want to know about voice features.';
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 1. Top Navigation Bar ---
  Widget _buildTopBar(BuildContext context, bool isDark) {
    final buttonBg = isDark ? const Color(0xFF181B19) : const Color(0xFFFAF7F0);
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.12) : const Color(0x35DFCDBC);
    final iconColor = isDark ? const Color(0xFFF7F4EE) : const Color(0xFF14261A);
    final emeraldAccent = isDark ? const Color(0xFF8BB596) : const Color(0xFF172C1E);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: Circular Button (Hamburger Menu in empty state, Close '✕' in active chat)
          Builder(
            builder: (ctx) => InkWell(
              onTap: () {
                if (_isEmptyChat) {
                  Scaffold.of(ctx).openDrawer();
                } else {
                  _clearCurrentChat();
                }
              },
              borderRadius: BorderRadius.circular(22),
              child: Tooltip(
                message: _isEmptyChat ? 'Open menu' : 'Close chat',
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: buttonBg,
                        border: Border.all(
                          color: borderColor,
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark ? Colors.black.withValues(alpha: 0.35) : const Color(0xFF735C4A).withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          _isEmptyChat ? Icons.menu_rounded : Icons.close_rounded,
                          size: 20,
                          color: iconColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Center: 3D PocketLLM Emerald & Platinum "P" Logo Icon
          Image.asset(
            'assets/images/pocketllm_logo.png',
            width: 38,
            height: 38,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Text(
              'PocketLLM',
              style: TextStyle(
                color: iconColor,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          // Right: Theme Toggle Button + Chat History Button
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Theme Toggle Button (☀️ / 🌙)
              InkWell(
                onTap: () => themeController.toggleTheme(),
                borderRadius: BorderRadius.circular(22),
                child: Tooltip(
                  message: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: Center(
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: buttonBg,
                          border: Border.all(
                            color: borderColor,
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isDark ? Colors.black.withValues(alpha: 0.35) : const Color(0xFF735C4A).withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                              key: ValueKey<bool>(isDark),
                              size: 19,
                              color: isDark ? const Color(0xFFD4AF37) : emeraldAccent,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Active Chat History Button
              if (!_isEmptyChat) ...[
                const SizedBox(width: 4),
                Builder(
                  builder: (ctx) => InkWell(
                    onTap: () => Scaffold.of(ctx).openDrawer(),
                    borderRadius: BorderRadius.circular(22),
                    child: Tooltip(
                      message: 'Chat History',
                      child: SizedBox(
                        width: 44,
                        height: 44,
                        child: Center(
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: buttonBg,
                              border: Border.all(
                                color: borderColor,
                                width: 1.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isDark ? Colors.black.withValues(alpha: 0.35) : const Color(0xFF735C4A).withValues(alpha: 0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                Icons.history_rounded,
                                size: 20,
                                color: iconColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // --- 2. Empty State (Student AI Assistant: Graduation Badge, Italic Headline & 4 Study Cards) ---
  Widget _buildEmptyState(BuildContext context, bool isDark) {
    final emeraldAccent = isDark ? const Color(0xFF8BB596) : const Color(0xFF172C1E);
    final textPrimary = isDark ? const Color(0xFFF7F4EE) : const Color(0xFF14261A);
    final textMuted = isDark ? const Color(0xFF8E928E) : const Color(0xFF6E736E);

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: availableHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // A. Graduation Cap Badge
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark
                            ? const Color(0xFF1E2620)
                            : const Color(0xFFE8F0EA),
                        border: Border.all(
                          color: emeraldAccent.withValues(alpha: isDark ? 0.35 : 0.22),
                          width: 1.2,
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
                      child: Center(
                        child: Icon(
                          Icons.school_rounded,
                          size: 25,
                          color: emeraldAccent,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // B. Main Headline with Editorial Italic Styling
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: availableHeight < 580 ? 22 : 25,
                          height: 1.22,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                          letterSpacing: -0.4,
                        ),
                        children: [
                          const TextSpan(text: 'How can '),
                          TextSpan(
                            text: 'PocketLLM',
                            style: TextStyle(
                              fontFamily: 'serif',
                              fontStyle: FontStyle.italic,
                              color: emeraldAccent,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const TextSpan(text: ' assist\nyour '),
                          TextSpan(
                            text: 'studies',
                            style: TextStyle(
                              fontFamily: 'serif',
                              fontStyle: FontStyle.italic,
                              color: emeraldAccent,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const TextSpan(text: ' today?'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // C. Subtitle
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 320),
                      child: Text(
                        'Private on-device intelligence for notes, writing, coding & problem solving.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.4,
                          fontWeight: FontWeight.w400,
                          color: textMuted,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // D. 2x2 Grid of Student Study Cards
                    _buildStudyCards(isDark, emeraldAccent, textPrimary, textMuted),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }

  // --- 2x2 Study Prompt Cards ---
  Widget _buildStudyCards(
    bool isDark,
    Color emeraldAccent,
    Color textPrimary,
    Color textMuted,
  ) {
    final cardBg = isDark ? const Color(0xFF161917) : const Color(0xFFFAF7F0);
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.10) : const Color(0x35DFCDBC);
    final iconBg = isDark ? const Color(0xFF223026) : const Color(0xFFE8F0EA);

    final cards = [
      (
        icon: Icons.article_outlined,
        title: 'Summarize Notes',
        desc: 'Extract key concepts & exam takeaways',
        prompt: 'Summarize my notes and extract key concepts & exam takeaways:',
      ),
      (
        icon: Icons.edit_note_rounded,
        title: 'Draft Essays & Papers',
        desc: 'Outlines, thesis statements & references',
        prompt: 'Help me outline and draft an academic essay on:',
      ),
      (
        icon: Icons.terminal_rounded,
        title: 'Solve & Code',
        desc: 'Step-by-step logic, math & algorithms',
        prompt: 'Solve this step-by-step and write clean code:',
      ),
      (
        icon: Icons.lightbulb_outline_rounded,
        title: 'Explore Concepts',
        desc: 'Deep dive topics with intuition',
        prompt: 'Explain this concept in-depth with intuitive analogies:',
      ),
    ];

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 440),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildSingleStudyCard(cards[0], isDark, cardBg, borderColor, iconBg, emeraldAccent, textPrimary, textMuted)),
              const SizedBox(width: 10),
              Expanded(child: _buildSingleStudyCard(cards[1], isDark, cardBg, borderColor, iconBg, emeraldAccent, textPrimary, textMuted)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildSingleStudyCard(cards[2], isDark, cardBg, borderColor, iconBg, emeraldAccent, textPrimary, textMuted)),
              const SizedBox(width: 10),
              Expanded(child: _buildSingleStudyCard(cards[3], isDark, cardBg, borderColor, iconBg, emeraldAccent, textPrimary, textMuted)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSingleStudyCard(
    ({IconData icon, String title, String desc, String prompt}) item,
    bool isDark,
    Color cardBg,
    Color borderColor,
    Color iconBg,
    Color emeraldAccent,
    Color textPrimary,
    Color textMuted,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _inputController.text = item.prompt;
          _inputController.selection = TextSelection.fromPosition(
            TextPosition(offset: _inputController.text.length),
          );
        },
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor, width: 1.0),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.25)
                    : const Color(0xFF735C4A).withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: iconBg,
                  border: Border.all(
                    color: emeraldAccent.withValues(alpha: isDark ? 0.25 : 0.15),
                    width: 0.8,
                  ),
                ),
                child: Center(
                  child: Icon(
                    item.icon,
                    size: 17,
                    color: emeraldAccent,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Text(
                item.desc,
                style: TextStyle(
                  fontSize: 10.5,
                  height: 1.3,
                  fontWeight: FontWeight.w400,
                  color: textMuted,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Filter Pills: Docs, Images, Sheets, Code ---
  Widget _buildFilterPills(bool isDark) {
    final pillBg = isDark ? const Color(0xFF181B19) : const Color(0xFFFAF7F0);
    final pillBorder = isDark ? Colors.white.withValues(alpha: 0.12) : const Color(0x35DFCDBC);
    final emeraldAccent = isDark ? const Color(0xFF8BB596) : const Color(0xFF172C1E);
    final textIdle = isDark ? const Color(0xFFF7F4EE) : const Color(0xFF14261A);
    final iconIdle = isDark ? const Color(0xFFACAFAB) : const Color(0xFF5A605A);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _filterSources.map((source) {
          final name = source['name'] as String;
          final icon = source['icon'] as IconData;
          final isSelected = _selectedFilter == name;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedFilter = name;
                });
                _inputController.text = 'Help me analyze $name';
              },
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 44,
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 13),
                    decoration: BoxDecoration(
                      color: isSelected && !isDark
                          ? const Color(0xFFEBF4EE)
                          : pillBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? emeraldAccent : pillBorder,
                        width: isSelected ? 1.4 : 0.8,
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          icon,
                          size: 15,
                          color: isSelected ? emeraldAccent : iconIdle,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          name,
                          style: TextStyle(
                            color: isSelected ? emeraldAccent : textIdle,
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // --- 3. Active Chat Stream ---
  Widget _buildChatList(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: _activeSession.messages.length + (_isGenerating ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < _activeSession.messages.length) {
          return ChatBubble(message: _activeSession.messages[index]);
        }
        return const PocketLLMThinkingIndicator();
      },
    );
  }
}

/// Custom painter to render the subtle isometric diamond lattice grid from the starting page
class _DiamondGridPainter extends CustomPainter {
  final bool isDark;

  _DiamondGridPainter({this.isDark = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark
          ? const Color(0xFF8BB596).withValues(alpha: 0.05)
          : const Color(0xFFDFCDBC).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;

    const spacing = 32.0;

    // Diagonal lines from top-left to bottom-right
    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }

    // Diagonal lines from top-right to bottom-left
    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i - size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DiamondGridPainter oldDelegate) => oldDelegate.isDark != isDark;
}
