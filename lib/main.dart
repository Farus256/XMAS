import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const TreeRaterApp());
}

class TreeRaterApp extends StatelessWidget {
  const TreeRaterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TreeRater',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark().copyWith(
          primary: const Color(0xFFFFD700),
          secondary: const Color(0xFFD40000),
        ),
        scaffoldBackgroundColor: const Color(0xFF003300),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
