import 'package:flutter/material.dart';

import '../models/estado_pedido.dart';

/// Etiqueta de color que muestra el estado de un pedido.
class EstadoChip extends StatelessWidget {
  const EstadoChip({super.key, required this.estado});

  final EstadoPedido estado;

  /// Color asociado a cada estado.
  static Color colorDe(EstadoPedido estado) {
    switch (estado) {
      case EstadoPedido.recibido:
        return Colors.blue.shade700;
      case EstadoPedido.enPreparacion:
        return Colors.orange.shade800;
      case EstadoPedido.listo:
        return Colors.green.shade700;
      case EstadoPedido.entregado:
        return Colors.grey.shade700;
      case EstadoPedido.anulado:
        return Colors.red.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = colorDe(estado);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        estado.etiqueta,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
