extends GdUnitTestSuite

# Arquitectura.md B.4 (T32, sesion 1) y D-013: la vista isometrica es un
# TileSet. Conversion casilla <-> pantalla solo con map_to_local / local_to_map
# (A.3), en las dos vistas; el mouse por MousePrueba (D-012), sin esperas entre
# un evento y su comprobacion. El fixture de 12 x 12 de T42, salvo el test (6).
const _ESCENA: String = "res://pantalla/combate/vista_combate.tscn"
const _ESCENARIO_12: String = "res://pruebas/fixtures/pantalla/escenario_12x12.json"
const _TEXTOS: String = "res://pruebas/fixtures/pantalla/es_rasgos.json"
const _CARPETA_DATOS: String = "res://datos"
const _PREFIJO_ESCENARIOS: String = "escenarios/"
const _VISTAS: Array[String] = [VistasTablero.ISOMETRICA, VistasTablero.CENITAL]
const _ENORME: float = 100000.0
# Pixeles de pantalla abajo que tapan los botones (Interfaz/Botones).
const _FRANJA_BOTONES: float = 72.0
const _EPSILON: float = 0.01


func _datos_fixture() -> Dictionary:
	var lectura: Dictionary = DatosFixture.cargar()
	assert_array(lectura["errores"]).is_empty()
	var datos: Dictionary = lectura["datos"]
	datos["textos/es.json"] = LectorFixture.leer(_TEXTOS, "textos")["datos"]
	return datos


func _escenario_12() -> Dictionary:
	var lectura: Dictionary = LectorFixture.leer(_ESCENARIO_12, "escenario")
	assert_array(lectura["errores"]).override_failure_message(str(lectura["errores"])).is_empty()
	return lectura["datos"]


func _vista(escenario: Dictionary, datos: Dictionary, vista_tablero: String) -> GdUnitSceneRunner:
	var runner: GdUnitSceneRunner = scene_runner(auto_free(load(_ESCENA).instantiate()))
	var vista: VistaCombate = runner.scene()
	vista.pausa_ia = 0.0
	vista.vista_tablero = vista_tablero
	MousePrueba.preparar(vista)
	vista.empezar(escenario, datos)
	return runner


func _vista_12(vista_tablero: String = VistasTablero.ISOMETRICA) -> GdUnitSceneRunner:
	return _vista(_escenario_12(), _datos_fixture(), vista_tablero)


func _fichas(vista: VistaCombate) -> Array[FichaUnidad]:
	var fichas: Array[FichaUnidad] = []
	for hijo in vista.tablero().get_node("Unidades").get_children():
		fichas.append(hijo as FichaUnidad)
	return fichas


func _casilla_de(foto: Dictionary, unidad_id: String) -> Vector2i:
	if unidad_id == Maestro.ID:
		return Vector2i(foto["maestro"]["posicion"][0], foto["maestro"]["posicion"][1])
	for criatura in foto["criaturas"]:
		if criatura["id"] == unidad_id and criatura["posicion"] != null:
			return Vector2i(criatura["posicion"][0], criatura["posicion"][1])
	return Criatura.SIN_POSICION


# Un punto del lienzo del tablero -> posicion en el viewport (camara incluida).
func _local_en_pantalla(vista: VistaCombate, local: Vector2) -> Vector2:
	var tablero: TileMapLayer = vista.tablero()
	return tablero.get_viewport().get_canvas_transform() * tablero.to_global(local)


func _en_pantalla(vista: VistaCombate, casilla: Vector2i) -> Vector2:
	return _local_en_pantalla(vista, vista.tablero().map_to_local(casilla))


func _visible_y_libre(vista: VistaCombate, punto: Vector2) -> bool:
	var tamanio: Vector2 = vista.get_viewport_rect().size
	return Rect2(Vector2.ZERO, tamanio - Vector2(0, _FRANJA_BOTONES)).grow(-8).has_point(punto)


# El area que se ve esta dentro de los limites, o centrada en el eje donde es
# mas grande (como test_vista_camara.gd).
func _assert_dentro(vista: VistaCombate, mensaje: String = "") -> void:
	var camara: Camera2D = vista.camara()
	var visible: Vector2 = vista.get_viewport_rect().size / camara.zoom.x
	var limites: Rect2 = vista.limites_camara()
	var centro: Vector2 = camara.global_position
	for eje in [0, 1]:
		if visible[eje] >= limites.size[eje]:
			assert_float(centro[eje]).override_failure_message("%s eje %d centrado" % [mensaje, eje]) \
					.is_equal_approx(limites.get_center()[eje], _EPSILON)
		else:
			assert_bool(centro[eje] - visible[eje] / 2.0 >= limites.position[eje] - _EPSILON \
					and centro[eje] + visible[eje] / 2.0 <= limites.end[eje] + _EPSILON) \
					.override_failure_message("%s eje %d: centro %s, visible %s, limites %s" % [mensaje, eje, centro, visible, limites]) \
					.is_true()


