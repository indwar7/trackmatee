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
            api.setToken('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzY0Nzg4OTIyLCJpYXQiOjE3NjQ3ODgwMjIsImp0aSI6IjlhYzVhNzJhMDBhODQ2OTNhOTFlMDg5OTRmMmU5MjA4IiwidXNlcl9pZCI6IjExIn0.OEtHeJy19r2QHhw6nWLeacK0BtV1d6yidbHiSJJWwYE');
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
