/// Estados por los que pasa un pedido.
/// Los cuatro primeros son los del Caso 03; [anulado] cumple el requisito de "anular registros".
enum EstadoPedido {
  recibido('Recibido', 'recibido'),
  enPreparacion('En preparación', 'en_preparacion'),
  listo('Listo', 'listo'),
  entregado('Entregado', 'entregado'),
  anulado('Anulado', 'anulado');

  const EstadoPedido(this.etiqueta, this.valorApi);

  /// Texto que se muestra en pantalla.
  final String etiqueta;

  /// Valor que usa la API REST.
  final String valorApi;

  /// Convierte el texto de la API en el estado. Lanza un error si no existe.
  static EstadoPedido desdeApi(String valor) {
    return EstadoPedido.values.firstWhere(
      (e) => e.valorApi == valor,
      orElse: () => throw FormatException('Estado desconocido: $valor'),
    );
  }

  /// Siguiente estado del flujo normal, o null si ya terminó.
  EstadoPedido? get siguiente {
    switch (this) {
      case EstadoPedido.recibido:
        return EstadoPedido.enPreparacion;
      case EstadoPedido.enPreparacion:
        return EstadoPedido.listo;
      case EstadoPedido.listo:
        return EstadoPedido.entregado;
      case EstadoPedido.entregado:
      case EstadoPedido.anulado:
        return null;
    }
  }

  /// Un pedido sigue "abierto" mientras no esté entregado ni anulado.
  bool get estaAbierto =>
      this != EstadoPedido.entregado && this != EstadoPedido.anulado;
}
