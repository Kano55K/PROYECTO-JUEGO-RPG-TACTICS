extends GdUnitTestSuite

# Arquitectura.md B.4 (T28), criterios 2 a 5, 7, 8 y 9: la huida del Maestro
# dentro del Combate, con fixtures (A.6). Sistema.md 11.7 (los enemigos que faltan
# actuan; las caidas mueren; sin +1; previsualizacion del dano maximo), 11.5, 5.2
# y 7.2. Lecturas declaradas S-59 (turno sin usar), S-60 (la ronda sigue entera;
# victoria si antes cae o huye la ultima enemiga; hambre antes de irse) y S-61
# (dano maximo con el tablero de ahora, sin tiradas, por los ataques del modo).
# Desde T46 (11.7 v1.8, S-63) el Maestro se va justo antes de su proximo turno,
# no al cerrar la ronda: aca, con Velocidad 9, al empezar la ronda 2. Los casos
# de dos rondas estan en test_huida_una_vuelta.gd.
# escenario_huida_maestro_combate.json, con la Velocidad del Maestro subida en
# memoria a 9 (juega primero): el Tasajero en Caza le pega 5 + 5 desde [2,5], la
# Ocarra no lo alcanza y va por rodauva_1, y el Surcon le pega 3 desde [2,7].
const _CARPETA: String = "res://pruebas/fixtures/combate/"
const _CARPETA_DATOS: String = "res://datos"
const _VELOCIDAD_MAESTRO: int = 9
const _TASAJERO: String = "tasajero_s1"
const _OCARRA: String = "ocarra_s1"
const _SURCON: String = "surcon_s1"
const _SUELTA: String = "rodauva_1"
const _CAIDA: String = "rodauva_2"
const _GUARDADA: String = "rodauva_g"
# Los numeros del fixture (la comprobacion): Tasajero 5 por golpe en Caza, dos
# golpes; Surcon 3; Maestro de balanza 2 con 20 de vida.
const _DANIO_TASAJERO: int = 10
const _DANIO_SURCON: int = 3
const _VIDA_MAESTRO: int = 20
const _TOPE_ACCIONES: int = 30


# hambre_cada: las rondas del hambre de combate (0 = la del fixture).
func _datos(hambre_cada: int = 0) -> Dictionary:
	var lectura: Dictionary = DatosFixture.cargar()
	var errores: Array[Dictionary] = lectura["errores"]
	assert_array(errores).override_failure_message(str(errores)).is_empty()
	var datos: Dictionary = lectura["datos"]
	datos.merge(MesaHuida.fichas_t25())
	datos["maestro.json"]["velocidad"] = _VELOCIDAD_MAESTRO
	if hambre_cada > 0:
		datos["tablas/hambre.json"]["combate"]["cada_rondas"] = hambre_cada
	return datos


# enemigas: los ids que quedan del escenario ([] = todas). vida_maestro: la del
# Maestro bajada a mano antes de empezar (0 = la de su balanza).
func _combate(archivo: String = "escenario_huida_maestro_combate.json", enemigas: Array[String] = [],
		vida_maestro: int = 0, datos: Dictionary = {}) -> Combate:
	var escenario: Dictionary = LectorFixture.leer(_CARPETA + archivo, "escenario")["datos"]
	if not enemigas.is_empty():
		escenario["enemigas"] = (escenario["enemigas"] as Array).filter(func(enemiga: Dictionary) -> bool:
				return enemigas.has(enemiga["id"]))
	var contexto: ContextoCombate = ContextoCombate.armar(escenario, _datos() if datos.is_empty() else datos)
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


# El turno del Maestro en la ronda 1 (juega primero): declara y termina.
func _declarar(combate: Combate) -> void:
	assert_str(combate.turno_actual().unidad_id).is_equal(Maestro.ID)
	assert_int(combate.instantanea()["ronda"]).is_equal(1)
	_aplicar_valida(combate, Accion.huir())
	assert_bool(combate.instantanea()["maestro"]["huida_declarada"]).is_true()
	_aplicar_valida(combate, Accion.terminar())


# La criatura del turno ataca a `objetivo_id` desde la casilla de menos pasos
# que lo golpea (Turno.pasos_para_mover y previsualizar_ataque).
func _atacar_a(combate: Combate, objetivo_id: String) -> void:
	var turno: Turno = combate.turno_actual()
	var pasos: Dictionary = turno.pasos_para_mover()
	var mejor: Vector2i = Criatura.SIN_POSICION
	for casilla: Vector2i in pasos.keys():
		if turno.previsualizar_ataque(casilla, objetivo_id).valida \
				and (mejor == Criatura.SIN_POSICION or pasos[casilla] < pasos[mejor]):
			mejor = casilla
	assert_that(mejor).override_failure_message("no golpea a " + objetivo_id).is_not_equal(Criatura.SIN_POSICION)
	if pasos[mejor] > 0:
		_aplicar_valida(combate, Accion.mover(mejor))
	_aplicar_valida(combate, Accion.atacar(objetivo_id))


