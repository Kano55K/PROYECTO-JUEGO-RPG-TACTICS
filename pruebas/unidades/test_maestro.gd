extends GdUnitTestSuite

# Arquitectura.md B.2 (T05, criterio 1): con una tabla de balanza de prueba que
# copia la 1.2, el Maestro con balanza 2 tiene vida 20 y danio 4, y con balanza 5,
# vida 14 y danio 3. Los numeros viven en el fixture, no en el codigo (M-01).
const _FIXTURE_BALANZA: String = "res://pruebas/fixtures/unidades/balanza_1_2.json"


func _tabla_balanza() -> TablaBalanza:
	var lectura: Dictionary = LectorFixture.leer(_FIXTURE_BALANZA, "balanza")
	var errores: Array[Dictionary] = lectura["errores"]
	assert_array(errores).override_failure_message(str(errores)).is_empty()
	return TablaBalanza.new(lectura["datos"])


# Sistema.md 1.2 y 11.2
func test_vida_y_danio_salen_de_la_balanza() -> void:
	var tabla: TablaBalanza = _tabla_balanza()

	var maestro_2: Maestro = Maestro.new(tabla, 2)
	assert_int(maestro_2.vida_max_real()).is_equal(20)
	assert_int(maestro_2.danio_cuerpo()).is_equal(4)
	assert_int(maestro_2.vida).is_equal(20)

	var maestro_5: Maestro = Maestro.new(tabla, 5)
	assert_int(maestro_5.vida_max_real()).is_equal(14)
	assert_int(maestro_5.danio_cuerpo()).is_equal(3)
	assert_int(maestro_5.vida).is_equal(14)

	# Derivados, nunca guardados: mover la balanza los cambia sin recrear al Maestro.
	maestro_2.balanza = 5
	assert_int(maestro_2.vida_max_real()).is_equal(14)
	assert_int(maestro_2.danio_cuerpo()).is_equal(3)
