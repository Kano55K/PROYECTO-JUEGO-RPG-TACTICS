# Arquitectura.md A.6 (T30, T30-fix): el jugador que tumba a la atacante de G,
# para los tests con datos/ real (test_ataque_nocturno_g.gd, test_resellar_g.gd y
# test_vista_resellar_g.gd). Todo sale de las consultas del Turno, sin
# coordenadas escritas.
class_name JugadorG
extends RefCounted

const ESCENARIO: String = "escenarios/g_ataque_nocturno.json"
const OCARRA: String = "ocarra_1"
const TOPE_ACCIONES: int = 300


# Juega hasta que termina el combate. Devuelve "" si termino en victoria con el
# destino de la Ocarra pendiente, o que fallo.
static func hasta_el_destino(combate: Combate) -> String:
	for _i in range(TOPE_ACCIONES):
		if not combate.error().is_empty():
			return combate.error()
		if combate.terminado():
			break
		if not combate.esperando_jugador():
			return "el combate no espera al jugador"
		var fallo: String = turno(combate)
		if not fallo.is_empty():
			return fallo
	if combate.fin() != FinCombate.Fin.VICTORIA:
		return "no termino en victoria"
	if not combate.esperando_destino():
		return "el destino no quedo pendiente"
	return ""


# Un turno del jugador: si la Ocarra es objetivo, la ataca; si no, se acerca a
# ella por la casilla de casillas_para_mover que mas acorta la distancia
# (Tablero.distancia) y la ataca si puede. Despues, lo que obligue una regla, y
# termina. Devuelve "" o que fallo.
static func turno(combate: Combate) -> String:
	var plantel: Plantel = combate.contexto().plantel
	var turno_actual: Turno = combate.turno_actual()
	var ocarra: Vector2i = plantel.criatura(OCARRA).posicion
	if not turno_actual.objetivos_para_atacar().has(OCARRA):
		var unidad: Vector2i = plantel.maestro.posicion if turno_actual.unidad_id == Maestro.ID \
				else plantel.criatura(turno_actual.unidad_id).posicion
		var mejor: Vector2i = Criatura.SIN_POSICION
		var distancia: int = Tablero.distancia(unidad, ocarra)
		for casilla in turno_actual.casillas_para_mover():
			if Tablero.distancia(casilla, ocarra) < distancia:
				distancia = Tablero.distancia(casilla, ocarra)
				mejor = casilla
		if mejor != Criatura.SIN_POSICION and not combate.aplicar(Accion.mover(mejor)).valida:
			return "mover rechazado"
	if not combate.terminado() and combate.turno_actual().objetivos_para_atacar().has(OCARRA) \
			and not combate.aplicar(Accion.atacar(OCARRA)).valida:
		return "atacar rechazado"
	if combate.terminado():
		return ""
	var obligado: String = JugadorEsperando.lo_obligado(combate)
	if not obligado.is_empty():
		return obligado
	if not combate.terminado() and not combate.aplicar(Accion.terminar()).valida:
		return "terminar rechazado"
	return ""
