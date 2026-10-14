extends GdUnitTestSuite

# Arquitectura.md A.3, A.6 y B.2 (T13, sesiones 1 y 2): la vista de combate con los
# escenarios reales de datos/ (se crean y se pueden usar; no compara numeros),
# con el runner de escenas de GdUnit4.
const _ESCENA: String = "res://pantalla/combate/vista_combate.tscn"
const _CARPETA_DATOS: String = "res://datos"
const _PREFIJO_ESCENARIOS: String = "escenarios/"
# Corta un combate que no termina (la politica del test siempre se acerca).
const _TOPE_ACCIONES: int = 300


func _datos() -> Dictionary:
	var carga: Dictionary = Cargador.new().cargar_carpeta(_CARPETA_DATOS)
	assert_array(carga["errores"]).override_failure_message(str(carga["errores"])).is_empty()
	return carga["datos"]


func _vista(escenario: Dictionary, datos: Dictionary, carpeta_registros: String = "") -> GdUnitSceneRunner:
	# Con una instancia, el runner no la libera: auto_free la libera al terminar.
	var runner: GdUnitSceneRunner = scene_runner(auto_free(load(_ESCENA).instantiate()))
	# Sin carpeta: los combates de estos tests no terminan, no se escribe nada.
	# T40, sesion 2: sin animar la IA (la pausa de los tests vale 0).
	(runner.scene() as VistaCombate).pausa_ia = 0.0
	(runner.scene() as VistaCombate).empezar(escenario, datos, [], carpeta_registros)
	return runner


func _rutas_escenarios(datos: Dictionary) -> Array[String]:
	var rutas: Array[String] = []
	for ruta in datos.keys():
		if (ruta as String).begins_with(_PREFIJO_ESCENARIOS):
			rutas.append(ruta)
	rutas.sort()
	return rutas


# (3) La vista de cada uno de los 10 escenarios se crea sin errores y queda
# esperando al jugador (la IA ya jugo hasta su primer turno).
# (4) Cada unidad esta en map_to_local de su casilla, y local_to_map de su
# posicion da la casilla.
func test_once_escenarios_se_dibujan_en_su_casilla() -> void:
	var datos: Dictionary = _datos()
	var rutas: Array[String] = _rutas_escenarios(datos)
	# A.9, T31: 10 desde que se borro d_rivales_balanza4.json.
	assert_int(rutas.size()).is_equal(10)
	for ruta in rutas:
		var runner: GdUnitSceneRunner = _vista(datos[ruta], datos)
		await runner.simulate_frames(1)
		var vista: VistaCombate = runner.scene()
		var combate: Combate = vista.combate()
		assert_object(combate).override_failure_message(ruta).is_not_null()
		assert_str(combate.error()).override_failure_message(ruta).is_empty()
		assert_bool(combate.esperando_jugador()).override_failure_message(ruta).is_true()
		assert_bool(runner.find_child("Mensaje").visible).override_failure_message(ruta).is_false()

		var casillas: Dictionary = _casillas_en_tablero(combate.instantanea())
		var fichas: Array[FichaUnidad] = vista.fichas()
		assert_int(fichas.size()).override_failure_message(ruta).is_equal(casillas.size())
		var tablero: TileMapLayer = vista.tablero()
		for ficha in fichas:
			var casilla: Vector2i = casillas[ficha.unidad_id]
			assert_vector(ficha.position).override_failure_message(ruta + " " + ficha.unidad_id) \
					.is_equal(tablero.map_to_local(casilla))
			assert_vector(tablero.local_to_map(ficha.position)).override_failure_message(ruta + " " + ficha.unidad_id) \
					.is_equal(casilla)