# (1) En las dos vistas, ida y vuelta de toda casilla del 12 x 12, y cada ficha
# en map_to_local de su casilla.
func test_conversion_ida_y_vuelta_en_las_dos_vistas() -> void:
	for vista_tablero in _VISTAS:
		var runner: GdUnitSceneRunner = _vista_12(vista_tablero)
		await runner.simulate_frames(1)
		var vista: VistaCombate = runner.scene()
		var tablero: TileMapLayer = vista.tablero()
		for y in range(12):
			for x in range(12):
				var casilla: Vector2i = Vector2i(x, y)
				assert_vector(tablero.local_to_map(tablero.map_to_local(casilla))) \
						.override_failure_message("%s %s" % [vista_tablero, casilla]).is_equal(casilla)
		var foto: Dictionary = vista.combate().instantanea()
		var fichas: Array[FichaUnidad] = _fichas(vista)
		assert_int(fichas.size()).is_equal(3)
		for ficha in fichas:
			assert_vector(ficha.position).override_failure_message("%s %s" % [vista_tablero, ficha.unidad_id]) \
					.is_equal(tablero.map_to_local(_casilla_de(foto, ficha.unidad_id)))


# (2) En isometrica, con zoom y la camara movida, hover y clic por MousePrueba
# caen en la casilla correcta, tambien en un punto del rombo cerca de la punta;
# y un punto dentro del rectangulo de la casilla pero fuera de su rombo cae en
# la vecina.
func test_clic_y_hover_isometrica_con_camara_y_zoom() -> void:
	var runner: GdUnitSceneRunner = _vista_12()
	await runner.simulate_frames(1)
	var vista: VistaCombate = runner.scene()
	var zoom_inicial: float = vista.camara().zoom.x
	vista.acercar()
	vista.acercar()
	vista.mover_camara(Vector2(0, _ENORME))
	await runner.simulate_frames(2)
	assert_float(vista.camara().zoom.x).is_greater(zoom_inicial)

	var tablero: TileMapLayer = vista.tablero()
	var turno: Turno = vista.combate().turno_actual()
	var destino: Vector2i = Criatura.SIN_POSICION
	for casilla in turno.casillas_para_mover():
		var punta: Vector2 = tablero.map_to_local(casilla).lerp(tablero.map_to_local(casilla + Vector2i(1, -1)), 0.45)
		if _visible_y_libre(vista, _en_pantalla(vista, casilla)) and _visible_y_libre(vista, _local_en_pantalla(vista, punta)):
			destino = casilla
			break
	assert_vector(destino).override_failure_message("ninguna casilla para mover a la vista").is_not_equal(Criatura.SIN_POSICION)

	# La punta derecha del rombo (hacia la vecina (1, -1), que en DIAMOND_DOWN
	# esta a la misma altura) es de la casilla.
	var cerca_de_la_punta: Vector2 = tablero.map_to_local(destino).lerp(
			tablero.map_to_local(destino + Vector2i(1, -1)), 0.45)
	MousePrueba.mover_a(_local_en_pantalla(vista, cerca_de_la_punta))
	assert_vector(vista.casilla_bajo_mouse()).is_equal(destino)
	# Pasada la mitad hacia la vecina (1, 0), el punto sigue dentro del
	# rectangulo de la casilla pero es de la vecina: la conversion es en rombo.
	var vecina: Vector2i = destino + Vector2i(1, 0)
	var hacia_la_vecina: Vector2 = tablero.map_to_local(destino).lerp(tablero.map_to_local(vecina), 0.55)
	var tamanio: Vector2 = Vector2(tablero.tile_set.tile_size)
	assert_bool(Rect2(tablero.map_to_local(destino) - tamanio / 2.0, tamanio).has_point(hacia_la_vecina)).is_true()
	MousePrueba.mover_a(_local_en_pantalla(vista, hacia_la_vecina))
	assert_vector(vista.casilla_bajo_mouse()).is_equal(vecina)

	# Hover y clic en el centro: la unidad del turno se mueve ahi.
	MousePrueba.mover_a(_en_pantalla(vista, destino))
	assert_vector(vista.casilla_bajo_mouse()).is_equal(destino)
	MousePrueba.clic_en(_en_pantalla(vista, destino))
	assert_vector(_casilla_de(vista.combate().instantanea(), turno.unidad_id)).is_equal(destino)


# (3) En las dos vistas, todas las capas del tablero usan el TileSet del
# tablero, que es el de VistasTablero (D-013 (2)).
func test_capas_usan_el_tileset_del_tablero() -> void:
	for vista_tablero in _VISTAS:
		var runner: GdUnitSceneRunner = _vista_12(vista_tablero)
		await runner.simulate_frames(1)
		var vista: VistaCombate = runner.scene()
		var tablero: TileMapLayer = vista.tablero()
		assert_object(tablero.tile_set).is_same(VistasTablero.tile_set(vista_tablero))
		var capas: int = 0
		for hijo in tablero.get_children():
			if hijo is TileMapLayer:
				capas += 1
				assert_object((hijo as TileMapLayer).tile_set).override_failure_message("%s %s" % [vista_tablero, hijo.name]) \
						.is_same(tablero.tile_set)
		# Surcos, Zona, Marcas, Afines, Rivales, RivalesEnemigas, DestinosHechizo
		# y AlcanzanHuida.
		assert_int(capas).is_greater_equal(8)


