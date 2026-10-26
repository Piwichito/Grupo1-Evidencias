import 'estado_pedido.dart';
import 'item_pedido.dart';

/// Pedido registrado por un mozo para una mesa.
class Pedido {
  const Pedido({
    required this.id,
    required this.mesa,
    required this.items,
    required this.fecha,
    this.cliente = '',
    this.observaciones = '',
    this.estado = EstadoPedido.recibido,
  });

  final int id;
  final int mesa;
  final List<ItemPedido> items;
  final DateTime fecha;
  final String cliente;
  final String observaciones;
  final EstadoPedido estado;

  /// Total a pagar: suma de los subtotales de cada ítem.
  double get total => items.fold(0.0, (suma, item) => suma + item.subtotal);

  /// Cantidad total de platos/bebidas del pedido.
  int get cantidadProductos =>
      items.fold(0, (suma, item) => suma + item.cantidad);

  /// Devuelve una copia del pedido con otro estado.
  /// (Los objetos son inmutables: en vez de modificarlos, se copian.)
  Pedido copyWith({EstadoPedido? estado}) {
    return Pedido(
      id: id,
      mesa: mesa,
      items: items,
      fecha: fecha,
      cliente: cliente,
      observaciones: observaciones,
      estado: estado ?? this.estado,
    );
  }
}
