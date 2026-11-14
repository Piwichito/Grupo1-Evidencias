import '../../models/producto.dart';
import '../api/api_client.dart';

/// Contrato para obtener la carta. Las pantallas y los providers dependen de este contrato,
/// no de cómo se obtienen los datos (API, SQLite, datos de prueba...).
abstract class MenuRepository {
  Future<List<Producto>> obtenerProductos();
}

/// Implementación que obtiene la carta desde la API REST.
class ApiMenuRepository implements MenuRepository {
  ApiMenuRepository(this._api);

  final ApiClient _api;

  @override
  Future<List<Producto>> obtenerProductos() async {
    final datos = await _api.get('/api/productos');
    return (datos as List<dynamic>)
        .map((p) => Producto.fromJson(p as Map<String, dynamic>))
        .toList();
  }
}
