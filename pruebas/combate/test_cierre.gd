extends GdUnitTestSuite

# Arquitectura.md B.2 (T10, sesion 2): cierre del combate, con fixtures (A.6).
# Sistema.md 3.2 (Quema), 5.2 (eventos y precisiones, P-001), 6 (Las caidas) y
# 11.5. Las caidas se producen con vida 0 y VidaCero, el mismo camino que un
# golpe aplicado. Los numeros son la comprobacion: el codigo los lee de las tablas.
const _CARPETA: String = "res://pruebas/fixtures/combate/"
const _CARPETA_UNIDADES: String = "res://pruebas/fixtures/unidades/"
const _ESPECIES: Array[String] = ["ocarra", "rodauva", "surcon", "zancajunco"]

var _cierre: Cierre


func before_test() -> void:
	var relaciones: Relaciones = Relaciones.new(_leer(_CARPETA_UNIDADES + "relaciones.json", "relaciones"))
	_cierre = Cierre.desde_datos(_leer(_CARPETA + "combate.json", "combate"), _leer(_CARPETA_UNIDADES + "lealtad.json", "lealtad"), relaciones)


func _leer(ruta: String, nombre_esquema: String) -> Dictionary:
	var lectura: Dictionary = LectorFixture.leer(ruta, nombre_esquema)
	var errores: Array[Dictionary] = lectura["errores"]
	assert_array(errores).override_failure_message(str(errores)).is_empty()
	return lectura["datos"]


func _plantel() -> Plantel:
	var especies: Dictionary = {}
	for id_especie in _ESPECIES:
		especies[id_especie] = Especie.new(_leer(_CARPETA_UNIDADES + id_especie + ".json", "especie"))
	var tabla: TablaBalanza = TablaBalanza.new(_leer(_CARPETA_UNIDADES + "balanza_1_2.json", "balanza"))
	return Plantel.desde_escenario(_leer(_CARPETA + "escenario_cierre.json", "escenario"), especies, tabla, _leer(_CARPETA_UNIDADES + "maestro.json", "maestro"))


# Lleva a 0 a cada unidad y la resuelve como despues de un golpe aplicado.
func _tumbar(plantel: Plantel, ids: Array[String]) -> void:
	for unidad_id in ids:
		if unidad_id == Maestro.ID:
			plantel.maestro.vida = 0
		else:
			plantel.criatura(unidad_id).vida = 0
		VidaCero.resolver(unidad_id, plantel, Surcos.new())


func _victoria(plantel: Plantel) -> void:
	_tumbar(plantel, ["rodauva_1", "ocarra_s1", "ocarra_n1"])


# Todo lo que el cierre puede cambiar en el Plantel.
func _foto(plantel: Plantel) -> String:
	var foto: Array = [plantel.cerrado]
	for criatura in plantel.criaturas():
		foto.append([criatura.id, criatura.vida, criatura.estado, criatura.lealtad, criatura.pergamino_id])
	for pergamino in plantel.pergaminos():
		foto.append([pergamino.id, pergamino.estado, pergamino.ocupante_id])
	return str(foto)


func _cambio(cierre: ResultadoCierre, criatura_id: String) -> CambioLealtad:
	for cambio in cierre.lealtad:
		if cambio.criatura_id == criatura_id:
			return cambio
	return null


func _motivos(cambio: CambioLealtad) -> Array[String]:
	var motivos: Array[String] = []
	for anotacion in cambio.anotaciones:
		motivos.append(anotacion.motivo)
	return motivos


func _assert_valido(cierre: ResultadoCierre) -> void:
	assert_bool(cierre.valido).override_failure_message("motivo: " + ResultadoCierre.Motivo.keys()[cierre.motivo]).is_true()


func _assert_rechazado(cierre: ResultadoCierre, motivo: ResultadoCierre.Motivo) -> void:
	assert_bool(cierre.valido).is_false()
	assert_str(ResultadoCierre.Motivo.keys()[cierre.motivo]).is_equal(ResultadoCierre.Motivo.keys()[motivo])


