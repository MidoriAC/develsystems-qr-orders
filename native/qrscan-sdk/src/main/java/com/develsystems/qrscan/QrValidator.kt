package com.develsystems.qrscan

/**
 * Valida el formato del ejercicio: `product:{id}`.
 * - Prefijo exacto `product:` en minúsculas, sin espacios.
 * - ID entero positivo sin ceros iniciales (`01` es inválido).
 * - Rechaza valores fuera del rango representable de [Int].
 */
object QrValidator {
    private val PATTERN = Regex("^product:([1-9][0-9]*)$")

    /** ID validado o `null` si el contenido es inválido. */
    fun validate(raw: String?): Int? {
        if (raw.isNullOrEmpty()) return null
        val digits = PATTERN.matchEntire(raw)?.groupValues?.get(1) ?: return null
        if (digits.length > 10) return null
        return digits.toLongOrNull()
            ?.takeIf { it in 1..Int.MAX_VALUE }
            ?.toInt()
    }
}
