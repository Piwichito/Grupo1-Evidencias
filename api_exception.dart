/// Error al comunicarse con la API. El mensaje ya está listo para mostrarse al usuario.
class ApiException implements Exception {
  const ApiException(this.mensaje, {this.codigoHttp, this.detalles = const []});

  final String mensaje;

  /// Código HTTP de la respuesta (null si ni siquiera hubo respuesta).
  final int? codigoHttp;

  /// Lista de problemas concretos (por ejemplo, los campos inválidos).
  final List<String> detalles;

  /// Mensaje con los detalles, para mostrar en un aviso.
  String get mensajeCompleto =>
      detalles.isEmpty ? mensaje : '$mensaje: ${detalles.join(' · ')}';

  /// 409: el recurso cambió mientras se trabajaba con él.
  bool get esConflicto => codigoHttp == 409;

  @override
  String toString() => 'ApiException($codigoHttp): $mensajeCompleto';
}
