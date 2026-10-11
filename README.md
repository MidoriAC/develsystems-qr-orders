# develsystems-qr-orders — Devel Systems · Mobile Flutter + SDK QR

App Flutter para registrar pedidos de demostración leyendo QR, con catálogo REST
(DummyJSON), base SQLite offline y cola de envío manual. SDK nativo Android en
Kotlin empaquetado como AAR e integrado por un puente Flutter propio
(`MethodChannel`). Plataforma: **Android** (iOS no incluido).

## Flujo entregado (§2 del examen)

1. Con conexión: `GET /products?limit=30` → SQLite. La UI siempre lee SQLite.
2. Lector desde Flutter: el SDK pide permiso de cámara, muestra captura y devuelve
   el `productId` del QR (`product:{id}`).
3. Productos al pedido (catálogo, búsqueda o QR), cantidades editables, total local
   **estimado** (`Σ precio × cantidad`, sin impuestos; no se iguala a DummyJSON).
4. Sin conexión: catálogo desde SQLite + pedido `Pendiente`.
5. Cierre total → catálogo y pedidos guardados siguen (el borrador no guardado, no;
   ver §6 del examen).
6. **Enviar pendientes** → `POST /carts/add` por pedido.
7. `Confirmado simulado` no se reenvía.

Vistas: `/` catálogo, `/search` búsqueda, `/product/:id` detalle,
`/order` pedido actual, `/history` historial. Navegación inferior con lector
central (`ShellRoute` + `MainLayout`).

## Arquitectura

Clean por feature (versión recortada al alcance del examen):

```
lib/config/            constants, environment (.env), router (go_router)
lib/core/http/         Dio con timeouts 10s + ApiException tipada
lib/core/db/           SQLite (AppDatabase, migración v1→v2)
lib/features/catalog/  domain/entities+repositories · data/datasources+repositories
                       · presentation/providers(state/notifier/providers)+screens
lib/features/orders/   igual + draft compartido (borrador) y cola de envío
lib/features/scan/     provider del puente (QrBridge inyectable)
lib/features/shared/   MainLayout + bottom nav + widgets comunes
plugin/qr_bridge/      paquete Dart local del puente (sin plugins de terceros)
native/qrscan-sdk/     SDK Kotlin independiente → .aar
test/                  pruebas Dart + fixtures
assets/qr/             QR de prueba (product:1,2,3)
```

Decisiones:

- **Estado:** `flutter_riverpod` sin codegen (`NotifierProvider` + `State`).
  Un `ChangeNotifier`-equivalente por feature; borrador compartido
  `Map<productId, OrderItem>` (re-escaneo suma cantidad).
- **Rutas:** `go_router` con `ShellRoute` (layout persistente).
- **HTTP:** `dio` (timeouts connect/send/receive 10s, `Content-Type: application/json`).
  `DioException` → `ApiException`: timeout = resultado desconocido, sin red =
  conexión, 4xx/5xx = error.
- **Env:** `flutter_dotenv` solo para `API_BASE_URL` y `USE_FAKE` (sin secretos;
  DummyJSON es público, `userId: 1` fijo).
- **DB:** `sqflite`. Entidad == modelo (`fromDummyJson`/`fromMap` son los mappers;
  sin archivos separados por alcance).

## SDK nativo `native/qrscan-sdk` (25 pts)

Módulo Android Library sin dependencia Flutter. Ver `native/qrscan-sdk/README.md`.

- `QrValidator`: `^product:([1-9][0-9]*)$`, IDs `1..2147483647`.
- `QrScanSession`: un solo resultado terminal por sesión; el **primer** código
  decide (válido → ID, inválido → `invalidQr`); repeticiones y tardíos se ignoran.
- `QrScannerActivity`: CameraX 1.3.4 + ML Kit `barcode-scanning:17.2.0`
  (modelo incluido → funciona offline). Permiso → `permissionDenied`;
  fallo de cámara → `cameraUnavailable`; atrás → `cancelled`;
  `onPause` cancela y libera (no restaura, sin callbacks tardíos); rotación no recrea.
- `QrScanContract`: API para apps nativas (`createIntent/parseProductId/parseError`).
- Errores: `permissionDenied, cameraUnavailable, invalidQr, cancelled, scanInProgress`.
- Dependencias y licencias: CameraX 1.3.4, ML Kit 17.2.0, activity/lifecycle/core-ktx
  (Apache 2.0); junit 4.13.2 solo tests (EPL 1.0).

```bash
cd android
./gradlew :qrscan-sdk:testDebugUnitTest   # 7/7 (validador + sesión única)
./gradlew :qrscan-sdk:assembleRelease     # build/qrscan-sdk/outputs/aar/qrscan-sdk-release.aar
```

## Puente `plugin/qr_bridge` + `MainActivity` (20 pts)