# Termina los turnos del jugador hasta el fin del combate.
func _hasta_el_fin(combate: Combate) -> void:
	for _i in range(_TOPE_ACCIONES):
		if combate.terminado():
			return
		_aplicar_valida(combate, Accion.terminar())
	assert_bool(combate.terminado()).is_true()


func _criatura(combate: Combate, unidad_id: String) -> Dictionary:
	for criatura: Dictionary in combate.instantanea()["criaturas"]:
		if criatura["id"] == unidad_id:
			return criatura
	return {}


func _lineas(combate: Combate, tipo: String) -> Array[Dictionary]:
	return combate.registro().lineas().filter(func(linea: Dictionary) -> bool: return linea["tipo"] == tipo)


func _tipos(combate: Combate, desde: int) -> Array:
	var lineas: Array[Dictionary] = combate.registro().lineas()
	return lineas.slice(desde).map(func(linea: Dictionary) -> String: return linea["tipo"])


# Danio que recibio el Maestro en los eventos `ataque` desde la linea `desde`.
func _danio_al_maestro(combate: Combate, desde: int) -> int:
	var total: int = 0
	for linea: Dictionary in combate.registro().lineas().slice(desde):
		if linea["tipo"] == "ataque" and linea["objetivo"] == Maestro.ID:
			total += (linea["vida_antes"] as int) - (linea["vida_despues"] as int)
	return total


# (2) La ronda sigue (S-60): el Tasajero y el Surcon le pegan al Maestro despues
# de la declaracion, y rodauva_1 juega su turno entero (se mueve y ataca).
func test_la_ronda_sigue() -> void:
	var combate: Combate = _combate()
	var desde: int = combate.registro().lineas().size()
	_declarar(combate)
	assert_str(combate.turno_actual().unidad_id).is_equal(_SUELTA)
	assert_int(_danio_al_maestro(combate, desde)).is_equal(_DANIO_TASAJERO)
	_atacar_a(combate, _OCARRA)
	assert_bool(combate.turno_actual().accion_usada).is_true()
	_aplicar_valida(combate, Accion.terminar())
	assert_int(_danio_al_maestro(combate, desde)).is_equal(_DANIO_TASAJERO + _DANIO_SURCON)
	var ataques: Array = _lineas(combate, "ataque").map(func(linea: Dictionary) -> String: return linea["atacante"])
	assert_array(ataques).contains_exactly([_TASAJERO, _TASAJERO, _OCARRA, _SUELTA, _SURCON])


# (3) Reescrito en T46 (Sistema.md 11.7 v1.8, S-63): el Maestro es el primero de
# la ronda siguiente, asi que se va al empezarla, justo despues de `ronda` y en
# lugar de su `turno`: huida, un solo cierre y despues todo COMBATE_TERMINADO.
# (6 en el Combate) la caida muere, la guardada sobrevive y la suelta pierde 4
# (Rodauva-Rodauva, 5.2), sin +1.
func test_se_va_antes_de_su_turno_de_la_ronda_siguiente() -> void:
	var combate: Combate = _combate()
	var desde: int = combate.registro().lineas().size()
	_declarar(combate)
	_hasta_el_fin(combate)
	assert_int(combate.fin()).is_equal(FinCombate.Fin.HUIDA)
	assert_int(combate.instantanea()["ronda"]).is_equal(2)
	assert_bool(combate.instantanea()["maestro"]["se_fue"]).is_true()
	assert_array(_tipos(combate, desde).slice(-4)).is_equal(["fin_ronda", "ronda", "fin", "cierre"])
	assert_array(_lineas(combate, "fin")).has_size(1)
	assert_str(_lineas(combate, "fin")[0]["desenlace"]).is_equal("huida")
	var cierres: Array[Dictionary] = _lineas(combate, "cierre")
	assert_array(cierres).has_size(1)
	assert_array(cierres[0]["muertas"]).is_equal([_CAIDA])
	assert_array(cierres[0]["pergaminos_ardidos"]).has_size(1)
	assert_array(cierres[0]["levantadas"]).is_empty()
	assert_str(_criatura(combate, _CAIDA)["estado"]).is_equal("muerta")
	assert_str(_criatura(combate, _GUARDADA)["estado"]).is_equal("guardada")
	assert_int(_criatura(combate, _GUARDADA)["lealtad"]).is_equal(5)
	assert_int(_criatura(combate, _SUELTA)["lealtad"]).is_equal(1)
	for cambio: Dictionary in cierres[0]["lealtad"]:
		assert_str(str(cambio)).not_contains("victoria")
	var lineas: int = combate.registro().lineas().size()
	var rechazo: ResultadoAccion = combate.aplicar(Accion.terminar())
	assert_str(ResultadoAccion.Motivo.keys()[rechazo.motivo]).is_equal("COMBATE_TERMINADO")
	assert_int(rechazo.fin).is_equal(FinCombate.Fin.HUIDA)
	assert_int(combate.registro().lineas().size()).is_equal(lineas)


