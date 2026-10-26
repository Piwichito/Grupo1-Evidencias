import 'categoria.dart';

/// Un plato o bebida del menú.
class Producto {
  const Producto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.categoria,
    this.disponible = true,
  });

  final int id;
  final String nombre;
  final String descripcion;
  final double precio;
  final Categoria categoria;
  final bool disponible;
}
