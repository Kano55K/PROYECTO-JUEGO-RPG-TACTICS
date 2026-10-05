extends GdUnitTestSuite

# Sistema.md 5.1 (estados de lealtad) y 7.1 (estados de hambre), con fixtures
# (A.6). Los cortes son la comprobacion: el codigo los lee de las tablas.
const _CARPETA_COMBATE: String = "res://pruebas/fixtures/combate/"
const _CARPETA_UNIDADES: String = "res://pruebas/fixtures/unidades/"


func _estados() -> EstadosUnidad:
	var hambre: Dictionary = LectorFixture.leer(_CARPETA_COMBATE + "hambre.json", "hambre")
	var lealtad: Dictionary = LectorFixture.leer(_CARPETA_UNIDADES + "lealtad.json", "lealtad")
	assert_array(hambre["errores"]).is_empty()
	assert_array(lealtad["errores"]).is_empty()
	return EstadosUnidad.desde_datos(hambre["datos"], lealtad["datos"])


# Sistema.md 7.1: 0-2 Saciado, 3-5 Normal, 6-8 Hambriento, 9-10 Famelico.
func test_estado_de_hambre() -> void:
	var estados: EstadosUnidad = _estados()
	assert_str(estados.hambre(0)).is_equal("saciado")
	assert_str(estados.hambre(2)).is_equal("saciado")
	assert_str(estados.hambre(3)).is_equal("normal")
	assert_str(estados.hambre(8)).is_equal("hambriento")
	assert_str(estados.hambre(10)).is_equal("famelico")


# Sistema.md 5.1: 0-1 Desleal, 2-3 Dudosa, 4 hasta umbral - 1 Neutral, desde el
# umbral de la balanza Leal (balanza 1: umbral 6; balanza 4: umbral 8).
func test_estado_de_lealtad() -> void:
	var estados: EstadosUnidad = _estados()
	assert_str(estados.lealtad(1, 6)).is_equal("desleal")
	assert_str(estados.lealtad(3, 6)).is_equal("dudosa")
	assert_str(estados.lealtad(4, 6)).is_equal("neutral")
	assert_str(estados.lealtad(5, 6)).is_equal("neutral")
	assert_str(estados.lealtad(6, 6)).is_equal("leal")
	assert_str(estados.lealtad(7, 8)).is_equal("neutral")
	assert_str(estados.lealtad(8, 8)).is_equal("leal")
