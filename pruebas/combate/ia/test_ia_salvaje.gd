extends GdUnitTestSuite

# Arquitectura.md B.2 (T11): IA de las salvajes, con fixtures (A.6).
# Sistema.md 11.8 (pasos, desempates, reglas fijas), 9.2 (punto 3), 10.7 y 11.2.
# La IA devuelve las acciones; los tests las aplican con Turno. Los numeros de
# vida y danio son la comprobacion: el codigo los lee de las fichas de prueba.
const _CARPETA: String = "res://pruebas/fixtures/combate/"
const _CARPETA_IA: String = "res://pruebas/fixtures/combate/ia/"
const _CARPETA_UNIDADES: String = "res://pruebas/fixtures/unidades/"
const _ESPECIES: Array[String] = ["ocarra", "rodauva", "surcon", "tasajero", "zancajunco"]
const _FUENTES: Array[String] = [
	"res://nucleo/combate/ia/ia_salvaje.gd",
	"res://nucleo/combate/ia/decision_ia.gd",
	"res://nucleo/combate/ia/opcion_ataque.gd",
]
const _AZAR_PROHIBIDO: Array[String] = ["GeneradorAzar", "randi", "randf", "RandomNumberGenerator"]

var _tablero: Tablero
var _danio: Danio


func before_test() -> void:
	var tabla_combate: Dictionary = _leer(_CARPETA + "combate.json", "combate")
	_tablero = Tablero.desde_datos({"ancho": 8, "alto": 8}, tabla_combate)
	_danio = Danio.desde_datos(tabla_combate, _leer(_CARPETA + "hambre.json", "hambre"))


func _leer(ruta: String, nombre_esquema: String) -> Dictionary:
	var lectura: Dictionary = LectorFixture.leer(ruta, nombre_esquema)
	var errores: Array[Dictionary] = lectura["errores"]
	assert_array(errores).override_failure_message(str(errores)).is_empty()
	return lectura["datos"]


func _plantel(ruta: String) -> Plantel:
	var especies: Dictionary = {}
	for id_especie in _ESPECIES:
		especies[id_especie] = Especie.new(_leer(_CARPETA_UNIDADES + id_especie + ".json", "especie"))
	var tabla: TablaBalanza = TablaBalanza.new(_leer(_CARPETA_UNIDADES + "balanza_1_2.json", "balanza"))
	return Plantel.desde_escenario(_leer(ruta, "escenario"), especies, tabla, _leer(_CARPETA_UNIDADES + "maestro.json", "maestro"))


func _plantel_ia(nombre: String) -> Plantel:
	return _plantel(_CARPETA_IA + nombre + ".json")


func _cola(plantel: Plantel) -> ColaIniciativa:
	var cola: ColaIniciativa = ColaIniciativa.new()
	cola.empezar_ronda(plantel)
	return cola


# Turno suelto de la salvaje, con la cola de la ronda para los desempates.
# surcos: los del combate (sin pasarlos, unos vacios).
func _decidir(plantel: Plantel, unidad_id: String, surcos: Surcos = null) -> Dictionary:
	var del_combate: Surcos = surcos if surcos != null else Surcos.new()
	var turno: Turno = Turno.empezar(EntradaCola.new(unidad_id, "", 0), plantel, _tablero, _danio, del_combate,
			DatosFixture.afinidad(), DatosFixture.cadena(), ColaIniciativa.new())
	return {"turno": turno, "decision": IASalvaje.decidir(turno, plantel, _cola(plantel))}


# Aplica las acciones en orden, como lo hara el bucle de T12: corta si el
# combate termina. Devuelve el resultado del ataque (o null si no ataco).
func _jugar(turno: Turno, decision: DecisionIA) -> ResultadoAccion:
	var ataque: ResultadoAccion = null
	for accion in decision.acciones:
		var resultado: ResultadoAccion = turno.aplicar(accion)
		assert_bool(resultado.valida).override_failure_message(
				decision.describir() + " -> " + ResultadoAccion.Motivo.keys()[resultado.motivo]).is_true()
		if accion.tipo == Accion.Tipo.ATACAR:
			ataque = resultado
		if resultado.fin != FinCombate.Fin.EN_CURSO:
			break
	return ataque


func _textos(decision: DecisionIA) -> Array[String]:
	var textos: Array[String] = []
	for accion in decision.acciones:
		match accion.tipo:
			Accion.Tipo.MOVER:
				textos.append("MOVER %s" % accion.casilla)
			Accion.Tipo.CAVAR:
				textos.append("CAVAR %s" % accion.casilla)
			Accion.Tipo.ATACAR:
				textos.append("ATACAR " + accion.objetivo_id)
			_:
				textos.append(Accion.Tipo.keys()[accion.tipo])
	return textos


func _assert_decision(decision: DecisionIA, paso: DecisionIA.Paso, acciones: Array[String]) -> void:
	assert_str(DecisionIA.Paso.keys()[decision.paso]).override_failure_message(decision.describir()) \
			.is_equal(DecisionIA.Paso.keys()[paso])
	assert_array(_textos(decision)).override_failure_message(decision.describir()).is_equal(acciones)


# Todo lo que una decision podria cambiar en el Plantel (y en los surcos, si se pasan).
func _foto(plantel: Plantel, surcos: Surcos = null) -> String:
	var foto: Array = [plantel.maestro.vida, plantel.maestro.posicion, plantel.maestro.caido]
	for criatura in plantel.criaturas():
		foto.append([criatura.id, criatura.vida, criatura.posicion, criatura.estado, criatura.erizada, criatura.modo,
				criatura.oculta, criatura.bono_junco, criatura.junco_turno_anterior])
	if surcos != null:
		foto.append([surcos.instantanea(), surcos.historial()])
	return str(foto)


# Oculta a una criatura de la tribu, con el bono (Sistema.md 11.2.2), sin jugar su turno.
func _ocultar(plantel: Plantel, unidad_id: String) -> void:
	Junco.ocultar(plantel.criatura(unidad_id))


