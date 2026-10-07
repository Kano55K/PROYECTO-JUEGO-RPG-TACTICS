extends GdUnitTestSuite

# Arquitectura.md B.3.1 (T42) y D-003: la camara movil de la vista de combate,
# con el runner de escenas de GdUnit4. El fixture de 12 x 12 (A.6) con los
# datos de prueba, y los 11 escenarios de datos/ solo para ver que abren bien.
const _ESCENA: String = "res://pantalla/combate/vista_combate.tscn"
const _ESCENA_PRINCIPAL: String = "res://pantalla/principal.tscn"
const _ESCENARIO_12: String = "res://pruebas/fixtures/pantalla/escenario_12x12.json"
const _TEXTOS: String = "res://pruebas/fixtures/pantalla/es_rasgos.json"
const _CARPETA_DATOS: String = "res://datos"
const _PREFIJO_ESCENARIOS: String = "escenarios/"
const _ACCIONES_DIRECCION: Array[String] = ["camara_arriba", "camara_abajo", "camara_izquierda", "camara_derecha"]
# Presentacion: tan rapida que un frame llega al borde.
const _VELOCIDAD_ENORME: float = 1000000.0
const _ENORME: float = 100000.0
# Pixeles de pantalla abajo que tapan los botones (Interfaz/Botones).
const _FRANJA_BOTONES: float = 72.0
const _EPSILON: float = 0.01


func after_test() -> void:
	for accion in _ACCIONES_DIRECCION:
		Input.action_release(accion)
	Input.action_release("camara_arrastrar")


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


# ajustes: propiedades de la vista que se ponen antes de empezar.
func _vista(escenario: Dictionary, datos: Dictionary, ajustes: Dictionary = {}) -> GdUnitSceneRunner:
	var runner: GdUnitSceneRunner = scene_runner(auto_free(load(_ESCENA).instantiate()))
	var vista: VistaCombate = runner.scene()
	vista.pausa_ia = 0.0
	for propiedad in ajustes.keys():
		vista.set(propiedad, ajustes[propiedad])
	vista.empezar(escenario, datos)
	return runner


func _vista_12(ajustes: Dictionary = {}) -> GdUnitSceneRunner:
	return _vista(_escenario_12(), _datos_fixture(), ajustes)


# El area que se ve (centro y viewport / zoom) esta dentro de los limites, o
# centrada en ellos en el eje donde es mas grande.
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


func _assert_zoom_en_rango(vista: VistaCombate, mensaje: String = "") -> void:
	var zoom: float = vista.camara().zoom.x
	assert_bool(zoom >= vista.zoom_minimo - _EPSILON and zoom <= vista.zoom_maximo + _EPSILON) \
			.override_failure_message("%s zoom %f" % [mensaje, zoom]).is_true()
	assert_float(vista.camara().zoom.y).is_equal(zoom)


# Casilla -> posicion en el viewport: map_to_local y la transformacion del lienzo (camara).
func _en_pantalla(vista: VistaCombate, casilla: Vector2i) -> Vector2:
	var tablero: TileMapLayer = vista.tablero()
	return tablero.get_viewport().get_canvas_transform() * tablero.to_global(tablero.map_to_local(casilla))


# Se ve y no la tapan los botones de abajo.
func _clickeable(vista: VistaCombate, casilla: Vector2i) -> bool:
	var tamanio: Vector2 = vista.get_viewport_rect().size
	return Rect2(Vector2.ZERO, tamanio - Vector2(0, _FRANJA_BOTONES)).grow(-8).has_point(_en_pantalla(vista, casilla))


func _casilla_de(foto: Dictionary, unidad_id: String) -> Vector2i:
	if unidad_id == Maestro.ID:
		return Vector2i(foto["maestro"]["posicion"][0], foto["maestro"]["posicion"][1])
	for criatura in foto["criaturas"]:
		if criatura["id"] == unidad_id:
			return Vector2i(criatura["posicion"][0], criatura["posicion"][1])
	return Criatura.SIN_POSICION


func _rueda(boton: MouseButton) -> void:
	var evento: InputEventMouseButton = InputEventMouseButton.new()
	evento.button_index = boton
	evento.pressed = true
	Input.parse_input_event(evento)
	var suelto: InputEventMouseButton = evento.duplicate()
	suelto.pressed = false
	Input.parse_input_event(suelto)


