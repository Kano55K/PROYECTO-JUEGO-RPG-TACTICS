extends GdUnitTestSuite

# Arquitectura.md B.4 (T31, sesion 2) y A.6: el flujo selector -> panel ->
# Jugar de la escena principal, con datos/ real (o una copia temporal para la
# recarga). Los clics van por MousePrueba (D-012).
const _ESCENA: String = "res://pantalla/principal.tscn"
const _DATOS: String = "res://datos"
const _TOPE_TURNOS: int = 200


func _principal(carpeta: String) -> GdUnitSceneRunner:
	# Con una instancia, el runner no la libera: auto_free la libera al terminar.
	var principal: Principal = auto_free(load(_ESCENA).instantiate())
	principal.carpeta_datos = carpeta
	principal.carpeta_registros = create_temp_dir("t31_registros")
	return scene_runner(principal)


func _centro(boton: Button) -> Vector2:
	return boton.get_global_rect().get_center()


func _boton_selector(runner: GdUnitSceneRunner, escenario_id: String) -> Button:
	for boton in runner.find_child("SelectorEscenario").get_children():
		if (boton as Button).text == escenario_id:
			return boton
	return null


# Del selector al panel de un escenario, con un clic.
func _abrir_panel(runner: GdUnitSceneRunner, escenario_id: String) -> PanelParametros:
	var boton: Button = _boton_selector(runner, escenario_id)
	assert_object(boton).override_failure_message(escenario_id).is_not_null()
	MousePrueba.clic_en(_centro(boton))
	await runner.simulate_frames(1)
	var panel: PanelParametros = (runner.scene() as Principal).panel()
	assert_bool(panel.visible).is_true()
	assert_bool(runner.find_child("SelectorEscenario").visible).is_false()
	return panel


func _jugar(runner: GdUnitSceneRunner) -> VistaCombate:
	MousePrueba.clic_en(_centro(runner.find_child("Jugar") as Button))
	await runner.simulate_frames(1)
	var vista: VistaCombate = (runner.scene() as Principal).vista()
	assert_object(vista).is_not_null()
	vista.pausa_ia = 0.0
	assert_bool((runner.scene() as Principal).panel().visible).is_false()
	return vista


func _elegir(panel: PanelParametros, ruta: String, opcion: String) -> void:
	var lista: OptionButton = panel.control(ruta)
	var indice: int = (panel.edicion().campo(ruta)["opciones"] as Array).find(opcion)
	lista.select(indice)
	lista.item_selected.emit(indice)


func _semilla_del_registro(combate: Combate) -> int:
	var inicio: Dictionary = combate.registro().lineas()[0]
	assert_str(inicio["tipo"] as String).is_equal("inicio")
	return inicio["semilla"]


# El Maestro declara la huida en su primer turno y los demas terminan, hasta
# que el combate termina (una forma corta de llegar al resultado).
func _hasta_el_final(vista: VistaCombate) -> void:
	for _i in range(_TOPE_TURNOS):
		if vista.combate().terminado():
			return
		var turno: Turno = vista.combate().turno_actual()
		if turno.unidad_id == Maestro.ID and vista.pulsar_huir():
			continue
		assert_bool(vista.pulsar_terminar()).override_failure_message(turno.unidad_id).is_true()
	assert_bool(vista.combate().terminado()).is_true()


# El contenido de cada archivo de la carpeta, por ruta relativa.
func _contenidos(carpeta: String, relativo: String = "") -> Dictionary:
	var resultado: Dictionary = {}
	var actual: String = carpeta.path_join(relativo)
	for nombre in DirAccess.get_files_at(actual):
		resultado[relativo.path_join(nombre)] = FileAccess.get_file_as_string(actual.path_join(nombre))
	for subcarpeta in DirAccess.get_directories_at(actual):
		resultado.merge(_contenidos(carpeta, relativo.path_join(subcarpeta)))
	return resultado


