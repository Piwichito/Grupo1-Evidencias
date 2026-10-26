import 'package:flutter/foundation.dart';

import '../models/estado_pedido.dart';
import '../models/item_pedido.dart';
import '../models/pedido.dart';
import 'menu_demo.dart';

/// Guarda los pedidos en memoria y avisa a las pantallas cuando cambian.
///
/// Extiende [ChangeNotifier]: cada vez que se llama a [notifyListeners],
/// los widgets que escuchan (con ListenableBuilder) se redibujan solos.
///
/// IMPORTANTE (Avance 1): los datos viven solo mientras la app está abierta.
/// En el Avance 3 se reemplazará por SQLite/SQFLite sin cambiar las pantallas.
class PedidoRepository extends ChangeNotifier {
  PedidoRepository._() {
    _cargarPedidosDemo();
  }

  /// Única instancia compartida por toda la app (patrón Singleton).
  static final PedidoRepository instancia = PedidoRepository._();

  final List<Pedido> _pedidos = [];
  int _siguienteId = 1;

  /// Lista de solo lectura: las pantallas no pueden modificarla directamente.
  List<Pedido> get pedidos => List.unmodifiable(_pedidos);

  /// Busca un pedido por su id (null si no existe).
  Pedido? buscarPorId(int id) {
    for (final pedido in _pedidos) {
      if (pedido.id == id) return pedido;
    }
    return null;
  }

  /// Registra un pedido nuevo con estado "Recibido" y lo devuelve.
  Pedido crearPedido({
    required int mesa,
    required List<ItemPedido> items,
    String cliente = '',
    String observaciones = '',
  }) {
    final pedido = Pedido(
      id: _siguienteId++,
      mesa: mesa,
      items: List.unmodifiable(items),
      fecha: DateTime.now(),
      cliente: cliente.trim(),
      observaciones: observaciones.trim(),
    );
    _pedidos.insert(0, pedido); // Los más recientes primero.
    notifyListeners();
    return pedido;
  }

  /// Cambia el estado de un pedido existente.
  void cambiarEstado(int id, EstadoPedido nuevoEstado) {
    final indice = _pedidos.indexWhere((p) => p.id == id);
    if (indice == -1) return;
    _pedidos[indice] = _pedidos[indice].copyWith(estado: nuevoEstado);
    notifyListeners();
  }

  /// Anula un pedido (queda en el historial con estado "Anulado").
  void anularPedido(int id) => cambiarEstado(id, EstadoPedido.anulado);

  /// Pedidos de ejemplo para poder probar la interfaz desde el inicio.
  void _cargarPedidosDemo() {
    crearPedido(
      mesa: 3,
      cliente: 'Familia Rojas',
      items: [
        ItemPedido(producto: menuDemo[3], cantidad: 2),
        ItemPedido(producto: menuDemo[7], cantidad: 1),
      ],
    );
    crearPedido(
      mesa: 5,
      items: [ItemPedido(producto: menuDemo[0], cantidad: 1)],
      observaciones: 'Ceviche sin ají.',
    );
    cambiarEstado(2, EstadoPedido.enPreparacion);
  }
}
