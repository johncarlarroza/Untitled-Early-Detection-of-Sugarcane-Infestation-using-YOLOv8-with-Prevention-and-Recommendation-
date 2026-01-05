import 'package:early_application_1/pages/chatbot_service.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ChatbotService _chatbotService = ChatbotService();

  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  late AnimationController _typingController;
  late Animation<int> _dotAnimation;

  @override
  void initState() {
    super.initState();

    _messages.add({
      'sender': 'bot',
      'message':
          'Hello! 🌱 I’m your sugarcane agricultural expert. Ask me anything about sugarcane varieties, pests, diseases, or farming practices.'
    });

    _typingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();

    _dotAnimation = IntTween(begin: 1, end: 3).animate(_typingController);
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text.trim();

    setState(() {
      _messages.add({'sender': 'user', 'message': userMessage});
      _isLoading = true;
    });

    _messageController.clear();

    try {
      final response = await _chatbotService.sendMessage(userMessage);

      setState(() {
        _isLoading = false;
        _messages.add({'sender': 'bot', 'message': response});
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
        _messages.add({
          'sender': 'bot',
          'message': 'Sorry, I had trouble responding. Please try again.'
        });
      });
    }
  }

  @override
  void dispose() {
    _typingController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'SugaBot',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.green[700],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isLoading && index == _messages.length) {
                  return _TypingIndicator(animation: _dotAnimation);
                }

                final message = _messages[index];
                final isUser = message['sender'] == 'user';

                return _ChatBubble(
                  message: message['message']!,
                  isUser: isUser,
                );
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Ask about sugarcane...',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.green[700],
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;

  const _ChatBubble({
    required this.message,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser)
            const CircleAvatar(
              radius: 18,
              backgroundColor: Colors.green,
              child: Icon(Icons.grass, color: Colors.white, size: 18),
            ),
          if (!isUser) const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: isUser ? Colors.green[600] : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
                  bottomRight: isUser ? Radius.zero : const Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                message,
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.black87,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
          if (isUser)
            const CircleAvatar(
              radius: 18,
              backgroundColor: Colors.blueGrey,
              child: Icon(Icons.person, color: Colors.white, size: 18),
            ),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  final Animation<int> animation;

  const _TypingIndicator({required this.animation});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundColor: Colors.green,
            child: Icon(Icons.agriculture, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return Text(
                  'Typing${'.' * animation.value}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
