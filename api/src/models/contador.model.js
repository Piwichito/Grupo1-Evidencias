const mongoose = require('mongoose');

// Colección auxiliar para numerar los pedidos (1, 2, 3...). Un documento por secuencia.
const contadorSchema = new mongoose.Schema(
  { _id: { type: String }, seq: { type: Number, default: 0 } },
  { collection: 'contadores' }
);

module.exports = mongoose.model('Contador', contadorSchema);
