extends GdUnitTestSuite

# Arquitectura.md B.4 (T27), criterio 13: el boton de guardar a una caida, el
# modo "elegir caida" (excluyente con los demas), el hover (costo y vida de
# Turno.previsualizar_guardar_caida), el clic izquierdo que la guarda y el
# suceso, con el runner de escenas de GdUnit4. Fixtures (A.6):
# escenario_guardar_caida_combate.json (en la ronda 1 la Ocarra tumba a
# rodauva_1 en [3,5], a distancia 2 del Maestro [3,7]; el Zancajunco tumba a
# rodauva_2, lejos; balanza 2: cuesta 2 y el Maestro tiene 8 de mana).
# es_rasgos.json mas copias textuales de datos/textos/es.json. Sistema.md 11.5 y 2.3.
# D-006 y D-012: el mouse se manda por MousePrueba (parse_input_event + flush), sin
# warp_mouse y sin await entre el evento y la comprobacion.
const _ESCENA: String = "res://pantalla/combate/vista_combate.tscn"
const _ESCENARIO: String = "res://pruebas/fixtures/combate/escenario_guardar_caida_combate.json"
const _TEXTOS: String = "res://pruebas/fixtures/pantalla/es_rasgos.json"
const _MARCA_ELEGIR: Vector2i = Vector2i(5, 0)
const _CAIDA: String = "rodauva_1"
const _CASILLA_CAIDA: Vector2i = Vector2i(3, 5)
const _BOTON: String = "GuardarCaida"
const _TOPE_TURNOS: int = 20
# Copias textuales de datos/textos/es.json v1.3.
const _TEXTOS_T27: Dictionary = {
	"accion.guardar_caida": "Guardar a la caída",
	"panel.mana": "Maná",
	"guardar_caida": "Tendés el pergamino hacia {caida}. El hilo {caida_la} encuentra donde cayó y {caida_la} recoge.",
	"guardar_caida.tooltip": "Guardada con lo justo para respirar. No se cura hasta que salga.",
}


func _datos() -> Dictionary:
	var lectura: Dictionary = DatosFixture.cargar()
	assert_array(lectura["errores"]).is_empty()
	var datos: Dictionary = lectura["datos"]
	var textos: Dictionary = LectorFixture.leer(_TEXTOS, "textos")["datos"]
	textos.merge(_TEXTOS_T27, true)
	datos["textos/es.json"] = textos
	return datos


# maestro_en: otra casilla para el Maestro (Criatura.SIN_POSICION: la del escenario).
func _vista(maestro_en: Vector2i = Criatura.SIN_POSICION) -> GdUnitSceneRunner:
	var escenario: Dictionary = LectorFixture.leer(_ESCENARIO, "escenario")["datos"]
	if maestro_en != Criatura.SIN_POSICION:
		escenario["maestro"]["posicion"] = [maestro_en.x, maestro_en.y]
	var runner: GdUnitSceneRunner = scene_runner(auto_free(load(_ESCENA).instantiate()))
	(runner.scene() as VistaCombate).pausa_ia = 0.0
	MousePrueba.preparar(runner.scene() as VistaCombate)
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


# (13) El boton sale en el turno del Maestro con el costo; el modo marca justo
# las caidas de la consulta; los modos se excluyen; pulsarlo otra vez sale.
func test_boton_y_modo() -> void:
	var runner: GdUnitSceneRunner = _vista()
	await runner.simulate_frames(1)
	var vista: VistaCombate = runner.scene()
	_hasta_el_maestro(vista)
	var boton: Button = runner.find_child(_BOTON)
	assert_object(boton).is_not_null()
	assert_str(boton.text).is_equal("Guardar a la caída (2 Maná)")
	assert_bool(boton.disabled).is_false()
	assert_str(boton.tooltip_text).is_equal("Guardada con lo justo para respirar. No se cura hasta que salga.")

	assert_bool(vista.pulsar_guardar_caida()).is_true()
	assert_bool(vista.eligiendo_caida()).is_true()
	assert_array(vista.combate().turno_actual().objetivos_para_guardar_caida()).is_equal([_CAIDA])
	var marcas: TileMapLayer = runner.find_child("Marcas")
	assert_array(marcas.get_used_cells()).is_equal([_CASILLA_CAIDA])
	assert_vector(marcas.get_cell_atlas_coords(_CASILLA_CAIDA)).is_equal(_MARCA_ELEGIR)
	assert_bool((runner.find_child(_BOTON) as Button).button_pressed).is_true()
	# Los modos se excluyen: un hechizo saca del modo, y el modo saca del hechizo.
	assert_bool(vista.pulsar_hechizo("remiendo")).is_true()
	assert_bool(vista.eligiendo_caida()).is_false()
	assert_bool(vista.pulsar_guardar_caida()).is_true()
	assert_str(vista.hechizo_elegido()).is_empty()
	assert_bool(vista.pulsar_guardar_caida()).is_true()
	assert_bool(vista.eligiendo_caida()).is_false()


