import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'report_screen.dart';
import 'report_detail_screen.dart';
import '../controllers/app_controller.dart';
import '../widgets/app_header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Icon _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'alumbrado':
        return const Icon(Icons.lightbulb, color: Colors.red);
      case 'vialidad':
        return const Icon(Icons.traffic, color: Colors.orange);
      case 'seguridad':
        return const Icon(Icons.shield, color: Colors.green);
      case 'limpieza':
        return const Icon(Icons.cleaning_services, color: Colors.teal);
      default:
        return const Icon(Icons.report, color: Colors.blue);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppController controller = Get.find<AppController>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(title: 'Inicio'),
            const SizedBox(height: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Obx(
                  () {
                    final recentReports = controller.reports.reversed.toList();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  controller.currentUser.value == null
                                      ? 'Hola, visitante'
                                      : 'Hola, ${controller.currentUser.value!.name}',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Crea reportes con ubicación real y fotos desde tu dispositivo.',
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.add_box_outlined),
                                  label: const Text('Crear nuevo reporte'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    minimumSize:
                                        const Size(double.infinity, 52),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => const ReportScreen()),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Reportes recientes',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${recentReports.length} totales',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Expanded(
                          child: recentReports.isEmpty
                              ? const Center(child: Text('No hay reportes aún'))
                              : RefreshIndicator(
                                  onRefresh: controller.refreshReports,
                                  child: ListView.builder(
                                    itemCount: recentReports.length,
                                    itemBuilder: (context, index) {
                                      final report = recentReports[index];
                                      return Card(
                                        elevation: 2,
                                        margin:
                                            const EdgeInsets.only(bottom: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: ListTile(
                                          leading: Container(
                                            height: 48,
                                            width: 48,
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Center(
                                              child: _categoryIcon(
                                                  report.categoria),
                                            ),
                                          ),
                                          title: Text(report.titulo.isEmpty
                                              ? 'Sin título'
                                              : report.titulo),
                                          subtitle: Text(
                                            '${report.estado} • ${report.direccion.isEmpty ? 'Sin dirección' : report.direccion}',
                                          ),
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    ReportDetailScreen(
                                                        report:
                                                            report.toJson()),
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
