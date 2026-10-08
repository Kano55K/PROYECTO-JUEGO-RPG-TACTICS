extends GdUnitTestSuite

# Arquitectura.md B.3 (T20) y D-005: la IA de las salvajes con Encono, cobardia e
# incidentes, con fixtures (A.6). Sistema.md 10.4 a 10.7 y 11.8 (paso 3 y los
# pasos 4 a 8 con las restricciones del turno). Lecturas declaradas S-35 y P-038
# (la restriccion de la enconada dura todo el turno), S-36, S-42 y S-43. Para
# fijar los estados, combate_rival_100.json (Encono y cobardia 100 %) o
# combate_incidente_100.json (incidente 100 %; con la semilla 1, el Encono de 35 %
# no sale). Cada test acomoda a sus unidades en las filas 6 a 9; las demas quedan
# estacionadas (escenario_rival_salvajes.json). Cada decision se juega con
# _jugar, que ademas comprueba el punto (12): decidir no cambia nada, da lo mismo
# dos veces y toda accion valida en el Turno. Cubre los puntos (5) a (12).
const _CARPETA: String = "res://pruebas/fixtures/combate/"
const _CARPETA_UNIDADES: String = "res://pruebas/fixtures/unidades/"
const _ESPECIES: Array[String] = ["ocarra", "rodauva", "surcon", "tasajero", "zancajunco"]
const _BASE_100: String = "combate_rival_100.json"
const _INCIDENTE_100: String = "combate_incidente_100.json"

var _tablero: Tablero
var _danio: Danio


func before_test() -> void:
	var tabla_combate: Dictionary = _leer(_CARPETA + "combate.json", "combate")
	_tablero = Tablero.desde_datos({"ancho": 12, "alto": 12}, tabla_combate)
	_danio = Danio.desde_datos(tabla_combate, _leer(_CARPETA + "hambre.json", "hambre"))


func _leer(ruta: String, nombre_esquema: String) -> Dictionary:
	var lectura: Dictionary = LectorFixture.leer(ruta, nombre_esquema)
	var errores: Array[Dictionary] = lectura["errores"]
	assert_array(errores).override_failure_message(str(errores)).is_empty()
	return lectura["datos"]


func _plantel(ubicar: Dictionary = {}) -> Plantel:
	var especies: Dictionary = {}
	for id_especie in _ESPECIES:
		especies[id_especie] = Especie.new(_leer(_CARPETA_UNIDADES + id_especie + ".json", "especie"))
	var tabla: TablaBalanza = TablaBalanza.new(_leer(_CARPETA_UNIDADES + "balanza_1_2.json", "balanza"))
	var plantel: Plantel = Plantel.desde_escenario(_leer(_CARPETA + "escenario_rival_salvajes.json", "escenario"),
			especies, tabla, _leer(_CARPETA_UNIDADES + "maestro.json", "maestro"))
	for id_unidad in ubicar.keys():
		if id_unidad == Maestro.ID:
			plantel.maestro.posicion = ubicar[id_unidad]
		else:
			plantel.criatura(id_unidad).posicion = ubicar[id_unidad]
	return plantel


# Empieza el turno (pasos 3 y 4 de 11.3) y decide. La cola de la ronda es para
# los desempates (P-021). Punto (12): la decision no cambia el Plantel, la cola
# ni el generador, y decidir otra vez da lo mismo.
func _decidir(plantel: Plantel, unidad_id: String, combate: String) -> Dictionary:
	var azar: GeneradorAzar = GeneradorAzar.new(1)
	var turno: Turno = Turno.empezar(EntradaCola.new(unidad_id, "", 0), plantel, _tablero, _danio, Surcos.new(),
			DatosFixture.afinidad(), DatosFixture.cadena(), ColaIniciativa.new(), DatosFixture.incidente(combate),
			DatosFixture.chequeo_rival(combate), azar)
	var cola: ColaIniciativa = ColaIniciativa.new()
	cola.empezar_ronda(plantel)
	var antes: String = _foto(plantel, cola, azar)
	var decision: DecisionIA = IASalvaje.decidir(turno, plantel, cola)
	assert_str(_foto(plantel, cola, azar)).override_failure_message("decidir cambio algo").is_equal(antes)
	assert_str(IASalvaje.decidir(turno, plantel, cola).describir()).is_equal(decision.describir())
	return {"turno": turno, "decision": decision}


