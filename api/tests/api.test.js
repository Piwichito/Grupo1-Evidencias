// Pruebas de integración de los endpoints (Supertest) usando repositorios en memoria.
const request = require('supertest');
const { crearEntorno } = require('./helpers');

let app;
let productos;

beforeEach(async () => {
  ({ app } = await crearEntorno());
  productos = (await request(app).get('/api/productos')).body;
});

const idDe = (nombre) => productos.find((p) => p.nombre === nombre).id;
const crearPedido = (items = [{ productoId: idDe('Lomo saltado'), cantidad: 2 }], rol = 'mozo') =>
  request(app).post('/api/pedidos').set('X-Rol', rol).send({ mesa: 5, cliente: 'Ana', items });

describe('GET /api/health', () => {
  test('responde 200 con estado ok', async () => {
    const r = await request(app).get('/api/health');
    expect(r.status).toBe(200);
    expect(r.body.estado).toBe('ok');
  });
});

describe('Productos', () => {
  test('GET /api/productos devuelve la carta completa', async () => {
    expect(productos).toHaveLength(12);
    expect(productos[0]).toEqual(expect.objectContaining({ id: expect.any(String), nombre: expect.any(String), precio: expect.any(Number) }));
  });

  test('GET /api/productos?categoria=bebidas filtra por categoría', async () => {
    const r = await request(app).get('/api/productos?categoria=bebidas');
    expect(r.status).toBe(200);
    expect(r.body).toHaveLength(3);
    expect(r.body.every((p) => p.categoria === 'bebidas')).toBe(true);
  });

  test('GET con categoría inválida responde 400', async () => {
    expect((await request(app).get('/api/productos?categoria=sopas')).status).toBe(400);
  });

  test('GET /api/productos/:id devuelve un producto, 404 si no existe, 400 si el id es inválido', async () => {
    expect((await request(app).get(`/api/productos/${idDe('Lomo saltado')}`)).body.nombre).toBe('Lomo saltado');
    expect((await request(app).get(`/api/productos/${'0'.repeat(24)}`)).status).toBe(404);
    expect((await request(app).get('/api/productos/abc')).status).toBe(400);
  });

  test('POST /api/productos: solo el administrador crea productos', async () => {
    const cuerpo = { nombre: 'Chaufa', descripcion: 'Arroz chaufa', precio: 18, categoria: 'fondos' };
    expect((await request(app).post('/api/productos').set('X-Rol', 'mozo').send(cuerpo)).status).toBe(403);
    const ok = await request(app).post('/api/productos').set('X-Rol', 'administrador').send(cuerpo);
    expect(ok.status).toBe(201);
    expect(ok.headers.location).toBe(`/api/productos/${ok.body.id}`);
    // Nombre repetido -> 409
    expect((await request(app).post('/api/productos').set('X-Rol', 'administrador').send(cuerpo)).status).toBe(409);
  });

  test('PATCH /api/productos/:id cambia el precio y la disponibilidad', async () => {
    const id = idDe('Tacu tacu con bistec');
    const r = await request(app).patch(`/api/productos/${id}`).set('X-Rol', 'administrador').send({ disponible: true, precio: 27 });
    expect(r.status).toBe(200);
    expect(r.body).toMatchObject({ disponible: true, precio: 27 });
    expect((await request(app).patch(`/api/productos/${id}`).set('X-Rol', 'administrador').send({})).status).toBe(400);
    expect((await request(app).patch(`/api/productos/${'0'.repeat(24)}`).set('X-Rol', 'administrador').send({ precio: 1 })).status).toBe(404);
  });
});

