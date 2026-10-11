# qrscan-sdk — SDK nativo de lectura QR (DevelSystems)

Módulo Android Library **independiente de Flutter**: cámara, permiso, ciclo de vida,
lectura y validación del QR, un solo resultado terminal por sesión.

## Compilar por separado

Desde `android/` (el módulo está incluido como `:qrscan-sdk` con `projectDir`
apuntando aquí, pero sus fuentes no dependen del proyecto app):

```bash
cd android
./gradlew :qrscan-sdk:testDebugUnitTest      # tests JVM (validador + sesión)
./gradlew :qrscan-sdk:assembleRelease        # genera qrscan-sdk-release.aar en
                                             # ../build/qrscan-sdk/outputs/aar/
```

Requiere JDK 17 (ver `android/gradle.properties` → `org.gradle.java.home`).

## Uso desde una app Android nativa

```kotlin
// 1. Dependencia al AAR (o `implementation(project(":qrscan-sdk"))` en monorepo)
implementation(files("libs/qrscan-sdk-release.aar"))

// 2. Lanzar con la API de resultados
val launcher = registerForActivityResult(ActivityResultContracts.StartActivityForResult()) { res ->
    val data = res.data
    val id = QrScanContract.parseProductId(data)   // Int? — solo formato válido
    val error = QrScanContract.parseError(data)    // permissionDenied | cameraUnavailable
                                                   // | invalidQr | cancelled | null si éxito
    // ...
}
launcher.launch(QrScanContract.createIntent(this))
```

El SDK **no** resuelve si el producto existe: eso lo decide la app (base local o REST).

## Decisiones

- **Decodificador:** ML Kit `barcode-scanning:17.2.0` (modelo incluido en la app,
  funciona sin conexión, licencia Apache 2.0). Cámara con CameraX `1.3.4`
  (`core/camera2/lifecycle/view`), Apache 2.0.
- **Primer código manda:** el primer QR decodificado termina la sesión
  (válido → ID, inválido → `invalidQr`). Detecciones repetidas y frames vacíos se ignoran.
- **Segundo plano:** `onPause` cancela (`cancelled`) y libera cámara/analizador;
  no se restaura la sesión ni hay callbacks tardíos. Rotación no recrea la pantalla.
- **Rango:** IDs `1..2147483647`; fuera de rango → `invalidQr`.

## Licencias de dependencias

| Dependencia | Versión | Licencia |
|---|---|---|
| androidx.camera (core/camera2/lifecycle/view) | 1.3.4 | Apache 2.0 |
| com.google.mlkit:barcode-scanning | 17.2.0 | Apache 2.0 |
| androidx.activity / lifecycle-runtime / core-ktx | 1.8.2 / 2.7.0 / 1.12.0 | Apache 2.0 |
| junit | 4.13.2 (solo tests) | EPL 1.0 |