# (6) La cola que se muestra coincide, entrada por entrada, con la de la
# ColaIniciativa del combate, con la marca de Caza y la entrada actual
# resaltada. Sin la Cuenta en la ronda: reescrito por Sistema.md 11.2.3 v1.3.
func test_cola_mostrada_es_la_del_combate() -> void:
	var datos: Dictionary = _datos()
	var runner: GdUnitSceneRunner = _vista(datos["escenarios/c_tasajero.json"], datos)
	await runner.simulate_frames(1)
	var vista: VistaCombate = runner.scene()
	var entradas: Array[EntradaCola] = vista.combate().cola()
	var filas: Array[Label] = vista.filas_cola()
	assert_int(filas.size()).is_equal(entradas.size())
	var marcas: Array[String] = []
	for i in range(entradas.size()):
		assert_str(filas[i].get_meta("unidad_id")).is_equal(entradas[i].unidad_id)
		assert_str(filas[i].get_meta("marca")).is_equal(entradas[i].marca)
		assert_bool(filas[i].get_meta("actual")).is_equal(i == vista.combate().entrada_actual())
		marcas.append(entradas[i].marca)
	assert_array(marcas).contains(["caza"])
	assert_array(marcas).not_contains(["cuenta"])
	assert_str(filas[marcas.find("caza")].text).contains("Caza")


# id -> casilla de las unidades que se dibujan: con posicion, de pie o caidas.
func _casillas_en_tablero(foto: Dictionary) -> Dictionary:
	var casillas: Dictionary = {}
	var maestro: Dictionary = foto["maestro"]
	if maestro["posicion"] != null:
		casillas[Maestro.ID] = Vector2i(maestro["posicion"][0], maestro["posicion"][1])
	for criatura in foto["criaturas"]:
		if criatura["posicion"] != null and criatura["estado"] in ["suelta", "caida"]:
			casillas[criatura["id"]] = Vector2i(criatura["posicion"][0], criatura["posicion"][1])
	return casillas


# (8) El desglose que se muestra con el mouse sobre una objetivo es igual al del
# evento `ataque` del registro cuando se la golpea.
func test_desglose_mostrado_es_el_del_ataque() -> void:
	var datos: Dictionary = _datos()
	var runner: GdUnitSceneRunner = _vista(datos["escenarios/a_dia_1.json"], datos, create_temp_dir("t13_desglose"))
	await runner.simulate_frames(1)
	var vista: VistaCombate = runner.scene()
	for _i in range(_TOPE_ACCIONES):
		assert_bool(vista.combate().esperando_jugador()).is_true()
		var turno: Turno = vista.combate().turno_actual()
		var objetivos: Array[String] = turno.objetivos_para_atacar()
		if objetivos.is_empty():
			_acercarse(vista)
			vista.pulsar_terminar()
			continue
		var casilla: Vector2i = _casilla_de(vista.combate().instantanea(), objetivos[0])
		vista.sobre_casilla(casilla)
		var mostrado: Dictionary = vista.desglose_mostrado()
		assert_dict(mostrado).is_not_empty()
		vista.clic_casilla(casilla)
		var ataque: Dictionary = _ultimo_evento(vista.combate().registro(), "ataque")
		assert_dict(ataque).is_not_empty()
		assert_str(ataque["atacante"]).is_equal(turno.unidad_id)
		assert_dict(ataque["desglose"]).is_equal(mostrado)
		return
	fail("nunca hubo una objetivo a tiro")


