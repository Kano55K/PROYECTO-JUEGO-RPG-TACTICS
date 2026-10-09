extends GdUnitTestSuite

# Arquitectura.md B.3 (T19): el contador del Encono y la enconada, con fixtures
# (A.6). Sistema.md 10.1 (no Secunda), 10.4 (la enconada no tira incidente), 10.5
# (contador, bono y Tasajero enconado en Caza), 11.3 pasos 3 y 4, 11.4 paso 3 y
# 11.5 (Fin del combate). Lecturas declaradas S-31 (no rechequea al volver de
# Secundar) y S-35 (obligacion de la enconada). Para fijar la enconada,
# combate_rival_100.json con tramo neutral y balanza 5, o el contador en el
# maximo (enconada sin tirar). Cada test acomoda a sus unidades alrededor de
# [3,3]; las demas quedan estacionadas (escenario_rival.json). Cubre los puntos
# (6) a (9) y (11).
const _CARPETA: String = "res://pruebas/fixtures/combate/"
const _CARPETA_UNIDADES: String = "res://pruebas/fixtures/unidades/"
const _ESPECIES: Array[String] = ["ocarra", "rodauva", "surcon", "tasajero", "zancajunco"]
const _BASE_100: String = "combate_rival_100.json"
const _BASE_0: String = "combate_rival_0.json"

var _tablero: Tablero


func before_test() -> void:
	var tabla_combate: Dictionary = _leer(_CARPETA + "combate.json", "combate")
	_tablero = Tablero.desde_datos({"ancho": 12, "alto": 12}, tabla_combate)


func _leer(ruta: String, nombre_esquema: String) -> Dictionary:
	var lectura: Dictionary = LectorFixture.leer(ruta, nombre_esquema)
	var errores: Array[Dictionary] = lectura["errores"]
	assert_array(errores).override_failure_message(str(errores)).is_empty()
	return lectura["datos"]


func _especies() -> Dictionary:
	var especies: Dictionary = {}
	for id_especie in _ESPECIES:
		especies[id_especie] = Especie.new(_leer(_CARPETA_UNIDADES + id_especie + ".json", "especie"))
	return especies


# El plantel de un escenario de fixtures con las posiciones de `ubicar`.
func _plantel(ubicar: Dictionary = {}, escenario: String = "escenario_rival.json") -> Plantel:
	var tabla: TablaBalanza = TablaBalanza.new(_leer(_CARPETA_UNIDADES + "balanza_1_2.json", "balanza"))
	var plantel: Plantel = Plantel.desde_escenario(_leer(_CARPETA + escenario, "escenario"), _especies(), tabla,
			_leer(_CARPETA_UNIDADES + "maestro.json", "maestro"))
	for id_unidad in ubicar.keys():
		if id_unidad == Maestro.ID:
			plantel.maestro.posicion = ubicar[id_unidad]
		else:
			plantel.criatura(id_unidad).posicion = ubicar[id_unidad]
	return plantel


# El turno de la unidad, como lo empieza el Combate (corre los pasos 3 y 4).
func _turno(plantel: Plantel, unidad_id: String, combate: String = _BASE_100,
		azar: GeneradorAzar = GeneradorAzar.new(1), entrada: EntradaCola = null,
		cola: ColaIniciativa = null) -> Turno:
	return Turno.empezar(entrada if entrada != null else EntradaCola.new(unidad_id, "", 0), plantel, _tablero,
			Surcos.new(), DatosFixture.cadena(), cola if cola != null else ColaIniciativa.new(),
			DatosFixture.reglas({"incidente": DatosFixture.incidente(combate),
				"chequeo_rival": DatosFixture.chequeo_rival(combate)}), azar)


func _motivo(turno: Turno, accion: Accion) -> String:
	return ResultadoAccion.Motivo.keys()[turno.validar(accion).motivo]


# Aplica una accion que tiene que rechazarse y comprueba que no cambio nada.
func _rechazada(plantel: Plantel, turno: Turno, accion: Accion, motivo: String) -> void:
	var antes: String = str(plantel.instantanea()) + str(turno.accion_usada) + str(turno.movimiento_usado)
	var resultado: ResultadoAccion = turno.aplicar(accion)
	assert_bool(resultado.valida).override_failure_message(str(accion.a_diccionario())).is_false()
	assert_str(ResultadoAccion.Motivo.keys()[resultado.motivo]).is_equal(motivo)
	assert_str(str(plantel.instantanea()) + str(turno.accion_usada) + str(turno.movimiento_usado)).is_equal(antes)


