extends GdUnitTestSuite

# T33, sesion 2, criterios (7) y (8): los calculos de E a H en el borde, con 10
# partidas de 3 jugadores (justo en el umbral de Sistema.md 11.9 no salta, uno
# mas si), las alarmas de D en el grupo con la balanza 4 y las comparaciones
# entre escenarios con los grupos sin cambios. Los umbrales salen del fixture
# de alarmas (los mismos numeros de 11.9).

const _BALANZA_4: Dictionary = {"maestro.balanza": 4}
const _RODAUVA_GUARDADA: Dictionary = {"tribu.rodauva_1.estado": "guardada"}


func _validas(partidas: Array[Dictionary]) -> void:
	for partida in partidas:
		var errores: Array[Dictionary] = MesaPlaytest.errores(partida)
		assert_array(errores).override_failure_message(str(errores)).is_empty()


func _estado(partidas: Array[Dictionary], escenario: String, id: String, variante: Dictionary = {}) -> Dictionary:
	_validas(partidas)
	var alarma: Dictionary = MesaPlaytest.alarma(MesaPlaytest.calcular(partidas), escenario, id, variante)
	assert_dict(alarma).override_failure_message(id).is_not_empty()
	return alarma


func _assert_alarma(alarma: Dictionary, estado: String, valor: Variant, n: int) -> void:
	var mensaje: String = str(alarma)
	assert_str(alarma["estado"] as String).override_failure_message(mensaje).is_equal(estado)
	assert_that(alarma["valor"]).override_failure_message(mensaje).is_equal(valor)
	assert_int(alarma["n"] as int).override_failure_message(mensaje).is_equal(n)


func _victorias(partidas: Array[Dictionary], cuantas: int) -> void:
	for i in range(partidas.size()):
		(partidas[i]["resultado"] as Dictionary)["desenlace"] = "victoria" if i < cuantas else "derrota_por_caida"


# --- E: acobardadas fuera de 10 a 60 % de las tiradas de la tribu (metrica 6) ---

# 10 partidas con 10 tiradas de la tribu cada una (100 en total), con
# "acobardadas" repartidas. Las tiradas de las enemigas no cuentan.
func _lote_e(escenario: String, acobardadas: int, n: int = 10) -> Array[Dictionary]:
	var partidas: Array[Dictionary] = MesaPlaytest.lote(escenario, n)
	for i in range(n):
		@warning_ignore("integer_division")
		var de_esta: int = acobardadas / n + (1 if i < acobardadas % n else 0)
		var cobardia: Dictionary = MesaPlaytest.metricas(partidas[i])["cobardia"]
		cobardia["tribu"] = {"acobardada": de_esta, "resistida": 10 - de_esta}
		cobardia["enemigas"] = {"acobardada": 5, "resistida": 0}
	return partidas


func test_e_acobardadas_fuera_de_rango() -> void:
	var casos: Array = [[10, AlarmasPlaytest.ESTADO_OK], [9, AlarmasPlaytest.ESTADO_ALARMA],
			[60, AlarmasPlaytest.ESTADO_OK], [61, AlarmasPlaytest.ESTADO_ALARMA]]
	for caso in casos:
		var alarma: Dictionary = _estado(_lote_e("e_cobardia", caso[0]), "e_cobardia", "e_acobardadas")
		_assert_alarma(alarma, caso[1], caso[0], 10)
		assert_dict(alarma["umbral"] as Dictionary).is_equal({"desde": 10, "hasta": 60})


# Vale para las dos variantes de E.
func test_e_acobardadas_vale_para_el_toggle() -> void:
	_assert_alarma(_estado(_lote_e("e_cobardia_afines", 61), "e_cobardia_afines", "e_acobardadas"),
			AlarmasPlaytest.ESTADO_ALARMA, 61, 10)


# Partidas sin tiradas no entran en n.
func test_e_sin_tiradas_no_cuenta() -> void:
	var partidas: Array[Dictionary] = _lote_e("e_cobardia", 30)
	partidas.append(MesaPlaytest.partida("e_cobardia", "j1", MesaPlaytest.semillas()[0]))
	_assert_alarma(_estado(partidas, "e_cobardia", "e_acobardadas"), AlarmasPlaytest.ESTADO_OK, 30, 10)


# --- E: toggle de afines (informativo) ---------------------------------------

