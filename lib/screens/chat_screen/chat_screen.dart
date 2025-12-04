import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String? initialMessage;
  const ChatScreen({this.initialMessage, super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class Message {
  final String text;
  final bool isUser;
  Message(this.text, {this.isUser = false});
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Message> _messages = [];
  final TextEditingController controller = TextEditingController();
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // 👋 AI welcome message
    _messages.add(
      Message('👋 Hi, I\'m Trackro — your AI travel assistant!', isUser: false),
    );

    // if initial message exists
    if (widget.initialMessage != null) {
      _messages.add(Message(widget.initialMessage!, isUser: true));

      Future.delayed(const Duration(milliseconds: 600), () {
        _messages.add(
          Message("You asked: \"${widget.initialMessage}\".\n(🤖 Mock AI response)"),
        );
        setState(() {});
      });
    }
  }

  void _sendMessage() {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    // user message
    setState(() {
      _messages.add(Message(text, isUser: true));
      controller.clear();
    });

    // mock AI reply
    Future.delayed(const Duration(milliseconds: 700), () {
      setState(() {
        _messages.add(
          Message("Thanks for your question.\nI am thinking... (🤖 mock reply)"),
        );
      });

      scrollController.animateTo(
        scrollController.position.maxScrollExtent + 200,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F0F),
        elevation: 0,
        title: const Text("AI Assistant", style: TextStyle(color: Colors.white)),
        leading: const Padding(
          padding: EdgeInsets.only(left: 12.0),
          child: CircleAvatar(
            backgroundColor: Color(0xFF1F1F1F),
            child: Icon(Icons.android, color: Colors.white),
          ),
        ),
      ),

      body: Column(
        children: [

          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _chatBubble(_messages[index]);
              },
            ),
          ),

          _chatInput(),
        ],
      ),
    );
  }

  // =====================================================================
  // CHAT BUBBLE
  // =====================================================================

  Widget _chatBubble(Message message) {
    final bool isUser = message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF292929) : const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(4),
            bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
          ),
        ),
        child: Text(
          message.text,
          style: const TextStyle(color: Colors.white, height: 1.4),
        ),
      ),
    );
  }

  // =====================================================================
  // INPUT BAR
  // =====================================================================

  Widget _chatInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      color: const Color(0xFF101010),
      child: Row(
        children: [

          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF1A1A1A),
                hintText: "Type your message…",
                hintStyle: const TextStyle(color: Colors.grey),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 14
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          GestureDetector(
            onTap: _sendMessage,
            child: CircleAvatar(
              backgroundColor: const Color(0xFF8B5CF6),
              child: const Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
