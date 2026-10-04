extends GdUnitTestSuite

# Arquitectura.md B.2 (T05, criterio 7): la ficha del Tasajero tiene dos turnos (8 y 3).
const _FIXTURE_TASAJERO: String = "res://pruebas/fixtures/unidades/tasajero.json"


# Sistema.md 11.2: Caza y cuenta, dos turnos completos por ronda.
func test_tasajero_tiene_dos_turnos() -> void:
	var lectura: Dictionary = LectorFixture.leer(_FIXTURE_TASAJERO, "especie")
	var errores: Array[Dictionary] = lectura["errores"]
	assert_array(errores).override_failure_message(str(errores)).is_empty()

	var tasajero: Especie = Especie.new(lectura["datos"])
	var turnos: Array[Dictionary] = tasajero.turnos()
	assert_int(turnos.size()).is_equal(2)
	assert_int(turnos[0]["velocidad"] as int).is_equal(8)
	assert_str(turnos[0]["marca"] as String).is_equal("caza")
	assert_int(turnos[1]["velocidad"] as int).is_equal(3)
	assert_str(turnos[1]["marca"] as String).is_equal("cuenta")