# (1) Con la camara desplazada y con zoom, el hover marca la casilla bajo el
# mouse y un clic de verdad da la accion del interprete en esa casilla.
func test_clic_y_hover_con_la_camara_movida() -> void:
	var runner: GdUnitSceneRunner = _vista_12()
	await runner.simulate_frames(1)
	var vista: VistaCombate = runner.scene()
	var zoom_inicial: float = vista.camara().zoom.x
	vista.acercar()
	vista.acercar()
	vista.mover_camara(Vector2(0, _ENORME))
	await runner.simulate_frames(2)
	assert_float(vista.camara().zoom.x).is_greater(zoom_inicial)

	var turno: Turno = vista.combate().turno_actual()
	var destino: Vector2i = Criatura.SIN_POSICION
	for casilla in turno.casillas_para_mover():
		if _clickeable(vista, casilla):
			destino = casilla
			break
	assert_vector(destino).override_failure_message("ninguna casilla para mover a la vista").is_not_equal(Criatura.SIN_POSICION)

	# Hover sobre la casilla vacia.
	runner.simulate_mouse_move(_en_pantalla(vista, destino))
	await runner.simulate_frames(2)
	assert_vector(vista.casilla_bajo_mouse()).is_equal(destino)
	assert_array(vista.tooltip_mostrado()).is_empty()

	# Clic: la unidad del turno se mueve ahi.
	runner.simulate_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	await runner.simulate_frames(2)
	assert_vector(_casilla_de(vista.combate().instantanea(), turno.unidad_id)).is_equal(destino)

	# Hover sobre la unidad que llego: su tooltip.
	runner.simulate_mouse_move(_en_pantalla(vista, destino) + Vector2(2, 2))
	await runner.simulate_frames(2)
	assert_vector(vista.casilla_bajo_mouse()).is_equal(destino)
	assert_array(vista.tooltip_mostrado()).is_not_empty()


# (1) Si la camara se mueve con el mouse quieto, el hover pasa a la casilla
# que queda bajo el mouse.
func test_hover_sigue_al_mover_la_camara() -> void:
	var runner: GdUnitSceneRunner = _vista_12()
	await runner.simulate_frames(1)
	var vista: VistaCombate = runner.scene()
	vista.acercar()
	vista.acercar()
	await runner.simulate_frames(1)
	var centro_pantalla: Vector2 = vista.get_viewport_rect().size / 2.0
	runner.simulate_mouse_move(centro_pantalla)
	await runner.simulate_frames(2)
	var antes: Vector2i = vista.casilla_bajo_mouse()
	vista.mover_camara(Vector2(0, _ENORME))
	await runner.simulate_frames(2)
	var tablero: TileMapLayer = vista.tablero()
	assert_vector(vista.casilla_bajo_mouse()).is_equal(tablero.local_to_map(tablero.get_local_mouse_position()))
	assert_vector(vista.casilla_bajo_mouse()).is_not_equal(antes)


# (2) Con cada direccion apretada, con zoom maximo y con el de apertura, la
# camara llega al borde y no sale de los limites.
func test_direcciones_no_salen_de_los_limites() -> void:
	var runner: GdUnitSceneRunner = _vista_12({"velocidad_camara": _VELOCIDAD_ENORME})
	await runner.simulate_frames(1)
	var vista: VistaCombate = runner.scene()
	for acercar in [false, true]:
		if acercar:
			for _i in range(20):
				vista.acercar()
		for accion in _ACCIONES_DIRECCION:
			Input.action_press(accion)
			await runner.simulate_frames(3)
			_assert_dentro(vista, accion)
			Input.action_release(accion)
			await runner.simulate_frames(1)
	# Con zoom maximo el area es mas chica que los limites: abajo a la derecha
	# la camara quedo en el borde.
	var visible: Vector2 = vista.get_viewport_rect().size / vista.camara().zoom.x
	Input.action_press("camara_derecha")
	Input.action_press("camara_abajo")
	await runner.simulate_frames(3)
	assert_vector(vista.camara().global_position).is_equal_approx(vista.limites_camara().end - visible / 2.0,
			Vector2(_EPSILON, _EPSILON))


