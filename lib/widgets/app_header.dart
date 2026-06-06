import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final bool showBack;

  const AppHeader({
    super.key,
    required this.title,
    this.showBack = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final primaryContainer = theme.colorScheme.primaryContainer;
    final onPrimary = theme.colorScheme.onPrimary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary, primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          if (showBack)
            IconButton(
              icon: Icon(Icons.arrow_back, color: onPrimary),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          Expanded(
            child: Center(
              child: Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          if (showBack) const SizedBox(width: 48),
        ],
      ),
    );
  }
}
