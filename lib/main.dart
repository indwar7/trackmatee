import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'services/api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(
          create: (_) {
            final api = ApiService();
            api.setToken('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzY0NzgzMzgwLCJpYXQiOjE3NjQ3ODI0ODAsImp0aSI6ImNjMzk3OTY2NjUzNzRjNzJiOTZmZGE3YTZhMzI5YzkyIiwidXNlcl9pZCI6IjExIn0.aIhZzu1GWNZcbOM5lN5LgzBKHp1z9h4SaA8agsKw_ZQ');
            return api;
          },
        )
      ],
      child: MaterialApp(
        title: 'TrackMate',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: const Color(0xFF1a1a2e),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF16213e),
            elevation: 0,
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
