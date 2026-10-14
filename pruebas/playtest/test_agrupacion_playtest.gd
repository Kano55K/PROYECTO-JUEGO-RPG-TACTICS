extends GdUnitTestSuite

# T33, sesion 1, criterios (4) y (5): AlarmasPlaytest agrupa por escenario +
# variante sin la semilla (D-015), cuenta jugadores distintos, avisa de las
# semillas fuera de la lista y marca insuficiente lo que no llega a 10 partidas
# con 3 jugadores (Sistema.md 11.9, "Como se mide"). Partidas armadas a mano
# (MesaPlaytest), con los datos de prueba.

const _BALANZA_4: Dictionary = {"maestro.balanza": 4}


func _calcular(partidas: Array[Dictionary]) -> Dictionary:
	for partida in partidas:
		var errores: Array[Dictionary] = MesaPlaytest.errores(partida)
		assert_array(errores).override_failure_message(str(errores)).is_empty()
	return MesaPlaytest.calcular(partidas)


func test_la_mesa_valida_contra_sus_esquemas() -> void:
	var partida: Dictionary = MesaPlaytest.partida("d_rivales_normal", null, 999, _BALANZA_4)
	assert_array(MesaPlaytest.errores(partida)).is_empty()
	assert_that((partida["ficha"] as Dictionary)["indice_semilla"]).is_null()
	partida = MesaPlaytest.partida("d_rivales_normal", "ana", MesaPlaytest.semillas()[2])
	assert_array(MesaPlaytest.errores(partida)).is_empty()
	assert_int((partida["ficha"] as Dictionary)["indice_semilla"] as int).is_equal(3)


# (4) La misma variante con otra semilla es el mismo grupo.
func test_misma_variante_con_otra_semilla_es_el_mismo_grupo() -> void:
	var semillas: Array = MesaPlaytest.semillas()
	var informe: Dictionary = _calcular([
		MesaPlaytest.partida("d_rivales_normal", "ana", semillas[0], _BALANZA_4),
		MesaPlaytest.partida("d_rivales_normal", "ana", semillas[1], _BALANZA_4),
	])
	assert_int((informe["grupos"] as Array).size()).is_equal(1)
	var grupo: Dictionary = MesaPlaytest.grupo(informe, "d_rivales_normal", _BALANZA_4)
	assert_int(grupo["partidas"] as int).is_equal(2)
	assert_array(grupo["semillas"] as Array).is_equal([semillas[0], semillas[1]])
	assert_array(grupo["semillas_fuera"] as Array).is_empty()
	assert_array(informe["avisos"] as Array).is_empty()


# (4) Con otra balanza, otro grupo; y las alarmas de D valen para los dos.
func test_otra_balanza_es_otro_grupo() -> void:
	var informe: Dictionary = _calcular([
		MesaPlaytest.partida("d_rivales_normal", "ana", MesaPlaytest.semillas()[0]),
		MesaPlaytest.partida("d_rivales_normal", "ana", MesaPlaytest.semillas()[0], _BALANZA_4),
	])
	assert_int((informe["grupos"] as Array).size()).is_equal(2)
	assert_int(MesaPlaytest.grupo(informe, "d_rivales_normal")["partidas"] as int).is_equal(1)
	assert_int(MesaPlaytest.grupo(informe, "d_rivales_normal", _BALANZA_4)["partidas"] as int).is_equal(1)
	assert_dict(MesaPlaytest.alarma(informe, "d_rivales_normal", "d_rivales_invisibles")).is_not_empty()
	assert_dict(MesaPlaytest.alarma(informe, "d_rivales_normal", "d_rivales_invisibles", _BALANZA_4)).is_not_empty()


# (4) La semilla nunca es parte de la variante, aunque venga en la ficha.
func test_la_semilla_no_separa_grupos() -> void:
	var con_semilla: Dictionary = _BALANZA_4.duplicate()
	con_semilla["semilla"] = MesaPlaytest.semillas()[4]
	var informe: Dictionary = _calcular([
		MesaPlaytest.partida("d_rivales_normal", "ana", MesaPlaytest.semillas()[3], _BALANZA_4),
		MesaPlaytest.partida("d_rivales_normal", "ana", MesaPlaytest.semillas()[4], con_semilla),
	])
	assert_int((informe["grupos"] as Array).size()).is_equal(1)
	assert_dict((informe["grupos"] as Array)[0]["variante"] as Dictionary).is_equal(_BALANZA_4)