# (1) Remate: entre dos que puede tumbar, la de menos vida, aunque la otra este
# mas cerca. Hacia [6,4] golpea a distancia 2 desde [6,2] o [4,4] (3 pasos):
# orden de lectura.
func test_remate_va_por_la_de_menos_vida() -> void:
	var plantel: Plantel = _plantel_ia("ia_remate")
	var jugada: Dictionary = _decidir(plantel, "ocarra_s1")
	var decision: DecisionIA = jugada["decision"]
	_assert_decision(decision, DecisionIA.Paso.REMATE, ["MOVER (6, 2)", "ATACAR rodauva_2", "TERMINAR"])
	assert_str(decision.objetivo_id).is_equal("rodauva_2")
	assert_int(decision.danio_previsto).is_equal(4)

	_jugar(jugada["turno"], decision)
	assert_int(plantel.criatura("rodauva_2").estado).is_equal(Criatura.Estado.CAIDA)
	assert_int(plantel.criatura("rodauva_1").vida).is_equal(4)


# (2) Remate moviendose (S-8): desde [4,0] no llega; desde [4,3] tumba a la Rodauva.
func test_remate_moviendose() -> void:
	var plantel: Plantel = _plantel_ia("ia_remate_moviendose")
	var jugada: Dictionary = _decidir(plantel, "ocarra_s1")
	var decision: DecisionIA = jugada["decision"]
	assert_array((jugada["turno"] as Turno).objetivos_para_atacar()).is_empty()
	_assert_decision(decision, DecisionIA.Paso.REMATE, ["MOVER (4, 3)", "ATACAR rodauva_1", "TERMINAR"])

	var ataque: ResultadoAccion = _jugar(jugada["turno"], decision)
	assert_int(ataque.danio).is_equal(decision.danio_previsto)
	assert_int(plantel.criatura("rodauva_1").vida).is_equal(0)
	assert_int(plantel.criatura("rodauva_1").estado).is_equal(Criatura.Estado.CAIDA)


# (3) Remate al Maestro: lo tumba sin moverse y el combate termina (11.5).
func test_remate_al_maestro_termina_el_combate() -> void:
	var plantel: Plantel = _plantel_ia("ia_remate_maestro")
	var jugada: Dictionary = _decidir(plantel, "ocarra_s1")
	var decision: DecisionIA = jugada["decision"]
	_assert_decision(decision, DecisionIA.Paso.REMATE, ["ATACAR " + Maestro.ID, "TERMINAR"])

	var ataque: ResultadoAccion = _jugar(jugada["turno"], decision)
	assert_int(ataque.fin).is_equal(FinCombate.Fin.DERROTA_POR_CAIDA)
	assert_bool(plantel.maestro.caido).is_true()
	assert_int(plantel.criatura("rodauva_1").vida).is_equal(8)


# (4) Cercana, sin remate (paso 5, S-19, P-020): mas cercana -> menos vida ->
# antes en la cola.
func test_cercana_y_sus_desempates() -> void:
	# (a) Rodauva (6) a 1 contra el Maestro (5) a 2: la mas cercana, aunque tenga mas vida.
	var plantel: Plantel = _plantel_ia("ia_cercana")
	_assert_decision(_decidir(plantel, "ocarra_s1")["decision"], DecisionIA.Paso.CERCANA, ["ATACAR rodauva_1", "TERMINAR"])

	# (b) Las dos a 2: la de menos vida, el Maestro.
	plantel = _plantel_ia("ia_cercana")
	plantel.criatura("rodauva_1").posicion = Vector2i(1, 2)
	_assert_decision(_decidir(plantel, "ocarra_s1")["decision"], DecisionIA.Paso.CERCANA, ["ATACAR " + Maestro.ID, "TERMINAR"])

	# (c) Surcon y Rodauva a 2 y con 6: la Rodauva actua antes (Velocidad 6
	# contra 2), aunque el Surcon va antes en el Plantel y en orden de lectura.
	plantel = _plantel_ia("ia_cercana")
	plantel.maestro.posicion = Vector2i(7, 7)
	plantel.maestro.vida = plantel.maestro.vida_max_real()
	plantel.criatura("rodauva_1").posicion = Vector2i(5, 2)
	plantel.criatura("surcon_1").posicion = Vector2i(1, 2)
	plantel.criatura("surcon_1").vida = 6
	_assert_decision(_decidir(plantel, "ocarra_s1")["decision"], DecisionIA.Paso.CERCANA, ["ATACAR rodauva_1", "TERMINAR"])


# (5) Casilla desde donde golpear: si ya alcanza no se mueve; la Ocarra prefiere
# la distancia 2; despues menos pasos y orden de lectura.
func test_casilla_para_golpear() -> void:
	# (a) Ya alcanza a la adyacente: no se mueve.
	var plantel: Plantel = _plantel_ia("ia_casilla_quieta")
	_assert_decision(_decidir(plantel, "ocarra_s1")["decision"], DecisionIA.Paso.CERCANA, ["ATACAR rodauva_1", "TERMINAR"])

	# (b) No alcanza: distancia 2 desde [2,0] (3 pasos) antes que distancia 1 (2 pasos).
	plantel = _plantel_ia("ia_casilla_distancia_2")
	var decision: DecisionIA = _decidir(plantel, "ocarra_s1")["decision"]
	_assert_decision(decision, DecisionIA.Paso.CERCANA, ["MOVER (2, 0)", "ATACAR rodauva_1", "TERMINAR"])

	# (c) Alcance 1: [2,2] y [3,3] a 2 pasos, [3,1] a 4 (primera en orden de
	# lectura): menos pasos y despues orden de lectura.
	plantel = _plantel_ia("ia_casilla_pasos")
	var jugada: Dictionary = _decidir(plantel, "rodauva_s1")
	decision = jugada["decision"]
	_assert_decision(decision, DecisionIA.Paso.CERCANA, ["MOVER (2, 2)", "ATACAR rodauva_1", "TERMINAR"])
	_jugar(jugada["turno"], decision)
	assert_int(plantel.criatura("rodauva_1").vida).is_equal(6)


