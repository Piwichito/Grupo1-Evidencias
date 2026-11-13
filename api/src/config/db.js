const dns = require('node:dns');
const mongoose = require('mongoose');

// Conecta con MongoDB Atlas. Si falla, el error se muestra claro y la API no arranca.
async function conectarMongo(uri) {
  if (!uri) {
    throw new Error('Falta MONGODB_URI. Copia .env.example como .env y pega tu cadena de conexión de Atlas.');
  }
  // En algunas redes o PCs con Windows, Node no logra resolver la dirección "mongodb+srv"
  // (error "querySrv ECONNREFUSED"). Con DNS_SERVERS=8.8.8.8,1.1.1.1 en el .env se usan
  // servidores DNS públicos solo para esta API.
  if (process.env.DNS_SERVERS) {
    dns.setServers(process.env.DNS_SERVERS.split(',').map((s) => s.trim()).filter(Boolean));
  }
  mongoose.set('strictQuery', true);
  await mongoose.connect(uri, { serverSelectionTimeoutMS: 10000 });
  console.log(`MongoDB conectado: base "${mongoose.connection.name}"`);
}

module.exports = { conectarMongo };
