import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'add_post_page.dart';
import 'post_card.dart';
import 'theme/app_theme.dart'; // <-- A CORREÇÃO ESTÁ AQUI

enum PostFilter { recent, nearby }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PostFilter _selectedFilter = PostFilter.recent;
  Position? _currentPosition;
  String? _username;

  @override
  void initState() {
    super.initState();
    _fetchUserDataAndLocation();
  }

  Future<void> _fetchUserDataAndLocation() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (mounted) {
        setState(() {
          _username = userData.data()?['username'];
        });
      }
    }
    
    // Lógica para obter a localização
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      
      if (permission == LocationPermission.deniedForever) return; 

      final position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }
    } catch (e) {
      print("Erro ao buscar localização: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Cabeçalho
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Olá, ${_username ?? 'Viajante'} 👋',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const Text('Explore o mundo!', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const CircleAvatar(
                    backgroundColor: Colors.grey,
                  )
                ],
              ),
            ),
            // Barra de Busca
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Explorar',
                  prefixIcon: const Icon(Icons.search),
                  fillColor: AppTheme.lightGrey,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: () {},
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Filtros
            // (O SegmentedButton pode ser estilizado aqui depois)

            // Feed
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('posts').orderBy('createdAt', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final posts = snapshot.data!.docs;
                  
                  // A lógica de ordenação por proximidade pode ser adicionada aqui
                  
                  return ListView.builder(
                    scrollDirection: Axis.horizontal, // Faz o scroll ser horizontal
                    itemCount: posts.length,
                    itemBuilder: (context, index) => PostCard(post: posts[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AddPostPage()));
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
        shape: const CircleBorder(),
      ),
    );
  }
}
