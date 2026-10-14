extends GdUnitTestSuite

# Arquitectura.md B.4 (T32, sesion 2) y D-013: revision de cada marca en
# isometrica. Cada una cae en la casilla que da el nucleo: la capa tiene esas
# casillas y esta alineada con el tablero (mismo map_to_local, misma
# transformacion), y una marca de ficha va en la ficha que esta en
# map_to_local de su casilla. Con los fixtures de los tests de cada tarea.
const _ESCENA: String = "res://pantalla/combate/vista_combate.tscn"
const _COMBATE: String = "res://pruebas/fixtures/combate/"
const _PANTALLA: String = "res://pruebas/fixtures/pantalla/"
const _TEXTOS: String = "res://pruebas/fixtures/pantalla/es_rasgos.json"
# Presentacion: el Maestro rapido de test_vista_huida_maestro.gd, para que juegue primero.
const _VELOCIDAD_MAESTRO: int = 9
const _TOPE_TURNOS: int = 20


func _datos() -> Dictionary:
	var lectura: Dictionary = DatosFixture.cargar()
	assert_array(lectura["errores"]).is_empty()
	var datos: Dictionary = lectura["datos"]
	datos["textos/es.json"] = LectorFixture.leer(_TEXTOS, "textos")["datos"]
	return datos


func _vista(ruta: String, datos: Dictionary = {}) -> GdUnitSceneRunner:
	var lectura: Dictionary = LectorFixture.leer(ruta, "escenario")
	assert_array(lectura["errores"]).override_failure_message(str(lectura["errores"])).is_empty()
	var runner: GdUnitSceneRunner = scene_runner(auto_free(load(_ESCENA).instantiate()))
	var vista: VistaCombate = runner.scene()
	vista.pausa_ia = 0.0
	vista.vista_tablero = VistasTablero.ISOMETRICA
	vista.empezar(lectura["datos"], _datos() if datos.is_empty() else datos)
	return runner


func _ordenadas(casillas: Array[Vector2i]) -> Array[Vector2i]:
	var copia: Array[Vector2i] = casillas.duplicate()
	copia.sort_custom(func(a: Vector2i, b: Vector2i) -> bool: return a.y < b.y or (a.y == b.y and a.x < b.x))
	return copia


func _posicion(vista: VistaCombate, unidad_id: String) -> Vector2i:
	var plantel: Plantel = vista.combate().contexto().plantel
	return plantel.maestro.posicion if unidad_id == Maestro.ID else plantel.criatura(unidad_id).posicion


func _posiciones(vista: VistaCombate, ids: Array) -> Array[Vector2i]:
	var casillas: Array[Vector2i] = []
	for unidad_id in ids:
		casillas.append(_posicion(vista, unidad_id))
	return casillas


# La capa marca justo esas casillas y esta alineada con el tablero.
func _assert_capa(vista: VistaCombate, nombre: String, esperadas: Array[Vector2i]) -> TileMapLayer:
	var tablero: TileMapLayer = vista.tablero()
	var capa: TileMapLayer = tablero.get_node(nombre)
	assert_object(capa.tile_set).override_failure_message(nombre).is_same(tablero.tile_set)
	assert_int(capa.tile_set.tile_shape).is_equal(TileSet.TILE_SHAPE_ISOMETRIC)
	assert_object(capa.transform).override_failure_message(nombre).is_equal(Transform2D.IDENTITY)
	assert_array(_ordenadas(capa.get_used_cells())).override_failure_message(nombre) \
			.is_equal(_ordenadas(esperadas))
	for casilla in esperadas:
		assert_vector(capa.to_global(capa.map_to_local(casilla))).override_failure_message("%s %s" % [nombre, casilla]) \
				.is_equal(tablero.to_global(tablero.map_to_local(casilla)))
	return capa


# La ficha de la unidad, en map_to_local de su casilla del nucleo.
func _assert_ficha(vista: VistaCombate, unidad_id: String) -> FichaUnidad:
	var ficha: FichaUnidad = vista.tablero().get_node("Unidades").get_node(unidad_id)
	assert_object(ficha).override_failure_message(unidad_id).is_not_null()
	assert_vector(ficha.position).override_failure_message(unidad_id) \
			.is_equal(vista.tablero().map_to_local(_posicion(vista, unidad_id)))
	return ficha


func _hasta_el_maestro(vista: VistaCombate) -> void:
	for _i in range(_TOPE_TURNOS):
		if vista.combate().turno_actual().unidad_id == Maestro.ID:
			return
		assert_bool(vista.pulsar_terminar()).is_true()
	fail("no llego el turno del Maestro")