# (3) Si la ronda que cierra suma hambre de combate (7.2), se suma antes de irse
# (S-60). Reescrito en T46 (Sistema.md 11.7 v1.8, S-63): hambre_combate va entre
# fin_ronda y la `ronda` siguiente, al empezar la cual se va.
func test_hambre_de_combate_antes_de_irse() -> void:
	var combate: Combate = _combate("escenario_huida_maestro_combate.json", [], 0, _datos(1))
	var hambre_antes: int = combate.instantanea()["maestro"]["hambre"]
	var desde: int = combate.registro().lineas().size()
	_declarar(combate)
	_hasta_el_fin(combate)
	assert_int(combate.fin()).is_equal(FinCombate.Fin.HUIDA)
	assert_array(_tipos(combate, desde).slice(-5)).is_equal(["fin_ronda", "hambre_combate", "ronda", "fin", "cierre"])
	assert_int(combate.instantanea()["maestro"]["hambre"]).is_equal(hambre_antes + 1)


# (4) El Maestro cae antes del cierre (11.7): derrota por caida, no huida. La
# previsualizacion lo decia (puede_caer).
func test_cae_antes_del_cierre() -> void:
	var vida: int = _DANIO_TASAJERO + _DANIO_SURCON
	var combate: Combate = _combate("escenario_huida_maestro_combate.json", [], vida)
	assert_bool(combate.previsualizar_huida()["puede_caer"]).is_true()
	_declarar(combate)
	_hasta_el_fin(combate)
	assert_int(combate.fin()).is_equal(FinCombate.Fin.DERROTA_POR_CAIDA)
	assert_str(_lineas(combate, "fin")[0]["desenlace"]).is_equal("derrota_por_caida")
	assert_bool(combate.instantanea()["maestro"]["se_fue"]).is_false()
	assert_array(_lineas(combate, "fin_ronda")).is_empty()


# (5) La ultima enemiga cae antes del cierre (S-60): victoria, con el +1.
func test_la_ultima_enemiga_cae_antes_del_cierre() -> void:
	var combate: Combate = _combate("escenario_huida_maestro_victoria.json", [_OCARRA])
	_declarar(combate)
	assert_str(combate.turno_actual().unidad_id).is_equal(_SUELTA)
	_atacar_a(combate, _OCARRA)
	assert_bool(combate.terminado()).is_true()
	assert_int(combate.fin()).is_equal(FinCombate.Fin.VICTORIA)
	var cierre: Dictionary = _lineas(combate, "cierre")[0]
	assert_str(str(cierre["lealtad"])).contains("victoria")
	assert_int(_criatura(combate, _SUELTA)["lealtad"]).is_equal(6)


# (5) La ultima enemiga huye en su turno (T25) antes del cierre: victoria, con el +1.
func test_la_ultima_enemiga_huye_antes_del_cierre() -> void:
	var combate: Combate = _combate("escenario_huida_maestro_victoria.json", ["huye_s1"])
	_declarar(combate)
	assert_bool(combate.terminado()).is_true()
	assert_int(combate.fin()).is_equal(FinCombate.Fin.VICTORIA)
	assert_array(_lineas(combate, "huida")).has_size(1)
	assert_int(_criatura(combate, _SUELTA)["lealtad"]).is_equal(6)


