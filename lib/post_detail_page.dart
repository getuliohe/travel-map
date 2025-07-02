import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'theme/app_theme.dart';

class PostDetailPage extends StatelessWidget {
  final String postId;

  const PostDetailPage({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('posts').doc(postId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Post não encontrado.'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final hasImage = data.containsKey('imageUrl') && data['imageUrl'] != null;

          return Stack(
            children: [
              // Imagem de fundo
              if (hasImage)
                Positioned.fill(
                  child: CachedNetworkImage(
                    imageUrl: data['imageUrl'],
                    fit: BoxFit.cover,
                  ),
                ),
              
              // Botões superiores (Voltar e Salvar)
              _buildTopButtons(context),

              // Conteúdo principal que pode ser arrastado
              DraggableScrollableSheet(
                initialChildSize: 0.6, // Começa em 60% da tela
                minChildSize: 0.6,
                maxChildSize: 0.9,
                builder: (BuildContext context, ScrollController scrollController) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
                    ),
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(24.0),
                      children: [
                        // Título e Localização
                        Text(
                          data['placeName'] ?? 'Sem nome',
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.grey, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'South, America', // Placeholder, pode ser substituído por dados reais
                              style: const TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // Abas (Overview / Detalhes)
                        // A implementação completa das abas pode ser adicionada aqui
                        const Text(
                          'Overview',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const Divider(height: 24),

                        // Ícones de Informação
                        _buildInfoRow(data),
                        const SizedBox(height: 24),

                        // Descrição
                        const Text(
                          'Descrição',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          data['description'] ?? 'Nenhuma descrição disponível.',
                          style: const TextStyle(color: Colors.black54, height: 1.5),
                        ),
                        const SizedBox(height: 80), // Espaço para o botão flutuante
                      ],
                    ),
                  );
                },
              ),
              
              // Botão "Traçar Rota"
              _buildTraceRouteButton(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopButtons(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildCircleButton(context, Icons.arrow_back, () => Navigator.of(context).pop()),
            _buildCircleButton(context, Icons.bookmark_border, () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton(BuildContext context, IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildInfoRow(Map<String, dynamic> data) {
    // Placeholder data
    final temperature = '32°C';
    final duration = '5:30-23:30 hrs';
    final averageRating = 4.9;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildInfoItem(Icons.access_time_filled, duration),
        _buildInfoItem(Icons.wb_sunny, temperature),
        _buildInfoItem(Icons.star, averageRating.toString()),
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.accentColor, size: 28),
        const SizedBox(height: 8),
        Text(text, style: const TextStyle(color: Colors.black54)),
      ],
    );
  }

  Widget _buildTraceRouteButton(BuildContext context) {
    return Align(
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
    );
  }
}
