# AI_USAGE

> Declaración exigida por el examen (`examen_mobile_flutter_sdk_qr.md` §10).


## 1. Herramientas / modelos

- OpenCode + Muse Spark 1.3 Free (variante high) — scaffolding, análisis y guía.
- Sin otros modelos por ahora.

## 2. Tareas y archivos afectados

| Fecha | Tarea | Archivos |
|---|---|---|
| 2026-10-08 | Núcleo app: Dio+timeouts, SQLite 3 tablas, entidades, repos, providers Riverpod, router y 3 pantallas mínimas | `lib/config/constants.dart`, `lib/config/router.dart`, `lib/core/http/dio_client.dart`, `lib/core/db/app_database.dart`, `lib/features/catalog/**`, `lib/features/orders/**`, `lib/main.dart` |
| 2026-10-08 | Registro inicial de flujo de trabajo (sin push/pull, commit propuesto por IA) | `AI_USAGE.md` |

## 3. Prompts representativos

1. "Analiza el md del proyecto y dame tus opiniones" — análisis de SDK + puente + app y viabilidad.
2. "Estandaricemos: no harás push/pull, me darás el commit y descripción; usemos dotenv, dio, go_router, riverpod" — definición de stack y norma de trabajo.

## 4. Cambios manuales del candidato (pendiente de completar)

- [ ] Revisar `pubspec.yaml` y correr `flutter pub get` localmente.
- [ ] Confirmar que entiende cada dependencia antes de defender en revisión de 20 min.

## 5. Verificación

- [x] `flutter pub get` — OK 2026-10-08.
- [x] `flutter analyze` — sin issues 2026-10-08.
- [ ] `flutter test` — pendiente (siguiente paso: tests repo + cola + puente con dobles).
- [ ] `git status` — solo cambios locales, sin push (por norma del candidato).

## 6. Sin comprobar aún

- Compilación del SDK (`native/qrscan-sdk` → `.aar`).
- Puente `plugin/qr_bridge` con `MethodChannel`.
- REST real contra `https://dummyjson.com/products?limit=30` y `POST /carts/add`.
- Flujo offline, cola `Enviar pendientes`, video 3-5 min, Release con AAR+APK.

## Norma de trabajo acordada

- La IA **no ejecuta** `git push` ni `git pull`.
- Al final de cada paso la IA propone: comando `git add/commit` + mensaje + descripción para que el candidato lo ejecute.
