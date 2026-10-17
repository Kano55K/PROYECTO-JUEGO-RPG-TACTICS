extends GdUnitTestSuite

# Arquitectura.md B.4 (T24), criterios 8 y 9: sellar dentro del Combate, con
# fixtures (A.6). escenario_sellar_combate.json (balanza 3: sellar al Surcon
# cuesta 4, lealtad inicial 1; semilla 3: el sellado de la ronda 1 falla y el de
# la ronda 2 sale). Sistema.md 4.1, 4.2, 2.3, 2.1 y 5.2; A.7 (orden del registro),
# D-007 (mana con motivo) y D-011 (metrica 7).
const _CARPETA: String = "res://pruebas/fixtures/combate/"
const _CARPETA_DATOS: String = "res://datos"
const _SURCON: String = "surcon_s1"
const _RODAUVA: String = "rodauva_1"


func _datos() -> Dictionary:
	var lectura: Dictionary = DatosFixture.cargar()
	var errores: Array[Dictionary] = lectura["errores"]
	assert_array(errores).override_failure_message(str(errores)).is_empty()
	return lectura["datos"]


func _escenario() -> Dictionary:
	return LectorFixture.leer(_CARPETA + "escenario_sellar_combate.json", "escenario")["datos"]


func _combate() -> Combate:
	var contexto: ContextoCombate = ContextoCombate.armar(_escenario(), _datos())
	assert_bool(contexto.valido).is_true()
	var combate: Combate = Combate.empezar(contexto)
	assert_str(combate.error()).is_empty()
	return combate


func _aplicar_valida(combate: Combate, accion: Accion) -> ResultadoAccion:
	var resultado: ResultadoAccion = combate.aplicar(accion)
	assert_bool(resultado.valida).override_failure_message("%s: %s" % [str(accion.a_diccionario()),
			ResultadoAccion.Motivo.keys()[resultado.motivo]]).is_true()
	assert_str(combate.error()).is_empty()
	return resultado


# Una ronda: la Rodauva le pega al Surcon y el Maestro lo intenta sellar. Devuelve
# el indice del registro donde empieza la accion del sellado.
func _ronda(combate: Combate) -> int:
	assert_str(combate.turno_actual().unidad_id).is_equal(_RODAUVA)
	_aplicar_valida(combate, Accion.atacar(_SURCON))
	_aplicar_valida(combate, Accion.terminar())
	assert_str(combate.turno_actual().unidad_id).is_equal(Maestro.ID)
	var desde: int = combate.registro().lineas().size()
	var resultado: ResultadoAccion = _aplicar_valida(combate, Accion.sellar(_SURCON))
	if not combate.terminado():
		_aplicar_valida(combate, Accion.terminar())
	assert_int(resultado.porcentaje).is_equal(65)
	return desde


# Las dos rondas: un sellado fallido y uno logrado. Devuelve los indices.
func _jugar(combate: Combate) -> Array[int]:
	var primero: int = _ronda(combate)
	var segundo: int = _ronda(combate)
	assert_bool(combate.terminado()).is_true()
	return [primero, segundo]


func _tipos_desde(combate: Combate, desde: int, cantidad: int) -> Array:
	var lineas: Array[Dictionary] = combate.registro().lineas()
	return lineas.slice(desde, desde + cantidad).map(func(linea: Dictionary) -> String: return linea["tipo"])


func _sin_n(linea: Dictionary) -> Dictionary:
	var copia: Dictionary = linea.duplicate(true)
	copia.erase("n")
	copia.erase("ronda")
	return copia


# (8) A.7: accion -> mana (sellar) -> tirada -> sellado; si sale, estado (fuera) y
# cadena_cortada (objetivo_fuera, P-029), y despues el fin.
func test_registro_en_el_orden_de_a7() -> void:
	var combate: Combate = _combate()
	var indices: Array[int] = _jugar(combate)
	var lineas: Array[Dictionary] = combate.registro().lineas()
	# El fallido: sin estado ni cadena; la tirada esta antes del sellado.
	assert_array(_tipos_desde(combate, indices[0], 4)).is_equal(["accion", "mana", "tirada", "sellado"])
	assert_dict(_sin_n(lineas[indices[0] + 1])).is_equal({"tipo": "mana", "unidad": Maestro.ID, "de": 9, "a": 5,
			"motivo": "sellar"})
	var fallido: Dictionary = _sin_n(lineas[indices[0] + 3])
	assert_str(fallido["resultado"]).is_equal("fallido")
	assert_int(fallido["tiro"]).is_equal(lineas[indices[0] + 2]["resultado"])
	assert_that(fallido["pergamino"]).is_null()
	# El logrado.
	assert_array(_tipos_desde(combate, indices[1], 7)).is_equal(["accion", "mana", "tirada", "sellado", "estado",
			"cadena_cortada", "fin"])
	var logrado: Dictionary = _sin_n(lineas[indices[1] + 3])
	assert_dict(logrado).is_equal({"tipo": "sellado", "objetivo": _SURCON, "porcentaje": 65,
			"tiro": lineas[indices[1] + 2]["resultado"], "resultado": "logrado", "pergamino": "pergamino_2"})
	assert_dict(_sin_n(lineas[indices[1] + 4])).is_equal({"tipo": "estado", "unidad": _SURCON, "de": "suelta",
			"a": "fuera"})
	assert_str(lineas[indices[1] + 5]["motivo"]).is_equal(Cadena.MOTIVO_OBJETIVO_FUERA)
	assert_str(lineas[indices[1] + 6]["desenlace"]).is_equal("victoria")