func _fuente(desglose: DesgloseDanio, fuente: ModificadorDanio.Fuente) -> ModificadorDanio:
	for modificador in desglose.modificadores:
		if modificador.fuente == fuente:
			return modificador
	return null


# (6) Sistema.md 10.5, Cada golpe a la rival: un golpe voluntario (sin estar
# enconada) suma 1 y no tiene bono. Encono 0 % con contador 0 y tramo neutral.
func test_golpe_voluntario_suma_sin_bono() -> void:
	var plantel: Plantel = _plantel({"ocarra_1": Vector2i(3, 3), "ocarra_s1": Vector2i(3, 4)})
	var turno: Turno = _turno(plantel, "ocarra_1", _BASE_0)
	assert_dict(turno.chequeo_rival).is_empty()
	assert_bool(turno.enconada).is_false()
	var golpe: ResultadoAccion = turno.aplicar(Accion.atacar("ocarra_s1"))
	assert_int(golpe.danio).is_equal(4)
	assert_object(_fuente(golpe.desglose, ModificadorDanio.Fuente.ENCONO)).is_null()
	assert_int(plantel.criatura("ocarra_1").encono).is_equal(1)
	assert_array(turno.eventos()).is_equal([{"tipo": "encono", "unidad": "ocarra_1", "de": 0, "a": 1,
			"rival": "ocarra_s1"}])


# (6) Sistema.md 10.5, Ejemplo: la Ocarra (4) enconada contra su rival, golpes
# seguidos: 5 / 6 / 7 / 7 (el punto del golpe cuenta; maximo +3). El desglose
# lleva la fuente encono; previsualizar da lo mismo que el golpe y validar o
# previsualizar no suben el contador.
func test_ocarra_enconada_pega_5_6_7_7() -> void:
	var plantel: Plantel = _plantel({"ocarra_1": Vector2i(3, 3), "ocarra_s1": Vector2i(3, 4)})
	var esperados: Array[int] = [5, 6, 7, 7]
	for indice in esperados.size():
		plantel.criatura("ocarra_s1").vida = 12
		var antes: int = plantel.criatura("ocarra_1").encono
		var turno: Turno = _turno(plantel, "ocarra_1")
		assert_bool(turno.enconada).is_true()
		assert_int(turno.validar(Accion.atacar("ocarra_s1")).danio).is_equal(esperados[indice])
		var vista: ResultadoAccion = turno.previsualizar_ataque(Vector2i(3, 3), "ocarra_s1")
		assert_int(vista.danio).is_equal(esperados[indice])
		assert_int(plantel.criatura("ocarra_1").encono).is_equal(antes)
		var golpe: ResultadoAccion = turno.aplicar(Accion.atacar("ocarra_s1"))
		assert_int(golpe.danio).is_equal(esperados[indice])
		var encono: ModificadorDanio = _fuente(golpe.desglose, ModificadorDanio.Fuente.ENCONO)
		assert_int(encono.valor).is_equal(esperados[indice] - 4)
		assert_int(encono.tipo).is_equal(ModificadorDanio.Tipo.PLANO)
		assert_int(plantel.criatura("ocarra_1").encono).is_equal(mini(antes + 1, 3))
		assert_bool(turno.aplicar(Accion.terminar()).valida).is_true()


# (6) Sistema.md 10.5: el contador suma sea del bando que sea (el golpe de una
# salvaje a su rival), y el Cierre lo vuelve a 0 (Fin del combate).
# Reescrito en T20 (Sistema.md 10.5 y 10.7 v1.6: las salvajes tiran Encono con
# tramo baja). Antes la salvaje no chequeaba; ahora, con combate_rival_0.json,
# tira 10 % (base 0 + 10 de baja) y con la semilla 1 (54) no se encona: el
# golpe es voluntario, sin bono, y suma igual.
func test_salvaje_suma_y_cierre_en_0() -> void:
	var plantel: Plantel = _plantel({"ocarra_1": Vector2i(3, 3), "ocarra_s1": Vector2i(3, 4)})
	var turno: Turno = _turno(plantel, "ocarra_s1", _BASE_0)
	assert_int(turno.chequeo_rival["porcentaje"] as int).is_equal(10)
	assert_str(turno.chequeo_rival["resultado"]).is_equal(ChequeoRival.RESULTADO_NO_ENCONADA)
	assert_bool(turno.enconada).is_false()
	var golpe: ResultadoAccion = turno.aplicar(Accion.atacar("ocarra_1"))
	assert_int(golpe.danio).is_equal(4)
	assert_int(plantel.criatura("ocarra_s1").encono).is_equal(1)

	plantel.criatura("ocarra_1").encono = 2
	for id_enemiga in ["ocarra_s1", "tasajero_s1", "zancajunco_s1", "surcon_s1"]:
		plantel.criatura(id_enemiga).estado = Criatura.Estado.FUERA
		plantel.criatura(id_enemiga).posicion = Criatura.SIN_POSICION
	var datos: Dictionary = DatosFixture.cargar()["datos"]
	var cierre: Cierre = Cierre.desde_datos(datos["tablas/combate.json"], datos["tablas/lealtad.json"],
			Relaciones.new(datos["relaciones.json"]))
	assert_bool(cierre.cerrar(plantel, FinCombate.Fin.VICTORIA).valido).is_true()
	for criatura in plantel.criaturas():
		assert_int(criatura.encono).override_failure_message(criatura.id).is_equal(0)


