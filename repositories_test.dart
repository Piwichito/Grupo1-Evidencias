import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sabor_pedidos/data/api/api_client.dart';
import 'package:sabor_pedidos/data/repositories/menu_repository.dart';
import 'package:sabor_pedidos/data/repositories/pedido_repository.dart';
import 'package:sabor_pedidos/models/categoria.dart';
import 'package:sabor_pedidos/models/estado_pedido.dart';
import 'package:sabor_pedidos/models/nuevo_pedido.dart';
import 'package:sabor_pedidos/models/rol.dart';

http.Response _json(Object cuerpo, int codigo) => http.Response.bytes(
  utf8.encode(jsonEncode(cuerpo)),
  codigo,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

const _pedidoJson = {
  'id': 'ped1',
  'numero': 1,
  'mesa': 5,
  'cliente': '',
  'observaciones': '',
  'estado': 'recibido',
  'items': [
    {
      'productoId': 'p1',
      'nombre': 'Lomo saltado',
      'precioUnitario': 26,
      'cantidad': 2,
      'subtotal': 52,
    },
  ],
  'total': 52,
  'creadoEn': '2026-11-08T15:00:00.000Z',
};

void main() {
  test('ApiMenuRepository convierte la carta en objetos Producto', () async {
    final api = ApiClient(
      baseUrl: 'http://x.test',
      cliente: MockClient(
        (req) async => _json([
          {
            'id': 'a',
            'nombre': 'Ceviche',
            'descripcion': '',
            'precio': 28,
            'categoria': 'entradas',
            'disponible': true,
          },
        ], 200),
      ),
    );
    final productos = await ApiMenuRepository(api).obtenerProductos();
    expect(productos.single.categoria, Categoria.entradas);
    expect(productos.single.precio, 28);
  });

  test('ApiPedidoRepository.obtenerPedidos pide /api/pedidos', () async {
    late Uri url;
    final api = ApiClient(
      baseUrl: 'http://x.test',
      cliente: MockClient((req) async {
        url = req.url;
        return _json([_pedidoJson], 200);
      }),
    );
    final pedidos = await ApiPedidoRepository(api).obtenerPedidos();
    expect(url.path, '/api/pedidos');
    expect(pedidos.single.numero, 1);
  });

  test('crearPedido envía el rol y el cuerpo correctos', () async {
    late http.Request recibida;
    final api = ApiClient(
      baseUrl: 'http://x.test',
      cliente: MockClient((req) async {
        recibida = req;
        return _json(_pedidoJson, 201);
      }),
    );
    final pedido = await ApiPedidoRepository(api).crearPedido(
      const NuevoPedido(
        mesa: 5,
        lineas: [LineaNuevoPedido(productoId: 'p1', cantidad: 2)],
      ),
      Rol.mozo,
    );
    expect(recibida.method, 'POST');
    expect(recibida.url.path, '/api/pedidos');
    expect(recibida.headers['X-Rol'], 'mozo');
    expect(jsonDecode(recibida.body)['items'][0]['productoId'], 'p1');
    expect(pedido.total, 52);
  });

  test('cambiarEstado usa PATCH con el estado en formato de la API', () async {
    late http.Request recibida;
    final api = ApiClient(
      baseUrl: 'http://x.test',
      cliente: MockClient((req) async {
        recibida = req;
        return _json({..._pedidoJson, 'estado': 'en_preparacion'}, 200);
      }),
    );
    final pedido = await ApiPedidoRepository(api)
        .cambiarEstado('ped1', EstadoPedido.enPreparacion, Rol.cocinero);
    expect(recibida.method, 'PATCH');
    expect(recibida.url.path, '/api/pedidos/ped1/estado');
    expect(recibida.headers['X-Rol'], 'cocinero');
    expect(jsonDecode(recibida.body), {'estado': 'en_preparacion'});
    expect(pedido.estado, EstadoPedido.enPreparacion);
  });
}
