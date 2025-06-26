import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TravelMap - Recomendações'),
        actions: [
          // Botão para Adicionar Post (a ser implementado)
          IconButton(
            icon: Icon(Icons.add_a_photo),
            onPressed: () {
              // Navegar para a tela de criação de post
            },
          ),
          // Botão de Logout
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              // O AuthWrapper cuidará da navegação
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('posts').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Nenhum post encontrado.'));
          }

          final posts = snapshot.data!.docs;

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              final data = post.data() as Map<String, dynamic>;

              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  leading: data['imageUrl'] != null
                      ? Image.network(
                          data['imageUrl'],
                          width: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(Icons.image, size: 50),
                        )
                      : Icon(Icons.image, size: 50),
                  title: Text(data['placeName'] ?? 'Nome indisponível'),
                  subtitle: Text('por ${data['authorName'] ?? 'Anônimo'}'),
                  onTap: () {
                    // Navegar para a tela de detalhes do post
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}