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
    final theme = Theme.of(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              Text(
                'Bienvenido a CityFix',
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Accede para guardar tus reportes y usar tus preferencias.',
                style: theme.textTheme.bodyMedium,
              ),
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
                  backgroundColor: theme.colorScheme.primary,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('Entrar',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontSize: 16,
                    )),
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
                icon: Icon(Icons.login,
                    color: theme.colorScheme.onSurface.withOpacity(0.9)),
                label: Text('Continuar con Google',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.9),
                      fontSize: 16,
                    )),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.surface,
                  foregroundColor: theme.colorScheme.onSurface,
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
