// Arma la aplicación Express. Recibe los repositorios por parámetro para poder usar MongoDB o memoria.
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');

const { PedidoService } = require('./services/pedido.service');
const { ProductoService } = require('./services/producto.service');
const crearRutasPedidos = require('./routes/pedido.routes');
const crearRutasProductos = require('./routes/producto.routes');
const { noEncontrada, manejarErrores } = require('./middlewares/error-handler');

function crearApp({ pedidoRepo, productoRepo, logs = true, reloj }) {
  const app = express();
  app.disable('x-powered-by');
  app.use(helmet());
  app.use(cors());
  app.use(express.json({ limit: '100kb' }));
  if (logs) app.use(morgan('dev'));

  app.get('/api/health', (req, res) => {
    res.json({ estado: 'ok', servicio: 'sabor-pedidos-api', hora: new Date().toISOString() });
  });

  const pedidoService = new PedidoService({ pedidoRepo, productoRepo, reloj });
  const productoService = new ProductoService({ productoRepo });
  app.use('/api/pedidos', crearRutasPedidos(pedidoService));
  app.use('/api/productos', crearRutasProductos(productoService));

  app.use(noEncontrada);
  app.use(manejarErrores);
  return app;
}

module.exports = { crearApp };