func _toggle(sin: int, con: int, n_con: int = 10) -> Dictionary:
	var partidas: Array[Dictionary] = _lote_e("e_cobardia", sin)
	partidas.append_array(_lote_e("e_cobardia_afines", con, n_con))
	# Un grupo de E sin el toggle con cambios no entra en la comparacion.
	for cambiada in _lote_e("e_cobardia", 0):
		(cambiada["ficha"] as Dictionary)["variante"] = _BALANZA_4.duplicate()
		partidas.append(cambiada)
	_validas(partidas)
	var informe: Dictionary = MesaPlaytest.calcular(partidas)
	var toggle: Dictionary = MesaPlaytest.informativa(informe, "e_toggle_afines")
	assert_dict(toggle).is_not_empty()
	# No es una alarma de grupo.
	assert_dict(MesaPlaytest.alarma(informe, "e_cobardia_afines", "e_toggle_afines")).is_empty()
	return toggle


func test_e_toggle_afines_en_el_borde() -> void:
	# [sin, con, resultado]: sin el toggle "se supera el 60%"; con el toggle
	# "queda entre 10% y 60%" (los bordes incluidos).
	var casos: Array = [
		[61, 10, AlarmasPlaytest.RESULTADO_APROBADO],
		[60, 10, AlarmasPlaytest.RESULTADO_NO_APROBADO],
		[61, 9, AlarmasPlaytest.RESULTADO_NO_APROBADO],
		[61, 60, AlarmasPlaytest.RESULTADO_APROBADO],
		[61, 61, AlarmasPlaytest.RESULTADO_NO_APROBADO],
	]
	for caso in casos:
		var toggle: Dictionary = _toggle(caso[0], caso[1])
		var mensaje: String = str(toggle)
		assert_str(toggle["resultado"] as String).override_failure_message(mensaje).is_equal(caso[2])
		assert_dict(toggle["valor"] as Dictionary).override_failure_message(mensaje).is_equal(
				{"escenario": caso[1], "comparado_con": caso[0]})
		assert_str(toggle["escenario"] as String).is_equal("e_cobardia_afines")
		assert_str(toggle["comparado_con"] as String).is_equal("e_cobardia")
		assert_int(toggle["n"] as int).is_equal(10)
		assert_int(toggle["n_comparado"] as int).is_equal(10)


func test_e_toggle_afines_insuficiente() -> void:
	# Con 9 partidas hay 90 tiradas: 9 acobardadas son el 10 %.
	var toggle: Dictionary = _toggle(61, 9, 9)
	assert_str(toggle["resultado"] as String).is_equal(AlarmasPlaytest.ESTADO_INSUFICIENTE)
	assert_dict(toggle["valor"] as Dictionary).is_equal({"escenario": 10, "comparado_con": 61})


# --- F: el Maestro cae sin rescatista (metricas 9 y 12) ----------------------

func _lote_f_rescate(sin_rescatista: int) -> Array[Dictionary]:
	var partidas: Array[Dictionary] = MesaPlaytest.lote("f_rescate", 11)
	for i in range(10):
		var metricas: Dictionary = MesaPlaytest.metricas(partidas[i])
		metricas["caidas"] = [{"unidad": "rodauva_1", "ronda": 2}, {"unidad": Maestro.ID, "ronda": 3}]
		metricas["rescate"] = {"rescatista": null if i < sin_rescatista else "rodauva_1"}
		(partidas[i]["resultado"] as Dictionary)["desenlace"] = "derrota_por_caida"
	# La 11: cae otra, no el Maestro. No entra en n.
	MesaPlaytest.metricas(partidas[10])["caidas"] = [{"unidad": "ocarra_1", "ronda": 2}]
	return partidas


func test_f_maestro_cae_sin_rescatista() -> void:
	_assert_alarma(_estado(_lote_f_rescate(6), "f_rescate", "f_rescate_azaroso"), AlarmasPlaytest.ESTADO_OK, 60, 10)
	_assert_alarma(_estado(_lote_f_rescate(7), "f_rescate", "f_rescate_azaroso"),
			AlarmasPlaytest.ESTADO_ALARMA, 70, 10)


# --- F: ninguna caida guardada en las partidas con caidas (metricas 9 y 10) ---

