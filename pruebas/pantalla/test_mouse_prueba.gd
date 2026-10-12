extends GdUnitTestSuite

# T24-ajustes (D-012): MousePrueba pasa la posicion del viewport a coordenadas
# de ventana antes de Input.parse_input_event, que le aplica la inversa de
# Viewport.get_final_transform(). La cuenta se prueba sin ventana, con una
# transformacion de escala y traslacion armada a mano.
const _FINAL: Transform2D = Transform2D(0.0, Vector2(2, 3), 0.0, Vector2(10, 20))
const _OTRO_DISPOSITIVO: int = 3
const _ESCENA: String = "res://pantalla/combate/vista_combate.tscn"
const _ESCENARIO_12: String = "res://pruebas/fixtures/pantalla/escenario_12x12.json"
const _TEXTOS: String = "res://pruebas/fixtures/pantalla/es_rasgos.json"
# La ventana chica del diagnostico de la sesion 1 (P-044).
const _VENTANA_CHICA: Vector2i = Vector2i(200, 120)
# Frames que se esperan, antes de mandar el evento, a que la ventana cambie.
const _TOPE_FRAMES: int = 120
# Pixeles de pantalla abajo que tapan los botones (Interfaz/Botones).
const _FRANJA_BOTONES: float = 72.0

var _tamanio_original: Vector2i = Vector2i.ZERO


func after_test() -> void:
	if _tamanio_original == Vector2i.ZERO:
		return
	var ventana: Window = get_tree().root
	ventana.size = _tamanio_original
	for _i in range(_TOPE_FRAMES):
		if ventana.size == _tamanio_original:
			break
		await get_tree().process_frame
	_tamanio_original = Vector2i.ZERO


# (2) Un movimiento: la posicion con escala y traslacion, el relative solo con
# la escala; global_position queda (Godot tampoco la convierte), y el device es
# el pedido. El evento original no cambia.
func test_movimiento_a_ventana() -> void:
	var evento: InputEventMouseMotion = InputEventMouseMotion.new()
	evento.position = Vector2(5, 7)
	evento.global_position = Vector2(5, 7)
	evento.relative = Vector2(4, -2)
	evento.button_mask = MOUSE_BUTTON_MASK_MIDDLE

	var enviado: InputEventMouseMotion = MousePrueba.a_ventana(evento, _FINAL, _OTRO_DISPOSITIVO)
	assert_vector(enviado.position).is_equal(Vector2(20, 41))
	assert_vector(enviado.relative).is_equal(Vector2(8, -6))
	assert_vector(enviado.global_position).is_equal(Vector2(5, 7))
	assert_int(enviado.button_mask).is_equal(MOUSE_BUTTON_MASK_MIDDLE)
	assert_int(enviado.device).is_equal(_OTRO_DISPOSITIVO)

	assert_vector(evento.position).is_equal(Vector2(5, 7))
	assert_vector(evento.relative).is_equal(Vector2(4, -2))
	assert_int(evento.device).is_not_equal(_OTRO_DISPOSITIVO)


# (2) Un boton: la posicion convertida; boton, pressed y mascara intactos.
func test_boton_a_ventana() -> void:
	var evento: InputEventMouseButton = InputEventMouseButton.new()
	evento.button_index = MOUSE_BUTTON_RIGHT
	evento.button_mask = MOUSE_BUTTON_MASK_RIGHT
	evento.pressed = true
	evento.position = Vector2(-1, 2)
	evento.global_position = Vector2(-1, 2)

	var enviado: InputEventMouseButton = MousePrueba.a_ventana(evento, _FINAL, MousePrueba.DISPOSITIVO)
	assert_vector(enviado.position).is_equal(Vector2(8, 26))
	assert_vector(enviado.global_position).is_equal(Vector2(-1, 2))
	assert_int(enviado.button_index).is_equal(MOUSE_BUTTON_RIGHT)
	assert_int(enviado.button_mask).is_equal(MOUSE_BUTTON_MASK_RIGHT)
	assert_bool(enviado.pressed).is_true()
	assert_int(enviado.device).is_equal(MousePrueba.DISPOSITIVO)
	assert_vector(evento.position).is_equal(Vector2(-1, 2))


# (2) Con la identidad (ventana de 1152 x 648) la posicion no cambia.
func test_identidad_no_cambia_la_posicion() -> void:
	var evento: InputEventMouseMotion = InputEventMouseMotion.new()
	evento.position = Vector2(351, 398)
	evento.relative = Vector2(1, 1)
	var enviado: InputEventMouseMotion = MousePrueba.a_ventana(evento, Transform2D.IDENTITY, MousePrueba.DISPOSITIVO)
	assert_vector(enviado.position).is_equal(Vector2(351, 398))
	assert_vector(enviado.relative).is_equal(Vector2(1, 1))


# (2) Con la ventana chica (la transformacion final deja de ser la identidad),
# un hover y un clic por MousePrueba dan la casilla esperada. La espera va
# antes de mandar el evento; entre el evento y la comprobacion, nada.
func test_ventana_chica() -> void:
	var lectura: Dictionary = DatosFixture.cargar()
	assert_array(lectura["errores"]).is_empty()
	var datos: Dictionary = lectura["datos"]
	datos["textos/es.json"] = LectorFixture.leer(_TEXTOS, "textos")["datos"]
	var escenario: Dictionary = LectorFixture.leer(_ESCENARIO_12, "escenario")["datos"]
	var runner: GdUnitSceneRunner = scene_runner(auto_free(load(_ESCENA).instantiate()))
	var vista: VistaCombate = runner.scene()
	vista.pausa_ia = 0.0
	MousePrueba.preparar(vista)
	vista.empezar(escenario, datos)
	await runner.simulate_frames(1)

	var ventana: Window = get_tree().root
	_tamanio_original = ventana.size
	ventana.size = _VENTANA_CHICA
	for _i in range(_TOPE_FRAMES):
		if _ventana_achicada(ventana):
			break
		await runner.simulate_frames(1)
	assert_bool(_ventana_achicada(ventana)).override_failure_message(
			"la ventana no se achico: %s, %s" % [ventana.size, ventana.get_final_transform()]).is_true()

	var turno: Turno = vista.combate().turno_actual()
	var destino: Vector2i = Criatura.SIN_POSICION
	for casilla in turno.casillas_para_mover():
		if _clickeable(vista, casilla):
			destino = casilla
			break
	assert_vector(destino).override_failure_message("ninguna casilla para mover a la vista").is_not_equal(Criatura.SIN_POSICION)
	MousePrueba.mover_a(_en_pantalla(vista, destino))
	assert_vector(vista.casilla_bajo_mouse()).is_equal(destino)
	MousePrueba.clic_en(_en_pantalla(vista, destino))
	assert_bool(turno.movimiento_usado).is_true()


func _ventana_achicada(ventana: Window) -> bool:
	return ventana.size == _VENTANA_CHICA and not ventana.get_final_transform().is_equal_approx(Transform2D.IDENTITY)


func _en_pantalla(vista: VistaCombate, casilla: Vector2i) -> Vector2:
	var tablero: TileMapLayer = vista.tablero()
	return tablero.get_viewport().get_canvas_transform() * tablero.to_global(tablero.map_to_local(casilla))


func _clickeable(vista: VistaCombate, casilla: Vector2i) -> bool:
	var tamanio: Vector2 = vista.get_viewport_rect().size
	return Rect2(Vector2.ZERO, tamanio - Vector2(0, _FRANJA_BOTONES)).grow(-8).has_point(_en_pantalla(vista, casilla))
