import 'package:flutter/material.dart';
import '../widgets/app_header.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool reportUpdates = true;
  bool safetyAlerts = true;
  bool communityNews = false;

  @override
  Widget build(BuildContext context) {
    final notifications = [
      {
        'title': 'Reporte actualizado',
        'subtitle': 'Tu reporte ha cambiado de estado a En proceso.',
        'enabled': reportUpdates,
      },
      {
        'title': 'Consejo de seguridad',
        'subtitle': 'Revisa las medidas de seguridad al reportar en la calle.',
        'enabled': safetyAlerts,
      },
      {
        'title': 'Nueva comunidad cerca',
        'subtitle': 'Se ha activado un grupo de vecinos para mejorar la zona.',
        'enabled': communityNews,
      },
    ];

    return Scaffold(
      body: Column(
        children: [
          const AppHeader(title: 'Notificaciones', showBack: true),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text('Preferencias',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Actualizaciones de reportes'),
                  subtitle: const Text(
                      'Recibe avisos cuando tu reporte cambie de estado.'),
                  value: reportUpdates,
                  onChanged: (value) {
                    setState(() {
                      reportUpdates = value;
                    });
                  },
                  secondary: const Icon(Icons.report),
                ),
                SwitchListTile(
                  title: const Text('Alertas de seguridad'),
                  subtitle:
                      const Text('Recibe consejos y avisos de seguridad.'),
                  value: safetyAlerts,
                  onChanged: (value) {
                    setState(() {
                      safetyAlerts = value;
                    });
                  },
                  secondary: const Icon(Icons.warning),
                ),
                SwitchListTile(
                  title: const Text('Novedades locales'),
                  subtitle:
                      const Text('Recibe noticias y reportes de tu barrio.'),
                  value: communityNews,
                  onChanged: (value) {
                    setState(() {
                      communityNews = value;
                    });
                  },
                  secondary: const Icon(Icons.public),
                ),
                const SizedBox(height: 20),
                const Text('Notificaciones recientes',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                for (final item in notifications)
                  if (item['enabled'] as bool)
                    Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        leading:
                            const Icon(Icons.notifications, color: Colors.blue),
                        title: Text(item['title'] as String),
                        subtitle: Text(item['subtitle'] as String),
                      ),
                    ),
                if (!notifications.any((item) => item['enabled'] as bool))
                  const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Column(
                      children: [
                        Icon(Icons.notifications_off,
                            size: 48, color: Colors.grey),
                        SizedBox(height: 12),
                        Text('No hay notificaciones activas',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
