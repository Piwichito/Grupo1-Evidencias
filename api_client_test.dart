import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sabor_pedidos/data/api/api_client.dart';
import 'package:sabor_pedidos/data/api/api_exception.dart';

/// Respuesta JSON codificada en UTF-8 (como la envía la API).
http.Response _json(Object cuerpo, int codigo) => http.Response.bytes(
  utf8.encode(jsonEncode(cuerpo)),
  codigo,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

ApiClient _cliente(
  MockClient mock, {
  Duration tiempoMaximo = const Duration(seconds: 5),
}) => ApiClient(
  baseUrl: 'http://servidor.test',
  cliente: mock,
  tiempoMaximo: tiempoMaximo,
);

void main() {
  test('GET devuelve el JSON decodificado y conserva las tildes', () async {
    final api = _cliente(
      MockClient((req) async {
        expect(req.url.toString(), 'http://servidor.test/api/productos');
        return _json([
          {'nombre': 'Ají de gallina'},
        ], 200);
      }),
    );
    final datos = await api.get('/api/productos') as List<dynamic>;
    expect(datos.first['nombre'], 'Ají de gallina');
  });

  test('POST envía el cuerpo en JSON y las cabeceras indicadas', () async {
    late http.Request recibida;
    final api = _cliente(
      MockClient((req) async {
        recibida = req;
        return _json({'ok': true}, 201);
      }),
    );
    await api.post('/api/pedidos', {'mesa': 3}, headers: {'X-Rol': 'mozo'});
    expect(recibida.method, 'POST');
    expect(recibida.headers['X-Rol'], 'mozo');
    expect(recibida.headers['Content-Type'], contains('application/json'));
    expect(jsonDecode(recibida.body), {'mesa': 3});
  });

  test('PATCH usa el método correcto', () async {
    late http.Request recibida;
    final api = _cliente(
      MockClient((req) async {
        recibida = req;
        return _json({'ok': true}, 200);
      }),
    );
    await api.patch('/api/pedidos/1/estado', {'estado': 'listo'});
    expect(recibida.method, 'PATCH');
  });

  test(
    'un error de la API se convierte en ApiException con sus detalles',
    () async {
      final api = _cliente(
        MockClient(
          (req) async => _json({
            'error': {
              'codigo': 'VALIDACION',
              'mensaje': 'Los datos enviados no son válidos',
              'detalles': ['mesa: debe ser un número entero entre 1 y 30'],
            },
          }, 400),
        ),
      );
      try {
        await api.post('/api/pedidos', {});
        fail('Debía lanzar ApiException');
      } on ApiException catch (e) {
        expect(e.codigoHttp, 400);
        expect(e.mensaje, 'Los datos enviados no son válidos');
        expect(e.detalles, hasLength(1));
        expect(e.mensajeCompleto, contains('mesa'));
      }
    },
  );

  test('el código 409 se identifica como conflicto', () async {
    final api = _cliente(
      MockClient(
        (req) async => _json({
          'error': {'mensaje': 'Transición no permitida', 'detalles': []},
        }, 409),
      ),
    );
    try {
      await api.patch('/api/pedidos/1/estado', {'estado': 'listo'});
      fail('Debía lanzar ApiException');
    } on ApiException catch (e) {
      expect(e.esConflicto, isTrue);
    }
  });

  test('sin conexión: mensaje claro para el usuario', () async {
    final api = _cliente(
      MockClient((req) async => throw http.ClientException('sin red')),
    );
    expect(
      () => api.get('/api/productos'),
      throwsA(
        isA<ApiException>().having(
          (e) => e.mensaje,
          'mensaje',
          contains('No se pudo conectar'),
        ),
      ),
    );
  });

  test(
    'si el servidor tarda demasiado se informa el tiempo de espera',
    () async {
      final api = _cliente(
        MockClient((req) async {
          await Future<void>.delayed(const Duration(milliseconds: 300));
          return _json([], 200);
        }),
        tiempoMaximo: const Duration(milliseconds: 50),
      );
      expect(
        () => api.get('/api/productos'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.mensaje,
            'mensaje',
            contains('tardó demasiado'),
          ),
        ),
      );
    },
  );

  test('una respuesta que no es JSON no rompe la app', () async {
    final api = _cliente(
      MockClient((req) async => http.Response('<html>', 200)),
    );
    expect(() => api.get('/api/productos'), throwsA(isA<ApiException>()));
  });

  test('un error 500 sin cuerpo JSON da un mensaje genérico', () async {
    final api = _cliente(MockClient((req) async => http.Response('', 500)));
    expect(
      () => api.get('/api/productos'),
      throwsA(isA<ApiException>().having((e) => e.codigoHttp, 'codigo', 500)),
    );
  });
}
