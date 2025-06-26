import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'auth_wrapper.dart'; // Importe o novo wrapper
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TravelMap App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // A home do app agora é o AuthWrapper, que cuidará da lógica de navegação.
      home: AuthWrapper(),
    );
  }
}