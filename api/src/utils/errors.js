// Errores controlados de la API. El middleware de errores los convierte en respuestas JSON.

class AppError extends Error {
  constructor(status, codigo, mensaje, detalles = []) {
    super(mensaje);
    this.name = 'AppError';
    this.status = status;
    this.codigo = codigo;
    this.detalles = detalles;
  }
}

const errorValidacion = (detalles, mensaje = 'Los datos enviados no son válidos') =>
  new AppError(400, 'VALIDACION', mensaje, detalles);

const noEncontrado = (mensaje) => new AppError(404, 'NO_ENCONTRADO', mensaje);

const prohibido = (mensaje) => new AppError(403, 'PROHIBIDO', mensaje);

const conflicto = (mensaje) => new AppError(409, 'CONFLICTO', mensaje);

const reglaNegocio = (detalles, mensaje = 'No se puede procesar el pedido') =>
  new AppError(422, 'REGLA_NEGOCIO', mensaje, detalles);

module.exports = { AppError, errorValidacion, noEncontrado, prohibido, conflicto, reglaNegocio };
