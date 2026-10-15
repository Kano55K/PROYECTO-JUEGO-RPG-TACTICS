extends GdUnitTestSuite

# Arquitectura.md B.4 (T45), test 3: S-52 (Sistema.md 11.7 v1.8). Sale el +25 de
# huida de la acobardada: huida_salvaje.acobardada_pts deja tablas/combate.json y
# su esquema. Usa datos/ real (A.6: que todo carga).
const _CARPETA_DATOS: String = "res://datos"
const _FIXTURE_COMBATE: String = "res://pruebas/fixtures/combate/combate.json"


func test_s52_sin_acobardada_pts() -> void:
	var carga: Dictionary = Cargador.new().cargar_carpeta(_CARPETA_DATOS)
	var errores: Array[Dictionary] = carga["errores"]
	assert_array(errores).override_failure_message(str(errores)).is_empty()
	var combate: Dictionary = carga["datos"]["tablas/combate.json"]
	assert_bool((combate["huida_salvaje"] as Dictionary).has("acobardada_pts")).is_false()
	assert_object(Huida.desde_datos(combate)).is_not_null()

	# Una copia del fixture con el campo de vuelta no valida (additionalProperties).
	var lectura: Dictionary = LectorFixture.leer(_FIXTURE_COMBATE, "combate")
	assert_array(lectura["errores"]).is_empty()
	var con_campo: Dictionary = (lectura["datos"] as Dictionary).duplicate(true)
	(con_campo["huida_salvaje"] as Dictionary)["acobardada_pts"] = 25
	var esquema: Dictionary = Cargador.new().esquema_resuelto(_CARPETA_DATOS, "combate")["esquema"]
	var rechazo: Array = Validador.new().validar(con_campo, esquema, "combate.json")["errores"]
	assert_array(rechazo).is_not_empty()
