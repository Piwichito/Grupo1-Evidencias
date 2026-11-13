const { puedeCrearPedidos, puedeGestionarCarta, puedeCambiarEstado } = require('../src/utils/permisos');
const { siguienteEstado, estaAbierto } = require('../src/utils/estados');

describe('Flujo de estados', () => {
  test('el flujo avanza recibido -> en_preparacion -> listo -> entregado', () => {
    expect(siguienteEstado('recibido')).toBe('en_preparacion');
    expect(siguienteEstado('en_preparacion')).toBe('listo');
    expect(siguienteEstado('listo')).toBe('entregado');
    expect(siguienteEstado('entregado')).toBeNull();
    expect(siguienteEstado('anulado')).toBeNull();
  });

  test('un pedido entregado o anulado ya no está abierto', () => {
    expect(estaAbierto('recibido')).toBe(true);
    expect(estaAbierto('listo')).toBe(true);
    expect(estaAbierto('entregado')).toBe(false);
    expect(estaAbierto('anulado')).toBe(false);
  });
});

describe('Permisos por rol', () => {
  test('el cocinero no puede crear pedidos', () => {
    expect(puedeCrearPedidos('cocinero')).toBe(false);
    expect(puedeCrearPedidos('mozo')).toBe(true);
    expect(puedeCrearPedidos('administrador')).toBe(true);
  });

  test('solo el administrador gestiona la carta', () => {
    expect(puedeGestionarCarta('administrador')).toBe(true);
    expect(puedeGestionarCarta('mozo')).toBe(false);
  });

  test('el cocinero avanza recibido -> en_preparacion -> listo, pero no entrega', () => {
    expect(puedeCambiarEstado('cocinero', 'recibido', 'en_preparacion')).toBe(true);
    expect(puedeCambiarEstado('cocinero', 'en_preparacion', 'listo')).toBe(true);
    expect(puedeCambiarEstado('cocinero', 'listo', 'entregado')).toBe(false);
  });

  test('el mozo solo entrega pedidos listos', () => {
    expect(puedeCambiarEstado('mozo', 'listo', 'entregado')).toBe(true);
    expect(puedeCambiarEstado('mozo', 'recibido', 'en_preparacion')).toBe(false);
  });

  test('anular: mozo y administrador sí, cocinero no', () => {
    expect(puedeCambiarEstado('mozo', 'recibido', 'anulado')).toBe(true);
    expect(puedeCambiarEstado('administrador', 'listo', 'anulado')).toBe(true);
    expect(puedeCambiarEstado('cocinero', 'recibido', 'anulado')).toBe(false);
  });

  test('el administrador puede realizar cualquier avance', () => {
    expect(puedeCambiarEstado('administrador', 'recibido', 'en_preparacion')).toBe(true);
    expect(puedeCambiarEstado('administrador', 'listo', 'entregado')).toBe(true);
  });
});
