import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../models/chat_session.dart';
import '../theme/app_theme.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input.dart';
import '../widgets/chat_sidebar.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final List<ChatSession> _sessions = [];
  late String _activeSessionId;
  final ScrollController _scrollController = ScrollController();
  bool _isGenerating = false;

  // Model selection
  final List<String> _models = ['PocketLLM Nano', 'Flash Extended', 'PocketLLM Pro'];
  int _selectedModelIndex = 0;

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
      title: 'What is PocketLLM?',
      messages: [
        ChatMessage(
          id: 'msg_2_1',
          text: 'What is PocketLLM and how does it work?',
          isUser: true,
          timestamp: now.subtract(const Duration(hours: 3)),
        ),
        ChatMessage(
          id: 'msg_2_2',
          text:
              'PocketLLM is designed to bring powerful AI capabilities directly to your personal devices in an ultra-lightweight, private, and lightning-fast package.',
          isUser: false,
          timestamp: now.subtract(const Duration(hours: 3, minutes: -1)),
        ),
      ],
      lastModified: now.subtract(const Duration(hours: 3)),
    );

    final pastSession2 = ChatSession(
      id: 'session_3',
      title: 'Flutter Architecture Tips',
      messages: [
        ChatMessage(
          id: 'msg_3_1',
          text: 'What are the best practices for clean Flutter architecture?',
          isUser: true,
          timestamp: now.subtract(const Duration(days: 1)),
        ),
        ChatMessage(
          id: 'msg_3_2',
          text:
              '1. Separate UI, business logic, and data layers.\n2. Leverage reactive state management.\n3. Implement explicit themes and reusable design tokens.',
          isUser: false,
          timestamp: now.subtract(const Duration(days: 1, minutes: -2)),
        ),
      ],
      lastModified: now.subtract(const Duration(days: 1)),
    );

    _sessions.addAll([defaultSession, pastSession1, pastSession2]);
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

    // Simulate AI response
    Timer(const Duration(milliseconds: 800), () {
      if (!mounted) return;

      final isImageRequest = _isImagePrompt(text);
      final aiResponseText = _generateMockResponse(text);

      final aiMsg = ChatMessage(
        id: 'msg_ai_${DateTime.now().millisecondsSinceEpoch}',
        text: aiResponseText,
        isUser: false,
        timestamp: DateTime.now(),
        isImageGeneration: isImageRequest,
        imageUrl: isImageRequest ? 'assets/images/vibrant_infinity_logo.png' : null,
      );

      setState(() {
        session.messages.add(aiMsg);
        session.lastModified = DateTime.now();
        _isGenerating = false;
      });

      _scrollToBottom();
    });
  }

  bool _isImagePrompt(String text) {
    final lower = text.toLowerCase();
    return lower.contains('generate image') ||
        lower.contains('draw') ||
        lower.contains('create image') ||
        lower.contains('make image') ||
        lower.contains('picture of');
  }

  String _generateMockResponse(String userPrompt) {
    final lower = userPrompt.toLowerCase();
    if (_isImagePrompt(userPrompt)) {
      return 'Here\'s what I generated based on your prompt: "$userPrompt"';
    }
    if (lower.contains('hello') || lower.contains('hi')) {
      return 'Hello! How can I assist you with your project or questions today?';
    } else if (lower.contains('who are you') || lower.contains('what is pocketllm')) {
      return 'I am PocketLLM, an on-device, lightweight AI assistant designed to provide instant answers with complete privacy and zero clutter.';
    } else if (lower.contains('theme')) {
      return 'PocketLLM features a modern PocketLLM-inspired design with deep OLED blacks, ambient blue gradients, and vibrant accent colors. You can toggle between dark and light themes.';
    } else {
      return 'Thanks for your message! PocketLLM is ready to help you summarize, code, brainstorm, and answer questions with precision.\n\nYou asked: "$userPrompt"';
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showModelSelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1E1F24) : const Color(0xFFF0F4F9);
    final textPrimary = isDark ? const Color(0xFFE3E3E8) : const Color(0xFF1F1F1F);
    final textSecondary = isDark ? const Color(0xFF8E8E98) : const Color(0xFF70757A);
    final accent = isDark ? const Color(0xFF8AB4F8) : const Color(0xFF1A73E8);

    showModalBottomSheet(
      context: context,
      backgroundColor: bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle bar
                    Container(
                      width: 36,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF3C3D44) : const Color(0xFFDADCE0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Text(
                      'Select Model',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(_models.length, (i) {
                      final isSelected = i == _selectedModelIndex;
                      return InkWell(
                        onTap: () {
                          setState(() => _selectedModelIndex = i);
                          setModalState(() {});
                          Navigator.pop(ctx);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                          margin: const EdgeInsets.only(bottom: 6),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? accent.withValues(alpha: 0.12)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            border: isSelected
                                ? Border.all(color: accent, width: 1.5)
                                : null,
                          ),
                          child: Row(
                            children: [
                              // Model icon
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: isSelected
                                      ? const LinearGradient(
                                          colors: [Color(0xFF4FC3F7), Color(0xFF7C4DFF), Color(0xFFFF4081)],
                                        )
                                      : null,
                                  color: isSelected ? null : (isDark ? const Color(0xFF2A2B31) : const Color(0xFFE2E5EA)),
                                ),
                                child: Center(
                                  child: isSelected
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(18),
                                          child: Image.asset(
                                            'assets/images/vibrant_infinity_logo.png',
                                            width: 36,
                                            height: 36,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => const Icon(Icons.all_inclusive, size: 18, color: Colors.white),
                                          ),
                                        )
                                      : Icon(Icons.all_inclusive, size: 18, color: textSecondary),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _models[i],
                                      style: TextStyle(
                                        color: isSelected ? accent : textPrimary,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _modelDescription(i),
                                      style: TextStyle(
                                        color: textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Icon(Icons.check_circle, color: accent, size: 22),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _modelDescription(int index) {
    switch (index) {
      case 0:
        return 'On-device, fast, private';
      case 1:
        return 'Extended context, powerful reasoning';
      case 2:
        return 'Most capable, multi-modal';
      default:
        return '';
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
      backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
      drawer: Drawer(
        width: 300,
        backgroundColor: isDark ? const Color(0xFF0D0E11) : Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        child: sidebarWidget,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar (PocketLLM style)
            _buildTopBar(context, isDark),

            // Main Chat Area
            Expanded(
              child: _isEmptyChat
                  ? _buildEmptyState(context, isDark)
                  : _buildChatList(context, isDark),
            ),

            // Chat Input
            ChatInput(
              onSend: _handleSendMessage,
              isBusy: _isGenerating,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, bool isDark) {
    final textPrimary = isDark ? const Color(0xFFE3E3E8) : const Color(0xFF1F1F1F);
    final textSecondary = isDark ? const Color(0xFF8E8E98) : const Color(0xFF70757A);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          // Hamburger menu
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu, size: 24, color: textPrimary),
              onPressed: () => Scaffold.of(context).openDrawer(),
              tooltip: 'Open menu',
            ),
          ),

          const SizedBox(width: 4),

          // Model selector dropdown
          InkWell(
            onTap: _showModelSelector,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _models[_selectedModelIndex].split(' ').first,
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _models[_selectedModelIndex].split(' ').skip(1).join(' '),
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down_rounded, size: 22, color: textSecondary),
                ],
              ),
            ),
          ),

          const Spacer(),

          // Edit / new chat icon
          IconButton(
            icon: Icon(Icons.edit_outlined, size: 22, color: textPrimary),
            onPressed: _startNewChat,
            tooltip: 'New Chat',
          ),

          // User profile avatar
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/images/pratik_avatar.png',
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? const Color(0xFF2A2B31) : const Color(0xFFE2E5EA),
                    ),
                    child: Icon(Icons.person, size: 18, color: textSecondary),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Stack(
      children: [
        // Ambient deep blue glow at center-bottom
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, 0.6),
                radius: 1.2,
                colors: isDark
                    ? [
                        const Color(0xFF060B24).withValues(alpha: 0.8),
                        const Color(0xFF000000),
                      ]
                    : [
                        const Color(0xFFE8F0FE).withValues(alpha: 0.5),
                        const Color(0xFFFFFFFF),
                      ],
              ),
            ),
          ),
        ),

        // Centered logo + prompt text
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Vibrant infinity logo
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Image.asset(
                    'assets/images/vibrant_infinity_logo.png',
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFF4FC3F7), Color(0xFFAB47BC), Color(0xFFFF7043)],
                        ),
                      ),
                      child: const Icon(Icons.all_inclusive, size: 30, color: Colors.white),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // "What should we focus on?"
              Text(
                'What should we focus\non?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? const Color(0xFFE3E3E8) : const Color(0xFF1F1F1F),
                  fontSize: 28,
                  fontWeight: FontWeight.w400,
                  height: 1.3,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChatList(BuildContext context, bool isDark) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: _activeSession.messages.length + (_isGenerating ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < _activeSession.messages.length) {
          return ChatBubble(message: _activeSession.messages[index]);
        }
        // Thinking indicator
        return const PocketLLMThinkingIndicator();
      },
    );
  }
}
