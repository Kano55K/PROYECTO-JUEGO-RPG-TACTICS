extends GdUnitTestSuite

# Arquitectura.md B.4 (T31, sesion 2): el panel de parametros es una pantalla
# de desarrollo armada desde EdicionEscenario (rangos del esquema). Con
# fixtures (A.6). Los botones se pulsan con MousePrueba (D-012); los controles
# de numero, opcion e interruptor se cambian como lo haria el jugador al
# confirmar el valor (emiten su senial).
const _ESCENA: String = "res://pantalla/parametros/panel_parametros.tscn"
const _ESCENARIO: String = "res://pruebas/fixtures/parametros/escenario_parametros.json"
const _CARPETA_ESQUEMA_REAL: String = "res://datos"
const _CARPETA_ESQUEMA_OTRO: String = "res://pruebas/fixtures/parametros/esquema_otro"


func _escenario() -> Dictionary:
	var lectura: Dictionary = LectorFixture.leer(_ESCENARIO, "escenario")
	assert_array(lectura["errores"] as Array).override_failure_message(str(lectura["errores"])).is_empty()
	return lectura["datos"]


func _edicion(carpeta_esquema: String = _CARPETA_ESQUEMA_REAL) -> EdicionEscenario:
	var datos: Dictionary = DatosFixture.cargar()["datos"]
	var esquema: Dictionary = Cargador.new().esquema_resuelto(carpeta_esquema, "escenario")["esquema"]
	return EdicionEscenario.new(_escenario(), datos, esquema)


func _panel(edicion: EdicionEscenario) -> GdUnitSceneRunner:
	var runner: GdUnitSceneRunner = scene_runner(auto_free(load(_ESCENA).instantiate()))
	(runner.scene() as PanelParametros).abrir(edicion)
	return runner


func _centro(boton: Button) -> Vector2:
	return boton.get_global_rect().get_center()


func _poner_numero(panel: PanelParametros, ruta: String, numero: int) -> void:
	var nulo: CheckBox = panel.control_por_defecto(ruta)
	if nulo != null and nulo.button_pressed:
		nulo.button_pressed = false
	(panel.control(ruta) as SpinBox).value = numero


func _elegir(panel: PanelParametros, ruta: String, opcion: String) -> void:
	var lista: OptionButton = panel.control(ruta)
	for i in range(lista.item_count):
		if lista.get_item_text(i) == opcion:
			lista.select(i)
			lista.item_selected.emit(i)
			return
	fail("sin la opcion %s en %s" % [opcion, ruta])


func _texto_opcion(panel: PanelParametros, ruta: String) -> String:
	var lista: OptionButton = panel.control(ruta)
	return lista.get_item_text(lista.selected)


# (10) Un control por campo editable, del tipo del campo y con los limites del
# esquema; "por defecto" para los que admiten null.
func test_10_un_control_por_campo() -> void:
	var edicion: EdicionEscenario = _edicion()
	var runner: GdUnitSceneRunner = _panel(edicion)
	await runner.simulate_frames(1)
	var panel: PanelParametros = runner.scene()
	var campos: Array[Dictionary] = edicion.campos()
	assert_array(panel.rutas()).is_equal(campos.map(func(c: Dictionary) -> String: return c["ruta"]))
	for campo in campos:
		var ruta: String = campo["ruta"]
		var control: Control = panel.control(ruta)
		assert_object(control).override_failure_message(ruta).is_not_null()
		match campo["tipo"]:
			EdicionEscenario.TIPO_ENTERO:
				assert_object(control).override_failure_message(ruta).is_instanceof(SpinBox)
				var numero: SpinBox = control
				if campo["minimo"] != null:
					assert_int(int(numero.min_value)).override_failure_message(ruta).is_equal(campo["minimo"])
				if campo["maximo"] != null:
					assert_int(int(numero.max_value)).override_failure_message(ruta).is_equal(campo["maximo"])
				# Nunca recorta: el error lo da la validacion.
				assert_bool(numero.allow_greater and numero.allow_lesser).override_failure_message(ruta).is_true()
			EdicionEscenario.TIPO_OPCION:
				assert_object(control).override_failure_message(ruta).is_instanceof(OptionButton)
				assert_int((control as OptionButton).item_count).is_equal((campo["opciones"] as Array).size())
			EdicionEscenario.TIPO_BOOLEANO:
				assert_object(control).override_failure_message(ruta).is_instanceof(CheckButton)
		var nulo: CheckBox = panel.control_por_defecto(ruta)
		if campo["admite_nulo"]:
			assert_object(nulo).override_failure_message(ruta).is_not_null()
			assert_bool(nulo.button_pressed).override_failure_message(ruta).is_equal(edicion.valor(ruta) == null)
		else:
			assert_object(nulo).override_failure_message(ruta).is_null()
	assert_int(int((panel.control("maestro.balanza") as SpinBox).value)).is_equal(2)
	assert_str(_texto_opcion(panel, "tribu.ocarra_1.estado")).is_equal("guardada")
	assert_bool(panel.puede_jugar()).is_true()


