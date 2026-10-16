extends GdUnitTestSuite

# Arquitectura.md B.4 (T46, D-017), criterios 1, 2, 4 a 6 y 8, con fixtures
# (A.6). Sistema.md 11.7 v1.8 (S-63): la huida declarada termina justo antes del
# proximo turno del Maestro, asi que cada unidad del tablero actua una vez mas
# (las que faltan en la ronda y, en la siguiente, las que van antes que el). Si
# en el medio se cierra una ronda, rigen sus efectos (hambre de combate, corte de
# la cadena). S-60 y S-61 no cambian salvo esa ventana.
# escenario_huida_una_vuelta.json: Ocarra (7), rodauva_1 (6), Maestro (5),
# Surcon (2); la Ocarra y el Surcon le pegan al Maestro. Los criterios 3 y 5 usan
# escenario_huida_maestro_combate.json con el Maestro primero (Velocidad 9).
const _CARPETA: String = "res://pruebas/fixtures/combate/"
const _CARPETA_DATOS: String = "res://datos"
const _ESCENARIO: String = "escenario_huida_una_vuelta.json"
const _OCARRA: String = "ocarra_s1"
const _SURCON: String = "surcon_s1"
const _SUELTA: String = "rodauva_1"
const _VELOCIDAD_PRIMERO: int = 9
const _TOPE_ACCIONES: int = 30


# hambre_cada: las rondas del hambre de combate (0 = la del fixture).
# velocidad_maestro: 0 = la del fixture.
func _datos(hambre_cada: int = 0, velocidad_maestro: int = 0) -> Dictionary:
	var lectura: Dictionary = DatosFixture.cargar()
	var errores: Array[Dictionary] = lectura["errores"]
	assert_array(errores).override_failure_message(str(errores)).is_empty()
	var datos: Dictionary = lectura["datos"]
	if hambre_cada > 0:
		datos["tablas/hambre.json"]["combate"]["cada_rondas"] = hambre_cada
	if velocidad_maestro > 0:
		datos["maestro.json"]["velocidad"] = velocidad_maestro
	return datos


# enemigas: los ids que quedan ([] = todas). vida y mana del Maestro bajados a
# mano antes de empezar (-1 = los del escenario).
func _combate(enemigas: Array[String] = [], datos: Dictionary = {}, vida: int = -1, mana: int = -1,
		archivo: String = _ESCENARIO) -> Combate:
	var escenario: Dictionary = LectorFixture.leer(_CARPETA + archivo, "escenario")["datos"]
	if not enemigas.is_empty():
		escenario["enemigas"] = (escenario["enemigas"] as Array).filter(func(enemiga: Dictionary) -> bool:
				return enemigas.has(enemiga["id"]))
	var contexto: ContextoCombate = ContextoCombate.armar(escenario, _datos() if datos.is_empty() else datos)
	assert_bool(contexto.valido).is_true()
	if vida >= 0:
		contexto.plantel.maestro.vida = vida
	if mana >= 0:
		contexto.plantel.maestro.mana = mana
	var combate: Combate = Combate.empezar(contexto)
	assert_str(combate.error()).is_empty()
	return combate


func _aplicar_valida(combate: Combate, accion: Accion) -> ResultadoAccion:
	var resultado: ResultadoAccion = combate.aplicar(accion)
	assert_bool(resultado.valida).override_failure_message("%s: %s" % [str(accion.a_diccionario()),
			ResultadoAccion.Motivo.keys()[resultado.motivo]]).is_true()
	assert_str(combate.error()).is_empty()
	return resultado


# Termina los turnos del jugador hasta el del Maestro de la ronda 1.
func _hasta_el_maestro(combate: Combate) -> void:
	for _i in range(_TOPE_ACCIONES):
		if combate.turno_actual().unidad_id == Maestro.ID:
			break
		_aplicar_valida(combate, Accion.terminar())
	assert_str(combate.turno_actual().unidad_id).is_equal(Maestro.ID)
	assert_int(combate.instantanea()["ronda"]).is_equal(1)


