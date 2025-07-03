import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:travelmap3/post_detail_page.dart';

class MapViewPage extends StatefulWidget {
  const MapViewPage({super.key});

  @override
  State<MapViewPage> createState() => _MapViewPageState();
}

class _MapViewPageState extends State<MapViewPage> {
  final MapController _mapController = MapController();
  LatLng? _initialCenter; // Inicia como nulo
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    _determineInitialPosition();
  }

  Future<void> _determineInitialPosition() async {
    try {
      // Pede permissão e obtém a localização
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('Serviço de localização desabilitado.');
      
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) throw Exception('Permissão negada.');
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Permissão negada permanentemente.');
      } 
      
      Position position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _initialCenter = LatLng(position.latitude, position.longitude);
          _isMapReady = true;
        });
      }
    } catch (e) {
      print("Não foi possível obter a localização: $e");
      // Se falhar, usa a localização padrão e deixa o mapa pronto
      if (mounted) {
        setState(() {
          _initialCenter = LatLng(-14.2350, -51.9253); // Centro do Brasil
          _isMapReady = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Locais'),
      ),
      body: !_isMapReady 
        ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(), SizedBox(height: 10), Text("Obtendo localização...")]))
        : StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('posts').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final List<Marker> markers = snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final geoPoint = data['location'] as GeoPoint;
                return Marker(
                  width: 40.0,
                  height: 40.0,
                  point: LatLng(geoPoint.latitude, geoPoint.longitude),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PostDetailPage(postId: doc.id)),
                      );
                    },
                    child: const Icon(Icons.location_pin, color: Colors.red, size: 40.0),
                  ),
                );
              }).toList();

              return FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _initialCenter!,
                  initialZoom: 13.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  ),
                  MarkerLayer(markers: markers),
                ],
              );
            },
          ),
    );
  }
}