extends GdUnitTestSuite

# Arquitectura.md B.4 (T29), criterios 5, 7 y 8: el rescate dentro del Combate,
# con fixtures (A.6). Sistema.md 6 y 11.5; A.7 (evento `rescate` entre `fin` y
# `cierre`, solo con derrota_por_caida); D-005 (Combate.rescatista_ahora calcula
# sin aplicar); D-011 (metrica 12). escenario_rescate_combate.json: zancajunco_1
# (leal, 7) juega primero; despues la Ocarra salvaje remata al Maestro.
const _CARPETA: String = "res://pruebas/fixtures/combate/"
const _CARPETA_CONTRATO: String = "res://pruebas/fixtures/combate/contrato/"
const _CARPETA_DATOS: String = "res://datos"
const _LEAL: String = "zancajunco_1"
const _UMBRAL: int = 7
const _RESCATE: int = 2


func _datos() -> Dictionary:
	var lectura: Dictionary = DatosFixture.cargar()
	var errores: Array[Dictionary] = lectura["errores"]
	assert_array(errores).override_failure_message(str(errores)).is_empty()
	return lectura["datos"]


func _escenario(ruta: String) -> Dictionary:
	var lectura: Dictionary = LectorFixture.leer(ruta, "escenario")
	var errores: Array[Dictionary] = lectura["errores"]
	assert_array(errores).override_failure_message(str(errores)).is_empty()
	return lectura["datos"]


# lealtad: la de zancajunco_1 en el escenario (asi la grabacion la lleva).
func _combate(lealtad: int = _UMBRAL) -> Combate:
	var escenario: Dictionary = _escenario(_CARPETA + "escenario_rescate_combate.json")
	((escenario["tribu"] as Array)[0] as Dictionary)["lealtad"] = lealtad
	return _empezar(escenario, _datos())


func _empezar(escenario: Dictionary, datos: Dictionary) -> Combate:
	var contexto: ContextoCombate = ContextoCombate.armar(escenario, datos)
	assert_bool(contexto.valido).is_true()
	var combate: Combate = Combate.empezar(contexto)
	assert_str(combate.error()).is_empty()
	return combate


func _aplicar_valida(combate: Combate, accion: Accion) -> void:
	var resultado: ResultadoAccion = combate.aplicar(accion)
	assert_bool(resultado.valida).override_failure_message(
			ResultadoAccion.Motivo.keys()[resultado.motivo] + " " + str(accion.a_diccionario())).is_true()
	assert_str(combate.error()).is_empty()


func _tipos(combate: Combate) -> Array[String]:
	var tipos: Array[String] = []
	for linea in combate.registro().lineas():
		tipos.append(linea["tipo"])
	return tipos


func _lineas(combate: Combate, tipo: String) -> Array[Dictionary]:
	return combate.registro().lineas().filter(func(linea: Dictionary) -> bool: return linea["tipo"] == tipo)


func _errores_esquema(valor: Variant, nombre_esquema: String) -> Array[Dictionary]:
	var esquema: Dictionary = Cargador.new().esquema_resuelto(_CARPETA_DATOS, nombre_esquema)["esquema"]
	return Validador.new().validar(valor, esquema, nombre_esquema)["errores"]


# (7) En el turno del jugador, rescatista_ahora da la que despues elige el Cierre,
# y consultarla no cambia la instantanea ni el generador.
func test_rescatista_ahora_es_la_del_cierre() -> void:
	var combate: Combate = _combate()
	assert_str(combate.turno_actual().unidad_id).is_equal(_LEAL)
	var antes: Dictionary = combate.instantanea()
	var tiradas: int = combate.contexto().azar_combate.historial().size()
	var ahora: Variant = combate.rescatista_ahora()
	assert_str(ahora).is_equal(_LEAL)
	assert_dict(combate.instantanea()).is_equal(antes)
	assert_int(combate.contexto().azar_combate.historial().size()).is_equal(tiradas)

	_aplicar_valida(combate, Accion.terminar())
	assert_int(combate.fin()).is_equal(FinCombate.Fin.DERROTA_POR_CAIDA)
	assert_str(combate.resultado().rescatista).is_equal(ahora)
	assert_bool(combate.resultado().permadeath).is_false()


# (7) La consulta sigue al Plantel: si la lealtad baja del umbral, nadie; si vuelve, ella.
func test_rescatista_ahora_sigue_la_lealtad() -> void:
	var combate: Combate = _combate()
	var leal: Criatura = combate.contexto().plantel.criatura(_LEAL)
	leal.lealtad = _UMBRAL - 1
	assert_object(combate.rescatista_ahora()).is_null()
	leal.lealtad = _UMBRAL
	assert_str(combate.rescatista_ahora()).is_equal(_LEAL)


# (8) Registro con rescate: fin -> rescate -> cierre, y el +2 en el cierre con su motivo.
func test_registro_con_rescate() -> void:
	var combate: Combate = _combate()
	_aplicar_valida(combate, Accion.terminar())
	var tipos: Array[String] = _tipos(combate)
	assert_array(tipos.slice(-3)).is_equal(["fin", "rescate", "cierre"])
	var rescate: Dictionary = _lineas(combate, "rescate")[0]
	assert_str(rescate["rescatista"]).is_equal(_LEAL)
	assert_bool(rescate["permadeath"]).is_false()
	var cambios: Array = _lineas(combate, "cierre")[0]["lealtad"]
	assert_array(cambios).is_equal([{"id": _LEAL, "antes": _UMBRAL, "cambio": _RESCATE,
			"despues": _UMBRAL + _RESCATE, "anotaciones": [{"cambio": _RESCATE, "motivo": "rescate"}]}])

	var resultado: Dictionary = combate.resultado().a_diccionario()
	var errores: Array[Dictionary] = _errores_esquema(resultado, "resultado")
	assert_array(errores).override_failure_message(str(errores)).is_empty()
	assert_str(resultado["rescatista"]).is_equal(_LEAL)
	assert_bool(resultado["permadeath"]).is_false()
	assert_dict(resultado["metricas"]["rescate"]).is_equal({"rescatista": _LEAL})