# (7) S-35, la enconada que alcanza: atacar a otra, Hacerse junco, Erizarse, cavar,
# Secundar y terminar antes de atacar se rechazan sin cambios. Solo se mueve a
# casillas desde donde golpea a su rival. Despues del ataque, terminar vale.
func test_enconada_que_alcanza() -> void:
	var plantel: Plantel = _plantel({"ocarra_1": Vector2i(3, 3), "ocarra_s1": Vector2i(3, 6),
			"surcon_s1": Vector2i(2, 3)})
	var turno: Turno = _turno(plantel, "ocarra_1")
	assert_bool(turno.enconada).is_true()
	assert_int(turno.obligacion).is_equal(Turno.Obligacion.ATACAR)
	_rechazada(plantel, turno, Accion.atacar("surcon_s1"), "OBJETIVO_NO_RIVAL")
	_rechazada(plantel, turno, Accion.hacerse_junco(), "ENCONADA")
	_rechazada(plantel, turno, Accion.erizarse(), "ENCONADA")
	_rechazada(plantel, turno, Accion.cavar(Vector2i(4, 3)), "ENCONADA")
	_rechazada(plantel, turno, Accion.secundar("ocarra_2"), "ENCONADA")
	assert_bool(turno.puede_secundar()).is_false()
	_rechazada(plantel, turno, Accion.terminar(), "DEBE_ATACAR_RIVAL")
	assert_bool(turno.puede_terminar()).is_false()
	_rechazada(plantel, turno, Accion.mover(Vector2i(4, 3)), "CASILLA_SIN_RIVAL")
	# Desde [3,4] la golpea en linea (alcance 2) y desde [3,5], al lado.
	assert_array(turno.casillas_para_mover()).contains_exactly_in_any_order([Vector2i(3, 4), Vector2i(3, 5)])
	assert_array(turno.objetivos_para_atacar()).is_empty()

	assert_bool(turno.aplicar(Accion.mover(Vector2i(3, 4))).valida).is_true()
	assert_array(turno.objetivos_para_atacar()).is_equal(["ocarra_s1"])
	assert_bool(turno.aplicar(Accion.atacar("ocarra_s1")).valida).is_true()
	assert_bool(turno.puede_terminar()).is_true()
	assert_bool(turno.aplicar(Accion.terminar()).valida).is_true()


# (8) S-35, la enconada que no alcanza: el Zancajunco (Mov 4, Alc 1) tiene a su
# rival a 5, pero la unica casilla al lado de ella que le llega esta tapada. Solo
# se mueve a las casillas de menor distancia a la rival, no usa la accion y no
# termina hasta acercarse.
func test_enconada_que_no_alcanza() -> void:
	var plantel: Plantel = _plantel({"zancajunco_1": Vector2i(3, 3), "ocarra_s1": Vector2i(3, 8),
			"surcon_s1": Vector2i(3, 7)})
	plantel.criatura("zancajunco_1").encono = 3
	var turno: Turno = _turno(plantel, "zancajunco_1", "combate.json")
	assert_bool(turno.enconada).is_true()
	assert_bool(turno.chequeo_rival["tiro"]).is_false()
	assert_int(turno.obligacion).is_equal(Turno.Obligacion.ACERCARSE)
	assert_bool(turno.accion_usada).is_true()
	assert_array(turno.objetivos_para_atacar()).is_empty()
	_rechazada(plantel, turno, Accion.hacerse_junco(), "ENCONADA")
	_rechazada(plantel, turno, Accion.terminar(), "DEBE_ACERCARSE")
	_rechazada(plantel, turno, Accion.mover(Vector2i(2, 6)), "CASILLA_NO_ACERCA")
	assert_array(turno.casillas_para_mover()).is_equal([Vector2i(3, 6)])
	assert_bool(turno.aplicar(Accion.mover(Vector2i(3, 6))).valida).is_true()
	assert_bool(turno.puede_terminar()).is_true()


