/// Categorías del menú del restaurante.
enum Categoria {
  entradas('Entradas'),
  fondos('Platos de fondo'),
  bebidas('Bebidas'),
  postres('Postres');

  const Categoria(this.etiqueta);

  final String etiqueta;

  /// Valor que usa la API (coincide con el nombre del enum).
  String get valorApi => name;

  /// Convierte el texto de la API en la categoría. Lanza un error si no existe.
  static Categoria desdeApi(String valor) {
    return Categoria.values.firstWhere(
      (c) => c.valorApi == valor,
      orElse: () => throw FormatException('Categoría desconocida: $valor'),
    );
  }
}