# (10) y manual 3: el selector abre el panel del escenario (sin combate); C con
# la Rodauva guardada se juega desde Jugar y la Rodauva no esta en el tablero.
func test_selector_panel_jugar() -> void:
	var runner: GdUnitSceneRunner = _principal(_DATOS)
	await runner.simulate_frames(1)
	var principal: Principal = runner.scene()
	var panel: PanelParametros = await _abrir_panel(runner, "c_tasajero")
	assert_object(principal.vista()).is_null()
	assert_str(panel.edicion().escenario()["id"] as String).is_equal("c_tasajero")
	assert_array(panel.rutas()).contains(["tribu.rodauva_1.estado", "toggles.afines_contra_cobardia"])

	_elegir(panel, "tribu.rodauva_1.estado", "guardada")
	var vista: VistaCombate = await _jugar(runner)
	assert_str(vista.combate().error()).is_empty()
	for criatura in (vista.combate().instantanea()["criaturas"] as Array):
		if (criatura as Dictionary)["id"] == "rodauva_1":
			assert_str(criatura["estado"]).is_equal("guardada")
			assert_that(criatura["posicion"]).is_null()


# (12) El boton de la semilla suma 1 y el combate usa esa semilla (evento
# inicio). (15) Jugar variantes hasta el final no cambia ningun archivo de
# datos/; la corrida editada se guarda con _editado. Al volver al selector, el
# panel del escenario conserva la ultima variante.
func test_12_15_semilla_variantes_y_volver() -> void:
	var antes: Dictionary = _contenidos(ProjectSettings.globalize_path(_DATOS))
	var runner: GdUnitSceneRunner = _principal(_DATOS)
	await runner.simulate_frames(1)
	var principal: Principal = runner.scene()

	var panel: PanelParametros = await _abrir_panel(runner, "a_dia_1")
	var del_archivo: int = panel.edicion().valor("semilla")
	MousePrueba.clic_en(_centro(runner.find_child("SemillaMasUno") as Button))
	var vista: VistaCombate = await _jugar(runner)
	assert_int(_semilla_del_registro(vista.combate())).is_equal(del_archivo + 1)
	_hasta_el_final(vista)
	var guardadas: PackedStringArray = DirAccess.get_files_at(principal.carpeta_registros)
	assert_array(Array(guardadas)).contains(["a_dia_1_editado_%d_1.json" % (del_archivo + 1)])

	MousePrueba.clic_en(_centro(runner.find_child("BotonVolver") as Button))
	await runner.simulate_frames(1)
	assert_object(principal.vista()).is_null()
	assert_bool(runner.find_child("SelectorEscenario").visible).is_true()
	panel = await _abrir_panel(runner, "a_dia_1")
	assert_int(panel.edicion().valor("semilla") as int).is_equal(del_archivo + 1)
	assert_int(int((panel.control("semilla") as SpinBox).value)).is_equal(del_archivo + 1)

	# Otra variante, de otro escenario, con la balanza cambiada.
	MousePrueba.clic_en(_centro(runner.find_child("Volver") as Button))
	await runner.simulate_frames(1)
	panel = await _abrir_panel(runner, "d_rivales_normal")
	(panel.control("maestro.balanza") as SpinBox).value = 4
	vista = await _jugar(runner)
	assert_int(vista.combate().contexto().escenario["maestro"]["balanza"] as int).is_equal(4)
	_hasta_el_final(vista)

	assert_dict(_contenidos(ProjectSettings.globalize_path(_DATOS))).is_equal(antes)


# Sin cambios, Jugar guarda con el nombre de siempre.
func test_sin_cambios_el_nombre_de_siempre() -> void:
	var runner: GdUnitSceneRunner = _principal(_DATOS)
	await runner.simulate_frames(1)
	var principal: Principal = runner.scene()
	var panel: PanelParametros = await _abrir_panel(runner, "a_dia_1")
	var semilla: int = panel.edicion().valor("semilla")
	var vista: VistaCombate = await _jugar(runner)
	_hasta_el_final(vista)
	var guardadas: PackedStringArray = DirAccess.get_files_at(principal.carpeta_registros)
	assert_array(Array(guardadas)).contains(["a_dia_1_%d_1.json" % semilla])


