extends GdUnitTestSuite

# Arquitectura.md B.3 (T23), A.7 y D-011: los eventos `distancia_maestro` y
# `encierro`, en un combate real con fixtures (A.6). Sistema.md 11.9, metricas
# 13 y 14. Tests (1) y (2) del criterio de terminado; las consultas del Tablero
# que los calculan (y el caso null) estan en test_tablero.gd.
const _ESCENARIO: String = "res://pruebas/fixtures/combate/escenario_eventos_metricas.json"


func _escenario() -> Dictionary:
	var lectura: Dictionary = LectorFixture.leer(_ESCENARIO, "escenario")
	assert_array(lectura["errores"] as Array).override_failure_message(str(lectura["errores"])).is_empty()
	return lectura["datos"]


func _contexto(escenario: Dictionary) -> ContextoCombate:
	var carga: Dictionary = DatosFixture.cargar()
	assert_array(carga["errores"] as Array).is_empty()
	var contexto: ContextoCombate = ContextoCombate.armar(escenario, carga["datos"])
	assert_bool(contexto.valido).is_true()
	return contexto


func _lineas(combate: Combate) -> Array[Dictionary]:
	return combate.registro().lineas()


# Termina turnos del jugador hasta el turno de `unidad_id` en la ronda pedida
# (sin terminarlo).
func _hasta_turno(combate: Combate, unidad_id: String, ronda: int) -> void:
	for _i in range(100):
		assert_str(combate.error()).is_empty()
		if combate.turno_actual().unidad_id == unidad_id and (combate.instantanea()["ronda"] as int) == ronda:
			return
		assert_bool(combate.aplicar(Accion.terminar()).valida).is_true()
	fail("no llego al turno de %s en la ronda %d" % [unidad_id, ronda])


func _terminar(combate: Combate) -> void:
	assert_bool(combate.aplicar(Accion.terminar()).valida).is_true()
	assert_str(combate.error()).is_empty()


# Los eventos registrados desde el indice `desde`.
func _desde(combate: Combate, desde: int) -> Array[Dictionary]:
	var lineas: Array[Dictionary] = _lineas(combate)
	return lineas.slice(desde)


# (1) Detras de cada fin_turno del Maestro va distancia_maestro, con lo que da
# el Tablero en ese momento; un turno de criatura no lo escribe.
func test_distancia_maestro_detras_de_cada_fin_turno_del_maestro() -> void:
	var combate: Combate = Combate.empezar(_contexto(_escenario()))
	for ronda in [1, 2, 3]:
		_hasta_turno(combate, Maestro.ID, ronda)
		var antes: int = _lineas(combate).size()
		_terminar(combate)
		# Despues del Maestro solo queda el Surcon (Velocidad 2), de la tribu: el
		# combate lo espera sin mover a nadie, asi el Plantel es el del fin_turno.
		assert_str(combate.turno_actual().unidad_id).is_equal("surcon_1")
		var plantel: Plantel = combate.contexto().plantel
		var esperada: Variant = combate.contexto().tablero.distancia_a_enemiga_de_pie(plantel.maestro.posicion,
				Criatura.Bando.TRIBU, plantel)
		var nuevos: Array[Dictionary] = _desde(combate, antes)
		var tipos: Array = nuevos.map(func(linea: Dictionary) -> String: return linea["tipo"])
		assert_str(tipos[tipos.find("fin_turno") + 1]).is_equal("distancia_maestro")
		var evento: Dictionary = nuevos[tipos.find("distancia_maestro")]
		assert_int(evento["distancia"]).is_equal(esperada)
		assert_int(evento["ronda"]).is_equal(ronda)

	# Uno por cada fin_turno del Maestro, y nunca detras de otro.
	var lineas: Array[Dictionary] = _lineas(combate)
	var del_maestro: int = 0
	var distancias: int = 0
	for i in range(lineas.size()):
		if lineas[i]["tipo"] == "fin_turno" and lineas[i]["unidad"] == Maestro.ID:
			del_maestro += 1
		if lineas[i]["tipo"] == "distancia_maestro":
			distancias += 1
			assert_dict(lineas[i - 1]).contains_key_value("tipo", "fin_turno").contains_key_value("unidad", Maestro.ID)
	assert_int(distancias).is_equal(del_maestro)
	assert_int(del_maestro).is_equal(3)


# (1) Con una oculta mas cerca que la otra enemiga, la distancia es a la oculta
# (esta de pie: Objetivos.de_pie).
func test_la_oculta_cuenta() -> void:
	var contexto: ContextoCombate = _contexto(_escenario())
	var zancajunco: Criatura = contexto.plantel.criatura("zancajunco_s1")
	var combate: Combate = Combate.empezar(contexto)
	_hasta_turno(combate, Maestro.ID, 1)
	# Lo que haya hecho en su turno, la Zancajunco queda oculta y a 2 del Maestro.
	zancajunco.posicion = Vector2i(1, 2)
	zancajunco.oculta = true
	var antes: int = _lineas(combate).size()
	_terminar(combate)
	var evento: Dictionary = _desde(combate, antes).filter(
			func(linea: Dictionary) -> bool: return linea["tipo"] == "distancia_maestro")[0]
	assert_int(evento["distancia"]).is_equal(2)


# (2) encierro: el Maestro en [1,0] tiene el borde arriba y a la tribu en sus
# otras 3 ortogonales (una caida entre ellas): lo escribe, aunque sus
# diagonales esten libres. La Rodauva, en la esquina con [0,1] libre, no.
func test_encierro() -> void:
	var escenario: Dictionary = _escenario()
	# La Ocarra de la tribu empieza caida en [1,1]: sigue ocupando la casilla.
	((escenario["tribu"] as Array)[2] as Dictionary)["vida"] = 0
	var combate: Combate = Combate.empezar(_contexto(escenario))
	assert_int(combate.contexto().plantel.criatura("ocarra_1").estado).is_equal(Criatura.Estado.CAIDA)
	_hasta_turno(combate, "rodauva_1", 1)
	var antes: int = _lineas(combate).size()
	_terminar(combate)
	_hasta_turno(combate, Maestro.ID, 1)
	var de_la_rodauva: Array[Dictionary] = _desde(combate, antes)
	assert_bool(de_la_rodauva.any(func(linea: Dictionary) -> bool: return linea["tipo"] == "encierro")).is_false()

	antes = _lineas(combate).size()
	_terminar(combate)
	var nuevos: Array[Dictionary] = _desde(combate, antes)
	var tipos: Array = nuevos.map(func(linea: Dictionary) -> String: return linea["tipo"])
	assert_array(tipos.slice(0, 4)).is_equal(["accion", "fin_turno", "distancia_maestro", "encierro"])
	assert_dict(nuevos[3]).contains_key_value("unidad", Maestro.ID).contains_key_value("casilla", [1, 0])

	# Con [1,1] libre, ya no.
	var libre: Dictionary = _escenario()
	((libre["tribu"] as Array)[2] as Dictionary)["posicion"] = [2, 5]
	var sin_encierro: Combate = Combate.empezar(_contexto(libre))
	_hasta_turno(sin_encierro, Maestro.ID, 1)
	_terminar(sin_encierro)
	assert_bool(_lineas(sin_encierro).any(func(linea: Dictionary) -> bool: return linea["tipo"] == "encierro")) \
			.is_false()