func _lote_f_guardadas(sin_guardar: int) -> Array[Dictionary]:
	var partidas: Array[Dictionary] = MesaPlaytest.lote("f_rescate", 12)
	for partida in partidas:
		(partida["resultado"] as Dictionary)["unidades"] = [
			MesaPlaytest.unidad("rodauva_1", "rodauva", "tribu"),
			MesaPlaytest.unidad("ocarra_1", "ocarra", "tribu"),
			MesaPlaytest.unidad("zancajunco_s1", "zancajunco", "enemiga"),
		]
	for i in range(10):
		var metricas: Dictionary = MesaPlaytest.metricas(partidas[i])
		metricas["caidas"] = [{"unidad": "ocarra_1", "ronda": 2}]
		if i >= sin_guardar:
			metricas["caidas_guardadas"] = [{"unidad": "ocarra_1", "ronda": 3}]
	# P-050: solo cuentan las caidas de criaturas de la tribu. Ni el Maestro ni
	# una enemiga entran en n.
	MesaPlaytest.metricas(partidas[10])["caidas"] = [{"unidad": Maestro.ID, "ronda": 2}]
	MesaPlaytest.metricas(partidas[11])["caidas"] = [{"unidad": "zancajunco_s1", "ronda": 2}]
	return partidas


func test_f_sin_caidas_guardadas() -> void:
	_assert_alarma(_estado(_lote_f_guardadas(8), "f_rescate", "f_guardar_no_se_lee"),
			AlarmasPlaytest.ESTADO_OK, 80, 10)
	_assert_alarma(_estado(_lote_f_guardadas(9), "f_rescate", "f_guardar_no_se_lee"),
			AlarmasPlaytest.ESTADO_ALARMA, 90, 10)


# --- G: comer en mas del 70 % (destino de la atacante) ------------------------

# fallo_y_comer: cuantas de las que no comen resellan, fallan y despues comen
# (P-051 v1.8: cuentan como sellar).
func _lote_g(comer: int, fallo_y_comer: int = 0) -> Array[Dictionary]:
	var partidas: Array[Dictionary] = MesaPlaytest.lote("g_ataque_nocturno", 12)
	for i in range(10):
		var destino: Dictionary = {"opcion": "comer", "resultado": "comida", "primera_opcion": "comer"}
		if i >= comer + fallo_y_comer:
			destino = {"opcion": "perdonar", "resultado": "perdonada", "primera_opcion": "perdonar"} if i % 2 == 0 \
					else {"opcion": "sellar", "resultado": "sellada", "primera_opcion": "sellar"}
		elif i >= comer:
			destino = {"opcion": "comer", "resultado": "comida", "primera_opcion": "sellar"}
		(partidas[i]["resultado"] as Dictionary)["destino_atacante"] = destino
	# P-051: una derrota (se fue) y una partida sin destino no entran en n.
	(partidas[10]["resultado"] as Dictionary)["desenlace"] = "derrota_por_caida"
	(partidas[10]["resultado"] as Dictionary)["destino_atacante"] = {"opcion": null, "resultado": "se_fue",
			"primera_opcion": null}
	return partidas


func test_g_comer_siempre() -> void:
	_assert_alarma(_estado(_lote_g(7), "g_ataque_nocturno", "g_comer_siempre"), AlarmasPlaytest.ESTADO_OK, 70, 10)
	_assert_alarma(_estado(_lote_g(8), "g_ataque_nocturno", "g_comer_siempre"), AlarmasPlaytest.ESTADO_ALARMA, 80, 10)


# T45 (P-051, Sistema.md 11.9 v1.8): cuenta la primera opcion elegida. Con 7 que
# comen y 3 que resellan, fallan y despues comen, comer es el 70 %, no el 100 %.
func test_g_fallo_y_comer_cuenta_como_sellar() -> void:
	_assert_alarma(_estado(_lote_g(7, 3), "g_ataque_nocturno", "g_comer_siempre"), AlarmasPlaytest.ESTADO_OK, 70, 10)
	_assert_alarma(_estado(_lote_g(8, 2), "g_ataque_nocturno", "g_comer_siempre"),
			AlarmasPlaytest.ESTADO_ALARMA, 80, 10)


# --- H contra C: victorias de H mas de 20 puntos por encima (desenlace) -------

