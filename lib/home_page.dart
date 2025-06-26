import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'add_post_page.dart'; // Importe a nova página

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // A lógica de geolocalização pode permanecer aqui ou ser movida
  // para onde for mais útil, como a página de posts.
  // Por enquanto, vamos focar na navegação.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TravelMap'), // Título atualizado
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      // Corpo da Home Page será o feed de posts (a ser implementado)
      body: const Center(
        child: Text(
          'Feed de Posts aparecerá aqui!',
          style: TextStyle(fontSize: 20),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPostPage()),
          );
        },
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add_location_alt),
      ),
    );
  }
}