# (14) R dentro del combate vuelve a leer los datos y reinicia con la variante;
# con un dato cambiado que la invalida, vuelve al panel con el error.
func test_14_recargar_con_la_variante() -> void:
	var carpeta: String = create_temp_dir("t31_recarga")
	_copiar_carpeta(_DATOS, carpeta)
	var runner: GdUnitSceneRunner = _principal(carpeta)
	await runner.simulate_frames(1)
	var principal: Principal = runner.scene()
	var panel: PanelParametros = await _abrir_panel(runner, "a_dia_1")
	var semilla: int = panel.edicion().valor("semilla")
	var reserva: int = panel.edicion().campo("maestro.mana_entrada")["maximo"]
	panel.control_por_defecto("maestro.mana_entrada").button_pressed = false
	assert_int(panel.edicion().valor("maestro.mana_entrada") as int).is_equal(reserva)
	panel.pulsar_semilla_mas_uno()
	var vista: VistaCombate = await _jugar(runner)

	var evento: InputEventAction = InputEventAction.new()
	evento.action = "recargar"
	evento.pressed = true
	Input.parse_input_event(evento)
	await runner.simulate_frames(2)
	assert_object(principal.vista()).is_not_null()
	assert_object(principal.vista()).is_not_same(vista)
	var contexto: ContextoCombate = principal.vista().combate().contexto()
	assert_int(contexto.semilla).is_equal(semilla + 1)
	assert_int(contexto.escenario["maestro"]["mana_entrada"] as int).is_equal(reserva)
	assert_bool(principal.vista().combate().esperando_jugador()).is_true()

	# La reserva de la balanza del escenario baja en 1 en la copia: el mana de
	# entrada explicito ya no entra (no se recorta).
	var balanza: int = contexto.escenario["maestro"]["balanza"]
	var ruta_balanza: String = carpeta.path_join("tablas/balanza.json")
	var texto: String = FileAccess.get_file_as_string(ruta_balanza)
	var fila: RegEx = RegEx.create_from_string("\"posicion\":\\s*%d,\\s*\"reserva_mana\":\\s*%d" % [balanza, reserva])
	assert_object(fila.search(texto)).is_not_null()
	_escribir(ruta_balanza, fila.sub(texto, "\"posicion\": %d,\n      \"reserva_mana\": %d" % [balanza, reserva - 1]))
	principal.recargar()
	await runner.simulate_frames(1)
	assert_array(principal.errores()).is_empty()
	assert_object(principal.vista()).is_null()
	panel = principal.panel()
	assert_bool(panel.visible).is_true()
	assert_int(panel.edicion().valor("maestro.mana_entrada") as int).is_equal(reserva)
	assert_int(panel.edicion().valor("semilla") as int).is_equal(semilla + 1)
	assert_str(panel.texto_error("maestro.mana_entrada")).contains(str(reserva))
	assert_bool(panel.puede_jugar()).is_false()
	assert_bool((runner.find_child("Jugar") as Button).disabled).is_true()


func _copiar_carpeta(origen: String, destino: String) -> void:
	DirAccess.make_dir_recursive_absolute(destino)
	for nombre in DirAccess.get_files_at(origen):
		if nombre.ends_with(".json"):
			_escribir(destino.path_join(nombre), FileAccess.get_file_as_string(origen.path_join(nombre)))
	for subcarpeta in DirAccess.get_directories_at(origen):
		_copiar_carpeta(origen.path_join(subcarpeta), destino.path_join(subcarpeta))


func _escribir(ruta: String, contenido: String) -> void:
	var archivo: FileAccess = FileAccess.open(ruta, FileAccess.WRITE)
	archivo.store_string(contenido)
	archivo.close()