# (9) Sistema.md 10.5, Tasajero enconado en Caza: solo el primero de sus dos
# ataques va a la rival (la Rodauva, con el bono +3); el segundo es libre (el
# Surcon, que no es rival: sin bono).
func test_tasajero_enconado_en_caza() -> void:
	var plantel: Plantel = _plantel({}, "escenario_caza_tribu_encono.json")
	plantel.criatura("tasajero_1").encono = 3
	var turno: Turno = _turno(plantel, "tasajero_1", "combate.json")
	assert_bool(turno.enconada).is_true()
	assert_int(turno.ataques_restantes).is_equal(2)
	_rechazada(plantel, turno, Accion.atacar("surcon_s1"), "OBJETIVO_NO_RIVAL")
	var primero: ResultadoAccion = turno.aplicar(Accion.atacar("rodauva_s1"))
	assert_bool(primero.valida).is_true()
	assert_int(_fuente(primero.desglose, ModificadorDanio.Fuente.ENCONO).valor).is_equal(3)
	var segundo: ResultadoAccion = turno.aplicar(Accion.atacar("surcon_s1"))
	assert_bool(segundo.valida).is_true()
	assert_object(_fuente(segundo.desglose, ModificadorDanio.Fuente.ENCONO)).is_null()
	assert_bool(turno.aplicar(Accion.terminar()).valida).is_true()


# (11) Sistema.md 10.4 y 11.3 paso 4: la enconada no tira incidente aunque tenga a
# su rival aliada al lado (solo la tirada del chequeo); una que no quedo
# enconada si lo tira (incidente en 100).
func test_enconada_no_tira_incidente() -> void:
	var ubicar: Dictionary = {"ocarra_1": Vector2i(3, 3), "ocarra_2": Vector2i(4, 4), "ocarra_s1": Vector2i(3, 6)}
	var azar: GeneradorAzar = GeneradorAzar.new(1)
	var enconada: Turno = _turno(_plantel(ubicar), "ocarra_1", _BASE_100, azar)
	assert_bool(enconada.enconada).is_true()
	assert_dict(enconada.incidente).is_empty()
	assert_int(azar.historial().size()).is_equal(1)

	var otro_azar: GeneradorAzar = GeneradorAzar.new(1)
	var tranquila: Turno = _turno(_plantel(ubicar), "ocarra_1", _BASE_0, otro_azar)
	assert_bool(tranquila.enconada).is_false()
	assert_array(tranquila.incidente["rivales"]).is_equal(["ocarra_2"])
	assert_int(otro_azar.historial().size()).is_equal(1)


# (11) S-31: la que Secundo no vuelve a chequear al volver, aunque ahora tenga a su
# rival a su alcance con el Encono en 100.
func test_secundo_no_rechequea() -> void:
	var plantel: Plantel = _plantel({"ocarra_1": Vector2i(3, 3), "ocarra_2": Vector2i(6, 3)})
	var cola: ColaIniciativa = ColaIniciativa.new()
	cola.empezar_ronda(plantel)
	var entrada: EntradaCola = cola.siguiente(plantel)
	while entrada.unidad_id != "ocarra_1":
		entrada = cola.siguiente(plantel)
	var azar: GeneradorAzar = GeneradorAzar.new(1)
	var turno: Turno = _turno(plantel, "ocarra_1", _BASE_100, azar, entrada, cola)
	assert_dict(turno.chequeo_rival).is_empty()
	assert_bool(turno.aplicar(Accion.secundar("ocarra_2")).valida).is_true()
	var ocarra_2: Turno = _turno(plantel, "ocarra_2", _BASE_100, azar, cola.siguiente(plantel), cola)
	assert_str(ocarra_2.unidad_id).is_equal("ocarra_2")
	ocarra_2.aplicar(Accion.terminar())

	plantel.criatura("ocarra_s1").posicion = Vector2i(3, 5)
	var tiradas: int = azar.historial().size()
	var vuelta: EntradaCola = cola.siguiente(plantel)
	assert_bool(vuelta.vuelve).is_true()
	var de_vuelta: Turno = _turno(plantel, "ocarra_1", _BASE_100, azar, vuelta, cola)
	assert_int(azar.historial().size()).is_equal(tiradas)
	assert_dict(de_vuelta.chequeo_rival).is_empty()
	assert_bool(de_vuelta.enconada).is_false()
	assert_bool(de_vuelta.puede_terminar()).is_true()
