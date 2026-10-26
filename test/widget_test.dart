import 'package:flutter_test/flutter_test.dart';

import 'package:sabor_pedidos/main.dart';
import 'package:sabor_pedidos/models/categoria.dart';
import 'package:sabor_pedidos/models/estado_pedido.dart';
import 'package:sabor_pedidos/models/item_pedido.dart';
import 'package:sabor_pedidos/models/pedido.dart';
import 'package:sabor_pedidos/models/producto.dart';
import 'package:sabor_pedidos/models/rol.dart';

void main() {
  group('Modelos', () {
    const lomo = Producto(
      id: 1,
      nombre: 'Lomo saltado',
      descripcion: 'Plato de prueba',
      precio: 26.0,
      categoria: Categoria.fondos,
    );

    test('El total del pedido suma los subtotales', () {
      final pedido = Pedido(
        id: 1,
        mesa: 2,
        fecha: DateTime(2026, 1, 1),
        items: const [
          ItemPedido(producto: lomo, cantidad: 2),
          ItemPedido(producto: lomo, cantidad: 1),
        ],
      );
      expect(pedido.total, 78.0);
      expect(pedido.cantidadProductos, 3);
    });

    test('El flujo de estados avanza en orden', () {
      expect(EstadoPedido.recibido.siguiente, EstadoPedido.enPreparacion);
      expect(EstadoPedido.enPreparacion.siguiente, EstadoPedido.listo);
      expect(EstadoPedido.listo.siguiente, EstadoPedido.entregado);
      expect(EstadoPedido.entregado.siguiente, isNull);
    });

    test('Permisos por rol', () {
      expect(Rol.cocinero.puedeCrearPedidos, isFalse);
      expect(Rol.mozo.puedeAvanzarDesde(EstadoPedido.listo), isTrue);
      expect(Rol.mozo.puedeAvanzarDesde(EstadoPedido.recibido), isFalse);
      expect(Rol.cocinero.puedeAvanzarDesde(EstadoPedido.recibido), isTrue);
    });
  });

  group('Interfaz', () {
    testWidgets('Bienvenida -> login valida el nombre -> menú principal',
        (tester) async {
      await tester.pumpWidget(const SaborPedidosApp());
      expect(find.text('Sabor Peruano'), findsOneWidget);

      await tester.tap(find.text('Comenzar'));
      await tester.pumpAndSettle();
      expect(find.text('Iniciar sesión'), findsOneWidget);

      // Sin nombre debe mostrar el error de validación.
      await tester.tap(find.text('Ingresar'));
      await tester.pump();
      expect(find.text('Ingresa un nombre de al menos 3 letras'), findsOneWidget);

      // Con nombre válido entra al menú principal.
      await tester.enterText(find.byType(TextFormField), 'Ana');
      await tester.tap(find.text('Ingresar'));
      await tester.pumpAndSettle();
      expect(find.text('Hola, Ana'), findsOneWidget);
      expect(find.text('Nuevo pedido'), findsOneWidget);
    });
  });
}
