// Constantes y reglas del flujo de un pedido. Se usan en toda la API.

const ESTADOS = Object.freeze({
  RECIBIDO: 'recibido',
  EN_PREPARACION: 'en_preparacion',
  LISTO: 'listo',
  ENTREGADO: 'entregado',
  ANULADO: 'anulado',
});

const LISTA_ESTADOS = Object.values(ESTADOS);

const CATEGORIAS = Object.freeze(['entradas', 'fondos', 'bebidas', 'postres']);

const ROLES = Object.freeze(['mozo', 'cocinero', 'administrador']);

const MAX_MESAS = 30;

// Siguiente estado del flujo normal.
const FLUJO = Object.freeze({
  [ESTADOS.RECIBIDO]: ESTADOS.EN_PREPARACION,
  [ESTADOS.EN_PREPARACION]: ESTADOS.LISTO,
  [ESTADOS.LISTO]: ESTADOS.ENTREGADO,
});

const siguienteEstado = (estado) => FLUJO[estado] ?? null;

// Un pedido está "abierto" mientras no esté entregado ni anulado.
const estaAbierto = (estado) => estado !== ESTADOS.ENTREGADO && estado !== ESTADOS.ANULADO;

module.exports = { ESTADOS, LISTA_ESTADOS, CATEGORIAS, ROLES, MAX_MESAS, siguienteEstado, estaAbierto };
