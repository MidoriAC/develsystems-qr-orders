package com.example.develsystems_qr_orders

import android.content.Intent
import com.develsystems.qrscan.QrScanContract
import com.develsystems.qrscan.QrScanErrors
import com.develsystems.qrscan.QrScannerActivity
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Puente Flutter propio (MethodChannel `develsystems.qrscan`).
 * - `scanProduct()` lanza [QrScannerActivity] y devuelve `{productId}`.
 * - `cancelScan()` cierra la pantalla activa; el `scanProduct` pendiente termina entonces como error tipado `cancelled`.
 * - Segundo `scanProduct` con sesión activa → `scanInProgress`, sin colgar llamadas.
 * - Al destruirse la actividad, la llamada pendiente se cierra como `cancelled`.
 */
class MainActivity : FlutterActivity() {

    private val channelName = "develsystems.qrscan"
    private val requestScan = 1001
    private var pending: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "scanProduct" -> {
                    if (pending != null) {
                        result.error(
                            QrScanErrors.SCAN_IN_PROGRESS,
                            QrScanErrors.SCAN_IN_PROGRESS,
                            null,
                        )
                        return@setMethodCallHandler
                    }
                    pending = result
                    try {
                        @Suppress("DEPRECATION")
                        startActivityForResult(
                            QrScanContract.createIntent(this),
                            requestScan,
                        )
                    } catch (_: Exception) {
                        pending = null
                        result.error(
                            QrScanErrors.CAMERA_UNAVAILABLE,
                            QrScanErrors.CAMERA_UNAVAILABLE,
                            null,
                        )
                    }
                }
                "cancelScan" -> {
                    QrScannerActivity.cancelActive()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    @Deprecated("Puente mínimo: basta el resultado clásico")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != requestScan) return
        val result = pending ?: return
        pending = null
        val id = QrScanContract.parseProductId(data)
        if (id != null) {
            result.success(mapOf("productId" to id))
        } else {
            val code = QrScanContract.parseError(data) ?: QrScanErrors.CANCELLED
            result.error(code, code, null)
        }
    }

    override fun onDestroy() {
        pending?.error(QrScanErrors.CANCELLED, QrScanErrors.CANCELLED, null)
        pending = null
        super.onDestroy()
    }
}