# Surcos (T40) con el color del bando de su duenio.
func test_surcos() -> void:
	var runner: GdUnitSceneRunner = _vista(_COMBATE + "escenario_surco_tribu.json")
	await runner.simulate_frames(1)
	var vista: VistaCombate = runner.scene()
	assert_bool(vista.pulsar_terminar()).is_true()
	assert_bool(vista.pulsar_activa(LecturaCombate.ACTIVA_CAVAR)).is_true()
	assert_bool(vista.clic_casilla(Vector2i(3, 5))).is_true()
	var esperadas: Array[Vector2i] = []
	for surco in vista.combate().instantanea()["surcos"]:
		esperadas.append(Vector2i(surco["casilla"][0], surco["casilla"][1]))
	assert_array(esperadas).is_not_empty()
	var capa: TileMapLayer = _assert_capa(vista, "Surcos", esperadas)
	# El duenio es de la tribu: la marca de la tribu.
	assert_vector(capa.get_cell_atlas_coords(esperadas[0])).is_equal(Vector2i(2, 0))


# Oculta y bono pendiente (T38): la ficha del Zancajunco, transparente y con sus
# marcas, en su casilla.
func test_oculta_y_bono() -> void:
	var runner: GdUnitSceneRunner = _vista(_COMBATE + "escenario_c.json")
	await runner.simulate_frames(1)
	var vista: VistaCombate = runner.scene()
	assert_str(vista.combate().turno_actual().unidad_id).is_equal("zancajunco_1")
	assert_bool(vista.pulsar_activa(LecturaCombate.ACTIVA_HACERSE_JUNCO)).is_true()
	var zancajunco: Criatura = vista.combate().contexto().plantel.criatura("zancajunco_1")
	assert_bool(zancajunco.oculta).is_true()
	var ficha: FichaUnidad = _assert_ficha(vista, "zancajunco_1")
	assert_float(ficha.modulate.a).is_less(1.0)
	# Oculta y, si el bono quedo pendiente, su marca: separadas por " · ".
	var marcas: int = ficha.texto_marcas().split(" · ", false).size()
	assert_int(marcas).is_greater_equal(2 if zancajunco.bono_junco else 1)


# Modo del Tasajero (T36) en la ficha y en la cola.
func test_modo_del_tasajero() -> void:
	var runner: GdUnitSceneRunner = _vista(_COMBATE + "escenario_c.json")
	await runner.simulate_frames(1)
	var vista: VistaCombate = runner.scene()
	assert_str(vista.combate().contexto().plantel.criatura("tasajero_s1").modo).is_not_empty()
	var ficha: FichaUnidad = _assert_ficha(vista, "tasajero_s1")
	assert_str(ficha.texto_marcas()).is_not_empty()
	var marca_cola: String = ""
	for entrada in vista.combate().cola():
		if entrada.unidad_id == "tasajero_s1":
			marca_cola = entrada.marca
	assert_str(marca_cola).is_not_empty()
	var en_la_cola: bool = false
	for etiqueta in runner.find_child("Cola").get_children():
		if etiqueta.has_meta("unidad_id") and etiqueta.get_meta("unidad_id") == "tasajero_s1":
			en_la_cola = etiqueta.get_meta("marca") == marca_cola
	assert_bool(en_la_cola).is_true()


# Zona de Caza (T40): la de zona_amenaza.
func test_zona_de_caza() -> void:
	var runner: GdUnitSceneRunner = _vista(_COMBATE + "escenario_c.json")
	await runner.simulate_frames(1)
	var vista: VistaCombate = runner.scene()
	var esperadas: Array[Vector2i] = vista.combate().zona_amenaza("tasajero_s1")
	assert_array(esperadas).is_not_empty()
	_assert_capa(vista, "Zona", esperadas)


# Afines (T41) y rivales del incidente (T18), con el mouse sobre la propia.
func test_afines_y_rivales() -> void:
	var runner: GdUnitSceneRunner = _vista(_COMBATE + "escenario_c.json")
	await runner.simulate_frames(1)
	var vista: VistaCombate = runner.scene()
	var casilla: Vector2i = Vector2i(4, 6)
	assert_vector(_posicion(vista, "zancajunco_1")).is_equal(casilla)
	vista.sobre_casilla(casilla)
	var afines: Array[Vector2i] = _posiciones(vista, vista.combate().afines_desde("zancajunco_1", casilla))
	var rivales: Array[Vector2i] = _posiciones(vista, vista.combate().incidente_en("zancajunco_1", casilla)["rivales"])
	assert_array(afines).is_not_empty()
	assert_array(rivales).is_not_empty()
	_assert_capa(vista, "Afines", afines)
	_assert_capa(vista, "Rivales", rivales)
	# Las 4 ortogonales de la propia, en la misma capa alineada.
	_assert_capa(vista, "Ortogonales", vista.combate().contexto().tablero.vecinas(casilla))