# (6) Acercarse: sin nadie al alcance, a la casilla alcanzable mas cercana a la
# objetivo; empatadas a 7, orden de lectura.
func test_acercarse() -> void:
	var plantel: Plantel = _plantel_ia("ia_acercarse")
	var jugada: Dictionary = _decidir(plantel, "ocarra_s1")
	var decision: DecisionIA = jugada["decision"]
	_assert_decision(decision, DecisionIA.Paso.ACERCARSE, ["MOVER (3, 0)", "TERMINAR"])
	assert_str(decision.objetivo_id).is_equal("rodauva_1")
	_jugar(jugada["turno"], decision)
	assert_that(plantel.criatura("ocarra_s1").posicion).is_equal(Vector2i(3, 0))


# (7) Erizarse (paso 3): vida <= 50% y una enemiga adyacente; 4 de 8 es el borde.
func test_erizarse() -> void:
	for vida in [3, 4]:
		var plantel: Plantel = _plantel_ia("ia_erizarse")
		plantel.criatura("rodauva_s1").vida = vida
		var jugada: Dictionary = _decidir(plantel, "rodauva_s1")
		var decision: DecisionIA = jugada["decision"]
		_assert_decision(decision, DecisionIA.Paso.ERIZARSE, ["ERIZARSE", "TERMINAR"])
		_jugar(jugada["turno"], decision)
		assert_bool(plantel.criatura("rodauva_s1").erizada).is_true()
		assert_that(plantel.criatura("rodauva_s1").posicion).is_equal(Vector2i(3, 3))

	# Con 5 de 8 sigue la lista: ataca al Maestro adyacente.
	var con_cinco: Plantel = _plantel_ia("ia_erizarse")
	con_cinco.criatura("rodauva_s1").vida = 5
	_assert_decision(_decidir(con_cinco, "rodauva_s1")["decision"], DecisionIA.Paso.CERCANA, ["ATACAR " + Maestro.ID, "TERMINAR"])

	# Con 3 pero sin enemiga adyacente: se mueve y ataca.
	var sin_adyacente: Plantel = _plantel_ia("ia_erizarse")
	sin_adyacente.criatura("rodauva_s1").vida = 3
	sin_adyacente.maestro.posicion = Vector2i(3, 6)
	_assert_decision(_decidir(sin_adyacente, "rodauva_s1")["decision"], DecisionIA.Paso.CERCANA,
			["MOVER (3, 5)", "ATACAR " + Maestro.ID, "TERMINAR"])


# (8) Una especie sin el rasgo no se eriza aunque tenga poca vida y una enemiga adyacente.
func test_sin_el_rasgo_no_se_eriza() -> void:
	var plantel: Plantel = _plantel_ia("ia_erizarse")
	plantel.criatura("ocarra_s1").vida = 2
	_assert_decision(_decidir(plantel, "ocarra_s1")["decision"], DecisionIA.Paso.CERCANA, ["ATACAR rodauva_1", "TERMINAR"])


# (9) Nadie apunta a una caida, aunque podria tumbarla y este adyacente.
func test_nadie_apunta_a_una_caida() -> void:
	var plantel: Plantel = _plantel_ia("ia_caida")
	plantel.criatura("rodauva_1").vida = 0
	plantel.criatura("rodauva_1").estado = Criatura.Estado.CAIDA
	var decision: DecisionIA = _decidir(plantel, "ocarra_s1")["decision"]
	_assert_decision(decision, DecisionIA.Paso.CERCANA, ["ATACAR rodauva_2", "TERMINAR"])


# (10) El Tasajero decide una vez por ronda, en Caza, con el tablero de ese
# momento: en la ronda 1 tumba a la Rodauva; en la 2 va por el Maestro.
# Reescrito por Sistema.md 11.2.3 v1.3 (antes: decidia en Caza y otra vez en
# Cuenta en la misma ronda) y 11.2 (Danio 5). Reescrito en T39 por 11.8 paso 6b:
# en Caza elige casilla y presas (paso CAZA, no REMATE ni CERCANA); el primer
# golpe tumba a la Rodauva y el segundo se pierde (S-23), y al Maestro le da los
# dos ataques: 5 + 5.
func test_tasajero_decide_en_cada_turno() -> void:
	var plantel: Plantel = _plantel_ia("ia_tasajero")
	var cola: ColaIniciativa = ColaIniciativa.new()
	var decisiones: Array[DecisionIA] = []
	for ronda in range(2):
		cola.empezar_ronda(plantel)
		var entrada: EntradaCola = cola.siguiente(plantel)
		while entrada != null:
			var turno: Turno = Turno.empezar(entrada, plantel, _tablero, _danio, Surcos.new(), DatosFixture.afinidad(),
					DatosFixture.cadena(), cola)
			if entrada.unidad_id == "tasajero_s1":
				assert_str(entrada.marca).is_equal("caza")
				var decision: DecisionIA = IASalvaje.decidir(turno, plantel, cola)
				decisiones.append(decision)
				_jugar(turno, decision)
			else:
				assert_bool(turno.aplicar(Accion.terminar()).valida).is_true()
			entrada = cola.siguiente(plantel)
		cola.terminar_ronda()

	assert_int(decisiones.size()).is_equal(2)
	_assert_decision(decisiones[0], DecisionIA.Paso.CAZA, ["MOVER (3, 3)", "ATACAR rodauva_1", "TERMINAR"])
	_assert_decision(decisiones[1], DecisionIA.Paso.CAZA,
			["MOVER (6, 3)", "ATACAR " + Maestro.ID, "ATACAR " + Maestro.ID, "TERMINAR"])
	assert_int(plantel.criatura("rodauva_1").estado).is_equal(Criatura.Estado.CAIDA)
	assert_int(plantel.maestro.vida).is_equal(plantel.maestro.vida_max_real() - 5 - 5)


