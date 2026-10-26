import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_theme.dart';
import '../core/formato.dart';
import '../data/menu_demo.dart';
import '../data/pedido_repository.dart';
import '../models/categoria.dart';
import '../models/item_pedido.dart';
import '../widgets/filtro_categorias.dart';
import '../widgets/producto_card.dart';

/// Pantalla: formulario para registrar un pedido nuevo.
class NuevoPedidoScreen extends StatefulWidget {
  const NuevoPedidoScreen({super.key});

  @override
  State<NuevoPedidoScreen> createState() => _NuevoPedidoScreenState();
}

class _NuevoPedidoScreenState extends State<NuevoPedidoScreen> {
  static const int _maxMesas = 30;

  final _formKey = GlobalKey<FormState>();
  final _mesaController = TextEditingController();
  final _clienteController = TextEditingController();
  final _observacionesController = TextEditingController();

  Categoria _categoria = Categoria.entradas;

  /// Cantidad elegida por producto: { idProducto: cantidad }.
  final Map<int, int> _cantidades = {};

  @override
  void dispose() {
    _mesaController.dispose();
    _clienteController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  /// Convierte las cantidades elegidas en ítems del pedido.
  List<ItemPedido> get _items {
    return [
      for (final producto in menuDemo)
        if ((_cantidades[producto.id] ?? 0) > 0)
          ItemPedido(producto: producto, cantidad: _cantidades[producto.id]!),
    ];
  }

  double get _total => _items.fold(0.0, (suma, item) => suma + item.subtotal);

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agrega al menos un producto al pedido')),
      );
      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar pedido'),
        content: Text(
          'Mesa ${_mesaController.text} · ${_items.length} producto(s)\n'
          'Total: ${formatearSoles(_total)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Registrar'),
          ),
        ],
      ),
    );

    // Después de un await hay que verificar que la pantalla siga abierta.
    if (confirmar != true || !mounted) return;

    PedidoRepository.instancia.crearPedido(
      mesa: int.parse(_mesaController.text),
      items: _items,
      cliente: _clienteController.text,
      observaciones: _observacionesController.text,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pedido registrado correctamente')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final productos =
        menuDemo.where((p) => p.categoria == _categoria).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo pedido')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 16),
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  TextFormField(
                    controller: _mesaController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Número de mesa',
                      prefixIcon: Icon(Icons.table_restaurant),
                      border: OutlineInputBorder(),
                    ),
                    validator: (valor) {
                      final mesa = int.tryParse(valor ?? '');
                      if (mesa == null || mesa < 1 || mesa > _maxMesas) {
                        return 'Ingresa una mesa entre 1 y $_maxMesas';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _clienteController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Cliente (opcional)',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            FiltroCategorias(
              seleccionada: _categoria,
              onSeleccionar: (c) => setState(() => _categoria = c),
            ),
            for (final producto in productos)
              ProductoCard(
                producto: producto,
                cantidad: _cantidades[producto.id] ?? 0,
                onCambiarCantidad: (nueva) =>
                    setState(() => _cantidades[producto.id] = nueva),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextFormField(
                controller: _observacionesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Observaciones (opcional)',
                  hintText: 'Ej.: sin ají, sin cebolla...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total'),
                    Text(
                      formatearSoles(_total),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primario,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: _registrar,
                  child: const Text('Registrar pedido'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
