# SaborPedidos – Pedidos de menú para un restaurante local (Caso 03 · Grupo 1)

Proyecto académico CERTUS – Implementación de soluciones para plataformas móviles.
Evidencia 2 (AA2): la app consume una API REST propia (carpeta `api/` del repositorio) conectada a MongoDB Atlas.

## Frameworks utilizados
- **Provider** (estado) y **http** (cliente REST) en la app Flutter.
- **Express** y **Mongoose** en la API (Node.js), con **MongoDB Atlas** como base de datos en la nube.
- Pruebas: **flutter_test** (+ `MockClient`) en la app y **Jest + Supertest** en la API.

## Cómo ejecutar
1. Enciende la API (ver `api/README.md`): `cd api`, `npm install`, `npm start`.
2. En la app:
   ```
   flutter pub get
   flutter analyze
   flutter test
   flutter run --dart-define=API_URL=http://10.0.2.2:3000
   ```
   - `10.0.2.2` es la PC vista desde el emulador de Android.
   - En un celular real usa la IP de tu PC en la misma red Wi-Fi, por ejemplo `http://192.168.1.20:3000`.
3. Android necesita el permiso `INTERNET` y `android:usesCleartextTraffic="true"` en
   `android/app/src/main/AndroidManifest.xml` para hablar con la API local por HTTP.

Requiere una versión estable reciente de Flutter (3.27 o superior).

## Estructura de `lib/`
- `core` – tema, formato y configuración de la API (`api_config.dart`)
- `models` – Producto, Pedido, ItemPedido, NuevoPedido y enums (Categoria, EstadoPedido, Rol), con `fromJson`
- `data/api` – `ApiClient` (http) y `ApiException`
- `data/repositories` – acceso a datos (interfaces e implementaciones con la API)
- `providers` – `MenuProvider` y `PedidosProvider` (Provider)
- `screens` – 7 pantallas
- `widgets` – widgets reutilizables (`VistaCarga`, `ProductoCard`, `EstadoChip`, ...)

## Pruebas (carpeta `test/`)
`models_test`, `api_client_test`, `repositories_test`, `providers_test` y `widget_test` (usan repositorios falsos de `fakes.dart`).
