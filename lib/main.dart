import 'package:flutter/material.dart';
import 'package:password_manager/myapp.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final hasPin = prefs.getBool('has_pin') ?? false;
  runApp(MyApp(showSetup: !hasPin));
}