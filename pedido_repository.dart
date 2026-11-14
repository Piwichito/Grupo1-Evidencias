import '../../models/estado_pedido.dart';
import '../../models/nuevo_pedido.dart';
import '../../models/pedido.dart';
import '../../models/rol.dart';
import '../api/api_client.dart';

/// Contrato para gestionar los pedidos.
abstract class PedidoRepository {
  Future<List<Pedido>> obtenerPedidos();
  Future<Pedido> crearPedido(NuevoPedido nuevo, Rol rol);
  Future<Pedido> cambiarEstado(String id, EstadoPedido estado, Rol rol);
}

/// Implementación que usa la API REST (los datos se guardan en MongoDB Atlas).
class ApiPedidoRepository implements PedidoRepository {
  ApiPedidoRepository(this._api);

  final ApiClient _api;

  /// La API identifica al usuario por el encabezado X-Rol.
  Map<String, String> _cabeceraRol(Rol rol) => {'X-Rol': rol.valorApi};

  @override
  Future<List<Pedido>> obtenerPedidos() async {
    final datos = await _api.get('/api/pedidos');
    return (datos as List<dynamic>)
        .map((p) => Pedido.fromJson(p as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Pedido> crearPedido(NuevoPedido nuevo, Rol rol) async {
    final datos = await _api.post(
      '/api/pedidos',
      nuevo.toJson(),
      headers: _cabeceraRol(rol),
    );
    return Pedido.fromJson(datos as Map<String, dynamic>);
  }

  @override
  Future<Pedido> cambiarEstado(String id, EstadoPedido estado, Rol rol) async {
    final datos = await _api.patch('/api/pedidos/$id/estado', {
      'estado': estado.valorApi,
    }, headers: _cabeceraRol(rol));
    return Pedido.fromJson(datos as Map<String, dynamic>);
  }
}
