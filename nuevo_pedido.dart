/// Una línea del pedido que se va a enviar: solo producto y cantidad.
/// (El precio lo define el servidor, no la app.)
class LineaNuevoPedido {
  const LineaNuevoPedido({required this.productoId, required this.cantidad});

  final String productoId;
  final int cantidad;

  Map<String, dynamic> toJson() => {
    'productoId': productoId,
    'cantidad': cantidad,
  };
}

/// Datos del formulario "Nuevo pedido" listos para enviarse a la API.
class NuevoPedido {
  const NuevoPedido({
    required this.mesa,
    required this.lineas,
    this.cliente = '',
    this.observaciones = '',
  });

  final int mesa;
  final List<LineaNuevoPedido> lineas;
  final String cliente;
  final String observaciones;

  Map<String, dynamic> toJson() => {
    'mesa': mesa,
    'cliente': cliente,
    'observaciones': observaciones,
    'items': lineas.map((l) => l.toJson()).toList(),
  };
}
