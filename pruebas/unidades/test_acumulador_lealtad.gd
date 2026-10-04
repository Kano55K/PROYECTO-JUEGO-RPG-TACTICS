extends GdUnitTestSuite

# Arquitectura.md B.2 (T10, criterio 9): el acumulador de lealtad suma por
# criatura y recorta a la escala una sola vez. Sistema.md 5.2, Precisiones. Los
# limites salen del fixture copia de lealtad.json (A.6).
const _CARPETA: String = "res://pruebas/fixtures/unidades/"

var _tabla_lealtad: Dictionary
var _rodauva: Especie


func before_test() -> void:
	_tabla_lealtad = _leer(_CARPETA + "lealtad.json", "lealtad")
	_rodauva = Especie.new(_leer(_CARPETA + "rodauva.json", "especie"))


func _leer(ruta: String, nombre_esquema: String) -> Dictionary:
	var lectura: Dictionary = LectorFixture.leer(ruta, nombre_esquema)
	var errores: Array[Dictionary] = lectura["errores"]
	assert_array(errores).override_failure_message(str(errores)).is_empty()
	return lectura["datos"]


func _criatura(id_criatura: String, lealtad: int) -> Criatura:
	var criatura: Criatura = Criatura.new(id_criatura, _rodauva, Criatura.Bando.TRIBU)
	criatura.lealtad = lealtad
	return criatura


func _criaturas(lista: Array) -> Array[Criatura]:
	var resultado: Array[Criatura] = []
	resultado.assign(lista)
	return resultado


# (9a) Ejemplo de 5.2: una rescatista con 9 que gana 2 y pierde 2 queda en 9, no
# en 8. El orden de las anotaciones no cambia nada.
func test_suma_y_recorte_unicos() -> void:
	for motivos in [["rescate", "muerte_en_el_grupo"], ["muerte_en_el_grupo", "rescate"]]:
		var rescatista: Criatura = _criatura("rodauva_1", 9)
		var acumulador: AcumuladorLealtad = AcumuladorLealtad.desde_datos(_tabla_lealtad)
		for motivo in motivos:
			acumulador.anotar("rodauva_1", 2 if motivo == "rescate" else -2, motivo)
		var cambios: Array[CambioLealtad] = acumulador.aplicar(_criaturas([rescatista]))
		assert_int(rescatista.lealtad).is_equal(9)
		assert_int(cambios.size()).is_equal(1)
		assert_str(cambios[0].criatura_id).is_equal("rodauva_1")
		assert_int(cambios[0].antes).is_equal(9)
		assert_int(cambios[0].cambio).is_equal(0)
		assert_int(cambios[0].despues).is_equal(9)
		assert_int(cambios[0].anotaciones.size()).is_equal(2)
		assert_str(cambios[0].anotaciones[0].motivo).is_equal(motivos[0])
		assert_str(cambios[0].anotaciones[1].motivo).is_equal(motivos[1])


# (9b) 1 con -4 queda en 0, no en -3.
func test_recorte_al_minimo() -> void:
	var criatura: Criatura = _criatura("rodauva_1", 1)
	var acumulador: AcumuladorLealtad = AcumuladorLealtad.desde_datos(_tabla_lealtad)
	acumulador.anotar("rodauva_1", -4, "muerte_en_el_grupo_afines")
	var cambios: Array[CambioLealtad] = acumulador.aplicar(_criaturas([criatura]))
	assert_int(criatura.lealtad).is_equal(0)
	assert_int(cambios[0].antes).is_equal(1)
	assert_int(cambios[0].cambio).is_equal(-4)
	assert_int(cambios[0].despues).is_equal(0)


# Sin anotaciones no aparece ni cambia; se aplica una sola vez.
func test_sin_anotaciones_y_una_sola_vez() -> void:
	var anotada: Criatura = _criatura("rodauva_1", 5)
	var sin_anotar: Criatura = _criatura("rodauva_2", 5)
	var acumulador: AcumuladorLealtad = AcumuladorLealtad.desde_datos(_tabla_lealtad)
	acumulador.anotar("rodauva_1", 1, "victoria")
	var cambios: Array[CambioLealtad] = acumulador.aplicar(_criaturas([anotada, sin_anotar]))
	assert_int(cambios.size()).is_equal(1)
	assert_str(cambios[0].criatura_id).is_equal("rodauva_1")
	assert_int(anotada.lealtad).is_equal(6)
	assert_int(sin_anotar.lealtad).is_equal(5)

	acumulador.anotar("rodauva_1", 1, "victoria")
	assert_array(acumulador.aplicar(_criaturas([anotada, sin_anotar]))).is_empty()
	assert_int(anotada.lealtad).is_equal(6)
