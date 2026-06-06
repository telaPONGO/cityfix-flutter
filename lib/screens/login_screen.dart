import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'register_screen.dart';
import 'main_navigation.dart';
import '../controllers/app_controller.dart';
import '../widgets/custom_input.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passController = TextEditingController();
  final controller = Get.find<AppController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              const Text(
                'Bienvenido a CityFix',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                  'Accede para guardar tus reportes y usar tus preferencias.'),
              const SizedBox(height: 30),
              CustomInput(
                icon: Icons.email,
                hint: 'Correo electrónico',
                controller: emailController,
              ),
              const SizedBox(height: 18),
              CustomInput(
                icon: Icons.lock,
                hint: 'Contraseña',
                controller: passController,
                isPassword: true,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  final success = await controller.login(
                    emailController.text.trim(),
                    passController.text.trim(),
                  );
                  if (!success) {
                    Get.snackbar('Error', 'Credenciales incorrectas');
                    return;
                  }
                  Get.offAll(const MainNavigation());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Entrar', style: TextStyle(fontSize: 16)),
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
                  Get.offAll(const MainNavigation());
                },
                icon: const Icon(Icons.login, color: Colors.black87),
                label: const Text('Continuar con Google',
                    style: TextStyle(color: Colors.black87, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 18),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    );
                  },
                  child: const Text('¿No tienes cuenta? Regístrate aquí',
                      style: TextStyle(decoration: TextDecoration.underline)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
