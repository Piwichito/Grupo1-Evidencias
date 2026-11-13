const crypto = require('crypto');

// Redondea a 2 decimales (montos en soles).
const redondear = (n) => Math.round((n + Number.EPSILON) * 100) / 100;

// Un id válido tiene el formato de ObjectId de MongoDB (24 caracteres hexadecimales).
const esIdValido = (id) => typeof id === 'string' && /^[a-f0-9]{24}$/i.test(id);

// Genera un id con el mismo formato (lo usa el repositorio en memoria).
const generarId = () => crypto.randomBytes(12).toString('hex');

module.exports = { redondear, esIdValido, generarId };