func _foto(plantel: Plantel, cola: ColaIniciativa, azar: GeneradorAzar) -> String:
	var entradas: Array = []
	for entrada in cola.entradas():
		entradas.append([entrada.unidad_id, entrada.marca, entrada.vuelve])
	return str([plantel.instantanea(), entradas, cola.lugar(), azar.historial()])


# Aplica las acciones en orden (punto 12: cada una valida en el Turno). Devuelve
# los resultados de los ataques.
func _jugar(turno: Turno, decision: DecisionIA) -> Array[ResultadoAccion]:
	var ataques: Array[ResultadoAccion] = []
	for accion in decision.acciones:
		var resultado: ResultadoAccion = turno.aplicar(accion)
		assert_bool(resultado.valida).override_failure_message(
				decision.describir() + " -> " + ResultadoAccion.Motivo.keys()[resultado.motivo]).is_true()
		if accion.tipo == Accion.Tipo.ATACAR:
			ataques.append(resultado)
	assert_bool(turno.terminado).is_true()
	return ataques


func _textos(decision: DecisionIA) -> Array[String]:
	var textos: Array[String] = []
	for accion in decision.acciones:
		match accion.tipo:
			Accion.Tipo.MOVER:
				textos.append("MOVER %s" % accion.casilla)
			Accion.Tipo.ATACAR:
				textos.append("ATACAR " + accion.objetivo_id)
			_:
				textos.append(Accion.Tipo.keys()[accion.tipo])
	return textos


func _assert_decision(decision: DecisionIA, paso: DecisionIA.Paso, acciones: Array[String]) -> void:
	assert_str(DecisionIA.Paso.keys()[decision.paso]).override_failure_message(decision.describir()) \
			.is_equal(DecisionIA.Paso.keys()[paso])
	assert_array(_textos(decision)).override_failure_message(decision.describir()).is_equal(acciones)


func _fuente(desglose: DesgloseDanio, fuente: ModificadorDanio.Fuente) -> ModificadorDanio:
	for modificador in desglose.modificadores:
		if modificador.fuente == fuente:
			return modificador
	return null


# (5) Sistema.md 10.5 y 11.8 paso 3: la Ocarra salvaje enconada va por su rival
# (ocarra_1, a 3) aunque la Rodauva de la tribu al lado, con 1 de vida, se
# pudiera rematar (paso 5). La golpea desde [5,7] (distancia 2, 11.8). El
# desglose trae el Encono (+1), el contador sube y el danio aplicado es el previsto.
func test_enconada_va_por_su_rival_y_no_remata() -> void:
	var plantel: Plantel = _plantel({"ocarra_s1": Vector2i(5, 6), "ocarra_1": Vector2i(5, 9),
			"rodauva_1": Vector2i(6, 6)})
	plantel.criatura("rodauva_1").vida = 1
	var jugada: Dictionary = _decidir(plantel, "ocarra_s1", _BASE_100)
	var turno: Turno = jugada["turno"]
	var decision: DecisionIA = jugada["decision"]
	assert_bool(turno.enconada).is_true()
	_assert_decision(decision, DecisionIA.Paso.ENCONO, ["MOVER (5, 7)", "ATACAR ocarra_1", "TERMINAR"])
	assert_str(decision.describir()).starts_with("paso 3 ENCONO")
	var vida_antes: int = plantel.criatura("ocarra_1").vida
	var golpe: ResultadoAccion = _jugar(turno, decision)[0]
	assert_int(_fuente(golpe.desglose, ModificadorDanio.Fuente.ENCONO).valor).is_equal(1)
	assert_int(golpe.danio).is_equal(5)
	assert_int(vida_antes - plantel.criatura("ocarra_1").vida).is_equal(decision.danio_previsto)
	assert_int(plantel.criatura("ocarra_s1").encono).is_equal(1)
	assert_int(plantel.criatura("rodauva_1").vida).is_equal(1)


