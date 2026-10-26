import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/formato.dart';
import '../models/producto.dart';

/// Tarjeta que muestra un producto del menú.
/// Si se envía [cantidad] y [onCambiarCantidad], muestra botones +/-
/// (se usa al registrar un pedido). Si no, es solo informativa (la carta).
class ProductoCard extends StatelessWidget {
  const ProductoCard({
    super.key,
    required this.producto,
    this.cantidad,
    this.onCambiarCantidad,
  });

  final Producto producto;
  final int? cantidad;
  final ValueChanged<int>? onCambiarCantidad;

  @override
  Widget build(BuildContext context) {
    final bool seleccionable = cantidad != null && onCambiarCantidad != null;
    final int actual = cantidad ?? 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    producto.nombre,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.texto,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    producto.descripcion,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    producto.disponible
                        ? formatearSoles(producto.precio)
                        : 'Agotado',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: producto.disponible
                          ? AppColors.primario
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            if (seleccionable && producto.disponible)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed:
                        actual > 0 ? () => onCambiarCantidad!(actual - 1) : null,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text(
                    '$actual',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => onCambiarCantidad!(actual + 1),
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
