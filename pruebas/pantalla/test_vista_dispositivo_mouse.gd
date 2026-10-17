extends GdUnitTestSuite

# T24-ajustes (D-012): el filtro de device del mouse de VistaCombate. Los tests
# preparan la vista con MousePrueba y un evento de otro device (el cursor real
# de la maquina) no cambia nada; con la configuracion por defecto, la vista
# acepta cualquier device, como el juego. Fixture de 12 x 12 (A.6) con los
# datos de prueba. D-006: eventos con su position, sin await en el medio; todos
# por MousePrueba (D-012), con el device de cada caso.
const _ESCENA: String = "res://pantalla/combate/vista_combate.tscn"
const _ESCENARIO_12: String = "res://pruebas/fixtures/pantalla/escenario_12x12.json"
const _TEXTOS: String = "res://pruebas/fixtures/pantalla/es_rasgos.json"
# Pixeles de pantalla abajo que tapan los botones (Interfaz/Botones).
const _FRANJA_BOTONES: float = 72.0


func _vista(preparada: bool) -> GdUnitSceneRunner:
	var lectura: Dictionary = DatosFixture.cargar()
	assert_array(lectura["errores"]).is_empty()
	var datos: Dictionary = lectura["datos"]
	datos["textos/es.json"] = LectorFixture.leer(_TEXTOS, "textos")["datos"]
	var escenario: Dictionary = LectorFixture.leer(_ESCENARIO_12, "escenario")["datos"]
	var runner: GdUnitSceneRunner = scene_runner(auto_free(load(_ESCENA).instantiate()))
	var vista: VistaCombate = runner.scene()
	vista.pausa_ia = 0.0
	if preparada:
		MousePrueba.preparar(vista)
	vista.empezar(escenario, datos)
	return runner


func _en_pantalla(vista: VistaCombate, casilla: Vector2i) -> Vector2:
	var tablero: TileMapLayer = vista.tablero()
	return tablero.get_viewport().get_canvas_transform() * tablero.to_global(tablero.map_to_local(casilla))


func _clickeable(vista: VistaCombate, casilla: Vector2i) -> bool:
	var tamanio: Vector2 = vista.get_viewport_rect().size
	return Rect2(Vector2.ZERO, tamanio - Vector2(0, _FRANJA_BOTONES)).grow(-8).has_point(_en_pantalla(vista, casilla))


# Dos casillas para mover distintas, a la vista.
func _dos_casillas(vista: VistaCombate) -> Array[Vector2i]:
	var casillas: Array[Vector2i] = []
	for casilla in vista.combate().turno_actual().casillas_para_mover():
		if _clickeable(vista, casilla):
			casillas.append(casilla)
		if casillas.size() == 2:
			break
	assert_int(casillas.size()).override_failure_message("faltan casillas para mover a la vista").is_equal(2)
	return casillas


# El device con el que llega el mouse real: el de un evento nuevo de Godot.
func _dispositivo_real() -> int:
	var dispositivo: int = InputEventMouseMotion.new().device
	assert_int(dispositivo).is_not_equal(MousePrueba.DISPOSITIVO)
	return dispositivo


# (3) Con la vista preparada para los tests, un movimiento y un clic de otro
# device no cambian la casilla bajo el mouse ni mueven a nadie.
func test_otro_dispositivo_no_cambia_la_casilla() -> void:
	var runner: GdUnitSceneRunner = _vista(true)
	await runner.simulate_frames(1)
	var vista: VistaCombate = runner.scene()
	assert_int(vista.dispositivo_mouse).is_equal(MousePrueba.DISPOSITIVO)
	var casillas: Array[Vector2i] = _dos_casillas(vista)
	var turno: Turno = vista.combate().turno_actual()

	MousePrueba.mover_a(_en_pantalla(vista, casillas[0]), MousePrueba.DISPOSITIVO)
	assert_vector(vista.casilla_bajo_mouse()).is_equal(casillas[0])

	MousePrueba.mover_a(_en_pantalla(vista, casillas[1]), _dispositivo_real())
	assert_vector(vista.casilla_bajo_mouse()).is_equal(casillas[0])
	MousePrueba.clic_en(_en_pantalla(vista, casillas[1]), MOUSE_BUTTON_LEFT, MOUSE_BUTTON_MASK_LEFT, _dispositivo_real())
	assert_vector(vista.casilla_bajo_mouse()).is_equal(casillas[0])
	assert_bool(turno.movimiento_usado).is_false()
	assert_object(vista.combate().turno_actual()).is_same(turno)


# (3) Con la configuracion por defecto, la vista acepta el mouse de cualquier
# device: el real y el de los tests.
func test_por_defecto_acepta_cualquier_dispositivo() -> void:
	var runner: GdUnitSceneRunner = _vista(false)
	await runner.simulate_frames(1)
	var vista: VistaCombate = runner.scene()
	assert_int(vista.dispositivo_mouse).is_equal(VistaCombate.DISPOSITIVO_CUALQUIERA)
	var casillas: Array[Vector2i] = _dos_casillas(vista)

	MousePrueba.mover_a(_en_pantalla(vista, casillas[0]), _dispositivo_real())
	assert_vector(vista.casilla_bajo_mouse()).is_equal(casillas[0])
	MousePrueba.mover_a(_en_pantalla(vista, casillas[1]), MousePrueba.DISPOSITIVO)
	assert_vector(vista.casilla_bajo_mouse()).is_equal(casillas[1])
