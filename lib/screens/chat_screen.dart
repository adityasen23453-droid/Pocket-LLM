import 'dart:async';
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

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatSession> _sessions = [];
  late String _activeSessionId;
  final ScrollController _scrollController = ScrollController();
  bool _isGenerating = false;
  bool _isSidebarVisible = true;

  @override
  void initState() {
    super.initState();
    _initDefaultSessions();
  }

  void _initDefaultSessions() {
    final now = DateTime.now();
    final defaultSession = ChatSession(
      id: 'session_1',
      title: 'Welcome to PocketLLM',
      messages: [
        ChatMessage(
          id: 'msg_welcome',
          text:
              'Hello! I am PocketLLM, your pocket-sized intelligent companion. How can I assist you today?',
          isUser: false,
          timestamp: now.subtract(const Duration(minutes: 5)),
        ),
      ],
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
      messages: [
        ChatMessage(
          id: 'welcome_${DateTime.now().millisecondsSinceEpoch}',
          text: 'Started a new conversation with PocketLLM. How can I help?',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      ],
      lastModified: DateTime.now(),
    );

    setState(() {
      _sessions.insert(0, newSession);
      _activeSessionId = newId;
    });
    _scrollToBottom();
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
    Timer(const Duration(milliseconds: 650), () {
      if (!mounted) return;
      final aiResponseText = _generateMockResponse(text);
      final aiMsg = ChatMessage(
        id: 'msg_ai_${DateTime.now().millisecondsSinceEpoch}',
        text: aiResponseText,
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

  String _generateMockResponse(String userPrompt) {
    final lower = userPrompt.toLowerCase();
    if (lower.contains('hello') || lower.contains('hi')) {
      return 'Hello! How can I assist you with your project or questions today?';
    } else if (lower.contains('who are you') || lower.contains('what is pocketllm')) {
      return 'I am PocketLLM, an on-device, lightweight AI assistant designed to provide instant answers with complete privacy and zero clutter.';
    } else if (lower.contains('theme')) {
      return 'PocketLLM features two distinct, clean themes: Light (White & Black) and Dark (Charcoal Black & White). You can toggle them instantly from the sidebar or header.';
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = MediaQuery.of(context).size.width >= 768;

    final sidebarWidget = ChatSidebar(
      sessions: _sessions,
      activeSessionId: _activeSessionId,
      onSelectSession: (id) {
        _selectSession(id);
        if (!isDesktop) {
          Navigator.of(context).pop(); // Close drawer on mobile
        }
      },
      onNewChat: () {
        _startNewChat();
        if (!isDesktop) {
          Navigator.of(context).pop();
        }
      },
      onDeleteSession: _deleteSession,
      onBackToLanding: () {
        if (!isDesktop) {
          Navigator.of(context).pop();
        }
        Navigator.pushReplacementNamed(context, '/');
      },
    );

    return Scaffold(
      drawer: isDesktop ? null : Drawer(child: sidebarWidget),
      appBar: AppBar(
        titleSpacing: 4,
        leadingWidth: 96,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded, size: 22),
              tooltip: 'Back to Landing Page',
              onPressed: () => Navigator.pushReplacementNamed(context, '/'),
            ),
            if (isDesktop)
              IconButton(
                icon: Icon(
                  _isSidebarVisible ? Icons.menu_open_rounded : Icons.menu_rounded,
                  size: 22,
                ),
                onPressed: () {
                  setState(() {
                    _isSidebarVisible = !_isSidebarVisible;
                  });
                },
                tooltip: _isSidebarVisible ? 'Hide sidebar' : 'Show sidebar',
              )
            else
              Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu_rounded, size: 22),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  tooltip: 'Open chat history',
                ),
              ),
          ],
        ),
        title: InkWell(
          onTap: () => Navigator.pushReplacementNamed(context, '/'),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white : Colors.black,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.all_inclusive,
                      size: 15,
                      color: isDark ? const Color(0xFF121212) : Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    _activeSession.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              size: 20,
            ),
            onPressed: () => themeController.toggleTheme(),
            tooltip: isDark ? 'Switch to Light Theme' : 'Switch to Dark Theme',
          ),
          IconButton(
            icon: const Icon(Icons.add_rounded, size: 22),
            onPressed: _startNewChat,
            tooltip: 'New Chat',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          // Sidebar on Desktop / Tablet
          if (isDesktop && _isSidebarVisible) sidebarWidget,

          // Main Chat Area
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: _activeSession.messages.length + (_isGenerating ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index < _activeSession.messages.length) {
                        return ChatBubble(message: _activeSession.messages[index]);
                      }
                      // Typing indicator
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark ? const Color(0xFF25252C) : const Color(0xFF000000),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.all_inclusive,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF19191E) : const Color(0xFFF4F4F6),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isDark ? const Color(0xFF2A2A32) : const Color(0xFFE5E5EB),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: isDark ? Colors.white : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'PocketLLM is thinking...',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark ? const Color(0xFFB0B0B8) : const Color(0xFF666666),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Chat Input field
                ChatInput(
                  onSend: _handleSendMessage,
                  isBusy: _isGenerating,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
