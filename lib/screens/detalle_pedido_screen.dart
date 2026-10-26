import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/formato.dart';
import '../data/pedido_repository.dart';
import '../data/sesion.dart';
import '../models/pedido.dart';
import '../widgets/estado_chip.dart';

/// Pantalla: detalle de un pedido, con opción de actualizar su estado
/// o anularlo (según el rol del usuario).
class DetallePedidoScreen extends StatelessWidget {
  const DetallePedidoScreen({super.key, required this.pedidoId});

  final int pedidoId;

  Future<void> _confirmarAnulacion(BuildContext context) async {
    final anular = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Anular pedido'),
        content: Text('¿Seguro que deseas anular el pedido #$pedidoId?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Sí, anular'),
          ),
        ],
      ),
    );

    if (anular == true) {
      PedidoRepository.instancia.anularPedido(pedidoId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pedido #$pedidoId')),
      body: ListenableBuilder(
        listenable: PedidoRepository.instancia,
        builder: (context, _) {
          final pedido = PedidoRepository.instancia.buscarPorId(pedidoId);
          if (pedido == null) {
            return const Center(child: Text('El pedido no existe'));
          }
          return _construirDetalle(context, pedido);
        },
      ),
    );
  }

  Widget _construirDetalle(BuildContext context, Pedido pedido) {
    final siguiente = pedido.estado.siguiente;
    final puedeAvanzar = Sesion.rol.puedeAvanzarDesde(pedido.estado);
    final puedeAnular = pedido.estado.estaAbierto && Sesion.rol.puedeAnular;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Mesa ${pedido.mesa}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            EstadoChip(estado: pedido.estado),
          ],
        ),
        const SizedBox(height: 4),
        Text('Hora: ${formatearHora(pedido.fecha)}'),
        if (pedido.cliente.isNotEmpty) Text('Cliente: ${pedido.cliente}'),
        const Divider(height: 32),
        const Text(
          'Productos',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        for (final item in pedido.items)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('${item.cantidad} x ${item.producto.nombre}'),
            trailing: Text(formatearSoles(item.subtotal)),
          ),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              formatearSoles(pedido.total),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primario,
              ),
            ),
          ],
        ),
        if (pedido.observaciones.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Observaciones: ${pedido.observaciones}'),
        ],
        const SizedBox(height: 24),
        if (puedeAvanzar && siguiente != null)
          ElevatedButton(
            onPressed: () => PedidoRepository.instancia
                .cambiarEstado(pedido.id, siguiente),
            child: Text('Marcar como ${siguiente.etiqueta}'),
          ),
        if (puedeAnular) ...[
          const SizedBox(height: 12),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              foregroundColor: Colors.red.shade700,
            ),
            onPressed: () => _confirmarAnulacion(context),
            child: const Text('Anular pedido'),
          ),
        ],
      ],
    );
  }
}