`MethodChannel "develsystems.qrscan"` (elegido frente a Pigeon: contrato de 2
métodos, sin codegen). Ver `plugin/qr_bridge/README.md`.

| Método | Resultado | Errores |
|---|---|---|
| `scanProduct()` | `{productId}` | `permissionDenied, cameraUnavailable, invalidQr, cancelled, scanInProgress` |
| `cancelScan()` | `null` | — (el pendiente completa como `cancelled`) |

Cancelación = error tipado en todo el recorrido; ninguna llamada queda pendiente
(`onDestroy` la cierra como `cancelled`). El puente no valida formato (SDK) ni
resuelve existencia (app contra SQLite/REST). `android/app` depende de
`:qrscan-sdk`: integración real, no reenvío a plugin de hardware.

## Persistencia y cola

Tablas: `products` (id, title, price, thumbnail, updatedAt + description,
category, brand, sku, stock, rating, discount, availability, tags/images en JSON),
`orders` (id local UUID, status, createdAt/updatedAt, attempts, lastError,
remoteRef), `order_items` (orderId, productId, qty>0, nameSnapshot,
priceSnapshot; PK compuesta; inserción fusionada por producto en transacción).

Estados: `pending → sending → confirmed | error | unknown`.
`unknown` (timeout tras enviar) no se reenvía en lote: requiere reintento manual
explícito. `sending` se recupera a `unknown` al arrancar (nunca bloqueado).
Doble toque en **Enviar pendientes** no duplica lotes ni POST.
Para una API real harían falta clave de idempotencia del servidor + consulta de
estado; aquí `Confirmado simulado` es referencia local de demo.

## Instalación y ejecución

Requiere Flutter 3.27.1 y JDK 17 (`android/gradle.properties` fija
`org.gradle.java.home`; AGP 8.1 no compila con Java 11).

```bash
flutter pub get
flutter analyze
flutter test
flutter run                       # dispositivo Android físico recomendado
flutter build apk --debug         # build/app/outputs/flutter-apk/app-debug.apk
```

## QR de prueba (§4)

`assets/qr/product_1/2/3.png` (`product:1`, `product:2`, `product:3`).
Regenerables con: `pip install qrcode pillow` y
`python -c "import qrcode; [qrcode.make(f'product:{i}').save(f'product_{i}.png') for i in (1,2,3)]"`.
`product:999999` = formato válido inexistente (probar con doble de red).
`meta.qrCode` de DummyJSON **no** es el QR del ejercicio y no se usa.

## Offline reproducible

1. Con red: abrir catálogo (pobla SQLite) → crear pedido → guardar.
2. Modo avión: catálogo visible, búsqueda y detalle funcionan, nuevo pedido guarda.
3. Cerrar la app desde recientes → reabrir: todo sigue.
4. Reconectar → Historial → Enviar pendientes → doble toque → un lote →
   `Confirmado simulado` sin reenvío.

## Pruebas

```bash
flutter test                                   # 13/13 (puente 3, pedidos 7, catálogo 3)
cd android && ./gradlew :qrscan-sdk:testDebugUnitTest   # 7/7
```

Fixtures en `test/fixtures/` para modo sin red. Las pruebas no dependen de
DummyJSON (dobles con `mocktail`, SQLite con `sqflite_common_ffi`).

## Entrega

- Commit entregado: *(hash completo del tag `v1.0.0` — completar tras etiquetar)*
- Release: https://github.com/MidoriAC/develsystems-qr-orders/releases/tag/v1.0.0
- AAR: `qrscan-sdk-release.aar` (adjunto a la Release)
- APK: `app-debug.apk` (adjunto a la Release)
- Video (3-5 min): https://drive.google.com/file/d/1mtf_uS5LwH1oDuZnrI-dEWpCrLQXlUZa/view?usp=sharing

## Herramientas, dispositivo, tiempo y límites

- Flutter 3.27.1 · Dart 3.6.0 · AGP 8.1.0 · Kotlin 1.8.22 · Gradle 8.3 · JDK 17.
- Paquetes: flutter_riverpod 2.6.1, go_router 14.8.1, dio 5.7.0,
  flutter_dotenv 5.2.1, sqflite 2.4.1, uuid, intl, connectivity_plus,
  mocktail + sqflite_common_ffi (tests).
- Dispositivo probado: Android físico *(completar modelo + versión)*.
- Tiempo aproximado: *(completar)* horas efectivas.
- Límites: sin iOS; borrador no persiste (permitido §6); detalle fino
  (reviews, dimensiones, garantía) solo en red; video pendiente de grabar.
- Implementado y probado: SDK + AAR, puente, catálogo offline, pedidos, cola,
  búsqueda, detalle, tests 20/20. Pendiente: video + Release.

## IA

Ver `AI_USAGE.md` (uso declarado; no reduce nota).
