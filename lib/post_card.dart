import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'post_detail_page.dart';

class PostCard extends StatelessWidget {
  final DocumentSnapshot post;
  final double? distance;

  const PostCard({super.key, required this.post, this.distance});

  @override
  Widget build(BuildContext context) {
    final data = post.data() as Map<String, dynamic>;
    final bool hasImage = data.containsKey('imageUrl') && data['imageUrl'] != null;

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => PostDetailPage(postId: post.id)));
      },
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(left: 16),
        child: Stack(
          children: [
            // Imagem com bordas arredondadas
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
            // Gradiente para escurecer a parte de baixo da imagem
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
            // Ícone de favorito
            const Positioned(
              top: 16,
              right: 16,
              child: Icon(Icons.favorite_border, color: Colors.white),
            ),
            // Textos sobre a imagem
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['placeName'] ?? 'Sem nome',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        data['authorName'] ?? 'South, America', // Placeholder
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      const Spacer(),
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      const Text('4.9', style: TextStyle(color: Colors.white, fontSize: 14)), // Placeholder
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