# (6) Sistema.md 10.5, salvaje enconada con varias rivales: puede tumbar gana a
# menos vida. El Tasajero salvaje en Cuenta (5 - 1 + 1 de Encono = 5) tumba a la
# Ocarra con 5 de vida y no a la Rodauva erizada con 3 (-50 %: le hace 2).
func test_desempate_puede_tumbar() -> void:
	var plantel: Plantel = _plantel({"tasajero_s1": Vector2i(5, 6), "ocarra_1": Vector2i(5, 9),
			"rodauva_1": Vector2i(3, 6)})
	plantel.criatura("tasajero_s1").modo = "cuenta"
	plantel.criatura("ocarra_1").vida = 5
	plantel.criatura("rodauva_1").vida = 3
	plantel.criatura("rodauva_1").erizada = true
	var jugada: Dictionary = _decidir(plantel, "tasajero_s1", _BASE_100)
	var turno: Turno = jugada["turno"]
	assert_array(turno.chequeo_rival["rivales"]).is_equal(["ocarra_1", "rodauva_1"])
	assert_int(turno.previsualizar_ataque(Vector2i(4, 6), "rodauva_1").danio).is_equal(2)
	var decision: DecisionIA = jugada["decision"]
	assert_str(DecisionIA.Paso.keys()[decision.paso]).override_failure_message(decision.describir()).is_equal("ENCONO")
	assert_str(decision.objetivo_id).override_failure_message(decision.describir()).is_equal("ocarra_1")
	_jugar(turno, decision)
	assert_int(plantel.criatura("ocarra_1").vida).is_equal(0)


# (6) Sistema.md 10.5: sin remate, menos vida gana a mas cercana. La Ocarra
# salvaje enconada: ocarra_1 a 3 con 10 de vida, zancajunco_1 a 5 con 8.
func test_desempate_menos_vida() -> void:
	var plantel: Plantel = _plantel({"ocarra_s1": Vector2i(5, 6), "ocarra_1": Vector2i(5, 9),
			"zancajunco_1": Vector2i(7, 9)})
	plantel.criatura("ocarra_1").vida = 10
	plantel.criatura("zancajunco_1").vida = 8
	var jugada: Dictionary = _decidir(plantel, "ocarra_s1", _BASE_100)
	var decision: DecisionIA = jugada["decision"]
	assert_str(DecisionIA.Paso.keys()[decision.paso]).override_failure_message(decision.describir()).is_equal("ENCONO")
	assert_str(decision.objetivo_id).override_failure_message(decision.describir()).is_equal("zancajunco_1")
	_jugar(jugada["turno"], decision)


# (6) Sistema.md 10.5: con la misma vida, mas cercana gana a la cola. ocarra_1 a
# 3 y zancajunco_1 (actua antes: Vel 8 contra 7) a 5, las dos con 10.
func test_desempate_mas_cercana() -> void:
	var plantel: Plantel = _plantel({"ocarra_s1": Vector2i(5, 6), "ocarra_1": Vector2i(5, 9),
			"zancajunco_1": Vector2i(7, 9)})
	plantel.criatura("ocarra_1").vida = 10
	plantel.criatura("zancajunco_1").vida = 10
	var jugada: Dictionary = _decidir(plantel, "ocarra_s1", _BASE_100)
	var decision: DecisionIA = jugada["decision"]
	assert_str(DecisionIA.Paso.keys()[decision.paso]).override_failure_message(decision.describir()).is_equal("ENCONO")
	assert_str(decision.objetivo_id).override_failure_message(decision.describir()).is_equal("ocarra_1")
	_jugar(jugada["turno"], decision)


