extends GdUnitTestSuite

# Arquitectura.md B.2.1 (T40, sesion 1): la vista muestra los rasgos con lo que
# le da el nucleo. Fixtures (A.6) y el runner de escenas de GdUnit4: tooltip de
# una enemiga (test 5), aviso al mover junto a una oculta (destaparia), zona de
# Caza (zona_amenaza, con la accion `zona`) y el modo "elegir casilla" de Cavar.
const _ESCENA: String = "res://pantalla/combate/vista_combate.tscn"
const _CARPETA_COMBATE: String = "res://pruebas/fixtures/combate/"
const _TEXTOS: String = "res://pruebas/fixtures/pantalla/es_rasgos.json"


func _vista(nombre: String) -> GdUnitSceneRunner:
	var lectura: Dictionary = DatosFixture.cargar()
	assert_array(lectura["errores"]).is_empty()
	var datos: Dictionary = lectura["datos"]
	datos["textos/es.json"] = LectorFixture.leer(_TEXTOS, "textos")["datos"]
	var escenario: Dictionary = LectorFixture.leer(_CARPETA_COMBATE + nombre + ".json", "escenario")["datos"]
	var runner: GdUnitSceneRunner = scene_runner(auto_free(load(_ESCENA).instantiate()))
	# T40, sesion 2: sin animar la IA (la pausa de los tests vale 0).
	(runner.scene() as VistaCombate).pausa_ia = 0.0
	(runner.scene() as VistaCombate).empezar(escenario, datos)
	return runner


func _ordenadas(casillas: Array[Vector2i]) -> Array[Vector2i]:
	var copia: Array[Vector2i] = casillas.duplicate()
	copia.sort_custom(func(a: Vector2i, b: Vector2i) -> bool: return a.y < b.y or (a.y == b.y and a.x < b.x))
	return copia


# (5) Con el mouse sobre el Tasajero enemigo de C: su rasgo y su estado (Caza y
# el umbral). Sobre una casilla vacia, nada.
func test_tooltip_de_una_enemiga() -> void:
	var runner: GdUnitSceneRunner = _vista("escenario_c")
	await runner.simulate_frames(1)
	var vista: VistaCombate = runner.scene()
	vista.sobre_casilla(Vector2i(3, 1))
	assert_array(vista.tooltip_mostrado()).contains(["Tasajero", "Caza y cuenta", "Caza",
			"Con 15 de vida o menos, pasa a Cuenta."])
	assert_bool(runner.find_child("PanelUnidad").visible).is_true()
	vista.sobre_casilla(Vector2i(0, 0))
	assert_array(vista.tooltip_mostrado()).is_empty()
	assert_bool(runner.find_child("PanelUnidad").visible).is_false()


# El Tasajero de la tribu [6,2] juega primero; con el Zancajunco salvaje [3,2]
# oculto, pararse en [4,2] lo destaparia y se avisa; en [5,2], no.
func test_aviso_al_mover_junto_a_una_oculta() -> void:
	var runner: GdUnitSceneRunner = _vista("escenario_junco_salvaje")
	await runner.simulate_frames(1)
	var vista: VistaCombate = runner.scene()
	assert_str(vista.combate().turno_actual().unidad_id).is_equal("tasajero_1")
	vista.combate().contexto().plantel.criatura("zancajunco_s1").oculta = true
	vista.sobre_casilla(Vector2i(4, 2))
	assert_str(vista.aviso_mostrado()).is_equal("Pararse acá destapa al Zancajunco, y queda a tiro de su embestida.")
	vista.sobre_casilla(Vector2i(5, 2))
	assert_str(vista.aviso_mostrado()).is_empty()


