import 'package:flutter/services.dart';

/// Códigos estables del contrato (mismos que `QrScanErrors` en Kotlin).
abstract final class QrScanCodes {
  static const permissionDenied = 'permissionDenied';
  static const cameraUnavailable = 'cameraUnavailable';
  static const invalidQr = 'invalidQr';
  static const cancelled = 'cancelled';
  static const scanInProgress = 'scanInProgress';
}

/// Error tipado del puente. La cancelación también llega como error
/// con `code == cancelled` (criterio único en todo el recorrido).
class QrScanException implements Exception {
  final String code;
  final String message;
  const QrScanException(this.code, this.message);
  @override
  String toString() => 'QrScanException($code): $message';
}

/// Puente propio: habla con el SDK por `MethodChannel`, sin plugins de terceros.
/// Elegido `MethodChannel` frente a Pigeon: sin codegen, contrato mínimo

class QrBridge {
  static const channelName = 'develsystems.qrscan';

  final MethodChannel channel;
  QrBridge({MethodChannel? channel})
      : channel = channel ?? const MethodChannel(channelName);

  /// Abre el lector nativo y devuelve el `productId` validado por el SDK.
  /// Lanza [QrScanException] con un código de [QrScanCodes].
  Future<int> scanProduct() async {
    try {
      final res = await channel.invokeMapMethod<String, Object?>('scanProduct');
      final id = (res?['productId'] as num?)?.toInt();
      if (id == null || id <= 0) {
        throw const QrScanException(
            QrScanCodes.invalidQr, 'Respuesta nativa sin productId válido');
      }
      return id;
    } on PlatformException catch (e) {
      throw QrScanException(e.code, e.message ?? e.code);
    }
  }

  /// Cierra la lectura activa. El `scanProduct` pendiente completa como `cancelled`.
  Future<void> cancelScan() => channel.invokeMethod<void>('cancelScan');
}
