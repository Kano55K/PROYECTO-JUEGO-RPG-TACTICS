extends GdUnitTestSuite

# Arquitectura.md B.4 (T26), criterio 14: el boton Guardar, los botones de
# invocar, el modo "elegir casilla" (marcas de Turno.casillas_para_invocar,
# excluyente con los demas modos), el aviso de destapar en el hover y el clic
# izquierdo que invoca, con el runner de escenas de GdUnit4. Fixtures (A.6):
# escenario_guardar_invocar_combate.json (la Rodauva [4,1] junto al Maestro
# [5,1], rodauva_g guardada, balanza 2: cuesta 2), es_rasgos.json y copias
# textuales de datos/textos/es.json. Sistema.md 3.1 y 2.3.
# D-006 y D-012: el mouse se manda por MousePrueba (parse_input_event + flush), sin
# warp_mouse y sin await entre el evento y la comprobacion.
const _ESCENA: String = "res://pantalla/combate/vista_combate.tscn"
const _ESCENARIO: String = "res://pruebas/fixtures/combate/escenario_guardar_invocar_combate.json"
const _TEXTOS: String = "res://pruebas/fixtures/pantalla/es_rasgos.json"
const _MARCA_ELEGIR: Vector2i = Vector2i(5, 0)
const _CASILLA: Vector2i = Vector2i(5, 2)
# Copias textuales de datos/textos/es.json.
const _TEXTOS_T26: Dictionary = {
	"accion.guardar": "Guardar",
	"accion.invocar": "Invocar",
	"panel.mana": "Maná",
	"guardar": "{criatura} toca el pergamino y el hilo {criatura_la} recoge.",
	"guardar.tooltip": "A salvo hasta que la saques. Mientras tanto, no gana ni pierde nada.",
	"invocar": "Desenrollás el pergamino. {criatura} sale parpadeando: para {criatura_ella}, no pasó el tiempo.",
	"invocar.tooltip": "Llega en la ronda que viene.",
}


func _datos() -> Dictionary:
	var lectura: Dictionary = DatosFixture.cargar()
	assert_array(lectura["errores"]).is_empty()
	var datos: Dictionary = lectura["datos"]
	var textos: Dictionary = LectorFixture.leer(_TEXTOS, "textos")["datos"]
	textos.merge(_TEXTOS_T26, true)
	datos["textos/es.json"] = textos
	return datos


func _vista() -> GdUnitSceneRunner:
	var escenario: Dictionary = LectorFixture.leer(_ESCENARIO, "escenario")["datos"]
	var runner: GdUnitSceneRunner = scene_runner(auto_free(load(_ESCENA).instantiate()))
	(runner.scene() as VistaCombate).pausa_ia = 0.0
	MousePrueba.preparar(runner.scene() as VistaCombate)
	(runner.scene() as VistaCombate).empezar(escenario, _datos())
	return runner


func _en_pantalla(vista: VistaCombate, casilla: Vector2i) -> Vector2:
	var tablero: TileMapLayer = vista.tablero()
	return tablero.get_viewport().get_canvas_transform() * tablero.to_global(tablero.map_to_local(casilla))


func _ids_fichas(vista: VistaCombate) -> Array:
	return vista.fichas().map(func(ficha: FichaUnidad) -> String: return ficha.unidad_id)


func _sucesos(runner: GdUnitSceneRunner) -> String:
	return (runner.find_child("Sucesos") as Label).text


# (14) El boton Guardar sale solo cuando vale: junto al Maestro si; despues de
# moverse en diagonal, no. Pulsarlo la guarda: deja el tablero y sale el suceso.
func test_boton_guardar() -> void:
	var runner: GdUnitSceneRunner = _vista()
	await runner.simulate_frames(1)
	var vista: VistaCombate = runner.scene()
	assert_str(vista.combate().turno_actual().unidad_id).is_equal("rodauva_1")
	var boton: Button = runner.find_child("Guardar")
	assert_object(boton).is_not_null()
	assert_str(boton.text).is_equal("Guardar")
	assert_str(boton.tooltip_text).is_equal("A salvo hasta que la saques. Mientras tanto, no gana ni pierde nada.")
	assert_bool(vista.pulsar_guardar()).is_true()
	assert_bool(_ids_fichas(vista).has("rodauva_1")).is_false()
	assert_str(_sucesos(runner)).contains("La Rodauva toca el pergamino y el hilo la recoge.")
	assert_str(vista.combate().turno_actual().unidad_id).is_equal(Maestro.ID)
	assert_object(runner.find_child("Guardar")).is_null()


func test_sin_boton_guardar_en_diagonal() -> void:
	var runner: GdUnitSceneRunner = _vista()
	await runner.simulate_frames(1)
	var vista: VistaCombate = runner.scene()
	assert_bool(vista.clic_casilla(Vector2i(4, 2))).is_true()
	assert_object(runner.find_child("Guardar")).is_null()
	assert_bool(vista.pulsar_guardar()).is_false()


