extends GdUnitTestSuite

# Arquitectura.md B.2.1 (T40, sesion 2, test 6): el ritmo de la IA. La vista
# muestra de a uno los pasos que el nucleo ya resolvio (SecuenciaIA) y al final
# se redibuja desde el nucleo. Con pausa 0 no anima; con `saltar` o dejando
# correr la pausa, el dibujo final es el mismo. Fixtures (A.6): escenario_c.
const _ESCENA: String = "res://pantalla/combate/vista_combate.tscn"
const _ESCENARIO: String = "res://pruebas/fixtures/combate/escenario_c.json"
const _TEXTOS: String = "res://pruebas/fixtures/pantalla/es_rasgos.json"
# Presentacion: una pausa que no llega a correr durante el test.
const _PAUSA_LARGA: float = 100.0
const _PAUSA_CORTA: float = 0.01
# Corta un combate en el que la IA nunca se mueve ni ataca.
const _TOPE_TERMINAR: int = 20


func _vista(pausa: float) -> GdUnitSceneRunner:
	var lectura: Dictionary = DatosFixture.cargar()
	assert_array(lectura["errores"]).is_empty()
	var datos: Dictionary = lectura["datos"]
	datos["textos/es.json"] = LectorFixture.leer(_TEXTOS, "textos")["datos"]
	var escenario: Dictionary = LectorFixture.leer(_ESCENARIO, "escenario")["datos"]
	var runner: GdUnitSceneRunner = scene_runner(auto_free(load(_ESCENA).instantiate()))
	var vista: VistaCombate = runner.scene()
	vista.pausa_ia = pausa
	vista.empezar(escenario, datos)
	return runner


# Manda `terminar` hasta que, despues de uno, la IA se mueve o ataca. Devuelve
# cuantos mando.
func _terminar_hasta_la_ia(vista: VistaCombate) -> int:
	for i in range(_TOPE_TERMINAR):
		var antes: int = vista.combate().registro().lineas().size()
		assert_bool(vista.pulsar_terminar()).is_true()
		if not SecuenciaIA.pasos(vista.combate().registro().lineas(), antes).is_empty():
			return i + 1
	fail("la IA nunca se movio ni ataco")
	return 0


# Lo que se ve: cada ficha (casilla, vida y color), las filas de la cola, los
# sucesos, los botones y las marcas (ordenadas: get_used_cells no tiene orden fijo).
func _dibujo(runner: GdUnitSceneRunner) -> Dictionary:
	var vista: VistaCombate = runner.scene()
	var fichas: Dictionary = {}
	for ficha in vista.fichas():
		fichas[ficha.unidad_id] = [vista.tablero().local_to_map(ficha.position), ficha.texto_vida(), ficha.modulate]
	var cola: Array[String] = []
	for fila in vista.filas_cola():
		cola.append(fila.text)
	var marcas: TileMapLayer = runner.find_child("Marcas")
	return {
		"fichas": fichas,
		"cola": cola,
		"sucesos": (runner.find_child("Sucesos") as Label).text,
		"botones": (runner.find_child("Botones") as Control).visible,
		"marcas": _ordenadas(marcas.get_used_cells()),
	}


# El dibujo coincide con el nucleo: cada ficha en la casilla y con la vida de
# la instantanea.
func _assert_dibujo_del_nucleo(vista: VistaCombate) -> void:
	var foto: Dictionary = vista.combate().instantanea()
	var plantel: Plantel = vista.combate().contexto().plantel
	for ficha in vista.fichas():
		var casilla: Variant = foto["maestro"]["posicion"]
		var vida: int = plantel.maestro.vida
		if ficha.unidad_id != Maestro.ID:
			for criatura in foto["criaturas"]:
				if criatura["id"] == ficha.unidad_id:
					casilla = criatura["posicion"]
					vida = criatura["vida"]
		assert_vector(ficha.position).override_failure_message(ficha.unidad_id) \
				.is_equal(vista.tablero().map_to_local(Vector2i(casilla[0], casilla[1])))
		assert_str(ficha.texto_vida()).override_failure_message(ficha.unidad_id).starts_with("%d/" % vida)


# (6a) Con pausa 0, despues del `terminar` que hace jugar a la IA no hay
# secuencia y el dibujo es el del nucleo.
func test_pausa_cero_dibuja_el_nucleo() -> void:
	var runner: GdUnitSceneRunner = _vista(0.0)
	await runner.simulate_frames(1)
	var vista: VistaCombate = runner.scene()
	_terminar_hasta_la_ia(vista)
	assert_bool(vista.en_secuencia()).is_false()
	assert_bool(vista.combate().esperando_jugador()).is_true()
	_assert_dibujo_del_nucleo(vista)