# (9) Jugar A hasta el final mandando acciones por la vista guarda la grabacion
# y el registro, y reproducir esa grabacion con el Reproductor da el mismo registro.
func test_jugar_a_guarda_y_se_reproduce_igual() -> void:
	var datos: Dictionary = _datos()
	var escenario: Dictionary = datos["escenarios/a_dia_1.json"]
	var carpeta: String = create_temp_dir("t13_jugar_a")
	var runner: GdUnitSceneRunner = _vista(escenario, datos, carpeta)
	await runner.simulate_frames(1)
	var vista: VistaCombate = runner.scene()
	for _i in range(_TOPE_ACCIONES):
		if vista.combate().terminado():
			break
		assert_bool(vista.combate().esperando_jugador()).override_failure_message(vista.combate().error()).is_true()
		var turno: Turno = vista.combate().turno_actual()
		var objetivos: Array[String] = turno.objetivos_para_atacar()
		if not objetivos.is_empty():
			vista.clic_casilla(_casilla_de(vista.combate().instantanea(), objetivos[0]))
		else:
			_acercarse(vista)
		if not vista.combate().terminado():
			vista.pulsar_terminar()
	assert_bool(vista.combate().terminado()).is_true()
	await runner.simulate_frames(1)
	assert_bool(runner.find_child("PantallaResultado").visible).is_true()

	var base: String = carpeta.path_join("%s_%d_1" % [escenario["id"], escenario["semilla"]])
	assert_bool(FileAccess.file_exists(base + ".json")).override_failure_message(base).is_true()
	assert_bool(FileAccess.file_exists(base + ".jsonl")).override_failure_message(base).is_true()
	var guardadas: PackedStringArray = FileAccess.get_file_as_string(base + ".jsonl").split("\n", false)
	assert_array(Array(guardadas)).is_equal(Array(vista.combate().registro().lineas_json()))

	var esquema: Dictionary = Cargador.new().esquema_resuelto(_CARPETA_DATOS, "grabacion")["esquema"]
	var validacion: Dictionary = Validador.new().validar(
			JSON.parse_string(FileAccess.get_file_as_string(base + ".json")), esquema, "grabacion")
	assert_array(validacion["errores"]).override_failure_message(str(validacion["errores"])).is_empty()
	var reproduccion: Reproductor = Reproductor.reproducir(Grabacion.desde_diccionario(validacion["datos"]), datos)
	assert_str(reproduccion.error).is_empty()
	assert_bool(reproduccion.aviso_huella).is_false()
	assert_array(Array(reproduccion.combate.registro().lineas_json())).is_equal(Array(guardadas))


# T40 (test 7): jugar C hasta el final por la vista, con activas y animando la
# IA (pausa larga y `saltar` en cada secuencia), guarda una grabacion que se
# reproduce igual: animar no cambia nada del combate. Politica: atacar si hay
# objetivo; si no, la primera activa habilitada; si no, acercarse.
# Cambia de danio en T16 por Sistema.md 10.2: en las rondas 1 y 2 la Ocarra
# leal y despues el Maestro encadenan sobre el Tasajero (afines, +70: el Maestro
# pega 8). Ninguna asercion depende del danio, asi que solo cambia este comentario.
func test_jugar_c_con_activas_se_reproduce_igual() -> void:
	var datos: Dictionary = _datos()
	var escenario: Dictionary = datos["escenarios/c_tasajero.json"]
	var carpeta: String = create_temp_dir("t40_jugar_c")
	var runner: GdUnitSceneRunner = _vista(escenario, datos, carpeta)
	await runner.simulate_frames(1)
	var vista: VistaCombate = runner.scene()
	# Presentacion: una pausa que no llega a correr durante el test.
	vista.pausa_ia = 100.0
	var secuencias: int = 0
	for _i in range(_TOPE_ACCIONES):
		if vista.combate().terminado():
			break
		assert_bool(vista.combate().esperando_jugador()).override_failure_message(vista.combate().error()).is_true()
		var turno: Turno = vista.combate().turno_actual()
		var objetivos: Array[String] = turno.objetivos_para_atacar()
		if not objetivos.is_empty():
			vista.clic_casilla(_casilla_de(vista.combate().instantanea(), objetivos[0]))
		elif not _usar_activa(vista):
			_acercarse(vista)
		if not vista.combate().terminado():
			assert_bool(vista.pulsar_terminar()).is_true()
		if vista.saltar():
			secuencias += 1
	assert_bool(vista.combate().terminado()).is_true()
	assert_int(secuencias).is_greater(0)
	await runner.simulate_frames(1)
	assert_bool(runner.find_child("PantallaResultado").visible).is_true()

	var base: String = carpeta.path_join("%s_%d_1" % [escenario["id"], escenario["semilla"]])
	assert_bool(FileAccess.file_exists(base + ".json")).override_failure_message(base).is_true()
	var guardadas: PackedStringArray = FileAccess.get_file_as_string(base + ".jsonl").split("\n", false)
	assert_array(Array(guardadas)).is_equal(Array(vista.combate().registro().lineas_json()))
	var esquema: Dictionary = Cargador.new().esquema_resuelto(_CARPETA_DATOS, "grabacion")["esquema"]
	var validacion: Dictionary = Validador.new().validar(
			JSON.parse_string(FileAccess.get_file_as_string(base + ".json")), esquema, "grabacion")
	assert_array(validacion["errores"]).override_failure_message(str(validacion["errores"])).is_empty()
	# Se usaron activas.
	var tipos: Array = []
	for accion in validacion["datos"]["acciones"]:
		tipos.append(accion["accion"]["tipo"])
	assert_bool(tipos.has("hacerse_junco") or tipos.has("erizarse")).override_failure_message(str(tipos)).is_true()
	var reproduccion: Reproductor = Reproductor.reproducir(Grabacion.desde_diccionario(validacion["datos"]), datos)
	assert_str(reproduccion.error).is_empty()
	assert_bool(reproduccion.aviso_huella).is_false()
	assert_array(Array(reproduccion.combate.registro().lineas_json())).is_equal(Array(guardadas))


