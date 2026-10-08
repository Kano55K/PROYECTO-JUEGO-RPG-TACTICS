extends GdUnitTestSuite

# Arquitectura.md A.6 ("Robustez de la IA", desde T20) y D-005: test permanente
# con datos/ real. Juega los 11 escenarios con 10 semillas cada uno (la del
# escenario y las 9 de _SEMILLAS_EXTRA, puestas en una copia del escenario), con
# el jugador esperando (JugadorEsperando, el mismo ayudante del test de
# contacto), hasta el fin del combate o la ronda 12. Exige que ningun combate
# termine con error(): la IA nunca devuelve una accion que el Turno rechace.
# Desde T20 las salvajes tiran Encono, cobardia e incidentes y el camino de la IA
# depende de las tiradas: una sola semilla no recorre los casos.
const _CARPETA_DATOS: String = "res://datos"
const _HASTA_RONDA: int = 12
# Fijas: cambiarlas cambia los combates que se recorren.
const _SEMILLAS_EXTRA: Array[int] = [1, 2, 3, 7, 42, 99, 1000, 31337, 2026]
# Corta un combate que no avanza (nunca deberia pasar).
const _TOPE_ACCIONES: int = 200

var _datos: Dictionary = {}


func before() -> void:
	var carga: Dictionary = Cargador.new().cargar_carpeta(_CARPETA_DATOS)
	assert_array(carga["errores"]).override_failure_message(str(carga["errores"])).is_empty()
	_datos = carga["datos"]


# Las 10 semillas del escenario y, por cada una que falla, una linea con el
# escenario, la semilla, la ronda, la unidad y el error (la decision de la IA y
# el motivo con que el Turno la rechazo).
func _robustez(escenario_id: String) -> void:
	var escenario: Dictionary = _datos["escenarios/%s.json" % escenario_id]
	var semillas: Array[int] = [escenario["semilla"] as int]
	semillas.append_array(_SEMILLAS_EXTRA)
	var fallas: Array[String] = []
	for semilla in semillas:
		var copia: Dictionary = escenario.duplicate(true)
		copia["semilla"] = semilla
		var falla: String = _jugar(copia)
		if not falla.is_empty():
			fallas.append("%s, semilla %d: %s" % [escenario_id, semilla, falla])
	assert_array(fallas).override_failure_message("\n".join(fallas)).is_empty()


# "" si el combate llego al fin o pasada la ronda 12 sin error; si no, que paso.
func _jugar(escenario: Dictionary) -> String:
	var contexto: ContextoCombate = ContextoCombate.armar(escenario, _datos)
	if not contexto.valido:
		return "contexto invalido: %s" % contexto.motivo
	var combate: Combate = Combate.empezar(contexto)
	for _i in range(_TOPE_ACCIONES):
		if not combate.error().is_empty():
			return _donde(combate) + combate.error()
		if combate.terminado() or (combate.instantanea()["ronda"] as int) > _HASTA_RONDA:
			return ""
		if not combate.esperando_jugador():
			return _donde(combate) + "no espera al jugador"
		var falla: String = JugadorEsperando.lo_obligado(combate)
		if not falla.is_empty():
			return _donde(combate) + "jugador: " + falla
		if not combate.error().is_empty():
			return _donde(combate) + combate.error()
		if combate.terminado():
			return ""
		var terminar: ResultadoAccion = combate.aplicar(Accion.terminar())
		if not terminar.valida:
			return _donde(combate) + "terminar rechazada: " + ResultadoAccion.Motivo.keys()[terminar.motivo]
	return _donde(combate) + "el combate no avanzo"


func _donde(combate: Combate) -> String:
	var turno: Turno = combate.turno_actual()
	return "ronda %d, unidad %s: " % [combate.instantanea()["ronda"], turno.unidad_id if turno != null else "-"]


func test_a_dia_1() -> void:
	_robustez("a_dia_1")


func test_b_muro() -> void:
	_robustez("b_muro")


func test_c_tasajero() -> void:
	_robustez("c_tasajero")


func test_d_rivales_normal() -> void:
	_robustez("d_rivales_normal")


func test_d_rivales_hambriento() -> void:
	_robustez("d_rivales_hambriento")


func test_d_rivales_balanza4() -> void:
	_robustez("d_rivales_balanza4")


func test_e_cobardia() -> void:
	_robustez("e_cobardia")


func test_e_cobardia_afines() -> void:
	_robustez("e_cobardia_afines")


func test_f_rescate() -> void:
	_robustez("f_rescate")


func test_g_ataque_nocturno() -> void:
	_robustez("g_ataque_nocturno")


func test_h_soplo() -> void:
	_robustez("h_soplo")


# Los 11 escenarios de datos/ son los que juega este test.
func test_estan_los_11_escenarios() -> void:
	var escenarios: Array[String] = []
	for clave: String in _datos.keys():
		if clave.begins_with("escenarios/"):
			escenarios.append(clave.trim_prefix("escenarios/").trim_suffix(".json"))
	escenarios.sort()
	assert_array(escenarios).is_equal(["a_dia_1", "b_muro", "c_tasajero", "d_rivales_balanza4",
			"d_rivales_hambriento", "d_rivales_normal", "e_cobardia", "e_cobardia_afines", "f_rescate",
			"g_ataque_nocturno", "h_soplo"])
