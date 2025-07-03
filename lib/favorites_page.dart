import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travelmap3/post_card.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Favoritos'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).snapshots(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!userSnapshot.hasData || userSnapshot.data?.data() == null) {
            return const Center(child: Text('Não foi possível carregar os dados do usuário.'));
          }
          
          final data = userSnapshot.data!.data() as Map<String, dynamic>;
          final List<dynamic> favoriteIds = data.containsKey('favorites') ? data['favorites'] as List<dynamic> : [];

          // CORREÇÃO: Se a lista de favoritos estiver vazia, mostramos uma mensagem.
          if (favoriteIds.isEmpty) {
            return const Center(
              child: Text('Você ainda não favoritou nenhum local.', style: TextStyle(color: Colors.grey)),
            );
          }

          // A busca só acontece se a lista não estiver vazia.
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('posts').where(FieldPath.documentId, whereIn: favoriteIds).snapshots(),
            builder: (context, postSnapshot) {
              if (postSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!postSnapshot.hasData || postSnapshot.data!.docs.isEmpty) {
                return const Center(child: Text('Nenhum post favorito encontrado.'));
              }
              
              final posts = postSnapshot.data!.docs;
              return ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    height: 320,
                    child: PostCard(post: posts[index]),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
