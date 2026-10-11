package com.develsystems.qrscan

/** Códigos de error estables del contrato. Se propagan al puente sin cambios. */
object QrScanErrors {
    const val PERMISSION_DENIED = "permissionDenied"
    const val CAMERA_UNAVAILABLE = "cameraUnavailable"
    const val INVALID_QR = "invalidQr"
    const val CANCELLED = "cancelled"
    const val SCAN_IN_PROGRESS = "scanInProgress"
}
