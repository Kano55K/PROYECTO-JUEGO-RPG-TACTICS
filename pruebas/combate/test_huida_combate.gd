extends GdUnitTestSuite

# Arquitectura.md B.4 (T25), criterios 3, 4, 6, 7 y 8: la huida dentro del
# Combate, con fixtures (A.6). escenario_huida_combate.json: huye_s1
# (especie_huida_100, 7 de 30: 100 %) juega primero y huye; la Ocarra salvaje
# sigue en pie. escenario_huida_tasajero.json: el Tasajero (25 %) con 7 de 30,
# semilla 5 (se queda dos veces). Sistema.md 11.7, 11.3 paso 2, 5.2 y 11.9
# (metrica 8); A.7 (orden del registro) y D-011.
const _CARPETA: String = "res://pruebas/fixtures/combate/"
const _CARPETA_DATOS: String = "res://datos"
const _HUYE: String = "huye_s1"
const _OCARRA: String = "ocarra_s1"
const _TASAJERO: String = "tasajero_s1"


func _datos() -> Dictionary:
	var lectura: Dictionary = DatosFixture.cargar()
	var errores: Array[Dictionary] = lectura["errores"]
	assert_array(errores).override_failure_message(str(errores)).is_empty()
	var datos: Dictionary = lectura["datos"]
	datos.merge(MesaHuida.fichas_t25())
	return datos


func _escenario(archivo: String = "escenario_huida_combate.json") -> Dictionary:
	return LectorFixture.leer(_CARPETA + archivo, "escenario")["datos"]


func _combate(escenario: Dictionary) -> Combate:
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


func _indice(lineas: Array[Dictionary], tipo: String, unidad_id: String, desde: int = 0) -> int:
	for indice in range(desde, lineas.size()):
		if lineas[indice]["tipo"] == tipo and lineas[indice].get("unidad") == unidad_id:
			return indice
	return -1


func _tipos(lineas: Array[Dictionary], desde: int, hasta: int) -> Array:
	return lineas.slice(desde, hasta).map(func(linea: Dictionary) -> String: return linea["tipo"])


func _sin_n(linea: Dictionary) -> Dictionary:
	var copia: Dictionary = linea.duplicate(true)
	copia.erase("n")
	copia.erase("ronda")
	return copia


# (7) A.7: turno -> tirada -> huida -> estado (fuera) -> fin_turno (sin
# posicion); despues juega la siguiente de la cola. (3) Queda fuera y no vuelve
# a tener turno en la ronda.
func test_huye_registro_en_el_orden_de_a7() -> void:
	var combate: Combate = _combate(_escenario())
	var lineas: Array[Dictionary] = combate.registro().lineas()
	var turno: int = _indice(lineas, "turno", _HUYE)
	assert_int(turno).is_greater(-1)
	assert_array(_tipos(lineas, turno, turno + 6)).is_equal(["turno", "tirada", "huida", "estado", "fin_turno",
			"turno"])
	var tiro: int = lineas[turno + 1]["resultado"]
	assert_dict(_sin_n(lineas[turno + 2])).is_equal({"tipo": "huida", "unidad": _HUYE, "porcentaje": 100,
			"tiro": tiro, "resultado": "huye"})
	assert_dict(_sin_n(lineas[turno + 3])).is_equal({"tipo": "estado", "unidad": _HUYE, "de": "suelta", "a": "fuera"})
	assert_dict(_sin_n(lineas[turno + 4])).is_equal({"tipo": "fin_turno", "unidad": _HUYE, "posicion": null})
	assert_str(lineas[turno + 5]["unidad"]).is_equal(_OCARRA)
	assert_int(_indice(lineas, "turno", _HUYE, turno + 1)).is_equal(-1)
	assert_bool(combate.terminado()).is_false()
	assert_int(combate.porcentaje_huida(_HUYE)).is_equal(0)


# (4) y (7) Se queda (la misma salvaje con 1 %, semilla 1: el combate tira 54):
# turno -> tirada -> huida -> y el turno sigue con la IA (accion ...).
func test_se_queda_y_juega() -> void:
	var escenario: Dictionary = _escenario()
	escenario["enemigas"][0]["especie"] = "especie_huida_1"
	var combate: Combate = _combate(escenario)
	var lineas: Array[Dictionary] = combate.registro().lineas()
	var turno: int = _indice(lineas, "turno", _HUYE)
	assert_array(_tipos(lineas, turno, turno + 4)).is_equal(["turno", "tirada", "huida", "accion"])
	assert_dict(_sin_n(lineas[turno + 2])).is_equal({"tipo": "huida", "unidad": _HUYE, "porcentaje": 1,
			"tiro": lineas[turno + 1]["resultado"], "resultado": "se_queda"})
	assert_int(lineas[turno + 1]["resultado"] as int).is_greater(1)
	assert_int(_indice(lineas, "fin_turno", _HUYE, turno)).is_greater(turno)
	assert_int(combate.porcentaje_huida(_HUYE)).is_equal(1)