# Declara la huida (y termina el turno). Devuelve la linea desde la que mirar.
func _declarar(combate: Combate) -> int:
	_hasta_el_maestro(combate)
	var desde: int = combate.registro().lineas().size()
	_aplicar_valida(combate, Accion.huir())
	_aplicar_valida(combate, Accion.terminar())
	return desde


func _hasta_el_fin(combate: Combate) -> void:
	for _i in range(_TOPE_ACCIONES):
		if combate.terminado():
			return
		_aplicar_valida(combate, Accion.terminar())
	assert_bool(combate.terminado()).is_true()


func _desde(combate: Combate, desde: int) -> Array[Dictionary]:
	return combate.registro().lineas().slice(desde)


func _tipos(lineas: Array[Dictionary]) -> Array:
	return lineas.map(func(linea: Dictionary) -> String: return linea["tipo"])


# Las unidades de los eventos `turno`, en orden.
func _turnos(lineas: Array[Dictionary]) -> Array:
	return lineas.filter(func(linea: Dictionary) -> bool: return linea["tipo"] == "turno") \
			.map(func(linea: Dictionary) -> String: return linea["unidad"])


func _danio_al_maestro(lineas: Array[Dictionary]) -> int:
	var total: int = 0
	for linea: Dictionary in lineas:
		if linea["tipo"] == "ataque" and linea["objetivo"] == Maestro.ID:
			total += (linea["vida_antes"] as int) - (linea["vida_despues"] as int)
	return total


func _criatura(combate: Combate, unidad_id: String) -> Dictionary:
	for criatura: Dictionary in combate.instantanea()["criaturas"]:
		if criatura["id"] == unidad_id:
			return criatura
	return {}


# (1) 11.7 v1.8: el Maestro es el ultimo de la ronda (sin el Surcon). Regenera en
# la ronda 1 y declara; la ronda cierra con el hambre de combate (7.2), en la 2
# actuan la Ocarra y rodauva_1 y el combate termina en huida antes de su turno,
# sin el evento mana de la regeneracion.
func test_ultimo_de_la_ronda() -> void:
	var combate: Combate = _combate([_OCARRA], _datos(1), -1, 0)
	_hasta_el_maestro(combate)
	var regeneraciones: Array = combate.registro().lineas().filter(func(linea: Dictionary) -> bool:
			return linea["tipo"] == "mana" and linea["unidad"] == Maestro.ID)
	assert_array(regeneraciones).has_size(1)
	var mana: int = combate.instantanea()["maestro"]["mana"]
	var desde: int = _declarar(combate)
	_hasta_el_fin(combate)
	assert_int(combate.fin()).is_equal(FinCombate.Fin.HUIDA)
	var lineas: Array[Dictionary] = _desde(combate, desde)
	var tipos: Array = _tipos(lineas)
	var fin_ronda: int = tipos.find("fin_ronda")
	assert_array(tipos.slice(fin_ronda, fin_ronda + 3)).is_equal(["fin_ronda", "hambre_combate", "ronda"])
	assert_array(_turnos(lineas)).is_equal([_OCARRA, _SUELTA])
	assert_array(tipos.slice(-2)).is_equal(["fin", "cierre"])
	assert_int(lineas[-2]["ronda"]).is_equal(2)
	assert_str(lineas[-2]["desenlace"]).is_equal("huida")
	for linea: Dictionary in lineas:
		assert_bool(linea["tipo"] == "mana" and linea["unidad"] == Maestro.ID).is_false()
	assert_int(combate.instantanea()["maestro"]["mana"]).is_equal(mana)
	assert_bool(combate.instantanea()["maestro"]["se_fue"]).is_true()


