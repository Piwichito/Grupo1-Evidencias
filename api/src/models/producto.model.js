const mongoose = require('mongoose');
const { CATEGORIAS } = require('../utils/estados');

const productoSchema = new mongoose.Schema(
  {
    nombre: { type: String, required: true, trim: true, unique: true, maxlength: 80 },
    descripcion: { type: String, default: '', trim: true, maxlength: 200 },
    precio: { type: Number, required: true, min: 0 },
    categoria: { type: String, required: true, enum: CATEGORIAS, index: true },
    disponible: { type: Boolean, default: true },
  },
  { timestamps: true, collection: 'productos' }
);

module.exports = mongoose.model('Producto', productoSchema);
