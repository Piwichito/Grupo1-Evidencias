// Manejo central de errores: todas las respuestas de error tienen el mismo formato JSON.
const { AppError } = require('../utils/errors');

const noEncontrada = (req, res, next) => {
  next(new AppError(404, 'RUTA_NO_ENCONTRADA', `No existe la ruta ${req.method} ${req.originalUrl}`));
};

// eslint-disable-next-line no-unused-vars
const manejarErrores = (err, req, res, next) => {
  // JSON mal formado en el cuerpo de la petición.
  if (err.type === 'entity.parse.failed') {
    return res.status(400).json({ error: { codigo: 'JSON_INVALIDO', mensaje: 'El cuerpo de la petición no es un JSON válido', detalles: [] } });
  }
  if (err.type === 'entity.too.large') {
    return res.status(413).json({ error: { codigo: 'CUERPO_MUY_GRANDE', mensaje: 'El cuerpo de la petición es demasiado grande', detalles: [] } });
  }
  if (err instanceof AppError) {
    return res.status(err.status).json({ error: { codigo: err.codigo, mensaje: err.message, detalles: err.detalles } });
  }
  // Error inesperado: se registra y se responde sin exponer detalles internos.
  console.error(err);
  res.status(500).json({ error: { codigo: 'ERROR_INTERNO', mensaje: 'Ocurrió un error inesperado en el servidor', detalles: [] } });
};

module.exports = { noEncontrada, manejarErrores };
