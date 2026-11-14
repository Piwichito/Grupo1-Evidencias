// Lee el rol del usuario desde el encabezado "X-Rol" (mozo | cocinero | administrador).
// Es una simplificación académica: en una versión real se usaría autenticación (por ejemplo JWT).
const { ROLES } = require('../utils/estados');
const { errorValidacion } = require('../utils/errors');

module.exports = (req, res, next) => {
  const rol = String(req.header('x-rol') || '').toLowerCase();
  if (!ROLES.includes(rol)) {
    return next(errorValidacion([`Encabezado X-Rol requerido. Valores válidos: ${ROLES.join(', ')}`]));
  }
  req.rol = rol;
  next();
};
