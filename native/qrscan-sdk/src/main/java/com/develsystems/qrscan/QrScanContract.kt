package com.develsystems.qrscan

import android.content.Context
import android.content.Intent

/**
 * API pública del SDK para apps nativas (sin Flutter).
 * El segundo intento de apertura con sesión activa se ignora en destino
 * (`singleTop` + [QrScannerActivity.onNewIntent]); el puente Flutter
 * devuelve [QrScanErrors.SCAN_IN_PROGRESS] en ese caso.
 */
object QrScanContract {
    const val EXTRA_PRODUCT_ID = "com.develsystems.qrscan.EXTRA_PRODUCT_ID"
    const val EXTRA_ERROR_CODE = "com.develsystems.qrscan.EXTRA_ERROR_CODE"

    fun createIntent(context: Context): Intent =
        Intent(context, QrScannerActivity::class.java)

    fun parseProductId(data: Intent?): Int? =
        data?.takeIf { it.hasExtra(EXTRA_PRODUCT_ID) }
            ?.getIntExtra(EXTRA_PRODUCT_ID, -1)
            ?.takeIf { it > 0 }

    fun parseError(data: Intent?): String? =
        data?.getStringExtra(EXTRA_ERROR_CODE)
}
