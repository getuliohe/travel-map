import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'add_post_page.dart';
import 'post_card.dart';

enum PostFilter { recent, nearby }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PostFilter _selectedFilter = PostFilter.recent;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    // Lógica para obter permissão de localização
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Serviços de localização estão desabilitados.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Permissão de localização negada.');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Permissão de localização negada permanentemente.');
    } 

    // Obtém a posição e atualiza o estado
    final position = await Geolocator.getCurrentPosition();
    if (mounted) {
      setState(() {
        _currentPosition = position;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TravelMap Feed'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Seletor de Filtro
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SegmentedButton<PostFilter>(
              segments: const <ButtonSegment<PostFilter>>[
                ButtonSegment<PostFilter>(
                  value: PostFilter.recent,
                  label: Text('Recentes'),
                  icon: Icon(Icons.schedule),
                ),
                ButtonSegment<PostFilter>(
                  value: PostFilter.nearby,
                  label: Text('Próximos'),
                  icon: Icon(Icons.location_on_outlined),
                ),
              ],
              selected: <PostFilter>{_selectedFilter},
              onSelectionChanged: (Set<PostFilter> newSelection) {
                setState(() {
                  _selectedFilter = newSelection.first;
                });
              },
            ),
          ),
          
          // Feed de Posts
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('posts').orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Nenhum post encontrado.'));
                }

                List<DocumentSnapshot> posts = snapshot.data!.docs;
                Map<String, double> distances = {};

                // Se o filtro for "Próximos" e a localização estiver disponível
                if (_selectedFilter == PostFilter.nearby && _currentPosition != null) {
                  for (var post in posts) {
                    final data = post.data() as Map<String, dynamic>;
                    final geoPoint = data['location'] as GeoPoint;
                    final distance = Geolocator.distanceBetween(
                      _currentPosition!.latitude,
                      _currentPosition!.longitude,
                      geoPoint.latitude,
                      geoPoint.longitude,
                    ) / 1000; // Converte para km
                    distances[post.id] = distance;
                  }
                  // Ordena a lista de posts com base na distância calculada
                  posts.sort((a, b) => distances[a.id]!.compareTo(distances[b.id]!));
                }

                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return PostCard(
                      post: post,
                      distance: distances[post.id],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPostPage()),
          );
        },
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add),
      ),
    );
  }
}