# (10) Con otro esquema, el limite de la balanza y el toggle nuevo aparecen sin
# tocar codigo.
func test_10_limites_de_otro_esquema() -> void:
	var runner: GdUnitSceneRunner = _panel(_edicion(_CARPETA_ESQUEMA_OTRO))
	await runner.simulate_frames(1)
	var panel: PanelParametros = runner.scene()
	assert_int(int((panel.control("maestro.balanza") as SpinBox).max_value)).is_equal(3)
	assert_object(panel.control("toggles.toggle_prueba")).is_instanceof(CheckButton)


# (11) mana_entrada por encima de la reserva: el error va junto al campo y Jugar
# se deshabilita (un clic no juega). Al corregirlo, se habilita.
func test_11_error_deshabilita_jugar() -> void:
	var edicion: EdicionEscenario = _edicion()
	var runner: GdUnitSceneRunner = _panel(edicion)
	await runner.simulate_frames(1)
	var panel: PanelParametros = runner.scene()
	var jugar: Button = runner.find_child("Jugar")
	var reserva: int = edicion.campo("maestro.mana_entrada")["maximo"]
	assert_str(panel.texto_error("maestro.mana_entrada")).is_empty()

	_poner_numero(panel, "maestro.mana_entrada", reserva + 1)
	assert_int(edicion.valor("maestro.mana_entrada") as int).is_equal(reserva + 1)
	assert_str(panel.texto_error("maestro.mana_entrada")).contains(str(reserva + 1))
	assert_bool(panel.puede_jugar()).is_false()
	assert_bool(jugar.disabled).is_true()
	var pulsadas: Array[int] = [0]
	panel.jugar.connect(func() -> void: pulsadas[0] += 1)
	MousePrueba.clic_en(_centro(jugar))
	assert_int(pulsadas[0]).is_equal(0)

	_poner_numero(panel, "maestro.mana_entrada", reserva)
	assert_str(panel.texto_error("maestro.mana_entrada")).is_empty()
	assert_bool(jugar.disabled).is_false()
	MousePrueba.clic_en(_centro(jugar))
	assert_int(pulsadas[0]).is_equal(1)


# (11) Un numero fuera del rango del esquema: error con el valor esperado; el
# panel no lo recorta.
func test_11_fuera_de_rango_no_se_recorta() -> void:
	var edicion: EdicionEscenario = _edicion(_CARPETA_ESQUEMA_OTRO)
	var runner: GdUnitSceneRunner = _panel(edicion)
	await runner.simulate_frames(1)
	var panel: PanelParametros = runner.scene()
	_poner_numero(panel, "maestro.balanza", 4)
	assert_int(edicion.valor("maestro.balanza") as int).is_equal(4)
	assert_int(int((panel.control("maestro.balanza") as SpinBox).value)).is_equal(4)
	assert_str(panel.texto_error("maestro.balanza")).contains("3")
	assert_bool(panel.puede_jugar()).is_false()


