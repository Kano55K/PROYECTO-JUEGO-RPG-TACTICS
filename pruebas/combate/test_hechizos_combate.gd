extends GdUnitTestSuite

# Arquitectura.md B.3 (T22), criterios 8, 10 y 11: los hechizos dentro del
# Combate, con fixtures (A.6): el mana con motivo hechizo justo detras de la
# accion (D-007), los eventos de A.7 en su orden, y la grabacion que se reproduce
# igual. Sistema.md 1.6, 2.1 y 2.3. escenario_hechizos_combate.json: Maestro con
# 8 de mana; Martillazo y Lanzadera cuestan 2, Remiendo 4; regenera 1 por turno.
const _CARPETA: String = "res://pruebas/fixtures/combate/"
const _CARPETA_DATOS: String = "res://datos"


func _datos() -> Dictionary:
	var lectura: Dictionary = DatosFixture.cargar()
	var errores: Array[Dictionary] = lectura["errores"]
	assert_array(errores).override_failure_message(str(errores)).is_empty()
	return lectura["datos"]


func _combate() -> Combate:
	var escenario: Dictionary = LectorFixture.leer(_CARPETA + "escenario_hechizos_combate.json", "escenario")["datos"]
	var contexto: ContextoCombate = ContextoCombate.armar(escenario, _datos())
	assert_bool(contexto.valido).is_true()
	var combate: Combate = Combate.empezar(contexto)
	assert_str(combate.error()).is_empty()
	return combate


func _aplicar_valida(combate: Combate, accion: Accion) -> void:
	var resultado: ResultadoAccion = combate.aplicar(accion)
	assert_bool(resultado.valida).override_failure_message("%s: %s" % [str(accion.a_diccionario()),
			ResultadoAccion.Motivo.keys()[resultado.motivo]]).is_true()
	assert_str(combate.error()).is_empty()


# Hace terminar a las unidades del jugador hasta el turno del Maestro.
func _hasta_el_maestro(combate: Combate) -> void:
	while combate.turno_actual().unidad_id != Maestro.ID:
		_aplicar_valida(combate, Accion.terminar())


# Las lineas del registro desde el indice `desde`, sin las tiradas, sin n ni ronda.
func _eventos_desde(combate: Combate, desde: int) -> Array[Dictionary]:
	var resultado: Array[Dictionary] = []
	var lineas: Array[Dictionary] = combate.registro().lineas()
	for indice in range(desde, lineas.size()):
		var evento: Dictionary = lineas[indice].duplicate(true)
		if evento["tipo"] == "tirada":
			continue
		evento.erase("n")
		evento.erase("ronda")
		resultado.append(evento)
	return resultado


func _tipos(eventos: Array[Dictionary]) -> Array:
	return eventos.map(func(evento: Dictionary) -> String: return evento["tipo"])


# Lanza el hechizo comprobando que previsualizar no cambia nada (ni el generador)
# y devuelve {previsto, eventos} con los eventos de la accion.
func _lanzar(combate: Combate, accion: Accion) -> Dictionary:
	var turno: Turno = combate.turno_actual()
	var foto: String = JSON.stringify(combate.instantanea())
	var tiradas: int = combate.contexto().azar_combate.historial().size()
	var previsto: ResultadoAccion = turno.previsualizar_hechizo(accion.hechizo_id, accion.objetivo_id, accion.sentido)
	assert_bool(previsto.valida).is_true()
	assert_str(JSON.stringify(combate.instantanea())).is_equal(foto)
	assert_int(combate.contexto().azar_combate.historial().size()).is_equal(tiradas)
	var desde: int = combate.registro().lineas().size()
	_aplicar_valida(combate, accion)
	return {"previsto": previsto, "eventos": _eventos_desde(combate, desde)}


# Los tres hechizos, uno por ronda: Martillazo al Surcon, Remiendo sobre si
# mismo y Lanzadera a la Rodauva. Devuelve los resultados de _lanzar.
func _jugar_los_tres(combate: Combate) -> Array[Dictionary]:
	var jugadas: Array[Dictionary] = []
	var acciones: Array[Accion] = [Accion.hechizo("martillazo", "surcon_s1"), Accion.hechizo("remiendo", Maestro.ID),
			Accion.hechizo("lanzadera", "rodauva_1", "empujar")]
	for accion in acciones:
		_hasta_el_maestro(combate)
		jugadas.append(_lanzar(combate, accion))
		_aplicar_valida(combate, Accion.terminar())
	return jugadas


