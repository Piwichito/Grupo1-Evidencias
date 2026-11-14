# SaborPedidos – API REST (Caso 03 · Grupo 1)

API construida con **Node.js + Express** y **MongoDB Atlas (Mongoose)** para la app móvil Flutter.
Proyecto académico CERTUS – Implementación de soluciones para plataformas móviles (AA2).

## Requisitos
- Node.js 18 o superior (`node -v`)
- Una cuenta gratuita en MongoDB Atlas (base de datos en la nube)

## 1. Crear la base de datos en la nube (MongoDB Atlas)
1. Entra a https://www.mongodb.com/cloud/atlas y crea una cuenta.
2. **Create** → plan gratuito **M0** → elige la región más cercana → crea el cluster.
3. **Database Access** → *Add New Database User*: usuario y contraseña (guárdalos, no uses caracteres como `@` o `:` en la contraseña).
4. **Network Access** → *Add IP Address* → *Allow access from anywhere* (`0.0.0.0/0`). Es lo más simple para el proyecto académico.
5. **Database** → *Connect* → *Drivers* → copia la cadena `mongodb+srv://...`.
6. Agrega el nombre de la base antes del `?`: `...mongodb.net/saborpedidos?retryWrites=true&w=majority`.

## 2. Configurar y ejecutar
```bash
cd api
npm install
copy .env.example .env      # en Mac/Linux: cp .env.example .env
# abre .env y pega tu MONGODB_URI
npm run dev                 # reinicia solo al guardar cambios (o: npm start)
```
Al iniciar por primera vez con la base vacía, la API carga la carta inicial (12 productos).
También puedes cargarla manualmente con `npm run seed`.

Comprueba que funciona: http://localhost:3000/api/health

> **Importante:** el archivo `.env` contiene tu contraseña. Está en `.gitignore`: **nunca lo subas a GitHub**. Compártelo con tu equipo por un canal privado.

### Modo demo (sin MongoDB)
`npm run demo` levanta la API con datos en memoria (se pierden al cerrar). Sirve para probar rápido, pero para la evidencia se usa Atlas.

## 3. Pruebas
```bash
npm test                    # pruebas unitarias y de endpoints (Jest + Supertest)
npm run test:coverage       # con informe de cobertura
```
Pruebas contra una base real (opcional, usa una base de prueba que se elimina al final):
```powershell
$env:MONGODB_TEST_URI="mongodb+srv://usuario:password@cluster.mongodb.net/saborpedidos_test"
npm test
```
Para probar a mano los endpoints usa `docs/pruebas-manuales.http` (extensión *REST Client* de VS Code) o Postman.

## 4. Endpoints
| Método | Ruta | Descripción | Rol (X-Rol) |
|---|---|---|---|
| GET | `/api/health` | Estado del servidor | — |
| GET | `/api/productos?categoria=` | Carta (entradas, fondos, bebidas, postres) | — |
| GET | `/api/productos/:id` | Un producto | — |
| POST | `/api/productos` | Crear producto | administrador |
| PATCH | `/api/productos/:id` | Cambiar precio / disponibilidad | administrador |
| GET | `/api/pedidos?estado=` | Lista de pedidos (más recientes primero) | — |
| GET | `/api/pedidos/:id` | Un pedido | — |
| POST | `/api/pedidos` | Registrar pedido | mozo, administrador |
| PATCH | `/api/pedidos/:id/estado` | Cambiar estado (flujo y permisos) | según el estado |

Estados: `recibido → en_preparacion → listo → entregado` y `anulado` (desde cualquier estado abierto).
El rol se envía en el encabezado `X-Rol` (`mozo`, `cocinero` o `administrador`). Es una simplificación académica; en una versión real se usaría autenticación (JWT).

Ejemplo de registro de pedido:
```http
POST /api/pedidos
X-Rol: mozo
Content-Type: application/json

{ "mesa": 5, "cliente": "Familia Rojas", "observaciones": "Sin ají",
  "items": [ { "productoId": "<id>", "cantidad": 2 } ] }
```
Errores: todos usan el formato `{ "error": { "codigo", "mensaje", "detalles": [] } }` con los códigos
400 (datos inválidos), 403 (rol sin permiso), 404 (no existe), 409 (transición no permitida o cambio simultáneo) y 422 (producto agotado o inexistente).

## 5. Estructura
```
api/
├── src/
│   ├── server.js            # arranque (elige MongoDB o memoria)
│   ├── app.js               # arma Express y las rutas
│   ├── config/              # variables de entorno y conexión a Atlas
│   ├── models/              # esquemas Mongoose (productos, pedidos, contadores)
│   ├── repositories/        # acceso a datos: versión MongoDB y versión en memoria
│   ├── services/            # reglas de negocio (total, flujo de estados, permisos)
│   ├── controllers/ routes/ # capa HTTP
│   ├── middlewares/         # rol, errores
│   ├── validators/          # validación de datos
│   ├── utils/               # constantes, permisos, errores
│   └── seed/                # carta inicial
├── tests/                   # Jest + Supertest
└── docs/pruebas-manuales.http
```

## 6. Desplegar en Render (opcional, para usar la API desde un celular real)
1. Sube el repositorio a GitHub.
2. En https://render.com → *New* → *Web Service* → conecta el repositorio.
3. **Root Directory:** `api` · **Build Command:** `npm install` · **Start Command:** `npm start`.
4. En *Environment* agrega `MONGODB_URI` (tu cadena de Atlas) y `DB_MODE=mongo`.
5. Al terminar tendrás una URL como `https://sabor-pedidos-api.onrender.com`. El plan gratuito se "duerme" tras unos minutos sin uso: la primera petición puede tardar ~1 minuto.
