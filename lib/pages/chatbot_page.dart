import 'dart:async';
import 'dart:ui';

import 'package:early_application_1/pages/chatbot_service.dart';
import 'package:flutter/material.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ChatbotService _chatbotService = ChatbotService();
  final ScrollController _scrollController = ScrollController();

  final List<_ChatMessage> _messages = [];
  bool _isLoading = false;

  late AnimationController _typingController;
  late Animation<int> _dotAnimation;

  // 🎨 Theme colors (Green + Brown)
  static const _bgTop = Color(0xFF0B2E1B); // deep forest
  static const _bgMid = Color(0xFF154B2B); // green
  static const _bgBottom = Color(0xFF6B3D1F); // cocoa brown

  static const _accentGreen = Color(0xFF2E7D32);
  static const _accentGreen2 = Color(0xFF1B5E20);

  static const _cocoa = Color(0xFF7A4A2B);
  static const _cocoa2 = Color(0xFF5A351F);

  static const _cream = Color(0xFFF7F1E6);
  static const _bubbleBot = Color(0xFFFFF8ED);
  static const _bubbleBotBorder = Color(0xFFE9D9C8);

  @override
  void initState() {
    super.initState();

    _messages.add(
      _ChatMessage.bot(
        "Hello! 🌿 I’m CocoaBot, your cacao farming assistant.\nAsk me about pests, diseases, or best cocoa farming practices.",
      ),
    );

    _typingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
    _dotAnimation = IntTween(begin: 1, end: 3).animate(_typingController);

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom({bool animated = true}) {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position.maxScrollExtent;
    if (animated) {
      _scrollController.animateTo(
        pos,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(pos);
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage.user(text));
      _isLoading = true;
    });
    _messageController.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    try {
      final response = await _chatbotService.sendMessage(text);

      setState(() {
        _isLoading = false;
        _messages.add(_ChatMessage.bot(response));
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
        _messages
            .add(_ChatMessage.bot("Something went wrong. Please try again 🌱"));
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _typingController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: _FancyAppBar(
        title: "CocoaBot",
        subtitle: "Cacao farming assistant",
        leftIcon: Icons.eco_rounded,
        gradient: const LinearGradient(
          colors: [_accentGreen2, _accentGreen, _cocoa],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      body: Stack(
        children: [
          // Background gradient
          const _BackgroundGradient(),

          // Subtle leaf/circle pattern overlay
          const _PatternOverlay(),

          // Content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 10),
                _TopHintChip(
                  icon: Icons.tips_and_updates_rounded,
                  text: "Try: “How to control cocoa mirids?”",
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (_isLoading && index == _messages.length) {
                        return _TypingIndicator(
                          animation: _dotAnimation,
                          bubbleColor: _bubbleBot,
                          borderColor: _bubbleBotBorder,
                          iconBg: _cocoa,
                        );
                      }

                      final m = _messages[index];
                      final isUser = m.sender == _Sender.user;

                      return _ChatBubble(
                        message: m.text,
                        time: m.timeLabel,
                        isUser: isUser,
                        // user bubble is green; bot bubble is cream
                        userGradient: const LinearGradient(
                          colors: [_accentGreen2, _accentGreen],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        botColor: _bubbleBot,
                        botBorder: _bubbleBotBorder,
                        botIconBg: _cocoa,
                        userIconBg: _accentGreen2,
                      );
                    },
                  ),
                ),
                _InputBar(
                  controller: _messageController,
                  onSend: _sendMessage,
                  onSubmitted: (_) => _sendMessage(),
                  accentGradient: const LinearGradient(
                    colors: [_accentGreen2, _accentGreen, _cocoa],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/* ------------------------------ UI WIDGETS ------------------------------ */

class _FancyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String subtitle;
  final IconData leftIcon;
  final Gradient gradient;

  const _FancyAppBar({
    required this.title,
    required this.subtitle,
    required this.leftIcon,
    required this.gradient,
  });

  @override
  Size get preferredSize => const Size.fromHeight(86);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      flexibleSpace: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(22)),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(gradient: gradient),
            ),
            // glass blur
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.white.withOpacity(0.06)),
            ),
          ],
        ),
      ),
      title: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.22)),
            ),
            child: Icon(leftIcon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.85),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
      centerTitle: false,
    );
  }
}