# (8) La partida con un fallido y un logrado se graba, valida contra el esquema,
# pasa por JSON y se reproduce con el mismo registro.
func test_grabacion_se_reproduce_igual() -> void:
	var en_vivo: Combate = _combate()
	_jugar(en_vivo)
	var grabacion: Dictionary = Grabacion.desde_combate(en_vivo).a_diccionario()
	var esquema: Dictionary = Cargador.new().esquema_resuelto(_CARPETA_DATOS, "grabacion")["esquema"]
	var leida: Dictionary = Validador.new().validar(JSON.parse_string(JSON.stringify(grabacion)), esquema, "grabacion")
	assert_array(leida["errores"] as Array).override_failure_message(str(leida["errores"])).is_empty()
	var tipos: Array = (leida["datos"]["acciones"] as Array).map(func(a: Dictionary) -> String: return a["accion"]["tipo"])
	assert_int(tipos.count("sellar")).is_equal(2)
	var reproduccion: Reproductor = Reproductor.reproducir(Grabacion.desde_diccionario(leida["datos"]), _datos())
	assert_str(reproduccion.error).is_empty()
	assert_array(reproduccion.combate.registro().lineas_json()).is_equal(en_vivo.registro().lineas_json())
	assert_dict(reproduccion.combate.instantanea()).is_equal(en_vivo.instantanea())


# (9) El resultado lleva la captura con la lealtad inicial de la balanza 3 (1,
# Sistema.md 4.2) y valida contra el esquema. La capturada sale guardada: no
# tiene anotacion de victoria (5.2); la Rodauva de la tribu, si.
func test_resultado_con_capturas_valida() -> void:
	var combate: Combate = _combate()
	_jugar(combate)
	var datos: Dictionary = combate.resultado().a_diccionario()
	assert_array(datos["capturas"]).is_equal([{"unidad": _SURCON, "especie": "surcon", "pergamino": "pergamino_2",
			"lealtad": 1}])
	assert_int(datos["pergaminos"]["en_blanco"]).is_equal(0)
	var con_cambios: Array = (datos["lealtad_cambios"] as Array).map(func(c: Dictionary) -> String: return c["id"])
	assert_array(con_cambios).contains_exactly([_RODAUVA])
	var esquema: Dictionary = Cargador.new().esquema_resuelto(_CARPETA_DATOS, "resultado")["esquema"]
	var validado: Dictionary = Validador.new().validar(JSON.parse_string(JSON.stringify(datos)), esquema, "resultado")
	assert_array(validado["errores"] as Array).override_failure_message(str(validado["errores"])).is_empty()


# (9) D-011: la metrica 7 con los dos intentos, en orden, con el % mostrado.
func test_metrica_7_con_los_dos_intentos() -> void:
	var combate: Combate = _combate()
	_jugar(combate)
	assert_array(combate.resultado().metricas["sellados"]).is_equal([
		{"objetivo": _SURCON, "porcentaje": 65, "logrado": false},
		{"objetivo": _SURCON, "porcentaje": 65, "logrado": true},
	])


# (9) Sin intentos, la metrica 7 es una lista vacia.
func test_metrica_7_vacia_sin_intentos() -> void:
	var combate: Combate = _combate()
	_aplicar_valida(combate, Accion.terminar())
	_aplicar_valida(combate, Accion.terminar())
	var metricas: Dictionary = MetricasCombate.calcular(_escenario(), combate.registro().lineas())
	assert_array(metricas["sellados"]).is_empty()


# T24: porcentaje_sellado y costo_sellado, para la salvaje sin mirar distancia,
# mana ni pergaminos; null para el Maestro y la tribu.
func test_porcentaje_y_costo_sellado() -> void:
	var combate: Combate = _combate()
	assert_int(combate.porcentaje_sellado(_SURCON)).is_equal(65)
	assert_int(combate.costo_sellado(_SURCON)).is_equal(4)
	assert_that(combate.porcentaje_sellado(_RODAUVA)).is_null()
	assert_that(combate.porcentaje_sellado(Maestro.ID)).is_null()
	assert_that(combate.costo_sellado(Maestro.ID)).is_null()
