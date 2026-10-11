package com.develsystems.qrscan

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import android.widget.FrameLayout
import androidx.activity.ComponentActivity
import androidx.activity.result.contract.ActivityResultContracts
import androidx.camera.core.CameraSelector
import androidx.camera.core.ImageAnalysis
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.view.PreviewView
import androidx.core.content.ContextCompat
import com.google.mlkit.vision.barcode.BarcodeScanning
import com.google.mlkit.vision.common.InputImage
import java.util.concurrent.Executor

/**
 * Vista de captura del SDK. Coordina permiso, cámara y ciclo de vida:
 * - Solicita `CAMERA` al abrir; si se niega → `permissionDenied` terminal.
 * - Fallo de apertura/bind → `cameraUnavailable` terminal.
 * - `onPause` (segundo plano) cancela la sesión de forma controlada y cierra;
 *   no se restaura ni se emiten callbacks tardíos. Rotación no recrea
 *   (`configChanges` en el manifiesto).
 * - Botón atrás → `cancelled`. Solo un resultado terminal por sesión.
 */
class QrScannerActivity : ComponentActivity() {

    private lateinit var mainExecutor: Executor
    private var previewView: PreviewView? = null
    private var cameraProvider: ProcessCameraProvider? = null
    private val barcodeScanner = BarcodeScanning.getClient()

    private val session = QrScanSession { outcome ->
        val data = Intent().apply {
            when (outcome) {
                is ScanOutcome.Success ->
                    putExtra(QrScanContract.EXTRA_PRODUCT_ID, outcome.productId)
                is ScanOutcome.Failure ->
                    putExtra(QrScanContract.EXTRA_ERROR_CODE, outcome.code)
            }
        }
        setResult(RESULT_OK, data)
        finish()
    }

    private val permissionLauncher = registerForActivityResult(
        ActivityResultContracts.RequestPermission(),
    ) { granted ->
        if (granted) startCamera()
        else {
            session.fail(QrScanErrors.PERMISSION_DENIED)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        mainExecutor = ContextCompat.getMainExecutor(this)
        val previewView = PreviewView(this).apply {
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT,
            )
        }
        this.previewView = previewView
        setContentView(previewView)
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA) ==
            PackageManager.PERMISSION_GRANTED
        ) {
            startCamera()
        } else {
            permissionLauncher.launch(Manifest.permission.CAMERA)
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        // Sesión ya activa: se ignora (el puente reporta scanInProgress).
    }

    override fun onPause() {
        super.onPause()
        // Segundo plano: cancelación controlada, sin fugas ni callbacks tardíos.
        if (!session.isFinished) {
            session.cancel()
        }
    }

    override fun onDestroy() {
        cameraProvider?.unbindAll()
        barcodeScanner.close()
        super.onDestroy()
    }

    @androidx.annotation.OptIn(androidx.camera.core.ExperimentalGetImage::class)
    private fun startCamera() {
        val providerFuture = ProcessCameraProvider.getInstance(this)
        providerFuture.addListener(
            {
                try {
                    val provider = providerFuture.get()
                    cameraProvider = provider
                    val preview = androidx.camera.core.Preview.Builder().build().apply {
                        setSurfaceProvider(previewView?.surfaceProvider)
                    }
                    val analysis = ImageAnalysis.Builder()
                        .setBackpressureStrategy(
                            ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST,
                        )
                        .build()
                        .apply {
                            setAnalyzer(mainExecutor) { imageProxy ->
                                val mediaImage = imageProxy.image
                                if (mediaImage == null || session.isFinished) {
                                    imageProxy.close()
                                    return@setAnalyzer
                                }
                                val input = InputImage.fromMediaImage(
                                    mediaImage,
                                    imageProxy.imageInfo.rotationDegrees,
                                )
                                barcodeScanner.process(input)
                                    .addOnSuccessListener { barcodes ->
                                        val raw = barcodes.firstOrNull()?.rawValue
                                        if (raw != null) session.onBarcode(raw)
                                    }
                                    .addOnCompleteListener { imageProxy.close() }
                            }
                        }
                    provider.unbindAll()
                    provider.bindToLifecycle(
                        this,
                        CameraSelector.DEFAULT_BACK_CAMERA,
                        preview,
                        analysis,
                    )
                } catch (_: Exception) {
                    session.fail(QrScanErrors.CAMERA_UNAVAILABLE)
                }
            },
            mainExecutor,
        )
    }
}
