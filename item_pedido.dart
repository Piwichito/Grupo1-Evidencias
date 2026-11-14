/// Una línea de un pedido ya registrado: guarda el nombre y el precio del producto
/// en el momento de la venta (aunque la carta cambie después).
class ItemPedido {
  const ItemPedido({
    required this.productoId,
    required this.nombre,
    required this.precioUnitario,
    required this.cantidad,
  });

  final String productoId;
  final String nombre;
  final double precioUnitario;
  final int cantidad;

  /// Precio unitario por cantidad.
  double get subtotal => precioUnitario * cantidad;

  factory ItemPedido.fromJson(Map<String, dynamic> json) {
    return ItemPedido(
      productoId: json['productoId'] as String,
      nombre: json['nombre'] as String,
      precioUnitario: (json['precioUnitario'] as num).toDouble(),
      cantidad: json['cantidad'] as int,
    );
  }
}