# (4) En isometrica, los limites contienen el centro de las 4 esquinas, y la
# camara no sale de ellos en ninguna direccion, con el zoom maximo.
func test_limites_contienen_las_cuatro_esquinas() -> void:
	var runner: GdUnitSceneRunner = _vista_12()
	await runner.simulate_frames(1)
	var vista: VistaCombate = runner.scene()
	var tablero: TileMapLayer = vista.tablero()
	for esquina in [Vector2i(0, 0), Vector2i(11, 0), Vector2i(0, 11), Vector2i(11, 11)]:
		var centro: Vector2 = tablero.to_global(tablero.map_to_local(esquina))
		assert_bool(vista.limites_camara().has_point(centro)) \
				.override_failure_message("%s en %s, limites %s" % [esquina, centro, vista.limites_camara()]).is_true()
	_assert_dentro(vista, "al abrir")
	for _i in range(20):
		vista.acercar()
	for direccion in [Vector2(_ENORME, 0), Vector2(-_ENORME, 0), Vector2(0, _ENORME), Vector2(0, -_ENORME)]:
		vista.mover_camara(direccion)
		_assert_dentro(vista, str(direccion))


# (5) Las fichas se ordenan por y: la de mayor profundidad (x + y) queda mas
# abajo y se dibuja despues. Las capas de marcas quedan debajo de las fichas.
func test_fichas_por_profundidad() -> void:
	var runner: GdUnitSceneRunner = _vista_12()
	await runner.simulate_frames(1)
	var vista: VistaCombate = runner.scene()
	var unidades: Node2D = vista.tablero().get_node("Unidades")
	assert_bool(unidades.y_sort_enabled).is_true()
	var foto: Dictionary = vista.combate().instantanea()
	var por_id: Dictionary = {}
	for ficha in _fichas(vista):
		por_id[ficha.unidad_id] = ficha
		assert_int(ficha.z_index).is_equal(0)
	# El Maestro en (0, 11) y la Rodauva en (1, 11): la Rodauva esta adelante.
	var maestro: FichaUnidad = por_id[Maestro.ID]
	var rodauva: FichaUnidad = por_id["rodauva_1"]
	var casilla_maestro: Vector2i = _casilla_de(foto, Maestro.ID)
	var casilla_rodauva: Vector2i = _casilla_de(foto, "rodauva_1")
	assert_int(casilla_rodauva.x + casilla_rodauva.y).is_greater(casilla_maestro.x + casilla_maestro.y)
	assert_float(rodauva.position.y).is_greater(maestro.position.y)
	for hijo in vista.tablero().get_children():
		if hijo is TileMapLayer:
			assert_int(hijo.get_index()).override_failure_message(hijo.name).is_less(unidades.get_index())
			assert_int((hijo as TileMapLayer).z_index).is_equal(unidades.z_index)


# (6) datos/ real: los 10 escenarios abren en isometrica, esperando al jugador,
# con la camara dentro de los limites.
func test_escenarios_reales_en_isometrica() -> void:
	var carga: Dictionary = Cargador.new().cargar_carpeta(_CARPETA_DATOS)
	assert_array(carga["errores"]).is_empty()
	var datos: Dictionary = carga["datos"]
	var rutas: Array[String] = []
	for ruta in datos.keys():
		if (ruta as String).begins_with(_PREFIJO_ESCENARIOS):
			rutas.append(ruta)
	assert_int(rutas.size()).is_equal(10)
	for ruta in rutas:
		var runner: GdUnitSceneRunner = _vista(datos[ruta], datos, VistasTablero.ISOMETRICA)
		await runner.simulate_frames(1)
		var vista: VistaCombate = runner.scene()
		assert_object(vista.tablero().tile_set).is_same(VistasTablero.tile_set(VistasTablero.ISOMETRICA))
		assert_str(vista.combate().error()).override_failure_message(ruta).is_empty()
		assert_bool(vista.combate().esperando_jugador()).override_failure_message(ruta).is_true()
		_assert_dentro(vista, ruta)


# (7) La vista con un valor desconocido no arranca: muestra el error.
func test_vista_desconocida_no_arma_el_combate() -> void:
	var runner: GdUnitSceneRunner = _vista_12("rara")
	await runner.simulate_frames(1)
	var vista: VistaCombate = runner.scene()
	assert_object(vista.combate()).is_null()
	assert_bool(runner.find_child("Mensaje").visible).is_true()
	assert_str((runner.find_child("Mensaje") as Label).text).contains("rara")
