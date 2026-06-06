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
    final theme = Theme.of(context);

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
                      Text(
                        'Explorar incidencias',
                        style: theme.textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
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
                          fillColor: theme.inputDecorationTheme.fillColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text('Sugerencias de categorías',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
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
                            selectedColor:
                                theme.colorScheme.primary.withOpacity(0.2),
                            backgroundColor:
                                theme.colorScheme.primary.withOpacity(0.1),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: controller.filteredReports.isEmpty
                            ? Center(
                                child: Text('No hay resultados',
                                    style: theme.textTheme.bodyMedium),
                              )
                            : RefreshIndicator(
                                onRefresh: controller.refreshReports,
                                child: ListView.builder(
                                  itemCount: controller.filteredReports.length,
                                  itemBuilder: (context, index) {
                                    final report =
                                        controller.filteredReports[index];
                                    return Card(
                                      color: theme.cardColor,
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
                                            color: theme.colorScheme.primary
                                                .withOpacity(0.12),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Center(
                                            child:
                                                _categoryIcon(report.categoria),
                                          ),
                                        ),
                                        title: Text(
                                          report.titulo.isEmpty
                                              ? 'Sin título'
                                              : report.titulo,
                                          style: theme.textTheme.titleMedium,
                                        ),
                                        subtitle: Text(
                                          '${report.estado} • ${report.direccion.isEmpty ? 'Sin dirección' : report.direccion}',
                                          style: theme.textTheme.bodySmall,
                                        ),
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