# (7) S-61: la previsualizacion en el turno del Maestro. Las enemigas pendientes
# en el orden de la cola (la tribu no figura); el Tasajero en Caza cuenta sus dos
# golpes; la Ocarra no lo alcanza (falso y 0); la caida de la tribu moriria. Y es
# exacta: el danio recibido hasta el cierre es el danio maximo.
func test_previsualizacion_es_el_peor_caso_aplicado() -> void:
	var combate: Combate = _combate()
	var previa: Dictionary = combate.previsualizar_huida()
	assert_array(previa["enemigas"]).is_equal([
		{"unidad": _TASAJERO, "alcanza": true, "danio": _DANIO_TASAJERO},
		{"unidad": _OCARRA, "alcanza": false, "danio": 0},
		{"unidad": _SURCON, "alcanza": true, "danio": _DANIO_SURCON},
	])
	assert_int(previa["danio_maximo"]).is_equal(_DANIO_TASAJERO + _DANIO_SURCON)
	assert_int(previa["vida"]).is_equal(_VIDA_MAESTRO)
	assert_bool(previa["puede_caer"]).is_false()
	assert_array(previa["caidas"]).is_equal([_CAIDA])
	var desde: int = combate.registro().lineas().size()
	_declarar(combate)
	_hasta_el_fin(combate)
	assert_int(_danio_al_maestro(combate, desde)).is_equal(previa["danio_maximo"])


# (7) Previsualizar no cambia la instantanea, el registro ni el generador.
func test_previsualizar_no_cambia_nada() -> void:
	var combate: Combate = _combate()
	var antes: String = JSON.stringify([combate.instantanea(), combate.registro().lineas(),
			combate.contexto().azar_combate.historial()])
	combate.previsualizar_huida()
	combate.previsualizar_huida()
	assert_str(JSON.stringify([combate.instantanea(), combate.registro().lineas(),
			combate.contexto().azar_combate.historial()])).is_equal(antes)


# (7) Solo cuentan las entradas pendientes: en el turno de rodauva_1, el Tasajero
# y la Ocarra ya jugaron y queda el Surcon.
func test_solo_las_pendientes() -> void:
	var combate: Combate = _combate()
	_declarar(combate)
	assert_str(combate.turno_actual().unidad_id).is_equal(_SUELTA)
	var previa: Dictionary = combate.previsualizar_huida()
	assert_array(previa["enemigas"]).is_equal([{"unidad": _SURCON, "alcanza": true, "danio": _DANIO_SURCON}])
	assert_int(previa["danio_maximo"]).is_equal(_DANIO_SURCON)
	assert_int(previa["vida"]).is_equal(_VIDA_MAESTRO - _DANIO_TASAJERO)


# (8) Registro: la accion huir, y al cierre fin huida y cierre. La partida se
# graba, valida contra el esquema, pasa por JSON y se reproduce con el mismo
# registro y la misma instantanea.
func test_grabacion_se_reproduce_igual() -> void:
	var en_vivo: Combate = _combate()
	_declarar(en_vivo)
	_hasta_el_fin(en_vivo)
	var acciones: Array[Dictionary] = _lineas(en_vivo, "accion").filter(func(linea: Dictionary) -> bool:
			return linea["accion"]["tipo"] == "huir")
	assert_array(acciones).has_size(1)
	assert_str(acciones[0]["unidad"]).is_equal(Maestro.ID)
	var grabacion: Dictionary = Grabacion.desde_combate(en_vivo).a_diccionario()
	var esquema: Dictionary = Cargador.new().esquema_resuelto(_CARPETA_DATOS, "grabacion")["esquema"]
	var leida: Dictionary = Validador.new().validar(JSON.parse_string(JSON.stringify(grabacion)), esquema, "grabacion")
	assert_array(leida["errores"] as Array).override_failure_message(str(leida["errores"])).is_empty()
	var tipos: Array = (leida["datos"]["acciones"] as Array).map(func(a: Dictionary) -> String: return a["accion"]["tipo"])
	assert_bool(tipos.has("huir")).is_true()
	var reproduccion: Reproductor = Reproductor.reproducir(Grabacion.desde_diccionario(leida["datos"]), _datos())
	assert_str(reproduccion.error).is_empty()
	assert_array(reproduccion.combate.registro().lineas_json()).is_equal(en_vivo.registro().lineas_json())
	assert_dict(reproduccion.combate.instantanea()).is_equal(en_vivo.instantanea())


# (9) El resultado con desenlace huida valida contra el esquema y la metrica 11
# da causa huida a la muerta.
func test_resultado_y_metrica_11() -> void:
	var combate: Combate = _combate()
	_declarar(combate)
	_hasta_el_fin(combate)
	var resultado: Dictionary = combate.resultado().a_diccionario()
	assert_str(resultado["desenlace"]).is_equal("huida")
	assert_bool(resultado["maestro_caido"]).is_false()
	assert_array(resultado["metricas"]["muertes"]).is_equal([{"unidad": _CAIDA, "causa": "huida"}])
	var esquema: Dictionary = Cargador.new().esquema_resuelto(_CARPETA_DATOS, "resultado")["esquema"]
	var errores: Array = Validador.new().validar(resultado, esquema, "resultado")["errores"]
	assert_array(errores).override_failure_message(str(errores)).is_empty()
