import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb; // Importa o kIsWeb
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geolocator/geolocator.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class AddPostPage extends StatefulWidget {
  const AddPostPage({super.key});

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final _formKey = GlobalKey<FormState>();
  final _placeNameController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Vamos usar XFile, que é o tipo retornado pelo image_picker e funciona em todas as plataformas
  XFile? _imageFile;
  LatLng? _selectedLocation;
  bool _isLoading = false;

  double _easyAccessRating = 3.0;
  double _amenitiesRating = 3.0;
  double _accessibilityRating = 3.0;

  final MapController _mapController = MapController();
  static final LatLng _initialCenter = LatLng(-14.2350, -51.9253);

  @override
  void initState() {
    super.initState();
    _determinePositionAndMoveCamera();
  }

  Future<void> _determinePositionAndMoveCamera() async {
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final userLocation = LatLng(position.latitude, position.longitude);
      _mapController.move(userLocation, 13.0);
      setState(() {
        _selectedLocation = userLocation;
      });
    } catch (e) {
      print("Erro ao obter localização inicial: $e");
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  Future<void> _submitPost() async {
    if (_formKey.currentState!.validate() && _imageFile != null && _selectedLocation != null) {
      setState(() => _isLoading = true);

      try {
        final user = FirebaseAuth.instance.currentUser!;
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('post_images')
            .child('${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg');
        
        // CORREÇÃO: Lógica de upload diferente para web e mobile
        if (kIsWeb) {
          await storageRef.putData(await _imageFile!.readAsBytes());
        } else {
          await storageRef.putFile(File(_imageFile!.path));
        }
        
        final imageUrl = await storageRef.getDownloadURL();

        final userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        final username = userData.data()?['username'] ?? 'Usuário Anônimo';

        await FirebaseFirestore.instance.collection('posts').add({
          'placeName': _placeNameController.text,
          'description': _descriptionController.text,
          'imageUrl': imageUrl,
          'location': GeoPoint(_selectedLocation!.latitude, _selectedLocation!.longitude),
          'ratings': {
            'easyAccess': _easyAccessRating,
            'amenities': _amenitiesRating,
            'accessibility': _accessibilityRating,
          },
          'authorId': user.uid,
          'authorName': username,
          'createdAt': Timestamp.now(),
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post criado com sucesso!')),
          );
          Navigator.of(context).pop();
        }

      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao criar o post: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } else {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha todos os campos, adicione uma imagem e selecione um local no mapa.')),
      );
    }
  }

  Widget _buildRatingBar(String title, ValueChanged<double> onRatingUpdate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        RatingBar.builder(
          initialRating: 3,
          minRating: 1,
          direction: Axis.horizontal,
          allowHalfRating: true,
          itemCount: 5,
          itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
          itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
          onRatingUpdate: onRatingUpdate,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adicionar Novo Local')),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _placeNameController,
                    decoration: const InputDecoration(labelText: 'Nome do Local'),
                    validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Descrição'),
                    maxLines: 3,
                     validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
                  ),
                  const SizedBox(height: 24),
                  Center(
                    // CORREÇÃO: Lógica para exibir a imagem na web e no mobile
                    child: _imageFile == null
                        ? const Text('Nenhuma imagem selecionada.')
                        : kIsWeb
                            ? Image.network(_imageFile!.path, height: 200)
                            : Image.file(File(_imageFile!.path), height: 200),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.image),
                    label: const Text('Selecionar Imagem'),
                    onPressed: _pickImage,
                  ),
                  const SizedBox(height: 24),
                  const Text('Toque no mapa para selecionar o local:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Container(
                    height: 300,
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _initialCenter,
                        initialZoom: 4.0,
                        onTap: (tapPosition, point) {
                          setState(() {
                            _selectedLocation = point;
                          });
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.travelmap3',
                        ),
                        if (_selectedLocation != null)
                          MarkerLayer(
                            markers: [
                              Marker(
                                width: 80.0,
                                height: 80.0,
                                point: _selectedLocation!,
                                child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildRatingBar('Fácil Acesso', (rating) => setState(() => _easyAccessRating = rating)),
                  _buildRatingBar('Comodidades', (rating) => setState(() => _amenitiesRating = rating)),
                  _buildRatingBar('Acessibilidade', (rating) => setState(() => _accessibilityRating = rating)),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _submitPost,
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: const Text('Salvar Post'),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
