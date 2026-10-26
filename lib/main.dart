import 'package:flutter/material.dart';

import 'core/app_theme.dart';
import 'screens/bienvenida_screen.dart';

void main() {
  runApp(const SaborPedidosApp());
}

/// Widget raíz de la aplicación.
class SaborPedidosApp extends StatelessWidget {
  const SaborPedidosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sabor Pedidos',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.claro,
      home: const BienvenidaScreen(),
    );
  }
}
