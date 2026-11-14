const { validarNuevoPedido, validarCambioEstado, validarNuevoProducto, validarCambiosProducto } = require('../src/validators/pedido.validator');

const ID_A = 'a'.repeat(24);
const ID_B = 'b'.repeat(24);
const pedidoValido = () => ({ mesa: 5, cliente: ' Ana ', observaciones: 'Sin ají', items: [{ productoId: ID_A, cantidad: 2 }] });

const detalles = (fn) => {
  try {
    fn();
  } catch (e) {
    return e.detalles;
  }
  return null;
};

describe('validarNuevoPedido', () => {
  test('acepta un pedido válido y recorta los textos', () => {
    const r = validarNuevoPedido(pedidoValido());
    expect(r.mesa).toBe(5);
    expect(r.cliente).toBe('Ana');
    expect(r.items).toHaveLength(1);
  });

  test('cliente y observaciones son opcionales', () => {
    const r = validarNuevoPedido({ mesa: 1, items: [{ productoId: ID_A, cantidad: 1 }] });
    expect(r.cliente).toBe('');
    expect(r.observaciones).toBe('');
  });

  test.each([[0], [31], [2.5], ['5'], [null], [undefined]])('rechaza la mesa %p', (mesa) => {
    const d = detalles(() => validarNuevoPedido({ ...pedidoValido(), mesa }));
    expect(d.some((x) => x.startsWith('mesa'))).toBe(true);
  });

  test('rechaza un pedido sin productos', () => {
    expect(detalles(() => validarNuevoPedido({ ...pedidoValido(), items: [] }))).toContain('items: debe incluir al menos un producto');
  });

  test.each([[0], [100], [1.5], ['2']])('rechaza la cantidad %p', (cantidad) => {
    const d = detalles(() => validarNuevoPedido({ ...pedidoValido(), items: [{ productoId: ID_A, cantidad }] }));
    expect(d.some((x) => x.includes('cantidad'))).toBe(true);
  });

  test('rechaza ids de producto inválidos', () => {
    const d = detalles(() => validarNuevoPedido({ ...pedidoValido(), items: [{ productoId: '123', cantidad: 1 }] }));
    expect(d.some((x) => x.includes('productoId'))).toBe(true);
  });

  test('rechaza productos repetidos', () => {
    const items = [{ productoId: ID_A, cantidad: 1 }, { productoId: ID_A, cantidad: 2 }];
    expect(detalles(() => validarNuevoPedido({ ...pedidoValido(), items })).some((x) => x.includes('repetido'))).toBe(true);
  });

  test('rechaza cliente demasiado largo y observaciones que no son texto', () => {
    const d = detalles(() => validarNuevoPedido({ ...pedidoValido(), cliente: 'x'.repeat(61), observaciones: 123 }));
    expect(d).toHaveLength(2);
  });

  test('rechaza un cuerpo que no es un objeto', () => {
    expect(detalles(() => validarNuevoPedido(null))).not.toBeNull();
    expect(detalles(() => validarNuevoPedido('texto'))).not.toBeNull();
  });

  test('acepta varios productos distintos', () => {
    const items = [{ productoId: ID_A, cantidad: 1 }, { productoId: ID_B, cantidad: 3 }];
    expect(validarNuevoPedido({ ...pedidoValido(), items }).items).toHaveLength(2);
  });
});

describe('validarCambioEstado', () => {
  test('acepta un estado conocido', () => {
    expect(validarCambioEstado({ estado: 'listo' })).toBe('listo');
  });
  test('rechaza un estado desconocido o ausente', () => {
    expect(detalles(() => validarCambioEstado({ estado: 'cocinando' }))).not.toBeNull();
    expect(detalles(() => validarCambioEstado({}))).not.toBeNull();
    expect(detalles(() => validarCambioEstado(undefined))).not.toBeNull();
  });
});

describe('validación de productos', () => {
  test('acepta un producto válido', () => {
    const r = validarNuevoProducto({ nombre: ' Chaufa ', precio: 15.5, categoria: 'fondos' });
    expect(r).toMatchObject({ nombre: 'Chaufa', precio: 15.5, categoria: 'fondos', disponible: true });
  });
  test('rechaza precio negativo, categoría inválida y nombre corto', () => {
    const d = detalles(() => validarNuevoProducto({ nombre: 'a', precio: -1, categoria: 'sopas' }));
    expect(d).toHaveLength(3);
  });
  test('los cambios parciales exigen al menos un campo válido', () => {
    expect(validarCambiosProducto({ precio: 10 })).toEqual({ precio: 10 });
    expect(validarCambiosProducto({ disponible: false })).toEqual({ disponible: false });
    expect(detalles(() => validarCambiosProducto({}))).not.toBeNull();
    expect(detalles(() => validarCambiosProducto({ precio: 'gratis' }))).not.toBeNull();
  });
});