# (6) Sistema.md 10.5 y P-021: con la misma vida y la misma distancia, la que
# actua antes en la cola: zancajunco_1 (Vel 8), aunque ocarra_1 va antes en el Plantel.
func test_desempate_antes_en_la_cola() -> void:
	var plantel: Plantel = _plantel({"ocarra_s1": Vector2i(5, 6), "ocarra_1": Vector2i(5, 9),
			"zancajunco_1": Vector2i(8, 6)})
	plantel.criatura("ocarra_1").vida = 10
	plantel.criatura("zancajunco_1").vida = 10
	var jugada: Dictionary = _decidir(plantel, "ocarra_s1", _BASE_100)
	var decision: DecisionIA = jugada["decision"]
	assert_str(DecisionIA.Paso.keys()[decision.paso]).override_failure_message(decision.describir()).is_equal("ENCONO")
	assert_str(decision.objetivo_id).override_failure_message(decision.describir()).is_equal("zancajunco_1")
	_jugar(jugada["turno"], decision)


# (7) S-35 y lectura declarada S-43: el Zancajunco salvaje enconado no alcanza a
# ocarra_1 (rodeada por la Rodauva, el Tasajero de la tribu y el Maestro; [5,10]
# queda a mas de 4 pasos). Va a la casilla de menor distancia que el Turno le
# permite, la primera en orden de lectura ([5,7]; tambien [4,8] y [6,8] quedan a
# 2), no ataca a la Rodauva aunque la tiene al lado y termina.
func test_enconada_que_no_alcanza_se_acerca() -> void:
	var plantel: Plantel = _plantel({"zancajunco_s1": Vector2i(5, 6), "ocarra_1": Vector2i(5, 9),
			"rodauva_1": Vector2i(5, 8), "tasajero_1": Vector2i(4, 9), Maestro.ID: Vector2i(6, 9)})
	var jugada: Dictionary = _decidir(plantel, "zancajunco_s1", _BASE_100)
	var turno: Turno = jugada["turno"]
	assert_bool(turno.enconada).is_true()
	assert_int(turno.obligacion).is_equal(Turno.Obligacion.ACERCARSE)
	assert_array(turno.casillas_para_mover()).contains_exactly_in_any_order(
			[Vector2i(5, 7), Vector2i(4, 8), Vector2i(6, 8)])
	_assert_decision(jugada["decision"], DecisionIA.Paso.ENCONO, ["MOVER (5, 7)", "TERMINAR"])
	assert_array(_jugar(turno, jugada["decision"])).is_empty()
	assert_int(plantel.criatura("rodauva_1").vida).is_equal(8)


# (8) Sistema.md 10.5 y lectura declarada S-42: el Tasajero salvaje enconado en
# Caza. Sin Encono iria a [8,7], junto al Zancajunco y al Maestro (menos vida
# sumada, paso 6b). Enconado, la casilla tiene que golpear a ocarra_1: [6,9] la
# deja junto a ella y al Tasajero de la tribu (2 presas). Primer ataque a la
# rival, segundo a la otra presa.
func test_caza_enconada_primero_la_rival() -> void:
	var plantel: Plantel = _plantel({"tasajero_s1": Vector2i(5, 6), "ocarra_1": Vector2i(5, 9),
			"tasajero_1": Vector2i(6, 10), "zancajunco_1": Vector2i(8, 6), Maestro.ID: Vector2i(8, 8)})
	var jugada: Dictionary = _decidir(plantel, "tasajero_s1", _BASE_100)
	assert_bool((jugada["turno"] as Turno).enconada).is_true()
	_assert_decision(jugada["decision"], DecisionIA.Paso.ENCONO,
			["MOVER (6, 9)", "ATACAR ocarra_1", "ATACAR tasajero_1", "TERMINAR"])
	_jugar(jugada["turno"], jugada["decision"])


