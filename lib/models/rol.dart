import 'estado_pedido.dart';

/// Tipos de usuario del sistema (según el Caso 03).
enum Rol {
  mozo('Mozo'),
  cocinero('Cocinero'),
  administrador('Administrador');

  const Rol(this.etiqueta);

  /// Texto que se muestra en pantalla.
  final String etiqueta;

  /// El mozo y el administrador pueden registrar pedidos nuevos.
  bool get puedeCrearPedidos => this != Rol.cocinero;

  /// Solo mozo y administrador pueden anular un pedido.
  bool get puedeAnular => this != Rol.cocinero;

  /// Indica si este rol puede cambiar un pedido que está en [actual]
  /// hacia el siguiente estado.
  /// - Cocinero: recibido -> en preparación -> listo.
  /// - Mozo: listo -> entregado.
  /// - Administrador: cualquier avance.
  bool puedeAvanzarDesde(EstadoPedido actual) {
    if (this == Rol.administrador) return actual.siguiente != null;
    if (this == Rol.cocinero) {
      return actual == EstadoPedido.recibido ||
          actual == EstadoPedido.enPreparacion;
    }
    // Mozo
    return actual == EstadoPedido.listo;
  }
}
