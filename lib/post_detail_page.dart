import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:travelmap3/theme/app_theme.dart';

class PostDetailPage extends StatefulWidget {
  final String postId;
  const PostDetailPage({super.key, required this.postId});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  double? _distance;

  @override
  void initState() {
    super.initState();
    _calculateDistance();
  }

  Future<void> _calculateDistance() async {
    try {
      final postDoc = await FirebaseFirestore.instance.collection('posts').doc(widget.postId).get();
      if (!postDoc.exists) return;

      final postData = postDoc.data() as Map<String, dynamic>;
      final postLocation = postData['location'] as GeoPoint;

      final position = await Geolocator.getCurrentPosition();
      final distanceInMeters = Geolocator.distanceBetween(
        position.latitude, position.longitude,
        postLocation.latitude, postLocation.longitude,
      );
      if (mounted) {
        setState(() {
          _distance = distanceInMeters / 1000; // em km
        });
      }
    } catch (e) {
      print("Erro ao calcular distância: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('posts').doc(widget.postId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          if (!snapshot.data!.exists) return const Center(child: Text('Post não encontrado.'));

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final hasImage = data.containsKey('imageUrl') && data['imageUrl'] != null;
          final ratings = data.containsKey('ratings') ? data['ratings'] as Map<String, dynamic> : null;

          return Stack(
            children: [
              if (hasImage)
                Positioned.fill(
                  child: CachedNetworkImage(imageUrl: data['imageUrl'], fit: BoxFit.cover),
                ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildCircleButton(context, Icons.arrow_back, () => Navigator.of(context).pop()),
                    ],
                  ),
                ),
              ),
              DraggableScrollableSheet(
                initialChildSize: 0.6,
                minChildSize: 0.6,
                maxChildSize: 0.9,
                builder: (context, scrollController) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
                    ),
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(24.0),
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(data['placeName'] ?? 'Sem nome', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  // ATUALIZAÇÃO: Adicionado o nome do autor
                                  Text(
                                    'por ${data['authorName'] ?? 'Anônimo'}',
                                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                            if (_distance != null)
                              Text('${_distance!.toStringAsFixed(1)} km', style: const TextStyle(fontSize: 16, color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text('Descrição', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(data['description'] ?? 'Nenhuma descrição disponível.', style: const TextStyle(color: Colors.black54, height: 1.5)),
                        const SizedBox(height: 24),
                        if (ratings != null) ...[
                          const Text('Avaliações', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const Divider(height: 24),
                          _buildReadOnlyRating("Fácil Acesso", ratings['easyAccess']?.toDouble() ?? 0.0),
                          _buildReadOnlyRating("Comodidades", ratings['amenities']?.toDouble() ?? 0.0),
                          _buildReadOnlyRating("Acessibilidade", ratings['accessibility']?.toDouble() ?? 0.0),
                        ],
                        const SizedBox(height: 80),
                      ],
                    ),
                  );
                },
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.route_outlined),
                    label: const Text('Traçar Rota'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: AppTheme.darkTextColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCircleButton(BuildContext context, IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), shape: BoxShape.circle),
      child: IconButton(icon: Icon(icon, color: Colors.white), onPressed: onPressed),
    );
  }

  Widget _buildReadOnlyRating(String title, double rating) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          RatingBarIndicator(
            rating: rating,
            itemBuilder: (context, index) => const Icon(Icons.star, color: Colors.amber),
            itemCount: 5,
            itemSize: 20.0,
          ),
        ],
      ),
    );
  }
}