# (13) Con el Maestro lejos, el boton esta deshabilitado, el tooltip suma el
# motivo de Turno.motivo_guardar_caida y pulsarlo no entra al modo.
func test_boton_deshabilitado_con_el_motivo() -> void:
	var runner: GdUnitSceneRunner = _vista(Vector2i(7, 7))
	await runner.simulate_frames(1)
	var vista: VistaCombate = runner.scene()
	_hasta_el_maestro(vista)
	assert_int(vista.combate().turno_actual().motivo_guardar_caida()) \
			.is_equal(ResultadoAccion.Motivo.FUERA_DE_ALCANCE)
	var boton: Button = runner.find_child(_BOTON)
	assert_bool(boton.disabled).is_true()
	assert_str(boton.tooltip_text).ends_with("[FALTA: aviso.guardar_caida.fuera_de_alcance]")
	assert_bool(vista.pulsar_guardar_caida()).is_false()
	assert_bool(vista.eligiendo_caida()).is_false()


# (13) En el modo, el hover sobre la caida muestra el costo y la vida de
# previsualizar_guardar_caida; el clic izquierdo la guarda (el evento lleva esa
# vida y el mana baja ese costo) y el suceso lo dice.
func test_hover_clic_y_suceso() -> void:
	var runner: GdUnitSceneRunner = _vista()
	await runner.simulate_frames(1)
	var vista: VistaCombate = runner.scene()
	_hasta_el_maestro(vista)
	assert_bool(vista.pulsar_guardar_caida()).is_true()
	var posicion: Vector2 = _en_pantalla(vista, _CASILLA_CAIDA)
	MousePrueba.mover_a(posicion)
	var mostrado: Dictionary = vista.guardado_caida_mostrado()
	assert_dict(mostrado).is_equal({"objetivo": _CAIDA, "costo": 2, "vida": {"de": 0, "a": 1}})
	var panel: Label = runner.find_child("PanelDesglose")
	assert_bool(panel.visible).is_true()
	assert_str(panel.text).contains("Maná: 8 → 6")
	assert_str(panel.text).contains("Vida: 0 → 1")
	MousePrueba.clic_en(posicion)
	var evento: Dictionary = _ultimo(vista, "guardado_caida")
	assert_str(evento["unidad"]).is_equal(mostrado["objetivo"])
	assert_int(evento["vida"]).is_equal(mostrado["vida"]["a"])
	var mana: Dictionary = _ultimo(vista, "mana")
	assert_str(mana["motivo"]).is_equal("guardar_caida")
	assert_int((mana["de"] as int) - (mana["a"] as int)).is_equal(mostrado["costo"])
	assert_bool(vista.eligiendo_caida()).is_false()
	assert_dict(vista.guardado_caida_mostrado()).is_empty()
	assert_str((runner.find_child("Sucesos") as Label).text) \
			.contains("Tendés el pergamino hacia la Rodauva. El hilo la encuentra donde cayó y la recoge.")
	# Gasto la accion y no el movimiento: el boton queda deshabilitado y el Maestro todavia se mueve.
	assert_bool((runner.find_child(_BOTON) as Button).disabled).is_true()
	assert_bool(vista.combate().turno_actual().casillas_para_mover().is_empty()).is_false()