# (2) 11.7 v1.8: declara con el Surcon pendiente. Actua el Surcon, cierra la
# ronda y en la 2 actuan la Ocarra y rodauva_1: cada una una sola vez.
func test_con_enemigas_pendientes() -> void:
	var combate: Combate = _combate()
	var desde: int = _declarar(combate)
	_hasta_el_fin(combate)
	assert_int(combate.fin()).is_equal(FinCombate.Fin.HUIDA)
	var lineas: Array[Dictionary] = _desde(combate, desde)
	var tipos: Array = _tipos(lineas)
	assert_array(_turnos(lineas)).is_equal([_SURCON, _OCARRA, _SUELTA])
	var turnos: Array[int] = []
	for indice in range(lineas.size()):
		if lineas[indice]["tipo"] == "turno":
			turnos.append(indice)
	var fin_ronda: int = tipos.find("fin_ronda")
	assert_bool(turnos[0] < fin_ronda and fin_ronda < turnos[1]).is_true()
	assert_array(tipos.filter(func(tipo: String) -> bool: return tipo == "fin_ronda")).has_size(1)
	assert_array(tipos.slice(-2)).is_equal(["fin", "cierre"])
	assert_int(combate.instantanea()["ronda"]).is_equal(2)


# (4) 11.7: el Maestro cae antes de irse (el golpe de la Ocarra en la ronda 2):
# derrota por caida, con el rescate de rodauva_1 (lealtad 7, 11.5). La vida es la
# justa: el danio que recibe en la partida del test 2.
func test_cae_antes_de_irse() -> void:
	var referencia: Combate = _combate()
	_declarar(referencia)
	_hasta_el_fin(referencia)
	var vida: int = _danio_al_maestro(referencia.registro().lineas())
	assert_int(vida).is_greater(0)

	var combate: Combate = _combate([], {}, vida)
	_hasta_el_maestro(combate)
	assert_bool(combate.previsualizar_huida()["puede_caer"]).is_true()
	_declarar(combate)
	_hasta_el_fin(combate)
	assert_int(combate.fin()).is_equal(FinCombate.Fin.DERROTA_POR_CAIDA)
	assert_int(combate.instantanea()["ronda"]).is_equal(2)
	assert_bool(combate.instantanea()["maestro"]["se_fue"]).is_false()
	var rescates: Array = combate.registro().lineas().filter(func(linea: Dictionary) -> bool:
			return linea["tipo"] == "rescate")
	assert_array(rescates).has_size(1)
	assert_str(rescates[0]["rescatista"]).is_equal(_SUELTA)


# (5) 10.2 y 11.7 v1.8: el Maestro primero (Velocidad 9) y solo la Ocarra. Tras
# declarar, rodauva_1 empieza una cadena contra la Ocarra; la ronda cierra y la
# corta con fin_ronda, y el Maestro se va al empezar la 2.
func test_la_cadena_se_corta_con_fin_ronda() -> void:
	var combate: Combate = _combate([_OCARRA], _datos(0, _VELOCIDAD_PRIMERO), -1, -1,
			"escenario_huida_maestro_combate.json")
	assert_str(combate.turno_actual().unidad_id).is_equal(Maestro.ID)
	var desde: int = combate.registro().lineas().size()
	_aplicar_valida(combate, Accion.huir())
	_aplicar_valida(combate, Accion.terminar())
	assert_str(combate.turno_actual().unidad_id).is_equal(_SUELTA)
	var turno: Turno = combate.turno_actual()
	var pasos: Dictionary = turno.pasos_para_mover()
	var mejor: Vector2i = Criatura.SIN_POSICION
	for casilla: Vector2i in pasos.keys():
		if turno.previsualizar_ataque(casilla, _OCARRA).valida \
				and (mejor == Criatura.SIN_POSICION or pasos[casilla] < pasos[mejor]):
			mejor = casilla
	assert_that(mejor).is_not_equal(Criatura.SIN_POSICION)
	if pasos[mejor] > 0:
		_aplicar_valida(combate, Accion.mover(mejor))
	assert_int(_aplicar_valida(combate, Accion.atacar(_OCARRA)).eslabon).is_equal(1)
	assert_object(combate.instantanea()["cadena"]).is_not_null()
	_hasta_el_fin(combate)
	assert_int(combate.fin()).is_equal(FinCombate.Fin.HUIDA)
	var lineas: Array[Dictionary] = _desde(combate, desde)
	assert_array(_tipos(lineas).slice(-5)).is_equal(["fin_ronda", "cadena_cortada", "ronda", "fin", "cierre"])
	assert_str(lineas[-4]["motivo"]).is_equal(Cadena.MOTIVO_FIN_RONDA)


