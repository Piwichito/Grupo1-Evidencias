// Pruebas de integración contra una base MongoDB real (Atlas o local).
// Solo se ejecutan si defines MONGODB_TEST_URI (usa una base de PRUEBA, por ejemplo ".../saborpedidos_test").
// Al terminar, la base de prueba se elimina por completo.
//   PowerShell:  $env:MONGODB_TEST_URI="mongodb+srv://..../saborpedidos_test"; npm test
const request = require('supertest');
const mongoose = require('mongoose');

const uri = process.env.MONGODB_TEST_URI;
const describeSiHayMongo = uri ? describe : describe.skip;

describeSiHayMongo('Integración con MongoDB (repositorios Mongoose)', () => {
  let app;
  let productos;

  beforeAll(async () => {
    const { conectarMongo } = require('../src/config/db');
    const { crearApp } = require('../src/app');
    const { PedidoRepositoryMongo } = require('../src/repositories/pedido.repository.mongo');
    const { ProductoRepositoryMongo } = require('../src/repositories/producto.repository.mongo');
    const { cargarMenu } = require('../src/seed/cargar-menu');
    await conectarMongo(uri);
    await mongoose.connection.dropDatabase();
    const productoRepo = new ProductoRepositoryMongo();
    await cargarMenu(productoRepo);
    app = crearApp({ pedidoRepo: new PedidoRepositoryMongo(), productoRepo, logs: false });
    productos = (await request(app).get('/api/productos')).body;
  });

  afterAll(async () => {
    await mongoose.connection.dropDatabase();
    await mongoose.disconnect();
  });

  const idDe = (nombre) => productos.find((p) => p.nombre === nombre).id;

  test('la carta se carga una sola vez y se puede filtrar por categoría', async () => {
    expect(productos).toHaveLength(12);
    const { cargarMenu } = require('../src/seed/cargar-menu');
    const { ProductoRepositoryMongo } = require('../src/repositories/producto.repository.mongo');
    expect(await cargarMenu(new ProductoRepositoryMongo())).toBe(0); // no duplica
    const postres = await request(app).get('/api/productos?categoria=postres');
    expect(postres.body).toHaveLength(2);
  });

  test('crea pedidos numerados y guarda el total', async () => {
    const items = [{ productoId: idDe('Lomo saltado'), cantidad: 2 }, { productoId: idDe('Chicha morada (jarra)'), cantidad: 1 }];
    const a = await request(app).post('/api/pedidos').set('X-Rol', 'mozo').send({ mesa: 4, items });
    const b = await request(app).post('/api/pedidos').set('X-Rol', 'mozo').send({ mesa: 5, items });
    expect(a.status).toBe(201);
    expect(a.body.total).toBe(64);
    expect(b.body.numero).toBe(a.body.numero + 1);
  });

  test('numera sin repetir cuando se crean pedidos al mismo tiempo', async () => {
    const items = [{ productoId: idDe('Gaseosa personal'), cantidad: 1 }];
    const respuestas = await Promise.all(
      Array.from({ length: 8 }, () => request(app).post('/api/pedidos').set('X-Rol', 'mozo').send({ mesa: 1, items }))
    );
    const numeros = respuestas.map((r) => r.body.numero);
    expect(new Set(numeros).size).toBe(8);
  });

  test('recorre el flujo de estados y lista por estado', async () => {
    const items = [{ productoId: idDe('Anticuchos'), cantidad: 1 }];
    const { body: p } = await request(app).post('/api/pedidos').set('X-Rol', 'mozo').send({ mesa: 9, items });
    const cambiar = (rol, estado) => request(app).patch(`/api/pedidos/${p.id}/estado`).set('X-Rol', rol).send({ estado });
    expect((await cambiar('cocinero', 'en_preparacion')).body.estado).toBe('en_preparacion');
    expect((await cambiar('cocinero', 'listo')).body.estado).toBe('listo');
    expect((await cambiar('mozo', 'entregado')).body.estado).toBe('entregado');
    const entregados = await request(app).get('/api/pedidos?estado=entregado');
    expect(entregados.body.some((x) => x.id === p.id)).toBe(true);
    expect((await request(app).get(`/api/pedidos/${p.id}`)).body.items[0].nombre).toBe('Anticuchos');
  });

  test('dos cambios simultáneos del mismo pedido: solo uno gana (el otro recibe 409)', async () => {
    const items = [{ productoId: idDe('Suspiro limeño'), cantidad: 1 }];
    const { body: p } = await request(app).post('/api/pedidos').set('X-Rol', 'mozo').send({ mesa: 2, items });
    const cambiar = () => request(app).patch(`/api/pedidos/${p.id}/estado`).set('X-Rol', 'cocinero').send({ estado: 'en_preparacion' });
    const [r1, r2] = await Promise.all([cambiar(), cambiar()]);
    expect([r1.status, r2.status].sort()).toEqual([200, 409]);
  });

  test('el administrador actualiza el precio de un producto', async () => {
    const r = await request(app).patch(`/api/productos/${idDe('Limonada frozen')}`).set('X-Rol', 'administrador').send({ precio: 9.5 });
    expect(r.status).toBe(200);
    expect(r.body.precio).toBe(9.5);
  });
});
