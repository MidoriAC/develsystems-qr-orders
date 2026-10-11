# qr_bridge — puente Flutter propio (sin plugins de terceros)

## Contrato

Canal: `develsystems.qrscan` (`MethodChannel`, elegido frente a Pigeon por
contrato mínimo sin codegen).

| Método | Resultado | Errores (`PlatformException.code`) |
|---|---|---|
| `scanProduct()` | `{productId: int}` | `permissionDenied`, `cameraUnavailable`, `invalidQr`, `cancelled`, `scanInProgress` |
| `cancelScan()` | `null` | — (el `scanProduct` pendiente completa como `cancelled`) |

La cancelación se representa como **error tipado** en todo el recorrido.
Ninguna llamada queda pendiente: el `MainActivity` la cierra como `cancelled`
al destruirse, y el segundo `scanProduct` concurrente responde `scanInProgress`.

El puente no valida formato (lo hace el SDK) ni resuelve existencia
(lo hace la app contra SQLite/REST).
