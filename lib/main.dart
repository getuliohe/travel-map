import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:travelmap2/screens/home_screen.dart'; 
import 'package:travelmap2/screens/login_screen.dart'; 
import 'package:travelmap2/screens/register_screen.dart'; 
import 'package:travelmap2/screens/splash_screen.dart'; 
import 'firebase_options.dart';

void main() async {
  // Garante que os widgets do Flutter estão inicializados
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializa o Firebase
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
      title: 'App com Firestore',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        brightness: Brightness.dark, // Tema escuro como na sua imagem
      ),
      // A rota inicial é a nossa tela de splash
      initialRoute: '/',
      // Define as rotas nomeadas para navegar entre as telas
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}