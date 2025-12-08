import 'package:flutter/material.dart';
import 'screens/chat_screen.dart';

void main() => runApp(TrackmateeChatbotApp());

class TrackmateeChatbotApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Trackmatee Chatbot UI',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Color(0xFF0E0E0E),
        primaryColor: Color(0xFFBFA6FF),
        textTheme: ThemeData.dark().textTheme.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
      ),
      home: ChatScreen(),
    );
  }
}