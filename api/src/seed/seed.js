// Uso: npm run seed  -> carga la carta inicial en MongoDB Atlas (no duplica productos).
const mongoose = require('mongoose');
const { mongoUri } = require('../config/env');
const { conectarMongo } = require('../config/db');
const { ProductoRepositoryMongo } = require('../repositories/producto.repository.mongo');
const { cargarMenu } = require('./cargar-menu');

(async () => {
  try {
    await conectarMongo(mongoUri);
    const creados = await cargarMenu(new ProductoRepositoryMongo());
    console.log(`Listo: ${creados} productos nuevos cargados.`);
  } catch (err) {
    console.error('Error al cargar la carta:', err.message);
    process.exitCode = 1;
  } finally {
    await mongoose.disconnect();
  }
})();
