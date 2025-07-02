import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'auth_wrapper.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart'; // Importe o tema

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TravelMap',
      theme: AppTheme.lightTheme, // Aplica o tema
      home: AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}
