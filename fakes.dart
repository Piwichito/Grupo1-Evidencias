import 'dart:async';

import 'package:sabor_pedidos/data/api/api_exception.dart';
import 'package:sabor_pedidos/data/repositories/menu_repository.dart';
import 'package:sabor_pedidos/data/repositories/pedido_repository.dart';
import 'package:sabor_pedidos/models/categoria.dart';
import 'package:sabor_pedidos/models/estado_pedido.dart';
import 'package:sabor_pedidos/models/item_pedido.dart';
import 'package:sabor_pedidos/models/nuevo_pedido.dart';
import 'package:sabor_pedidos/models/pedido.dart';
import 'package:sabor_pedidos/models/producto.dart';
import 'package:sabor_pedidos/models/rol.dart';

/// Carta de prueba (sin usar la API real).
const List<Producto> productosDePrueba = [
  Producto(
    id: 'p1',
    nombre: 'Ceviche clásico',
    descripcion: 'Pescado fresco y limón',
    precio: 28,
    categoria: Categoria.entradas,
  ),
  Producto(
    id: 'p2',
    nombre: 'Lomo saltado',
    descripcion: 'Lomo fino y papas',
    precio: 26,
    categoria: Categoria.fondos,
  ),
  Producto(
    id: 'p3',
    nombre: 'Chicha morada',
    descripcion: 'Jarra de 1 litro',
    precio: 12,
    categoria: Categoria.bebidas,
    disponible: false,
  ),
];

Pedido pedidoDePrueba({
  String id = 'ped1',
  int numero = 1,
  EstadoPedido estado = EstadoPedido.recibido,
}) {
  return Pedido(
    id: id,
    numero: numero,
    mesa: 3,
    cliente: 'Familia Rojas',
    estado: estado,
    total: 52,
    fecha: DateTime(2026, 11, 8, 14, 5),
    items: const [
      ItemPedido(
        productoId: 'p2',
        nombre: 'Lomo saltado',
        precioUnitario: 26,
        cantidad: 2,
      ),
    ],
  );
}

/// Repositorio de carta falso: devuelve la lista o lanza el error indicado.
class FakeMenuRepository implements MenuRepository {
  FakeMenuRepository({this.productos = productosDePrueba, this.error});

  List<Producto> productos;
  Object? error;
  int llamadas = 0;

  @override
  Future<List<Producto>> obtenerProductos() async {
    llamadas++;
    if (error != null) throw error!;
    return productos;
  }
}

/// Repositorio de pedidos falso: guarda todo en memoria y registra lo que recibe.
class FakePedidoRepository implements PedidoRepository {
  FakePedidoRepository({List<Pedido>? iniciales})
    : pedidos = iniciales ?? [pedidoDePrueba()];

  List<Pedido> pedidos;
  final List<NuevoPedido> creados = [];
  final List<(String, EstadoPedido, Rol)> cambios = [];

  /// Si se asigna, la siguiente operación lanza este error.
  ApiException? errorAlEscribir;

  /// Si se asigna, la creación espera a que se complete (sirve para simular un envío lento).
  Completer<void>? esperaCreacion;

  int cargas = 0;

  @override
  Future<List<Pedido>> obtenerPedidos() async {
    cargas++;
    return List.of(pedidos);
  }

  @override
  Future<Pedido> crearPedido(NuevoPedido nuevo, Rol rol) async {
    await esperaCreacion?.future;
    if (errorAlEscribir != null) throw errorAlEscribir!;
    creados.add(nuevo);
    final pedido = Pedido(
      id: 'nuevo${creados.length}',
      numero: pedidos.length + 1,
      mesa: nuevo.mesa,
      cliente: nuevo.cliente,
      observaciones: nuevo.observaciones,
      total: 0,
      fecha: DateTime(2026, 11, 8, 15),
      items: const [],
    );
    pedidos = [pedido, ...pedidos];
    return pedido;
  }

  @override
  Future<Pedido> cambiarEstado(String id, EstadoPedido estado, Rol rol) async {
    if (errorAlEscribir != null) throw errorAlEscribir!;
    cambios.add((id, estado, rol));
    final actual = pedidos.firstWhere((p) => p.id == id);
    final actualizado = Pedido(
      id: actual.id,
      numero: actual.numero,
      mesa: actual.mesa,
      cliente: actual.cliente,
      observaciones: actual.observaciones,
      total: actual.total,
      fecha: actual.fecha,
      items: actual.items,
      estado: estado,
    );
    pedidos = [for (final p in pedidos) p.id == id ? actualizado : p];
    return actualizado;
  }
}