# (11) Previsualizar y decidir no cambian el Plantel; misma situacion, mismas
# acciones; sin el generador de azar. Reescrito por Sistema.md 11.2.2 v1.3: sin
# el +2 de primer ataque, la IA ve 4, el mismo danio que el ataque real (el
# bono de Hacerse junco y su gasto se prueban en T38).
func test_decidir_no_cambia_nada_y_es_determinista() -> void:
	var plantel: Plantel = _plantel_ia("ia_junco")
	var antes: String = _foto(plantel)
	var primera: DecisionIA = _decidir(plantel, "zancajunco_s1")["decision"]
	var jugada: Dictionary = _decidir(plantel, "zancajunco_s1")
	var segunda: DecisionIA = jugada["decision"]
	# Tumba a la Rodauva (4) con su danio de ficha.
	_assert_decision(primera, DecisionIA.Paso.REMATE, ["MOVER (3, 3)", "ATACAR rodauva_1", "TERMINAR"])
	assert_int(primera.danio_previsto).is_equal(4)
	assert_str(_foto(plantel)).is_equal(antes)
	assert_array(_textos(segunda)).is_equal(_textos(primera))
	assert_str(segunda.describir()).is_equal(primera.describir())

	var ataque: ResultadoAccion = _jugar(jugada["turno"], segunda)
	assert_int(ataque.danio).is_equal(primera.danio_previsto)

	for ruta in _FUENTES:
		var codigo: String = FileAccess.get_file_as_string(ruta)
		assert_str(codigo).is_not_empty()
		for prohibido in _AZAR_PROHIBIDO:
			assert_bool(codigo.contains(prohibido)).override_failure_message(ruta + " usa " + prohibido).is_false()


# (12) Escenario A (P-009): la Ocarra va por la Rodauva. Ronda 1: se acerca a
# [4,3]; ronda 2: la golpea desde [4,5], a distancia 2 (8 -> 4).
func test_escenario_a_la_ocarra_va_por_la_rodauva() -> void:
	var plantel: Plantel = _plantel(_CARPETA_UNIDADES + "escenario_a.json")
	var cola: ColaIniciativa = ColaIniciativa.new()
	var decisiones: Array[DecisionIA] = []
	for ronda in range(2):
		cola.empezar_ronda(plantel)
		var entrada: EntradaCola = cola.siguiente(plantel)
		while entrada != null:
			var turno: Turno = Turno.empezar(entrada, plantel, _tablero, _danio, Surcos.new(), DatosFixture.afinidad(),
					DatosFixture.cadena(), cola)
			if entrada.unidad_id == "ocarra_s1":
				var decision: DecisionIA = IASalvaje.decidir(turno, plantel, cola)
				decisiones.append(decision)
				_jugar(turno, decision)
			else:
				assert_bool(turno.aplicar(Accion.terminar()).valida).is_true()
			entrada = cola.siguiente(plantel)
		cola.terminar_ronda()

	_assert_decision(decisiones[0], DecisionIA.Paso.ACERCARSE, ["MOVER (4, 3)", "TERMINAR"])
	assert_str(decisiones[0].objetivo_id).is_equal("rodauva_1")
	_assert_decision(decisiones[1], DecisionIA.Paso.CERCANA, ["MOVER (4, 5)", "ATACAR rodauva_1", "TERMINAR"])
	assert_int(plantel.criatura("rodauva_1").vida).is_equal(4)
	assert_int(plantel.maestro.vida).is_equal(plantel.maestro.vida_max_real())


# ---------------------------------------------------------------------------
# T39 (Arquitectura.md B.2.1): IA v1.3, Sistema.md 11.8 pasos 2, 6b, 7 y 8.

# T39 (1) Caza (paso 6b, 11.2.3 Dos presas): en cruz, la esquina concava [2,4]
# lo deja junto a 2 presas y le da un ataque a cada una (la Rodauva, de menos
# vida, primero: P-026). En linea o en bloque no hay casilla con 2 presas: una
# sola, con los dos ataques.
func test_t39_caza_cruz_y_linea() -> void:
	var plantel: Plantel = _plantel_ia("ia_caza_cruz")
	var jugada: Dictionary = _decidir(plantel, "tasajero_s1")
	var decision: DecisionIA = jugada["decision"]
	_assert_decision(decision, DecisionIA.Paso.CAZA, ["MOVER (2, 4)", "ATACAR rodauva_1", "ATACAR ocarra_1", "TERMINAR"])
	assert_array(decision.objetivos).is_equal(["rodauva_1", "ocarra_1"])
	assert_int(decision.danio_previsto).is_equal(5 + 5)
	_jugar(jugada["turno"], decision)
	assert_int(plantel.criatura("rodauva_1").vida).is_equal(8 - 5)
	assert_int(plantel.criatura("ocarra_1").vida).is_equal(12 - 5)

	# Linea: [3,4] junto a la Rodauva, 5 + 5 y cae en el segundo (11.2.3, Contra la Rodauva).
	plantel = _plantel_ia("ia_caza_linea")
	jugada = _decidir(plantel, "tasajero_s1")
	decision = jugada["decision"]
	_assert_decision(decision, DecisionIA.Paso.CAZA, ["MOVER (3, 4)", "ATACAR rodauva_1", "ATACAR rodauva_1", "TERMINAR"])
	_jugar(jugada["turno"], decision)
	assert_int(plantel.criatura("rodauva_1").estado).is_equal(Criatura.Estado.CAIDA)
	assert_int(plantel.criatura("ocarra_1").vida).is_equal(12)

	# Bloque de 2 x 2 (Maestro [2,5], Rodauva [3,5], Ocarra [2,6], Surcon [3,6]):
	# tampoco hay esquina con 2 presas; va por la Rodauva desde [3,4].
	plantel = _plantel_ia("ia_caza_linea")
	plantel.criatura("ocarra_1").posicion = Vector2i(2, 6)
	plantel.criatura("surcon_1").posicion = Vector2i(3, 6)
	_assert_decision(_decidir(plantel, "tasajero_s1")["decision"], DecisionIA.Paso.CAZA,
			["MOVER (3, 4)", "ATACAR rodauva_1", "ATACAR rodauva_1", "TERMINAR"])


