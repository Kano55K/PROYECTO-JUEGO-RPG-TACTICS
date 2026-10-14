extends GdUnitTestSuite

# T30-fix, con datos/ real (A.6) y el runner de escenas de GdUnit4: G jugado
# hasta tumbar a la Ocarra (JugadorG) y el clic en "Sellar de nuevo". Si sale, la
# pantalla de resultado muestra el nuevo sello (nocturno.sellar), la Ocarra
# guardada, la lealtad final y Volver. Si falla, la linea del fallo (sellar.fallo),
# el mana ya descontado, la Ocarra caida y quedan Perdonar y Comer (Sistema.md 4.4).
# Las semillas se buscan en el nucleo (la primera que sale y la primera que
# falla): ninguna escrita a mano. Textos de datos/textos/es.json.
# D-006 y D-012: el mouse sale solo de MousePrueba.
const _CARPETA_DATOS: String = "res://datos"
const _ESCENA: String = "res://pantalla/combate/vista_combate.tscn"
const _TOPE_SEMILLAS: int = 50
# Mundo.md 4.6 y la variante de la Ocarra de sellar.fallo, copiadas de es.json.
const _TEXTO_SELLAR: String = "Su pergamino ya es ceniza. Desenrollás uno en blanco y el hilo la recoge, más corto que antes."
const _TEXTO_FALLO: String = "La Ocarra se sacude el hilo como si fuera agua y te grazna."
const _TEXTO_BOTON: String = "Sellar de nuevo (%d Maná · %d%%)"

var _datos: Dictionary = {}


func _cargar() -> Dictionary:
	if _datos.is_empty():
		var carga: Dictionary = Cargador.new().cargar_carpeta(_CARPETA_DATOS)
		assert_array(carga["errores"]).override_failure_message(str(carga["errores"])).is_empty()
		_datos = carga["datos"]
	return _datos


func _escenario(semilla: int) -> Dictionary:
	var escenario: Dictionary = (_cargar()[JugadorG.ESCENARIO] as Dictionary).duplicate(true)
	escenario["semilla"] = semilla
	return escenario


# La primera semilla de 1 a _TOPE_SEMILLAS con la que el resellado da ese
# resultado, jugando G en el nucleo con JugadorG.
func _semilla_con(resultado: String) -> int:
	for semilla in range(1, _TOPE_SEMILLAS + 1):
		var combate: Combate = Combate.empezar(ContextoCombate.armar(_escenario(semilla), _cargar()))
		assert_str(JugadorG.hasta_el_destino(combate)).is_empty()
		combate.aplicar(Accion.destino_atacante(DestinoAtacante.OPCION_SELLAR))
		var ultimo: Dictionary = {}
		for linea in combate.registro().lineas():
			if linea["tipo"] == "destino_atacante":
				ultimo = linea
		if ultimo["resultado"] == resultado:
			return semilla
	fail("ninguna semilla da " + resultado)
	return -1


# La vista con G y esa semilla, jugada hasta el destino sobre su combate.
func _vista_en_el_destino(semilla: int) -> GdUnitSceneRunner:
	var runner: GdUnitSceneRunner = scene_runner(auto_free(load(_ESCENA).instantiate()))
	var vista: VistaCombate = runner.scene()
	vista.pausa_ia = 0.0
	MousePrueba.preparar(vista)
	vista.empezar(_escenario(semilla), _cargar(), [], create_temp_dir("t30_fix_%d" % semilla))
	assert_str(JugadorG.hasta_el_destino(vista.combate())).is_empty()
	vista.redibujar()
	return runner


func _texto(runner: GdUnitSceneRunner) -> String:
	return (runner.find_child("TextoResultado") as Label).text


func _linea_ocarra(texto: String) -> String:
	for linea in texto.split("\n"):
		if linea.begins_with("Ocarra · "):
			return linea
	return ""


func _botones_destino(runner: GdUnitSceneRunner) -> Array[String]:
	var nombres: Array[String] = []
	for hijo in (runner.find_child("BotonesDestino") as Control).get_children():
		if not hijo.is_queued_for_deletion():
			nombres.append(hijo.name)
	return nombres


# El boton muestra el costo y el % de previsualizar_destino, y el clic lo aplica.
func _pulsar_sellar(runner: GdUnitSceneRunner) -> ResultadoAccion:
	var vista: VistaCombate = runner.scene()
	var previa: ResultadoAccion = vista.combate().previsualizar_destino(DestinoAtacante.OPCION_SELLAR)
	var boton: Button = runner.find_child("Destino_sellar")
	assert_str(boton.text).is_equal(_TEXTO_BOTON % [previa.costo, previa.porcentaje])
	MousePrueba.clic_en(boton.get_global_rect().get_center())
	return previa


func test_resellado_que_sale_se_ve_entero() -> void:
	var runner: GdUnitSceneRunner = _vista_en_el_destino(_semilla_con(DestinoAtacante.RESULTADO_SELLADA))
	await runner.simulate_frames(2)
	var vista: VistaCombate = runner.scene()
	_pulsar_sellar(runner)
	await runner.simulate_frames(1)
	assert_bool(vista.combate().esperando_destino()).is_false()
	var texto: String = _texto(runner)
	assert_str(texto).contains(_TEXTO_SELLAR)
	assert_str(_linea_ocarra(texto)).contains("Guardada")
	assert_str(texto).contains("Lealtad")
	# rodauva_1, leal de 8: +1 de la victoria; sellar no anota (Sistema.md 9.3).
	assert_str(texto).contains("Rodauva: 8 → 9")
	assert_array(_botones_destino(runner)).is_empty()
	assert_bool((runner.find_child("BotonVolver") as Button).visible).is_true()


func test_resellado_que_falla_se_ve_con_el_mana() -> void:
	var runner: GdUnitSceneRunner = _vista_en_el_destino(_semilla_con(DestinoAtacante.RESULTADO_SELLADO_FALLIDO))
	await runner.simulate_frames(2)
	var vista: VistaCombate = runner.scene()
	var previa: ResultadoAccion = _pulsar_sellar(runner)
	await runner.simulate_frames(1)
	assert_bool(vista.combate().esperando_destino()).is_true()
	var texto: String = _texto(runner)
	assert_str(texto).contains(_TEXTO_FALLO)
	assert_str(texto).contains("Maná: %d" % previa.mana["a"])
	assert_int(vista.combate().contexto().plantel.maestro.mana).is_equal(previa.mana["a"])
	assert_str(_linea_ocarra(texto)).contains("Caída")
	# Sistema.md 4.4: quedan perdonar y comer.
	assert_array(_botones_destino(runner)).is_equal(["Destino_perdonar", "Destino_comer"])
	assert_bool(vista.pulsar_destino(DestinoAtacante.OPCION_SELLAR)).is_false()
	assert_bool((runner.find_child("BotonVolver") as Button).visible).is_false()
