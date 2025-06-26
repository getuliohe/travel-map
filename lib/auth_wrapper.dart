import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page.dart';
import 'welcome_page.dart';

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Enquanto estiver conectando, mostre um indicador de carregamento
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // Se o snapshot tiver dados, significa que o usuário está logado
        if (snapshot.hasData) {
          return HomePage(); // Mostra o feed (HomePage)
        }

        // Se não tiver dados, o usuário não está logado
        return WelcomePage(); // Mostra a página de boas-vindas com Login/Registro
      },
    );
  }
}