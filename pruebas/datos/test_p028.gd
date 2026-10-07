extends GdUnitTestSuite

# Arquitectura.md B.3 (T15), test 12: P-028 (A.2.2, "cada numero en un solo
# archivo"). Sale dudosa_hasta de tablas/lealtad.json y de su esquema: Dudosa es
# desleal_hasta + 1 hasta neutral_desde - 1. Usa datos/ real (A.6: que todo carga).
const _CARPETA_DATOS: String = "res://datos"
const _FIXTURE_LEALTAD: String = "res://pruebas/fixtures/unidades/lealtad.json"


func test_p028_sin_dudosa_hasta() -> void:
	var carga: Dictionary = Cargador.new().cargar_carpeta(_CARPETA_DATOS)
	var errores: Array[Dictionary] = carga["errores"]
	assert_array(errores).override_failure_message(str(errores)).is_empty()
	var datos: Dictionary = carga["datos"]
	var lealtad: Dictionary = datos["tablas/lealtad.json"]
	assert_bool(lealtad.has("dudosa_hasta")).is_false()

	# Una copia del fixture con el campo de vuelta no valida (additionalProperties).
	var lectura: Dictionary = LectorFixture.leer(_FIXTURE_LEALTAD, "lealtad")
	assert_array(lectura["errores"]).is_empty()
	var con_dudosa: Dictionary = (lectura["datos"] as Dictionary).duplicate(true)
	con_dudosa["dudosa_hasta"] = 3
	var esquema: Dictionary = Cargador.new().esquema_resuelto(_CARPETA_DATOS, "lealtad")["esquema"]
	var rechazo: Array = Validador.new().validar(con_dudosa, esquema, "lealtad.json")["errores"]
	assert_array(rechazo).is_not_empty()

	# Sistema.md 5.1 con la balanza 2 (umbral 7): los estados salen igual que antes.
	var estados: EstadosUnidad = EstadosUnidad.desde_datos(datos["tablas/hambre.json"], lealtad)
	var umbral: int = 0
	for fila in (datos["tablas/balanza.json"]["posiciones"] as Array):
		if fila["posicion"] == 2:
			umbral = fila["umbral_rescate"]
	assert_int(umbral).is_equal(7)
	var esperados: Array[String] = ["desleal", "desleal", "dudosa", "dudosa", "neutral", "neutral",
			"neutral", "leal", "leal", "leal", "leal"]
	for valor in esperados.size():
		assert_str(estados.lealtad(valor, umbral)).override_failure_message("lealtad %d" % valor) \
				.is_equal(esperados[valor])
