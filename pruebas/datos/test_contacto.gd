extends GdUnitTestSuite

# Arquitectura.md B.3.1 (T43) y A.11 ("Contacto de los escenarios"): test
# permanente con datos/ real. Juega cada escenario con el jugador esperando
# (solo `terminar`, salvo lo minimo que obliga una regla, T19) y comprueba los
# criterios de despliegue de Sistema.md 11.9 v1.6 contra la IA real. Todo sale
# del registro, de la instantanea y de las consultas del nucleo: el test no
# calcula reglas por su cuenta. Si una tarea hace fallar este test, no se ajustan
# el test ni las coordenadas: se anota en docs/PREGUNTAS.md (CLAUDE.md, "Test de contacto").
const _CARPETA_DATOS: String = "res://datos"
# Corta un combate que no avanza (nunca deberia pasar).
const _TOPE_ACCIONES: int = 200

# Sistema.md 11.9 v1.6, Criterios de despliegue en 12 x 12: distancia minima
# tribu-enemiga por escenario (estandar 8; E, 10). G queda en 8 x 8, aparte.
const _DISTANCIA: Dictionary = {
	"a_dia_1": 8, "b_muro": 8, "c_tasajero": 8, "h_soplo": 8,
	"d_rivales_normal": 8, "d_rivales_hambriento": 8, "d_rivales_balanza4": 8,
	"e_cobardia": 10, "e_cobardia_afines": 10, "f_rescate": 8,
}
# Sistema.md 11.3 v1.6: tablero de referencia 12 x 12; G, excepcion en 8 x 8 (11.9).
const _LADO_REFERENCIA: int = 12
const _LADO_G: int = 8
const _G: String = "g_ataque_nocturno"
const _D: Array[String] = ["d_rivales_normal", "d_rivales_hambriento", "d_rivales_balanza4"]
const _E: Array[String] = ["e_cobardia", "e_cobardia_afines"]


func _datos() -> Dictionary:
	var carga: Dictionary = Cargador.new().cargar_carpeta(_CARPETA_DATOS)
	assert_array(carga["errores"]).override_failure_message(str(carga["errores"])).is_empty()
	return carga["datos"]


# T31 (A.9): d_rivales_balanza4 es la variante de D armada como en el panel.
func _contexto(datos: Dictionary, escenario_id: String) -> ContextoCombate:
	var escenario: Dictionary = VariantesEscenario.escenario(datos, escenario_id)
	assert_dict(escenario).override_failure_message(escenario_id).is_not_empty()
	var contexto: ContextoCombate = ContextoCombate.armar(escenario, datos)
	assert_bool(contexto.valido).override_failure_message(escenario_id).is_true()
	return contexto


# Juega con el jugador esperando hasta que empieza la ronda `hasta_ronda` + 1 o
# termina el combate. al_turno(combate) se llama al empezar cada turno del jugador.
func _jugar(datos: Dictionary, escenario_id: String, hasta_ronda: int, al_turno: Callable = Callable()) -> Combate:
	var combate: Combate = Combate.empezar(_contexto(datos, escenario_id))
	for _i in range(_TOPE_ACCIONES):
		assert_str(combate.error()).override_failure_message(escenario_id).is_empty()
		if combate.terminado() or (combate.instantanea()["ronda"] as int) > hasta_ronda:
			return combate
		assert_bool(combate.esperando_jugador()).override_failure_message(escenario_id).is_true()
		if al_turno.is_valid():
			al_turno.call(combate)
		_jugar_lo_obligado(combate, escenario_id)
		if combate.terminado():
			return combate
		assert_bool(combate.aplicar(Accion.terminar()).valida).override_failure_message(escenario_id).is_true()
	fail("%s: el combate no avanzo" % escenario_id)
	return combate


# CLAUDE.md, "Test de contacto" (excepcion autorizada en T19; A.11): lo minimo
# que obliga una regla, con el ayudante comun (JugadorEsperando, T20).
func _jugar_lo_obligado(combate: Combate, escenario_id: String) -> void:
	var falla: String = JugadorEsperando.lo_obligado(combate)
	assert_str(falla).override_failure_message("%s: %s" % [escenario_id, falla]).is_empty()


func _eventos(combate: Combate, tipo: String) -> Array[Dictionary]:
	var lista: Array[Dictionary] = []
	for linea in combate.registro().lineas():
		if linea["tipo"] == tipo:
			lista.append(linea)
	return lista


func _es_enemiga(combate: Combate, unidad_id: String) -> bool:
	return unidad_id != Maestro.ID and combate.contexto().plantel.criatura(unidad_id).bando != Criatura.Bando.TRIBU