# (8) S-42: con la rival como unica presa, los dos ataques a ella.
func test_caza_enconada_rival_unica_presa() -> void:
	var plantel: Plantel = _plantel({"tasajero_s1": Vector2i(5, 6), "ocarra_1": Vector2i(5, 9)})
	var jugada: Dictionary = _decidir(plantel, "tasajero_s1", _BASE_100)
	var decision: DecisionIA = jugada["decision"]
	assert_str(DecisionIA.Paso.keys()[decision.paso]).is_equal("ENCONO")
	assert_array(decision.objetivos).override_failure_message(decision.describir()).is_equal(["ocarra_1", "ocarra_1"])
	assert_int(_jugar(jugada["turno"], decision).size()).is_equal(2)


# (8) S-42: si el primer golpe tumba a la rival (6 de vida: 5 + 1 de Encono), el
# segundo va a la otra presa; si no hay otra, se pierde (un solo ataque).
func test_caza_enconada_rival_tumbada() -> void:
	var con_otra: Plantel = _plantel({"tasajero_s1": Vector2i(5, 6), "ocarra_1": Vector2i(5, 9),
			"tasajero_1": Vector2i(6, 10)})
	con_otra.criatura("ocarra_1").vida = 6
	var jugada: Dictionary = _decidir(con_otra, "tasajero_s1", _BASE_100)
	var decision: DecisionIA = jugada["decision"]
	assert_array(decision.objetivos).override_failure_message(decision.describir()) \
			.is_equal(["ocarra_1", "tasajero_1"])
	_jugar(jugada["turno"], decision)
	assert_int(con_otra.criatura("ocarra_1").vida).is_equal(0)

	var sola: Plantel = _plantel({"tasajero_s1": Vector2i(5, 6), "ocarra_1": Vector2i(5, 9)})
	sola.criatura("ocarra_1").vida = 6
	jugada = _decidir(sola, "tasajero_s1", _BASE_100)
	decision = jugada["decision"]
	assert_array(decision.objetivos).override_failure_message(decision.describir()).is_equal(["ocarra_1"])
	_jugar(jugada["turno"], decision)


# (9) Sistema.md 10.5 y 11.8 (retirada de la Cuenta), D-005. Con P-038 en la
# lectura de hoy (la restriccion de la enconada dura todo el turno), el Tasajero
# salvaje enconado en Cuenta golpea a ocarra_1 (7 de vida, menos que la Rodauva)
# desde [5,8] y se retira solo a una casilla desde donde sigue golpeando a una
# rival: [6,8] (junto a la Rodauva), a 2 de ocarra_1. [6,7] quedaria a 3 pero el
# Turno no la permite.
func test_cuenta_enconada_se_retira_donde_el_turno_permite() -> void:
	var plantel: Plantel = _plantel({"tasajero_s1": Vector2i(5, 6), "ocarra_1": Vector2i(5, 9),
			"rodauva_1": Vector2i(7, 8)})
	plantel.criatura("tasajero_s1").modo = "cuenta"
	plantel.criatura("ocarra_1").vida = 7
	var jugada: Dictionary = _decidir(plantel, "tasajero_s1", _BASE_100)
	var turno: Turno = jugada["turno"]
	var decision: DecisionIA = jugada["decision"]
	_assert_decision(decision, DecisionIA.Paso.ENCONO, ["MOVER (5, 8)", "ATACAR ocarra_1", "MOVER (6, 8)", "TERMINAR"])
	assert_bool(turno.pasos_para_retirarse(Vector2i(5, 8)).has(Vector2i(6, 7))).is_true()
	var permitidas: Dictionary = turno.casillas_para_retirarse(Vector2i(5, 8), "ocarra_1")
	assert_bool(permitidas.has(Vector2i(6, 7))).is_false()
	assert_bool(permitidas.has(decision.retirada)).is_true()
	_jugar(turno, decision)


