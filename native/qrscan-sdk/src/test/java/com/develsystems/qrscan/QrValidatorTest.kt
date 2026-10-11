package com.develsystems.qrscan

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

/** Tabla del examen §4 + bordes de representación segura. */
class QrValidatorTest {

    @Test fun `product 1 2 3 son validos`() {
        assertEquals(1, QrValidator.validate("product:1"))
        assertEquals(2, QrValidator.validate("product:2"))
        assertEquals(3, QrValidator.validate("product:3"))
    }

    @Test fun `ceros signo y prefijo invalido`() {
        assertNull(QrValidator.validate("product:0"))
        assertNull(QrValidator.validate("product:-1"))
        assertNull(QrValidator.validate("product:01"))
        assertNull(QrValidator.validate("PRODUCT:1"))
        assertNull(QrValidator.validate("product:abc"))
        assertNull(QrValidator.validate("hola"))
    }

    @Test fun `formato valido aunque inexistente`() {
        assertEquals(999999, QrValidator.validate("product:999999"))
    }

    @Test fun `fuera de rango y vacios`() {
        assertNull(QrValidator.validate("product:99999999999"))
        assertNull(QrValidator.validate("product:2147483648"))
        assertEquals(Int.MAX_VALUE, QrValidator.validate("product:2147483647"))
        assertNull(QrValidator.validate(null))
        assertNull(QrValidator.validate(""))
        assertNull(QrValidator.validate(" product:1"))
        assertNull(QrValidator.validate("product:1 "))
    }
}
