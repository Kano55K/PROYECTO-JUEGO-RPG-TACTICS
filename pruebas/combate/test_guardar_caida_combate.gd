extends GdUnitTestSuite

# Arquitectura.md B.4 (T27), criterios 8, 9, 10 y 11: guardar a una caida dentro
# del Combate, con fixtures (A.6). escenario_guardar_caida_combate.json: en la
# ronda 1 el Zancajunco salvaje tumba a rodauva_2 y la Ocarra salvaje a
# rodauva_1, que queda a distancia 2 del Maestro; en la ronda 2 la Ocarra le pega
# al Maestro. Sistema.md 11.5, 3.1, 2.3, 11.3 (la invocada entra la ronda
# siguiente) y 11.9 (metrica 10); A.7 (orden del registro), D-007 (mana con
# motivo) y D-011. Lectura declarada S-58 (se invoca despues con esa vida).
const _CARPETA: String = "res://pruebas/fixtures/combate/"
const _CARPETA_DATOS: String = "res://datos"
const _CAIDA: String = "rodauva_1"
const _LEJOS: String = "rodauva_2"
const _VIDA_FIXTURE: int = 1
const _COSTO_RODAUVA: int = 2
const _TOPE_ACCIONES: int = 30


func _datos() -> Dictionary:
	var lectura: Dictionary = DatosFixture.cargar()
	var errores: Array[Dictionary] = lectura["errores"]
	assert_array(errores).override_failure_message(str(errores)).is_empty()
	return lectura["datos"]


# vida_maestro: la del Maestro bajada a mano antes de empezar (0 = la de su balanza).
func _combate(vida_maestro: int = 0) -> Combate:
	var escenario: Dictionary = LectorFixture.leer(_CARPETA + "escenario_guardar_caida_combate.json",
			"escenario")["datos"]
	var contexto: ContextoCombate = ContextoCombate.armar(escenario, _datos())
	assert_bool(contexto.valido).is_true()
	if vida_maestro > 0:
		contexto.plantel.maestro.vida = vida_maestro
	var combate: Combate = Combate.empezar(contexto)
	assert_str(combate.error()).is_empty()
	return combate


func _aplicar_valida(combate: Combate, accion: Accion) -> ResultadoAccion:
	var resultado: ResultadoAccion = combate.aplicar(accion)
	assert_bool(resultado.valida).override_failure_message("%s: %s" % [str(accion.a_diccionario()),
			ResultadoAccion.Motivo.keys()[resultado.motivo]]).is_true()
	assert_str(combate.error()).is_empty()
	return resultado


# Termina los turnos del jugador hasta el del Maestro; false si antes termino el combate.
func _hasta_el_maestro(combate: Combate) -> bool:
	for _i in range(_TOPE_ACCIONES):
		assert_str(combate.error()).is_empty()
		if combate.terminado():
			return false
		if combate.turno_actual().unidad_id == Maestro.ID:
			return true
		_aplicar_valida(combate, Accion.terminar())
	return false


func _criatura(combate: Combate, unidad_id: String) -> Dictionary:
	for criatura: Dictionary in combate.instantanea()["criaturas"]:
		if criatura["id"] == unidad_id:
			return criatura
	return {}


func _sin_n(linea: Dictionary) -> Dictionary:
	var copia: Dictionary = linea.duplicate(true)
	copia.erase("n")
	copia.erase("ronda")
	return copia


# Ronda 1, turno del Maestro: las dos Rodauvas caidas; la cercana se guarda.
# Devuelve el indice del registro donde empieza la accion.
func _guardar(combate: Combate) -> int:
	assert_bool(_hasta_el_maestro(combate)).is_true()
	assert_int(combate.instantanea()["ronda"]).is_equal(1)
	assert_str(_criatura(combate, _CAIDA)["estado"]).is_equal("caida")
	assert_str(_criatura(combate, _LEJOS)["estado"]).is_equal("caida")
	var desde: int = combate.registro().lineas().size()
	_aplicar_valida(combate, Accion.guardar_caida(_CAIDA))
	return desde