# Los ataques de las enemigas, en orden.
func _ataques_enemigos(combate: Combate) -> Array[Dictionary]:
	var lista: Array[Dictionary] = []
	for ataque in _eventos(combate, "ataque"):
		if _es_enemiga(combate, ataque["atacante"]):
			lista.append(ataque)
	return lista


func _ataques_de(combate: Combate, atacante_id: String, ronda: int) -> Array[Dictionary]:
	var lista: Array[Dictionary] = []
	for ataque in _eventos(combate, "ataque"):
		if ataque["atacante"] == atacante_id and (ataque["ronda"] as int) == ronda:
			lista.append(ataque)
	return lista


func _posicion_al_cerrar(combate: Combate, unidad_id: String, ronda: int) -> Vector2i:
	var posicion: Vector2i = Criatura.SIN_POSICION
	for fin_turno in _eventos(combate, "fin_turno"):
		if fin_turno["unidad"] == unidad_id and (fin_turno["ronda"] as int) == ronda:
			posicion = Vector2i(fin_turno["posicion"][0], fin_turno["posicion"][1])
	return posicion


# id -> casilla de las unidades del tablero, por bando.
func _casillas(plantel: Plantel, bando: Criatura.Bando) -> Dictionary:
	var casillas: Dictionary = {}
	if bando == Criatura.Bando.TRIBU:
		casillas[Maestro.ID] = plantel.maestro.posicion
	for criatura in plantel.criaturas():
		if criatura.bando == bando and criatura.posicion != Criatura.SIN_POSICION:
			casillas[criatura.id] = criatura.posicion
	return casillas


# Sistema.md 11.3 v1.6 y 11.9 v1.6; D-004 (el limite de 12 x 12 lo revisa este test).
func test_tableros_y_zonas() -> void:
	var datos: Dictionary = _datos()
	var g: Dictionary = datos["escenarios/%s.json" % _G]["tablero"]
	assert_int(g["ancho"] as int).is_equal(_LADO_G)
	assert_int(g["alto"] as int).is_equal(_LADO_G)
	for escenario_id: String in _DISTANCIA.keys():
		var contexto: ContextoCombate = _contexto(datos, escenario_id)
		assert_int(contexto.tablero.ancho).override_failure_message(escenario_id).is_equal(_LADO_REFERENCIA)
		assert_int(contexto.tablero.alto).override_failure_message(escenario_id).is_equal(_LADO_REFERENCIA)
		for bando in [Criatura.Bando.TRIBU, Criatura.Bando.ENEMIGA]:
			var zona: Array[Vector2i] = contexto.tablero.despliegue(bando)
			var casillas: Dictionary = _casillas(contexto.plantel, bando)
			for unidad_id: String in casillas.keys():
				assert_bool(zona.has(casillas[unidad_id])) \
						.override_failure_message("%s %s %s" % [escenario_id, unidad_id, casillas[unidad_id]]).is_true()


# Sistema.md 11.9 v1.6: distancia minima entre la tribu (Maestro incluido) y las enemigas.
func test_distancia_minima() -> void:
	var datos: Dictionary = _datos()
	for escenario_id: String in _DISTANCIA.keys():
		var plantel: Plantel = _contexto(datos, escenario_id).plantel
		var minima: int = -1
		for tribu: Vector2i in _casillas(plantel, Criatura.Bando.TRIBU).values():
			for enemiga: Vector2i in _casillas(plantel, Criatura.Bando.ENEMIGA).values():
				var distancia: int = Tablero.distancia(tribu, enemiga)
				if minima < 0 or distancia < minima:
					minima = distancia
		assert_int(minima).override_failure_message(escenario_id).is_equal(_DISTANCIA[escenario_id] as int)


# Sistema.md 11.3 v1.6, Contacto en la ronda 2: con la tribu quieta, ninguna
# enemiga ataca en la ronda 1.
func test_ninguna_enemiga_ataca_en_la_ronda_1() -> void:
	var datos: Dictionary = _datos()
	for escenario_id: String in _DISTANCIA.keys():
		# Se corta al primer turno del jugador de la ronda 2: las enemigas que
		# actuan antes ya jugaron esa ronda, por eso se filtra por ronda.
		var combate: Combate = _jugar(datos, escenario_id, 1)
		var en_la_1: Array[Dictionary] = []
		for ataque in _ataques_enemigos(combate):
			if (ataque["ronda"] as int) == 1:
				en_la_1.append(ataque)
		assert_array(en_la_1).override_failure_message(escenario_id).is_empty()