# (10) Sistema.md 10.6 y S-36: la Rodauva salvaje acobardada por el Tasajero de la
# tribu (a 3) no puede golpearlo sin acercarse; golpea al Zancajunco desde [4,6]
# (no queda mas cerca del Tasajero) con -50 %: 1.
func test_acobardada_ataca_sin_acercarse() -> void:
	var plantel: Plantel = _plantel({"rodauva_s1": Vector2i(5, 6), "tasajero_1": Vector2i(5, 9),
			"zancajunco_1": Vector2i(3, 6)})
	var jugada: Dictionary = _decidir(plantel, "rodauva_s1", _BASE_100)
	var turno: Turno = jugada["turno"]
	assert_bool(turno.acobardada).is_true()
	_assert_decision(jugada["decision"], DecisionIA.Paso.CERCANA, ["MOVER (4, 6)", "ATACAR zancajunco_1", "TERMINAR"])
	var golpe: ResultadoAccion = _jugar(turno, jugada["decision"])[0]
	assert_int(golpe.danio).is_equal(1)
	assert_object(_fuente(golpe.desglose, ModificadorDanio.Fuente.COBARDIA)).is_not_null()
	assert_int(Tablero.distancia(plantel.criatura("rodauva_s1").posicion, Vector2i(5, 9))).is_greater_equal(3)


# (10) S-36 y 11.8 (Acercarse): si la unica unidad a la que acercarse es su rival,
# la acobardada no se mueve.
func test_acobardada_no_se_acerca_a_su_rival() -> void:
	var plantel: Plantel = _plantel({"rodauva_s1": Vector2i(5, 6), "tasajero_1": Vector2i(5, 9)})
	var jugada: Dictionary = _decidir(plantel, "rodauva_s1", _BASE_100)
	assert_bool((jugada["turno"] as Turno).acobardada).is_true()
	_assert_decision(jugada["decision"], DecisionIA.Paso.ACERCARSE, ["TERMINAR"])
	_jugar(jugada["turno"], jugada["decision"])
	assert_that(plantel.criatura("rodauva_s1").posicion).is_equal(Vector2i(5, 6))


# (11) Sistema.md 10.4 y 10.7: el Zancajunco salvaje distraido por la Ocarra
# salvaje en diagonal (no la alcanza) pierde la accion: no se hace junco (paso 7)
# ni ataca; se acerca a la tribu y termina.
func test_distraida_se_acerca_sin_prepararse() -> void:
	var plantel: Plantel = _plantel({"zancajunco_s1": Vector2i(5, 6), "ocarra_s2": Vector2i(6, 7)})
	var jugada: Dictionary = _decidir(plantel, "zancajunco_s1", _INCIDENTE_100)
	var turno: Turno = jugada["turno"]
	assert_str(turno.incidente["resultado"]).is_equal(Turno.RESULTADO_DISTRAIDA)
	var decision: DecisionIA = jugada["decision"]
	assert_str(DecisionIA.Paso.keys()[decision.paso]).is_equal("ACERCARSE")
	var tipos: Array[String] = _textos(decision)
	assert_str(tipos[0]).starts_with("MOVER")
	assert_str(tipos[tipos.size() - 1]).is_equal("TERMINAR")
	assert_int(tipos.size()).is_equal(2)
	_jugar(turno, decision)
	assert_bool(plantel.criatura("zancajunco_s1").oculta).is_false()


# (11) La Ocarra salvaje distraida con una presa a tiro no ataca: se acerca.
func test_distraida_no_ataca() -> void:
	var plantel: Plantel = _plantel({"ocarra_s1": Vector2i(5, 6), "ocarra_s2": Vector2i(6, 7),
			"rodauva_1": Vector2i(5, 9)})
	var jugada: Dictionary = _decidir(plantel, "ocarra_s1", _INCIDENTE_100)
	assert_str((jugada["turno"] as Turno).incidente["resultado"]).is_equal(Turno.RESULTADO_DISTRAIDA)
	_assert_decision(jugada["decision"], DecisionIA.Paso.ACERCARSE, ["MOVER (5, 8)", "TERMINAR"])
	assert_array(_jugar(jugada["turno"], jugada["decision"])).is_empty()
	assert_int(plantel.criatura("rodauva_1").vida).is_equal(8)
