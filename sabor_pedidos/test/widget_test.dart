import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sabor_pedidos/data/api/api_exception.dart';
import 'package:sabor_pedidos/data/sesion.dart';
import 'package:sabor_pedidos/main.dart';
import 'package:sabor_pedidos/models/estado_pedido.dart';

import 'fakes.dart';

/// Abre la app con repositorios falsos y entra con el nombre y rol indicados.
Future<void> _entrar(
  WidgetTester tester, {
  required FakeMenuRepository menu,
  required FakePedidoRepository pedidos,
  String nombre = 'Ana',
  String? rol,
}) async {
  await tester.pumpWidget(
    SaborPedidosApp(menuRepository: menu, pedidoRepository: pedidos),
  );
  await tester.tap(find.text('Comenzar'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextFormField), nombre);
  if (rol != null) {
    await tester.tap(find.text(rol));
    await tester.pump();
  }
  await tester.tap(find.text('Ingresar'));
  await tester.pumpAndSettle();
}

void main() {
  setUp(Sesion.cerrar);

  testWidgets('bienvenida -> login valida el nombre -> menú principal', (
    tester,
  ) async {
    final menu = FakeMenuRepository();
    final pedidos = FakePedidoRepository();
    await tester.pumpWidget(
      SaborPedidosApp(menuRepository: menu, pedidoRepository: pedidos),
    );
    expect(find.text('Sabor Peruano'), findsOneWidget);

    await tester.tap(find.text('Comenzar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ingresar'));
    await tester.pump();
    expect(find.text('Ingresa un nombre de al menos 3 letras'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'Ana');
    await tester.tap(find.text('Ingresar'));
    await tester.pumpAndSettle();
    expect(find.text('Hola, Ana'), findsOneWidget);
    expect(find.text('Nuevo pedido'), findsOneWidget);
    // Al entrar, la app pidió la carta y los pedidos a la API (falsa).
    expect(menu.llamadas, 1);
    expect(pedidos.cargas, 1);
  });

  testWidgets('el cocinero no ve la opción "Nuevo pedido"', (tester) async {
    await _entrar(
      tester,
      menu: FakeMenuRepository(),
      pedidos: FakePedidoRepository(),
      rol: 'Cocinero',
    );
    expect(find.text('Nuevo pedido'), findsNothing);
    expect(find.text('Pedidos'), findsOneWidget);
  });

  testWidgets('registrar un pedido: valida la mesa y lo envía a la API', (
    tester,
  ) async {
    final pedidos = FakePedidoRepository();
    await _entrar(tester, menu: FakeMenuRepository(), pedidos: pedidos);

    await tester.tap(find.text('Nuevo pedido'));
    await tester.pumpAndSettle();
    expect(find.text('Ceviche clásico'), findsOneWidget);

    // Sin mesa ni productos no se envía nada.
    await tester.ensureVisible(find.text('Registrar pedido'));
    await tester.tap(find.text('Registrar pedido'));
    await tester.pump();
    expect(find.text('Ingresa una mesa entre 1 y 30'), findsOneWidget);
    expect(pedidos.creados, isEmpty);

    // Con mesa y un producto, se confirma y se envía.
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Número de mesa'),
      '5',
    );
    await tester.tap(find.byIcon(Icons.add_circle_outline).first);
    await tester.pump();
    expect(find.text('S/ 28.00'), findsWidgets); // total actualizado

    await tester.ensureVisible(find.text('Registrar pedido'));
    await tester.tap(find.text('Registrar pedido'));
    await tester.pumpAndSettle();
    expect(find.text('Confirmar pedido'), findsOneWidget);
    await tester.tap(find.text('Registrar'));
    await tester.pumpAndSettle();

    expect(pedidos.creados, hasLength(1));
    expect(pedidos.creados.single.mesa, 5);
    expect(pedidos.creados.single.lineas.single.productoId, 'p1');
    expect(find.text('Hola, Ana'), findsOneWidget); // volvió al menú
  });

  testWidgets('si la API rechaza el pedido, la pantalla sigue abierta', (
    tester,
  ) async {
    final pedidos = FakePedidoRepository()
      ..errorAlEscribir = const ApiException(
        'No se puede procesar el pedido',
        codigoHttp: 422,
        detalles: ['Chicha morada: producto agotado'],
      );
    await _entrar(tester, menu: FakeMenuRepository(), pedidos: pedidos);

    await tester.tap(find.text('Nuevo pedido'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Número de mesa'),
      '2',
    );
    await tester.tap(find.byIcon(Icons.add_circle_outline).first);
    await tester.pump();
    await tester.ensureVisible(find.text('Registrar pedido'));
    await tester.tap(find.text('Registrar pedido'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Registrar'));
    await tester.pump(); // procesa el envío
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.textContaining('producto agotado'), findsOneWidget);
    expect(find.text('Nuevo pedido'), findsWidgets); // sigue en el formulario
  });

  testWidgets(
    'lista de pedidos -> detalle -> avanzar el estado (administrador)',
    (tester) async {
      final pedidos = FakePedidoRepository();
      await _entrar(
        tester,
        menu: FakeMenuRepository(),
        pedidos: pedidos,
        rol: 'Administrador',
      );

      await tester.tap(find.text('Pedidos'));
      await tester.pumpAndSettle();
      expect(find.text('Pedido #1 · Mesa 3'), findsOneWidget);

      await tester.tap(find.text('Pedido #1 · Mesa 3'));
      await tester.pumpAndSettle();
      expect(find.text('2 x Lomo saltado'), findsOneWidget);

      await tester.tap(find.text('Marcar como En preparación'));
      await tester.pumpAndSettle();

      expect(pedidos.cambios.single.$2, EstadoPedido.enPreparacion);
      expect(find.text('Marcar como Listo'), findsOneWidget);
    },
  );

  testWidgets(
    'si la carta no carga, se muestra el error y se puede reintentar',
    (tester) async {
      final menu = FakeMenuRepository(
        error: const ApiException('Sin conexión'),
      );
      await _entrar(tester, menu: menu, pedidos: FakePedidoRepository());

      // La opción está en la segunda fila del menú: se desplaza hasta ella antes de tocarla.
      await tester.ensureVisible(find.text('Carta del menú'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Carta del menú'));
      await tester.pumpAndSettle();
      expect(find.text('Sin conexión'), findsOneWidget);

      menu.error = null; // vuelve la conexión
      await tester.tap(find.text('Reintentar'));
      await tester.pumpAndSettle();
      expect(find.text('Ceviche clásico'), findsOneWidget);
    },
  );
}