func _h_contra_c(victorias_h: int, victorias_c: int, n_c: int = 10) -> Dictionary:
	var h: Array[Dictionary] = MesaPlaytest.lote("h_soplo", 10)
	_victorias(h, victorias_h)
	var c: Array[Dictionary] = MesaPlaytest.lote("c_tasajero", n_c)
	_victorias(c, victorias_c)
	# (8) Los grupos con cambios no entran: si C con la Rodauva guardada
	# contara, la diferencia seria otra.
	var c_cambiada: Array[Dictionary] = MesaPlaytest.lote("c_tasajero", 10, 3, _RODAUVA_GUARDADA)
	_victorias(c_cambiada, 0)
	var h_cambiada: Array[Dictionary] = MesaPlaytest.lote("h_soplo", 10, 3, _BALANZA_4)
	_victorias(h_cambiada, 10)
	var partidas: Array[Dictionary] = []
	for lista in [h, c, c_cambiada, h_cambiada]:
		partidas.append_array(lista)
	_validas(partidas)
	var informe: Dictionary = MesaPlaytest.calcular(partidas)
	# No es una alarma de grupo.
	assert_dict(MesaPlaytest.alarma(informe, "h_soplo", "h_mas_facil_que_c")).is_empty()
	var comparacion: Dictionary = MesaPlaytest.comparacion(informe, "h_mas_facil_que_c")
	assert_dict(comparacion).is_not_empty()
	return comparacion


func test_h_victorias_diferencia() -> void:
	var en_el_borde: Dictionary = _h_contra_c(5, 3)
	_assert_alarma(en_el_borde, AlarmasPlaytest.ESTADO_OK, 20, 10)
	assert_int(en_el_borde["n_comparado"] as int).is_equal(10)
	assert_int(en_el_borde["umbral"] as int).is_equal(20)
	assert_str(en_el_borde["escenario"] as String).is_equal("h_soplo")
	assert_str(en_el_borde["comparado_con"] as String).is_equal("c_tasajero")
	_assert_alarma(_h_contra_c(6, 3), AlarmasPlaytest.ESTADO_ALARMA, 30, 10)
	# Por debajo de C no salta.
	_assert_alarma(_h_contra_c(0, 10), AlarmasPlaytest.ESTADO_OK, -100, 10)


func test_h_victorias_diferencia_insuficiente() -> void:
	var comparacion: Dictionary = _h_contra_c(6, 3, 9)
	assert_str(comparacion["estado"] as String).is_equal(AlarmasPlaytest.ESTADO_INSUFICIENTE)
	assert_int(comparacion["n_comparado"] as int).is_equal(9)


# Sin partidas de C, la comparacion es insuficiente y sin valor.
func test_h_sin_c_es_insuficiente() -> void:
	var h: Array[Dictionary] = MesaPlaytest.lote("h_soplo", 10)
	var comparacion: Dictionary = MesaPlaytest.comparacion(MesaPlaytest.calcular(h), "h_mas_facil_que_c")
	_assert_alarma(comparacion, AlarmasPlaytest.ESTADO_INSUFICIENTE, null, 10)
	assert_int(comparacion["n_comparado"] as int).is_equal(0)


# --- (8) D se lee tambien con la balanza 4 ------------------------------------

# Cada grupo de D mide sus propias partidas: el normal no salta y el de la
# balanza 4, con un solo combate con incidente, si.
func test_d_balanza_4_se_mide_aparte() -> void:
	var normal: Array[Dictionary] = MesaPlaytest.lote("d_rivales_normal", 10)
	var balanza_4: Array[Dictionary] = MesaPlaytest.lote("d_rivales_normal", 10, 3, _BALANZA_4)
	for i in range(10):
		if i < 2:
			(MesaPlaytest.metricas(normal[i])["incidentes"]["tribu"] as Dictionary)["golpe"] = 1
		if i < 1:
			(MesaPlaytest.metricas(balanza_4[i])["incidentes"]["tribu"] as Dictionary)["golpe"] = 1
	var partidas: Array[Dictionary] = []
	partidas.append_array(normal)
	partidas.append_array(balanza_4)
	_validas(partidas)
	var informe: Dictionary = MesaPlaytest.calcular(partidas)
	_assert_alarma(MesaPlaytest.alarma(informe, "d_rivales_normal", "d_rivales_invisibles"),
			AlarmasPlaytest.ESTADO_OK, 20, 10)
	_assert_alarma(MesaPlaytest.alarma(informe, "d_rivales_normal", "d_rivales_invisibles", _BALANZA_4),
			AlarmasPlaytest.ESTADO_ALARMA, 10, 10)
