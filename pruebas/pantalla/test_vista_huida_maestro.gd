extends GdUnitTestSuite

# Arquitectura.md B.4 (T28), criterio 10: el boton Huir en la vista, con el
# runner de escenas de GdUnit4. Con el mouse sobre el boton, el panel muestra
# Combate.previsualizar_huida y se marcan las enemigas que alcanzan al Maestro;
# el clic declara; despues, la marca en el Maestro; al cerrar la ronda, el
# resultado dice huida. Fixtures (A.6): escenario_huida_maestro_combate.json
# (Velocidad del Maestro subida en memoria a 9: juega primero; el Tasajero en
# [2,1] y el Surcon en [2,9] lo alcanzan, la Ocarra en [9,1] no), es_rasgos.json
# y textos de prueba para las claves propuestas. Sistema.md 11.7.
# D-006 y D-012: el mouse se manda por MousePrueba (parse_input_event + flush), sin
# warp_mouse y sin await entre el evento y la comprobacion.
const _ESCENA: String = "res://pantalla/combate/vista_combate.tscn"
const _ESCENARIO: String = "res://pruebas/fixtures/combate/escenario_huida_maestro_combate.json"
const _TEXTOS: String = "res://pruebas/fixtures/pantalla/es_rasgos.json"
const _VELOCIDAD_MAESTRO: int = 9
const _BOTON: String = "Huir"
const _CASILLA_TASAJERO: Vector2i = Vector2i(2, 1)
const _CASILLA_SURCON: Vector2i = Vector2i(2, 9)
const _MARCA_ALCANZA: Vector2i = Vector2i(1, 0)
const _TOPE_TURNOS: int = 10
# Copias textuales de datos/textos/es.json (los botones del Maestro: con las
# claves faltantes, el texto [FALTA: ...] deja el boton Huir fuera de la ventana)
# y textos de prueba de las claves propuestas (marca.huida_declarada y
# huida.previa.alcanzan, copia de es.json desde T30, Mundo.md 1.5 v1.4).
const _TEXTOS_T28: Dictionary = {
	"accion.sellar": "Sellar",
	"accion.invocar": "Invocar",
	"accion.guardar_caida": "Guardar a la caída",
	"accion.esperar": "Esperar",
	"hechizo.martillazo.nombre": "Martillazo",
	"hechizo.lanzadera.nombre": "Lanzadera",
	"hechizo.remiendo.nombre": "Remiendo",
	"panel.mana": "Maná",
	"accion.huir": "Huir",
	"huida.maestro.declarar": "Retrocedés. Hasta que salgas del claro, todavía te pueden alcanzar.",
	"marca.huida_declarada": "Se va",
	"huida.previa.alcanzan": "Te pueden alcanzar. En el peor caso, {n} de daño.",
}


func _datos() -> Dictionary:
	var lectura: Dictionary = DatosFixture.cargar()
	assert_array(lectura["errores"]).is_empty()
	var datos: Dictionary = lectura["datos"]
	datos["maestro.json"]["velocidad"] = _VELOCIDAD_MAESTRO
	var textos: Dictionary = LectorFixture.leer(_TEXTOS, "textos")["datos"]
	textos.merge(_TEXTOS_T28, true)
	datos["textos/es.json"] = textos
	return datos


func _vista() -> GdUnitSceneRunner:
	var escenario: Dictionary = LectorFixture.leer(_ESCENARIO, "escenario")["datos"]
	var runner: GdUnitSceneRunner = scene_runner(auto_free(load(_ESCENA).instantiate()))
	(runner.scene() as VistaCombate).pausa_ia = 0.0
	MousePrueba.preparar(runner.scene() as VistaCombate)
	(runner.scene() as VistaCombate).empezar(escenario, _datos())
	return runner


func _centro(boton: Button) -> Vector2:
	return boton.get_global_rect().get_center()


func _en_pantalla(vista: VistaCombate, casilla: Vector2i) -> Vector2:
	var tablero: TileMapLayer = vista.tablero()
	return tablero.get_viewport().get_canvas_transform() * tablero.to_global(tablero.map_to_local(casilla))


func _ficha(vista: VistaCombate, unidad_id: String) -> FichaUnidad:
	for ficha in vista.fichas():
		if ficha.unidad_id == unidad_id:
			return ficha
	return null