# (8) Sin rescatista: permadeath en el evento, en el resultado y en la metrica 12.
func test_registro_con_permadeath() -> void:
	var combate: Combate = _combate(_UMBRAL - 1)
	assert_object(combate.rescatista_ahora()).is_null()
	_aplicar_valida(combate, Accion.terminar())
	assert_array(_tipos(combate).slice(-3)).is_equal(["fin", "rescate", "cierre"])
	var rescate: Dictionary = _lineas(combate, "rescate")[0]
	assert_object(rescate["rescatista"]).is_null()
	assert_bool(rescate["permadeath"]).is_true()
	assert_array(_lineas(combate, "cierre")[0]["lealtad"]).is_empty()

	var resultado: Dictionary = combate.resultado().a_diccionario()
	var errores: Array[Dictionary] = _errores_esquema(resultado, "resultado")
	assert_array(errores).override_failure_message(str(errores)).is_empty()
	assert_object(resultado["rescatista"]).is_null()
	assert_bool(resultado["permadeath"]).is_true()
	assert_dict(resultado["metricas"]["rescate"]).is_equal({"rescatista": null})


# (8) La grabacion pasa por JSON y se reproduce con el mismo registro.
func test_grabacion_se_reproduce_igual() -> void:
	var en_vivo: Combate = _combate()
	_aplicar_valida(en_vivo, Accion.terminar())
	var grabacion: Dictionary = Grabacion.desde_combate(en_vivo).a_diccionario()
	var esquema: Dictionary = Cargador.new().esquema_resuelto(_CARPETA_DATOS, "grabacion")["esquema"]
	var leida: Dictionary = Validador.new().validar(JSON.parse_string(JSON.stringify(grabacion)), esquema, "grabacion")
	assert_array(leida["errores"] as Array).override_failure_message(str(leida["errores"])).is_empty()
	var reproduccion: Reproductor = Reproductor.reproducir(Grabacion.desde_diccionario(leida["datos"]), _datos())
	assert_str(reproduccion.error).is_empty()
	assert_array(reproduccion.combate.registro().lineas_json()).is_equal(en_vivo.registro().lineas_json())
	assert_dict(reproduccion.combate.resultado().a_diccionario()).is_equal(en_vivo.resultado().a_diccionario())


# (6) y (8) En una victoria: sin evento rescate, rescatista null, permadeath falso
# y metrica 12 null.
func test_victoria_sin_rescate() -> void:
	var escenario: Dictionary = _escenario(_CARPETA_CONTRATO + "contrato_victoria.json")
	for criatura: Dictionary in escenario["tribu"]:
		criatura["lealtad"] = 10
	var combate: Combate = _empezar(escenario, _datos())
	_aplicar_valida(combate, Accion.mover(Vector2i(2, 5)))
	_aplicar_valida(combate, Accion.atacar("ocarra_s1"))
	assert_int(combate.fin()).is_equal(FinCombate.Fin.VICTORIA)
	assert_array(_lineas(combate, "rescate")).is_empty()
	var resultado: Dictionary = combate.resultado().a_diccionario()
	assert_object(resultado["rescatista"]).is_null()
	assert_bool(resultado["permadeath"]).is_false()
	assert_object(resultado["metricas"]["rescate"]).is_null()


# (5) y (6) Con la huida declarada (T28): si el Maestro se va, no hay rescate; si
# cae antes del cierre, rescata una de las que se iban.
func test_huida_declarada() -> void:
	var datos: Dictionary = _datos()
	datos.merge(MesaHuida.fichas_t25())
	datos["maestro.json"]["velocidad"] = 9
	var escenario: Dictionary = _escenario(_CARPETA + "escenario_huida_maestro_combate.json")
	((escenario["tribu"] as Array)[0] as Dictionary)["lealtad"] = _UMBRAL

	var se_va: Combate = _empezar(escenario.duplicate(true), datos.duplicate(true))
	_declarar_y_esperar(se_va)
	assert_int(se_va.fin()).is_equal(FinCombate.Fin.HUIDA)
	assert_array(_lineas(se_va, "rescate")).is_empty()
	assert_object(se_va.resultado().a_diccionario()["rescatista"]).is_null()
	assert_bool(se_va.resultado().permadeath).is_false()

	# Con 13 de vida, el Tasajero (10) y el Surcon (3) lo tumban antes del cierre.
	var contexto: ContextoCombate = ContextoCombate.armar(escenario.duplicate(true), datos.duplicate(true))
	contexto.plantel.maestro.vida = 13
	var cae: Combate = Combate.empezar(contexto)
	_declarar_y_esperar(cae)
	assert_int(cae.fin()).is_equal(FinCombate.Fin.DERROTA_POR_CAIDA)
	assert_str(_lineas(cae, "rescate")[0]["rescatista"]).is_equal("rodauva_1")
	assert_str(cae.resultado().rescatista).is_equal("rodauva_1")


# El Maestro juega primero (Velocidad 9): declara la huida y despues el jugador
# termina todos sus turnos hasta que el combate acaba.
func _declarar_y_esperar(combate: Combate) -> void:
	assert_str(combate.turno_actual().unidad_id).is_equal(Maestro.ID)
	_aplicar_valida(combate, Accion.huir())
	for _i in range(30):
		if combate.terminado():
			return
		_aplicar_valida(combate, Accion.terminar())
	assert_bool(combate.terminado()).is_true()
