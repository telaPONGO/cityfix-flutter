import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/app_controller.dart';
import '../utils/platform_image.dart';
import '../widgets/app_header.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final descController = TextEditingController();
  final addressController = TextEditingController();
  final titleController = TextEditingController();
  final AppController controller = Get.find<AppController>();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    controller.loadCurrentLocation();
  }

  Future<void> _showImageSourceSheet() async {
    const isWeb = kIsWeb;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Seleccionar de la galería'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
              if (!isWeb)
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Tomar una foto'),
                  onTap: () => Navigator.of(context).pop(ImageSource.camera),
                ),
              if (isWeb)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Text(
                    'La cámara no está disponible en la versión web. Usa un dispositivo móvil para tomar una foto.',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
            ],
          ),
        );
      },
    );

    if (source != null) {
      await controller.pickImage(source);
    }
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey[900],
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildInputCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildPhotoCard() {
    return Obx(
      () => GestureDetector(
        onTap: _showImageSourceSheet,
        child: Container(
          height: 220,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: (controller.selectedImagePath.value == null &&
                  controller.selectedImageBytes.value == null)
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(14),
                      child: const Icon(Icons.photo_camera,
                          size: 36, color: Colors.white),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Agregar imagen del reporte',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Toca para seleccionar una foto o tomar una nueva',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.blueGrey[700]),
                    ),
                  ],
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Builder(builder: (context) {
                    final bytes = controller.selectedImageBytes.value;
                    final path = controller.selectedImagePath.value;
                    if (bytes != null) {
                      return Image.memory(bytes, fit: BoxFit.cover);
                    }
                    if (path != null && path.startsWith('data:')) {
                      final base64Data = path.split(',').last;
                      try {
                        final bytes = base64Decode(base64Data);
                        return Image.memory(bytes, fit: BoxFit.cover);
                      } catch (_) {
                        return const Center(
                          child: Icon(Icons.broken_image,
                              size: 48, color: Colors.blue),
                        );
                      }
                    }
                    return buildLocalImage(path ?? '', fit: BoxFit.cover);
                  }),
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const AppHeader(title: 'Crear reporte', showBack: true),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildPhotoCard(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Ubicación actual'),
                    const SizedBox(height: 12),
                    _buildInputCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: addressController,
                            decoration: InputDecoration(
                              hintText: 'Ej: Calle 10 #23-45',
                              prefixIcon: const Icon(Icons.location_on),
                              filled: true,
                              fillColor: const Color(0xFFF7F9FF),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    final ok =
                                        await controller.loadCurrentLocation();
                                    if (!ok) {
                                      Get.snackbar('Atención',
                                          'No se pudo obtener la ubicación. Revisa permisos.');
                                    } else {
                                      Get.snackbar(
                                          'Listo', 'Ubicación actualizada.');
                                    }
                                  },
                                  icon: const Icon(Icons.my_location),
                                  label: const Text('Usar ubicación actual'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Obx(
                            () {
                              final position = controller.currentPosition.value;
                              return Text(
                                position == null
                                    ? 'Aún no hay coordenadas'
                                    : 'Lat: ${position.latitude.toStringAsFixed(5)}, Lon: ${position.longitude.toStringAsFixed(5)}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Detalles del reporte'),
                    const SizedBox(height: 12),
                    _buildInputCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(
                            () => DropdownButtonFormField<String>(
                              value: controller.selectedCategory.value,
                              items: controller.categories
                                  .map((category) => DropdownMenuItem(
                                        value: category,
                                        child: Text(category),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  controller.selectedCategory.value = value;
                                }
                              },
                              decoration: InputDecoration(
                                labelText: 'Categoría',
                                filled: true,
                                fillColor: const Color(0xFFF7F9FF),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          TextField(
                            controller: titleController,
                            decoration: InputDecoration(
                              labelText: 'Título del reporte',
                              hintText: 'Ej: Hueco peligroso en la vía',
                              filled: true,
                              fillColor: const Color(0xFFF7F9FF),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          TextField(
                            controller: descController,
                            maxLines: 5,
                            decoration: InputDecoration(
                              labelText: 'Descripción del problema',
                              alignLabelWithHint: true,
                              filled: true,
                              fillColor: const Color(0xFFF7F9FF),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSending
                            ? null
                            : () async {
                                if (controller.currentUser.value == null) {
                                  Get.snackbar('Error',
                                      'Debes iniciar sesión para enviar un reporte.');
                                  return;
                                }
                                if (titleController.text.isEmpty ||
                                    descController.text.isEmpty) {
                                  Get.snackbar('Atención',
                                      'Completa título y descripción antes de enviar.');
                                  return;
                                }

                                setState(() {
                                  _isSending = true;
                                });

                                final error = await controller.addReport(
                                  titulo: titleController.text,
                                  descripcion: descController.text,
                                  direccion: addressController.text.isEmpty
                                      ? 'No disponible'
                                      : addressController.text,
                                );

                                setState(() {
                                  _isSending = false;
                                });

                                if (error == null) {
                                  Get.snackbar('Éxito',
                                      'Reporte enviado correctamente.');
                                  titleController.clear();
                                  descController.clear();
                                  addressController.clear();
                                } else {
                                  Get.snackbar('Error', error);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo[700],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                        ),
                        child: _isSending
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.2,
                                ),
                              )
                            : const Text(
                                'Enviar reporte',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