# (2) Arrastrar con el boton del medio no saca la camara de los limites.
func test_arrastrar_no_sale_de_los_limites() -> void:
	var runner: GdUnitSceneRunner = _vista_12()
	await runner.simulate_frames(1)
	var vista: VistaCombate = runner.scene()
	for _i in range(20):
		vista.acercar()
	await runner.simulate_frames(1)
	var inicio: Vector2 = vista.camara().global_position
	var boton: InputEventMouseButton = InputEventMouseButton.new()
	boton.button_index = MOUSE_BUTTON_MIDDLE
	boton.pressed = true
	Input.parse_input_event(boton)
	await runner.simulate_frames(1)
	var posiciones: Array[Vector2] = []
	for relativo in [Vector2(_ENORME, _ENORME), Vector2(-_ENORME, -_ENORME)]:
		var movimiento: InputEventMouseMotion = InputEventMouseMotion.new()
		movimiento.relative = relativo
		movimiento.button_mask = MOUSE_BUTTON_MASK_MIDDLE
		Input.parse_input_event(movimiento)
		await runner.simulate_frames(2)
		_assert_dentro(vista, str(relativo))
		posiciones.append(vista.camara().global_position)
	var suelto: InputEventMouseButton = boton.duplicate()
	suelto.pressed = false
	Input.parse_input_event(suelto)
	await runner.simulate_frames(1)
	# Arrastrar a la derecha y abajo lleva la camara arriba a la izquierda, y al reves.
	assert_bool(posiciones[0].x < inicio.x and posiciones[0].y < inicio.y).is_true()
	assert_bool(posiciones[1].x > inicio.x and posiciones[1].y > inicio.y).is_true()
	# Suelto el boton, mover el mouse ya no arrastra.
	var despues: InputEventMouseMotion = InputEventMouseMotion.new()
	despues.relative = Vector2(_ENORME, 0)
	Input.parse_input_event(despues)
	await runner.simulate_frames(2)
	assert_vector(vista.camara().global_position).is_equal(posiciones[1])


# (3) La rueda acerca y aleja, sin pasar del maximo ni del minimo.
func test_zoom_respeta_minimo_y_maximo() -> void:
	var runner: GdUnitSceneRunner = _vista_12()
	await runner.simulate_frames(1)
	var vista: VistaCombate = runner.scene()
	for _i in range(20):
		_rueda(MOUSE_BUTTON_WHEEL_UP)
		await runner.simulate_frames(1)
		_assert_zoom_en_rango(vista)
		_assert_dentro(vista)
	assert_float(vista.camara().zoom.x).is_equal_approx(vista.zoom_maximo, _EPSILON)
	for _i in range(20):
		_rueda(MOUSE_BUTTON_WHEEL_DOWN)
		await runner.simulate_frames(1)
		_assert_zoom_en_rango(vista)
		_assert_dentro(vista)
	assert_float(vista.camara().zoom.x).is_equal_approx(vista.zoom_minimo, _EPSILON)


# (4) Los 11 escenarios de datos/ y el fixture de 12 x 12 abren con la camara
# dentro de los limites y el zoom en su rango.
func test_escenarios_abren_dentro_de_los_limites() -> void:
	var carga: Dictionary = Cargador.new().cargar_carpeta(_CARPETA_DATOS)
	assert_array(carga["errores"]).is_empty()
	var datos: Dictionary = carga["datos"]
	var rutas: Array[String] = []
	for ruta in datos.keys():
		if (ruta as String).begins_with(_PREFIJO_ESCENARIOS):
			rutas.append(ruta)
	assert_int(rutas.size()).is_equal(11)
	for ruta in rutas:
		var runner: GdUnitSceneRunner = _vista(datos[ruta], datos)
		await runner.simulate_frames(1)
		var vista: VistaCombate = runner.scene()
		_assert_zoom_en_rango(vista, ruta)
		_assert_dentro(vista, ruta)
		# Entran enteros, centrados en el tablero: los de 12 x 12 y G en 8 x 8
		# (Sistema.md 11.9 v1.6, T43; solo cambio este comentario).
		assert_vector(vista.camara().global_position).override_failure_message(ruta) \
				.is_equal_approx(vista.limites_camara().get_center(), Vector2(_EPSILON, _EPSILON))
	var runner_12: GdUnitSceneRunner = _vista_12()
	await runner_12.simulate_frames(1)
	_assert_zoom_en_rango(runner_12.scene(), "12x12")
	_assert_dentro(runner_12.scene(), "12x12")


