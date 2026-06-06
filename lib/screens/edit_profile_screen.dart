import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/app_controller.dart';
import '../models/user.dart';
import '../utils/platform_image.dart';
import '../widgets/app_header.dart';
import '../widgets/custom_input.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final controller = Get.find<AppController>();
  final nameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final birthdateController = TextEditingController();
  final passwordController = TextEditingController();
  DateTime? selectedBirthdate;
  String? profileImage;

  @override
  void initState() {
    super.initState();
    final user = controller.currentUser.value;
    if (user != null) {
      nameController.text = user.name;
      lastNameController.text = user.lastname;
      emailController.text = user.email;
      passwordController.text = '';
      profileImage = user.profileImage;
      if (user.birthdate != null) {
        selectedBirthdate = DateTime.tryParse(user.birthdate!);
        if (selectedBirthdate != null) {
          birthdateController.text =
              '${selectedBirthdate!.day.toString().padLeft(2, '0')}/${selectedBirthdate!.month.toString().padLeft(2, '0')}/${selectedBirthdate!.year}';
        }
      }
    }
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
        birthdateController.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  int _calculateAge(DateTime birthday) {
    final today = DateTime.now();
    var age = today.year - birthday.year;
    if (today.month < birthday.month ||
        (today.month == birthday.month && today.day < birthday.day)) {
      age--;
    }
    return age;
  }

  Future<void> _pickPhoto() async {
    await controller.pickProfileImage();
    setState(() {
      profileImage = controller.profileImagePath.value;
    });
  }

  Future<void> _saveProfile() async {
    if (nameController.text.isEmpty || lastNameController.text.isEmpty) {
      Get.snackbar('Error', 'Nombre y apellidos son obligatorios.');
      return;
    }

    if (selectedBirthdate == null) {
      Get.snackbar('Error', 'Selecciona tu fecha de nacimiento.');
      return;
    }

    final age = _calculateAge(selectedBirthdate!);
    if (age < 18) {
      Get.snackbar('Error', 'Debes ser mayor de edad.');
      return;
    }

    final currentUser = controller.currentUser.value;
    if (currentUser == null) {
      Get.snackbar('Error', 'No hay usuario activo para actualizar.');
      return;
    }

    final updatedProfileImage = controller.profileImagePath.value ??
        (controller.profileImageBytes.value != null
            ? 'data:image/png;base64,${base64Encode(controller.profileImageBytes.value!)}'
            : profileImage);

    final updatedUser = User(
      name: nameController.text.trim(),
      lastname: lastNameController.text.trim(),
      email: currentUser.email,
      password: passwordController.text.isEmpty
          ? currentUser.password
          : passwordController.text.trim(),
      birthdate: selectedBirthdate!.toIso8601String().split('T').first,
      profileImage: updatedProfileImage,
    );

    await controller.updateCurrentUser(updatedUser);
    Get.back();
    Get.snackbar('Éxito', 'Perfil actualizado correctamente');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(title: 'Editar perfil', showBack: true),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: _pickPhoto,
                        child: CircleAvatar(
                          radius: 52,
                          backgroundColor: Colors.blue.shade100,
                          child: profileImage == null || profileImage!.isEmpty
                              ? const Icon(Icons.camera_alt,
                                  size: 40, color: Colors.blue)
                              : ClipOval(
                                  child: Builder(builder: (context) {
                                    final profileBytes =
                                        controller.profileImageBytes.value;
                                    if (profileBytes != null) {
                                      return Image.memory(profileBytes,
                                          width: 104,
                                          height: 104,
                                          fit: BoxFit.cover);
                                    }
                                    final imagePath = profileImage!;
                                    if (imagePath.startsWith('data:')) {
                                      final base64Data =
                                          imagePath.split(',').last;
                                      try {
                                        final bytes = base64Decode(base64Data);
                                        return Image.memory(bytes,
                                            width: 104,
                                            height: 104,
                                            fit: BoxFit.cover);
                                      } catch (_) {
                                        return const Icon(Icons.person,
                                            size: 40, color: Colors.blue);
                                      }
                                    }
                                    if (imagePath.startsWith('http') ||
                                        imagePath.startsWith('https')) {
                                      return Image.network(
                                        imagePath,
                                        width: 104,
                                        height: 104,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return const Icon(Icons.person,
                                              size: 40, color: Colors.blue);
                                        },
                                      );
                                    }
                                    return buildLocalImage(imagePath,
                                        width: 104,
                                        height: 104,
                                        fit: BoxFit.cover);
                                  }),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
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
                      readOnly: true,
                    ),
                    const SizedBox(height: 14),
                    CustomInput(
                      icon: Icons.calendar_today,
                      hint: 'Fecha de nacimiento',
                      controller: birthdateController,
                      readOnly: true,
                      onTap: _selectBirthdate,
                    ),
                    const SizedBox(height: 14),
                    CustomInput(
                      icon: Icons.lock,
                      hint: 'Nueva contraseña (opcional)',
                      controller: passwordController,
                      isPassword: true,
                    ),
                    const SizedBox(height: 28),
                    ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        minimumSize: const Size(double.infinity, 56),
                      ),
                      child: const Text('Guardar cambios',
                          style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
