extends GdUnitTestSuite

# Arquitectura.md B.3.1 (T41), test 7: Sistema.md 7.2 v1.6, el hambre de combate
# suma cada 6 rondas. Usa datos/ real (A.6: que todo carga).
const _CARPETA_DATOS: String = "res://datos"


func test_cada_rondas_vale_6() -> void:
	var carga: Dictionary = Cargador.new().cargar_carpeta(_CARPETA_DATOS)
	var errores: Array[Dictionary] = carga["errores"]
	assert_array(errores).override_failure_message(str(errores)).is_empty()
	var hambre: Dictionary = carga["datos"]["tablas/hambre.json"]
	assert_int(hambre["combate"]["cada_rondas"]).is_equal(6)
