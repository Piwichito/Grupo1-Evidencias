// Permisos por rol. Replican las reglas de la app móvil (clase Rol en Dart).
const { ESTADOS } = require('./estados');

// Mozo y administrador pueden registrar pedidos.
const puedeCrearPedidos = (rol) => rol !== 'cocinero';

// Solo el administrador gestiona la carta.
const puedeGestionarCarta = (rol) => rol === 'administrador';

// ¿Puede este rol cambiar un pedido de "actual" a "nuevo"?
// (La validez del flujo se comprueba aparte, en el servicio.)
function puedeCambiarEstado(rol, actual, nuevo) {
  if (nuevo === ESTADOS.ANULADO) return rol !== 'cocinero';
  if (rol === 'administrador') return true;
  if (rol === 'cocinero') {
    return (
      (actual === ESTADOS.RECIBIDO && nuevo === ESTADOS.EN_PREPARACION) ||
      (actual === ESTADOS.EN_PREPARACION && nuevo === ESTADOS.LISTO)
    );
  }
  // Mozo: solo entrega pedidos listos.
  return actual === ESTADOS.LISTO && nuevo === ESTADOS.ENTREGADO;
}

module.exports = { puedeCrearPedidos, puedeGestionarCarta, puedeCambiarEstado };
