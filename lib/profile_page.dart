import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:travelmap3/post_detail_page.dart';
import 'package:travelmap3/theme/app_theme.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Seção com informações do usuário
          FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).get(),
            builder: (context, userSnapshot) {
              if (!userSnapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final userData = userSnapshot.data!.data() as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    const CircleAvatar(radius: 40, backgroundColor: Colors.grey),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(userData['username'] ?? 'Usuário', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        Text(userData['email'] ?? 'Sem e-mail', style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(height: 1),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("Meus Locais Postados", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          // Grade de Posts do Usuário
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .where('authorId', isEqualTo: currentUser?.uid)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, postSnapshot) {
                if (postSnapshot.hasError) {
                  // Mostra o erro do índice para o desenvolvedor
                  print("ERRO DO FIREBASE (provavelmente índice faltando): ${postSnapshot.error}");
                  return const Center(child: Text("Erro ao carregar posts. Verifique o console.", textAlign: TextAlign.center));
                }
                if (postSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!postSnapshot.hasData || postSnapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Você ainda não postou nenhum local.', style: TextStyle(color: Colors.grey)));
                }
                final posts = postSnapshot.data!.docs;
                return GridView.builder(
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return _buildProfilePostCard(context, post);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget específico para o card do perfil
  Widget _buildProfilePostCard(BuildContext context, DocumentSnapshot post) {
    final data = post.data() as Map<String, dynamic>;
    final hasImage = data.containsKey('imageUrl') && data['imageUrl'] != null;

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => PostDetailPage(postId: post.id)));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: hasImage
                  ? CachedNetworkImage(
                      imageUrl: data['imageUrl'],
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: AppTheme.lightGrey),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                    )
                  : Container(color: AppTheme.lightGrey, child: const Icon(Icons.camera_alt_outlined, color: Colors.grey)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data['placeName'] ?? 'Sem nome',
            style: const TextStyle(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
