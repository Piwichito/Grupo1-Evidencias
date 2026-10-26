/// Estados por los que pasa un pedido.
/// Los cuatro primeros son los del Caso 03; [anulado] se agrega para cumplir
/// el requisito general de "eliminar o anular registros".
enum EstadoPedido {
  recibido('Recibido'),
  enPreparacion('En preparación'),
  listo('Listo'),
  entregado('Entregado'),
  anulado('Anulado');

  const EstadoPedido(this.etiqueta);

  final String etiqueta;

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
