import 'estado_pedido.dart';
import 'item_pedido.dart';

/// Pedido registrado por un mozo para una mesa (viene de la API).
class Pedido {
  const Pedido({
    required this.id,
    required this.numero,
    required this.mesa,
    required this.items,
    required this.total,
    required this.fecha,
    this.cliente = '',
    this.observaciones = '',
    this.estado = EstadoPedido.recibido,
  });

  /// Identificador interno (MongoDB).
  final String id;

  /// Número correlativo que se muestra al usuario (Pedido #1, #2...).
  final int numero;
  final int mesa;
  final List<ItemPedido> items;
  final double total;
  final DateTime fecha;
  final String cliente;
  final String observaciones;
  final EstadoPedido estado;

  /// Cantidad total de platos/bebidas del pedido.
  int get cantidadProductos =>
      items.fold(0, (suma, item) => suma + item.cantidad);

  /// Crea un pedido a partir del JSON de la API.
  factory Pedido.fromJson(Map<String, dynamic> json) {
    final lista = json['items'] as List<dynamic>;
    return Pedido(
      id: json['id'] as String,
      numero: json['numero'] as int,
      mesa: json['mesa'] as int,
      cliente: (json['cliente'] as String?) ?? '',
      observaciones: (json['observaciones'] as String?) ?? '',
      estado: EstadoPedido.desdeApi(json['estado'] as String),
      items: lista
          .map((i) => ItemPedido.fromJson(i as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toDouble(),
      // La API envía la fecha en UTC; se convierte a la hora local del teléfono.
      fecha: DateTime.parse(json['creadoEn'] as String).toLocal(),
    );
  }
}
