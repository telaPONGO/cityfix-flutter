import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../utils/platform_image.dart';
import '../widgets/app_header.dart';

class ReportDetailScreen extends StatelessWidget {
  final Map report;

  const ReportDetailScreen({super.key, required this.report});

  Widget _buildInfoChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildImageCard() {
    final path = report['imagePath'] as String?;
    return Container(
      height: 260,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Builder(builder: (context) {
          if (path == null || path.isEmpty) {
            return Container(
              color: Colors.grey[300],
              child: const Center(
                child: Icon(Icons.image, size: 72, color: Colors.white70),
              ),
            );
          }
          // Handle base64 encoded images
          if (path.startsWith('data:')) {
            final base64Data = path.split(',').last;
            try {
              final bytes = base64Decode(base64Data);
              return Image.memory(bytes, fit: BoxFit.cover);
            } catch (_) {
              return Container(
                color: Colors.grey[300],
                child: const Center(
                  child:
                      Icon(Icons.broken_image, size: 72, color: Colors.white70),
                ),
              );
            }
          }
          // Handle HTTP/HTTPS URLs from server
          if (path.startsWith('http://') || path.startsWith('https://')) {
            return Image.network(
              path,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.broken_image,
                        size: 72, color: Colors.white70),
                  ),
                );
              },
            );
          }
          // Handle local file paths (non-web)
          if (!kIsWeb) {
            return buildLocalImage(path, fit: BoxFit.cover);
          }
          return Container(
            color: Colors.grey[300],
            child: const Center(
              child: Icon(Icons.image, size: 72, color: Colors.white70),
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = report['titulo'] ?? 'Sin título';
    final description = report['descripcion'] ?? 'Sin descripción';
    final address = report['direccion'] ?? 'Sin dirección';
    final category = report['categoria'] ?? 'General';
    final status = report['estado'] ?? 'Pendiente';
    final userName = report['userName']?.toString();
    final userLastname = report['userLastname']?.toString();
    final author = (userName != null && userName.isNotEmpty)
        ? '$userName ${userLastname ?? ''}'.trim()
        : report['user']?.toString() ?? 'Anónimo';
    final latitude = report['latitude'];
    final longitude = report['longitude'];
    final lat = latitude is num
        ? latitude.toDouble()
        : double.tryParse(latitude?.toString() ?? '');
    final lng = longitude is num
        ? longitude.toDouble()
        : double.tryParse(longitude?.toString() ?? '');

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FF),
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(title: 'Detalle del reporte', showBack: true),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildImageCard(),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _buildInfoChip(category, Colors.indigo),
                                const SizedBox(width: 10),
                                _buildInfoChip(status, Colors.orange),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                const Icon(Icons.person, color: Colors.grey),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Reportado por $author',
                                    style:
                                        const TextStyle(color: Colors.black87),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.location_on,
                                    color: Colors.blue),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    address,
                                    style: const TextStyle(
                                        color: Colors.black87, height: 1.5),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (lat != null && lng != null) ...[
                        const SizedBox(height: 20),
                        Text(
                          'Ubicación exacta',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[900],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          height: 220,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 16,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: FlutterMap(
                              options: MapOptions(
                                center: LatLng(lat, lng),
                                zoom: 15,
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  subdomains: const ['a', 'b', 'c'],
                                  userAgentPackageName: 'com.example.cityfix',
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      width: 48,
                                      height: 48,
                                      point: LatLng(lat, lng),
                                      builder: (context) => const Icon(
                                        Icons.location_on,
                                        color: Colors.red,
                                        size: 40,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Coordenadas: ${lat.toStringAsFixed(5)} / ${lng.toStringAsFixed(5)}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Descripción',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              description,
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.6,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
