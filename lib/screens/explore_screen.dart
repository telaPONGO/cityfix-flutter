import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/app_controller.dart';
import '../widgets/app_header.dart';
import 'report_detail_screen.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

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
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(title: 'Explorar'),
            const SizedBox(height: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Explorar incidencias',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        onChanged: (value) {
                          controller.searchText.value = value;
                        },
                        decoration: InputDecoration(
                          hintText: 'Buscar reportes...',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text('Sugerencias de categorías',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: controller.categories.map((text) {
                          final selected = controller.searchText.value == text;
                          return ChoiceChip(
                            label: Text(text),
                            selected: selected,
                            onSelected: (v) {
                              if (v) {
                                controller.searchText.value =
                                    text.toLowerCase();
                              } else {
                                controller.searchText.value = '';
                              }
                            },
                            selectedColor: Colors.blue.shade100,
                            backgroundColor: Colors.blue.shade50,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: controller.filteredReports.isEmpty
                            ? const Center(child: Text('No hay resultados'))
                            : RefreshIndicator(
                                onRefresh: controller.refreshReports,
                                child: ListView.builder(
                                  itemCount: controller.filteredReports.length,
                                  itemBuilder: (context, index) {
                                    final report =
                                        controller.filteredReports[index];
                                    return Card(
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16)),
                                      margin: const EdgeInsets.only(bottom: 12),
                                      child: ListTile(
                                        leading: Container(
                                          width: 46,
                                          height: 46,
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade50,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Center(
                                            child:
                                                _categoryIcon(report.categoria),
                                          ),
                                        ),
                                        title: Text(report.titulo.isEmpty
                                            ? 'Sin título'
                                            : report.titulo),
                                        subtitle: Text(
                                            '${report.estado} • ${report.direccion.isEmpty ? 'Sin dirección' : report.direccion}'),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  ReportDetailScreen(
                                                      report: report.toJson()),
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
