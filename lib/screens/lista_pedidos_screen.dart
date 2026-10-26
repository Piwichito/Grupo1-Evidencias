import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/formato.dart';
import '../data/pedido_repository.dart';
import '../models/estado_pedido.dart';
import '../models/pedido.dart';
import '../widgets/estado_chip.dart';
import 'detalle_pedido_screen.dart';

/// Pantalla: listado de pedidos con filtro por estado.
class ListaPedidosScreen extends StatefulWidget {
  const ListaPedidosScreen({super.key});

  @override
  State<ListaPedidosScreen> createState() => _ListaPedidosScreenState();
}

class _ListaPedidosScreenState extends State<ListaPedidosScreen> {
  /// null significa "Todos".
  EstadoPedido? _filtro;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pedidos')),
      body: Column(
        children: [
          _construirFiltros(),
          Expanded(
            // Se redibuja automáticamente cuando el repositorio cambia.
            child: ListenableBuilder(
              listenable: PedidoRepository.instancia,
              builder: (context, _) {
                final pedidos = PedidoRepository.instancia.pedidos
                    .where((p) => _filtro == null || p.estado == _filtro)
                    .toList();

                if (pedidos.isEmpty) {
                  return const Center(child: Text('No hay pedidos para mostrar'));
                }

                return ListView.builder(
                  itemCount: pedidos.length,
                  itemBuilder: (context, indice) =>
                      _PedidoTile(pedido: pedidos[indice]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirFiltros() {
    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: const Text('Todos'),
              selected: _filtro == null,
              onSelected: (_) => setState(() => _filtro = null),
            ),
          ),
          for (final estado in EstadoPedido.values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(estado.etiqueta),
                selected: _filtro == estado,
                onSelected: (_) => setState(() => _filtro = estado),
              ),
            ),
        ],
      ),
    );
  }
}

class _PedidoTile extends StatelessWidget {
  const _PedidoTile({required this.pedido});

  final Pedido pedido;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DetallePedidoScreen(pedidoId: pedido.id),
            ),
          );
        },
        leading: CircleAvatar(
          backgroundColor: AppColors.primario,
          child: Text(
            '${pedido.mesa}',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text('Pedido #${pedido.id} · Mesa ${pedido.mesa}'),
        subtitle: Text(
          '${pedido.cantidadProductos} producto(s) · '
          '${formatearHora(pedido.fecha)} · ${formatearSoles(pedido.total)}',
        ),
        trailing: EstadoChip(estado: pedido.estado),
      ),
    );
  }
}
