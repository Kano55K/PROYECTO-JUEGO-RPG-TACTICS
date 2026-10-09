extends GdUnitTestSuite

# Arquitectura.md B.2 (T05, criterio 3) y A.6: test de datos reales. Con datos/
# se crea el plantel de los 11 escenarios. No compara contra numeros de
# Sistema.md: la vida maxima se lee de la balanza cargada.
const _CARPETA_DATOS: String = "res://datos"


func _datos() -> Dictionary:
	var resultado: Dictionary = Cargador.new().cargar_carpeta(_CARPETA_DATOS)
	var errores: Array[Dictionary] = resultado["errores"]
	assert_array(errores).override_failure_message(str(errores)).is_empty()
	return resultado["datos"]


func test_once_escenarios_crean_plantel() -> void:
	var datos: Dictionary = _datos()
	var cantidad: int = 0
	for ruta in datos.keys():
		if not (ruta as String).begins_with("escenarios/"):
			continue
		cantidad += 1
		var escenario: Dictionary = datos[ruta]
		var plantel: Plantel = Plantel.desde_datos(datos, escenario)
		assert_object(plantel).override_failure_message(ruta).is_not_null()
		assert_object(plantel.maestro).override_failure_message(ruta).is_not_null()

		var tribu: Array = escenario["tribu"]
		var enemigas: Array = escenario["enemigas"]
		var atacantes: int = 0
		for enemiga in enemigas:
			if (enemiga as Dictionary)["comportamiento"] == "atacante_nocturna":
				atacantes += 1
		assert_int(plantel.criaturas().size()).override_failure_message(ruta).is_equal(tribu.size() + enemigas.size())
		var esperados: int = tribu.size() + atacantes + (escenario["pergaminos_en_blanco"] as int)
		assert_int(plantel.pergaminos().size()).override_failure_message(ruta).is_equal(esperados)
		for criatura in plantel.criaturas():
			assert_object(criatura.especie).override_failure_message(criatura.id).is_not_null()
	assert_int(cantidad).is_equal(11)


# Sistema.md 11.9, F: el Maestro empieza en 6, con la vida maxima de su balanza.
func test_f_maestro_en_6() -> void:
	var datos: Dictionary = _datos()
	var plantel: Plantel = Plantel.desde_datos(datos, datos["escenarios/f_rescate.json"])
	assert_int(plantel.maestro.vida).is_equal(6)
	var tabla: TablaBalanza = TablaBalanza.new(datos["tablas/balanza.json"])
	var fila: Dictionary = tabla.fila(plantel.maestro.balanza)
	assert_int(plantel.maestro.vida_max_real()).is_equal(fila["vida_max_real"] as int)


# Arquitectura.md B.2 (T06) y A.6: con datos/ se crea el tablero de los 11
# escenarios y toda posicion fijada queda dentro.
func test_once_escenarios_crean_tablero() -> void:
	var datos: Dictionary = _datos()
	var cantidad: int = 0
	for ruta in datos.keys():
		if not (ruta as String).begins_with("escenarios/"):
			continue
		cantidad += 1
		var escenario: Dictionary = datos[ruta]
		var tablero: Tablero = Tablero.desde_datos(escenario["tablero"], datos["tablas/combate.json"])
		var plantel: Plantel = Plantel.desde_datos(datos, escenario)
		var posiciones: Array[Vector2i] = [plantel.maestro.posicion]
		for criatura in plantel.criaturas():
			posiciones.append(criatura.posicion)
		for posicion in posiciones:
			if posicion != Criatura.SIN_POSICION:
				assert_bool(tablero.dentro(posicion)).override_failure_message("%s %s" % [ruta, posicion]).is_true()
		assert_array(tablero.despliegue(Criatura.Bando.TRIBU)).override_failure_message(ruta).is_not_empty()
	assert_int(cantidad).is_equal(11)


# Arquitectura.md B.3 (T21, 1b), Sistema.md 11.9 y 2.1: G entra con 4 de mana
# (sueno interrumpido, 2.4) y los otros 10 con la reserva de su balanza, leida
# de la tabla cargada. El mana actual arranca en el de entrada.
func test_t21_mana_de_entrada_de_los_escenarios() -> void:
	var datos: Dictionary = _datos()
	var tabla: TablaBalanza = TablaBalanza.new(datos["tablas/balanza.json"])
	var cantidad: int = 0
	for ruta in datos.keys():
		if not (ruta as String).begins_with("escenarios/"):
			continue
		cantidad += 1
		var maestro: Maestro = Plantel.desde_datos(datos, datos[ruta]).maestro
		var esperado: int = 4 if ruta == "escenarios/g_ataque_nocturno.json" \
				else tabla.fila(maestro.balanza)["reserva_mana"] as int
		assert_int(maestro.mana_entrada).override_failure_message(ruta).is_equal(esperado)
		assert_int(maestro.mana).override_failure_message(ruta).is_equal(esperado)
	assert_int(cantidad).is_equal(11)