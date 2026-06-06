import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/app_controller.dart';
import '../widgets/app_header.dart';
import 'report_detail_screen.dart';

class MyReportsScreen extends StatelessWidget {
  const MyReportsScreen({super.key});

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
    final controller = Get.find<AppController>();

    return Scaffold(
      body: Column(
        children: [
          const AppHeader(title: 'Mis reportes', showBack: true),
          Expanded(
            child: Obx(
              () {
                final myReports = controller.myReports;
                if (myReports.isEmpty) {
                  return const Center(child: Text('No tienes reportes'));
                }
                return RefreshIndicator(
                  onRefresh: controller.refreshMyReports,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: myReports.length,
                    itemBuilder: (context, index) {
                      final report = myReports[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        child: ListTile(
                          leading: Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child:
                                Center(child: _categoryIcon(report.categoria)),
                          ),
                          title: Text(report.titulo.isEmpty
                              ? 'Sin título'
                              : report.titulo),
                          subtitle: Text(
                              '${report.estado} • ${report.direccion.isEmpty ? 'Sin dirección' : report.direccion}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_forever,
                                color: Colors.redAccent),
                            onPressed: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Eliminar reporte'),
                                  content: const Text(
                                      '¿Estás seguro de que deseas eliminar este reporte?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancelar'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('Eliminar'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmed != true) return;

                              final error =
                                  await controller.deleteReport(report.id);
                              if (error != null) {
                                Get.snackbar('Error', error);
                              } else {
                                Get.snackbar('Reporte eliminado',
                                    'El reporte fue eliminado correctamente.');
                              }
                            },
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => ReportDetailScreen(
                                      report: report.toJson())),
                            );
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