# T39 (2) Desempates de la casilla de Caza (tabla de 11.8), uno por renglon, y
# con 3 presas las 2 de menos vida. ia_caza: [2,4] (Rodauva 8 + Ocarra 12) a 3
# pasos desde [3,2]; [5,4] y [4,5] (Maestro 20 + Surcon 24) a 4.
func test_t39_desempates_de_la_caza() -> void:
	# (a) Junto a 2 presas > junto a 1, aunque la de 1 tumbe: con el Maestro en
	# 10, [3,4] lo tumba con 5 + 5, pero va a [2,4].
	var plantel: Plantel = _plantel_ia("ia_caza")
	plantel.maestro.vida = 10
	_assert_decision(_decidir(plantel, "tasajero_s1")["decision"], DecisionIA.Paso.CAZA,
			["MOVER (2, 4)", "ATACAR rodauva_1", "ATACAR ocarra_1", "TERMINAR"])

	# (b) La que tumba a alguien, aunque sume mas vida: el Surcon en 5 hace que
	# [5,4] y [4,5] tumben (25 contra 20). Orden de lectura: [5,4]. Primero el
	# Surcon, de menos vida (P-026).
	plantel = _plantel_ia("ia_caza")
	plantel.criatura("surcon_1").vida = 5
	_assert_decision(_decidir(plantel, "tasajero_s1")["decision"], DecisionIA.Paso.CAZA,
			["MOVER (5, 4)", "ATACAR surcon_1", "ATACAR " + Maestro.ID, "TERMINAR"])

	# (c) Menos vida sumada: 20 en [2,4] contra 44.
	plantel = _plantel_ia("ia_caza")
	_assert_decision(_decidir(plantel, "tasajero_s1")["decision"], DecisionIA.Paso.CAZA,
			["MOVER (2, 4)", "ATACAR rodauva_1", "ATACAR ocarra_1", "TERMINAR"])

	# (d) Menos pasos: con el Maestro en 8 y el Surcon en 12 los dos pares suman
	# 20. Desde [4,2], [5,4] queda a 3 pasos y [2,4] a 4, aunque [2,4] va antes
	# en orden de lectura.
	plantel = _plantel_ia("ia_caza")
	plantel.maestro.vida = 8
	plantel.criatura("surcon_1").vida = 12
	plantel.criatura("tasajero_s1").posicion = Vector2i(4, 2)
	_assert_decision(_decidir(plantel, "tasajero_s1")["decision"], DecisionIA.Paso.CAZA,
			["MOVER (5, 4)", "ATACAR " + Maestro.ID, "ATACAR surcon_1", "TERMINAR"])

	# (e) Orden de lectura: Maestro 8 + Surcon 12 en [5,4] y [4,5], las dos a 4
	# pasos; la Ocarra en 24 deja a [2,4] con 32. Gana [5,4] (y menor).
	plantel = _plantel_ia("ia_caza")
	plantel.maestro.vida = 8
	plantel.criatura("surcon_1").vida = 12
	plantel.criatura("ocarra_1").vida = 24
	_assert_decision(_decidir(plantel, "tasajero_s1")["decision"], DecisionIA.Paso.CAZA,
			["MOVER (5, 4)", "ATACAR " + Maestro.ID, "ATACAR surcon_1", "TERMINAR"])

	# (f) 3 presas en [3,4] (Rodauva 8, Ocarra 12, Maestro 20; el Surcon queda
	# lejos): ataca a las 2 de menos vida.
	plantel = _plantel_ia("ia_caza")
	_tres_presas(plantel)
	_assert_decision(_decidir(plantel, "tasajero_s1")["decision"], DecisionIA.Paso.CAZA,
			["MOVER (3, 4)", "ATACAR rodauva_1", "ATACAR ocarra_1", "TERMINAR"])

	# (g) Lectura declarada P-026: empatadas en vida, antes en la cola. Con las
	# tres en 8: la Ocarra (7) y la Rodauva (6); el Maestro (5) queda afuera.
	plantel = _plantel_ia("ia_caza")
	_tres_presas(plantel)
	plantel.maestro.vida = 8
	plantel.criatura("ocarra_1").vida = 8
	_assert_decision(_decidir(plantel, "tasajero_s1")["decision"], DecisionIA.Paso.CAZA,
			["MOVER (3, 4)", "ATACAR ocarra_1", "ATACAR rodauva_1", "TERMINAR"])


# Tasajero [3,1]; [3,4] queda junto a la Rodauva [2,4], el Maestro [4,4] y la
# Ocarra [3,5], a 3 pasos. Ninguna otra casilla a su alcance tiene 2 presas.
func _tres_presas(plantel: Plantel) -> void:
	plantel.criatura("tasajero_s1").posicion = Vector2i(3, 1)
	plantel.criatura("rodauva_1").posicion = Vector2i(2, 4)
	plantel.criatura("ocarra_1").posicion = Vector2i(3, 5)
	plantel.criatura("surcon_1").posicion = Vector2i(7, 7)


