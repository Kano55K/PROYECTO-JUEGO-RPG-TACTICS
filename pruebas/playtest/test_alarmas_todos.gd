extends GdUnitTestSuite

# T33, sesion 2, criterios (7) y (9): las alarmas de "todos" (distancia del
# Maestro y activas) y la de "C y E" (encierro), en el borde. La activa y el
# encierro se reconocen por el efecto de la ficha, nunca por el id de la
# especie. En el escenario C de la fixture, rodauva_1 (erizarse), ocarra_1 y
# zancajunco_1 (ocultarse) empiezan sueltas; el Tasajero es tasajero_s1.


func _estado(partidas: Array[Dictionary], escenario: String, id: String, variante: Dictionary = {}) -> Dictionary:
	for partida in partidas:
		var errores: Array[Dictionary] = MesaPlaytest.errores(partida)
		assert_array(errores).override_failure_message(str(errores)).is_empty()
	var alarma: Dictionary = MesaPlaytest.alarma(MesaPlaytest.calcular(partidas), escenario, id, variante)
	assert_dict(alarma).override_failure_message(id).is_not_empty()
	return alarma


func _assert_alarma(alarma: Dictionary, estado: String, valor: Variant, n: int) -> void:
	var mensaje: String = str(alarma)
	assert_str(alarma["estado"] as String).override_failure_message(mensaje).is_equal(estado)
	assert_that(alarma["valor"]).override_failure_message(mensaje).is_equal(valor)
	assert_int(alarma["n"] as int).override_failure_message(mensaje).is_equal(n)


# --- Todos: distancia media del Maestro mayor a 3 (metrica 13, decimas) -------

func _lote_distancia(lejos: int) -> Array[Dictionary]:
	var partidas: Array[Dictionary] = MesaPlaytest.lote("b_muro", 11)
	for i in range(10):
		# 3,1 de promedio es "mayor a 3"; 3,0 no.
		MesaPlaytest.metricas(partidas[i])["distancia_maestro"] = {"turnos": 10, "suma": 31 if i < lejos else 30}
	# La 11 no tuvo turnos del Maestro desde el primer ataque: no entra en n.
	return partidas


func test_todos_distancia_del_maestro() -> void:
	_assert_alarma(_estado(_lote_distancia(5), "b_muro", "todos_maestro_se_esconde"),
			AlarmasPlaytest.ESTADO_OK, 50, 10)
	_assert_alarma(_estado(_lote_distancia(6), "b_muro", "todos_maestro_se_esconde"),
			AlarmasPlaytest.ESTADO_ALARMA, 60, 10)


# --- Todos: activa usada en menos del 20 % de los combates disponible (14) ----

func _usos(unidad: String, erizarse: int, hacerse_junco: int) -> Dictionary:
	return {"unidad": unidad, "erizarse": erizarse, "cavar": 0, "hacerse_junco": hacerse_junco}


# C con la tribu y el Tasajero en resultado.unidades; "usada" partidas usan
# Erizarse. Una enemiga que se eriza no cuenta como uso de la tribu.
func _lote_erizarse(usada: int, variante: Dictionary = {}, estado_final: String = "suelta") -> Array[Dictionary]:
	var partidas: Array[Dictionary] = MesaPlaytest.lote("c_tasajero", 10, 3, variante)
	for i in range(10):
		(partidas[i]["resultado"] as Dictionary)["unidades"] = [
			MesaPlaytest.unidad("rodauva_1", "rodauva", "tribu", estado_final),
			MesaPlaytest.unidad("ocarra_1", "ocarra", "tribu"),
			MesaPlaytest.unidad("zancajunco_1", "zancajunco", "tribu"),
			MesaPlaytest.unidad("rodauva_s1", "rodauva", "enemiga"),
		]
		var usos: Array = [_usos("rodauva_s1", 2, 0)]
		if i < usada:
			usos.append(_usos("rodauva_1", 1, 0))
		(MesaPlaytest.metricas(partidas[i])["activas"] as Dictionary)["usos"] = usos
	return partidas


func test_todos_activa_poco_usada() -> void:
	_assert_alarma(_estado(_lote_erizarse(2), "c_tasajero", "todos_activa_erizarse"),
			AlarmasPlaytest.ESTADO_OK, 20, 10)
	_assert_alarma(_estado(_lote_erizarse(1), "c_tasajero", "todos_activa_erizarse"),
			AlarmasPlaytest.ESTADO_ALARMA, 10, 10)


