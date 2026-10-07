extends GdUnitTestSuite

# Arquitectura.md B.3 (T14), tests 1 a 3: Sistema.md 5.4 (obediencia = lealtad -
# penalizacion por hambre, con los cortes de 5.1) y 10.7 / 9.2 punto 3 (salvajes
# y atacante: tramo "baja"). Fixtures (A.6): los numeros son la comprobacion.
const _CARPETA_COMBATE: String = "res://pruebas/fixtures/combate/"
const _CARPETA_UNIDADES: String = "res://pruebas/fixtures/unidades/"


func _leer(ruta: String, esquema: String) -> Dictionary:
	var lectura: Dictionary = LectorFixture.leer(ruta, esquema)
	var errores: Array[Dictionary] = lectura["errores"]
	assert_array(errores).override_failure_message(str(errores)).is_empty()
	return lectura["datos"]


func _obediencia(tabla_lealtad: Dictionary = {}) -> Obediencia:
	var lealtad: Dictionary = tabla_lealtad
	if lealtad.is_empty():
		lealtad = _leer(_CARPETA_UNIDADES + "lealtad.json", "lealtad")
	return Obediencia.desde_datos(_leer(_CARPETA_COMBATE + "hambre.json", "hambre"), lealtad,
			_leer(_CARPETA_COMBATE + "combate.json", "combate"))


func _maestro(balanza: int) -> Maestro:
	return Maestro.new(TablaBalanza.new(_leer(_CARPETA_UNIDADES + "balanza_1_2.json", "balanza")), balanza)


func _criatura(lealtad: int, hambre: int, bando: Criatura.Bando = Criatura.Bando.TRIBU) -> Criatura:
	var criatura: Criatura = Criatura.new("rodauva_1", Especie.new(_leer(_CARPETA_UNIDADES + "rodauva.json", "especie")), bando)
	criatura.lealtad = lealtad
	criatura.hambre = hambre
	return criatura


func _assert_obediencia(obediencia: Obediencia, maestro: Maestro, lealtad: int, hambre: int, valor: int, tramo: String) -> void:
	var criatura: Criatura = _criatura(lealtad, hambre)
	assert_that(obediencia.valor(criatura)).override_failure_message("lealtad %d, hambre %d" % [lealtad, hambre]).is_equal(valor)
	assert_str(obediencia.tramo(criatura, maestro)).override_failure_message("lealtad %d, hambre %d" % [lealtad, hambre]).is_equal(tramo)


# (1) Balanza 2 (umbral 7). Sin recorte: 1 famelica da -3 (lectura tecnica, B.3).
func test_obediencia_con_la_balanza_2() -> void:
	var obediencia: Obediencia = _obediencia()
	var maestro: Maestro = _maestro(2)
	_assert_obediencia(obediencia, maestro, 8, 3, 8, Obediencia.TRAMO_LEAL)
	_assert_obediencia(obediencia, maestro, 8, 6, 6, Obediencia.TRAMO_NEUTRAL)
	_assert_obediencia(obediencia, maestro, 8, 9, 4, Obediencia.TRAMO_NEUTRAL)
	# D hambriento: lealtad 5 con hambre 6.
	_assert_obediencia(obediencia, maestro, 5, 6, 3, Obediencia.TRAMO_BAJA)
	_assert_obediencia(obediencia, maestro, 1, 9, -3, Obediencia.TRAMO_BAJA)


# (2) Los cortes salen de los datos y son los de la lealtad (5.4, P-003): con
# el piso de Neutral en 5, obediencia 4 es baja (y lealtad 4 deja de ser
# neutral); con la balanza 4 (umbral 8), 7 es neutral.
func test_cortes_desde_los_datos() -> void:
	var lealtad: Dictionary = _leer(_CARPETA_UNIDADES + "lealtad.json", "lealtad").duplicate(true)
	lealtad["neutral_desde"] = 5
	var obediencia: Obediencia = _obediencia(lealtad)
	# Lealtad 4, hambre 3 (Normal, sin penalizacion): obediencia 4.
	_assert_obediencia(obediencia, _maestro(2), 4, 3, 4, Obediencia.TRAMO_BAJA)
	_assert_obediencia(obediencia, _maestro(2), 5, 3, 5, Obediencia.TRAMO_NEUTRAL)
	var estados: EstadosUnidad = EstadosUnidad.desde_datos(_leer(_CARPETA_COMBATE + "hambre.json", "hambre"), lealtad)
	assert_str(estados.lealtad(4, 7)).is_not_equal(EstadosUnidad.LEALTAD_NEUTRAL)
	assert_str(estados.lealtad(5, 7)).is_equal(EstadosUnidad.LEALTAD_NEUTRAL)

	var normal: Obediencia = _obediencia()
	_assert_obediencia(normal, _maestro(4), 7, 3, 7, Obediencia.TRAMO_NEUTRAL)
	_assert_obediencia(normal, _maestro(4), 8, 3, 8, Obediencia.TRAMO_LEAL)


# (3) Sistema.md 10.7 y 9.2 punto 3: la salvaje y la atacante nocturna no se
# calculan, aunque tengan lealtad (el esquema de escenario no la admite en las
# enemigas: se pone en la Criatura, como la traeria la partida en 0b).
func test_salvaje_y_atacante_son_baja() -> void:
	var obediencia: Obediencia = _obediencia()
	var maestro: Maestro = _maestro(2)
	var salvaje: Criatura = _criatura(8, 3, Criatura.Bando.ENEMIGA)
	salvaje.comportamiento = Criatura.Comportamiento.SALVAJE
	assert_that(obediencia.valor(salvaje)).is_null()
	assert_str(obediencia.tramo(salvaje, maestro)).is_equal(Obediencia.TRAMO_BAJA)

	var datos: Dictionary = DatosFixture.cargar()["datos"]
	var plantel: Plantel = Plantel.desde_datos(datos, _leer(_CARPETA_UNIDADES + "escenario_g.json", "escenario"))
	var atacante: Criatura = plantel.criatura("ocarra_1")
	assert_int(atacante.comportamiento).is_equal(Criatura.Comportamiento.ATACANTE_NOCTURNA)
	atacante.lealtad = 8
	assert_that(obediencia.valor(atacante)).is_null()
	assert_str(obediencia.tramo(atacante, plantel.maestro)).is_equal(Obediencia.TRAMO_BAJA)