# T39 (3) El primer ataque tumba a su presa (S-23). Con 2 presas, el segundo va
# a la otra adyacente. Con 1, el segundo se pierde: la decision lleva un solo ataque.
func test_t39_el_primer_golpe_tumba() -> void:
	# Cruz con la Rodauva en 5: cae con el primero y el segundo va a la Ocarra.
	var plantel: Plantel = _plantel_ia("ia_caza_cruz")
	plantel.criatura("rodauva_1").vida = 5
	var jugada: Dictionary = _decidir(plantel, "tasajero_s1")
	var decision: DecisionIA = jugada["decision"]
	_assert_decision(decision, DecisionIA.Paso.CAZA, ["MOVER (2, 4)", "ATACAR rodauva_1", "ATACAR ocarra_1", "TERMINAR"])
	_jugar(jugada["turno"], decision)
	assert_int(plantel.criatura("rodauva_1").estado).is_equal(Criatura.Estado.CAIDA)
	assert_int(plantel.criatura("ocarra_1").vida).is_equal(12 - 5)

	# Linea con la Rodauva en 5: cae con el primero; no hay otra presa junto a [3,4].
	plantel = _plantel_ia("ia_caza_linea")
	plantel.criatura("rodauva_1").vida = 5
	jugada = _decidir(plantel, "tasajero_s1")
	decision = jugada["decision"]
	_assert_decision(decision, DecisionIA.Paso.CAZA, ["MOVER (3, 4)", "ATACAR rodauva_1", "TERMINAR"])
	_jugar(jugada["turno"], decision)
	assert_int(plantel.criatura("rodauva_1").estado).is_equal(Criatura.Estado.CAIDA)
	assert_int(plantel.maestro.vida).is_equal(plantel.maestro.vida_max_real())
	assert_int(plantel.criatura("ocarra_1").vida).is_equal(12)
	assert_bool((jugada["turno"] as Turno).terminado).is_true()


# T39 (4) Cuenta (tabla de 11.8, Retirada): golpea desde la casilla de menos
# pasos (5 - 1 = 4) y se retira con los que le quedan a la mas lejana de la
# enemiga de pie mas cercana; puede volver a la casilla de la que salio.
# Arrinconado, sin casilla que lo aleje, se queda.
func test_t39_cuenta_golpea_y_se_retira() -> void:
	var plantel: Plantel = _plantel_ia("ia_cuenta")
	plantel.criatura("tasajero_s1").modo = "cuenta"
	var jugada: Dictionary = _decidir(plantel, "tasajero_s1")
	var decision: DecisionIA = jugada["decision"]
	_assert_decision(decision, DecisionIA.Paso.CERCANA, ["MOVER (3, 3)", "ATACAR rodauva_1", "MOVER (3, 1)", "TERMINAR"])
	assert_that(decision.retirada).is_equal(Vector2i(3, 1))
	assert_int(decision.danio_previsto).is_equal(4)
	_jugar(jugada["turno"], decision)
	assert_int(plantel.criatura("rodauva_1").vida).is_equal(8 - 4)
	assert_that(plantel.criatura("tasajero_s1").posicion).is_equal(Vector2i(3, 1))

	# Arrinconado en [0,0] entre la Rodauva [1,0] y la Ocarra [0,1]: ataca a la
	# de menos vida desde su casilla y no se mueve.
	plantel = _plantel_ia("ia_cuenta")
	plantel.criatura("tasajero_s1").modo = "cuenta"
	plantel.criatura("tasajero_s1").posicion = Vector2i(0, 0)
	plantel.criatura("rodauva_1").posicion = Vector2i(1, 0)
	plantel.criatura("ocarra_1").posicion = Vector2i(0, 1)
	jugada = _decidir(plantel, "tasajero_s1")
	decision = jugada["decision"]
	_assert_decision(decision, DecisionIA.Paso.CERCANA, ["ATACAR rodauva_1", "TERMINAR"])
	assert_that(decision.retirada).is_equal(Criatura.SIN_POSICION)
	_jugar(jugada["turno"], decision)
	assert_that(plantel.criatura("tasajero_s1").posicion).is_equal(Vector2i(0, 0))


# T39 (5) F en fixtures (Sistema.md 11.9 y 11.2.2), con la tribu esperando: el
# Zancajunco salvaje se oculta en la ronda 1 (paso 7), avanza destapado y con el
# bono en la 2 (paso 8) y en la 3 pega 4 + 3 = 7 y tumba al Maestro con 6. Si el
# Maestro lo golpea en la 2, pierde el bono y en la 3 pega 4.
func test_t39_f_el_zancajunco_se_oculta_avanza_y_embiste() -> void:
	var combate: Combate = _combate_f(false)
	var zancajunco: Criatura = combate.contexto().plantel.criatura("zancajunco_s1")
	var acciones: Array[Dictionary] = _acciones_de(combate, "zancajunco_s1")
	assert_str(acciones[0]["paso"]).is_equal("prepararse")
	assert_str(acciones[0]["accion"]["tipo"]).is_equal("hacerse_junco")
	assert_str(acciones[1]["paso"]).is_equal("acercarse")
	assert_str(acciones[1]["accion"]["tipo"]).is_equal("mover")
	var golpe: Dictionary = _ataques_de(combate, "zancajunco_s1")[0]
	assert_str(golpe["objetivo"]).is_equal(Maestro.ID)
	assert_int((golpe["desglose"] as Dictionary)["total"] as int).is_equal(7)
	assert_int(golpe["vida_antes"] as int).is_equal(6)
	assert_bool(combate.terminado()).is_true()
	assert_int(combate.fin()).is_equal(FinCombate.Fin.DERROTA_POR_CAIDA)
	assert_bool(zancajunco.bono_junco).is_false()
	# En la ronda 2 avanzo destapado (motivo mover) y conservando el bono.
	var destapes: Array[Dictionary] = []
	for linea in combate.registro().lineas():
		if linea["tipo"] == "destape" and linea["unidad"] == "zancajunco_s1":
			destapes.append(linea)
	assert_str(destapes[0]["motivo"]).is_equal(Junco.MOTIVO_MOVER)

	# Variante: el Maestro lo golpea en la ronda 2 y le quita el bono.
	combate = _combate_f(true)
	golpe = _ataques_de(combate, "zancajunco_s1")[0]
	assert_str(golpe["objetivo"]).is_equal(Maestro.ID)
	assert_int((golpe["desglose"] as Dictionary)["total"] as int).is_equal(4)


