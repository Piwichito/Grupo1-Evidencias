import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../core/formato.dart';
import '../data/api/api_exception.dart';
import '../models/categoria.dart';
import '../models/nuevo_pedido.dart';
import '../models/producto.dart';
import '../providers/menu_provider.dart';
import '../providers/pedidos_provider.dart';
import '../widgets/filtro_categorias.dart';
import '../widgets/mensajes.dart';
import '../widgets/producto_card.dart';
import '../widgets/vista_carga.dart';

/// Pantalla: formulario para registrar un pedido nuevo (se envía a la API).
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
  final Map<String, int> _cantidades = {};

  @override
  void dispose() {
    _mesaController.dispose();
    _clienteController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  /// Líneas del pedido: solo los productos con cantidad mayor a cero.
  List<LineaNuevoPedido> get _lineas => [
    for (final entrada in _cantidades.entries)
      if (entrada.value > 0)
        LineaNuevoPedido(productoId: entrada.key, cantidad: entrada.value),
  ];

  /// Total mostrado en pantalla (la API vuelve a calcularlo al registrar el pedido).
  double _total(List<Producto> productos) {
    double suma = 0;
    for (final producto in productos) {
      suma += producto.precio * (_cantidades[producto.id] ?? 0);
    }
    return suma;
  }

  Future<void> _registrar(double total) async {
    final pedidos = context.read<PedidosProvider>();
    if (pedidos.enviando) {
      return; // Evita registrar dos veces con un doble toque.
    }
    if (!_formKey.currentState!.validate()) return;

    final lineas = _lineas;
    if (lineas.isEmpty) {
      mostrarAviso(
        context,
        'Agrega al menos un producto al pedido',
        esError: true,
      );
      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar pedido'),
        content: Text(
          'Mesa ${_mesaController.text} · ${lineas.length} producto(s)\n'
          'Total: ${formatearSoles(total)}',
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

    try {
      final pedido = await pedidos.crear(
        NuevoPedido(
          mesa: int.parse(_mesaController.text),
          lineas: lineas,
          cliente: _clienteController.text.trim(),
          observaciones: _observacionesController.text.trim(),
        ),
      );
      if (!mounted || pedido == null) return;
      mostrarAviso(
        context,
        'Pedido #${pedido.numero} registrado correctamente',
      );
      Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      mostrarAviso(context, e.mensajeCompleto, esError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final menu = context.watch<MenuProvider>();
    final enviando = context.select<PedidosProvider, bool>((p) => p.enviando);
    final productos = menu.productosDe(_categoria);
    final total = _total(menu.productos);

    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo pedido')),
      body: VistaCarga(
        cargado: menu.cargado,
        error: menu.error,
        onReintentar: menu.cargar,
        child: Form(
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
                      maxLength: 60,
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
                  maxLength: 200,
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
                      formatearSoles(total),
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
                  // Se deshabilita mientras la carta no cargó o hay un envío en curso.
                  onPressed: (menu.cargado && !enviando)
                      ? () => _registrar(total)
                      : null,
                  child: Text(enviando ? 'Enviando...' : 'Registrar pedido'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
