import 'package:flutter/foundation.dart';

import '../data/api/api_exception.dart';
import '../data/repositories/pedido_repository.dart';
import '../data/sesion.dart';
import '../models/estado_pedido.dart';
import '../models/nuevo_pedido.dart';
import '../models/pedido.dart';
import '../models/rol.dart';

/// Estado de los pedidos. Toda la comunicación con la API pasa por aquí.
class PedidosProvider extends ChangeNotifier {
  PedidosProvider(this._repositorio, {Rol Function()? obtenerRol})
    : _obtenerRol = obtenerRol ?? (() => Sesion.rol);

  final PedidoRepository _repositorio;

  /// Devuelve el rol del usuario actual (se puede reemplazar en las pruebas).
  final Rol Function() _obtenerRol;

  List<Pedido> _pedidos = const [];
  bool _cargando = false;
  bool _cargado = false;
  bool _enviando = false;
  String? _error;

  List<Pedido> get pedidos => _pedidos;
  bool get cargando => _cargando;
  bool get cargado => _cargado;

  /// true mientras se registra un pedido o se cambia su estado (sirve para bloquear los botones).
  bool get enviando => _enviando;
  String? get error => _error;

  /// Busca un pedido por su id (null si no está en la lista).
  Pedido? buscarPorId(String id) {
    for (final pedido in _pedidos) {
      if (pedido.id == id) return pedido;
    }
    return null;
  }

  /// Obtiene la lista de pedidos desde la API.
  Future<void> cargar() async {
    if (_cargando) return;
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      _pedidos = await _repositorio.obtenerPedidos();
      _cargado = true;
    } on ApiException catch (e) {
      _error = e.mensajeCompleto;
    } on FormatException catch (e) {
      _error =
          'Los pedidos recibidos no tienen el formato esperado (${e.message})';
    } on TypeError {
      _error = 'Los pedidos recibidos no tienen el formato esperado';
    }
    _cargando = false;
    notifyListeners();
  }

  /// Registra un pedido nuevo. Lanza [ApiException] si la API lo rechaza.
  /// Si ya hay un envío en curso devuelve null (evita pedidos duplicados por doble toque).
  Future<Pedido?> crear(NuevoPedido nuevo) async {
    if (_enviando) return null;
    return _ejecutarEnvio(() async {
      final pedido = await _repositorio.crearPedido(nuevo, _obtenerRol());
      _pedidos = [pedido, ..._pedidos];
      return pedido;
    });
  }

  /// Cambia el estado de un pedido. Lanza [ApiException] si la API lo rechaza.
  /// Si hay un conflicto (otro usuario lo cambió antes) se recarga la lista.
  Future<Pedido?> cambiarEstado(String id, EstadoPedido estado) async {
    if (_enviando) return null;
    return _ejecutarEnvio(() async {
      try {
        final actualizado = await _repositorio.cambiarEstado(
          id,
          estado,
          _obtenerRol(),
        );
        _pedidos = [for (final p in _pedidos) p.id == id ? actualizado : p];
        return actualizado;
      } on ApiException catch (e) {
        if (e.esConflicto) {
          // La información local quedó desactualizada: se vuelve a pedir la lista.
          Future.microtask(cargar);
        }
        rethrow;
      }
    });
  }

  /// Marca [enviando] mientras dura la operación y siempre lo libera al terminar.
  Future<Pedido?> _ejecutarEnvio(Future<Pedido> Function() operacion) async {
    _enviando = true;
    notifyListeners();
    try {
      return await operacion();
    } finally {
      _enviando = false;
      notifyListeners();
    }
  }
}
