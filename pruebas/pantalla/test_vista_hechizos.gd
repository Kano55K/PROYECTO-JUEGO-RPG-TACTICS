extends GdUnitTestSuite

# Arquitectura.md B.3 (T22, sesion 2), criterios 1 a 3: los botones de los
# hechizos, el modo "elegir objetivo", el hover (lo mostrado = el evento al
# aplicar) y el clic izquierdo y derecho, con el runner de escenas de GdUnit4.
# Fixtures (A.6): escenario_hechizos_combate.json: la Rodauva [2,6] juega
# primero (el test la hace terminar); el Maestro [3,6] tiene al Surcon salvaje
# [3,3] a 3. Hechizos de prueba (escala vieja, D-009). Sistema.md 1.6 y 2.3.
# D-006 y D-012: el mouse se manda por MousePrueba (parse_input_event + flush), sin
# warp_mouse y sin await entre el evento y la comprobacion.
const _ESCENA: String = "res://pantalla/combate/vista_combate.tscn"
const _ESCENARIO: String = "res://pruebas/fixtures/combate/escenario_hechizos_combate.json"
const _TEXTOS: String = "res://pruebas/fixtures/pantalla/es_rasgos.json"
const _HECHIZOS_OTRO_ID: String = "res://pruebas/fixtures/pantalla/hechizos.json"
const _MAESTRO_OTRO_ID: String = "res://pruebas/fixtures/pantalla/maestro_hechizos.json"
const _CARPETA_DATOS: String = "res://datos"
const _MARCA_ELEGIR: Vector2i = Vector2i(5, 0)
const _MARCA_DESTINO: Vector2i = Vector2i(6, 0)
const _SURCON: Vector2i = Vector2i(3, 3)
const _TOPE_TURNOS: int = 20


func _datos(otro_id: bool = false) -> Dictionary:
	var lectura: Dictionary = DatosFixture.cargar()
	assert_array(lectura["errores"]).is_empty()
	var datos: Dictionary = lectura["datos"]
	if otro_id:
		datos["hechizos.json"] = LectorFixture.leer(_HECHIZOS_OTRO_ID, "hechizos")["datos"]
		datos["maestro.json"] = LectorFixture.leer(_MAESTRO_OTRO_ID, "maestro")["datos"]
	datos["textos/es.json"] = LectorFixture.leer(_TEXTOS, "textos")["datos"]
	return datos


func _vista(datos: Dictionary) -> GdUnitSceneRunner:
	var escenario: Dictionary = LectorFixture.leer(_ESCENARIO, "escenario")["datos"]
	var runner: GdUnitSceneRunner = scene_runner(auto_free(load(_ESCENA).instantiate()))
	(runner.scene() as VistaCombate).pausa_ia = 0.0
	MousePrueba.preparar(runner.scene() as VistaCombate)
	(runner.scene() as VistaCombate).empezar(escenario, datos)
	return runner


# Termina los turnos (por la vista) hasta el del Maestro.
func _hasta_el_maestro(vista: VistaCombate) -> void:
	for _i in range(_TOPE_TURNOS):
		if vista.combate().turno_actual().unidad_id == Maestro.ID:
			return
		assert_bool(vista.pulsar_terminar()).is_true()
	fail("no llego el turno del Maestro")


func _ordenadas(casillas: Array[Vector2i]) -> Array[Vector2i]:
	var copia: Array[Vector2i] = casillas.duplicate()
	copia.sort()
	return copia


func _casilla_de(vista: VistaCombate, unidad_id: String) -> Vector2i:
	var foto: Dictionary = vista.combate().instantanea()
	var posicion: Array = foto["maestro"]["posicion"]
	for criatura in foto["criaturas"]:
		if criatura["id"] == unidad_id:
			posicion = criatura["posicion"]
	return Vector2i(posicion[0], posicion[1])


# El ultimo evento del registro de ese tipo, sin n ni ronda.
func _ultimo(vista: VistaCombate, tipo: String) -> Dictionary:
	var encontrado: Dictionary = {}
	for linea in vista.combate().registro().lineas():
		if linea["tipo"] == tipo:
			encontrado = linea.duplicate(true)
	encontrado.erase("n")
	encontrado.erase("ronda")
	return encontrado


