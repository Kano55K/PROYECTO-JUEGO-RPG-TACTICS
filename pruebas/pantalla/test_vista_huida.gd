extends GdUnitTestSuite

# Arquitectura.md B.4 (T25), criterio 10: el % de huida sobre la unidad en la
# vista (marca de la ficha y tooltip) es el de Combate.porcentaje_huida y el
# `porcentaje` del evento `huida` cuando le toca; sin marca con 0 %. Con el
# runner de escenas de GdUnit4. Fixtures (A.6): escenario_huida_pantalla.json (el
# Surcon salvaje, 5 de 24: 25 %, juega ultimo en la ronda 1; la Ocarra salvaje,
# 0 %) y es_rasgos.json. Los textos de la marca y del tooltip no existen en
# es.json: los de aca son de prueba. Sistema.md 11.7.
# D-006 y D-012: el mouse se manda por MousePrueba (parse_input_event + flush), sin
# warp_mouse y sin await entre el evento y la comprobacion.
const _ESCENA: String = "res://pantalla/combate/vista_combate.tscn"
const _ESCENARIO: String = "res://pruebas/fixtures/pantalla/escenario_huida_pantalla.json"
const _TEXTOS: String = "res://pruebas/fixtures/pantalla/es_rasgos.json"
const _SURCON: String = "surcon_s1"
const _OCARRA: String = "ocarra_s1"
const _CASILLA_SURCON: Vector2i = Vector2i(0, 0)
# Textos de prueba de las claves propuestas (no estan en es.json).
const _TEXTOS_PRUEBA: Dictionary = {
	"marca.huida": "Huida",
	"huida.salvaje.porcentaje": "{porcentaje}% de que se vaya",
}


func _datos() -> Dictionary:
	var lectura: Dictionary = DatosFixture.cargar()
	assert_array(lectura["errores"]).is_empty()
	var datos: Dictionary = lectura["datos"]
	var textos: Dictionary = LectorFixture.leer(_TEXTOS, "textos")["datos"]
	textos.merge(_TEXTOS_PRUEBA, true)
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


func _ficha(vista: VistaCombate, unidad_id: String) -> FichaUnidad:
	for ficha in vista.fichas():
		if ficha.unidad_id == unidad_id:
			return ficha
	return null


func _huidas(vista: VistaCombate) -> Array[Dictionary]:
	var lista: Array[Dictionary] = []
	for linea in vista.combate().registro().lineas():
		if linea["tipo"] == "huida":
			lista.append(linea)
	return lista


# (10) Antes del turno del Surcon: su ficha y su tooltip muestran el 25 % de
# porcentaje_huida; la Ocarra (0 %), no. Cuando le toca, el evento `huida`
# lleva ese mismo %.
func test_porcentaje_sobre_la_unidad_igual_al_evento() -> void:
	var runner: GdUnitSceneRunner = _vista()
	await runner.simulate_frames(1)
	var vista: VistaCombate = runner.scene()
	assert_array(_huidas(vista)).is_empty()
	var porcentaje: int = vista.combate().porcentaje_huida(_SURCON)
	assert_int(porcentaje).is_equal(25)
	assert_str(_ficha(vista, _SURCON).texto_marcas()).contains("Huida %d%%" % porcentaje)
	assert_str(_ficha(vista, _OCARRA).texto_marcas()).not_contains("Huida")
	assert_str(_ficha(vista, "rodauva_1").texto_marcas()).not_contains("Huida")
	MousePrueba.mover_a(_en_pantalla(vista, _CASILLA_SURCON))
	assert_array(vista.tooltip_mostrado()).contains(["%d%% de que se vaya" % porcentaje])
	# La Rodauva y el Maestro terminan: juega el Surcon y tira.
	assert_bool(vista.pulsar_terminar()).is_true()
	assert_bool(vista.pulsar_terminar()).is_true()
	var huidas: Array[Dictionary] = _huidas(vista)
	assert_int(huidas.size()).is_equal(1)
	assert_str(huidas[0]["unidad"]).is_equal(_SURCON)
	assert_int(huidas[0]["porcentaje"]).is_equal(porcentaje)