# "Por defecto": tildado deja null; destildado, el valor del numero.
func test_por_defecto() -> void:
	var edicion: EdicionEscenario = _edicion()
	var runner: GdUnitSceneRunner = _panel(edicion)
	await runner.simulate_frames(1)
	var panel: PanelParametros = runner.scene()
	var nulo: CheckBox = panel.control_por_defecto("maestro.vida")
	var numero: SpinBox = panel.control("maestro.vida")
	assert_bool(numero.editable).is_false()
	nulo.button_pressed = false
	assert_bool(numero.editable).is_true()
	assert_int(edicion.valor("maestro.vida") as int).is_equal(int(numero.value))
	numero.value = 150
	assert_int(edicion.valor("maestro.vida") as int).is_equal(150)
	nulo.button_pressed = true
	assert_that(edicion.valor("maestro.vida")).is_null()
	assert_bool(edicion.difiere()).is_false()


# P-023: soltar una guardada sin posicion en el archivo no se aplica; el motivo
# queda junto al campo y la opcion vuelve a guardada.
func test_soltar_sin_posicion_muestra_el_motivo() -> void:
	var edicion: EdicionEscenario = _edicion()
	var runner: GdUnitSceneRunner = _panel(edicion)
	await runner.simulate_frames(1)
	var panel: PanelParametros = runner.scene()
	_elegir(panel, "tribu.ocarra_1.estado", "suelta")
	assert_str(edicion.valor("tribu.ocarra_1.estado") as String).is_equal("guardada")
	assert_str(_texto_opcion(panel, "tribu.ocarra_1.estado")).is_equal("guardada")
	assert_str(panel.texto_error("tribu.ocarra_1.estado")).contains(EdicionEscenario.MOTIVO_SIN_POSICION_EN_ARCHIVO)

	_elegir(panel, "tribu.rodauva_1.estado", "guardada")
	assert_str(edicion.valor("tribu.rodauva_1.estado") as String).is_equal("guardada")
	assert_str(panel.texto_error("tribu.ocarra_1.estado")).is_empty()


# (12) El boton de la semilla suma 1 (sin reloj ni azar del sistema).
func test_12_semilla_mas_uno() -> void:
	var edicion: EdicionEscenario = _edicion()
	var runner: GdUnitSceneRunner = _panel(edicion)
	await runner.simulate_frames(1)
	var panel: PanelParametros = runner.scene()
	var mas_uno: Button = runner.find_child("SemillaMasUno")
	MousePrueba.clic_en(_centro(mas_uno))
	MousePrueba.clic_en(_centro(mas_uno))
	assert_int(edicion.valor("semilla") as int).is_equal(7)
	assert_int(int((panel.control("semilla") as SpinBox).value)).is_equal(7)


# (13) "Restaurar del archivo" vuelve la variante y los controles al escenario
# del archivo, errores incluidos.
func test_13_restaurar_del_archivo() -> void:
	var edicion: EdicionEscenario = _edicion()
	var runner: GdUnitSceneRunner = _panel(edicion)
	await runner.simulate_frames(1)
	var panel: PanelParametros = runner.scene()
	_poner_numero(panel, "maestro.balanza", 3)
	_poner_numero(panel, "maestro.vida", 150)
	_poner_numero(panel, "maestro.mana_entrada", 99)
	_elegir(panel, "tribu.rodauva_1.estado", "guardada")
	(panel.control("toggles.afines_contra_cobardia") as CheckButton).button_pressed = true
	assert_bool(edicion.difiere()).is_true()
	assert_bool(panel.puede_jugar()).is_false()

	MousePrueba.clic_en(_centro(runner.find_child("Restaurar") as Button))
	assert_bool(panel.edicion().difiere()).is_false()
	assert_dict(panel.edicion().escenario()).is_equal(_escenario())
	assert_int(int((panel.control("maestro.balanza") as SpinBox).value)).is_equal(2)
	assert_bool(panel.control_por_defecto("maestro.vida").button_pressed).is_true()
	assert_bool(panel.control_por_defecto("maestro.mana_entrada").button_pressed).is_true()
	assert_str(_texto_opcion(panel, "tribu.rodauva_1.estado")).is_equal("suelta")
	assert_bool((panel.control("toggles.afines_contra_cobardia") as CheckButton).button_pressed).is_false()
	assert_str(panel.texto_error("maestro.mana_entrada")).is_empty()
	assert_bool(panel.puede_jugar()).is_true()


