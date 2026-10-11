extends GdUnitTestSuite

# Arquitectura.md B.4 (T24), criterio 10: el boton Sellar, el modo "elegir
# objetivo", el % sobre la salvaje, el hover (lo mostrado = el evento `sellado`
# al aplicar) y el clic izquierdo, con el runner de escenas de GdUnit4.
# Fixtures (A.6): escenario_sellar_combate.json (la Rodauva [3,3] juega primero y
# el test la hace terminar; el Maestro [4,5], balanza 3, tiene al Surcon salvaje
# [4,3] con 5 de 24 a distancia 2: 65 %, cuesta 4). es_rasgos.json mas copias
# textuales de datos/textos/es.json. Sistema.md 4.1 y 2.3.
# D-006: el mouse se manda como evento (parse_input_event + flush), sin
# warp_mouse y sin await entre el evento y la comprobacion.
const _ESCENA: String = "res://pantalla/combate/vista_combate.tscn"
const _ESCENARIO: String = "res://pruebas/fixtures/combate/escenario_sellar_combate.json"
const _TEXTOS: String = "res://pruebas/fixtures/pantalla/es_rasgos.json"
const _MARCA_ELEGIR: Vector2i = Vector2i(5, 0)
const _SURCON: Vector2i = Vector2i(4, 3)
const _TOPE_TURNOS: int = 20
# Copias textuales de datos/textos/es.json v1.3.
const _TEXTOS_SELLAR: Dictionary = {
	"accion.sellar": "Sellar",
	"panel.mana": "Maná",
	"sellar.tooltip": "{porcentaje}% de que el hilo {criatura_la} sujete. Si se suelta, el maná se pierde igual.",
}


func _datos() -> Dictionary:
	var lectura: Dictionary = DatosFixture.cargar()
	assert_array(lectura["errores"]).is_empty()
	var datos: Dictionary = lectura["datos"]
	var textos: Dictionary = LectorFixture.leer(_TEXTOS, "textos")["datos"]
	textos.merge(_TEXTOS_SELLAR, true)
	datos["textos/es.json"] = textos
	return datos


# maestro_en: otra casilla para el Maestro (Criatura.SIN_POSICION: la del escenario).
func _vista(maestro_en: Vector2i = Criatura.SIN_POSICION) -> GdUnitSceneRunner:
	var escenario: Dictionary = LectorFixture.leer(_ESCENARIO, "escenario")["datos"]
	if maestro_en != Criatura.SIN_POSICION:
		escenario["maestro"]["posicion"] = [maestro_en.x, maestro_en.y]
	var runner: GdUnitSceneRunner = scene_runner(auto_free(load(_ESCENA).instantiate()))
	(runner.scene() as VistaCombate).pausa_ia = 0.0
	(runner.scene() as VistaCombate).empezar(escenario, _datos())
	return runner


func _hasta_el_maestro(vista: VistaCombate) -> void:
	for _i in range(_TOPE_TURNOS):
		if vista.combate().turno_actual().unidad_id == Maestro.ID:
			return
		assert_bool(vista.pulsar_terminar()).is_true()
	fail("no llego el turno del Maestro")


func _ultimo(vista: VistaCombate, tipo: String) -> Dictionary:
	var encontrado: Dictionary = {}
	for linea in vista.combate().registro().lineas():
		if linea["tipo"] == tipo:
			encontrado = linea.duplicate(true)
	return encontrado


func _en_pantalla(vista: VistaCombate, casilla: Vector2i) -> Vector2:
	var tablero: TileMapLayer = vista.tablero()
	return tablero.get_viewport().get_canvas_transform() * tablero.to_global(tablero.map_to_local(casilla))


func _mandar(evento: InputEvent) -> void:
	Input.parse_input_event(evento)
	Input.flush_buffered_events()


func _mover_a(posicion: Vector2) -> void:
	var evento: InputEventMouseMotion = InputEventMouseMotion.new()
	evento.position = posicion
	evento.global_position = posicion
	_mandar(evento)


func _clic_en(posicion: Vector2) -> void:
	var evento: InputEventMouseButton = InputEventMouseButton.new()
	evento.button_index = MOUSE_BUTTON_LEFT
	evento.button_mask = MOUSE_BUTTON_MASK_LEFT
	evento.position = posicion
	evento.global_position = posicion
	evento.pressed = true
	_mandar(evento)
	var suelto: InputEventMouseButton = evento.duplicate()
	suelto.button_mask = 0
	suelto.pressed = false
	_mandar(suelto)


func _ficha(vista: VistaCombate, unidad_id: String) -> FichaUnidad:
	for ficha in vista.fichas():
		if ficha.unidad_id == unidad_id:
			return ficha
	return null


