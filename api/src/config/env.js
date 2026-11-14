require('dotenv').config();

module.exports = {
  puerto: Number(process.env.PORT) || 3000,
  modoDb: (process.env.DB_MODE || 'mongo').toLowerCase(),
  mongoUri: process.env.MONGODB_URI || '',
};