# (10) El boton sale habilitado en el turno del Maestro; con el mouse encima, el
# panel muestra la previsualizacion del nucleo y se marcan el Tasajero y el
# Surcon (la Ocarra no lo alcanza). Al sacar el mouse del boton, se borra.
func test_mouse_sobre_el_boton_muestra_la_previsualizacion() -> void:
	var runner: GdUnitSceneRunner = _vista()
	await runner.simulate_frames(2)
	var vista: VistaCombate = runner.scene()
	assert_str(vista.combate().turno_actual().unidad_id).is_equal(Maestro.ID)
	var boton: Button = runner.find_child(_BOTON)
	assert_object(boton).is_not_null()
	assert_str(boton.text).is_equal("Huir")
	assert_bool(boton.disabled).is_false()

	MousePrueba.mover_a(_centro(boton))
	assert_dict(vista.huida_mostrada()).is_equal(vista.combate().previsualizar_huida())
	assert_array(vista.casillas_alcanzan_huida()).contains_exactly_in_any_order([_CASILLA_TASAJERO, _CASILLA_SURCON])
	var capa: TileMapLayer = runner.find_child("AlcanzanHuida")
	assert_vector(capa.get_cell_atlas_coords(_CASILLA_TASAJERO)).is_equal(_MARCA_ALCANZA)
	var panel: Label = runner.find_child("PanelDesglose")
	assert_bool(panel.visible).is_true()
	# Reescrito en T30 (Mundo.md 1.5 v1.4): la clave del Worldbuilder, con {n}.
	assert_str(panel.text).contains("Te pueden alcanzar. En el peor caso, 13 de daño.")

	MousePrueba.mover_a(_en_pantalla(vista, Vector2i(6, 6)))
	assert_dict(vista.huida_mostrada()).is_empty()
	assert_array(vista.casillas_alcanzan_huida()).is_empty()
	assert_bool(panel.visible).is_false()


# (10) Despues de moverse, el boton queda deshabilitado con el motivo en el
# tooltip (clave propuesta: falta en es.json) y pulsarlo no declara.
func test_boton_deshabilitado_despues_de_mover() -> void:
	var runner: GdUnitSceneRunner = _vista()
	await runner.simulate_frames(2)
	var vista: VistaCombate = runner.scene()
	assert_bool(vista.clic_casilla(Vector2i(2, 7))).is_true()
	var boton: Button = runner.find_child(_BOTON)
	assert_bool(boton.disabled).is_true()
	assert_str(boton.tooltip_text).is_equal("[FALTA: aviso.huir.ya_se_movio]")
	assert_bool(vista.pulsar_huir()).is_false()
	assert_bool(vista.combate().instantanea()["maestro"]["huida_declarada"]).is_false()


# (10) El clic en el boton declara: la marca sale en el Maestro, el boton se va y
# el suceso lo dice. Al cerrar la ronda, la pantalla de resultado muestra el
# desenlace huida (clave propuesta: falta en es.json).
func test_clic_declara_y_resultado() -> void:
	var runner: GdUnitSceneRunner = _vista()
	await runner.simulate_frames(2)
	var vista: VistaCombate = runner.scene()
	var boton: Button = runner.find_child(_BOTON)
	MousePrueba.clic_en(_centro(boton))
	await runner.simulate_frames(1)
	assert_bool(vista.combate().instantanea()["maestro"]["huida_declarada"]).is_true()
	assert_object(runner.find_child(_BOTON)).is_null()
	assert_str(_ficha(vista, Maestro.ID).texto_marcas()).contains("Se va")
	assert_str((runner.find_child("Sucesos") as Label).text) \
			.contains("Retrocedés. Hasta que salgas del claro, todavía te pueden alcanzar.")

	for _i in range(_TOPE_TURNOS):
		if vista.combate().terminado():
			break
		assert_bool(vista.pulsar_terminar()).is_true()
	assert_int(vista.combate().fin()).is_equal(FinCombate.Fin.HUIDA)
	var resultado: Control = runner.find_child("PantallaResultado")
	assert_bool(resultado.visible).is_true()
	assert_str((runner.find_child("TextoResultado") as Label).text).contains("[FALTA: resultado.desenlace.huida]")
