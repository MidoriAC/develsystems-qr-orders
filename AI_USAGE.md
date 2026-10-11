# AI_USAGE

> Declaración exigida por el examen (`examen_mobile_flutter_sdk_qr.md` §10).


## 1. Herramientas / modelos

- OpenCode + Muse Spark 1.3 Free (variante high) — scaffolding, análisis y guía.
- Sin otros modelos por ahora.

## 2. Tareas y archivos afectados

| Fecha | Tarea | Archivos |
|---|---|---|
| 2026-10-08 | Núcleo app: Dio+timeouts, SQLite 3 tablas, entidades, repos, providers Riverpod, router y 3 pantallas mínimas | `lib/config/constants.dart`, `lib/config/router.dart`, `lib/core/http/dio_client.dart`, `lib/core/db/app_database.dart`, `lib/features/catalog/**`, `lib/features/orders/**`, `lib/main.dart` |
| 2026-10-10/11 | Refactor candidato: `Environment` (antes `Enviroment`), split providers en state/notifier/providers | `lib/config/environment.dart`, `lib/main.dart`, `lib/features/*/presentation/providers/*` |
| 2026-10-11 | Fix IA punto 1: `baseUrl` como getter perezoso con fallback, `initEnvironment` tolerante sin `.env`, `MainApp` a `StatelessWidget` | `lib/config/environment.dart`, `lib/main.dart`, `catalog_providers.dart` |
| 2026-10-11 | Fix borrador: merge por `productId` en `insertOrder`, borrador compartido catalog→pedido, cantidades editables, sin IDs quemados | `orders_local_ds.dart`, `draft_providers.dart`, `order_screen.dart`, `catalog_screen.dart` |
| 2026-10-11 | Evaluación de punto estable (solo lectura) + JDK 17 para AGP 8.1 | `android/gradle.properties` |
| 2026-10-11 | SDK Kotlin `qrscan-sdk`: validador, sesión terminal única, contrato, Activity CameraX+MLKit, tests JVM 7/7, AAR, README nativo | `native/qrscan-sdk/**`, `android/settings.gradle` |
| 2026-10-11 | Puente `qr_bridge` (MethodChannel) + integración en pedido + tests Dart 3/3 + APK debug | `android/app/.../MainActivity.kt`, `android/app/build.gradle`, `plugin/qr_bridge/**`, `lib/features/scan/**`, `order_screen.dart`, `test/qr_bridge_test.dart` |
| 2026-10-11 | Entidad Product enriquecida (DummyJSON), migración DB v1→v2, búsqueda offline, detalle, rutas /search y /product/:id, nav inferior funcional | IA + candidato: `product.dart`, `app_database.dart`, `catalog_state.dart`, `catalog_notifier.dart`, `search_screen.dart`, `product_detail_screen.dart`, `router.dart`, `bottom_navigation_menu.dart`, `catalog_screen.dart` |
| 2026-10-11 | UI candidato: catálogo en grid con `ProductoContainer`, filtros por categoría en búsqueda, QR de prueba, logo | Candidato: `catalog_screen.dart`, `producto_container.dart`, `search_screen.dart`, `assets/logos/Dsystems.png`, `product_1/2/3.png` |
| 2026-10-11 | Limpieza deprecados (`withOpacity`→`withValues`) | IA: `search_screen.dart`, `producto_container.dart` |
| 2026-10-11 | `settings.gradle` propio del SDK (apertura standalone en AS) | IA: `native/qrscan-sdk/settings.gradle` |
| 2026-10-08 | Registro inicial de flujo de trabajo (sin push/pull, commit propuesto por IA) | `AI_USAGE.md` |

## 3. Prompts representativos

1. "Analiza el md del proyecto y dame tus opiniones" — análisis de SDK + puente + app y viabilidad.
2. "Estandaricemos: no harás push/pull, me darás el commit y descripción; usemos dotenv, dio, go_router, riverpod" — definición de stack y norma de trabajo.

## 4. Cambios manuales del candidato

- Revisó `pubspec.yaml` y corrió `flutter pub get` localmente.
- Refactor propio: creó `lib/config/enviroment.dart` (luego renombrado a `environment.dart`) y dividió providers en `state/notifier/providers` por feature.
- Entiende el stack (dio, riverpod sin codegen, go_router, dotenv);

## 5. Verificación

- [x] `flutter pub get` — OK 2026-10-08.
- [x] `flutter analyze` — sin issues 2026-10-08 y 2026-10-11.
- [x] JDK 17 (`C:\Program Files\Java\jdk-17.0.12`) fijado en `android/gradle.properties` — AGP 8.1 lo exige (el `java` del PATH es 11).
- [x] `:qrscan-sdk:testDebugUnitTest` — 7/7 OK 2026-10-11.
- [x] `:qrscan-sdk:assembleRelease` — `build/qrscan-sdk/outputs/aar/qrscan-sdk-release.aar` OK 2026-10-11.
- [x] `flutter test` (puente) — 3/3 OK 2026-10-11.
- [x] `flutter build apk --debug` — `build/app/outputs/flutter-apk/app-debug.apk` OK 2026-10-11.
- [ ] REST real contra `https://dummyjson.com` — pendiente de verificación manual.
- [ ] `git status` — commits locales por subir, sin push (por norma del candidato).

## 6. Sin comprobar aún

- Puente `plugin/qr_bridge` con `MethodChannel`.
- REST real contra `https://dummyjson.com/products?limit=30` y `POST /carts/add`.
- Flujo offline, cola `Enviar pendientes`, video 3-5 min, Release con AAR+APK.

## Norma de trabajo acordada

- La IA **no ejecuta** `git push` ni `git pull`.
- Al final de cada paso la IA propone: comando `git add/commit` + mensaje + descripción para que el candidato lo ejecute.
