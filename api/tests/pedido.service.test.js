const { crearEntorno, producto } = require('./helpers');

let env;
let lomo;
let chicha;
let tacu;

beforeEach(async () => {
  env = await crearEntorno();
  lomo = await producto(env.productoRepo, 'Lomo saltado'); // S/ 26.00
  chicha = await producto(env.productoRepo, 'Chicha morada (jarra)'); // S/ 12.00
  tacu = await producto(env.productoRepo, 'Tacu tacu con bistec'); // agotado
});

const nuevo = (items, extra = {}) => ({ mesa: 3, items, ...extra });

describe('PedidoService.crear', () => {
  test('crea el pedido, numera, calcula subtotales y total', async () => {
    const p = await env.pedidoService.crear(
      nuevo([{ productoId: lomo.id, cantidad: 2 }, { productoId: chicha.id, cantidad: 1 }], { cliente: 'Familia Rojas' }),
      'mozo'
    );
    expect(p.numero).toBe(1);
    expect(p.estado).toBe('recibido');
    expect(p.total).toBe(64);
    expect(p.items[0]).toMatchObject({ nombre: 'Lomo saltado', precioUnitario: 26, cantidad: 2, subtotal: 52 });
    expect(p.cliente).toBe('Familia Rojas');
    expect(p.creadoEn).toBe('2026-11-08T15:00:00.000Z');
  });

  test('numera los pedidos de forma consecutiva', async () => {
    const a = await env.pedidoService.crear(nuevo([{ productoId: lomo.id, cantidad: 1 }]), 'mozo');
    const b = await env.pedidoService.crear(nuevo([{ productoId: lomo.id, cantidad: 1 }]), 'administrador');
    expect([a.numero, b.numero]).toEqual([1, 2]);
  });

  test('el cocinero no puede registrar pedidos (403)', async () => {
    await expect(env.pedidoService.crear(nuevo([{ productoId: lomo.id, cantidad: 1 }]), 'cocinero')).rejects.toMatchObject({ status: 403 });
  });

  test('rechaza datos inválidos (400)', async () => {
    await expect(env.pedidoService.crear({ mesa: 99, items: [] }, 'mozo')).rejects.toMatchObject({ status: 400, codigo: 'VALIDACION' });
  });

  test('rechaza productos agotados (422)', async () => {
    await expect(env.pedidoService.crear(nuevo([{ productoId: tacu.id, cantidad: 1 }]), 'mozo')).rejects.toMatchObject({
      status: 422,
      detalles: ['Tacu tacu con bistec: producto agotado'],
    });
  });

  test('rechaza productos que no existen (422)', async () => {
    await expect(env.pedidoService.crear(nuevo([{ productoId: 'f'.repeat(24), cantidad: 1 }]), 'mozo')).rejects.toMatchObject({ status: 422 });
  });

  test('un pedido con un producto inexistente no se guarda', async () => {
    await env.pedidoService.crear(nuevo([{ productoId: lomo.id, cantidad: 1 }, { productoId: 'f'.repeat(24), cantidad: 1 }]), 'mozo').catch(() => {});
    expect(await env.pedidoRepo.listar()).toHaveLength(0);
  });

  test('el precio lo define el servidor aunque el cliente envíe otro', async () => {
    const p = await env.pedidoService.crear(nuevo([{ productoId: lomo.id, cantidad: 1, precioUnitario: 0.01 }]), 'mozo');
    expect(p.total).toBe(26);
  });
});