# (4) Una semilla fuera de la lista da su aviso.
func test_semilla_fuera_de_la_lista_da_aviso() -> void:
	var informe: Dictionary = _calcular([
		MesaPlaytest.partida("c_tasajero", "ana", MesaPlaytest.semillas()[0]),
		MesaPlaytest.partida("c_tasajero", "ana", 999),
		MesaPlaytest.partida("c_tasajero", "ana", 999),
	])
	var grupo: Dictionary = MesaPlaytest.grupo(informe, "c_tasajero")
	assert_array(grupo["semillas_fuera"] as Array).is_equal([999])
	var avisos: Array = informe["avisos"]
	assert_int(avisos.size()).is_equal(1)
	assert_dict(avisos[0] as Dictionary).is_equal({"tipo": AlarmasPlaytest.AVISO_SEMILLA_FUERA,
			"escenario": "c_tasajero", "variante": {}, "semilla": 999})


func test_jugadores_distintos_y_orden_de_los_grupos() -> void:
	var partidas: Array[Dictionary] = MesaPlaytest.lote("c_tasajero", 4, 2)
	partidas.append(MesaPlaytest.partida("c_tasajero", null, MesaPlaytest.semillas()[0]))
	partidas.append(MesaPlaytest.partida("b_muro", "ana", MesaPlaytest.semillas()[0]))
	var informe: Dictionary = _calcular(partidas)
	var grupos: Array = informe["grupos"]
	assert_array(grupos.map(func(g: Dictionary) -> String: return g["escenario"])).is_equal(["b_muro", "c_tasajero"])
	# Sin nombre no cuenta como otro jugador.
	assert_int(MesaPlaytest.grupo(informe, "c_tasajero")["jugadores"] as int).is_equal(2)
	assert_int(MesaPlaytest.grupo(informe, "c_tasajero")["partidas"] as int).is_equal(5)


# (5) Con 10 partidas de 3 jugadores se mide.
func test_diez_partidas_de_tres_jugadores_se_miden() -> void:
	var alarma: Dictionary = MesaPlaytest.alarma(_calcular(MesaPlaytest.lote("b_muro", 10)), "b_muro", "b_huir_no_se_lee")
	assert_str(alarma["estado"] as String).is_equal(AlarmasPlaytest.ESTADO_OK)
	assert_int(alarma["valor"] as int).is_equal(100)
	assert_int(alarma["n"] as int).is_equal(10)


# (5) Con 9 partidas: insuficiente, y el valor igual se calcula.
func test_nueve_partidas_es_insuficiente() -> void:
	var alarma: Dictionary = MesaPlaytest.alarma(_calcular(MesaPlaytest.lote("b_muro", 9)), "b_muro", "b_huir_no_se_lee")
	assert_str(alarma["estado"] as String).is_equal(AlarmasPlaytest.ESTADO_INSUFICIENTE)
	assert_int(alarma["valor"] as int).is_equal(100)
	assert_int(alarma["n"] as int).is_equal(9)
	assert_int(alarma["umbral"] as int).is_equal(30)


# (5) Con 10 partidas de 2 jugadores: insuficiente, con valor.
func test_dos_jugadores_es_insuficiente() -> void:
	var partidas: Array[Dictionary] = MesaPlaytest.lote("b_muro", 10, 2)
	for i in range(8):
		(partidas[i]["resultado"] as Dictionary)["desenlace"] = "derrota_por_caida"
	var alarma: Dictionary = MesaPlaytest.alarma(_calcular(partidas), "b_muro", "b_huir_no_se_lee")
	assert_str(alarma["estado"] as String).is_equal(AlarmasPlaytest.ESTADO_INSUFICIENTE)
	assert_int(alarma["valor"] as int).is_equal(20)


# Sin ninguna partida que medir (n = 0): insuficiente, con valor null.
func test_sin_nada_que_medir_es_insuficiente() -> void:
	var alarma: Dictionary = MesaPlaytest.alarma(_calcular(MesaPlaytest.lote("a_dia_1", 10)), "a_dia_1", "a_mismo_tramo")
	assert_str(alarma["estado"] as String).is_equal(AlarmasPlaytest.ESTADO_INSUFICIENTE)
	assert_that(alarma["valor"]).is_null()
	assert_int(alarma["n"] as int).is_equal(0)
