extends GdUnitTestSuite

# Arquitectura.md B.3 (T14), test 9: Sistema.md 1.2 (pasos de Arrimo por
# posicion) y 1.3 (efecto por paso). Fixtures (A.6). La tabla por posicion de
# 1.3 es derivada (A.2.2): se reproduce sumando a las bases de combate.json.
const _CARPETA_COMBATE: String = "res://pruebas/fixtures/combate/"
const _CARPETA_UNIDADES: String = "res://pruebas/fixtures/unidades/"


func _leer(ruta: String, esquema: String) -> Dictionary:
	var lectura: Dictionary = LectorFixture.leer(ruta, esquema)
	var errores: Array[Dictionary] = lectura["errores"]
	assert_array(errores).override_failure_message(str(errores)).is_empty()
	return lectura["datos"]


func _maestro(balanza: int) -> Maestro:
	return Maestro.new(TablaBalanza.new(_leer(_CARPETA_UNIDADES + "balanza_1_2.json", "balanza")), balanza)


# (9) 3 pasos con la balanza 2 y 0 con la 5, leidos de la fila; con 3 pasos,
# -15 a incidente, Encono y cobardia y +30 al combo; sumado a las bases da la
# fila de la balanza 2 de 1.3: incidente 5%, combo +50% / +70%.
func test_arrimo() -> void:
	assert_int(Arrimo.pasos(_maestro(2))).is_equal(3)
	assert_int(Arrimo.pasos(_maestro(5))).is_equal(0)

	var arrimo: Arrimo = Arrimo.desde_datos(_leer(_CARPETA_COMBATE + "arrimo.json", "arrimo"))
	var pasos: int = Arrimo.pasos(_maestro(2))
	assert_int(arrimo.ajuste(pasos, Arrimo.Uso.INCIDENTE)).is_equal(-15)
	assert_int(arrimo.ajuste(pasos, Arrimo.Uso.ENCONO)).is_equal(-15)
	assert_int(arrimo.ajuste(pasos, Arrimo.Uso.COBARDIA)).is_equal(-15)
	assert_int(arrimo.ajuste(pasos, Arrimo.Uso.COMBO)).is_equal(30)
	# Las salvajes no tienen Arrimo (10.7): quien llama pasa 0.
	assert_int(arrimo.ajuste(0, Arrimo.Uso.COMBO)).is_equal(0)

	var combate: Dictionary = _leer(_CARPETA_COMBATE + "combate.json", "combate")
	assert_int((combate["incidente"]["base_pct"] as int) + arrimo.ajuste(pasos, Arrimo.Uso.INCIDENTE)).is_equal(5)
	assert_int((combate["combo"]["sin_relacion_pct"] as int) + arrimo.ajuste(pasos, Arrimo.Uso.COMBO)).is_equal(50)
	assert_int((combate["combo"]["afines_pct"] as int) + arrimo.ajuste(pasos, Arrimo.Uso.COMBO)).is_equal(70)
	# Balanza 1 (4 pasos): incidente 0%, combo +60% / +80% (1.3).
	var pasos_1: int = Arrimo.pasos(_maestro(1))
	assert_int((combate["incidente"]["base_pct"] as int) + arrimo.ajuste(pasos_1, Arrimo.Uso.INCIDENTE)).is_equal(0)
	assert_int((combate["combo"]["afines_pct"] as int) + arrimo.ajuste(pasos_1, Arrimo.Uso.COMBO)).is_equal(80)
