import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sabor_pedidos/data/api/api_exception.dart';
import 'package:sabor_pedidos/models/categoria.dart';
import 'package:sabor_pedidos/models/estado_pedido.dart';
import 'package:sabor_pedidos/models/nuevo_pedido.dart';
import 'package:sabor_pedidos/models/rol.dart';
import 'package:sabor_pedidos/providers/menu_provider.dart';
import 'package:sabor_pedidos/providers/pedidos_provider.dart';

import 'fakes.dart';

const _nuevo = NuevoPedido(
  mesa: 2,
  lineas: [LineaNuevoPedido(productoId: 'p1', cantidad: 1)],
);

void main() {
  group('MenuProvider', () {
    test('carga la carta y permite filtrar por categoría', () async {
      final provider = MenuProvider(FakeMenuRepository());
      expect(provider.cargado, isFalse);
      await provider.cargar();
      expect(provider.cargado, isTrue);
      expect(provider.error, isNull);
      expect(provider.productos, hasLength(3));
      expect(
        provider.productosDe(Categoria.fondos).single.nombre,
        'Lomo saltado',
      );
    });

    test('si la API falla guarda el mensaje de error', () async {
      final provider = MenuProvider(
        FakeMenuRepository(error: const ApiException('Sin conexión')),
      );
      await provider.cargar();
      expect(provider.cargado, isFalse);
      expect(provider.error, 'Sin conexión');
      expect(provider.cargando, isFalse);
    });

    test('se recupera después de un error al reintentar', () async {
      final repo = FakeMenuRepository(error: const ApiException('Falló'));
      final provider = MenuProvider(repo);
      await provider.cargar();
      repo.error = null;
      await provider.cargar();
      expect(provider.cargado, isTrue);
      expect(provider.error, isNull);
    });

    test('notifica a los oyentes al cambiar', () async {
      final provider = MenuProvider(FakeMenuRepository());
      var avisos = 0;
      provider.addListener(() => avisos++);
      await provider.cargar();
      expect(avisos, greaterThanOrEqualTo(2)); // al empezar y al terminar
    });
  });

  group('PedidosProvider', () {
    test('carga los pedidos', () async {
      final provider = PedidosProvider(
        FakePedidoRepository(),
        obtenerRol: () => Rol.mozo,
      );
      await provider.cargar();
      expect(provider.pedidos, hasLength(1));
      expect(provider.buscarPorId('ped1')?.mesa, 3);
      expect(provider.buscarPorId('no-existe'), isNull);
    });

    test('crear agrega el pedido al inicio de la lista', () async {
      final repo = FakePedidoRepository();
      final provider = PedidosProvider(repo, obtenerRol: () => Rol.mozo);
      await provider.cargar();
      final creado = await provider.crear(_nuevo);
      expect(creado, isNotNull);
      expect(provider.pedidos.first.id, creado!.id);
      expect(provider.pedidos, hasLength(2));
      expect(provider.enviando, isFalse);
    });

    test('un doble toque no registra el pedido dos veces', () async {
      final repo = FakePedidoRepository()..esperaCreacion = Completer<void>();
      final provider = PedidosProvider(repo, obtenerRol: () => Rol.mozo);
      final primero = provider.crear(_nuevo);
      final segundo = await provider.crear(_nuevo); // ignorado: ya hay un envío
      expect(segundo, isNull);
      expect(provider.enviando, isTrue);
      repo.esperaCreacion!.complete();
      await primero;
      expect(repo.creados, hasLength(1));
      expect(provider.enviando, isFalse);
    });

    test(
      'si la API rechaza el pedido se lanza ApiException y se libera el envío',
      () async {
        final repo = FakePedidoRepository()
          ..errorAlEscribir = const ApiException(
            'Producto agotado',
            codigoHttp: 422,
          );
        final provider = PedidosProvider(repo, obtenerRol: () => Rol.mozo);
        await expectLater(provider.crear(_nuevo), throwsA(isA<ApiException>()));
        expect(provider.enviando, isFalse);
        expect(provider.pedidos, isEmpty);
      },
    );

    test('cambiarEstado reemplaza el pedido y usa el rol actual', () async {
      final repo = FakePedidoRepository();
      final provider = PedidosProvider(repo, obtenerRol: () => Rol.cocinero);
      await provider.cargar();
      await provider.cambiarEstado('ped1', EstadoPedido.enPreparacion);
      expect(provider.buscarPorId('ped1')!.estado, EstadoPedido.enPreparacion);
      expect(repo.cambios.single.$3, Rol.cocinero);
    });

    test(
      'ante un conflicto (409) vuelve a pedir la lista al servidor',
      () async {
        final repo = FakePedidoRepository();
        final provider = PedidosProvider(repo, obtenerRol: () => Rol.cocinero);
        await provider.cargar();
        expect(repo.cargas, 1);
        repo.errorAlEscribir = const ApiException(
          'Modificado por otro usuario',
          codigoHttp: 409,
        );
        await expectLater(
          provider.cambiarEstado('ped1', EstadoPedido.enPreparacion),
          throwsA(isA<ApiException>()),
        );
        await Future<void>.delayed(Duration.zero); // deja correr la recarga
        expect(repo.cargas, 2);
      },
    );
  });
}