# (6) S-61 con la ventana de 11.7 v1.8: en el turno del Maestro, las enemigas
# que actuan antes de que se vaya son el Surcon (esta ronda) y la Ocarra (la
# siguiente, antes que el), en ese orden. Son exactamente las que despues tienen
# turno, y el danio recibido no supera el maximo previsto.
func test_previsualizacion_es_el_peor_caso_aplicado() -> void:
	var combate: Combate = _combate()
	_hasta_el_maestro(combate)
	var previa: Dictionary = combate.previsualizar_huida()
	var unidades: Array = (previa["enemigas"] as Array).map(func(enemiga: Dictionary) -> String:
			return enemiga["unidad"])
	assert_array(unidades).is_equal([_SURCON, _OCARRA])
	for enemiga: Dictionary in previa["enemigas"]:
		assert_bool(enemiga["alcanza"]).is_true()
	var desde: int = _declarar(combate)
	_hasta_el_fin(combate)
	var lineas: Array[Dictionary] = _desde(combate, desde)
	var enemigas: Array = _turnos(lineas).filter(func(unidad: String) -> bool: return unidad != _SUELTA)
	assert_array(enemigas).is_equal(unidades)
	assert_int(_danio_al_maestro(lineas)).is_less_equal(previa["danio_maximo"])
	assert_int(_danio_al_maestro(lineas)).is_greater(0)


# (6) Previsualizar no cambia la instantanea, el registro, la cola ni el generador.
func test_previsualizar_no_cambia_nada() -> void:
	var combate: Combate = _combate()
	_hasta_el_maestro(combate)
	var antes: String = JSON.stringify([combate.instantanea(), combate.registro().lineas(),
			combate.cola().map(func(entrada: EntradaCola) -> String: return entrada.unidad_id),
			combate.contexto().azar_combate.historial()])
	combate.previsualizar_huida()
	combate.previsualizar_huida()
	assert_str(JSON.stringify([combate.instantanea(), combate.registro().lineas(),
			combate.cola().map(func(entrada: EntradaCola) -> String: return entrada.unidad_id),
			combate.contexto().azar_combate.historial()])).is_equal(antes)


# (8) La partida de dos rondas se graba, valida contra el esquema, pasa por JSON
# y se reproduce con el mismo registro y la misma instantanea; el resultado valida.
func test_grabacion_y_resultado() -> void:
	var en_vivo: Combate = _combate()
	_declarar(en_vivo)
	_hasta_el_fin(en_vivo)
	var grabacion: Dictionary = Grabacion.desde_combate(en_vivo).a_diccionario()
	var esquema: Dictionary = Cargador.new().esquema_resuelto(_CARPETA_DATOS, "grabacion")["esquema"]
	var leida: Dictionary = Validador.new().validar(JSON.parse_string(JSON.stringify(grabacion)), esquema, "grabacion")
	assert_array(leida["errores"] as Array).override_failure_message(str(leida["errores"])).is_empty()
	var reproduccion: Reproductor = Reproductor.reproducir(Grabacion.desde_diccionario(leida["datos"]), _datos())
	assert_str(reproduccion.error).is_empty()
	assert_array(reproduccion.combate.registro().lineas_json()).is_equal(en_vivo.registro().lineas_json())
	assert_dict(reproduccion.combate.instantanea()).is_equal(en_vivo.instantanea())

	var resultado: Dictionary = en_vivo.resultado().a_diccionario()
	assert_str(resultado["desenlace"]).is_equal("huida")
	var esquema_resultado: Dictionary = Cargador.new().esquema_resuelto(_CARPETA_DATOS, "resultado")["esquema"]
	var errores: Array = Validador.new().validar(resultado, esquema_resultado, "resultado")["errores"]
	assert_array(errores).override_failure_message(str(errores)).is_empty()
	assert_str(_criatura(en_vivo, _SUELTA)["estado"]).is_equal("suelta")
