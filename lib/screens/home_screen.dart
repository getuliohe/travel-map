import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Pega os dados do usuário passados como argumento da rota
    final userData = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final userName = userData?['name'] ?? 'Usuário';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tela Inicial'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Ao sair, volta para a tela de login
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Bem-vindo(a), $userName!',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}