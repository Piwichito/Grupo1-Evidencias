import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_exception.dart';

/// Cliente HTTP de la app: realiza las peticiones a la API REST, convierte las respuestas
/// de JSON y traduce cualquier fallo a un [ApiException] con un mensaje claro.
class ApiClient {
  ApiClient({
    required this.baseUrl,
    http.Client? cliente,
    this.tiempoMaximo = const Duration(seconds: 30),
  }) : _cliente = cliente ?? http.Client();

  final String baseUrl;
  final Duration tiempoMaximo;
  final http.Client _cliente;

  Future<dynamic> get(String ruta, {Map<String, String>? headers}) {
    return _enviar(
      () => _cliente.get(_uri(ruta), headers: _cabeceras(headers)),
    );
  }

  Future<dynamic> post(
    String ruta,
    Object cuerpo, {
    Map<String, String>? headers,
  }) {
    return _enviar(
      () => _cliente.post(
        _uri(ruta),
        headers: _cabeceras(headers),
        body: jsonEncode(cuerpo),
      ),
    );
  }

  Future<dynamic> patch(
    String ruta,
    Object cuerpo, {
    Map<String, String>? headers,
  }) {
    return _enviar(
      () => _cliente.patch(
        _uri(ruta),
        headers: _cabeceras(headers),
        body: jsonEncode(cuerpo),
      ),
    );
  }

  Uri _uri(String ruta) => Uri.parse('$baseUrl$ruta');

  Map<String, String> _cabeceras(Map<String, String>? extra) => {
    'Content-Type': 'application/json; charset=utf-8',
    'Accept': 'application/json',
    ...?extra,
  };

  /// Ejecuta la petición con tiempo máximo y traduce los errores.
  Future<dynamic> _enviar(Future<http.Response> Function() peticion) async {
    final http.Response respuesta;
    try {
      respuesta = await peticion().timeout(tiempoMaximo);
    } on TimeoutException {
      throw const ApiException(
        'El servidor tardó demasiado en responder. Si usas la API gratuita en la nube, '
        'puede estar iniciando: inténtalo de nuevo en un minuto.',
      );
    } on http.ClientException {
      throw const ApiException(
        'No se pudo conectar con el servidor. Revisa tu conexión y que la API esté encendida.',
      );
    }
    return _procesar(respuesta);
  }

  dynamic _procesar(http.Response respuesta) {
    // Se decodifica como UTF-8 para conservar tildes y la "ñ".
    final texto = utf8.decode(respuesta.bodyBytes);
    final dynamic datos = texto.isEmpty ? null : _decodificar(texto);

    if (respuesta.statusCode >= 200 && respuesta.statusCode < 300) {
      return datos;
    }

    // Formato de error de la API: { "error": { "mensaje": "...", "detalles": [...] } }
    if (datos is Map<String, dynamic> && datos['error'] is Map) {
      final error = datos['error'] as Map;
      final detalles =
          (error['detalles'] as List?)?.map((d) => d.toString()).toList() ??
          const <String>[];
      throw ApiException(
        (error['mensaje'] as String?) ?? 'Error del servidor',
        codigoHttp: respuesta.statusCode,
        detalles: detalles,
      );
    }
    throw ApiException(
      'Error inesperado del servidor (${respuesta.statusCode})',
      codigoHttp: respuesta.statusCode,
    );
  }

  dynamic _decodificar(String texto) {
    try {
      return jsonDecode(texto);
    } on FormatException {
      throw const ApiException('La respuesta del servidor no es válida');
    }
  }

  /// Libera los recursos del cliente HTTP.
  void cerrar() => _cliente.close();
}
