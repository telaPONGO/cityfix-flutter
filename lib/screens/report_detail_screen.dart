import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/api_service.dart';
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

  String _normalizeImageUrl(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    final apiOrigin = ApiService.baseUrl.replaceFirst(RegExp(r'/api$'), '');
    if (path.startsWith('/')) {
      return '$apiOrigin$path';
    }
    return '$apiOrigin/$path';
  }

  Widget _buildImageCard(BuildContext context) {
    final theme = Theme.of(context);
    final path = report['imagePath'] as String?;
    return Container(
      height: 260,
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.08),
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
              color: theme.colorScheme.surface,
              child: Center(
                child: Icon(Icons.image,
                    size: 72,
                    color: theme.colorScheme.onSurface.withOpacity(0.35)),
              ),
            );
          }
          if (path.startsWith('data:')) {
            final base64Data = path.split(',').last;
            try {
              final bytes = base64Decode(base64Data);
              return Image.memory(bytes, fit: BoxFit.cover);
            } catch (_) {
              return Container(
                color: theme.colorScheme.surface,
                child: Center(
                  child: Icon(Icons.broken_image,
                      size: 72,
                      color: theme.colorScheme.onSurface.withOpacity(0.35)),
                ),
              );
            }
          }
          final imageUrl = _normalizeImageUrl(path);
          if (imageUrl.startsWith('http://') ||
              imageUrl.startsWith('https://')) {
            return Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: theme.colorScheme.surface,
                  child: Center(
                    child: Icon(Icons.broken_image,
                        size: 72,
                        color: theme.colorScheme.onSurface.withOpacity(0.35)),
                  ),
                );
              },
            );
          }
          if (!kIsWeb) {
            return buildLocalImage(path, fit: BoxFit.cover);
          }
          return Container(
            color: theme.colorScheme.surface,
            child: Center(
              child: Icon(Icons.image,
                  size: 72,
                  color: theme.colorScheme.onSurface.withOpacity(0.35)),
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

    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
                      _buildImageCard(context),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: theme.shadowColor.withOpacity(0.08),
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
                              style: theme.textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
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
                                Icon(Icons.person,
                                    color: theme.colorScheme.onSurfaceVariant),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Reportado por $author',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.location_on,
                                    color: theme.colorScheme.primary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    address,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.onSurface,
                                        height: 1.5),
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
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
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
                                color: theme.shadowColor.withOpacity(0.08),
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
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      Text(
                        description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                          height: 1.5,
                        ),
                      ),
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
