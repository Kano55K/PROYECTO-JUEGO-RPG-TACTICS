extends GdUnitTestSuite

# Arquitectura.md B.3 (T23) y D-011, con datos/ real (A.6): los 11 escenarios
# jugados con el jugador esperando (JugadorEsperando, como test_contacto y
# test_robustez_ia) hasta el fin o la ronda 12 dan metricas validas contra el
# esquema `resultado`, sin ningun float. En A, B, C, D y H la ronda del primer
# ataque es la 2 (Sistema.md 11.9 v1.6, criterios de despliegue; lo mismo que
# comprueba test_contacto.gd). Test (11) del criterio de terminado.
const _CARPETA_DATOS: String = "res://datos"
const _HASTA_RONDA: int = 12
const _TOPE_ACCIONES: int = 200
const _PRIMER_ATAQUE_EN_2: Array[String] = ["a_dia_1", "b_muro", "c_tasajero", "d_rivales_normal",
		"d_rivales_hambriento", "d_rivales_balanza4", "h_soplo"]
const _RONDA_PRIMER_ATAQUE: int = 2

var _datos: Dictionary = {}
var _esquema_metricas: Dictionary = {}


func before() -> void:
	var carga: Dictionary = Cargador.new().cargar_carpeta(_CARPETA_DATOS)
	assert_array(carga["errores"]).override_failure_message(str(carga["errores"])).is_empty()
	_datos = carga["datos"]
	# El sub-esquema de `metricas`, con los $defs de la raiz: sirve tambien para
	# un combate que no termino (sin resultado).
	var resultado: Dictionary = Cargador.new().esquema_resuelto(_CARPETA_DATOS, "resultado")["esquema"]
	_esquema_metricas = (resultado["properties"]["metricas"] as Dictionary).duplicate(true)
	_esquema_metricas["$defs"] = resultado["$defs"]


# Juega el escenario y devuelve sus metricas (las del resultado si termino).
func _metricas(escenario_id: String) -> Dictionary:
	var escenario: Dictionary = _datos["escenarios/%s.json" % escenario_id]
	var contexto: ContextoCombate = ContextoCombate.armar(escenario, _datos)
	assert_bool(contexto.valido).override_failure_message(escenario_id).is_true()
	var combate: Combate = Combate.empezar(contexto)
	for _i in range(_TOPE_ACCIONES):
		assert_str(combate.error()).override_failure_message(escenario_id).is_empty()
		if combate.terminado() or (combate.instantanea()["ronda"] as int) > _HASTA_RONDA:
			break
		assert_str(JugadorEsperando.lo_obligado(combate)).override_failure_message(escenario_id).is_empty()
		if combate.terminado():
			break
		assert_bool(combate.aplicar(Accion.terminar()).valida).override_failure_message(escenario_id).is_true()
	var metricas: Dictionary = MetricasCombate.calcular(escenario, combate.registro().lineas())
	if combate.terminado():
		assert_dict(combate.resultado().a_diccionario()["metricas"]).is_equal(metricas)
	var validacion: Dictionary = Validador.new().validar(metricas, _esquema_metricas, escenario_id)
	assert_array(validacion["errores"] as Array).override_failure_message(str(validacion["errores"])).is_empty()
	assert_bool(_tiene_float(metricas)).override_failure_message(escenario_id).is_false()
	return metricas


func _tiene_float(valor: Variant) -> bool:
	if valor is float:
		return true
	if valor is Dictionary:
		for clave in (valor as Dictionary).keys():
			if _tiene_float(valor[clave]):
				return true
	if valor is Array:
		for elemento in (valor as Array):
			if _tiene_float(elemento):
				return true
	return false


func test_los_11_escenarios_dan_metricas_validas() -> void:
	var escenarios: Array[String] = []
	for clave: String in _datos.keys():
		if clave.begins_with("escenarios/"):
			escenarios.append(clave.trim_prefix("escenarios/").trim_suffix(".json"))
	escenarios.sort()
	assert_int(escenarios.size()).is_equal(11)
	for escenario_id in escenarios:
		var metricas: Dictionary = _metricas(escenario_id)
		if _PRIMER_ATAQUE_EN_2.has(escenario_id):
			assert_int(metricas["rondas"]["primer_ataque"]).override_failure_message(escenario_id) \
					.is_equal(_RONDA_PRIMER_ATAQUE)