# (10) Consultas: objetivos, motivo, costo y previsualizacion calculan sin
# aplicar (ni la instantanea, ni el mana, ni el generador) y dicen lo mismo
# que validar y aplicar.
func test_consultas_son_validar_y_aplicar() -> void:
	var combate: Combate = _combate()
	assert_bool(_hasta_el_maestro(combate)).is_true()
	var turno: Turno = combate.turno_actual()
	var antes: Dictionary = combate.instantanea()
	var tiradas: int = combate.registro().lineas().filter(func(linea: Dictionary) -> bool:
			return linea["tipo"] == "tirada").size()
	assert_array(turno.objetivos_para_guardar_caida()).is_equal([_CAIDA])
	assert_int(turno.motivo_guardar_caida()).is_equal(ResultadoAccion.Motivo.NINGUNO)
	assert_int(combate.costo_guardar_caida(_CAIDA)).is_equal(_COSTO_RODAUVA)
	# El costo no mira la distancia; de una enemiga o de una suelta, null.
	assert_int(combate.costo_guardar_caida(_LEJOS)).is_equal(_COSTO_RODAUVA)
	assert_object(combate.costo_guardar_caida("ocarra_s1")).is_null()
	assert_str(ResultadoAccion.Motivo.keys()[turno.validar(Accion.guardar_caida(_LEJOS)).motivo]) \
			.is_equal("FUERA_DE_ALCANCE")
	var previa: ResultadoAccion = turno.previsualizar_guardar_caida(_CAIDA)
	var validada: ResultadoAccion = turno.validar(Accion.guardar_caida(_CAIDA))
	assert_dict(combate.instantanea()).is_equal(antes)
	assert_bool(previa.valida).is_true()
	var mana: int = antes["maestro"]["mana"]
	assert_dict(previa.mana).is_equal({"de": mana, "a": mana - _COSTO_RODAUVA})
	assert_dict(previa.vida).is_equal({"de": 0, "a": _VIDA_FIXTURE})
	var aplicada: ResultadoAccion = _aplicar_valida(combate, Accion.guardar_caida(_CAIDA))
	for resultado in [validada, aplicada]:
		assert_int(resultado.costo).is_equal(previa.costo)
		assert_dict(resultado.mana).is_equal(previa.mana)
		assert_dict(resultado.vida).is_equal(previa.vida)
		assert_dict(resultado.evento).is_equal(previa.evento)
	# Guardar a una caida no tira nada.
	assert_int(combate.registro().lineas().filter(func(linea: Dictionary) -> bool:
			return linea["tipo"] == "tirada").size()).is_equal(tiradas)
	assert_int(combate.instantanea()["maestro"]["mana"]).is_equal(mana - _COSTO_RODAUVA)


# (10) A.7: accion -> mana (guardar_caida) -> estado (caida -> guardada) ->
# guardado_caida. El Maestro sigue en su turno (no hay fin_turno) y se puede mover.
func test_registro_en_el_orden_de_a7() -> void:
	var combate: Combate = _combate()
	var desde: int = _guardar(combate)
	var lineas: Array[Dictionary] = combate.registro().lineas().slice(desde)
	var mana: int = (lineas[1]["de"] as int)
	assert_array(lineas.map(_sin_n)).is_equal([
		{"tipo": "accion", "unidad": Maestro.ID, "origen": "jugador",
				"accion": {"tipo": "guardar_caida", "objetivo": _CAIDA}, "paso": null},
		{"tipo": "mana", "unidad": Maestro.ID, "de": mana, "a": mana - _COSTO_RODAUVA, "motivo": "guardar_caida"},
		{"tipo": "estado", "unidad": _CAIDA, "de": "caida", "a": "guardada"},
		{"tipo": "guardado_caida", "unidad": _CAIDA, "vida": _VIDA_FIXTURE},
	])
	var guardada: Dictionary = _criatura(combate, _CAIDA)
	assert_str(guardada["estado"]).is_equal("guardada")
	assert_object(guardada["posicion"]).is_null()
	assert_int(guardada["vida"]).is_equal(_VIDA_FIXTURE)
	assert_str(guardada["pergamino"]).is_not_empty()
	assert_str(combate.turno_actual().unidad_id).is_equal(Maestro.ID)
	assert_bool(combate.turno_actual().casillas_para_mover().is_empty()).is_false()


# (9) S-58: en el turno siguiente del Maestro (ronda 2) se invoca, pagando el
# costo de invocar, y vuelve con la vida que le quedo al guardarla.
func test_se_invoca_despues_con_esa_vida() -> void:
	var combate: Combate = _combate()
	_guardar(combate)
	_aplicar_valida(combate, Accion.terminar())
	assert_bool(_hasta_el_maestro(combate)).is_true()
	assert_int(combate.instantanea()["ronda"]).is_equal(2)
	var turno: Turno = combate.turno_actual()
	assert_array(turno.guardadas_para_invocar()).contains([_CAIDA])
	assert_int(combate.costo_invocar(_CAIDA)).is_equal(_COSTO_RODAUVA)
	var casilla: Vector2i = turno.casillas_para_invocar()[0]
	_aplicar_valida(combate, Accion.invocar(_CAIDA, casilla))
	var invocada: Dictionary = _criatura(combate, _CAIDA)
	assert_str(invocada["estado"]).is_equal("suelta")
	assert_int(invocada["vida"]).is_equal(_VIDA_FIXTURE)
	assert_array(invocada["posicion"]).is_equal([casilla.x, casilla.y])