# (10) El boton sale solo en el turno del Maestro, con el costo; el modo marca
# justo las objetivos de la consulta; pulsarlo otra vez sale del modo.
func test_boton_y_modo() -> void:
	var runner: GdUnitSceneRunner = _vista()
	await runner.simulate_frames(1)
	var vista: VistaCombate = runner.scene()
	assert_object(runner.find_child("Sellar")).is_null()
	_hasta_el_maestro(vista)
	var boton: Button = runner.find_child("Sellar")
	assert_object(boton).is_not_null()
	assert_str(boton.text).is_equal("Sellar (4 Maná)")
	assert_bool(boton.disabled).is_false()

	assert_bool(vista.pulsar_sellar()).is_true()
	assert_bool(vista.eligiendo_sellar()).is_true()
	assert_array(vista.combate().turno_actual().objetivos_para_sellar()).is_equal(["surcon_s1"])
	var marcas: TileMapLayer = runner.find_child("Marcas")
	assert_array(marcas.get_used_cells()).is_equal([_SURCON])
	assert_vector(marcas.get_cell_atlas_coords(_SURCON)).is_equal(_MARCA_ELEGIR)
	assert_bool((runner.find_child("Sellar") as Button).button_pressed).is_true()
	# Los modos se excluyen: un hechizo saca del modo sellar.
	assert_bool(vista.pulsar_hechizo("remiendo")).is_true()
	assert_bool(vista.eligiendo_sellar()).is_false()
	assert_bool(vista.pulsar_sellar()).is_true()
	assert_str(vista.hechizo_elegido()).is_empty()
	assert_bool(vista.pulsar_sellar()).is_true()
	assert_bool(vista.eligiendo_sellar()).is_false()


# (10) Con el Surcon a 4, el boton esta deshabilitado, el tooltip dice el motivo
# de Turno.motivo_sellar (fuera de alcance) y pulsarlo no entra al modo.
func test_boton_deshabilitado_con_el_motivo() -> void:
	var runner: GdUnitSceneRunner = _vista(Vector2i(4, 7))
	await runner.simulate_frames(1)
	var vista: VistaCombate = runner.scene()
	_hasta_el_maestro(vista)
	assert_int(vista.combate().turno_actual().motivo_sellar()).is_equal(ResultadoAccion.Motivo.FUERA_DE_ALCANCE)
	var boton: Button = runner.find_child("Sellar")
	assert_bool(boton.disabled).is_true()
	assert_str(boton.text).is_equal("Sellar (4 Maná)")
	assert_str(boton.tooltip_text).is_equal("[FALTA: aviso.sellar.fuera_de_alcance]")
	assert_bool(vista.pulsar_sellar()).is_false()
	assert_bool(vista.eligiendo_sellar()).is_false()


# (10) El % sobre la salvaje (marca de la ficha y tooltip) es el de
# Combate.porcentaje_sellado, desde el principio.
func test_porcentaje_sobre_la_salvaje() -> void:
	var runner: GdUnitSceneRunner = _vista()
	await runner.simulate_frames(1)
	var vista: VistaCombate = runner.scene()
	var porcentaje: Variant = vista.combate().porcentaje_sellado("surcon_s1")
	assert_int(porcentaje).is_equal(65)
	assert_str(_ficha(vista, "surcon_s1").texto_marcas()).contains("%d%%" % porcentaje)
	assert_str(_ficha(vista, "rodauva_1").texto_marcas()).not_contains("%")
	_mover_a(_en_pantalla(vista, _SURCON))
	assert_array(vista.tooltip_mostrado()).contains(
			["65% de que el hilo lo sujete. Si se suelta, el maná se pierde igual."])


# (10) En el modo, el hover sobre el Surcon muestra el % y el costo de
# previsualizar_sellar, y el clic izquierdo sella: el evento `sellado` lleva ese
# % y el mana baja el costo.
func test_hover_igual_al_evento_y_clic() -> void:
	var runner: GdUnitSceneRunner = _vista()
	await runner.simulate_frames(1)
	var vista: VistaCombate = runner.scene()
	_hasta_el_maestro(vista)
	assert_bool(vista.pulsar_sellar()).is_true()
	var posicion: Vector2 = _en_pantalla(vista, _SURCON)
	_mover_a(posicion)
	var mostrado: Dictionary = vista.sellado_mostrado()
	assert_dict(mostrado).is_equal({"objetivo": "surcon_s1", "porcentaje": 65, "costo": 4})
	var panel: Label = runner.find_child("PanelDesglose")
	assert_bool(panel.visible).is_true()
	assert_str(panel.text).contains("65% de que el hilo lo sujete")
	assert_str(panel.text).contains("Maná: 9 → 5")
	_clic_en(posicion)
	var evento: Dictionary = _ultimo(vista, "sellado")
	assert_str(evento["objetivo"]).is_equal(mostrado["objetivo"])
	assert_int(evento["porcentaje"]).is_equal(mostrado["porcentaje"])
	var mana: Dictionary = _ultimo(vista, "mana")
	assert_int((mana["de"] as int) - (mana["a"] as int)).is_equal(mostrado["costo"])
	assert_bool(vista.eligiendo_sellar()).is_false()
	assert_dict(vista.sellado_mostrado()).is_empty()
