import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:travelmap3/post_detail_page.dart';

class PostCard extends StatelessWidget {
  final DocumentSnapshot post;
  final double? distance;

  const PostCard({super.key, required this.post, this.distance});

  double _calculateAverageRating(Map<String, dynamic> ratings) {
    final values = ratings.values.whereType<num>().map((e) => e.toDouble());
    if (values.isEmpty) return 0.0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  @override
  Widget build(BuildContext context) {
    final data = post.data() as Map<String, dynamic>;
    final bool hasImage = data.containsKey('imageUrl') && data['imageUrl'] != null;
    double averageRating = data.containsKey('ratings') ? _calculateAverageRating(data['ratings']) : 0.0;

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => PostDetailPage(postId: post.id)));
      },
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(left: 16),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: hasImage
                  ? CachedNetworkImage(
                      imageUrl: data['imageUrl'],
                      width: 220,
                      height: 320,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: Colors.grey[200]),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                    )
                  : Container(width: 220, height: 320, color: Colors.grey[200]),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['placeName'] ?? 'Sem nome',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  // ATUALIZAÇÃO: Adicionado o nome do autor
                  Text(
                    'por ${data['authorName'] ?? 'Anônimo'}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (averageRating > 0)
                        RatingBarIndicator(
                          rating: averageRating,
                          itemBuilder: (context, index) => const Icon(Icons.star, color: Colors.amber),
                          itemCount: 5,
                          itemSize: 16.0,
                        ),
                      const Spacer(),
                      if (distance != null)
                        Text(
                          '${distance!.toStringAsFixed(1)} km',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
