extends GdUnitTestSuite

# Arquitectura.md B.4 (T30, sesion 3), criterio 15, con el runner de escenas de
# GdUnit4: el golpe inicial en los sucesos y la pantalla de resultado con la
# atacante pendiente: los botones Destino_<opcion> (LecturaCombate.botones_destino),
# sin Volver ni grabacion guardada hasta elegir; el clic en un boton aplica el
# destino; tras un fallo de sellar quedan perdonar y comer. Fixtures (A.6):
# escenario_nocturno_combate.json (MesaNocturno), escenario_destino_combate.json
# (MesaDestino; semilla 26: el resellado falla), es_rasgos.json y textos de
# prueba de las claves nocturno.*. Sistema.md 9.2, 9.3 y 4.4.
# D-006 y D-012: el mouse sale solo de MousePrueba.
const _ESCENA: String = "res://pantalla/combate/vista_combate.tscn"
const _TEXTOS: String = "res://pruebas/fixtures/pantalla/es_rasgos.json"
const _TEXTOS_PRUEBA: Dictionary = {
	"nocturno.base": "Despiertas: {criatura} encima.",
	"nocturno.base.ocarra": "No grazna.",
	"nocturno.atacante.caida": "{criatura} cae y espera.",
	"nocturno.boton.perdonar": "Perdonar",
	"nocturno.boton.sellar": "Sellar de nuevo",
	"nocturno.boton.comer": "Comer",
	"nocturno.perdonar": "Perdonas a {criatura}.",
	"nocturno.perdonar.tribu": "La tribu duerme cerca.",
	"nocturno.perdonar.tooltip": "Se va libre.",
	"nocturno.sellar.tooltip": "Vuelve sin confianza.",
	"nocturno.comer.tooltip": "Te da de comer.",
	"resultado.volver": "Volver",
}


func _vista(escenario: Dictionary, carpeta: String = "") -> GdUnitSceneRunner:
	var lectura: Dictionary = DatosFixture.cargar()
	assert_array(lectura["errores"]).is_empty()
	var datos: Dictionary = lectura["datos"]
	var textos: Dictionary = LectorFixture.leer(_TEXTOS, "textos")["datos"]
	textos.merge(_TEXTOS_PRUEBA, true)
	datos["textos/es.json"] = textos
	var runner: GdUnitSceneRunner = scene_runner(auto_free(load(_ESCENA).instantiate()))
	(runner.scene() as VistaCombate).pausa_ia = 0.0
	MousePrueba.preparar(runner.scene() as VistaCombate)
	(runner.scene() as VistaCombate).empezar(escenario, datos, [], carpeta)
	return runner


func _centro(boton: Button) -> Vector2:
	return boton.get_global_rect().get_center()


func _botones_destino(runner: GdUnitSceneRunner) -> Array[String]:
	var nombres: Array[String] = []
	for hijo in (runner.find_child("BotonesDestino") as Control).get_children():
		if not hijo.is_queued_for_deletion():
			nombres.append(hijo.name)
	return nombres


func _guardados(carpeta: String) -> Array:
	return Array(DirAccess.get_files_at(carpeta)).filter(func(archivo: String) -> bool:
		return archivo.ends_with(".jsonl"))


# (15) Antes del primer turno, los sucesos muestran el golpe inicial.
func test_golpe_inicial_en_los_sucesos() -> void:
	var runner: GdUnitSceneRunner = _vista(MesaNocturno.escenario())
	await runner.simulate_frames(2)
	var sucesos: String = (runner.find_child("Sucesos") as Label).text
	assert_str(sucesos).contains("Despiertas: la Ocarra encima.")
	assert_str(sucesos).contains("No grazna.")


# (15) Victoria con la atacante caida: el resultado se ve con los tres botones y
# sus tooltips, sin Volver, y la grabacion todavia no se guardo.
func test_pantalla_de_resultado_con_la_atacante_pendiente() -> void:
	var carpeta: String = create_temp_dir("t30_pendiente")
	var runner: GdUnitSceneRunner = _vista(MesaDestino.escenario(), carpeta)
	await runner.simulate_frames(2)
	var vista: VistaCombate = runner.scene()
	assert_bool(vista.combate().esperando_destino()).is_true()
	assert_bool((runner.find_child("PantallaResultado") as Control).visible).is_true()
	assert_array(_botones_destino(runner)).is_equal(["Destino_perdonar", "Destino_sellar", "Destino_comer"])
	assert_str((runner.find_child("Destino_perdonar") as Button).tooltip_text).is_equal("Se va libre.")
	assert_str((runner.find_child("Destino_sellar") as Button).text).starts_with("Sellar de nuevo (")
	assert_bool((runner.find_child("BotonVolver") as Button).visible).is_false()
	assert_str((runner.find_child("TextoResultado") as Label).text).contains("La Ocarra cae y espera.")
	assert_array(_guardados(carpeta)).is_empty()


# (15) El clic en Perdonar aplica el destino: sin botones, Volver visible, las
# lineas de Mundo.md 4.6 en el resultado y la grabacion guardada una vez, con la
# accion del destino.
func test_clic_en_perdonar() -> void:
	var carpeta: String = create_temp_dir("t30_perdonar")
	var runner: GdUnitSceneRunner = _vista(MesaDestino.escenario(), carpeta)
	await runner.simulate_frames(2)
	var vista: VistaCombate = runner.scene()
	MousePrueba.clic_en(_centro(runner.find_child("Destino_perdonar") as Button))
	await runner.simulate_frames(1)
	assert_bool(vista.combate().esperando_destino()).is_false()
	assert_array(_botones_destino(runner)).is_empty()
	assert_bool((runner.find_child("BotonVolver") as Button).visible).is_true()
	var texto: String = (runner.find_child("TextoResultado") as Label).text
	assert_str(texto).contains("Perdonas a la Ocarra.")
	assert_str(texto).contains("La tribu duerme cerca.")
	assert_array(_guardados(carpeta)).has_size(1)
	var grabacion: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(
			carpeta.path_join(_guardados(carpeta)[0].replace(".jsonl", ".json"))))
	var ultima: Dictionary = (grabacion["acciones"] as Array).back()
	assert_str(ultima["accion"]["tipo"]).is_equal("destino_atacante")


# (15) Sistema.md 4.4: el resellado falla (semilla 26) y quedan perdonar y comer.
func test_clic_en_sellar_que_falla() -> void:
	var escenario: Dictionary = MesaDestino.escenario()
	escenario["semilla"] = MesaDestino.SEMILLA_FALLA
	var runner: GdUnitSceneRunner = _vista(escenario)
	await runner.simulate_frames(2)
	var vista: VistaCombate = runner.scene()
	MousePrueba.clic_en(_centro(runner.find_child("Destino_sellar") as Button))
	await runner.simulate_frames(1)
	assert_bool(vista.combate().esperando_destino()).is_true()
	assert_array(_botones_destino(runner)).is_equal(["Destino_perdonar", "Destino_comer"])
	assert_bool(vista.pulsar_destino("sellar")).is_false()
	assert_bool(vista.pulsar_destino("comer")).is_true()
	assert_bool(vista.combate().esperando_destino()).is_false()
