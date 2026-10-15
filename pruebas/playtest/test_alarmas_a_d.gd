extends GdUnitTestSuite

# T33, sesion 1, criterio (6): cada calculo de A a D (y H, que comparte el de
# desenlace) en el borde, con 10 partidas de 3 jugadores: justo en el umbral de
# Sistema.md 11.9 no salta, y uno mas si, con la comparacion que pide 11.9.
# Los umbrales salen del fixture de alarmas (los mismos numeros de 11.9).


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


func _desenlaces(partidas: Array[Dictionary], cuantas: int, desenlace: String, resto: String) -> void:
	for i in range(partidas.size()):
		(partidas[i]["resultado"] as Dictionary)["desenlace"] = desenlace if i < cuantas else resto


# A: mas del 80% de los primeros sellados en el mismo tramo (metrica 7).
func _lote_a(en_50: int) -> Array[Dictionary]:
	var partidas: Array[Dictionary] = MesaPlaytest.lote("a_dia_1", 11)
	for i in range(10):
		var primero: int = 50 if i < en_50 else 80
		# Solo cuenta el primer intento.
		MesaPlaytest.metricas(partidas[i])["sellados"] = [
			{"objetivo": "ocarra_s1", "porcentaje": primero, "logrado": false},
			{"objetivo": "ocarra_s1", "porcentaje": 80, "logrado": true},
		]
	# La partida 11 no intento sellar: no entra en n.
	return partidas


func test_a_primer_sellado_mismo_tramo() -> void:
	_assert_alarma(_estado(_lote_a(8), "a_dia_1", "a_mismo_tramo"), AlarmasPlaytest.ESTADO_OK, 80, 10)
	_assert_alarma(_estado(_lote_a(9), "a_dia_1", "a_mismo_tramo"), AlarmasPlaytest.ESTADO_ALARMA, 90, 10)
	# El tramo mas frecuente puede ser cualquiera: 1 en 50 y 9 en 80.
	_assert_alarma(_estado(_lote_a(1), "a_dia_1", "a_mismo_tramo"), AlarmasPlaytest.ESTADO_ALARMA, 90, 10)


# B: menos del 30% terminan en huida o en victoria.
func test_b_desenlace_menor_que() -> void:
	var partidas: Array[Dictionary] = MesaPlaytest.lote("b_muro", 10)
	_desenlaces(partidas, 3, "huida", "derrota_por_caida")
	(partidas[0]["resultado"] as Dictionary)["desenlace"] = "victoria"
	_assert_alarma(_estado(partidas, "b_muro", "b_huir_no_se_lee"), AlarmasPlaytest.ESTADO_OK, 30, 10)
	_desenlaces(partidas, 2, "huida", "derrota_por_caida")
	_assert_alarma(_estado(partidas, "b_muro", "b_huir_no_se_lee"), AlarmasPlaytest.ESTADO_ALARMA, 20, 10)


# C: mas de 5 rondas de pelea en mas del 20% de las partidas (metrica 1).
func _lote_c_rondas(de_pelea: Array[int]) -> Array[Dictionary]:
	var partidas: Array[Dictionary] = MesaPlaytest.lote("c_tasajero", de_pelea.size())
	for i in range(de_pelea.size()):
		(MesaPlaytest.metricas(partidas[i])["rondas"] as Dictionary)["de_pelea"] = de_pelea[i]
	return partidas


func test_c_rondas_de_pelea_mayor_que() -> void:
	# 5 rondas no es "mas de 5".
	var en_el_borde: Array[int] = [6, 6, 5, 5, 3, 3, 3, 3, 3, 3]
	_assert_alarma(_estado(_lote_c_rondas(en_el_borde), "c_tasajero", "c_rondas_largas"),
			AlarmasPlaytest.ESTADO_OK, 20, 10)
	var uno_mas: Array[int] = [6, 6, 6, 5, 3, 3, 3, 3, 3, 3]
	_assert_alarma(_estado(_lote_c_rondas(uno_mas), "c_tasajero", "c_rondas_largas"),
			AlarmasPlaytest.ESTADO_ALARMA, 30, 10)


# C: promedio de rondas de pelea fuera de 2 a 3,5, en decimas.
func test_c_rondas_de_pelea_promedio_fuera() -> void:
	var casos: Array = [
		[[2, 2, 2, 2, 2, 2, 2, 2, 2, 2], AlarmasPlaytest.ESTADO_OK, 20],
		[[1, 2, 2, 2, 2, 2, 2, 2, 2, 2], AlarmasPlaytest.ESTADO_ALARMA, 19],
		[[3, 3, 3, 3, 3, 4, 4, 4, 4, 4], AlarmasPlaytest.ESTADO_OK, 35],
		[[3, 3, 3, 3, 4, 4, 4, 4, 4, 4], AlarmasPlaytest.ESTADO_ALARMA, 36],
	]
	for caso in casos:
		var de_pelea: Array[int] = []
		de_pelea.assign(caso[0])
		var alarma: Dictionary = _estado(_lote_c_rondas(de_pelea), "c_tasajero", "c_rondas_promedio")
		_assert_alarma(alarma, caso[1], caso[2], 10)
		assert_dict(alarma["umbral"] as Dictionary).is_equal({"desde": 20, "hasta": 35})


