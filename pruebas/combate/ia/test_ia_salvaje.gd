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
func _decidir(plantel: Plantel, unidad_id: String) -> Dictionary:
	var turno: Turno = Turno.empezar(EntradaCola.new(unidad_id, "", 0), plantel, _tablero, _danio, Surcos.new())
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
			Accion.Tipo.ATACAR:
				textos.append("ATACAR " + accion.objetivo_id)
			_:
				textos.append(Accion.Tipo.keys()[accion.tipo])
	return textos


func _assert_decision(decision: DecisionIA, paso: DecisionIA.Paso, acciones: Array[String]) -> void:
	assert_str(DecisionIA.Paso.keys()[decision.paso]).override_failure_message(decision.describir()) \
			.is_equal(DecisionIA.Paso.keys()[paso])
	assert_array(_textos(decision)).override_failure_message(decision.describir()).is_equal(acciones)


# Todo lo que una decision podria cambiar en el Plantel.
func _foto(plantel: Plantel) -> String:
	var foto: Array = [plantel.maestro.vida, plantel.maestro.posicion, plantel.maestro.caido]
	for criatura in plantel.criaturas():
		foto.append([criatura.id, criatura.vida, criatura.posicion, criatura.estado, criatura.erizada, criatura.modo])
	return str(foto)


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
# Cuenta en la misma ronda) y 11.2 (Danio 5).
func test_tasajero_decide_en_cada_turno() -> void:
	var plantel: Plantel = _plantel_ia("ia_tasajero")
	var cola: ColaIniciativa = ColaIniciativa.new()
	var decisiones: Array[DecisionIA] = []
	for ronda in range(2):
		cola.empezar_ronda(plantel)
		var entrada: EntradaCola = cola.siguiente(plantel)
		while entrada != null:
			var turno: Turno = Turno.empezar(entrada, plantel, _tablero, _danio, Surcos.new())
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
	_assert_decision(decisiones[0], DecisionIA.Paso.REMATE, ["MOVER (3, 3)", "ATACAR rodauva_1", "TERMINAR"])
	_assert_decision(decisiones[1], DecisionIA.Paso.CERCANA, ["MOVER (6, 3)", "ATACAR " + Maestro.ID, "TERMINAR"])
	assert_int(plantel.criatura("rodauva_1").estado).is_equal(Criatura.Estado.CAIDA)
	assert_int(plantel.maestro.vida).is_equal(plantel.maestro.vida_max_real() - 5)


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
			var turno: Turno = Turno.empezar(entrada, plantel, _tablero, _danio, Surcos.new())
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