# (6b) Con una pausa larga, el mismo `terminar` deja la secuencia en curso: el
# primer paso ya se ve, la entrada de juego esta bloqueada y F3 sigue andando.
# `saltar` (accion del InputMap) la termina con el mismo dibujo que con pausa 0.
func test_saltar_deja_el_mismo_dibujo() -> void:
	var runner_cero: GdUnitSceneRunner = _vista(0.0)
	await runner_cero.simulate_frames(1)
	var veces: int = _terminar_hasta_la_ia(runner_cero.scene())
	var esperado: Dictionary = _dibujo(runner_cero)

	var runner: GdUnitSceneRunner = _vista(_PAUSA_LARGA)
	await runner.simulate_frames(1)
	var vista: VistaCombate = runner.scene()
	for _i in range(veces - 1):
		assert_bool(vista.pulsar_terminar()).is_true()
		assert_bool(vista.en_secuencia()).is_false()
	var antes: int = vista.combate().registro().lineas().size()
	assert_bool(vista.pulsar_terminar()).is_true()
	assert_bool(vista.en_secuencia()).is_true()

	# El primer paso, con lo que dice el registro.
	var primero: Dictionary = SecuenciaIA.pasos(vista.combate().registro().lineas(), antes)[0]
	var marcas: TileMapLayer = runner.find_child("Marcas")
	if primero["tipo"] == SecuenciaIA.MOVIMIENTO:
		var actua: FichaUnidad = runner.find_child(primero["unidad"])
		assert_vector(actua.position).is_equal(vista.tablero().map_to_local(primero["hasta"]))
		assert_array(marcas.get_used_cells()).is_equal([primero["hasta"]])
	else:
		assert_int(marcas.get_used_cells().size()).is_equal(1)

	# Bloqueado: clics, terminar, activas y los botones.
	var turno: Turno = vista.combate().turno_actual()
	assert_bool(vista.clic_casilla(turno.casillas_para_mover()[0])).is_false()
	assert_bool(vista.pulsar_terminar()).is_false()
	assert_bool(vista.pulsar_activa(LecturaCombate.ACTIVA_HACERSE_JUNCO)).is_false()
	assert_bool((runner.find_child("Botones") as Control).visible).is_false()
	assert_object(vista.combate().turno_actual()).is_same(turno)

	# F3 anda durante la secuencia.
	var depuracion: Control = runner.find_child("PanelDepuracion")
	var visible_antes: bool = depuracion.visible
	_mandar_accion("depuracion")
	await runner.simulate_frames(2)
	assert_bool(depuracion.visible).is_equal(not visible_antes)
	_mandar_accion("depuracion")
	await runner.simulate_frames(2)

	_mandar_accion("saltar")
	await runner.simulate_frames(2)
	assert_bool(vista.en_secuencia()).is_false()
	assert_dict(_dibujo(runner)).is_equal(esperado)
	_assert_dibujo_del_nucleo(vista)


# (6c) Con una pausa corta, dejando correr la secuencia hasta el final, el
# dibujo es el mismo que con pausa 0.
func test_la_secuencia_termina_sola() -> void:
	var runner_cero: GdUnitSceneRunner = _vista(0.0)
	await runner_cero.simulate_frames(1)
	_terminar_hasta_la_ia(runner_cero.scene())
	var esperado: Dictionary = _dibujo(runner_cero)

	var runner: GdUnitSceneRunner = _vista(_PAUSA_CORTA)
	await runner.simulate_frames(1)
	var vista: VistaCombate = runner.scene()
	_terminar_hasta_la_ia(vista)
	assert_bool(vista.en_secuencia()).is_true()
	for _i in range(200):
		if not vista.en_secuencia():
			break
		await runner.simulate_frames(1, 20)
	assert_bool(vista.en_secuencia()).is_false()
	assert_dict(_dibujo(runner)).is_equal(esperado)
	_assert_dibujo_del_nucleo(vista)


func _mandar_accion(accion: String) -> void:
	var evento: InputEventAction = InputEventAction.new()
	evento.action = accion
	evento.pressed = true
	Input.parse_input_event(evento)


func _ordenadas(casillas: Array[Vector2i]) -> Array[Vector2i]:
	var copia: Array[Vector2i] = casillas.duplicate()
	copia.sort_custom(func(a: Vector2i, b: Vector2i) -> bool: return a.y < b.y or (a.y == b.y and a.x < b.x))
	return copia
