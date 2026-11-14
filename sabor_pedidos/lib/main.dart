import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/api_config.dart';
import 'core/app_theme.dart';
import 'data/api/api_client.dart';
import 'data/repositories/menu_repository.dart';
import 'data/repositories/pedido_repository.dart';
import 'providers/menu_provider.dart';
import 'providers/pedidos_provider.dart';
import 'screens/bienvenida_screen.dart';

/// Punto de entrada: aquí se arman las piezas de la app (cliente HTTP -> repositorios -> providers).
void main() {
  final cliente = ApiClient(
    baseUrl: ApiConfig.baseUrl,
    tiempoMaximo: ApiConfig.tiempoMaximo,
  );

  runApp(
    SaborPedidosApp(
      menuRepository: ApiMenuRepository(cliente),
      pedidoRepository: ApiPedidoRepository(cliente),
    ),
  );
}

/// Widget raíz de la aplicación. Recibe los repositorios por parámetro para que las pruebas
/// puedan usar datos falsos en lugar de la API real.
class SaborPedidosApp extends StatelessWidget {
  const SaborPedidosApp({
    super.key,
    required this.menuRepository,
    required this.pedidoRepository,
  });

  final MenuRepository menuRepository;
  final PedidoRepository pedidoRepository;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MenuProvider(menuRepository)),
        ChangeNotifierProvider(
          create: (_) => PedidosProvider(pedidoRepository),
        ),
      ],
      child: MaterialApp(
        title: 'Sabor Pedidos',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.claro,
        home: const BienvenidaScreen(),
      ),
    );
  }
}
