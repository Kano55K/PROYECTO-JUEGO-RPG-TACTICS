extends GdUnitTestSuite

# Arquitectura.md B.3 (T21), tests 2 a 9: Sistema.md 2.1 (regeneracion al inicio
# de cada turno del Maestro, tope = el mana con el que entro), 2.2 (efecto del
# hambre: completo, solo en rondas pares o nada), 7.2 (el estado de hambre se
# recalcula en el acto), 11.3 paso 1 y S-31 (una vez por ronda); D-007 (evento
# `mana` solo si cambia). Fixtures (A.6): escenario_mana_combate.json, con la
# balanza 2 del fixture (reserva 8) y el hambre de combate cada 5 rondas.
const _ESCENARIO: String = "res://pruebas/fixtures/combate/escenario_mana_combate.json"
# Sistema.md 7.1: un valor de cada estado de hambre.
const _SACIADO: int = 1
const _NORMAL: int = 3
const _HAMBRIENTO: int = 6
const _FAMELICO: int = 9


func _datos() -> Dictionary:
	var lectura: Dictionary = DatosFixture.cargar()
	var errores: Array[Dictionary] = lectura["errores"]
	assert_array(errores).override_failure_message(str(errores)).is_empty()
	return lectura["datos"]


func _escenario() -> Dictionary:
	var lectura: Dictionary = LectorFixture.leer(_ESCENARIO, "escenario")
	var errores: Array[Dictionary] = lectura["errores"]
	assert_array(errores).override_failure_message(str(errores)).is_empty()
	return lectura["datos"]


func _regla() -> RegeneracionMana:
	return RegeneracionMana.desde_datos(_datos()["tablas/hambre.json"])


# El Maestro del fixture con el mana, el tope, la Regeneracion y el hambre pedidos.
func _maestro(mana: int, tope: int, regeneracion: int, hambre: int) -> Maestro:
	var maestro: Maestro = Plantel.desde_datos(_datos(), _escenario()).maestro
	maestro.mana_entrada = tope
	maestro.mana = mana
	maestro.regeneracion = regeneracion
	maestro.hambre = hambre
	return maestro


# Combate del fixture con el mana del Maestro bajado a mano antes de empezar
# (en T21 nada lo gasta). mana_entrada: null = la reserva de la balanza.
func _combate(mana: int, mana_entrada: Variant = null, regeneracion: int = 1) -> Combate:
	var escenario: Dictionary = _escenario()
	(escenario["maestro"] as Dictionary)["mana_entrada"] = mana_entrada
	(escenario["maestro"] as Dictionary)["regeneracion"] = regeneracion
	var contexto: ContextoCombate = ContextoCombate.armar(escenario, _datos())
	assert_bool(contexto.valido).is_true()
	contexto.plantel.maestro.mana = mana
	var combate: Combate = Combate.empezar(contexto)
	assert_str(combate.error()).is_empty()
	return combate


func _aplicar_valida(combate: Combate, accion: Accion) -> void:
	var resultado: ResultadoAccion = combate.aplicar(accion)
	assert_bool(resultado.valida).override_failure_message(
			ResultadoAccion.Motivo.keys()[resultado.motivo] + " " + str(accion.a_diccionario())).is_true()
	assert_str(combate.error()).is_empty()


# Solo `terminar` hasta que empiece la ronda pedida.
func _terminar_hasta_ronda(combate: Combate, ronda: int) -> void:
	while combate.instantanea()["ronda"] < ronda:
		_aplicar_valida(combate, Accion.terminar())


func _eventos(combate: Combate, tipo: String) -> Array[Dictionary]:
	var resultado: Array[Dictionary] = []
	for linea in combate.registro().lineas():
		if linea["tipo"] == tipo:
			resultado.append(linea)
	return resultado


# ronda -> {de, a} de los eventos `mana`.
func _mana_por_ronda(combate: Combate) -> Dictionary:
	var resultado: Dictionary = {}
	for evento in _eventos(combate, "mana"):
		assert_bool(resultado.has(evento["ronda"])).override_failure_message(
				"dos eventos mana en la ronda %d" % evento["ronda"]).is_false()
		resultado[evento["ronda"]] = {"de": evento["de"], "a": evento["a"]}
	return resultado


# (2) Sistema.md 2.1: Normal por debajo del tope suma su Regeneracion; con 3 y a
# 1 del tope queda en el tope; en el tope no cambia y no hay cambio que registrar.
func test_normal_suma_su_regeneracion_hasta_el_tope() -> void:
	var regla: RegeneracionMana = _regla()
	var maestro: Maestro = _maestro(2, 8, 1, _NORMAL)
	assert_dict(regla.aplicar(maestro, 1)).is_equal({"de": 2, "a": 3})
	assert_int(maestro.mana).is_equal(3)

	maestro = _maestro(7, 8, 3, _NORMAL)
	assert_dict(regla.aplicar(maestro, 1)).is_equal({"de": 7, "a": 8})
	assert_int(maestro.mana).is_equal(8)

	assert_dict(regla.aplicar(maestro, 2)).is_empty()
	assert_int(maestro.mana).is_equal(8)


