import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const FarmerAIApp());
}

class FarmerAIApp extends StatelessWidget {
  const FarmerAIApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FarmerAI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
      ),
      home: const HomeScreen(),
    );
  }
}