# (6) Victoria con una caida: se levanta con 1 de vida y recibe el +1, como las
# de pie; la guardada no lo recibe. La atacante caida no cambia.
func test_victoria_levanta_y_suma_uno() -> void:
	var plantel: Plantel = _plantel()
	_victoria(plantel)
	assert_int(FinCombate.evaluar(plantel)).is_equal(FinCombate.Fin.VICTORIA)

	var cierre: ResultadoCierre = _cierre.cerrar(plantel, FinCombate.Fin.VICTORIA)
	_assert_valido(cierre)
	assert_int(cierre.fin).is_equal(FinCombate.Fin.VICTORIA)
	assert_bool(cierre.maestro_caido).is_false()
	assert_array(cierre.levantadas).contains_exactly(["rodauva_1"])
	assert_array(cierre.muertas).is_empty()

	var levantada: Criatura = plantel.criatura("rodauva_1")
	assert_int(levantada.estado).is_equal(Criatura.Estado.SUELTA)
	assert_int(levantada.vida).is_equal(1)
	assert_that(levantada.posicion).is_equal(Vector2i(1, 6))
	assert_int(levantada.lealtad).is_equal(9)
	assert_int(plantel.criatura("rodauva_2").lealtad).is_equal(7)
	assert_int(plantel.criatura("surcon_1").lealtad).is_equal(10)
	assert_int(plantel.criatura("ocarra_1").lealtad).is_equal(8)
	assert_array(_motivos(_cambio(cierre, "rodauva_1"))).contains_exactly(["victoria"])

	assert_int(plantel.criatura("zancajunco_1").lealtad).is_equal(5)
	assert_object(_cambio(cierre, "zancajunco_1")).is_null()

	var atacante: Criatura = plantel.criatura("ocarra_n1")
	assert_int(atacante.estado).is_equal(Criatura.Estado.CAIDA)
	assert_int(atacante.vida).is_equal(0)
	assert_int(plantel.pergamino(atacante.pergamino_id).estado).is_equal(Pergamino.Estado.OCUPADO)
	assert_object(_cambio(cierre, "ocarra_n1")).is_null()
	assert_object(_cambio(cierre, "ocarra_s1")).is_null()
	assert_int(cierre.lealtad.size()).is_equal(4)


# (7) Derrota con dos caidas: las dos mueren, sus pergaminos arden y la muerte en
# el grupo se aplica dos veces (Surcon afin de las dos, Ocarra de ninguna).
func test_derrota_con_dos_caidas() -> void:
	var plantel: Plantel = _plantel()
	var pergaminos: Array[String] = [plantel.criatura("rodauva_1").pergamino_id, plantel.criatura("rodauva_2").pergamino_id]
	_tumbar(plantel, ["rodauva_1", "rodauva_2", Maestro.ID])

	var cierre: ResultadoCierre = _cierre.cerrar(plantel, FinCombate.Fin.DERROTA_POR_CAIDA)
	_assert_valido(cierre)
	assert_bool(cierre.maestro_caido).is_true()
	assert_array(cierre.muertas).contains_exactly(["rodauva_1", "rodauva_2"])
	assert_array(cierre.levantadas).is_empty()
	for id_criatura in ["rodauva_1", "rodauva_2"]:
		var muerta: Criatura = plantel.criatura(id_criatura)
		assert_int(muerta.estado).is_equal(Criatura.Estado.MUERTA)
		assert_str(muerta.pergamino_id).is_empty()
	for id_pergamino in pergaminos:
		assert_int(plantel.pergamino(id_pergamino).estado).is_equal(Pergamino.Estado.ARDIDO)

	# Reescrito en T29 (Sistema.md 6): surcon_1 (9, la mas leal) rescata y suma +2:
	# 9 + 2 - 4 - 4 = 3.
	assert_int(plantel.criatura("surcon_1").lealtad).is_equal(3)
	assert_array(_motivos(_cambio(cierre, "surcon_1"))).contains_exactly(["rescate", "muerte_en_el_grupo_afines", "muerte_en_el_grupo_afines"])
	assert_int(plantel.criatura("ocarra_1").lealtad).is_equal(3)
	assert_array(_motivos(_cambio(cierre, "ocarra_1"))).contains_exactly(["muerte_en_el_grupo", "muerte_en_el_grupo"])


# (8) Ejemplo de 5.2: muere una Rodauva -> la otra Rodauva y el Surcon pierden 4;
# la Ocarra pierde 2.
func test_ejemplo_muerte_de_una_rodauva() -> void:
	var plantel: Plantel = _plantel()
	_tumbar(plantel, ["rodauva_1", Maestro.ID])

	var cierre: ResultadoCierre = _cierre.cerrar(plantel, FinCombate.Fin.DERROTA_POR_CAIDA)
	_assert_valido(cierre)
	assert_int(_cambio(cierre, "rodauva_2").cambio).is_equal(-4)
	assert_int(plantel.criatura("rodauva_2").lealtad).is_equal(2)
	# Reescrito en T29 (Sistema.md 6): surcon_1 tambien rescata (+2): 9 + 2 - 4 = 7.
	assert_int(_cambio(cierre, "surcon_1").cambio).is_equal(-2)
	assert_int(plantel.criatura("surcon_1").lealtad).is_equal(7)
	assert_array(_motivos(_cambio(cierre, "surcon_1"))).contains_exactly(["rescate", "muerte_en_el_grupo_afines"])
	assert_int(_cambio(cierre, "ocarra_1").cambio).is_equal(-2)
	assert_int(plantel.criatura("ocarra_1").lealtad).is_equal(5)
	assert_array(_motivos(_cambio(cierre, "ocarra_1"))).contains_exactly(["muerte_en_el_grupo"])