describe('PedidoService.cambiarEstado', () => {
  let pedido;
  beforeEach(async () => {
    pedido = await env.pedidoService.crear(nuevo([{ productoId: lomo.id, cantidad: 1 }]), 'mozo');
  });

  test('recorre todo el flujo con los roles correctos', async () => {
    let r = await env.pedidoService.cambiarEstado(pedido.id, { estado: 'en_preparacion' }, 'cocinero');
    expect(r.estado).toBe('en_preparacion');
    r = await env.pedidoService.cambiarEstado(pedido.id, { estado: 'listo' }, 'cocinero');
    expect(r.estado).toBe('listo');
    r = await env.pedidoService.cambiarEstado(pedido.id, { estado: 'entregado' }, 'mozo');
    expect(r.estado).toBe('entregado');
  });

  test('no permite saltarse un estado (409)', async () => {
    await expect(env.pedidoService.cambiarEstado(pedido.id, { estado: 'listo' }, 'administrador')).rejects.toMatchObject({ status: 409 });
  });

  test('no permite retroceder (409)', async () => {
    await env.pedidoService.cambiarEstado(pedido.id, { estado: 'en_preparacion' }, 'cocinero');
    await expect(env.pedidoService.cambiarEstado(pedido.id, { estado: 'recibido' }, 'administrador')).rejects.toMatchObject({ status: 409 });
  });

  test('el mozo no puede pasar a preparación (403)', async () => {
    await expect(env.pedidoService.cambiarEstado(pedido.id, { estado: 'en_preparacion' }, 'mozo')).rejects.toMatchObject({ status: 403 });
  });

  test('anular funciona para el mozo y deja el pedido anulado', async () => {
    const r = await env.pedidoService.cambiarEstado(pedido.id, { estado: 'anulado' }, 'mozo');
    expect(r.estado).toBe('anulado');
  });

  test('el cocinero no puede anular (403)', async () => {
    await expect(env.pedidoService.cambiarEstado(pedido.id, { estado: 'anulado' }, 'cocinero')).rejects.toMatchObject({ status: 403 });
  });

  test('un pedido anulado o entregado no puede cambiar (409)', async () => {
    await env.pedidoService.cambiarEstado(pedido.id, { estado: 'anulado' }, 'mozo');
    await expect(env.pedidoService.cambiarEstado(pedido.id, { estado: 'en_preparacion' }, 'administrador')).rejects.toMatchObject({ status: 409 });
  });

  test('devuelve 404 si el pedido no existe y 400 si el id es inválido', async () => {
    await expect(env.pedidoService.cambiarEstado('e'.repeat(24), { estado: 'listo' }, 'mozo')).rejects.toMatchObject({ status: 404 });
    await expect(env.pedidoService.cambiarEstado('abc', { estado: 'listo' }, 'mozo')).rejects.toMatchObject({ status: 400 });
  });

  test('detecta un cambio simultáneo de otro usuario (409)', async () => {
    // Simula que entre la lectura y la escritura otro usuario cambió el estado.
    env.pedidoRepo.actualizarEstado = async () => null;
    await expect(env.pedidoService.cambiarEstado(pedido.id, { estado: 'en_preparacion' }, 'cocinero')).rejects.toMatchObject({
      status: 409,
      codigo: 'CONFLICTO',
    });
  });
});

describe('PedidoService.listar / obtener', () => {
  test('filtra por estado y valida el filtro', async () => {
    const a = await env.pedidoService.crear(nuevo([{ productoId: lomo.id, cantidad: 1 }]), 'mozo');
    await env.pedidoService.crear(nuevo([{ productoId: chicha.id, cantidad: 1 }]), 'mozo');
    await env.pedidoService.cambiarEstado(a.id, { estado: 'en_preparacion' }, 'cocinero');
    expect(await env.pedidoService.listar({ estado: 'en_preparacion' })).toHaveLength(1);
    expect(await env.pedidoService.listar()).toHaveLength(2);
    await expect(env.pedidoService.listar({ estado: 'xyz' })).rejects.toMatchObject({ status: 400 });
  });

  test('lista los más recientes primero', async () => {
    await env.pedidoService.crear(nuevo([{ productoId: lomo.id, cantidad: 1 }]), 'mozo');
    await env.pedidoService.crear(nuevo([{ productoId: lomo.id, cantidad: 1 }]), 'mozo');
    const lista = await env.pedidoService.listar();
    expect(lista.map((p) => p.numero)).toEqual([2, 1]);
  });
});