# Juega F con fixtures hasta que termina o hasta la ronda 4. La tribu espera,
# salvo con golpe_en_la_2: el Maestro [3,6] va a [3,3] y golpea al Zancajunco,
# que esta en [3,2] tras avanzar.
func _combate_f(golpe_en_la_2: bool) -> Combate:
	var lectura: Dictionary = DatosFixture.cargar()
	assert_array(lectura["errores"]).is_empty()
	var escenario: Dictionary = _leer(_CARPETA + "escenario_f.json", "escenario")
	var combate: Combate = Combate.empezar(ContextoCombate.armar(escenario, lectura["datos"]))
	while not combate.terminado() and int(combate.instantanea()["ronda"]) < 4:
		assert_str(combate.error()).is_empty()
		var turno: Turno = combate.turno_actual()
		if golpe_en_la_2 and int(combate.instantanea()["ronda"]) == 2 and turno.unidad_id == Maestro.ID:
			assert_that(combate.contexto().plantel.criatura("zancajunco_s1").posicion).is_equal(Vector2i(3, 2))
			assert_bool(combate.aplicar(Accion.mover(Vector2i(3, 3))).valida).is_true()
			assert_bool(combate.aplicar(Accion.atacar("zancajunco_s1")).valida).is_true()
			assert_bool(combate.contexto().plantel.criatura("zancajunco_s1").bono_junco).is_false()
		assert_bool(combate.aplicar(Accion.terminar()).valida).is_true()
	assert_str(combate.error()).is_empty()
	return combate


func _acciones_de(combate: Combate, unidad_id: String) -> Array[Dictionary]:
	var resultado: Array[Dictionary] = []
	for linea in combate.registro().lineas():
		if linea["tipo"] == "accion" and linea["unidad"] == unidad_id and linea["accion"]["tipo"] != "terminar":
			resultado.append(linea)
	return resultado


func _ataques_de(combate: Combate, unidad_id: String) -> Array[Dictionary]:
	var resultado: Array[Dictionary] = []
	for linea in combate.registro().lineas():
		if linea["tipo"] == "ataque" and linea["atacante"] == unidad_id:
			resultado.append(linea)
	return resultado


# T39 (6) Surcon salvaje (paso 7, 11.2.1): sin nadie a su alcance cava en la
# casilla valida mas cercana a la enemiga de pie mas cercana -> orden de
# lectura. Con el tope lleno no cava: se acerca (paso 8).
func test_t39_surcon_cava_hacia_la_mas_cercana() -> void:
	var plantel: Plantel = _plantel_ia("ia_surcon")
	var surcos: Surcos = Surcos.new()
	var jugada: Dictionary = _decidir(plantel, "surcon_s1", surcos)
	var decision: DecisionIA = jugada["decision"]
	_assert_decision(decision, DecisionIA.Paso.PREPARARSE, ["CAVAR (2, 1)", "TERMINAR"])
	assert_str(decision.objetivo_id).is_equal(Maestro.ID)
	_jugar(jugada["turno"], decision)
	assert_array(surcos.de("surcon_s1")).is_equal([Vector2i(2, 1)])

	# Lectura declarada P-027: el Maestro (20) y la Rodauva [6,4] (8) a 6: la de
	# menos vida. Hacia la Rodauva, [4,1] y [3,2] quedan a 5: orden de lectura.
	plantel = _plantel_ia("ia_surcon")
	plantel.criatura("rodauva_1").posicion = Vector2i(6, 4)
	_assert_decision(_decidir(plantel, "surcon_s1")["decision"], DecisionIA.Paso.PREPARARSE, ["CAVAR (4, 1)", "TERMINAR"])

	# Tope lleno (2 surcos de la ficha): se acerca al Maestro.
	plantel = _plantel_ia("ia_surcon")
	surcos = Surcos.new()
	surcos.cavar(Vector2i(0, 0), "surcon_s1", 2)
	surcos.cavar(Vector2i(7, 0), "surcon_s1", 2)
	decision = _decidir(plantel, "surcon_s1", surcos)["decision"]
	_assert_decision(decision, DecisionIA.Paso.ACERCARSE, ["MOVER (2, 2)", "TERMINAR"])


# T39 (7) Ninguna IA elige a una oculta (11.2.2, 11.8 reglas fijas): ni como
# presa de la Caza, ni como "mas cercana" de la retirada de la Cuenta o del
# surco, ni para acercarse (esta en el test 9).
func test_t39_ninguna_ia_elige_a_una_oculta() -> void:
	# Caza: el Zancajunco oculto en [1,4], con 4, seria una tercera presa de
	# [2,4] (la de menos vida). Oculto no cuenta: Rodauva y Ocarra.
	var plantel: Plantel = _plantel_ia("ia_caza_cruz")
	plantel.criatura("zancajunco_1").posicion = Vector2i(1, 4)
	plantel.criatura("zancajunco_1").vida = 4
	_ocultar(plantel, "zancajunco_1")
	var decision: DecisionIA = _decidir(plantel, "tasajero_s1")["decision"]
	_assert_decision(decision, DecisionIA.Paso.CAZA, ["MOVER (2, 4)", "ATACAR rodauva_1", "ATACAR ocarra_1", "TERMINAR"])

	# Cuenta: tumba a la Rodauva (4) desde [3,3]; la enemiga de pie mas cercana
	# es el Maestro [0,5] (a 5), no el Zancajunco oculto [5,1] (a 4). Se retira
	# lejos del Maestro: [3,1] (lejos del Zancajunco seria [1,3]).
	plantel = _plantel_ia("ia_cuenta")
	plantel.criatura("tasajero_s1").modo = "cuenta"
	plantel.criatura("rodauva_1").vida = 4
	plantel.maestro.posicion = Vector2i(0, 5)
	plantel.criatura("ocarra_1").posicion = Vector2i(7, 7)
	plantel.criatura("zancajunco_1").posicion = Vector2i(5, 1)
	_ocultar(plantel, "zancajunco_1")
	decision = _decidir(plantel, "tasajero_s1")["decision"]
	_assert_decision(decision, DecisionIA.Paso.REMATE, ["MOVER (3, 3)", "ATACAR rodauva_1", "MOVER (3, 1)", "TERMINAR"])

	# Surcon: el Zancajunco oculto [5,1] esta a 2 y no lo puede atacar; cava
	# hacia el Maestro, [2,1] (hacia el Zancajunco seria [4,1]).
	plantel = _plantel_ia("ia_surcon")
	plantel.criatura("zancajunco_1").posicion = Vector2i(5, 1)
	_ocultar(plantel, "zancajunco_1")
	_assert_decision(_decidir(plantel, "surcon_s1")["decision"], DecisionIA.Paso.PREPARARSE, ["CAVAR (2, 1)", "TERMINAR"])