# (14) En el turno del Maestro, el boton de invocar con nombre y costo; el modo
# marca justo las casillas de la consulta y excluye a los demas modos.
func test_boton_y_modo_invocar() -> void:
	var runner: GdUnitSceneRunner = _vista()
	await runner.simulate_frames(1)
	var vista: VistaCombate = runner.scene()
	assert_object(runner.find_child("Invocar_rodauva_g")).is_null()
	assert_bool(vista.pulsar_terminar()).is_true()
	var boton: Button = runner.find_child("Invocar_rodauva_g")
	assert_object(boton).is_not_null()
	assert_str(boton.text).is_equal("Invocar Rodauva (2 Maná)")
	assert_str(boton.tooltip_text).is_equal("Llega en la ronda que viene.")
	assert_bool(boton.disabled).is_false()
	assert_bool(vista.pulsar_invocar("rodauva_g")).is_true()
	assert_str(vista.invocando()).is_equal("rodauva_g")
	var esperadas: Array[Vector2i] = vista.combate().turno_actual().casillas_para_invocar()
	assert_array(esperadas).is_not_empty()
	var marcas: TileMapLayer = runner.find_child("Marcas")
	assert_array(marcas.get_used_cells()).contains_exactly_in_any_order(esperadas)
	assert_vector(marcas.get_cell_atlas_coords(esperadas[0])).is_equal(_MARCA_ELEGIR)
	assert_bool((runner.find_child("Invocar_rodauva_g") as Button).button_pressed).is_true()
	# Los modos se excluyen: un hechizo saca del modo invocar, e invocar del hechizo.
	assert_bool(vista.pulsar_hechizo("remiendo")).is_true()
	assert_str(vista.invocando()).is_empty()
	assert_bool(vista.pulsar_invocar("rodauva_g")).is_true()
	assert_str(vista.hechizo_elegido()).is_empty()
	assert_bool(vista.pulsar_invocar("rodauva_g")).is_true()
	assert_str(vista.invocando()).is_empty()


# (14) Despues de moverse, el boton queda deshabilitado con el motivo en el
# tooltip y no entra al modo.
func test_boton_deshabilitado_con_el_motivo() -> void:
	var runner: GdUnitSceneRunner = _vista()
	await runner.simulate_frames(1)
	var vista: VistaCombate = runner.scene()
	assert_bool(vista.pulsar_terminar()).is_true()
	assert_bool(vista.clic_casilla(Vector2i(6, 1))).is_true()
	var boton: Button = runner.find_child("Invocar_rodauva_g")
	assert_bool(boton.disabled).is_true()
	assert_str(boton.tooltip_text).is_equal("Llega en la ronda que viene.\n[FALTA: aviso.invocar.ya_se_movio]")
	assert_bool(vista.pulsar_invocar("rodauva_g")).is_false()
	assert_str(vista.invocando()).is_empty()


# (14) El clic izquierdo en una casilla marcada invoca: la invocada aparece ahi,
# el mana baja el costo y sale el suceso.
func test_clic_invoca() -> void:
	var runner: GdUnitSceneRunner = _vista()
	await runner.simulate_frames(1)
	var vista: VistaCombate = runner.scene()
	assert_bool(vista.pulsar_terminar()).is_true()
	assert_bool(vista.pulsar_invocar("rodauva_g")).is_true()
	var mana_antes: int = vista.combate().instantanea()["maestro"]["mana"]
	MousePrueba.clic_en(_en_pantalla(vista, _CASILLA))
	var foto: Dictionary = vista.combate().instantanea()
	var invocada: Array = (foto["criaturas"] as Array).filter(func(c: Dictionary) -> bool: return c["id"] == "rodauva_g")
	assert_array(invocada[0]["posicion"]).is_equal([5, 2])
	assert_int(mana_antes - (foto["maestro"]["mana"] as int)).is_equal(2)
	assert_bool(_ids_fichas(vista).has("rodauva_g")).is_true()
	assert_str(vista.invocando()).is_empty()
	assert_str(_sucesos(runner)).contains("Desenrollás el pergamino. La Rodauva sale parpadeando: para ella, no pasó el tiempo.")


# (14) S-24: con el mouse sobre una casilla donde la invocada destaparia a una
# oculta, el aviso (Turno.previsualizar_invocar). El test oculta al Surcon salvaje
# y lo pone junto a [5,2] a mano: lo que se prueba es que la pantalla muestra lo
# que dice la consulta.
func test_hover_avisa_destapar() -> void:
	var runner: GdUnitSceneRunner = _vista()
	await runner.simulate_frames(1)
	var vista: VistaCombate = runner.scene()
	assert_bool(vista.pulsar_terminar()).is_true()
	var surcon: Criatura = vista.combate().contexto().plantel.criatura("surcon_s1")
	surcon.posicion = Vector2i(5, 3)
	surcon.oculta = true
	assert_bool(vista.pulsar_invocar("rodauva_g")).is_true()
	MousePrueba.mover_a(_en_pantalla(vista, _CASILLA))
	assert_str(vista.aviso_mostrado()).is_equal("Pararse acá destapa al Zancajunco, y queda a tiro de su embestida.")
	MousePrueba.mover_a(_en_pantalla(vista, Vector2i(6, 1)))
	assert_str(vista.aviso_mostrado()).is_empty()
