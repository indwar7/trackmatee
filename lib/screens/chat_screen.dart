import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  bool _isLoading = false;
  String? _conversationId;
  final String backendUrl = 'https://chatbotcopy-ev49.onrender.com';

  @override
  void initState() {
    super.initState();
    _messages.add(Message('Hi, my name is Trackro, how may I help you today?', isUser: false));

    if (widget.initialMessage != null) {
      _messages.add(Message(widget.initialMessage!, isUser: true));
      Future.delayed(Duration(milliseconds: 500), () {
        _startConversation(widget.initialMessage!);
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _startConversation(String userMessage) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$backendUrl/inquire/start'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'message': userMessage,
        }),
      ).timeout(
        Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Store conversation ID for continuing the conversation
        _conversationId = data['conversation_id'];

        // Get the assistant's response
        final botReply = data['question'] ?? 'Sorry, I could not process your request.';

        setState(() {
          _messages.add(Message(botReply, isUser: false));
          _isLoading = false;
        });
      } else {
        setState(() {
          _messages.add(Message('Error: Unable to get response from server (${response.statusCode})', isUser: false));
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _messages.add(Message('Error: ${e.toString()}', isUser: false));
        _isLoading = false;
      });
    }
  }

  Future<void> _continueConversation(String userMessage) async {
    if (_conversationId == null) {
      setState(() {
        _messages.add(Message('Error: Conversation ID not found. Please start a new conversation.', isUser: false));
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$backendUrl/inquire/continue'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'conversation_id': _conversationId,
          'answer': userMessage,
        }),
      ).timeout(
        Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Get the assistant's response
        final botReply = data['question'] ?? data['refined_query'] ?? 'Sorry, I could not process your request.';

        setState(() {
          _messages.add(Message(botReply, isUser: false));
          _isLoading = false;
        });
      } else {
        setState(() {
          _messages.add(Message('Error: Unable to get response from server (${response.statusCode})', isUser: false));
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _messages.add(Message('Error: ${e.toString()}', isUser: false));
        _isLoading = false;
      });
    }
  }

  void _sendMessage() {
    final text = controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    _messages.add(Message(text, isUser: true));
    setState(() {});
    controller.clear();

    // If this is the first message, start a conversation
    if (_conversationId == null) {
      _startConversation(text);
    } else {
      // Otherwise, continue the existing conversation
      _continueConversation(text);
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
          child: CircleAvatar(
            backgroundColor: Colors.grey[800],
            child: Icon(Icons.person, color: Colors.white),
          ),
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
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C4BDB)),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('Trackro is typing...', style: TextStyle(color: Colors.grey[400])),
                ],
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
                      enabled: !_isLoading,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color(0xFF1A1A1A),
                        hintText: 'Type a message',
                        hintStyle: TextStyle(color: Colors.grey),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(12),
                      backgroundColor: Color(0xFF6C4BDB),
                    ),
                    onPressed: _isLoading ? null : _sendMessage,
                    child: Icon(Icons.send, color: Colors.white),
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