class _BackgroundGradient extends StatelessWidget {
  const _BackgroundGradient();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _ChatbotPageState._bgTop,
            _ChatbotPageState._bgMid,
            _ChatbotPageState._bgBottom,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }
}

class _PatternOverlay extends StatelessWidget {
  const _PatternOverlay();

  @override
  Widget build(BuildContext context) {
    // Simple soft circles as pattern (no asset needed)
    return IgnorePointer(
      child: Opacity(
        opacity: 0.10,
        child: CustomPaint(
          painter: _DotPatternPainter(),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    const spacing = 46.0;
    const r = 2.2;

    for (double y = 20; y < size.height; y += spacing) {
      for (double x = 18; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), r, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TopHintChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _TopHintChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.10),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.14)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: Colors.white.withOpacity(0.95)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.92),
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
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

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final ValueChanged<String> onSubmitted;
  final Gradient accentGradient;

  const _InputBar({
    required this.controller,
    required this.onSend,
    required this.onSubmitted,
    required this.accentGradient,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 6, 14, 14),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: Colors.white.withOpacity(0.16)),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      // optional: add attachments later
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Attachment coming soon ✨")),
                      );
                    },
                    icon: Icon(Icons.add_circle_outline_rounded,
                        color: Colors.white.withOpacity(0.95)),
                  ),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Ask about cocoa… 🌿",
                        hintStyle:
                            TextStyle(color: Colors.white.withOpacity(0.70)),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 10),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: onSubmitted,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _GradientButton(
                    onTap: onSend,
                    gradient: accentGradient,
                    child: const Icon(Icons.send_rounded,
                        color: Colors.white, size: 18),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  final Gradient gradient;

  const _GradientButton({
    required this.onTap,
    required this.child,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.22),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String message;
  final String time;
  final bool isUser;

  final Gradient userGradient;
  final Color botColor;
  final Color botBorder;
  final Color botIconBg;
  final Color userIconBg;

  const _ChatBubble({
    required this.message,
    required this.time,
    required this.isUser,
    required this.userGradient,
    required this.botColor,
    required this.botBorder,
    required this.botIconBg,
    required this.userIconBg,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: Radius.circular(isUser ? 18 : 6),
      bottomRight: Radius.circular(isUser ? 6 : 18),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser)
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: botIconBg.withOpacity(0.95),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child:
                  const Icon(Icons.eco_rounded, color: Colors.white, size: 18),
            ),
          if (!isUser) const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: radius,
                    border: isUser
                        ? null
                        : Border.all(color: botBorder.withOpacity(0.85)),
                    gradient: isUser ? userGradient : null,
                    color: isUser ? null : botColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isUser ? 0.22 : 0.10),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Text(
                    message,
                    style: TextStyle(
                      color: isUser ? Colors.white : const Color(0xFF2B2B2B),
                      fontSize: 15,
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.70),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (isUser) const SizedBox(width: 10),
          if (isUser)
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: userIconBg.withOpacity(0.92),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.18)),
              ),
              child: const Icon(Icons.person_rounded,
                  color: Colors.white, size: 18),
            ),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  final Animation<int> animation;
  final Color bubbleColor;
  final Color borderColor;
  final Color iconBg;

  const _TypingIndicator({
    required this.animation,
    required this.bubbleColor,
    required this.borderColor,
    required this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg.withOpacity(0.95),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(Icons.eco_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderColor.withOpacity(0.85)),
            ),
            child: AnimatedBuilder(
              animation: animation,
              builder: (context, _) {
                return Text(
                  'Typing${'.' * animation.value}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF5A4B3B),
                    fontWeight: FontWeight.w600,
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

/* ------------------------------ MODEL ------------------------------ */

enum _Sender { user, bot }

class _ChatMessage {
  final _Sender sender;
  final String text;
  final DateTime time;

  _ChatMessage({required this.sender, required this.text, required this.time});

  factory _ChatMessage.user(String text) =>
      _ChatMessage(sender: _Sender.user, text: text, time: DateTime.now());

  factory _ChatMessage.bot(String text) =>
      _ChatMessage(sender: _Sender.bot, text: text, time: DateTime.now());

  String get timeLabel {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return "$h:$m";
  }
}
