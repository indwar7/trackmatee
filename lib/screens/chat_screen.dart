import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

// ---------------- Chat Screen ----------------
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
  String? _conversationId;
  bool _isLoading = false;

  // Backend URL - Deployed on Render
  final String baseUrl = 'https://chatbotcopy-ev49.onrender.com';

  @override
  void initState() {
    super.initState();

    _messages.add(Message('Hi, my name is Trackro, how may I help you today?', isUser: false));

    if (widget.initialMessage != null) {
      _sendMessage(widget.initialMessage!);
    }
  }

  Future<void> _sendMessage(String text) async {
    if (_isLoading) return;

    // Add user message to UI
    setState(() {
      _messages.add(Message(text, isUser: true));
      _isLoading = true;
    });

    controller.clear();

    try {
      if (_conversationId == null) {
        // Start new conversation
        await _startConversation(text);
      } else {
        // Continue existing conversation
        await _continueConversation(text);
      }
    } catch (e) {
      setState(() {
        _messages.add(Message('Error: ${e.toString()}', isUser: false));
        _isLoading = false;
      });
    }
  }

  Future<void> _startConversation(String message) async {
    try {
      print('Attempting to connect to: $baseUrl/inquire/start/stream');

      final response = await http.post(
        Uri.parse('$baseUrl/inquire/start/stream'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'text/event-stream',
        },
        body: json.encode({'message': message}),
      ).timeout(
        Duration(seconds: 60),
        onTimeout: () {
          throw Exception('Request timeout - Backend might be waking up (Render free tier takes 30-60 seconds)');
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        await _handleStreamResponse(response.body);
      } else {
        throw Exception('Failed to start conversation: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error details: $e');
      throw Exception('Network error: $e');
    }
  }

  Future<void> _continueConversation(String answer) async {
    try {
      print('Continuing conversation: $baseUrl/inquire/continue/stream');

      final response = await http.post(
        Uri.parse('$baseUrl/inquire/continue/stream'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'text/event-stream',
        },
        body: json.encode({
          'conversation_id': _conversationId,
          'answer': answer,
        }),
      ).timeout(
        Duration(seconds: 60),
        onTimeout: () {
          throw Exception('Request timeout - Backend might be waking up');
        },
      );

      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        await _handleStreamResponse(response.body);
      } else {
        throw Exception('Failed to continue conversation: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error details: $e');
      throw Exception('Network error: $e');
    }
  }

  Future<void> _handleStreamResponse(String responseBody) async {
    String fullResponse = '';

    // Parse SSE (Server-Sent Events) response
    final lines = responseBody.split('\n');

    for (var line in lines) {
      if (line.startsWith('data: ')) {
        final jsonStr = line.substring(6);
        try {
          final data = json.decode(jsonStr);
          final type = data['type'];

          if (type == 'token') {
            // Accumulate streaming tokens
            fullResponse += data['content'];
            if (data['conversation_id'] != null) {
              _conversationId = data['conversation_id'];
            }
          } else if (type == 'done') {
            // Message complete
            if (data['conversation_id'] != null) {
              _conversationId = data['conversation_id'];
            }
            if (data['question'] != null) {
              fullResponse = data['question'];
            }
          } else if (type == 'final_query') {
            // Refined query received
            fullResponse = data['refined_query'];
            _conversationId = null; // Reset conversation
          } else if (type == 'error') {
            fullResponse = 'Error: ${data['content']}';
          }
        } catch (e) {
          print('Error parsing JSON: $e');
        }
      }
    }

    setState(() {
      if (fullResponse.isNotEmpty) {
        _messages.add(Message(fullResponse, isUser: false));
      }
      _isLoading = false;
    });
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
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  SizedBox(width: 16),
                  CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: Icon(Icons.android, color: Color(0xFF6C4BDB)),
                  ),
                  SizedBox(width: 12),
                  Text('Trackro is typing...', style: TextStyle(color: Colors.grey)),
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
                      onSubmitted: (text) {
                        if (text.trim().isNotEmpty && !_isLoading) {
                          _sendMessage(text.trim());
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(12),
                      backgroundColor: _isLoading ? Colors.grey : Color(0xFF6C4BDB),
                    ),
                    child: Icon(Icons.send, color: Colors.white),
                    onPressed: _isLoading
                        ? null
                        : () {
                      final text = controller.text.trim();
                      if (text.isNotEmpty) {
                        _sendMessage(text);
                      }
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

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
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
          if (!isUser) ...[
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