# (10) La muerta no recibe lealtad y una guardada no pierde.
func test_muerta_y_guardada_sin_cambios() -> void:
	var plantel: Plantel = _plantel()
	_tumbar(plantel, ["rodauva_1", Maestro.ID])

	var cierre: ResultadoCierre = _cierre.cerrar(plantel, FinCombate.Fin.DERROTA_POR_CAIDA)
	_assert_valido(cierre)
	assert_int(plantel.criatura("rodauva_1").lealtad).is_equal(8)
	assert_object(_cambio(cierre, "rodauva_1")).is_null()
	var guardada: Criatura = plantel.criatura("zancajunco_1")
	assert_int(guardada.estado).is_equal(Criatura.Estado.GUARDADA)
	assert_int(guardada.lealtad).is_equal(5)
	assert_int(plantel.pergamino(guardada.pergamino_id).estado).is_equal(Pergamino.Estado.OCUPADO)
	assert_object(_cambio(cierre, "zancajunco_1")).is_null()
	assert_int(cierre.lealtad.size()).is_equal(3)


# Un combate en curso no se cierra, y no cambia nada.
func test_en_curso_se_rechaza() -> void:
	var plantel: Plantel = _plantel()
	_tumbar(plantel, ["rodauva_1"])
	var antes: String = _foto(plantel)
	_assert_rechazado(_cierre.cerrar(plantel, FinCombate.Fin.EN_CURSO), ResultadoCierre.Motivo.COMBATE_EN_CURSO)
	assert_str(_foto(plantel)).is_equal(antes)


# El cierre corre una sola vez: el segundo se rechaza sin dar otro +1.
func test_se_cierra_una_sola_vez() -> void:
	var plantel: Plantel = _plantel()
	_victoria(plantel)
	_assert_valido(_cierre.cerrar(plantel, FinCombate.Fin.VICTORIA))
	assert_bool(plantel.cerrado).is_true()
	var antes: String = _foto(plantel)
	var otro: Cierre = Cierre.desde_datos(_leer(_CARPETA + "combate.json", "combate"), _leer(_CARPETA_UNIDADES + "lealtad.json", "lealtad"), Relaciones.new(_leer(_CARPETA_UNIDADES + "relaciones.json", "relaciones")))
	_assert_rechazado(_cierre.cerrar(plantel, FinCombate.Fin.VICTORIA), ResultadoCierre.Motivo.YA_CERRADO)
	_assert_rechazado(otro.cerrar(plantel, FinCombate.Fin.VICTORIA), ResultadoCierre.Motivo.YA_CERRADO)
	assert_str(_foto(plantel)).is_equal(antes)


