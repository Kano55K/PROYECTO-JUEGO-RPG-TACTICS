extends GdUnitTestSuite

# T33, sesion 3, criterio (10), con el runner de escenas de GdUnit4: la vista
# guarda la ficha de playtest (D-015) junto al resultado, con la variante sin la
# semilla y el jugador que recibe en empezar. En G (fixture escenario_destino_
# combate.json, MesaDestino), recien despues de elegir el destino de la
# atacante. Las semillas de playtest las pone el test en los datos.
const _ESCENA: String = "res://pantalla/combate/vista_combate.tscn"
const _TEXTOS: String = "res://pruebas/fixtures/pantalla/es_rasgos.json"


func _vista(escenario: Dictionary, carpeta: String, variante: Dictionary, jugador: Variant,
		semillas: Array) -> GdUnitSceneRunner:
	var lectura: Dictionary = DatosFixture.cargar()
	assert_array(lectura["errores"]).is_empty()
	var datos: Dictionary = lectura["datos"]
	datos["textos/es.json"] = LectorFixture.leer(_TEXTOS, "textos")["datos"]
	datos[AlarmasPlaytest.ARCHIVO] = {"semillas": semillas}
	var runner: GdUnitSceneRunner = scene_runner(auto_free(load(_ESCENA).instantiate()))
	(runner.scene() as VistaCombate).pausa_ia = 0.0
	MousePrueba.preparar(runner.scene() as VistaCombate)
	(runner.scene() as VistaCombate).empezar(escenario, datos, [], carpeta, not variante.is_empty(), variante,
			jugador)
	return runner


func _fichas(carpeta: String) -> Array:
	return Array(DirAccess.get_files_at(carpeta)).filter(func(archivo: String) -> bool:
		return archivo.ends_with(GuardadoCombate.SUFIJO_PLAYTEST))


func _leer_ficha(ruta: String) -> Dictionary:
	var esquema: Dictionary = Cargador.new().esquema_resuelto("res://datos", "playtest")["esquema"]
	var validacion: Dictionary = Validador.new().validar(
			JSON.parse_string(FileAccess.get_file_as_string(ruta)), esquema, "playtest")
	assert_array(validacion["errores"] as Array).override_failure_message(str(validacion["errores"])).is_empty()
	return validacion["datos"]


func test_en_g_la_ficha_se_escribe_despues_del_destino() -> void:
	var carpeta: String = create_temp_dir("t33_ficha_g")
	var escenario: Dictionary = MesaDestino.escenario()
	var semilla: int = escenario["semilla"]
	var variante: Dictionary = {"semilla": semilla, "pergaminos_en_blanco": 2}
	var runner: GdUnitSceneRunner = _vista(escenario, carpeta, variante, " Ana ", [7, semilla])
	await runner.simulate_frames(2)
	var vista: VistaCombate = runner.scene()
	assert_bool(vista.combate().esperando_destino()).is_true()
	assert_array(_fichas(carpeta)).is_empty()

	assert_bool(vista.pulsar_destino(DestinoAtacante.OPCION_PERDONAR)).is_true()
	await runner.simulate_frames(1)
	assert_bool(vista.combate().esperando_destino()).is_false()
	assert_array(_fichas(carpeta)).has_size(1)
	var nombre: String = _fichas(carpeta)[0]
	# Junto al resultado, con el mismo nombre.
	assert_bool(FileAccess.file_exists(carpeta.path_join(nombre.replace(GuardadoCombate.SUFIJO_PLAYTEST,
			GuardadoCombate.SUFIJO_RESULTADO)))).is_true()
	assert_dict(_leer_ficha(carpeta.path_join(nombre))).is_equal({"escenario": escenario["id"],
			"variante": {"pergaminos_en_blanco": 2}, "semilla": semilla, "indice_semilla": 2, "jugador": "Ana"})


func test_sin_variante_ni_jugador() -> void:
	var carpeta: String = create_temp_dir("t33_ficha_vacia")
	var escenario: Dictionary = MesaDestino.escenario()
	var runner: GdUnitSceneRunner = _vista(escenario, carpeta, {}, null, [])
	await runner.simulate_frames(2)
	var vista: VistaCombate = runner.scene()
	assert_bool(vista.pulsar_destino(DestinoAtacante.OPCION_PERDONAR)).is_true()
	await runner.simulate_frames(1)
	assert_array(_fichas(carpeta)).has_size(1)
	assert_dict(_leer_ficha(carpeta.path_join(_fichas(carpeta)[0]))).is_equal({"escenario": escenario["id"],
			"variante": {}, "semilla": escenario["semilla"], "indice_semilla": null, "jugador": null})
