import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/app_controller.dart';
import '../utils/platform_image.dart';
import '../widgets/custom_input.dart';
import '../models/user.dart';
import 'main_navigation.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final dateController = TextEditingController();
  final passController = TextEditingController();
  final controller = Get.find<AppController>();
  DateTime? selectedBirthdate;

  int _calculateAge(DateTime birthday) {
    final today = DateTime.now();
    var age = today.year - birthday.year;
    if (today.month < birthday.month ||
        (today.month == birthday.month && today.day < birthday.day)) {
      age--;
    }
    return age;
  }

  Future<void> _selectBirthdate() async {
    final today = DateTime.now();
    final firstDate = DateTime(today.year - 100, today.month, today.day);
    final lastDate = DateTime(today.year - 18, today.month, today.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedBirthdate ?? lastDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: 'Selecciona tu fecha de nacimiento',
    );
    if (picked != null) {
      setState(() {
        selectedBirthdate = picked;
        dateController.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              const Text(
                'Crea tu cuenta',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                  'Regístrate para guardar tus reportes y preferencias.'),
              const SizedBox(height: 28),
              Obx(
                () {
                  final profileImage = controller.profileImagePath.value;
                  final profileBytes = controller.profileImageBytes.value;

                  Widget imageWidget() {
                    if (profileBytes != null) {
                      return Image.memory(profileBytes,
                          width: 92, height: 92, fit: BoxFit.cover);
                    }
                    if (profileImage == null || profileImage.isEmpty) {
                      return const Icon(Icons.camera_alt,
                          size: 34, color: Colors.blue);
                    }
                    if (profileImage.startsWith('http') ||
                        profileImage.startsWith('https')) {
                      return Image.network(profileImage,
                          width: 92, height: 92, fit: BoxFit.cover);
                    }
                    return buildLocalImage(profileImage,
                        width: 92, height: 92, fit: BoxFit.cover);
                  }

                  return GestureDetector(
                    onTap: controller.pickProfileImage,
                    child: CircleAvatar(
                      radius: 46,
                      backgroundColor: Colors.blue.shade100,
                      child: ClipOval(child: imageWidget()),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              CustomInput(
                icon: Icons.person,
                hint: 'Nombres',
                controller: nameController,
              ),
              const SizedBox(height: 14),
              CustomInput(
                icon: Icons.person,
                hint: 'Apellidos',
                controller: lastNameController,
              ),
              const SizedBox(height: 14),
              CustomInput(
                icon: Icons.email,
                hint: 'Correo electrónico',
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),
              CustomInput(
                icon: Icons.calendar_today,
                hint: 'Fecha de nacimiento',
                controller: dateController,
                readOnly: true,
                onTap: _selectBirthdate,
              ),
              const SizedBox(height: 14),
              CustomInput(
                icon: Icons.lock,
                hint: 'Contraseña',
                controller: passController,
                isPassword: true,
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 56),
                ),
                onPressed: () async {
                  if (nameController.text.isEmpty ||
                      lastNameController.text.isEmpty ||
                      emailController.text.isEmpty ||
                      passController.text.isEmpty ||
                      selectedBirthdate == null) {
                    Get.snackbar('Error',
                        'Completa todos los campos y selecciona tu fecha de nacimiento.');
                    return;
                  }

                  final age = _calculateAge(selectedBirthdate!);
                  if (age < 18) {
                    Get.snackbar(
                        'Error', 'Debes ser mayor de edad para registrarte.');
                    return;
                  }

                  final profileImage = controller.profileImagePath.value ??
                      (controller.profileImageBytes.value != null
                          ? 'data:image/png;base64,${base64Encode(controller.profileImageBytes.value!)}'
                          : null);

                  final user = User(
                    name: nameController.text.trim(),
                    lastname: lastNameController.text.trim(),
                    email: emailController.text.trim(),
                    password: passController.text.trim(),
                    birthdate:
                        selectedBirthdate!.toIso8601String().split('T').first,
                    profileImage: profileImage,
                  );

                  final created = await controller.register(user);
                  if (!created) {
                    Get.snackbar('Error', 'El correo ya está registrado');
                    return;
                  }

                  Get.back();
                  Get.snackbar('Éxito', 'Usuario registrado correctamente');
                },
                child:
                    const Text('Registrarse', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: () async {
                  final success = await controller.signInWithGoogle();
                  if (!success) {
                    Get.snackbar(
                        'Error', 'No se pudo iniciar sesión con Google');
                    return;
                  }
                  Get.offAll(() => const MainNavigation());
                },
                icon: const Icon(Icons.login, color: Colors.black87),
                label: const Text('Registrarse con Google',
                    style: TextStyle(color: Colors.black87, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
