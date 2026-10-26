import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../data/sesion.dart';
import 'bienvenida_screen.dart';
import 'carta_screen.dart';
import 'lista_pedidos_screen.dart';
import 'nuevo_pedido_screen.dart';

/// Pantalla 3: menú principal. Las opciones dependen del rol.
class MenuPrincipalScreen extends StatelessWidget {
  const MenuPrincipalScreen({super.key});

  void _abrir(BuildContext context, Widget pantalla) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => pantalla));
  }

  void _cerrarSesion(BuildContext context) {
    Sesion.cerrar();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const BienvenidaScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rol = Sesion.rol;

    // Lista de opciones; solo se agregan las que el rol puede usar.
    final opciones = <_Opcion>[
      if (rol.puedeCrearPedidos)
        _Opcion(
          titulo: 'Nuevo pedido',
          icono: Icons.add_shopping_cart,
          pantalla: const NuevoPedidoScreen(),
        ),
      _Opcion(
        titulo: 'Pedidos',
        icono: Icons.receipt_long,
        pantalla: const ListaPedidosScreen(),
      ),
      _Opcion(
        titulo: 'Carta del menú',
        icono: Icons.menu_book,
        pantalla: const CartaScreen(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menú principal'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: () => _cerrarSesion(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hola, ${Sesion.nombre}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.texto,
              ),
            ),
            Text('Rol: ${rol.etiqueta}'),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  for (final opcion in opciones)
                    _OpcionCard(
                      opcion: opcion,
                      onTap: () => _abrir(context, opcion.pantalla),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Datos de una opción del menú principal.
class _Opcion {
  const _Opcion({
    required this.titulo,
    required this.icono,
    required this.pantalla,
  });

  final String titulo;
  final IconData icono;
  final Widget pantalla;
}

class _OpcionCard extends StatelessWidget {
  const _OpcionCard({required this.opcion, required this.onTap});

  final _Opcion opcion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(opcion.icono, size: 48, color: AppColors.primario),
            const SizedBox(height: 12),
            Text(
              opcion.titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