# Volver emite su senial (el selector lo maneja la principal).
func test_volver() -> void:
	var runner: GdUnitSceneRunner = _panel(_edicion())
	await runner.simulate_frames(1)
	var panel: PanelParametros = runner.scene()
	var pulsadas: Array[int] = [0]
	panel.volver.connect(func() -> void: pulsadas[0] += 1)
	MousePrueba.clic_en(_centro(runner.find_child("Volver") as Button))
	assert_int(pulsadas[0]).is_equal(1)


# T33, sesion 3 (11): el selector "Semilla de playtest" pone la semilla de la
# lista (las del fixture de alarmas, MesaPlaytest), por la misma edicion: la
# validacion pasa y el +1 sigue igual. Una semilla que no es de la lista
# muestra "playtest -".
func _panel_playtest(edicion: EdicionEscenario, semillas: Array) -> GdUnitSceneRunner:
	var runner: GdUnitSceneRunner = scene_runner(auto_free(load(_ESCENA).instantiate()))
	(runner.scene() as PanelParametros).abrir(edicion, [], semillas)
	return runner


func _elegir_playtest(panel: PanelParametros, indice: int) -> void:
	var lista: OptionButton = panel.control_semilla_playtest()
	lista.select(indice)
	lista.item_selected.emit(indice)


func test_t33_semilla_de_playtest() -> void:
	var semillas: Array = MesaPlaytest.semillas()
	var edicion: EdicionEscenario = _edicion()
	var runner: GdUnitSceneRunner = _panel_playtest(edicion, semillas)
	await runner.simulate_frames(1)
	var panel: PanelParametros = runner.scene()
	var lista: OptionButton = panel.control_semilla_playtest()
	assert_object(lista).is_not_null()
	assert_str(lista.name).is_equal("SemillaPlaytest")
	assert_int(lista.item_count).is_equal(semillas.size() + 1)
	assert_str(lista.get_item_text(lista.selected)).is_equal(PanelParametros.SIN_SEMILLA_PLAYTEST)

	_elegir_playtest(panel, 3)
	assert_int(edicion.valor("semilla") as int).is_equal(semillas[2])
	assert_int(int((panel.control("semilla") as SpinBox).value)).is_equal(semillas[2])
	assert_str(lista.get_item_text(lista.selected)).is_equal("3")
	assert_bool(panel.puede_jugar()).is_true()

	panel.pulsar_semilla_playtest(10)
	assert_int(edicion.valor("semilla") as int).is_equal(semillas[9])
	assert_str(lista.get_item_text(lista.selected)).is_equal("10")

	# El +1 sigue igual: la semilla siguiente, que no es de la lista.
	MousePrueba.clic_en(_centro(runner.find_child("SemillaMasUno") as Button))
	assert_int(edicion.valor("semilla") as int).is_equal(semillas[9] + 1)
	assert_str(lista.get_item_text(lista.selected)).is_equal(PanelParametros.SIN_SEMILLA_PLAYTEST)

	# Una semilla de la lista puesta a mano tambien se muestra por su indice.
	(panel.control("semilla") as SpinBox).value = semillas[1]
	assert_str(lista.get_item_text(lista.selected)).is_equal("2")

	# Elegir "playtest -" no cambia nada.
	_elegir_playtest(panel, 0)
	assert_int(edicion.valor("semilla") as int).is_equal(semillas[1])


func test_t33_sin_semillas_de_playtest_no_hay_selector() -> void:
	var runner: GdUnitSceneRunner = _panel(_edicion())
	await runner.simulate_frames(1)
	assert_object((runner.scene() as PanelParametros).control_semilla_playtest()).is_null()
	assert_object(runner.find_child("SemillaPlaytest", true, false)).is_null()
