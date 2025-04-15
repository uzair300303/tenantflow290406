import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tenantflow/components/my_button.dart';
import 'package:tenantflow/components/my_textfield.dart';
import 'package:tenantflow/constants.dart';
import 'package:tenantflow/pages/login_page.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  _ChatbotPageState createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController messageController = TextEditingController();
  final List<Map<String, dynamic>> messages = [];
  final List<Content> _chatHistory = [];
  late final GenerativeModel _model;
  String _partialBotResponse = '';
  bool isLoading = false;
  static const int _maxHistory = 10; // Limit to 10 exchanges (user + bot)

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: geminiApiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        maxOutputTokens: 512,
      ),
      systemInstruction: Content.text(
        'You are a tenant assistant for TenantFlow, a property management app designed to simplify tenant life. '
        'Provide friendly, concise, and accurate answers about leasing, maintenance requests, rent payments, '
        'community events, property rules, or tenant-related topics. Use a supportive and approachable tone. '
        'If a question is unclear, ask for clarification politely. If off-topic, redirect to tenant issues. '
        'Examples: '
        '- For "How do I pay rent?", suggest using the app’s payment feature or contacting the landlord. '
        '- For "What’s a lease?", explain it simply and mention common terms like security deposits.'
      ),
    );
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    // Load saved chat history
    final prefs = await SharedPreferences.getInstance();
    final savedMessages = prefs.getString('chat_history');
    if (savedMessages != null) {
      final List<dynamic> decoded = jsonDecode(savedMessages);
      setState(() {
        messages.addAll(decoded.map((m) => Map<String, dynamic>.from(m)));
        // Rebuild chat history for Gemini
        for (var msg in messages) {
          if (msg['sender'] == 'You') {
            _chatHistory.add(Content.text(msg['text']));
          } else {
            _chatHistory.add(Content.model([TextPart(msg['text'])]));
          }
        }
      });
    }
    // Add welcome message if no history
    if (messages.isEmpty) {
      setState(() {
        messages.add({
          'sender': 'Bot',
          'text': 'Welcome to TenantFlow’s Assistant! I’m here to help with questions about your lease, maintenance, rent, or community events. What’s on your mind?',
          'isMarkdown': true,
        });
      });
      _chatHistory.add(Content.model([TextPart(messages.last['text'])]));
    }
  }

  Future<void> _saveChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('chat_history', jsonEncode(messages));
    // Silent save, no snackbar
  }

  Future<void> _clearChat() async {
    setState(() {
      messages.clear();
      _chatHistory.clear();
      _partialBotResponse = '';
      messages.add({
        'sender': 'Bot',
        'text': 'Chat cleared! I’m ready to help with your tenant questions. What’s up?',
        'isMarkdown': true,
      });
      _chatHistory.add(Content.model([TextPart(messages.last['text'])]));
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('chat_history');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chat cleared', style: TextStyle(fontFamily: 'Poppins')),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  Future<void> sendMessage({bool isRetry = false}) async {
    final userMessage = messageController.text.trim();
    if (!isRetry) {
      if (userMessage.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a message', style: TextStyle(fontFamily: 'Poppins')),
          ),
        );
        return;
      }
      if (userMessage.length > 500) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Message too long (max 500 characters)', style: TextStyle(fontFamily: 'Poppins')),
          ),
        );
        return;
      }
      setState(() {
        messages.add({'sender': 'You', 'text': userMessage, 'isMarkdown': false});
        messages.add({'sender': 'Bot', 'text': '', 'isMarkdown': true});
        isLoading = true;
        messageController.clear();
      });
      _chatHistory.add(Content.text(userMessage));
    } else {
      setState(() {
        messages.add({'sender': 'Bot', 'text': '', 'isMarkdown': true});
        isLoading = true;
      });
    }

    // Truncate history if too long
    if (_chatHistory.length > _maxHistory * 2) {
      _chatHistory.removeRange(0, _chatHistory.length - _maxHistory * 2);
      setState(() {
        messages.add({
          'sender': 'Bot',
          'text': 'Older messages trimmed to keep things snappy. Let’s continue!',
          'isMarkdown': true,
        });
      });
      _chatHistory.add(Content.model([TextPart(messages.last['text'])]));
    }

    try {
      final responseStream = _model.generateContentStream(_chatHistory);

      await for (final chunk in responseStream) {
        setState(() {
          _partialBotResponse += chunk.text ?? '';
          messages.last['text'] = _partialBotResponse;
        });
      }

      setState(() {
        isLoading = false;
        _chatHistory.add(Content.model([TextPart(_partialBotResponse)]));
        _partialBotResponse = '';
      });
      await _saveChatHistory();
    } catch (e) {
      setState(() {
        messages.last['text'] = 'Error: $e\n[Tap to retry]';
        messages.last['isError'] = true;
        isLoading = false;
        _partialBotResponse = '';
      });
      _chatHistory.removeLast(); // Remove failed bot message
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tenant Assistant', style: TextStyle(fontFamily: 'Poppins')),
        backgroundColor: Colors.blue.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            tooltip: 'Clear Chat',
            onPressed: _clearChat,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final isUser = message['sender'] == 'You';
                  final isError = message['isError'] == true;
                  return FadeInAnimation(
                    delay: 100 * index,
                    child: Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: isError ? () => sendMessage(isRetry: true) : null,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isUser
                                ? Colors.blue.shade700
                                : isError
                                    ? Colors.red.shade100
                                    : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: message['isMarkdown'] == true
                              ? MarkdownBody(
                                  data: message['text']!,
                                  styleSheet: MarkdownStyleSheet(
                                    p: TextStyle(
                                      color: isUser ? Colors.white : Colors.black,
                                      fontFamily: 'Poppins',
                                      fontSize: 14,
                                    ),
                                    strong: const TextStyle(fontWeight: FontWeight.bold),
                                    listBullet: const TextStyle(fontFamily: 'Poppins'),
                                  ),
                                )
                              : Text(
                                  message['text']!,
                                  style: TextStyle(
                                    color: isUser ? Colors.white : Colors.black,
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (isLoading)
              const Padding(
                padding: EdgeInsets.all(10),
                child: CircularProgressIndicator(color: Colors.blue),
              ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: MyTextField(
                      controller: messageController,
                      hintText: 'Ask about tenant issues...',
                      obscureText: false,
                      showVisibilityToggle: false,
                      onSubmitted: (value) {
                        if (value.trim().isNotEmpty) {
                          sendMessage();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  MyButton(
                    onTap: () => sendMessage(),
                    text: 'Send',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }
}