extends GdUnitTestSuite

# Arquitectura.md B.4 (T29), criterio 9, con el runner de escenas de GdUnit4: la
# linea fija y la marca de quien rescataria (Combate.rescatista_ahora) en la
# vista, que cambian al redibujar; la pantalla de resultado con la rescatista; y
# la botonera (HFlowContainer), que no deja ningun boton del Maestro fuera de la
# ventana de 1152 px aunque los textos sean [FALTA]. Fixtures (A.6):
# escenario_rescate_combate.json, escenario_huida_maestro_combate.json (con la
# Velocidad del Maestro subida en memoria a 9, como T28: todos sus botones, con
# una caida y una guardada), es_rasgos.json y textos de prueba de las claves
# propuestas. Sistema.md 6.
# D-006 y D-012: ningun test manda mouse por su cuenta (MousePrueba.preparar).
const _ESCENA: String = "res://pantalla/combate/vista_combate.tscn"
const _ESCENARIO_RESCATE: String = "res://pruebas/fixtures/combate/escenario_rescate_combate.json"
const _ESCENARIO_BOTONES: String = "res://pruebas/fixtures/combate/escenario_huida_maestro_combate.json"
const _TEXTOS: String = "res://pruebas/fixtures/pantalla/es_rasgos.json"
const _VELOCIDAD_MAESTRO: int = 9
const _ANCHO_VENTANA: float = 1152.0
const _LEAL: String = "zancajunco_1"
const _TOPE_TURNOS: int = 10
# Textos de prueba de las claves propuestas.
const _TEXTOS_PRUEBA: Dictionary = {
	"panel.rescatista": "Te rescataría",
	"panel.sin_rescatista": "Nadie te rescataría",
	"marca.rescatista": "Te rescata",
	"resultado.rescatista": "Te rescató",
}


func _vista(escenario_ruta: String, textos_extra: Dictionary, velocidad_maestro: int = 0) -> GdUnitSceneRunner:
	var lectura: Dictionary = DatosFixture.cargar()
	assert_array(lectura["errores"]).is_empty()
	var datos: Dictionary = lectura["datos"]
	if velocidad_maestro > 0:
		datos["maestro.json"]["velocidad"] = velocidad_maestro
	var textos: Dictionary = LectorFixture.leer(_TEXTOS, "textos")["datos"]
	textos.merge(textos_extra, true)
	datos["textos/es.json"] = textos
	var escenario: Dictionary = LectorFixture.leer(escenario_ruta, "escenario")["datos"]
	var runner: GdUnitSceneRunner = scene_runner(auto_free(load(_ESCENA).instantiate()))
	(runner.scene() as VistaCombate).pausa_ia = 0.0
	MousePrueba.preparar(runner.scene() as VistaCombate)
	(runner.scene() as VistaCombate).empezar(escenario, datos)
	return runner


func _ficha(vista: VistaCombate, unidad_id: String) -> FichaUnidad:
	for ficha in vista.fichas():
		if ficha.unidad_id == unidad_id:
			return ficha
	return null


# (9) Al empezar, el panel dice quien rescataria y su ficha lleva la marca. Al
# terminar (la Ocarra remata al Maestro), el resultado nombra a la rescatista.
func test_linea_marca_y_resultado() -> void:
	var runner: GdUnitSceneRunner = _vista(_ESCENARIO_RESCATE, _TEXTOS_PRUEBA)
	await runner.simulate_frames(2)
	var vista: VistaCombate = runner.scene()
	var panel: Label = runner.find_child("PanelTurno")
	assert_str(panel.text).contains("Te rescataría: Zancajunco")
	assert_str(_ficha(vista, _LEAL).texto_marcas()).contains("Te rescata")
	for _i in range(_TOPE_TURNOS):
		if vista.combate().terminado():
			break
		assert_bool(vista.pulsar_terminar()).is_true()
	assert_int(vista.combate().fin()).is_equal(FinCombate.Fin.DERROTA_POR_CAIDA)
	assert_bool((runner.find_child("PantallaResultado") as Control).visible).is_true()
	assert_str((runner.find_child("TextoResultado") as Label).text).contains("Te rescató: Zancajunco")


# (9) La linea y la marca se rearman desde el nucleo: la leal baja a 6 y, al
# redibujar, nadie rescata.
func test_cambia_al_redibujar() -> void:
	var runner: GdUnitSceneRunner = _vista(_ESCENARIO_RESCATE, _TEXTOS_PRUEBA)
	await runner.simulate_frames(2)
	var vista: VistaCombate = runner.scene()
	vista.combate().contexto().plantel.criatura(_LEAL).lealtad = 6
	vista.redibujar()
	assert_str((runner.find_child("PanelTurno") as Label).text).contains("Nadie te rescataría")
	assert_str(_ficha(vista, _LEAL).texto_marcas()).not_contains("Te rescata")


# (9) Botonera: en el turno del Maestro, con todos sus botones (hechizos, Sellar,
# guardar a la caida, Huir, invocar a la guardada, Esperar) y los textos en
# [FALTA], ningun boton queda fuera de la ventana de 1152 px.
func test_botonera_entra_en_la_ventana() -> void:
	var runner: GdUnitSceneRunner = _vista(_ESCENARIO_BOTONES, {}, _VELOCIDAD_MAESTRO)
	await runner.simulate_frames(2)
	var vista: VistaCombate = runner.scene()
	assert_str(vista.combate().turno_actual().unidad_id).is_equal(Maestro.ID)
	var botones: Control = runner.find_child("Botones")
	assert_object(botones).is_instanceof(HFlowContainer)
	var ventana: Rect2 = vista.get_viewport_rect()
	assert_float(ventana.size.x).is_equal(_ANCHO_VENTANA)
	var nombres: Array[String] = []
	for hijo in botones.get_children():
		var boton: Button = hijo as Button
		if boton == null or not boton.visible:
			continue
		nombres.append(boton.name)
		assert_bool(ventana.encloses(boton.get_global_rect())) \
				.override_failure_message("%s fuera: %s" % [boton.name, boton.get_global_rect()]).is_true()
	assert_str((runner.find_child("Huir") as Button).text).is_equal("[FALTA: accion.huir]")
	assert_array(nombres).contains(["Hechizo_martillazo", "Sellar", "GuardarCaida", "Huir", "Invocar_rodauva_g",
			"BotonTerminar"])