# (2) En el combate: en el tope, ningun evento `mana`; por debajo, uno en cada
# turno del Maestro hasta llegar.
func test_en_el_tope_no_hay_evento() -> void:
	var en_el_tope: Combate = _combate(8)
	_terminar_hasta_ronda(en_el_tope, 4)
	assert_array(_eventos(en_el_tope, "mana")).is_empty()
	assert_int(en_el_tope.contexto().plantel.maestro.mana).is_equal(8)

	var abajo: Combate = _combate(6)
	_terminar_hasta_ronda(abajo, 4)
	assert_dict(_mana_por_ronda(abajo)).is_equal({1: {"de": 6, "a": 7}, 2: {"de": 7, "a": 8}})
	assert_int(abajo.contexto().plantel.maestro.mana).is_equal(8)


# (3) M-04: el tope es mana_entrada, no la reserva de la balanza (8 en el
# fixture): con entrada 4 nunca pasa de 4.
func test_el_tope_es_el_mana_de_entrada() -> void:
	var combate: Combate = _combate(1, 4, 3)
	var maestro: Maestro = combate.contexto().plantel.maestro
	assert_int(maestro.mana_entrada).is_equal(4)
	_terminar_hasta_ronda(combate, 4)
	assert_int(maestro.mana).is_equal(4)
	assert_int(maestro.mana_entrada).is_equal(4)
	assert_dict(_mana_por_ronda(combate)).is_equal({1: {"de": 1, "a": 4}})


# (4) Sistema.md 2.2: Hambriento solo en rondas pares; Famelico nunca; Saciado
# todas. El estado se lee de tablas/hambre.json del fixture.
func test_regeneracion_segun_el_hambre() -> void:
	var regla: RegeneracionMana = _regla()
	var esperado: Dictionary = {
		_HAMBRIENTO: [false, true, false, true],
		_FAMELICO: [false, false, false, false],
		_SACIADO: [true, true, true, true],
		_NORMAL: [true, true, true, true],
	}
	for hambre: int in esperado.keys():
		for ronda in range(1, 5):
			var maestro: Maestro = _maestro(0, 8, 1, hambre)
			var cambio: Dictionary = regla.aplicar(maestro, ronda)
			var regenera: bool = (esperado[hambre] as Array)[ronda - 1]
			assert_bool(not cambio.is_empty()).override_failure_message(
					"hambre %d, ronda %d" % [hambre, ronda]).is_equal(regenera)
			assert_int(maestro.mana).is_equal(1 if regenera else 0)


# (4) S-44: Famelico no regenera, pero no pierde el mana que ya tiene.
func test_famelico_conserva_su_mana() -> void:
	var maestro: Maestro = _maestro(5, 8, 1, _FAMELICO)
	assert_dict(_regla().aplicar(maestro, 2)).is_empty()
	assert_int(maestro.mana).is_equal(5)


# (5) Sistema.md 7.2: el hambre de combate lo pasa de 5 (Normal) a 6
# (Hambriento) al cerrar la ronda 5; desde su turno siguiente rige "solo en
# rondas pares": regenera en la 6 y la 8, no en la 7.
func test_hambre_de_combate_cambia_la_regla_en_el_acto() -> void:
	var combate: Combate = _combate(0)
	_terminar_hasta_ronda(combate, 9)
	var cambio_hambre: Array[Dictionary] = _eventos(combate, "hambre_combate")
	assert_int(cambio_hambre.size()).is_equal(1)
	assert_int(cambio_hambre[0]["ronda"]).is_equal(5)
	assert_array(cambio_hambre[0]["cambios"]).contains([{"unidad": Maestro.ID, "de": 5, "a": 6}])
	assert_dict(_mana_por_ronda(combate)).is_equal({
		1: {"de": 0, "a": 1}, 2: {"de": 1, "a": 2}, 3: {"de": 2, "a": 3}, 4: {"de": 3, "a": 4},
		5: {"de": 4, "a": 5}, 6: {"de": 5, "a": 6}, 8: {"de": 6, "a": 7},
	})