# Rivales enemigas (T19): las de rival_en.
func test_rivales_enemigas() -> void:
	var runner: GdUnitSceneRunner = _vista(_PANTALLA + "escenario_cobardia_pantalla.json")
	await runner.simulate_frames(1)
	var vista: VistaCombate = runner.scene()
	var turno: Turno = vista.combate().turno_actual()
	var casilla: Vector2i = Vector2i(2, 6)
	vista.sobre_casilla(casilla)
	var rival: Dictionary = vista.combate().rival_en(turno.unidad_id, casilla)
	assert_int(rival["porcentaje"]).is_greater(0)
	_assert_capa(vista, "RivalesEnemigas", _posiciones(vista, rival["rivales"]))


# Huida de las salvajes (T25): la marca va en la ficha de la que puede huir.
func test_huida_de_las_salvajes() -> void:
	var runner: GdUnitSceneRunner = _vista(_PANTALLA + "escenario_huida_pantalla.json")
	await runner.simulate_frames(1)
	var vista: VistaCombate = runner.scene()
	var porcentaje: int = vista.combate().porcentaje_huida("surcon_s1")
	assert_int(porcentaje).is_greater(0)
	assert_str(_assert_ficha(vista, "surcon_s1").texto_marcas()).contains("%d%%" % porcentaje)


# Huida del Maestro (T28): las enemigas que lo alcanzan, con el mouse sobre Huir.
func test_huida_del_maestro() -> void:
	var datos: Dictionary = _datos()
	datos["maestro.json"]["velocidad"] = _VELOCIDAD_MAESTRO
	var runner: GdUnitSceneRunner = _vista(_COMBATE + "escenario_huida_maestro_combate.json", datos)
	await runner.simulate_frames(2)
	var vista: VistaCombate = runner.scene()
	assert_str(vista.combate().turno_actual().unidad_id).is_equal(Maestro.ID)
	vista.mostrar_huida(true)
	var alcanzan: Array = []
	for enemiga in vista.combate().previsualizar_huida()["enemigas"]:
		if enemiga["alcanza"]:
			alcanzan.append(enemiga["unidad"])
	assert_array(alcanzan).is_not_empty()
	_assert_capa(vista, "AlcanzanHuida", _posiciones(vista, alcanzan))
	_assert_ficha(vista, Maestro.ID)


# Sellar (T24): las objetivos de objetivos_para_sellar.
func test_sellar() -> void:
	var runner: GdUnitSceneRunner = _vista(_COMBATE + "escenario_sellar_combate.json")
	await runner.simulate_frames(1)
	var vista: VistaCombate = runner.scene()
	_hasta_el_maestro(vista)
	assert_bool(vista.pulsar_sellar()).is_true()
	var objetivos: Array[String] = vista.combate().turno_actual().objetivos_para_sellar()
	assert_array(objetivos).is_not_empty()
	_assert_capa(vista, "Marcas", _posiciones(vista, objetivos))


# Guardar a una caida (T27): las de objetivos_para_guardar_caida.
func test_guardar_a_una_caida() -> void:
	var runner: GdUnitSceneRunner = _vista(_COMBATE + "escenario_guardar_caida_combate.json")
	await runner.simulate_frames(1)
	var vista: VistaCombate = runner.scene()
	_hasta_el_maestro(vista)
	assert_bool(vista.pulsar_guardar_caida()).is_true()
	var caidas: Array[String] = vista.combate().turno_actual().objetivos_para_guardar_caida()
	assert_array(caidas).is_not_empty()
	_assert_capa(vista, "Marcas", _posiciones(vista, caidas))
	for caida in caidas:
		_assert_ficha(vista, caida)


# Invocar (T26): las casillas de casillas_para_invocar.
func test_invocar() -> void:
	var runner: GdUnitSceneRunner = _vista(_COMBATE + "escenario_guardar_invocar_combate.json")
	await runner.simulate_frames(1)
	var vista: VistaCombate = runner.scene()
	assert_bool(vista.pulsar_terminar()).is_true()
	assert_bool(vista.pulsar_invocar("rodauva_g")).is_true()
	var casillas: Array[Vector2i] = vista.combate().turno_actual().casillas_para_invocar()
	assert_array(casillas).is_not_empty()
	_assert_capa(vista, "Marcas", casillas)