describe('POST /api/pedidos', () => {
  test('crea un pedido y responde 201 con el total calculado', async () => {
    const r = await crearPedido([{ productoId: idDe('Lomo saltado'), cantidad: 2 }, { productoId: idDe('Chicha morada (jarra)'), cantidad: 1 }]);
    expect(r.status).toBe(201);
    expect(r.body).toMatchObject({ numero: 1, mesa: 5, estado: 'recibido', total: 64 });
    expect(r.headers.location).toBe(`/api/pedidos/${r.body.id}`);
  });

  test('sin el encabezado X-Rol responde 400', async () => {
    const r = await request(app).post('/api/pedidos').send({ mesa: 1, items: [] });
    expect(r.status).toBe(400);
    expect(r.body.error.detalles[0]).toMatch(/X-Rol/);
  });

  test('con un rol desconocido responde 400', async () => {
    expect((await crearPedido(undefined, 'gerente')).status).toBe(400);
  });

  test('el cocinero recibe 403', async () => {
    expect((await crearPedido(undefined, 'cocinero')).status).toBe(403);
  });

  test('datos inválidos responden 400 con la lista de problemas', async () => {
    const r = await request(app).post('/api/pedidos').set('X-Rol', 'mozo').send({ mesa: 0, items: [] });
    expect(r.status).toBe(400);
    expect(r.body.error.codigo).toBe('VALIDACION');
    expect(r.body.error.detalles.length).toBeGreaterThanOrEqual(2);
  });

  test('un producto agotado responde 422', async () => {
    const r = await crearPedido([{ productoId: idDe('Tacu tacu con bistec'), cantidad: 1 }]);
    expect(r.status).toBe(422);
    expect(r.body.error.codigo).toBe('REGLA_NEGOCIO');
  });

  test('un JSON mal formado responde 400', async () => {
    const r = await request(app).post('/api/pedidos').set('X-Rol', 'mozo').set('Content-Type', 'application/json').send('{"mesa": 5,');
    expect(r.status).toBe(400);
    expect(r.body.error.codigo).toBe('JSON_INVALIDO');
  });
});

describe('GET /api/pedidos', () => {
  test('lista, filtra por estado y consulta por id', async () => {
    const a = (await crearPedido()).body;
    await crearPedido([{ productoId: idDe('Gaseosa personal'), cantidad: 3 }]);
    await request(app).patch(`/api/pedidos/${a.id}/estado`).set('X-Rol', 'cocinero').send({ estado: 'en_preparacion' });

    const todos = await request(app).get('/api/pedidos');
    expect(todos.body.map((p) => p.numero)).toEqual([2, 1]);

    const enPrep = await request(app).get('/api/pedidos?estado=en_preparacion');
    expect(enPrep.body).toHaveLength(1);
    expect(enPrep.body[0].id).toBe(a.id);

    expect((await request(app).get(`/api/pedidos/${a.id}`)).body.numero).toBe(1);
    expect((await request(app).get(`/api/pedidos/${'0'.repeat(24)}`)).status).toBe(404);
    expect((await request(app).get('/api/pedidos/xyz')).status).toBe(400);
    expect((await request(app).get('/api/pedidos?estado=otro')).status).toBe(400);
  });
});

describe('PATCH /api/pedidos/:id/estado', () => {
  test('recorre el flujo completo con los roles correctos', async () => {
    const { id } = (await crearPedido()).body;
    const cambiar = (rol, estado) => request(app).patch(`/api/pedidos/${id}/estado`).set('X-Rol', rol).send({ estado });
    expect((await cambiar('cocinero', 'en_preparacion')).body.estado).toBe('en_preparacion');
    expect((await cambiar('cocinero', 'listo')).body.estado).toBe('listo');
    expect((await cambiar('mozo', 'entregado')).body.estado).toBe('entregado');
  });

  test('transición inválida: 409; rol sin permiso: 403; estado desconocido: 400', async () => {
    const { id } = (await crearPedido()).body;
    const cambiar = (rol, estado) => request(app).patch(`/api/pedidos/${id}/estado`).set('X-Rol', rol).send({ estado });
    expect((await cambiar('administrador', 'entregado')).status).toBe(409);
    expect((await cambiar('mozo', 'en_preparacion')).status).toBe(403);
    expect((await cambiar('mozo', 'volando')).status).toBe(400);
  });

  test('anular un pedido y no poder modificarlo después', async () => {
    const { id } = (await crearPedido()).body;
    const anulado = await request(app).patch(`/api/pedidos/${id}/estado`).set('X-Rol', 'mozo').send({ estado: 'anulado' });
    expect(anulado.body.estado).toBe('anulado');
    const otra = await request(app).patch(`/api/pedidos/${id}/estado`).set('X-Rol', 'administrador').send({ estado: 'en_preparacion' });
    expect(otra.status).toBe(409);
  });

  test('pedido inexistente: 404', async () => {
    const r = await request(app).patch(`/api/pedidos/${'0'.repeat(24)}/estado`).set('X-Rol', 'mozo').send({ estado: 'anulado' });
    expect(r.status).toBe(404);
  });
});

describe('Rutas inexistentes', () => {
  test('responde 404 con el mismo formato de error', async () => {
    const r = await request(app).get('/api/mesas');
    expect(r.status).toBe(404);
    expect(r.body.error.codigo).toBe('RUTA_NO_ENCONTRADA');
  });
});