# (10) La partida con guardar a una caida se graba, valida contra el esquema,
# pasa por JSON y se reproduce con el mismo registro y la misma instantanea.
func test_grabacion_se_reproduce_igual() -> void:
	var en_vivo: Combate = _combate()
	_guardar(en_vivo)
	_aplicar_valida(en_vivo, Accion.terminar())
	assert_bool(_hasta_el_maestro(en_vivo)).is_true()
	var grabacion: Dictionary = Grabacion.desde_combate(en_vivo).a_diccionario()
	var esquema: Dictionary = Cargador.new().esquema_resuelto(_CARPETA_DATOS, "grabacion")["esquema"]
	var leida: Dictionary = Validador.new().validar(JSON.parse_string(JSON.stringify(grabacion)), esquema, "grabacion")
	assert_array(leida["errores"] as Array).override_failure_message(str(leida["errores"])).is_empty()
	var tipos: Array = (leida["datos"]["acciones"] as Array).map(func(a: Dictionary) -> String: return a["accion"]["tipo"])
	assert_bool(tipos.has("guardar_caida")).is_true()
	var reproduccion: Reproductor = Reproductor.reproducir(Grabacion.desde_diccionario(leida["datos"]), _datos())
	assert_str(reproduccion.error).is_empty()
	assert_array(reproduccion.combate.registro().lineas_json()).is_equal(en_vivo.registro().lineas_json())
	assert_dict(reproduccion.combate.instantanea()).is_equal(en_vivo.instantanea())


# (10) Ida y vuelta por diccionario; sin objetivo o con un campo de mas, no.
func test_accion_ida_y_vuelta() -> void:
	var accion: Accion = Accion.guardar_caida(_CAIDA)
	assert_dict(accion.a_diccionario()).is_equal({"tipo": "guardar_caida", "objetivo": _CAIDA})
	var vuelta: Accion = Accion.desde_diccionario(JSON.parse_string(JSON.stringify(accion.a_diccionario())))
	assert_object(vuelta).is_not_null()
	assert_dict(vuelta.a_diccionario()).is_equal(accion.a_diccionario())
	assert_object(Accion.desde_diccionario({"tipo": "guardar_caida"})).is_null()
	assert_object(Accion.desde_diccionario({"tipo": "guardar_caida", "objetivo": _CAIDA, "casilla": [1, 1]})).is_null()


# (8) y (11) El Maestro cae en la ronda 2: la guardada sigue guardada (no muerta)
# con su pergamino y sin anotaciones de muerte por ella; la otra caida muere. La
# metrica 10 cuenta solo a la guardada, y el resultado valida contra el esquema.
func test_derrota_metrica_10_y_resultado() -> void:
	var combate: Combate = _combate(1)
	_guardar(combate)
	_aplicar_valida(combate, Accion.terminar())
	for _i in range(_TOPE_ACCIONES):
		if combate.terminado():
			break
		_aplicar_valida(combate, Accion.terminar())
	assert_bool(combate.terminado()).is_true()
	assert_int(combate.fin()).is_equal(FinCombate.Fin.DERROTA_POR_CAIDA)
	var guardada: Dictionary = _criatura(combate, _CAIDA)
	assert_str(guardada["estado"]).is_equal("guardada")
	assert_str(guardada["pergamino"]).is_not_empty()
	assert_str(_criatura(combate, _LEJOS)["estado"]).is_equal("muerta")
	var cierre: Array = combate.registro().lineas().filter(func(linea: Dictionary) -> bool:
			return linea["tipo"] == "cierre")
	assert_array(cierre[0]["muertas"]).is_equal([_LEJOS])
	assert_array(cierre[0]["pergaminos_ardidos"]).has_size(1)

	var resultado: Dictionary = combate.resultado().a_diccionario()
	assert_array(resultado["metricas"]["caidas_guardadas"]).is_equal([{"unidad": _CAIDA, "ronda": 1}])
	var esquema: Dictionary = Cargador.new().esquema_resuelto(_CARPETA_DATOS, "resultado")["esquema"]
	var errores: Array = Validador.new().validar(resultado, esquema, "resultado")["errores"]
	assert_array(errores).override_failure_message(str(errores)).is_empty()