# Criterios 8, 10 y 11: cada hechizo paga su costo con un `mana` de motivo hechizo
# justo detras de la `accion`; despues, el `ataque` del Martillazo (con eslabon),
# el `remiendo` y la `lanzadera` iguales a lo previsto.
func test_mana_y_eventos_en_orden() -> void:
	var combate: Combate = _combate()
	var jugadas: Array[Dictionary] = _jugar_los_tres(combate)

	var martillazo: Array[Dictionary] = jugadas[0]["eventos"]
	assert_array(_tipos(martillazo).slice(0, 3)).is_equal(["accion", "mana", "ataque"])
	assert_dict(martillazo[0]["accion"]).is_equal({"tipo": "hechizo", "hechizo": "martillazo", "objetivo": "surcon_s1"})
	assert_dict(martillazo[1]).is_equal({"tipo": "mana", "unidad": Maestro.ID, "de": 8, "a": 6, "motivo": "hechizo"})
	assert_int(martillazo[2]["eslabon"]).is_equal(1)
	assert_dict(martillazo[2]["desglose"]).is_equal((jugadas[0]["previsto"] as ResultadoAccion).desglose.a_diccionario())
	assert_int(martillazo[2]["vida_antes"]).is_equal(24)
	assert_int(martillazo[2]["vida_despues"]).is_equal(21)

	var remiendo: Array[Dictionary] = jugadas[1]["eventos"]
	assert_array(_tipos(remiendo).slice(0, 3)).is_equal(["accion", "mana", "remiendo"])
	assert_dict(remiendo[1]).is_equal({"tipo": "mana", "unidad": Maestro.ID, "de": 7, "a": 3, "motivo": "hechizo"})
	assert_dict(remiendo[2]).is_equal((jugadas[1]["previsto"] as ResultadoAccion).evento)

	var lanzadera: Array[Dictionary] = jugadas[2]["eventos"]
	assert_array(_tipos(lanzadera).slice(0, 3)).is_equal(["accion", "mana", "lanzadera"])
	assert_dict(lanzadera[0]["accion"]).is_equal({"tipo": "hechizo", "hechizo": "lanzadera", "objetivo": "rodauva_1",
			"sentido": "empujar"})
	assert_dict(lanzadera[1]).is_equal({"tipo": "mana", "unidad": Maestro.ID, "de": 4, "a": 2, "motivo": "hechizo"})
	assert_dict(lanzadera[2]).is_equal((jugadas[2]["previsto"] as ResultadoAccion).evento)
	assert_array(lanzadera[2].keys()).contains_exactly_in_any_order(["tipo", "objetivo", "sentido", "desde", "hasta",
			"choque", "danio", "vida_antes", "vida_despues"])
	assert_int(combate.instantanea()["maestro"]["mana"]).is_equal(2)
	assert_str(combate.error()).is_empty()


# Criterio 8: con menos mana que el costo, el Combate rechaza el hechizo y no
# registra nada. Con 3 no alcanza el Remiendo (4) y si el Martillazo (2).
func test_sin_mana_no_registra_nada() -> void:
	var combate: Combate = _combate()
	_hasta_el_maestro(combate)
	var maestro: Maestro = combate.contexto().plantel.maestro
	maestro.mana = 1
	var lineas: int = combate.registro().lineas().size()
	var grabadas: int = combate.acciones_jugador().size()
	for accion in [Accion.hechizo("martillazo", "surcon_s1"), Accion.hechizo("remiendo", Maestro.ID),
			Accion.hechizo("lanzadera", "rodauva_1", "empujar")]:
		var resultado: ResultadoAccion = combate.aplicar(accion)
		assert_int(resultado.motivo).is_equal(ResultadoAccion.Motivo.MANA_INSUFICIENTE)
	maestro.mana = 3
	assert_int(combate.aplicar(Accion.hechizo("remiendo", Maestro.ID)).motivo) \
			.is_equal(ResultadoAccion.Motivo.MANA_INSUFICIENTE)
	assert_int(combate.registro().lineas().size()).is_equal(lineas)
	assert_int(combate.acciones_jugador().size()).is_equal(grabadas)
	_aplicar_valida(combate, Accion.hechizo("martillazo", "surcon_s1"))
	assert_int(maestro.mana).is_equal(1)


# Criterio 11: una grabacion con los tres hechizos valida contra el esquema, pasa
# por JSON y se reproduce con el mismo registro y la misma instantanea.
func test_grabacion_con_los_tres_se_reproduce_igual() -> void:
	var en_vivo: Combate = _combate()
	_jugar_los_tres(en_vivo)
	var grabacion: Dictionary = Grabacion.desde_combate(en_vivo).a_diccionario()
	var esquema: Dictionary = Cargador.new().esquema_resuelto(_CARPETA_DATOS, "grabacion")["esquema"]
	var leida: Dictionary = Validador.new().validar(JSON.parse_string(JSON.stringify(grabacion)), esquema, "grabacion")
	assert_array(leida["errores"] as Array).override_failure_message(str(leida["errores"])).is_empty()
	var tipos: Array = (leida["datos"]["acciones"] as Array).map(func(a: Dictionary) -> String: return a["accion"]["tipo"])
	assert_int(tipos.count("hechizo")).is_equal(3)

	var reproduccion: Reproductor = Reproductor.reproducir(Grabacion.desde_diccionario(leida["datos"]), _datos())
	assert_str(reproduccion.error).is_empty()
	assert_array(reproduccion.combate.registro().lineas_json()).is_equal(en_vivo.registro().lineas_json())
	assert_dict(reproduccion.combate.instantanea()).is_equal(en_vivo.instantanea())

	var con_sentido_raro: Dictionary = grabacion.duplicate(true)
	for grabada in (con_sentido_raro["acciones"] as Array):
		if (grabada["accion"] as Dictionary).has("sentido"):
			grabada["accion"]["sentido"] = "girar"
	assert_array(Validador.new().validar(con_sentido_raro, esquema, "grabacion")["errores"] as Array).is_not_empty()