# Casilla -> posicion en el viewport (map_to_local y la transformacion del lienzo).
func _en_pantalla(vista: VistaCombate, casilla: Vector2i) -> Vector2:
	var tablero: TileMapLayer = vista.tablero()
	return tablero.get_viewport().get_canvas_transform() * tablero.to_global(tablero.map_to_local(casilla))


# (1) Con el fixture de otro id, su boton sale de los datos con su costo y su
# modo marca justo los objetivos de la consulta; volver a pulsarlo sale del modo,
# y los modos se excluyen. Fuera del turno del Maestro no hay botones de hechizo.
func test_botones_y_modo_desde_los_datos() -> void:
	var runner: GdUnitSceneRunner = _vista(_datos(true))
	await runner.simulate_frames(1)
	var vista: VistaCombate = runner.scene()
	assert_object(runner.find_child("Hechizo_pedrada")).is_null()
	_hasta_el_maestro(vista)
	var boton: Button = runner.find_child("Hechizo_pedrada")
	assert_object(boton).is_not_null()
	assert_str(boton.text).contains("(3 ")
	assert_bool(boton.disabled).is_false()
	assert_object(runner.find_child("Hechizo_martillazo")).is_null()
	assert_object(runner.find_child("Hechizo_lanzadera")).is_not_null()

	assert_bool(vista.pulsar_hechizo("pedrada")).is_true()
	assert_str(vista.hechizo_elegido()).is_equal("pedrada")
	var esperadas: Array[Vector2i] = []
	for objetivo in vista.combate().turno_actual().objetivos_para_hechizo("pedrada"):
		esperadas.append(_casilla_de(vista, objetivo))
	assert_array(esperadas).is_equal([_SURCON])
	var marcas: TileMapLayer = runner.find_child("Marcas")
	assert_array(_ordenadas(marcas.get_used_cells())).is_equal(_ordenadas(esperadas))
	assert_vector(marcas.get_cell_atlas_coords(_SURCON)).is_equal(_MARCA_ELEGIR)
	assert_bool((runner.find_child("Hechizo_pedrada") as Button).button_pressed).is_true()

	# Otro hechizo cambia de modo; el mismo boton sale del modo.
	assert_bool(vista.pulsar_hechizo("remiendo")).is_true()
	assert_str(vista.hechizo_elegido()).is_equal("remiendo")
	assert_bool(vista.pulsar_hechizo("remiendo")).is_true()
	assert_str(vista.hechizo_elegido()).is_empty()

	assert_bool(vista.pulsar_terminar()).is_true()
	assert_object(runner.find_child("Hechizo_pedrada")).is_null()


# (1) Sin mana y con la accion usada, el boton esta deshabilitado, su tooltip
# dice el motivo y pulsarlo no entra al modo.
func test_botones_deshabilitados() -> void:
	var runner: GdUnitSceneRunner = _vista(_datos())
	await runner.simulate_frames(1)
	var vista: VistaCombate = runner.scene()
	_hasta_el_maestro(vista)
	vista.combate().contexto().plantel.maestro.mana = 3
	vista.redibujar()
	var remiendo: Button = runner.find_child("Hechizo_remiendo")
	assert_bool(remiendo.disabled).is_true()
	assert_str(remiendo.tooltip_text).ends_with("[FALTA: aviso.hechizo.mana_insuficiente]")
	assert_bool(vista.pulsar_hechizo("remiendo")).is_false()
	assert_str(vista.hechizo_elegido()).is_empty()

	assert_bool(vista.pulsar_hechizo("martillazo")).is_true()
	assert_bool(vista.clic_casilla(_SURCON)).is_true()
	for id_hechizo in ["martillazo", "lanzadera", "remiendo"]:
		var boton: Button = runner.find_child("Hechizo_" + id_hechizo)
		assert_bool(boton.disabled).override_failure_message(id_hechizo).is_true()
		assert_str(boton.tooltip_text).ends_with("[FALTA: aviso.hechizo.accion_usada]")


