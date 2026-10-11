import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_bridge/qr_bridge.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel(QrBridge.channelName);
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test('convierte un resultado nativo en productId', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'scanProduct');
      return {'productId': 3};
    });
    expect(await QrBridge().scanProduct(), 3);
  });

  test('propaga la cancelación como error tipado', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      throw PlatformException(code: QrScanCodes.cancelled);
    });
    expect(
      () => QrBridge().scanProduct(),
      throwsA(isA<QrScanException>()
          .having((e) => e.code, 'code', QrScanCodes.cancelled)),
    );
  });

  test('respuesta sin id válido es invalidQr', () async {
    messenger.setMockMethodCallHandler(
        channel, (call) async => <String, Object?>{});
    expect(
      () => QrBridge().scanProduct(),
      throwsA(isA<QrScanException>()
          .having((e) => e.code, 'code', QrScanCodes.invalidQr)),
    );
  });
}