# T39 (8) La explicacion de la IA dice el paso de 11.8 (y el modo, y el cambio de
# modo del paso 2). Ademas, en los pasos nuevos decidir no cambia nada y da lo
# mismo dos veces (extiende el test 11 de T11).
func test_t39_la_explicacion_dice_el_paso() -> void:
	# Paso 2: con 15 de 30 al inicio de su turno pasa a Cuenta (T36) y juega
	# este turno en Cuenta: golpea y se retira.
	var plantel: Plantel = _plantel_ia("ia_cuenta")
	plantel.criatura("tasajero_s1").vida = 15
	var decision: DecisionIA = _decidir(plantel, "tasajero_s1")["decision"]
	assert_dict(decision.cambio_modo).is_equal({"de": "caza", "a": "cuenta"})
	assert_str(decision.modo).is_equal("cuenta")
	assert_str(decision.describir()).contains("paso 6 CERCANA").contains("[cuenta]").contains("paso 2: caza->cuenta") \
			.contains("se retira a (3, 1)")

	var casos: Array = [
		["ia_erizarse", "rodauva_s1", "paso 4 ERIZARSE"],
		["ia_remate", "ocarra_s1", "paso 5 REMATE"],
		["ia_cercana", "ocarra_s1", "paso 6 CERCANA"],
		["ia_caza_cruz", "tasajero_s1", "paso 6b CAZA [caza]"],
		["ia_surcon", "surcon_s1", "paso 7 PREPARARSE"],
		["ia_acercarse", "ocarra_s1", "paso 8 ACERCARSE"],
	]
	for caso in casos:
		plantel = _plantel_ia(caso[0])
		if caso[0] == "ia_erizarse":
			plantel.criatura("rodauva_s1").vida = 3
		var texto: String = (_decidir(plantel, caso[1])["decision"] as DecisionIA).describir()
		assert_str(texto).override_failure_message(texto).contains(caso[2])
		assert_bool(texto.contains("paso 2")).is_false()

	# Decidir no cambia nada (Plantel ni surcos) y es determinista en Caza,
	# Cuenta (con retirada), cavar y ocultarse.
	var sin_cambios: Array = [["ia_caza_cruz", "tasajero_s1"], ["ia_cuenta", "tasajero_s1"],
			["ia_surcon", "surcon_s1"], ["ia_junco", "zancajunco_s1"]]
	for caso in sin_cambios:
		plantel = _plantel_ia(caso[0])
		if caso[0] == "ia_cuenta":
			plantel.criatura("tasajero_s1").modo = "cuenta"
		if caso[0] == "ia_junco":
			# Sin nadie a su alcance (la Rodauva a 8): se oculta.
			plantel.criatura("rodauva_1").posicion = Vector2i(0, 7)
		var surcos: Surcos = Surcos.new()
		var antes: String = _foto(plantel, surcos)
		var primera: DecisionIA = _decidir(plantel, caso[1], surcos)["decision"]
		var segunda: DecisionIA = _decidir(plantel, caso[1], surcos)["decision"]
		assert_str(_foto(plantel, surcos)).override_failure_message(caso[0]).is_equal(antes)
		assert_str(segunda.describir()).is_equal(primera.describir())
	var junco: Plantel = _plantel_ia("ia_junco")
	junco.criatura("rodauva_1").posicion = Vector2i(0, 7)
	_assert_decision(_decidir(junco, "zancajunco_s1")["decision"], DecisionIA.Paso.PREPARARSE, ["HACERSE_JUNCO", "TERMINAR"])


# T39 (9) Destapar y pegar no se planifica (11.2.2 v1.4): la Rodauva salvaje va
# hacia el Maestro (el Zancajunco oculto, mas cerca, no es objetivo), termina
# en [3,4] junto a el, lo destapa y no lo ataca en ese turno.
func test_t39_termina_al_lado_de_una_oculta_y_no_la_ataca() -> void:
	var plantel: Plantel = _plantel_ia("ia_oculta")
	_ocultar(plantel, "zancajunco_1")
	var jugada: Dictionary = _decidir(plantel, "rodauva_s1")
	var decision: DecisionIA = jugada["decision"]
	_assert_decision(decision, DecisionIA.Paso.ACERCARSE, ["MOVER (3, 4)", "TERMINAR"])
	assert_str(decision.objetivo_id).is_equal(Maestro.ID)
	var turno: Turno = jugada["turno"]
	_jugar(turno, decision)
	var zancajunco: Criatura = plantel.criatura("zancajunco_1")
	assert_bool(zancajunco.oculta).is_false()
	assert_bool(zancajunco.bono_junco).is_true()
	assert_int(zancajunco.vida).is_equal(12)
	assert_array(turno.eventos()).is_equal([
		{"tipo": "destape", "unidad": "zancajunco_1", "motivo": Junco.MOTIVO_CONTACTO, "por": "rodauva_s1"},
	])
