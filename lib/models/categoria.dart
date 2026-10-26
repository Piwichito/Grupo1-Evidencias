/// Categorías del menú del restaurante.
enum Categoria {
  entradas('Entradas'),
  fondos('Platos de fondo'),
  bebidas('Bebidas'),
  postres('Postres');

  const Categoria(this.etiqueta);

  final String etiqueta;
}
