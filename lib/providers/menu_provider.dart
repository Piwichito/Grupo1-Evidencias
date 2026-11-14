import 'package:flutter/foundation.dart';

import '../data/api/api_exception.dart';
import '../data/repositories/menu_repository.dart';
import '../models/categoria.dart';
import '../models/producto.dart';

/// Estado de la carta del menú. Las pantallas escuchan este objeto (Provider)
/// y se redibujan solas cuando cambia.
class MenuProvider extends ChangeNotifier {
  MenuProvider(this._repositorio);

  final MenuRepository _repositorio;

  List<Producto> _productos = const [];
  bool _cargando = false;
  bool _cargado = false;
  String? _error;

  List<Producto> get productos => _productos;
  bool get cargando => _cargando;

  /// true cuando la carta se obtuvo al menos una vez.
  bool get cargado => _cargado;
  String? get error => _error;

  List<Producto> productosDe(Categoria categoria) =>
      _productos.where((p) => p.categoria == categoria).toList();

  /// Obtiene la carta desde la API. Si falla, guarda el mensaje de error.
  Future<void> cargar() async {
    if (_cargando) return;
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      _productos = await _repositorio.obtenerProductos();
      _cargado = true;
    } on ApiException catch (e) {
      _error = e.mensajeCompleto;
    } on FormatException catch (e) {
      _error = 'La carta recibida no tiene el formato esperado (${e.message})';
    } on TypeError {
      _error = 'La carta recibida no tiene el formato esperado';
    }
    _cargando = false;
    notifyListeners();
  }
}
