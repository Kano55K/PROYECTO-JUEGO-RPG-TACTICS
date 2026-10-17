extends GdUnitTestSuite

# Arquitectura.md B.4 (T32, sesion 2), A.3 (riesgo) y Sistema.md 11.3 ("el
# cuerpo mira 4"): en isometrica, la capa Ortogonales marca las 4 vecinas
# ortogonales de la casilla bajo el mouse (unidad propia o casilla para mover),
# en el turno del jugador. Las da Tablero.vecinas (T06). Fixture de 12 x 12.
const _ESCENA: String = "res://pantalla/combate/vista_combate.tscn"
const _ESCENARIO_12: String = "res://pruebas/fixtures/pantalla/escenario_12x12.json"
const _TEXTOS: String = "res://pruebas/fixtures/pantalla/es_rasgos.json"


func _vista_12() -> GdUnitSceneRunner:
	var lectura: Dictionary = DatosFixture.cargar()
	assert_array(lectura["errores"]).is_empty()
	var datos: Dictionary = lectura["datos"]
	datos["textos/es.json"] = LectorFixture.leer(_TEXTOS, "textos")["datos"]
	var escenario: Dictionary = LectorFixture.leer(_ESCENARIO_12, "escenario")["datos"]
	var runner: GdUnitSceneRunner = scene_runner(auto_free(load(_ESCENA).instantiate()))
	var vista: VistaCombate = runner.scene()
	vista.pausa_ia = 0.0
	vista.vista_tablero = VistasTablero.ISOMETRICA
	vista.empezar(escenario, datos)
	return runner


func _ordenadas(casillas: Array[Vector2i]) -> Array[Vector2i]:
	var copia: Array[Vector2i] = casillas.duplicate()
	copia.sort_custom(func(a: Vector2i, b: Vector2i) -> bool: return a.y < b.y or (a.y == b.y and a.x < b.x))
	return copia


# Las marcas son las de Tablero.vecinas, ninguna en diagonal ni fuera del tablero.
func _assert_ortogonales(vista: VistaCombate, casilla: Vector2i, cuantas: int) -> void:
	var tablero: Tablero = vista.combate().contexto().tablero
	var marcadas: Array[Vector2i] = _ordenadas(vista.casillas_ortogonales())
	assert_array(marcadas).override_failure_message("%s: %s" % [casilla, marcadas]) \
			.is_equal(_ordenadas(tablero.vecinas(casilla)))
	assert_int(marcadas.size()).override_failure_message(str(casilla)).is_equal(cuantas)
	for marcada in marcadas:
		assert_int(Tablero.distancia(casilla, marcada)).is_equal(1)
		assert_bool(tablero.dentro(marcada)).is_true()


# (8) Sobre una unidad propia: 4 en el centro, 3 en un borde, 2 en una esquina.
func test_unidad_propia_en_centro_borde_y_esquina() -> void:
	var runner: GdUnitSceneRunner = _vista_12()
	await runner.simulate_frames(1)
	var vista: VistaCombate = runner.scene()
	assert_bool(vista.combate().esperando_jugador()).is_true()
	var plantel: Plantel = vista.combate().contexto().plantel
	# El Maestro en la esquina [0,11].
	vista.sobre_casilla(Vector2i(0, 11))
	_assert_ortogonales(vista, Vector2i(0, 11), 2)
	# La Rodauva en el borde [1,11].
	vista.sobre_casilla(Vector2i(1, 11))
	_assert_ortogonales(vista, Vector2i(1, 11), 3)
	# La Rodauva en el centro: la casilla se cambia en el plantel y se redibuja.
	plantel.criatura("rodauva_1").posicion = Vector2i(5, 5)
	vista.redibujar()
	vista.sobre_casilla(Vector2i(5, 5))
	_assert_ortogonales(vista, Vector2i(5, 5), 4)
	assert_array(vista.casillas_ortogonales()).not_contains([Vector2i(4, 4), Vector2i(6, 6), Vector2i(4, 6),
			Vector2i(6, 4)])


# (8) Sobre una casilla para mover, tambien; sobre una enemiga o una casilla
# vacia que no es para mover, nada.
func test_casilla_para_mover_si_enemiga_y_vacia_no() -> void:
	var runner: GdUnitSceneRunner = _vista_12()
	await runner.simulate_frames(1)
	var vista: VistaCombate = runner.scene()
	var turno: Turno = vista.combate().turno_actual()
	var para_mover: Array[Vector2i] = turno.casillas_para_mover()
	assert_array(para_mover).is_not_empty()
	vista.sobre_casilla(para_mover[0])
	_assert_ortogonales(vista, para_mover[0], vista.combate().contexto().tablero.vecinas(para_mover[0]).size())
	# La Ocarra salvaje en [11,0].
	vista.sobre_casilla(Vector2i(11, 0))
	assert_array(vista.casillas_ortogonales()).is_empty()
	var lejana: Vector2i = Vector2i(6, 0)
	assert_bool(para_mover.has(lejana)).is_false()
	vista.sobre_casilla(lejana)
	assert_array(vista.casillas_ortogonales()).is_empty()
	# Fuera del tablero, nada.
	vista.sobre_casilla(Vector2i(-3, 20))
	assert_array(vista.casillas_ortogonales()).is_empty()


# (8) Fuera del turno del jugador no marca nada: durante la secuencia de la IA.
func test_fuera_del_turno_del_jugador_nada() -> void:
	var runner: GdUnitSceneRunner = _vista_12()
	await runner.simulate_frames(1)
	var vista: VistaCombate = runner.scene()
	vista.sobre_casilla(Vector2i(0, 11))
	assert_array(vista.casillas_ortogonales()).is_not_empty()
	# Presentacion: una pausa que no llega a correr durante el test.
	vista.pausa_ia = 100.0
	for _i in range(20):
		if vista.en_secuencia():
			break
		assert_bool(vista.pulsar_terminar()).is_true()
	assert_bool(vista.en_secuencia()).is_true()
	assert_array(vista.casillas_ortogonales()).is_empty()
	vista.sobre_casilla(Vector2i(0, 11))
	assert_array(vista.casillas_ortogonales()).is_empty()