# Sistema.md 11.9 v1.6, A: la Ocarra se acerca en la ronda 1, va por la Rodauva
# y la golpea en la ronda 2.
func test_a_ocarra_va_por_la_rodauva() -> void:
	var combate: Combate = _jugar(_datos(), "a_dia_1", 2)
	var plantel: Plantel = combate.contexto().plantel
	var rodauva: Vector2i = plantel.criatura("rodauva_1").posicion
	var movida: bool = false
	for movimiento in _eventos(combate, "movimiento"):
		if movimiento["unidad"] == "ocarra_s1" and (movimiento["ronda"] as int) == 1:
			var desde: Vector2i = Vector2i(movimiento["desde"][0], movimiento["desde"][1])
			var hasta: Vector2i = Vector2i(movimiento["hasta"][0], movimiento["hasta"][1])
			movida = Tablero.distancia(hasta, rodauva) < Tablero.distancia(desde, rodauva)
	assert_bool(movida).is_true()
	var ataques: Array[Dictionary] = _ataques_enemigos(combate)
	assert_bool(ataques.is_empty()).is_false()
	assert_int(ataques[0]["ronda"] as int).is_equal(2)
	assert_str(ataques[0]["atacante"]).is_equal("ocarra_s1")
	assert_str(ataques[0]["objetivo"]).is_equal("rodauva_1")


# Sistema.md 11.9 v1.6, B: las dos Ocarras atacan en la ronda 2 y no terminan
# vecinas (8, tambien en diagonal) al final de las rondas 1 y 2.
func test_b_ocarras_llegan_sin_juntarse() -> void:
	var combate: Combate = _jugar(_datos(), "b_muro", 2)
	for ocarra in ["ocarra_s1", "ocarra_s2"]:
		assert_array(_ataques_de(combate, ocarra, 2)).override_failure_message(ocarra).is_not_empty()
	for ronda in [1, 2]:
		var una: Vector2i = _posicion_al_cerrar(combate, "ocarra_s1", ronda)
		var otra: Vector2i = _posicion_al_cerrar(combate, "ocarra_s2", ronda)
		assert_bool(una != Criatura.SIN_POSICION and otra != Criatura.SIN_POSICION).is_true()
		assert_bool(Tablero.es_vecina_en_8(una, otra)) \
				.override_failure_message("ronda %d: %s y %s" % [ronda, una, otra]).is_false()


# Sistema.md 11.9 v1.6, C y H: el Tasajero no ataca en la ronda 1 y ataca en
# Caza en la ronda 2.
func test_c_y_h_caza_en_la_ronda_2() -> void:
	var datos: Dictionary = _datos()
	for escenario_id in ["c_tasajero", "h_soplo"]:
		var combate: Combate = _jugar(datos, escenario_id, 2)
		assert_array(_ataques_de(combate, "tasajero_s1", 1)).override_failure_message(escenario_id).is_empty()
		assert_array(_ataques_de(combate, "tasajero_s1", 2)).override_failure_message(escenario_id).is_not_empty()
		var en_caza: bool = false
		for accion in _eventos(combate, "accion"):
			if accion["unidad"] == "tasajero_s1" and (accion["ronda"] as int) == 2 \
					and accion["accion"]["tipo"] == "atacar":
				en_caza = accion["paso"] == "caza"
		assert_bool(en_caza).override_failure_message(escenario_id).is_true()
		var marca_caza: bool = false
		for turno in _eventos(combate, "turno"):
			if turno["unidad"] == "tasajero_s1" and (turno["ronda"] as int) == 2:
				marca_caza = turno["marca"] == "caza"
		assert_bool(marca_caza).override_failure_message(escenario_id).is_true()


# Sistema.md 11.9 v1.6, D: las rivales aliadas empiezan vecinas (la diagonal ya
# cuenta) y la primera enemiga ataca en la ronda 2.
func test_d_rivales_vecinas_y_ataque_en_la_ronda_2() -> void:
	var datos: Dictionary = _datos()
	for escenario_id in _D:
		var combate: Combate = _jugar(datos, escenario_id, 2)
		var inicio: Dictionary = VariantesEscenario.escenario(datos, escenario_id)
		var casillas: Dictionary = {}
		for criatura in inicio["tribu"]:
			casillas[criatura["id"]] = Vector2i(criatura["posicion"][0], criatura["posicion"][1])
		assert_bool(Tablero.es_vecina_en_8(casillas["ocarra_1"], casillas["zancajunco_1"])) \
				.override_failure_message(escenario_id).is_true()
		var ataques: Array[Dictionary] = _ataques_enemigos(combate)
		assert_bool(ataques.is_empty()).override_failure_message(escenario_id).is_false()
		assert_int(ataques[0]["ronda"] as int).override_failure_message(escenario_id).is_equal(2)


