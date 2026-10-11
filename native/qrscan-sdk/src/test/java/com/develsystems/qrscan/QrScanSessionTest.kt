package com.develsystems.qrscan

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

/** Una sola terminación por sesión + cancelación (examen §8). */
class QrScanSessionTest {

    @Test fun `detecciones repetidas entregan un solo exito`() {
        val outcomes = mutableListOf<ScanOutcome>()
        val session = QrScanSession(outcomes::add)
        session.onBarcode("product:1")
        session.onBarcode("product:1")
        session.onBarcode("product:2")
        assertEquals(listOf(ScanOutcome.Success(1)), outcomes)
        assertTrue(session.isFinished)
    }

    @Test fun `primer codigo invalido termina como invalidQr`() {
        val outcomes = mutableListOf<ScanOutcome>()
        val session = QrScanSession(outcomes::add)
        session.onBarcode(null) // frame sin código: se ignora
        assertFalse(session.isFinished)
        session.onBarcode("hola")
        session.onBarcode("product:1") // tardío: se ignora
        assertEquals(
            listOf(ScanOutcome.Failure(QrScanErrors.INVALID_QR)),
            outcomes,
        )
    }

    @Test fun `cancelar una vez y liberar`() {
        val outcomes = mutableListOf<ScanOutcome>()
        val session = QrScanSession(outcomes::add)
        session.cancel()
        session.cancel()
        session.onBarcode("product:1")
        assertEquals(
            listOf(ScanOutcome.Failure(QrScanErrors.CANCELLED)),
            outcomes,
        )
    }
}