# (2) Martillazo: el desglose del hover es el `desglose` del `ataque` registrado.
# Remiendo: lo mostrado es el evento `remiendo` registrado.
func test_hover_martillazo_y_remiendo_iguales_al_evento() -> void:
	var runner: GdUnitSceneRunner = _vista(_datos())
	await runner.simulate_frames(1)
	var vista: VistaCombate = runner.scene()
	_hasta_el_maestro(vista)
	assert_bool(vista.pulsar_hechizo("martillazo")).is_true()
	vista.sobre_casilla(_SURCON)
	var mostrado: Dictionary = vista.desglose_mostrado()
	assert_dict(mostrado).is_not_empty()
	assert_bool((runner.find_child("PanelDesglose") as Label).visible).is_true()
	assert_bool(vista.clic_casilla(_SURCON)).is_true()
	assert_dict(_ultimo(vista, "ataque")["desglose"]).is_equal(mostrado)
	assert_str(vista.hechizo_elegido()).is_empty()

	# Siguiente turno del Maestro: Remiendo sobre si mismo, herido.
	assert_bool(vista.pulsar_terminar()).is_true()
	_hasta_el_maestro(vista)
	vista.combate().contexto().plantel.maestro.vida = 3
	assert_bool(vista.pulsar_hechizo("remiendo")).is_true()
	var casilla_maestro: Vector2i = _casilla_de(vista, Maestro.ID)
	vista.sobre_casilla(casilla_maestro)
	var curacion: Dictionary = vista.hechizo_mostrado()
	assert_array(curacion.keys()).is_equal([""])
	assert_str((runner.find_child("PanelDesglose") as Label).text).contains("3 → 7")
	assert_bool(vista.clic_casilla(casilla_maestro)).is_true()
	var evento: Dictionary = _ultimo(vista, "remiendo")
	assert_dict(curacion[""]["evento"]).is_equal(evento)


# (2) y (3) Lanzadera: el hover muestra empujar y atraer con su destino marcado;
# con el mouse real, el clic derecho atrae y lo mostrado es el evento registrado.
# Despues, una adyacente contra el borde: solo empujar, con choque, igual al evento.
func test_hover_y_clics_de_la_lanzadera() -> void:
	var runner: GdUnitSceneRunner = _vista(_datos())
	await runner.simulate_frames(1)
	var vista: VistaCombate = runner.scene()
	_hasta_el_maestro(vista)
	# El Maestro se acerca a 2 del Surcon.
	assert_bool(vista.clic_casilla(Vector2i(3, 5))).is_true()
	assert_bool(vista.pulsar_hechizo("lanzadera")).is_true()
	var posicion: Vector2 = _en_pantalla(vista, _SURCON)
	MousePrueba.mover_a(posicion)
	assert_vector(vista.casilla_bajo_mouse()).is_equal(_SURCON)
	var mostrado: Dictionary = vista.hechizo_mostrado()
	assert_array(mostrado.keys()).is_equal(["empujar", "atraer"])
	assert_array(_ordenadas(vista.casillas_destino_hechizo())).is_equal([Vector2i(3, 2), Vector2i(3, 4)])
	var destinos: TileMapLayer = runner.find_child("DestinosHechizo")
	assert_vector(destinos.get_cell_atlas_coords(Vector2i(3, 4))).is_equal(_MARCA_DESTINO)
	# Clic derecho: atrae.
	MousePrueba.clic_en(posicion, MOUSE_BUTTON_RIGHT, MOUSE_BUTTON_MASK_RIGHT)
	var evento: Dictionary = _ultimo(vista, "lanzadera")
	assert_str(evento["sentido"]).is_equal("atraer")
	assert_dict(mostrado["atraer"]["evento"]).is_equal(evento)
	assert_array(mostrado["atraer"]["destaparia"]).is_empty()
	assert_vector(_casilla_de(vista, "surcon_s1")).is_equal(Vector2i(3, 4))

	# Siguiente turno: el Surcon queda adyacente contra el borde de abajo.
	assert_bool(vista.pulsar_terminar()).is_true()
	_hasta_el_maestro(vista)
	var plantel: Plantel = vista.combate().contexto().plantel
	plantel.maestro.posicion = Vector2i(3, 6)
	plantel.criatura("surcon_s1").posicion = Vector2i(3, 7)
	plantel.criatura("rodauva_1").posicion = Vector2i(0, 0)
	vista.redibujar()
	assert_bool(vista.pulsar_hechizo("lanzadera")).is_true()
	vista.sobre_casilla(Vector2i(3, 7))
	mostrado = vista.hechizo_mostrado()
	assert_array(mostrado.keys()).is_equal(["empujar"])
	assert_bool(mostrado["empujar"]["evento"]["choque"]).is_true()
	assert_array(vista.casillas_destino_hechizo()).is_empty()
	# El derecho (atraer a una adyacente) no hace nada; el izquierdo empuja.
	assert_bool(vista.clic_casilla(Vector2i(3, 7), true)).is_false()
	assert_bool(vista.clic_casilla(Vector2i(3, 7))).is_true()
	assert_dict(mostrado["empujar"]["evento"]).is_equal(_ultimo(vista, "lanzadera"))
	assert_str((runner.find_child("Sucesos") as Label).text).contains("[FALTA: lanzadera.choque.obstaculo]")