# Sistema.md 11.9 v1.6, E: al empezar su turno de la ronda 1, ninguna Rodauva
# tiene una rival a su alcance; en la ronda 2, alguna si. Que sean rivales sale
# de relaciones.json (Objetivos lo deja a quien llama).
func test_e_rival_a_su_alcance_en_la_ronda_2() -> void:
	var datos: Dictionary = _datos()
	for escenario_id in _E:
		# ronda -> cuantas veces una Rodauva empezo su turno con una rival a su alcance.
		var con_rival: Dictionary = {1: 0, 2: 0}
		var turnos: Dictionary = {1: 0, 2: 0}
		var al_turno: Callable = func(combate: Combate) -> void:
			var plantel: Plantel = combate.contexto().plantel
			var unidad_id: String = combate.turno_actual().unidad_id
			if unidad_id == Maestro.ID or plantel.criatura(unidad_id).especie.id() != "rodauva":
				return
			var ronda: int = combate.instantanea()["ronda"]
			turnos[ronda] += 1
			for criatura in plantel.criaturas():
				if criatura.bando == Criatura.Bando.TRIBU:
					continue
				var rival: bool = combate.contexto().relaciones.relacion("rodauva", criatura.especie.id()) \
						== Relaciones.Relacion.MAL
				if rival and Objetivos.cuenta_como_rival_a_su_alcance(unidad_id, criatura.id, plantel):
					con_rival[ronda] += 1
		_jugar(datos, escenario_id, 2, al_turno)
		assert_int(turnos[1] as int).override_failure_message(escenario_id).is_equal(2)
		assert_int(turnos[2] as int).override_failure_message(escenario_id).is_equal(2)
		assert_int(con_rival[1] as int).override_failure_message(escenario_id).is_equal(0)
		assert_int(con_rival[2] as int).override_failure_message(escenario_id).is_greater(0)


# Sistema.md 11.9 v1.6, F: el Zancajunco salvaje se oculta en la ronda 1, avanza
# destapado y con el bono en la 2, y en la 3 le pega 70 al Maestro (que tiene 60).
# T44: reescrito con la escala x10 de Sistema.md 11.1 y 11.9 v1.7 (antes, 7 y 6).
func test_f_zancajunco_oculto_avanza_y_pega_70() -> void:
	# Primer turno del jugador de la ronda 2: el Zancajunco (Vel 8) ya avanzo.
	var foto_ronda_2: Dictionary = {}
	var al_turno: Callable = func(combate: Combate) -> void:
		if foto_ronda_2.is_empty() and (combate.instantanea()["ronda"] as int) == 2:
			foto_ronda_2.merge(combate.instantanea())
	var combate: Combate = _jugar(_datos(), "f_rescate", 3, al_turno)
	var ocultos: Array[Dictionary] = _eventos(combate, "oculto")
	assert_int(ocultos.size()).is_equal(1)
	assert_str(ocultos[0]["unidad"]).is_equal("zancajunco_s1")
	assert_int(ocultos[0]["ronda"] as int).is_equal(1)

	var movido: bool = false
	for movimiento in _eventos(combate, "movimiento"):
		if movimiento["unidad"] == "zancajunco_s1" and (movimiento["ronda"] as int) == 2:
			movido = true
	assert_bool(movido).is_true()
	var destapes: Array[Dictionary] = _eventos(combate, "destape")
	assert_int(destapes.size()).is_equal(1)
	assert_str(destapes[0]["unidad"]).is_equal("zancajunco_s1")
	assert_str(destapes[0]["motivo"]).is_equal(Junco.MOTIVO_MOVER)
	assert_int(destapes[0]["ronda"] as int).is_equal(2)
	var junco: Dictionary = {}
	for criatura in foto_ronda_2["criaturas"]:
		if criatura["id"] == "zancajunco_s1":
			junco = criatura
	assert_bool(junco["oculta"]).is_false()
	assert_bool(junco["bono_junco"]).is_true()

	var ataques: Array[Dictionary] = _ataques_enemigos(combate)
	assert_bool(ataques.is_empty()).is_false()
	assert_int(ataques[0]["ronda"] as int).is_equal(3)
	assert_str(ataques[0]["atacante"]).is_equal("zancajunco_s1")
	assert_str(ataques[0]["objetivo"]).is_equal(Maestro.ID)
	assert_int(ataques[0]["vida_antes"] as int).is_equal(60)
	assert_int(ataques[0]["desglose"]["total"] as int).is_equal(70)


# Sistema.md 11.9 v1.6, G: sin cambios; carga y llega al primer turno del jugador.
func test_g_llega_al_jugador() -> void:
	var combate: Combate = Combate.empezar(_contexto(_datos(), _G))
	assert_str(combate.error()).is_empty()
	assert_bool(combate.esperando_jugador()).is_true()