# (4) Si el tablero no entra entero con el zoom minimo, la camara se centra en
# el Maestro (acotada a los limites): el Maestro se ve.
func test_sin_entrar_centra_en_el_maestro() -> void:
	var runner: GdUnitSceneRunner = _vista_12({"zoom_minimo": 1.5, "zoom_maximo": 2.0})
	await runner.simulate_frames(1)
	var vista: VistaCombate = runner.scene()
	assert_float(vista.camara().zoom.x).is_equal(1.5)
	_assert_dentro(vista)
	var tablero: TileMapLayer = vista.tablero()
	var maestro: Vector2 = tablero.to_global(tablero.map_to_local(Vector2i(0, 11)))
	var visible: Vector2 = vista.get_viewport_rect().size / vista.camara().zoom.x
	assert_vector(vista.camara().global_position).is_equal(
			EncuadreCamara.acotar_centro(maestro, visible, vista.limites_camara()))
	assert_bool(Rect2(vista.camara().global_position - visible / 2.0, visible).has_point(maestro)).is_true()


# (5) R a mitad de un desplazamiento reinicia limpio: vista nueva, sin error y
# con la camara dentro de los limites.
func test_recargar_a_mitad_de_un_desplazamiento() -> void:
	var runner: GdUnitSceneRunner = scene_runner(auto_free(load(_ESCENA_PRINCIPAL).instantiate()))
	await runner.simulate_frames(1)
	var principal: Principal = runner.scene()
	var vista: VistaCombate = principal.abrir_escenario("a_dia_1")
	await runner.simulate_frames(1)
	vista.acercar()
	vista.acercar()
	Input.action_press("camara_derecha")
	await runner.simulate_frames(3)
	var evento: InputEventAction = InputEventAction.new()
	evento.action = "recargar"
	evento.pressed = true
	Input.parse_input_event(evento)
	await runner.simulate_frames(3)
	var nueva: VistaCombate = principal.vista()
	assert_object(nueva).is_not_null()
	assert_object(nueva).is_not_same(vista)
	assert_str(nueva.combate().error()).is_empty()
	assert_bool(nueva.combate().esperando_jugador()).is_true()
	_assert_dentro(nueva)
	Input.action_release("camara_derecha")
	await runner.simulate_frames(2)
	_assert_dentro(nueva)


# La camara anda durante la secuencia de la IA (solo mira) y nunca se mueve
# sola: ni entre pasos ni en el redibujo final.
func test_camara_durante_la_secuencia_de_la_ia() -> void:
	var runner: GdUnitSceneRunner = _vista_12()
	await runner.simulate_frames(1)
	var vista: VistaCombate = runner.scene()
	# Presentacion: una pausa que no llega a correr durante el test.
	vista.pausa_ia = 100.0
	for _i in range(20):
		if vista.en_secuencia():
			break
		assert_bool(vista.pulsar_terminar()).is_true()
	assert_bool(vista.en_secuencia()).is_true()
	var zoom_antes: float = vista.camara().zoom.x
	vista.acercar()
	vista.acercar()
	var antes: Vector2 = vista.camara().global_position
	vista.mover_camara(Vector2(0, _ENORME))
	await runner.simulate_frames(3)
	assert_bool(vista.en_secuencia()).is_true()
	assert_float(vista.camara().zoom.x).is_greater(zoom_antes)
	var movida: Vector2 = vista.camara().global_position
	assert_vector(movida).is_not_equal(antes)
	_assert_dentro(vista)
	assert_bool(vista.saltar()).is_true()
	await runner.simulate_frames(2)
	assert_vector(vista.camara().global_position).is_equal(movida)
	# Una accion del jugador y su redibujo tampoco la mueven.
	assert_bool(vista.pulsar_terminar()).is_true()
	await runner.simulate_frames(2)
	assert_vector(vista.camara().global_position).is_equal(movida)