# C: la Rodauva muere en mas del 50% de las partidas en que empezo suelta
# (metrica 11). En el escenario C, rodauva_1 empieza suelta.
func _lote_c_muertes(muere: int, variante: Dictionary = {}) -> Array[Dictionary]:
	var partidas: Array[Dictionary] = MesaPlaytest.lote("c_tasajero", 10, 3, variante)
	for i in range(10):
		var muertes: Array = [{"unidad": "ocarra_1", "causa": "derrota_por_caida"}]
		if i < muere:
			muertes.append({"unidad": "rodauva_1", "causa": "derrota_por_caida"})
		MesaPlaytest.metricas(partidas[i])["muertes"] = muertes
	return partidas


func test_c_muere_si_empezo_suelta() -> void:
	_assert_alarma(_estado(_lote_c_muertes(5), "c_tasajero", "c_rodauva_muere"), AlarmasPlaytest.ESTADO_OK, 50, 10)
	_assert_alarma(_estado(_lote_c_muertes(6), "c_tasajero", "c_rodauva_muere"), AlarmasPlaytest.ESTADO_ALARMA, 60, 10)


# Si la variante la deja guardada al empezar, la partida no entra en n.
func test_c_guardada_al_empezar_no_cuenta() -> void:
	var guardada: Dictionary = {"tribu.rodauva_1.estado": "guardada"}
	var alarma: Dictionary = _estado(_lote_c_muertes(6, guardada), "c_tasajero", "c_rodauva_muere", guardada)
	_assert_alarma(alarma, AlarmasPlaytest.ESTADO_INSUFICIENTE, null, 0)


# D normal: menos del 20% de los combates con al menos 1 incidente (de la tribu).
func _lote_d_incidentes(con_incidente: int) -> Array[Dictionary]:
	var partidas: Array[Dictionary] = MesaPlaytest.lote("d_rivales_normal", 10)
	for i in range(10):
		var incidentes: Dictionary = MesaPlaytest.metricas(partidas[i])["incidentes"]
		# Los de las enemigas no cuentan (P-049).
		(incidentes["enemigas"] as Dictionary)["golpe"] = 1
		if i < con_incidente:
			(incidentes["tribu"] as Dictionary)["distraida" if i % 2 == 0 else "golpe"] = 1
	return partidas


func test_d_combates_con_incidente() -> void:
	_assert_alarma(_estado(_lote_d_incidentes(2), "d_rivales_normal", "d_rivales_invisibles"),
			AlarmasPlaytest.ESTADO_OK, 20, 10)
	_assert_alarma(_estado(_lote_d_incidentes(1), "d_rivales_normal", "d_rivales_invisibles"),
			AlarmasPlaytest.ESTADO_ALARMA, 10, 10)


# D hambriento: derrota en mas del 50% de las partidas.
func test_d_hambriento_derrota() -> void:
	var partidas: Array[Dictionary] = MesaPlaytest.lote("d_rivales_hambriento", 10)
	_desenlaces(partidas, 5, "derrota_por_caida", "victoria")
	_assert_alarma(_estado(partidas, "d_rivales_hambriento", "d_castigo_derrota"), AlarmasPlaytest.ESTADO_OK, 50, 10)
	_desenlaces(partidas, 6, "derrota_por_caida", "huida")
	_assert_alarma(_estado(partidas, "d_rivales_hambriento", "d_castigo_derrota"), AlarmasPlaytest.ESTADO_ALARMA, 60, 10)


# D hambriento: 3 o mas golpes de incidente por combate, en promedio (decimas).
func _lote_d_golpes(golpes: int) -> Array[Dictionary]:
	var partidas: Array[Dictionary] = MesaPlaytest.lote("d_rivales_hambriento", 10)
	for i in range(10):
		@warning_ignore("integer_division")
		var de_esta: int = golpes / 10 + (1 if i < golpes % 10 else 0)
		(MesaPlaytest.metricas(partidas[i])["incidentes"]["tribu"] as Dictionary)["golpe"] = de_esta
		(MesaPlaytest.metricas(partidas[i])["incidentes"]["tribu"] as Dictionary)["distraida"] = 2
	return partidas


func test_d_hambriento_golpes_promedio() -> void:
	_assert_alarma(_estado(_lote_d_golpes(29), "d_rivales_hambriento", "d_castigo_golpes"),
			AlarmasPlaytest.ESTADO_OK, 29, 10)
	# "3 o mas": justo 3 de promedio ya salta.
	_assert_alarma(_estado(_lote_d_golpes(30), "d_rivales_hambriento", "d_castigo_golpes"),
			AlarmasPlaytest.ESTADO_ALARMA, 30, 10)


# H: victorias por debajo del 20%.
func test_h_victorias_menor_que() -> void:
	var partidas: Array[Dictionary] = MesaPlaytest.lote("h_soplo", 10)
	_desenlaces(partidas, 2, "victoria", "derrota_por_caida")
	_assert_alarma(_estado(partidas, "h_soplo", "h_build_trampa"), AlarmasPlaytest.ESTADO_OK, 20, 10)
	_desenlaces(partidas, 1, "victoria", "huida")
	_assert_alarma(_estado(partidas, "h_soplo", "h_build_trampa"), AlarmasPlaytest.ESTADO_ALARMA, 10, 10)
