extends GdUnitTestSuite

# Arquitectura.md W-01 (T10, sesion 2): relaciones par a par leidas de datos,
# con el fixture copia de relaciones.json (A.6). Sistema.md 10.8.
const _RUTA: String = "res://pruebas/fixtures/unidades/relaciones.json"

var _relaciones: Relaciones


func before_test() -> void:
	var lectura: Dictionary = LectorFixture.leer(_RUTA, "relaciones")
	var errores: Array[Dictionary] = lectura["errores"]
	assert_array(errores).override_failure_message(str(errores)).is_empty()
	_relaciones = Relaciones.new(lectura["datos"])


func test_pares_sin_orden() -> void:
	assert_int(_relaciones.relacion("rodauva", "surcon")).is_equal(Relaciones.Relacion.BIEN)
	assert_int(_relaciones.relacion("surcon", "rodauva")).is_equal(Relaciones.Relacion.BIEN)
	assert_int(_relaciones.relacion("zancajunco", "ocarra")).is_equal(Relaciones.Relacion.MAL)


func test_misma_especie_y_sin_relacion() -> void:
	assert_int(_relaciones.relacion("rodauva", "rodauva")).is_equal(Relaciones.Relacion.BIEN)
	assert_int(_relaciones.relacion("ocarra", "ocarra")).is_equal(Relaciones.Relacion.MAL)
	assert_int(_relaciones.relacion("rodauva", "ocarra")).is_equal(Relaciones.Relacion.NINGUNA)
	assert_int(_relaciones.relacion("surcon", "surcon")).is_equal(Relaciones.Relacion.NINGUNA)