# (6) S-31: el Maestro Secunda al Surcon y vuelve; regenera una sola vez en la ronda.
func test_secundar_y_volver_regenera_una_vez() -> void:
	var combate: Combate = _combate(2)
	_terminar_hasta_ronda(combate, 1)
	while combate.turno_actual().unidad_id != Maestro.ID:
		_aplicar_valida(combate, Accion.terminar())
	assert_int(combate.contexto().plantel.maestro.mana).is_equal(3)
	_aplicar_valida(combate, Accion.secundar("surcon_1"))
	assert_str(combate.turno_actual().unidad_id).is_equal("surcon_1")
	_aplicar_valida(combate, Accion.terminar())
	assert_str(combate.turno_actual().unidad_id).is_equal(Maestro.ID)
	assert_int(_eventos(combate, "turno_vuelve").size()).is_equal(1)
	assert_int(combate.contexto().plantel.maestro.mana).is_equal(3)
	assert_dict(_mana_por_ronda(combate)).is_equal({1: {"de": 2, "a": 3}})


# (7) El turno de una criatura de la tribu y el de una enemiga no tocan el mana.
func test_otros_turnos_no_tocan_el_mana() -> void:
	var datos: Dictionary = _datos()
	var plantel: Plantel = Plantel.desde_datos(datos, _escenario())
	var tablero: Tablero = Tablero.desde_datos(_escenario()["tablero"], datos["tablas/combate.json"])
	plantel.maestro.mana = 2
	for unidad_id in ["rodauva_1", "ocarra_s1"]:
		var cola: ColaIniciativa = ColaIniciativa.new()
		cola.empezar_ronda(plantel)
		var turno: Turno = Turno.empezar(EntradaCola.new(unidad_id, "", 0), plantel, tablero, Surcos.new(),
				DatosFixture.cadena(), cola, DatosFixture.reglas(), GeneradorAzar.new(1))
		assert_dict(turno.mana).is_empty()
		assert_int(plantel.maestro.mana).is_equal(2)

	var combate: Combate = _combate(0)
	_terminar_hasta_ronda(combate, 3)
	for evento in _eventos(combate, "mana"):
		assert_str(evento["unidad"]).is_equal(Maestro.ID)


# (8) D-007 y 11.3 paso 1: el evento `mana` va justo despues del `turno` del
# Maestro, antes de cualquier otro evento de su turno.
func test_el_evento_va_justo_despues_del_turno() -> void:
	var combate: Combate = _combate(0)
	_terminar_hasta_ronda(combate, 4)
	var lineas: Array[Dictionary] = combate.registro().lineas()
	var vistos: int = 0
	for indice in range(lineas.size()):
		if lineas[indice]["tipo"] != "mana":
			continue
		vistos += 1
		var anterior: Dictionary = lineas[indice - 1]
		assert_str(anterior["tipo"]).is_equal("turno")
		assert_str(anterior["unidad"]).is_equal(Maestro.ID)
		assert_int(anterior["ronda"]).is_equal(lineas[indice]["ronda"])
	assert_int(vistos).is_equal(3)


# (9) Registro (A.7, D-007), instantanea y resultado.
func test_registro_instantanea_y_resultado() -> void:
	var combate: Combate = _combate(5)
	# La Rodauva juega antes: todavia no regenero.
	assert_array(_eventos(combate, "mana")).is_empty()
	assert_int((combate.instantanea()["maestro"] as Dictionary)["mana"]).is_equal(5)
	_aplicar_valida(combate, Accion.terminar())
	assert_str(combate.turno_actual().unidad_id).is_equal(Maestro.ID)
	var evento: Dictionary = _eventos(combate, "mana")[0]
	evento.erase("n")
	assert_dict(evento).is_equal({"tipo": "mana", "unidad": Maestro.ID, "de": 5, "a": 6,
			"motivo": "regeneracion", "ronda": 1})
	assert_int((combate.instantanea()["maestro"] as Dictionary)["mana"]).is_equal(6)
	_terminar_hasta_ronda(combate, 2)
	_aplicar_valida(combate, Accion.terminar())
	assert_str(combate.turno_actual().unidad_id).is_equal(Maestro.ID)
	assert_int((combate.instantanea()["maestro"] as Dictionary)["mana"]).is_equal(7)


# (9) La grabacion no cambia (no hay accion nueva) y se reproduce con el mismo
# registro. Armado desde el escenario, el Maestro entra en el tope: sin eventos
# `mana` en vivo ni al reproducir.
func test_grabacion_se_reproduce_igual() -> void:
	var en_vivo: Combate = _combate(8)
	_terminar_hasta_ronda(en_vivo, 3)
	var reproduccion: Reproductor = Reproductor.reproducir(Grabacion.desde_combate(en_vivo), _datos())
	assert_str(reproduccion.error).is_empty()
	assert_array(reproduccion.combate.registro().lineas_json()).is_equal(en_vivo.registro().lineas_json())
	assert_array(_eventos(reproduccion.combate, "mana")).is_empty()
