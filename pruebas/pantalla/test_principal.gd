extends GdUnitTestSuite

# Arquitectura.md A.6 y B.2 (T13, sesiones 1 y 2): la escena principal, con el runner
# de escenas de GdUnit4. Arranque bloqueado con datos rotos, selector con los
# escenarios reales, lista de claves usadas que llega al Cargador y recarga.
const _ESCENA: String = "res://pantalla/principal.tscn"
const _DATOS_ROTOS: String = "res://pruebas/fixtures/cargador/un_error_ningun_dato"


func _principal(carpeta: String) -> GdUnitSceneRunner:
	# Con una instancia, el runner no la libera: auto_free la libera al terminar.
	var principal: Principal = auto_free(load(_ESCENA).instantiate())
	principal.carpeta_datos = carpeta
	return scene_runner(principal)


# (1) Con datos rotos, el juego no arranca: pantalla de error con archivo y campo.
func test_datos_rotos_muestran_error() -> void:
	var runner: GdUnitSceneRunner = _principal(_DATOS_ROTOS)
	await runner.simulate_frames(1)
	assert_bool(runner.find_child("PantallaError").visible).is_true()
	assert_str((runner.find_child("TextoErrores") as Label).text).contains("especies/rodauva.json").contains("vida")
	assert_bool(runner.find_child("SelectorEscenario").visible).is_false()
	assert_object((runner.scene() as Principal).vista()).is_null()


# (2) Con datos/ real arranca sin errores y lista los 11 escenarios.
func test_datos_reales_listan_los_escenarios() -> void:
	var runner: GdUnitSceneRunner = _principal("res://datos")
	await runner.simulate_frames(1)
	var principal: Principal = runner.scene()
	assert_array(principal.errores()).override_failure_message(str(principal.errores())).is_empty()
	assert_bool(runner.find_child("PantallaError").visible).is_false()
	assert_bool(runner.find_child("SelectorEscenario").visible).is_true()
	var ids: Array[String] = principal.ids_escenarios()
	assert_int(ids.size()).is_equal(11)
	var textos_botones: Array[String] = []
	for boton in runner.find_child("SelectorEscenario").get_children():
		textos_botones.append((boton as Button).text)
	assert_array(textos_botones).is_equal(ids)
	assert_array(ids).contains(["a_dia_1", "c_tasajero", "g_ataque_nocturno"])


# (5) La lista de claves usadas llega al Cargador: una clave que falta en un
# fixture de textos aparece como aviso, y no bloquea el arranque.
func test_clave_faltante_es_un_aviso() -> void:
	var runner: GdUnitSceneRunner = _principal("res://pruebas/fixtures/pantalla/textos_incompletos")
	await runner.simulate_frames(1)
	var principal: Principal = runner.scene()
	assert_array(principal.errores()).is_empty()
	var faltantes: Array[String] = []
	for aviso in principal.avisos():
		if aviso["esperado"] == "presente en el archivo":
			faltantes.append(aviso["campo"])
	assert_array(faltantes).contains([ClavesTextos.MARCA_CAZA, ClavesTextos.MAESTRO_NOMBRE])
	assert_array(faltantes).not_contains([ClavesTextos.MARCA_CUENTA])
	assert_bool(runner.find_child("SelectorEscenario").visible).is_true()


