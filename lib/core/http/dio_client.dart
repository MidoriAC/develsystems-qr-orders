import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final bool isTimeout;
  final bool isConnection;

  const ApiException(
    this.message, {
    this.statusCode,
    this.isTimeout = false,
    this.isConnection = false,
  });

  @override
  String toString() => 'ApiException($statusCode): $message';
}

Dio buildDio({required String baseUrl, required int timeoutMs}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: Duration(milliseconds: timeoutMs),
      sendTimeout: Duration(milliseconds: timeoutMs),
      receiveTimeout: Duration(milliseconds: timeoutMs),
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
      validateStatus: (s) => s != null && s >= 200 && s < 300,
    ),
  );
  return dio;
}

ApiException mapDioError(DioException e) {
  if (e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.sendTimeout ||
      e.type == DioExceptionType.receiveTimeout) {
    return ApiException('Timeout después de enviar: resultado desconocido',
        isTimeout: true);
  }
  if (e.type == DioExceptionType.connectionError ||
      e.type == DioExceptionType.unknown) {
    return const ApiException('Sin conexión o red no disponible',
        isConnection: true);
  }
  final code = e.response?.statusCode;
  if (code != null && code >= 400) {
    return ApiException('HTTP $code: ${e.response?.statusMessage ?? 'error'}',
        statusCode: code);
  }
  return ApiException('Respuesta inválida: ${e.message}');
}
