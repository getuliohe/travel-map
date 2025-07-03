import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:travelmap3/add_post_page.dart';
import 'package:travelmap3/post_card.dart';
import 'package:travelmap3/theme/app_theme.dart';

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
    await _determinePosition();
  }

  Future<void> _determinePosition() async {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  const CircleAvatar(backgroundColor: Colors.grey),
                ],
              ),
            ),
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
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text("Lugares populares", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SegmentedButton<PostFilter>(
                segments: const <ButtonSegment<PostFilter>>[
                  ButtonSegment<PostFilter>(value: PostFilter.recent, label: Text('Recentes')),
                  ButtonSegment<PostFilter>(value: PostFilter.nearby, label: Text('Próximos')),
                ],
                selected: <PostFilter>{_selectedFilter},
                onSelectionChanged: (newSelection) {
                  setState(() {
                    _selectedFilter = newSelection.first;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 320,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('posts').orderBy('createdAt', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  
                  List<DocumentSnapshot> posts = snapshot.data!.docs;
                  Map<String, double> distances = {};
                  
                  if (_currentPosition != null) {
                    for (var post in posts) {
                      final data = post.data() as Map<String, dynamic>;
                      final geoPoint = data['location'] as GeoPoint;
                      distances[post.id] = Geolocator.distanceBetween(
                        _currentPosition!.latitude, _currentPosition!.longitude,
                        geoPoint.latitude, geoPoint.longitude,
                      ) / 1000; // em km
                    }
                  }

                  if (_selectedFilter == PostFilter.nearby) {
                    if (_currentPosition == null) {
                      return const Center(child: Text("Habilite a localização para ver posts próximos."));
                    }
                    posts.sort((a, b) => distances[a.id]!.compareTo(distances[b.id]!));
                  }

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: posts.length,
                    itemBuilder: (context, index) => PostCard(
                      post: posts[index],
                      distance: distances[posts[index].id], // Passa a distância para o card
                    ),
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
