package com.develsystems.qrscan

import java.util.concurrent.atomic.AtomicBoolean

/** Resultado terminal de una sesión: como máximo uno. */
sealed interface ScanOutcome {
    data class Success(val productId: Int) : ScanOutcome
    data class Failure(val code: String) : ScanOutcome
}

/**
 * Sesión pura (sin dependencias Android: comprobable en JVM).
 * - El primer código decodificado decide: válido → [Success], inválido → [Failure] `invalidQr`.
 * - Detecciones repetidas, frames sin código (`null`) y llamadas tardías se ignoran.
 * - [cancel]/[fail] terminan la sesión si aún no terminó.
 */
class QrScanSession(
    private val onOutcome: (ScanOutcome) -> Unit,
) {
    private val finished = AtomicBoolean(false)
    val isFinished: Boolean get() = finished.get()

    fun onBarcode(raw: String?) {
        if (raw == null) return
        val id = QrValidator.validate(raw)
        if (id != null) finish(ScanOutcome.Success(id))
        else finish(ScanOutcome.Failure(QrScanErrors.INVALID_QR))
    }

    fun cancel() = finish(ScanOutcome.Failure(QrScanErrors.CANCELLED))

    fun fail(code: String) = finish(ScanOutcome.Failure(code))

    private fun finish(outcome: ScanOutcome) {
        if (finished.compareAndSet(false, true)) onOutcome(outcome)
    }
}
