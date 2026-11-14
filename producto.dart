import 'categoria.dart';

/// Un plato o bebida del menú (viene de la API).
class Producto {
  const Producto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.categoria,
    this.disponible = true,
  });

  final String id;
  final String nombre;
  final String descripcion;
  final double precio;
  final Categoria categoria;
  final bool disponible;

  /// Crea un producto a partir del JSON de la API.
  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      descripcion: (json['descripcion'] as String?) ?? '',
      precio: (json['precio'] as num).toDouble(),
      categoria: Categoria.desdeApi(json['categoria'] as String),
      disponible: (json['disponible'] as bool?) ?? true,
    );
  }
}
