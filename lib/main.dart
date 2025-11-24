import 'package:flutter/material.dart';
import 'map_screen.dart';

void main() {
  runApp(MyApp());  // <--- FIXED (removed const)
}

class MyApp extends StatelessWidget {
  MyApp({super.key});  // you can keep this const or remove const, both fine

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MapScreen(),   // <--- also no const
    );
  }
}