# (10) Recargar con un numero cambiado en una copia de los datos reinicia el
# escenario con el numero nuevo; con un dato roto muestra la pantalla de error.
# La copia es de datos/ entero (no hay una carpeta de fixtures completa); el
# test no depende de ningun numero de balance: lee el valor y le suma 1.
func test_recargar_lee_el_disco_y_reinicia() -> void:
	var carpeta: String = create_temp_dir("t13_recarga")
	_copiar_carpeta("res://datos", carpeta)
	var runner: GdUnitSceneRunner = _principal(carpeta)
	await runner.simulate_frames(1)
	var principal: Principal = runner.scene()
	assert_array(principal.errores()).override_failure_message(str(principal.errores())).is_empty()
	var vista: VistaCombate = principal.abrir_escenario("a_dia_1")
	var vida_antes: int = vista.combate().contexto().plantel.criatura("ocarra_s1").vida_max_real()

	var ruta_ocarra: String = carpeta.path_join("especies/ocarra.json")
	var regex: RegEx = RegEx.create_from_string("\"vida\":\\s*(\\d+)")
	var texto: String = FileAccess.get_file_as_string(ruta_ocarra)
	var vida_archivo: int = regex.search(texto).get_string(1).to_int()
	_escribir(ruta_ocarra, regex.sub(texto, "\"vida\": %d" % (vida_archivo + 1)))
	principal.recargar()
	await runner.simulate_frames(1)
	assert_array(principal.errores()).is_empty()
	assert_object(principal.vista()).is_not_null()
	assert_object(principal.vista()).is_not_same(vista)
	var nueva: Combate = principal.vista().combate()
	assert_int(nueva.contexto().plantel.criatura("ocarra_s1").vida_max_real()).is_equal(vida_antes + 1)
	assert_bool(nueva.esperando_jugador()).is_true()

	_escribir(ruta_ocarra, regex.sub(texto, "\"vida\": \"x\""))
	principal.recargar()
	await runner.simulate_frames(1)
	assert_array(principal.errores()).is_not_empty()
	assert_bool(runner.find_child("PantallaError").visible).is_true()
	assert_str((runner.find_child("TextoErrores") as Label).text).contains("especies/ocarra.json")
	assert_bool(runner.find_child("SelectorEscenario").visible).is_false()
	assert_object(principal.vista()).is_null()


# Un clic de mouse de verdad (no clic_casilla) sobre una casilla alcanzable
# llega hasta la vista por la accion `seleccionar`: ningun Control de la
# principal ni de la interfaz se lo come (mouse_filter IGNORE en los que tapan
# el tablero).
func test_clic_del_mouse_llega_al_tablero() -> void:
	var runner: GdUnitSceneRunner = _principal("res://datos")
	await runner.simulate_frames(1)
	var vista: VistaCombate = (runner.scene() as Principal).abrir_escenario("a_dia_1")
	await runner.simulate_frames(2)
	var turno: Turno = vista.combate().turno_actual()
	assert_bool(turno.movimiento_usado).is_false()
	var casillas: Array[Vector2i] = turno.casillas_para_mover()
	assert_array(casillas).is_not_empty()
	runner.simulate_mouse_move(_en_pantalla(vista, casillas[0]))
	await runner.simulate_frames(1)
	runner.simulate_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	await runner.simulate_frames(2)
	assert_bool(vista.combate().turno_actual().movimiento_usado).is_true()
	assert_object(vista.combate().turno_actual()).is_same(turno)


# T40, sesion 2 (test 6d): la accion `recargar` anda durante una secuencia de
# la IA y la corta limpia: la vista vieja se libera con su Timer, la nueva
# arranca sin secuencia y sin error.
func test_recargar_corta_la_secuencia_de_la_ia() -> void:
	var runner: GdUnitSceneRunner = _principal("res://datos")
	await runner.simulate_frames(1)
	var principal: Principal = runner.scene()
	var vista: VistaCombate = principal.abrir_escenario("c_tasajero")
	await runner.simulate_frames(1)
	# Presentacion: una pausa que no llega a correr durante el test.
	vista.pausa_ia = 100.0
	for _i in range(20):
		if vista.en_secuencia():
			break
		assert_bool(vista.pulsar_terminar()).is_true()
	assert_bool(vista.en_secuencia()).is_true()

	var evento: InputEventAction = InputEventAction.new()
	evento.action = "recargar"
	evento.pressed = true
	Input.parse_input_event(evento)
	await runner.simulate_frames(3)
	assert_object(principal.vista()).is_not_null()
	assert_object(principal.vista()).is_not_same(vista)
	assert_bool(principal.vista().en_secuencia()).is_false()
	assert_str(principal.vista().combate().error()).is_empty()
	assert_bool(principal.vista().combate().esperando_jugador()).is_true()


# Casilla -> posicion en el viewport: map_to_local y la transformacion del lienzo (camara).
func _en_pantalla(vista: VistaCombate, casilla: Vector2i) -> Vector2:
	var tablero: TileMapLayer = vista.tablero()
	return tablero.get_viewport().get_canvas_transform() * tablero.to_global(tablero.map_to_local(casilla))


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
