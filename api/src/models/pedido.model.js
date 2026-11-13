const mongoose = require('mongoose');
const { LISTA_ESTADOS, ESTADOS, MAX_MESAS } = require('../utils/estados');

// Cada línea del pedido guarda una "foto" del nombre y precio al momento de la venta.
const itemSchema = new mongoose.Schema(
  {
    productoId: { type: mongoose.Schema.Types.ObjectId, ref: 'Producto', required: true },
    nombre: { type: String, required: true },
    precioUnitario: { type: Number, required: true, min: 0 },
    cantidad: { type: Number, required: true, min: 1 },
    subtotal: { type: Number, required: true, min: 0 },
  },
  { _id: false }
);

const pedidoSchema = new mongoose.Schema(
  {
    numero: { type: Number, required: true, unique: true },
    mesa: { type: Number, required: true, min: 1, max: MAX_MESAS },
    cliente: { type: String, default: '', trim: true },
    observaciones: { type: String, default: '', trim: true },
    estado: { type: String, enum: LISTA_ESTADOS, default: ESTADOS.RECIBIDO, index: true },
    items: { type: [itemSchema], validate: (v) => v.length > 0 },
    total: { type: Number, required: true, min: 0 },
  },
  { timestamps: { createdAt: 'creadoEn', updatedAt: 'actualizadoEn' }, collection: 'pedidos' }
);

module.exports = mongoose.model('Pedido', pedidoSchema);
