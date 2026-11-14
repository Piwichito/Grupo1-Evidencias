import 'package:flutter/foundation.dart';

/// Configuración de la conexión con la API REST.
///
/// La dirección se puede cambiar al ejecutar, sin tocar el código:
///   flutter run --dart-define=API_URL=https://mi-api.onrender.com
class ApiConfig {
  ApiConfig._();

  static const String _urlDefinida = String.fromEnvironment('API_URL');

  /// - Si se definió API_URL, se usa esa.
  /// - En el emulador de Android, 10.0.2.2 es la PC donde corre la API.
  /// - En el navegador (web) se usa localhost.
  static String get baseUrl {
    if (_urlDefinida.isNotEmpty) return _urlDefinida;
    return kIsWeb ? 'http://localhost:3000' : 'http://10.0.2.2:3000';
  }

  /// Tiempo máximo de espera de una petición (la API gratuita de Render puede tardar al "despertar").
  static const Duration tiempoMaximo = Duration(seconds: 30);
}
