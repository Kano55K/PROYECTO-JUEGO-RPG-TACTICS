extends GdUnitTestSuite

# Arquitectura.md B.3 (T14), test 10: P-003 (Sistema.md 5.4 v1.1). Los tramos de
# obediencia usan los cortes de tablas/lealtad.json: sale obediencia.baja.hasta
# de tablas/combate.json y de su esquema. Usa datos/ real (A.6: que todo carga).
const _CARPETA_DATOS: String = "res://datos"
const _FIXTURE_COMBATE: String = "res://pruebas/fixtures/combate/combate.json"


func test_p003_sin_baja_hasta() -> void:
	var carga: Dictionary = Cargador.new().cargar_carpeta(_CARPETA_DATOS)
	var errores: Array[Dictionary] = carga["errores"]
	assert_array(errores).override_failure_message(str(errores)).is_empty()
	var combate: Dictionary = carga["datos"]["tablas/combate.json"]
	assert_bool((combate["obediencia"]["baja"] as Dictionary).has("hasta")).is_false()

	# Una copia del fixture con el campo de vuelta no valida (additionalProperties).
	var lectura: Dictionary = LectorFixture.leer(_FIXTURE_COMBATE, "combate")
	assert_array(lectura["errores"]).is_empty()
	var con_hasta: Dictionary = (lectura["datos"] as Dictionary).duplicate(true)
	(con_hasta["obediencia"]["baja"] as Dictionary)["hasta"] = 3
	var esquema: Dictionary = Cargador.new().esquema_resuelto(_CARPETA_DATOS, "combate")["esquema"]
	var rechazo: Array = Validador.new().validar(con_hasta, esquema, "combate.json")["errores"]
	assert_array(rechazo).is_not_empty()
