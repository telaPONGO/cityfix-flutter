import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/app_controller.dart';
import '../widgets/app_header.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AppController>();

    return Scaffold(
      body: Column(
        children: [
          const AppHeader(title: 'Configuración', showBack: true),
          const SizedBox(height: 20),
          Obx(
            () => SwitchListTile(
              secondary: const Icon(Icons.dark_mode),
              title: const Text('Modo oscuro'),
              value: controller.isDarkMode.value,
              onChanged: (value) {
                controller.changeTheme(value);
              },
            ),
          ),
          const ListTile(
            leading: Icon(Icons.lock),
            title: Text('Privacidad'),
            subtitle: Text(
                'Tus datos se usan localmente y pueden sincronizarse en el backend'),
          ),
        ],
      ),
    );
  }
}