# Politica del test 7: la primera activa habilitada, por los botones que se ven
# (Activa_<tipo>). Cavar entra en "elegir casilla" y cava en la primera de
# casillas_para_cavar.
func _usar_activa(vista: VistaCombate) -> bool:
	for hijo in vista.get_node("Interfaz/Botones").get_children():
		var boton: Button = hijo as Button
		if not boton.name.begins_with("Activa_") or boton.disabled:
			continue
		var tipo: String = boton.name.trim_prefix("Activa_")
		if tipo == LecturaCombate.ACTIVA_CAVAR:
			vista.pulsar_activa(tipo)
			return vista.clic_casilla(vista.combate().turno_actual().casillas_para_cavar()[0])
		return vista.pulsar_activa(tipo)
	return false


# Politica del test: mueve a la casilla alcanzable mas cercana a una enemiga.
func _acercarse(vista: VistaCombate) -> void:
	var turno: Turno = vista.combate().turno_actual()
	var casillas: Array[Vector2i] = turno.casillas_para_mover()
	if casillas.is_empty():
		return
	var foto: Dictionary = vista.combate().instantanea()
	var plantel: Plantel = vista.combate().contexto().plantel
	var enemigas: Array[Vector2i] = []
	for criatura in foto["criaturas"]:
		if criatura["estado"] == "suelta" and criatura["posicion"] != null \
				and plantel.criatura(criatura["id"]).bando != Criatura.Bando.TRIBU:
			enemigas.append(Vector2i(criatura["posicion"][0], criatura["posicion"][1]))
	var mejor: Vector2i = casillas[0]
	var mejor_distancia: int = _distancia_minima(mejor, enemigas)
	for casilla in casillas:
		var distancia: int = _distancia_minima(casilla, enemigas)
		if distancia < mejor_distancia:
			mejor = casilla
			mejor_distancia = distancia
	vista.clic_casilla(mejor)


func _distancia_minima(desde: Vector2i, hasta: Array[Vector2i]) -> int:
	var minima: int = 1 << 30
	for casilla in hasta:
		minima = mini(minima, absi(desde.x - casilla.x) + absi(desde.y - casilla.y))
	return minima


func _casilla_de(foto: Dictionary, unidad_id: String) -> Vector2i:
	if unidad_id == Maestro.ID:
		return Vector2i(foto["maestro"]["posicion"][0], foto["maestro"]["posicion"][1])
	for criatura in foto["criaturas"]:
		if criatura["id"] == unidad_id:
			return Vector2i(criatura["posicion"][0], criatura["posicion"][1])
	return Criatura.SIN_POSICION


func _ultimo_evento(registro: RegistroCombate, tipo: String) -> Dictionary:
	var lineas: Array[Dictionary] = registro.lineas()
	for i in range(lineas.size() - 1, -1, -1):
		if lineas[i]["tipo"] == tipo:
			return lineas[i]
	return {}