# (9) Sin la criatura de la activa en el tablero, el combate no cuenta: empezo
# guardada (variante) y termino guardada.
func test_activa_no_disponible_no_cuenta() -> void:
	var guardada: Dictionary = {"tribu.rodauva_1.estado": "guardada"}
	_assert_alarma(_estado(_lote_erizarse(0, guardada, "guardada"), "c_tasajero", "todos_activa_erizarse", guardada),
			AlarmasPlaytest.ESTADO_INSUFICIENTE, null, 0)


# (9) Empezo guardada y termino en el tablero: la invocaron, estuvo disponible.
func test_activa_invocada_esta_disponible() -> void:
	var guardada: Dictionary = {"tribu.rodauva_1.estado": "guardada"}
	_assert_alarma(_estado(_lote_erizarse(1, guardada, "caida"), "c_tasajero", "todos_activa_erizarse", guardada),
			AlarmasPlaytest.ESTADO_ALARMA, 10, 10)


# (9) Si la uso, estuvo disponible, aunque haya terminado guardada.
func test_activa_usada_esta_disponible() -> void:
	var guardada: Dictionary = {"tribu.rodauva_1.estado": "guardada"}
	_assert_alarma(_estado(_lote_erizarse(2, guardada, "guardada"), "c_tasajero", "todos_activa_erizarse", guardada),
			AlarmasPlaytest.ESTADO_OK, 100, 2)


# (9) Otra especie con el mismo efecto (especie_prueba, ocultarse) es la misma
# activa; el id de la especie no importa.
func _lote_ocultarse(especie: String, usada: int) -> Array[Dictionary]:
	var partidas: Array[Dictionary] = MesaPlaytest.lote("c_tasajero", 10)
	for i in range(10):
		(partidas[i]["resultado"] as Dictionary)["unidades"] = [MesaPlaytest.unidad("zancajunco_1", especie, "tribu")]
		if i < usada:
			(MesaPlaytest.metricas(partidas[i])["activas"] as Dictionary)["usos"] = [_usos("zancajunco_1", 0, 3)]
	return partidas


func test_activa_por_efecto_y_no_por_id() -> void:
	_assert_alarma(_estado(_lote_ocultarse("especie_prueba", 2), "c_tasajero", "todos_activa_ocultarse"),
			AlarmasPlaytest.ESTADO_OK, 20, 10)
	_assert_alarma(_estado(_lote_ocultarse("especie_prueba", 1), "c_tasajero", "todos_activa_ocultarse"),
			AlarmasPlaytest.ESTADO_ALARMA, 10, 10)
	# Una especie sin el efecto (la Ocarra, alabarda) no la tiene disponible.
	_assert_alarma(_estado(_lote_ocultarse("ocarra", 1), "c_tasajero", "todos_activa_ocultarse"),
			AlarmasPlaytest.ESTADO_INSUFICIENTE, null, 0)


# --- C y E: la unidad con caza_y_cuenta termina encerrada (metrica 14) --------

func _lote_encierro(escenario: String, encerrado: int) -> Array[Dictionary]:
	var partidas: Array[Dictionary] = MesaPlaytest.lote(escenario, 11)
	for i in range(10):
		(partidas[i]["resultado"] as Dictionary)["unidades"] = [
			MesaPlaytest.unidad("rodauva_1", "rodauva", "tribu"),
			MesaPlaytest.unidad("tasajero_s1", "tasajero", "enemiga"),
		]
		# Los encierros de otra unidad no cuentan.
		var encierros: Array = [{"unidad": "rodauva_1", "turnos": 2}]
		if i < encerrado:
			encierros.append({"unidad": "tasajero_s1", "turnos": 1})
		(MesaPlaytest.metricas(partidas[i])["activas"] as Dictionary)["encierros"] = encierros
	# La 11 no tiene ninguna unidad con el efecto: no entra en n.
	return partidas


func test_ce_encierro_de_efecto() -> void:
	_assert_alarma(_estado(_lote_encierro("c_tasajero", 2), "c_tasajero", "ce_encierro"),
			AlarmasPlaytest.ESTADO_OK, 20, 10)
	_assert_alarma(_estado(_lote_encierro("c_tasajero", 3), "c_tasajero", "ce_encierro"),
			AlarmasPlaytest.ESTADO_ALARMA, 30, 10)
	_assert_alarma(_estado(_lote_encierro("e_cobardia", 3), "e_cobardia", "ce_encierro"),
			AlarmasPlaytest.ESTADO_ALARMA, 30, 10)