# T28 (reescribe el test de T10 que rechazaba HUIDA con NO_IMPLEMENTADO, porque
# Sistema.md 11.7 ya la define): con el Maestro ido, las caidas del tablero mueren
# y su pergamino arde; muerte en el grupo a las sueltas (5.2: -4 a las afines de la
# muerta, -2 al resto); la guardada sobrevive, tambien la caida guardada (11.5,
# T27); nadie recibe el +1 de victoria.
func test_huida_las_caidas_mueren() -> void:
	var plantel: Plantel = _plantel()
	var pergamino_caida: String = plantel.criatura("rodauva_1").pergamino_id
	_tumbar(plantel, ["rodauva_1", "rodauva_2"])
	# rodauva_2 cayo y el Maestro la guardo (T27): guardada, fuera del tablero.
	var guardada_caida: Criatura = plantel.criatura("rodauva_2")
	guardada_caida.estado = Criatura.Estado.GUARDADA
	guardada_caida.posicion = Criatura.SIN_POSICION
	guardada_caida.vida = 1
	plantel.maestro.huida_declarada = true
	plantel.maestro.se_fue = true
	assert_int(FinCombate.evaluar(plantel)).is_equal(FinCombate.Fin.HUIDA)

	var cierre: ResultadoCierre = _cierre.cerrar(plantel, FinCombate.Fin.HUIDA)
	_assert_valido(cierre)
	assert_int(cierre.fin).is_equal(FinCombate.Fin.HUIDA)
	assert_bool(cierre.maestro_caido).is_false()
	assert_array(cierre.levantadas).is_empty()
	assert_array(cierre.muertas).contains_exactly(["rodauva_1"])
	var muerta: Criatura = plantel.criatura("rodauva_1")
	assert_int(muerta.estado).is_equal(Criatura.Estado.MUERTA)
	assert_str(muerta.pergamino_id).is_empty()
	assert_int(plantel.pergamino(pergamino_caida).estado).is_equal(Pergamino.Estado.ARDIDO)

	assert_int(_cambio(cierre, "surcon_1").cambio).is_equal(-4)
	assert_array(_motivos(_cambio(cierre, "surcon_1"))).contains_exactly(["muerte_en_el_grupo_afines"])
	assert_int(_cambio(cierre, "ocarra_1").cambio).is_equal(-2)
	assert_array(_motivos(_cambio(cierre, "ocarra_1"))).contains_exactly(["muerte_en_el_grupo"])
	for cambio in cierre.lealtad:
		assert_array(_motivos(cambio)).not_contains(["victoria"])

	assert_int(guardada_caida.estado).is_equal(Criatura.Estado.GUARDADA)
	assert_int(guardada_caida.vida).is_equal(1)
	assert_int(guardada_caida.lealtad).is_equal(6)
	assert_int(plantel.pergamino(guardada_caida.pergamino_id).estado).is_equal(Pergamino.Estado.OCUPADO)
	var guardada: Criatura = plantel.criatura("zancajunco_1")
	assert_int(guardada.estado).is_equal(Criatura.Estado.GUARDADA)
	assert_int(guardada.lealtad).is_equal(5)
	assert_int(cierre.lealtad.size()).is_equal(2)


# T28 (11.7): sin caidas, la huida no mata a nadie ni cambia la lealtad.
func test_huida_sin_caidas() -> void:
	var plantel: Plantel = _plantel()
	plantel.maestro.se_fue = true
	var cierre: ResultadoCierre = _cierre.cerrar(plantel, FinCombate.Fin.HUIDA)
	_assert_valido(cierre)
	assert_array(cierre.muertas).is_empty()
	assert_array(cierre.lealtad).is_empty()


# T28: Cierre.caidas_que_mueren es el criterio del cierre: las caidas de la tribu
# en el tablero, en su orden (la atacante caida no, la guardada no).
func test_caidas_que_mueren() -> void:
	var plantel: Plantel = _plantel()
	_tumbar(plantel, ["rodauva_2", "rodauva_1", "ocarra_n1"])
	var ids: Array[String] = []
	for criatura in Cierre.caidas_que_mueren(plantel):
		ids.append(criatura.id)
	assert_array(ids).contains_exactly(["rodauva_1", "rodauva_2"])


# T28 (11.7, S-60): el orden de evaluar es caida -> victoria -> huida, y la huida
# solo declarada no termina nada.
func test_evaluar_con_la_huida() -> void:
	var plantel: Plantel = _plantel()
	plantel.maestro.huida_declarada = true
	assert_int(FinCombate.evaluar(plantel)).is_equal(FinCombate.Fin.EN_CURSO)
	plantel.maestro.se_fue = true
	assert_int(FinCombate.evaluar(plantel)).is_equal(FinCombate.Fin.HUIDA)
	_tumbar(plantel, ["ocarra_s1", "ocarra_n1"])
	assert_int(FinCombate.evaluar(plantel)).is_equal(FinCombate.Fin.VICTORIA)
	_tumbar(plantel, [Maestro.ID])
	assert_int(FinCombate.evaluar(plantel)).is_equal(FinCombate.Fin.DERROTA_POR_CAIDA)


# T28: con el Maestro solo declarado (no se fue), HUIDA no coincide con el Plantel.
func test_huida_solo_declarada_no_coincide() -> void:
	var plantel: Plantel = _plantel()
	plantel.maestro.huida_declarada = true
	var antes: String = _foto(plantel)
	_assert_rechazado(_cierre.cerrar(plantel, FinCombate.Fin.HUIDA), ResultadoCierre.Motivo.FIN_NO_COINCIDE)
	assert_str(_foto(plantel)).is_equal(antes)


# El fin tiene que ser el del Plantel: con el Maestro caido no se cierra como victoria.
func test_fin_que_no_coincide() -> void:
	var plantel: Plantel = _plantel()
	_tumbar(plantel, ["rodauva_1", "ocarra_s1", "ocarra_n1", Maestro.ID])
	var antes: String = _foto(plantel)
	_assert_rechazado(_cierre.cerrar(plantel, FinCombate.Fin.VICTORIA), ResultadoCierre.Motivo.FIN_NO_COINCIDE)
	assert_str(_foto(plantel)).is_equal(antes)
