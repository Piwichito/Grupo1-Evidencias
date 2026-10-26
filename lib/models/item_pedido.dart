import 'producto.dart';

/// Una línea del pedido: un producto con su cantidad.
class ItemPedido {
  const ItemPedido({required this.producto, required this.cantidad});

  final Producto producto;
  final int cantidad;

  /// Precio unitario por cantidad.
  double get subtotal => producto.precio * cantidad;
}
