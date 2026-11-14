import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../core/formato.dart';
import '../models/estado_pedido.dart';
import '../models/pedido.dart';
import '../providers/pedidos_provider.dart';
import '../widgets/estado_chip.dart';
import '../widgets/mensajes.dart';
import '../widgets/vista_carga.dart';
import 'detalle_pedido_screen.dart';

/// Pantalla: listado de pedidos (desde la API) con filtro por estado.
class ListaPedidosScreen extends StatefulWidget {
  const ListaPedidosScreen({super.key});

  @override
  State<ListaPedidosScreen> createState() => _ListaPedidosScreenState();
}

class _ListaPedidosScreenState extends State<ListaPedidosScreen> {
  /// null significa "Todos".
  EstadoPedido? _filtro;

  @override
  void initState() {
    super.initState();
    // Al abrir la pantalla se actualiza la lista con lo último que hay en el servidor.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<PedidosProvider>().cargar();
    });
  }

  Future<void> _actualizar() async {
    final provider = context.read<PedidosProvider>();
    await provider.cargar();
    if (!mounted) return;
    if (provider.error != null) {
      mostrarAviso(context, provider.error!, esError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PedidosProvider>();
    final pedidos = provider.pedidos
        .where((p) => _filtro == null || p.estado == _filtro)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos'),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: provider.cargando ? null : _actualizar,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: VistaCarga(
        cargado: provider.cargado,
        error: provider.error,
        onReintentar: provider.cargar,
        child: Column(
          children: [
            _construirFiltros(),
            if (provider.cargando) const LinearProgressIndicator(minHeight: 2),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _actualizar,
                child: pedidos.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 80),
                          Center(child: Text('No hay pedidos para mostrar')),
                        ],
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: pedidos.length,
                        itemBuilder: (context, indice) =>
                            _PedidoTile(pedido: pedidos[indice]),
                      ),
              ),
            ),
          ],
        ),
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
        title: Text('Pedido #${pedido.numero} · Mesa ${pedido.mesa}'),
        subtitle: Text(
          '${pedido.cantidadProductos} producto(s) · '
          '${formatearHora(pedido.fecha)} · ${formatearSoles(pedido.total)}',
        ),
        trailing: EstadoChip(estado: pedido.estado),
      ),
    );
  }
}
