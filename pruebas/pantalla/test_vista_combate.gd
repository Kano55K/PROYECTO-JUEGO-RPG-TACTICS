extends GdUnitTestSuite

# Arquitectura.md A.3, A.6 y B.2 (T13, sesion 1): la vista de combate con los
# escenarios reales de datos/ (se crean y se pueden usar; no compara numeros),
# con el runner de escenas de GdUnit4.
const _ESCENA: String = "res://pantalla/combate/vista_combate.tscn"
const _CARPETA_DATOS: String = "res://datos"
const _PREFIJO_ESCENARIOS: String = "escenarios/"


func _datos() -> Dictionary:
	var carga: Dictionary = Cargador.new().cargar_carpeta(_CARPETA_DATOS)
	assert_array(carga["errores"]).override_failure_message(str(carga["errores"])).is_empty()
	return carga["datos"]


func _vista(escenario: Dictionary, datos: Dictionary) -> GdUnitSceneRunner:
	# Con una instancia, el runner no la libera: auto_free la libera al terminar.
	var runner: GdUnitSceneRunner = scene_runner(auto_free(load(_ESCENA).instantiate()))
	(runner.scene() as VistaCombate).empezar(escenario, datos)
	return runner


func _rutas_escenarios(datos: Dictionary) -> Array[String]:
	var rutas: Array[String] = []
	for ruta in datos.keys():
		if (ruta as String).begins_with(_PREFIJO_ESCENARIOS):
			rutas.append(ruta)
	rutas.sort()
	return rutas


# (3) La vista de cada uno de los 11 escenarios se crea sin errores y queda
# esperando al jugador (la IA ya jugo hasta su primer turno).
# (4) Cada unidad esta en map_to_local de su casilla, y local_to_map de su
# posicion da la casilla.
func test_once_escenarios_se_dibujan_en_su_casilla() -> void:
	var datos: Dictionary = _datos()
	var rutas: Array[String] = _rutas_escenarios(datos)
	assert_int(rutas.size()).is_equal(11)
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
# ColaIniciativa del combate, con Caza y Cuenta y la entrada actual resaltada.
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
	assert_array(marcas).contains(["caza", "cuenta"])
	assert_str(filas[marcas.find("caza")].text).contains("Caza")
	assert_str(filas[marcas.find("cuenta")].text).contains("Cuenta")


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
