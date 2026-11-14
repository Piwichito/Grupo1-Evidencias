import 'package:flutter_test/flutter_test.dart';
import 'package:sabor_pedidos/models/categoria.dart';
import 'package:sabor_pedidos/models/estado_pedido.dart';
import 'package:sabor_pedidos/models/nuevo_pedido.dart';
import 'package:sabor_pedidos/models/pedido.dart';
import 'package:sabor_pedidos/models/producto.dart';
import 'package:sabor_pedidos/models/rol.dart';

void main() {
  group('Producto.fromJson', () {
    test('convierte el JSON de la API', () {
      final p = Producto.fromJson({
        'id': 'abc',
        'nombre': 'Ají de gallina',
        'descripcion': 'Pollo en crema',
        'precio': 22,
        'categoria': 'fondos',
        'disponible': true,
      });
      expect(p.id, 'abc');
      expect(p.precio, 22.0);
      expect(p.categoria, Categoria.fondos);
      expect(p.disponible, isTrue);
    });

    test('usa valores por defecto si faltan campos opcionales', () {
      final p = Producto.fromJson({
        'id': 'x',
        'nombre': 'Agua',
        'precio': 3.5,
        'categoria': 'bebidas',
      });
      expect(p.descripcion, '');
      expect(p.disponible, isTrue);
    });

    test('lanza un error si la categoría no existe', () {
      expect(
        () => Producto.fromJson({
          'id': 'x',
          'nombre': 'Sopa',
          'precio': 1,
          'categoria': 'sopas',
        }),
        throwsFormatException,
      );
    });
  });

  group('Pedido.fromJson', () {
    final json = {
      'id': 'ped1',
      'numero': 7,
      'mesa': 5,
      'cliente': 'Ana',
      'observaciones': 'Sin ají',
      'estado': 'en_preparacion',
      'items': [
        {
          'productoId': 'p1',
          'nombre': 'Lomo saltado',
          'precioUnitario': 26,
          'cantidad': 2,
          'subtotal': 52,
        },
        {
          'productoId': 'p2',
          'nombre': 'Chicha morada',
          'precioUnitario': 12.5,
          'cantidad': 1,
          'subtotal': 12.5,
        },
      ],
      'total': 64.5,
      'creadoEn': '2026-11-08T15:00:00.000Z',
    };

    test('convierte el pedido con sus ítems', () {
      final p = Pedido.fromJson(json);
      expect(p.numero, 7);
      expect(p.estado, EstadoPedido.enPreparacion);
      expect(p.items, hasLength(2));
      expect(p.total, 64.5);
      expect(p.cantidadProductos, 3);
      expect(p.items.first.subtotal, 52);
    });

    test('la fecha UTC se convierte a hora local', () {
      final p = Pedido.fromJson(json);
      expect(p.fecha.toUtc(), DateTime.utc(2026, 11, 8, 15));
    });

    test('lanza un error si el estado es desconocido', () {
      expect(
        () => Pedido.fromJson({...json, 'estado': 'volando'}),
        throwsFormatException,
      );
    });
  });

  group('EstadoPedido', () {
    test('el flujo avanza en orden', () {
      expect(EstadoPedido.recibido.siguiente, EstadoPedido.enPreparacion);
      expect(EstadoPedido.enPreparacion.siguiente, EstadoPedido.listo);
      expect(EstadoPedido.listo.siguiente, EstadoPedido.entregado);
      expect(EstadoPedido.entregado.siguiente, isNull);
      expect(EstadoPedido.anulado.siguiente, isNull);
    });

    test('desdeApi / valorApi son equivalentes', () {
      for (final estado in EstadoPedido.values) {
        expect(EstadoPedido.desdeApi(estado.valorApi), estado);
      }
      expect(EstadoPedido.enPreparacion.valorApi, 'en_preparacion');
    });
  });

  group('Rol', () {
    test('permisos por rol', () {
      expect(Rol.cocinero.puedeCrearPedidos, isFalse);
      expect(Rol.mozo.puedeAvanzarDesde(EstadoPedido.listo), isTrue);
      expect(Rol.mozo.puedeAvanzarDesde(EstadoPedido.recibido), isFalse);
      expect(Rol.cocinero.puedeAvanzarDesde(EstadoPedido.recibido), isTrue);
      expect(Rol.cocinero.puedeAvanzarDesde(EstadoPedido.listo), isFalse);
    });

    test('valorApi coincide con lo que espera la API', () {
      expect(Rol.mozo.valorApi, 'mozo');
      expect(Rol.administrador.valorApi, 'administrador');
    });
  });

  test('NuevoPedido.toJson arma el cuerpo que espera la API', () {
    const nuevo = NuevoPedido(
      mesa: 4,
      cliente: 'Ana',
      observaciones: 'Sin ají',
      lineas: [LineaNuevoPedido(productoId: 'p1', cantidad: 2)],
    );
    expect(nuevo.toJson(), {
      'mesa': 4,
      'cliente': 'Ana',
      'observaciones': 'Sin ají',
      'items': [
        {'productoId': 'p1', 'cantidad': 2},
      ],
    });
  });
}
