// Validación de los datos que llegan en las peticiones. Lanza errorValidacion si hay problemas.
const { errorValidacion } = require('../utils/errors');
const { esIdValido } = require('../utils/helpers');
const { MAX_MESAS, LISTA_ESTADOS, CATEGORIAS } = require('../utils/estados');

const MAX_CLIENTE = 60;
const MAX_OBSERVACIONES = 200;
const MAX_LINEAS = 50;
const MAX_CANTIDAD = 99;

const esObjeto = (v) => v !== null && typeof v === 'object' && !Array.isArray(v);

// Texto opcional: devuelve el texto recortado o agrega un error.
function textoOpcional(valor, campo, max, detalles) {
  if (valor === undefined || valor === null) return '';
  if (typeof valor !== 'string' || valor.trim().length > max) {
    detalles.push(`${campo}: debe ser un texto de máximo ${max} caracteres`);
    return '';
  }
  return valor.trim();
}

function validarNuevoPedido(body) {
  const detalles = [];
  const b = esObjeto(body) ? body : {};

  if (!Number.isInteger(b.mesa) || b.mesa < 1 || b.mesa > MAX_MESAS) {
    detalles.push(`mesa: debe ser un número entero entre 1 y ${MAX_MESAS}`);
  }
  const cliente = textoOpcional(b.cliente, 'cliente', MAX_CLIENTE, detalles);
  const observaciones = textoOpcional(b.observaciones, 'observaciones', MAX_OBSERVACIONES, detalles);

  const items = [];
  if (!Array.isArray(b.items) || b.items.length === 0) {
    detalles.push('items: debe incluir al menos un producto');
  } else if (b.items.length > MAX_LINEAS) {
    detalles.push(`items: máximo ${MAX_LINEAS} productos por pedido`);
  } else {
    const vistos = new Set();
    b.items.forEach((it, i) => {
      const pos = `items[${i}]`;
      if (!esObjeto(it) || !esIdValido(it.productoId)) {
        detalles.push(`${pos}.productoId: id de producto inválido`);
        return;
      }
      if (!Number.isInteger(it.cantidad) || it.cantidad < 1 || it.cantidad > MAX_CANTIDAD) {
        detalles.push(`${pos}.cantidad: debe ser un entero entre 1 y ${MAX_CANTIDAD}`);
      }
      if (vistos.has(it.productoId)) {
        detalles.push(`${pos}.productoId: producto repetido en el pedido`);
      }
      vistos.add(it.productoId);
      items.push({ productoId: it.productoId, cantidad: it.cantidad });
    });
  }

  if (detalles.length > 0) throw errorValidacion(detalles);
  return { mesa: b.mesa, cliente, observaciones, items };
}

function validarCambioEstado(body) {
  const nuevo = esObjeto(body) ? body.estado : undefined;
  if (!LISTA_ESTADOS.includes(nuevo)) {
    throw errorValidacion([`estado: debe ser uno de ${LISTA_ESTADOS.join(', ')}`]);
  }
  return nuevo;
}

function validarNuevoProducto(body) {
  const detalles = [];
  const b = esObjeto(body) ? body : {};
  if (typeof b.nombre !== 'string' || b.nombre.trim().length < 2 || b.nombre.trim().length > 80) {
    detalles.push('nombre: debe tener entre 2 y 80 caracteres');
  }
  const descripcion = textoOpcional(b.descripcion, 'descripcion', 200, detalles);
  if (typeof b.precio !== 'number' || !Number.isFinite(b.precio) || b.precio < 0) {
    detalles.push('precio: debe ser un número mayor o igual a 0');
  }
  if (!CATEGORIAS.includes(b.categoria)) {
    detalles.push(`categoria: debe ser una de ${CATEGORIAS.join(', ')}`);
  }
  if (b.disponible !== undefined && typeof b.disponible !== 'boolean') {
    detalles.push('disponible: debe ser verdadero o falso');
  }
  if (detalles.length > 0) throw errorValidacion(detalles);
  return {
    nombre: b.nombre.trim(),
    descripcion,
    precio: b.precio,
    categoria: b.categoria,
    disponible: b.disponible ?? true,
  };
}

// Cambios parciales de un producto (solo precio y/o disponibilidad).
function validarCambiosProducto(body) {
  const detalles = [];
  const b = esObjeto(body) ? body : {};
  const cambios = {};
  if (b.precio !== undefined) {
    if (typeof b.precio !== 'number' || !Number.isFinite(b.precio) || b.precio < 0) {
      detalles.push('precio: debe ser un número mayor o igual a 0');
    } else cambios.precio = b.precio;
  }
  if (b.disponible !== undefined) {
    if (typeof b.disponible !== 'boolean') detalles.push('disponible: debe ser verdadero o falso');
    else cambios.disponible = b.disponible;
  }
  if (detalles.length === 0 && Object.keys(cambios).length === 0) {
    detalles.push('Envía al menos un campo a modificar: precio o disponible');
  }
  if (detalles.length > 0) throw errorValidacion(detalles);
  return cambios;
}

module.exports = { validarNuevoPedido, validarCambioEstado, validarNuevoProducto, validarCambiosProducto };
