import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String? initialMessage;

  ChatScreen({this.initialMessage});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class Message {
  final String text;
  final bool isUser;
  Message(this.text, {this.isUser = false});
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Message> _messages = [];
  final controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    _messages.add(Message('Hi, my name is Trackro, how may I help you today?', isUser: false));

    if (widget.initialMessage != null) {
      _messages.add(Message(widget.initialMessage!, isUser: true));

      Future.delayed(Duration(milliseconds: 500), () {
        _messages.add(Message("Thanks for asking: '${widget.initialMessage}'. (Mock reply)", isUser: false));
        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: CircleAvatar(backgroundColor: Colors.grey[800], child: Icon(Icons.person, color: Colors.white)),
        ),
        title: Text('Trackro', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (context, i) => ChatBubble(message: _messages[i]),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color(0xFF1A1A1A),
                        hintText: 'Type a message',
                        hintStyle: TextStyle(color: Colors.grey),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(shape: CircleBorder(), padding: EdgeInsets.all(12), backgroundColor: Color(0xFF6C4BDB)),
                    child: Icon(Icons.send, color: Colors.white),
                    onPressed: () {
                      final text = controller.text.trim();
                      if (text.isEmpty) return;

                      _messages.add(Message(text, isUser: true));
                      setState(() {});
                      controller.clear();

                      Future.delayed(Duration(milliseconds: 600), () {
                        _messages.add(Message('Thanks — we got your question: "$text". (Mock reply)', isUser: false));
                        setState(() {});
                      });
                    },
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final Message message;
  const ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final bool isUser = message.isUser;

    final radius = isUser
        ? BorderRadius.only(
      topLeft: Radius.circular(14),
      topRight: Radius.circular(14),
      bottomLeft: Radius.circular(14),
    )
        : BorderRadius.only(
      topLeft: Radius.circular(14),
      topRight: Radius.circular(14),
      bottomRight: Radius.circular(14),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser)
            ...[
              CircleAvatar(
                backgroundColor: Colors.transparent,
                child: Icon(Icons.android, color: Color(0xFF6C4BDB)),
              ),
              SizedBox(width: 8),
            ],
          Flexible(
            child: Container(
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isUser ? Color(0xFF2E2B2F) : Color(0xFF2C2C2C),
                borderRadius: radius,
              ),
              child: Text(message.text, style: TextStyle(color: Colors.white)),
            ),
          ),
          if (isUser) SizedBox(width: 8),
        ],
      ),
    );
  }
}
