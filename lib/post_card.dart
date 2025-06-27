import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart'; // Importe para as estrelas
import 'post_detail_page.dart';

class PostCard extends StatelessWidget {
  final DocumentSnapshot post;
  final double? distance;

  const PostCard({super.key, required this.post, this.distance});

  // Função para calcular a média das avaliações
  double _calculateAverageRating(Map<String, dynamic> ratings) {
    double total = 0;
    int count = 0;

    // Converte para double e soma, tratando valores nulos
    final double easyAccess = (ratings['easyAccess'] ?? 0.0).toDouble();
    final double amenities = (ratings['amenities'] ?? 0.0).toDouble();
    final double accessibility = (ratings['accessibility'] ?? 0.0).toDouble();

    total = easyAccess + amenities + accessibility;
    count = 3; // Temos 3 categorias de avaliação

    if (count == 0) return 0.0;
    return total / count;
  }

  @override
  Widget build(BuildContext context) {
    final data = post.data() as Map<String, dynamic>;
    final bool hasImage = data.containsKey('imageUrl') && data['imageUrl'] != null && data['imageUrl'].isNotEmpty;
    
    // Calcula a média para usar no card
    double averageRating = 0.0;
    if (data.containsKey('ratings')) {
      averageRating = _calculateAverageRating(data['ratings'] as Map<String, dynamic>);
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PostDetailPage(postId: post.id)),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        clipBehavior: Clip.antiAlias,
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasImage)
              CachedNetworkImage(
                imageUrl: data['imageUrl'],
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 180,
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 180,
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                ),
              )
            else
              Container(
                height: 180,
                color: Colors.grey[200],
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt_outlined, size: 50, color: Colors.grey),
                    SizedBox(height: 8),
                    Text("Sem imagem", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['placeName'] ?? 'Nome indisponível',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  // AVALIAÇÃO MÉDIA EM ESTRELAS
                  RatingBarIndicator(
                    rating: averageRating,
                    itemBuilder: (context, index) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    itemCount: 5,
                    itemSize: 22.0,
                    direction: Axis.horizontal,
                  ),
                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('por ${data['authorName'] ?? 'Anônimo'}', style: TextStyle(color: Colors.grey[600])),
                      if (distance != null)
                        Text(
                          '${distance!.toStringAsFixed(1)} km',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
