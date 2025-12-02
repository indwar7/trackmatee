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
            api.setToken('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzY0NjQ5MDU5LCJpYXQiOjE3NjQ2NDgxNTksImp0aSI6IjllYWNmZjkxNjE1MzQ0MjRiZmZjNTM2MzZkZmM3NjVlIiwidXNlcl9pZCI6IjIifQ.Koy1WrAF7j7_lS5XsbQfgo4EFwD9kqKTOPbXeC6cPfw');
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
