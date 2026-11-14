import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../core/formato.dart';
import '../data/api/api_exception.dart';
import '../data/sesion.dart';
import '../models/estado_pedido.dart';
import '../models/pedido.dart';
import '../providers/pedidos_provider.dart';
import '../widgets/estado_chip.dart';
import '../widgets/mensajes.dart';

/// Pantalla: detalle de un pedido, con opción de actualizar su estado
/// o anularlo (según el rol del usuario). Los cambios se guardan en la API.
class DetallePedidoScreen extends StatefulWidget {
  const DetallePedidoScreen({super.key, required this.pedidoId});

  final String pedidoId;

  @override
  State<DetallePedidoScreen> createState() => _DetallePedidoScreenState();
}

class _DetallePedidoScreenState extends State<DetallePedidoScreen> {
  /// Cambia el estado y muestra el error de la API si la operación falla.
  Future<void> _cambiarEstado(EstadoPedido nuevo) async {
    final provider = context.read<PedidosProvider>();
    try {
      await provider.cambiarEstado(widget.pedidoId, nuevo);
      if (!mounted) return;
      mostrarAviso(context, 'Pedido actualizado: ${nuevo.etiqueta}');
    } on ApiException catch (e) {
      if (!mounted) return;
      mostrarAviso(context, e.mensajeCompleto, esError: true);
    }
  }

  Future<void> _confirmarAnulacion(Pedido pedido) async {
    final anular = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Anular pedido'),
        content: Text('¿Seguro que deseas anular el pedido #${pedido.numero}?'),
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

    if (anular == true && mounted) {
      await _cambiarEstado(EstadoPedido.anulado);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PedidosProvider>();
    final pedido = provider.buscarPorId(widget.pedidoId);

    return Scaffold(
      appBar: AppBar(
        title: Text(pedido == null ? 'Pedido' : 'Pedido #${pedido.numero}'),
      ),
      body: pedido == null
          ? const Center(child: Text('El pedido no existe'))
          : _construirDetalle(pedido, provider.enviando),
    );
  }

  Widget _construirDetalle(Pedido pedido, bool enviando) {
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
            title: Text('${item.cantidad} x ${item.nombre}'),
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
            onPressed: enviando ? null : () => _cambiarEstado(siguiente),
            child: Text(
              enviando ? 'Guardando...' : 'Marcar como ${siguiente.etiqueta}',
            ),
          ),
        if (puedeAnular) ...[
          const SizedBox(height: 12),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              foregroundColor: Colors.red.shade700,
            ),
            onPressed: enviando ? null : () => _confirmarAnulacion(pedido),
            child: const Text('Anular pedido'),
          ),
        ],
      ],
    );
  }
}