# (3) La ultima enemiga de pie huye: victoria (5.2), sin fin_turno, con el cierre
# y el resultado; la metrica 8 la cuenta.
func test_la_ultima_que_huye_da_la_victoria() -> void:
	var escenario: Dictionary = _escenario()
	escenario["enemigas"] = [escenario["enemigas"][0]]
	var combate: Combate = _combate(escenario)
	assert_bool(combate.terminado()).is_true()
	assert_int(combate.fin()).is_equal(FinCombate.Fin.VICTORIA)
	var lineas: Array[Dictionary] = combate.registro().lineas()
	var turno: int = _indice(lineas, "turno", _HUYE)
	assert_array(_tipos(lineas, turno, lineas.size())).is_equal(["turno", "tirada", "huida", "estado", "fin", "cierre"])
	assert_object(combate.resultado()).is_not_null()
	assert_array(combate.resultado().metricas["capturas_perdidas"]).is_equal([
		{"unidad": _HUYE, "motivo": "huida", "ronda": 1}])


# (6) El Tasajero tira una vez por ronda, antes del cambio de modo: en la ronda
# 1, turno -> tirada -> huida -> cambio_modo; en la ronda 2, otra sola tirada.
func test_tasajero_una_tirada_por_ronda() -> void:
	var combate: Combate = _combate(_escenario("escenario_huida_tasajero.json"))
	for vuelta in 2:
		_aplicar_valida(combate, Accion.terminar())
		_aplicar_valida(combate, Accion.terminar())
	var lineas: Array[Dictionary] = combate.registro().lineas()
	var turno: int = _indice(lineas, "turno", _TASAJERO)
	assert_array(_tipos(lineas, turno, turno + 4)).is_equal(["turno", "tirada", "huida", "cambio_modo"])
	var por_ronda: Dictionary = {}
	for linea in lineas:
		if linea["tipo"] == "huida":
			assert_str(linea["unidad"]).is_equal(_TASAJERO)
			assert_int(linea["porcentaje"]).is_equal(25)
			assert_str(linea["resultado"]).is_equal("se_queda")
			por_ronda[linea["ronda"]] = por_ronda.get(linea["ronda"], 0) + 1
	assert_dict(por_ronda).contains_key_value(1, 1).contains_key_value(2, 1)
	assert_int(lineas.filter(func(l: Dictionary) -> bool: return l["tipo"] == "cambio_modo").size()).is_equal(1)


# (7) Una partida con una huida se graba, valida contra el esquema, pasa por
# JSON y se reproduce con el mismo registro.
func test_grabacion_se_reproduce_igual() -> void:
	var en_vivo: Combate = _combate(_escenario())
	for vuelta in 2:
		_aplicar_valida(en_vivo, Accion.terminar())
		_aplicar_valida(en_vivo, Accion.terminar())
	var grabacion: Dictionary = Grabacion.desde_combate(en_vivo).a_diccionario()
	var esquema: Dictionary = Cargador.new().esquema_resuelto(_CARPETA_DATOS, "grabacion")["esquema"]
	var leida: Dictionary = Validador.new().validar(JSON.parse_string(JSON.stringify(grabacion)), esquema, "grabacion")
	assert_array(leida["errores"] as Array).override_failure_message(str(leida["errores"])).is_empty()
	var reproduccion: Reproductor = Reproductor.reproducir(Grabacion.desde_diccionario(leida["datos"]), _datos())
	assert_str(reproduccion.error).is_empty()
	var tipos: Array = en_vivo.registro().lineas().map(func(l: Dictionary) -> String: return l["tipo"])
	assert_bool(tipos.has("huida")).is_true()
	assert_array(reproduccion.combate.registro().lineas_json()).is_equal(en_vivo.registro().lineas_json())
	assert_dict(reproduccion.combate.instantanea()).is_equal(en_vivo.instantanea())


# (8) El resultado de un combate con una huida valida contra el esquema, con la
# metrica 8 llena.
func test_resultado_con_huida_valida() -> void:
	var escenario: Dictionary = _escenario()
	escenario["enemigas"] = [escenario["enemigas"][0]]
	var combate: Combate = _combate(escenario)
	var datos: Dictionary = combate.resultado().a_diccionario()
	assert_array(datos["metricas"]["capturas_perdidas"]).is_equal([{"unidad": _HUYE, "motivo": "huida", "ronda": 1}])
	var esquema: Dictionary = Cargador.new().esquema_resuelto(_CARPETA_DATOS, "resultado")["esquema"]
	var validado: Dictionary = Validador.new().validar(JSON.parse_string(JSON.stringify(datos)), esquema, "resultado")
	assert_array(validado["errores"] as Array).override_failure_message(str(validado["errores"])).is_empty()
