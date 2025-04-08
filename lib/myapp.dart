import 'package:flutter/material.dart';
import 'package:password_manager/Pages/Authentication/Auth_screen.dart';
import 'package:password_manager/Pages/Authentication/Setup_screen.dart';

class MyApp extends StatelessWidget {
  final bool showSetup;

  const MyApp({required this.showSetup, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: showSetup ? SetupScreen() : AuthScreen(),
    );
  }
}