# La zona de Caza del Tasajero enemigo de C es la de zona_amenaza; la accion
# `zona` la oculta y la vuelve a mostrar. Un Tasajero de la tribu no la marca.
func test_zona_de_caza() -> void:
	var runner: GdUnitSceneRunner = _vista("escenario_c")
	await runner.simulate_frames(1)
	var vista: VistaCombate = runner.scene()
	assert_bool(vista.zona_visible()).is_true()
	var esperada: Array[Vector2i] = vista.combate().zona_amenaza("tasajero_s1")
	assert_array(esperada).is_not_empty()
	assert_array(_ordenadas(vista.casillas_zona())).is_equal(esperada)
	# Un evento de la accion del InputMap, como lo manda la tecla.
	var evento: InputEventAction = InputEventAction.new()
	evento.action = "zona"
	evento.pressed = true
	Input.parse_input_event(evento)
	await runner.simulate_frames(2)
	assert_bool(vista.zona_visible()).is_false()
	assert_array(vista.casillas_zona()).is_empty()
	vista.alternar_zona()
	assert_array(_ordenadas(vista.casillas_zona())).is_equal(esperada)

	runner = _vista("escenario_caza_tribu")
	await runner.simulate_frames(1)
	assert_array((runner.scene() as VistaCombate).casillas_zona()).is_empty()


# Cavar: el boton entra en el modo "elegir casilla"; una casilla invalida no
# hace nada y una valida cava. El surco queda en el tablero con el color de la tribu.
func test_modo_cavar_en_la_vista() -> void:
	var runner: GdUnitSceneRunner = _vista("escenario_surco_tribu")
	await runner.simulate_frames(1)
	var vista: VistaCombate = runner.scene()
	assert_bool(vista.pulsar_terminar()).is_true()
	assert_str(vista.combate().turno_actual().unidad_id).is_equal("surcon_1")
	assert_bool(vista.pulsar_activa(LecturaCombate.ACTIVA_CAVAR)).is_true()
	assert_bool(vista.eligiendo_cavar()).is_true()
	assert_bool(vista.clic_casilla(Vector2i(2, 5))).is_false()
	assert_bool(vista.clic_casilla(Vector2i(3, 5))).is_true()
	assert_bool(vista.eligiendo_cavar()).is_false()
	var surcos: TileMapLayer = runner.find_child("Surcos")
	assert_array(surcos.get_used_cells()).is_equal([Vector2i(3, 5)])
	assert_vector(surcos.get_cell_atlas_coords(Vector2i(3, 5))).is_equal(Vector2i(2, 0))


# T41 (11), Sistema.md 10.3 v1.6 y 15: el Zancajunco de C [4,6] juega primero.
# Con el mouse sobre [4,5] (alcanzable), el Maestro [3,6] queda en diagonal y es
# afin (leal): se marca su casilla y el aviso suma afinidad.tooltip. Sobre una
# casilla alcanzable sin afines, nada. Sobre la propia, el Maestro al lado da.
func test_marca_y_aviso_de_afinidad() -> void:
	var runner: GdUnitSceneRunner = _vista("escenario_c")
	await runner.simulate_frames(1)
	var vista: VistaCombate = runner.scene()
	var turno: Turno = vista.combate().turno_actual()
	assert_str(turno.unidad_id).is_equal("zancajunco_1")
	var tooltip: String = "Con una afín al lado o en diagonal, pega un poco más fuerte."
	var maestro: Vector2i = Vector2i(3, 6)

	assert_array(turno.casillas_para_mover()).contains([Vector2i(4, 5)])
	vista.sobre_casilla(Vector2i(4, 5))
	assert_array(vista.casillas_afines()).is_equal([maestro])
	assert_str(vista.aviso_mostrado()).is_equal(tooltip)
	assert_bool(runner.find_child("Aviso").visible).is_true()

	var sin_afines: Vector2i = Criatura.SIN_POSICION
	for casilla in turno.casillas_para_mover():
		if vista.combate().afines_desde("zancajunco_1", casilla).is_empty():
			sin_afines = casilla
			break
	assert_that(sin_afines).is_not_equal(Criatura.SIN_POSICION)
	vista.sobre_casilla(sin_afines)
	assert_array(vista.casillas_afines()).is_empty()
	assert_str(vista.aviso_mostrado()).is_empty()
	assert_bool(runner.find_child("Aviso").visible).is_false()

	vista.sobre_casilla(Vector2i(4, 6))
	assert_array(vista.casillas_afines()).is_equal([maestro])
	assert_str(vista.aviso_mostrado()).is_equal(tooltip)
