import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'login_screen.dart';
import '../controllers/app_controller.dart';
import '../utils/platform_image.dart';
import '../widgets/app_header.dart';
import 'settings_screen.dart';
import 'my_reports_screen.dart';
import 'notifications_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AppController>();

    return Scaffold(
      body: SafeArea(
        child: Obx(
          () {
            final user = controller.currentUser.value;
            return user == null
                ? _buildGuestView(context)
                : _buildUserView(context, controller);
          },
        ),
      ),
    );
  }

  Widget _buildGuestView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_outline, size: 90, color: Colors.grey),
            const SizedBox(height: 20),
            const Text(
              'No has iniciado sesión',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Inicia sesión para ver tu perfil, reportes y preferencias guardadas.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: const Text('Iniciar sesión'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserView(BuildContext context, AppController controller) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const AppHeader(title: 'Mi perfil'),
          const SizedBox(height: 20),
          Obx(
            () {
              final profileImage = controller.currentUser.value?.profileImage;

              Widget imageWidget() {
                if (profileImage == null || profileImage.isEmpty) {
                  return const Icon(Icons.person,
                      size: 48, color: Colors.white);
                }
                if (profileImage.startsWith('data:')) {
                  final base64Data = profileImage.split(',').last;
                  try {
                    final bytes = base64Decode(base64Data);
                    return Image.memory(bytes,
                        width: 100, height: 100, fit: BoxFit.cover);
                  } catch (_) {
                    return const Icon(Icons.person,
                        size: 48, color: Colors.white);
                  }
                }
                if (profileImage.startsWith('http') ||
                    profileImage.startsWith('https')) {
                  return Image.network(
                    profileImage,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.person,
                          size: 48, color: Colors.white);
                    },
                  );
                }
                return buildLocalImage(profileImage,
                    width: 100, height: 100, fit: BoxFit.cover);
              }

              return CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blue.shade100,
                child: ClipOval(child: imageWidget()),
              );
            },
          ),
          const SizedBox(height: 14),
          Text(
            '${controller.currentUser.value!.name} ${controller.currentUser.value!.lastname}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(controller.currentUser.value!.email),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  ProfileOption(
                    icon: Icons.edit,
                    text: 'Editar perfil',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const EditProfileScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ProfileOption(
                    icon: Icons.settings,
                    text: 'Configuración',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SettingsScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ProfileOption(
                    icon: Icons.report,
                    text: 'Mis reportes',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const MyReportsScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ProfileOption(
                    icon: Icons.notifications,
                    text: 'Notificaciones',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const NotificationsScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton.icon(
                  onPressed: () {
                    controller.logout();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text('Cerrar sesión',
                      style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class ProfileOption extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const ProfileOption({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(text),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