# (3) Fuera del modo hechizo, el clic derecho del mouse no hace nada.
func test_clic_derecho_fuera_del_modo() -> void:
	var runner: GdUnitSceneRunner = _vista(_datos())
	await runner.simulate_frames(1)
	var vista: VistaCombate = runner.scene()
	_hasta_el_maestro(vista)
	var lineas: int = vista.combate().registro().lineas().size()
	var posicion: Vector2 = _en_pantalla(vista, Vector2i(3, 5))
	MousePrueba.mover_a(posicion)
	MousePrueba.clic_en(posicion, MOUSE_BUTTON_RIGHT, MOUSE_BUTTON_MASK_RIGHT)
	assert_int(vista.combate().registro().lineas().size()).is_equal(lineas)
	assert_vector(_casilla_de(vista, Maestro.ID)).is_equal(Vector2i(3, 6))
	# El izquierdo, en cambio, mueve.
	MousePrueba.clic_en(posicion, MOUSE_BUTTON_LEFT, MOUSE_BUTTON_MASK_LEFT)
	assert_vector(_casilla_de(vista, Maestro.ID)).is_equal(Vector2i(3, 5))


# (3) Una partida con los tres hechizos jugada por la vista: la grabacion que
# guarda GuardadoCombate valida contra su esquema y se reproduce igual.
func test_tres_hechizos_se_graban_y_se_reproducen_igual() -> void:
	var datos: Dictionary = _datos()
	var runner: GdUnitSceneRunner = _vista(datos)
	await runner.simulate_frames(1)
	var vista: VistaCombate = runner.scene()
	_hasta_el_maestro(vista)
	assert_bool(vista.pulsar_hechizo("martillazo")).is_true()
	assert_bool(vista.clic_casilla(_casilla_de(vista, "surcon_s1"))).is_true()
	assert_bool(vista.pulsar_terminar()).is_true()
	_hasta_el_maestro(vista)
	assert_bool(vista.pulsar_hechizo("remiendo")).is_true()
	assert_bool(vista.clic_casilla(_casilla_de(vista, Maestro.ID))).is_true()
	assert_bool(vista.pulsar_terminar()).is_true()
	_hasta_el_maestro(vista)
	assert_bool(vista.pulsar_hechizo("lanzadera")).is_true()
	assert_bool(vista.clic_casilla(_casilla_de(vista, "rodauva_1"))).is_true()
	assert_str(_ultimo(vista, "lanzadera")["sentido"]).is_equal("empujar")
	var tipos: Array = []
	for linea in vista.combate().registro().lineas():
		if linea["tipo"] == "accion" and linea["accion"]["tipo"] == "hechizo":
			tipos.append(linea["accion"]["hechizo"])
	assert_array(tipos).is_equal(["martillazo", "remiendo", "lanzadera"])

	var carpeta: String = create_temp_dir("t22_hechizos")
	var base: String = GuardadoCombate.guardar(vista.combate(), carpeta)
	assert_str(base).is_not_empty()
	var esquema: Dictionary = Cargador.new().esquema_resuelto(_CARPETA_DATOS, "grabacion")["esquema"]
	var validacion: Dictionary = Validador.new().validar(
			JSON.parse_string(FileAccess.get_file_as_string(base + ".json")), esquema, "grabacion")
	assert_array(validacion["errores"]).override_failure_message(str(validacion["errores"])).is_empty()
	var reproduccion: Reproductor = Reproductor.reproducir(Grabacion.desde_diccionario(validacion["datos"]), datos)
	assert_str(reproduccion.error).is_empty()
	assert_array(Array(reproduccion.combate.registro().lineas_json())).is_equal(
			Array(vista.combate().registro().lineas_json()))
