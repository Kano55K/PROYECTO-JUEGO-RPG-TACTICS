extends GdUnitTestSuite

# Arquitectura.md B.4 (T26), criterios 7, 9, 10 y 11: guardar e invocar dentro
# del Combate y con las reglas de ronda y de cierre, con fixtures (A.6).
# escenario_guardar_invocar_combate.json: Rodauva de la tribu (Vel 6) al oeste
# del Maestro (Vel 5) en [5,1], rodauva_g guardada y un Surcon salvaje (Vel 2)
# que llega a pegarle a [5,2] y no al Maestro. Sistema.md 3.1, 2.3, 11.3 (entra
# en la cola desde la ronda siguiente), 7.2 (hambre de combate), 5.2 y 11.5
# (cierre); A.7 (orden del registro) y D-007 (mana con motivo). Lectura
# declarada S-56. Los criterios 9 y 10 tambien con turnos sueltos (MesaGuardar).
const _CARPETA: String = "res://pruebas/fixtures/combate/"
const _CARPETA_DATOS: String = "res://datos"
const _RODAUVA: String = "rodauva_1"
const _GUARDADA: String = "rodauva_g"
const _SURCON: String = "surcon_s1"
const _CASILLA: Vector2i = Vector2i(5, 2)


func _datos() -> Dictionary:
	var lectura: Dictionary = DatosFixture.cargar()
	var errores: Array[Dictionary] = lectura["errores"]
	assert_array(errores).override_failure_message(str(errores)).is_empty()
	return lectura["datos"]


func _combate() -> Combate:
	var escenario: Dictionary = LectorFixture.leer(_CARPETA + "escenario_guardar_invocar_combate.json",
			"escenario")["datos"]
	var contexto: ContextoCombate = ContextoCombate.armar(escenario, _datos())
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


func _sin_n(linea: Dictionary) -> Dictionary:
	var copia: Dictionary = linea.duplicate(true)
	copia.erase("n")
	copia.erase("ronda")
	return copia


func _tipos(lineas: Array[Dictionary]) -> Array:
	return lineas.map(func(linea: Dictionary) -> String: return linea["tipo"])


# Las rondas en las que la unidad tuvo su evento `turno`.
func _rondas_con_turno(combate: Combate, unidad_id: String) -> Array:
	var rondas: Array = []
	for linea in combate.registro().lineas():
		if linea["tipo"] == "turno" and linea["unidad"] == unidad_id:
			rondas.append(linea["ronda"])
	return rondas


# Ronda 1: la Rodauva se guarda y el Maestro la invoca en [5,2] (S-56). Devuelve
# los indices del registro donde empiezan las dos acciones.
func _guardar_e_invocar(combate: Combate) -> Array[int]:
	assert_str(combate.turno_actual().unidad_id).is_equal(_RODAUVA)
	var guardar: int = combate.registro().lineas().size()
	_aplicar_valida(combate, Accion.guardar())
	assert_str(combate.turno_actual().unidad_id).is_equal(Maestro.ID)
	var invocar: int = combate.registro().lineas().size()
	assert_int(combate.costo_invocar(_RODAUVA)).is_equal(2)
	assert_bool(combate.turno_actual().casillas_para_invocar().has(_CASILLA)).is_true()
	_aplicar_valida(combate, Accion.invocar(_RODAUVA, _CASILLA))
	_aplicar_valida(combate, Accion.terminar())
	return [guardar, invocar]


# (7) La invocada no actua en la ronda en curso y si en la siguiente; el Surcon
# salvaje le pega en la ronda en curso.
func test_ronda_de_entrada() -> void:
	var combate: Combate = _combate()
	_aplicar_valida(combate, Accion.terminar())
	assert_str(combate.turno_actual().unidad_id).is_equal(Maestro.ID)
	_aplicar_valida(combate, Accion.invocar(_GUARDADA, _CASILLA))
	assert_bool(combate.cola().any(func(entrada: EntradaCola) -> bool: return entrada.unidad_id == _GUARDADA)) \
			.is_false()
	_aplicar_valida(combate, Accion.terminar())
	# El Surcon jugo su turno de la ronda 1 y le pego a la invocada.
	var golpes: Array = combate.registro().lineas().filter(func(linea: Dictionary) -> bool:
			return linea["tipo"] == "ataque" and linea["atacante"] == _SURCON)
	assert_int(golpes.size()).is_equal(1)
	assert_str(golpes[0]["objetivo"]).is_equal(_GUARDADA)
	assert_int(golpes[0]["ronda"]).is_equal(1)
	# Ronda 2: la invocada ya esta en la cola y tiene su turno.
	assert_int(combate.instantanea()["ronda"]).is_equal(2)
	assert_bool(combate.cola().any(func(entrada: EntradaCola) -> bool: return entrada.unidad_id == _GUARDADA)) \
			.is_true()
	_aplicar_valida(combate, Accion.terminar())
	assert_str(combate.turno_actual().unidad_id).is_equal(_GUARDADA)
	assert_array(_rondas_con_turno(combate, _GUARDADA)).is_equal([2])


# (7) S-56: la que se guardo en esta ronda se invoca en la misma; no vuelve a
# actuar en esta ronda y si en la siguiente.
func test_guardada_en_la_ronda_se_invoca_en_la_misma() -> void:
	var combate: Combate = _combate()
	_guardar_e_invocar(combate)
	assert_str(combate.error()).is_empty()
	assert_int(combate.instantanea()["ronda"]).is_equal(2)
	assert_str(combate.turno_actual().unidad_id).is_equal(_RODAUVA)
	assert_array(_rondas_con_turno(combate, _RODAUVA)).is_equal([1, 2])


# (11) A.7: guardar: accion -> estado (suelta -> guardada) -> fin_turno sin
# posicion; invocar: accion -> mana (invocar) -> estado (guardada -> suelta) ->
# invocacion.
func test_registro_en_el_orden_de_a7() -> void:
	var combate: Combate = _combate()
	var indices: Array[int] = _guardar_e_invocar(combate)
	var lineas: Array[Dictionary] = combate.registro().lineas()
	var de_guardar: Array[Dictionary] = lineas.slice(indices[0], indices[0] + 3)
	assert_array(_tipos(de_guardar)).is_equal(["accion", "estado", "fin_turno"])
	assert_dict(_sin_n(de_guardar[0])).is_equal({"tipo": "accion", "unidad": _RODAUVA, "origen": "jugador",
			"accion": {"tipo": "guardar"}, "paso": null})
	assert_dict(_sin_n(de_guardar[1])).is_equal({"tipo": "estado", "unidad": _RODAUVA, "de": "suelta",
			"a": "guardada"})
	assert_dict(_sin_n(de_guardar[2])).is_equal({"tipo": "fin_turno", "unidad": _RODAUVA, "posicion": null})
	assert_str(lineas[indices[0] + 3]["tipo"]).is_equal("turno")
	var de_invocar: Array[Dictionary] = lineas.slice(indices[1], indices[1] + 4)
	assert_array(_tipos(de_invocar)).is_equal(["accion", "mana", "estado", "invocacion"])
	assert_dict(_sin_n(de_invocar[0])["accion"]).is_equal({"tipo": "invocar", "criatura": _RODAUVA, "casilla": [5, 2]})
	assert_dict(_sin_n(de_invocar[1])).is_equal({"tipo": "mana", "unidad": Maestro.ID, "de": 8, "a": 6,
			"motivo": "invocar"})
	assert_dict(_sin_n(de_invocar[2])).is_equal({"tipo": "estado", "unidad": _RODAUVA, "de": "guardada",
			"a": "suelta"})
	assert_dict(_sin_n(de_invocar[3])).is_equal({"tipo": "invocacion", "unidad": _RODAUVA, "casilla": [5, 2]})
	assert_str(lineas[indices[1] + 4]["tipo"]).is_equal("accion")


# (11) A.7: el surco_cerrado del Surcon guardado va detras del estado y antes del
# fin_turno (turno suelto con su evento en Surcos; el Combate vuelca el historial).
func test_surco_cerrado_en_el_registro() -> void:
	var escenario: Dictionary = LectorFixture.leer(_CARPETA + "escenario_guardar_invocar_combate.json",
			"escenario")["datos"]
	escenario["tribu"][0]["especie"] = "surcon"
	escenario["tribu"][0]["id"] = "surcon_1"
	escenario["enemigas"][0]["especie"] = "rodauva"
	escenario["enemigas"][0]["id"] = "rodauva_s1"
	var contexto: ContextoCombate = ContextoCombate.armar(escenario, _datos())
	assert_bool(contexto.valido).is_true()
	var combate: Combate = Combate.empezar(contexto)
	# Ronda 1: la Rodauva salvaje (Vel 6) juega primero; despues el Maestro y el Surcon (Vel 2).
	while combate.turno_actual().unidad_id != "surcon_1":
		_aplicar_valida(combate, Accion.terminar())
	_aplicar_valida(combate, Accion.cavar(Vector2i(3, 1)))
	_aplicar_valida(combate, Accion.terminar())
	while combate.turno_actual().unidad_id != "surcon_1":
		_aplicar_valida(combate, Accion.terminar())
	var desde: int = combate.registro().lineas().size()
	_aplicar_valida(combate, Accion.guardar())
	var lineas: Array[Dictionary] = combate.registro().lineas()
	assert_array(_tipos(lineas.slice(desde, desde + 4))).is_equal(["accion", "estado", "surco_cerrado", "fin_turno"])
	assert_str(lineas[desde + 2]["motivo"]).is_equal(Surcos.MOTIVO_DUENIO_FUERA)


# (11) La partida con guardar e invocar se graba, valida contra el esquema, pasa
# por JSON y se reproduce con el mismo registro y la misma instantanea.
func test_grabacion_se_reproduce_igual() -> void:
	var en_vivo: Combate = _combate()
	_guardar_e_invocar(en_vivo)
	_aplicar_valida(en_vivo, Accion.terminar())
	var grabacion: Dictionary = Grabacion.desde_combate(en_vivo).a_diccionario()
	var esquema: Dictionary = Cargador.new().esquema_resuelto(_CARPETA_DATOS, "grabacion")["esquema"]
	var leida: Dictionary = Validador.new().validar(JSON.parse_string(JSON.stringify(grabacion)), esquema, "grabacion")
	assert_array(leida["errores"] as Array).override_failure_message(str(leida["errores"])).is_empty()
	var tipos: Array = (leida["datos"]["acciones"] as Array).map(func(a: Dictionary) -> String: return a["accion"]["tipo"])
	assert_bool(tipos.has("guardar") and tipos.has("invocar")).is_true()
	var reproduccion: Reproductor = Reproductor.reproducir(Grabacion.desde_diccionario(leida["datos"]), _datos())
	assert_str(reproduccion.error).is_empty()
	assert_array(reproduccion.combate.registro().lineas_json()).is_equal(en_vivo.registro().lineas_json())
	assert_dict(reproduccion.combate.instantanea()).is_equal(en_vivo.instantanea())


# (11) Ida y vuelta por diccionario de las dos acciones.
func test_accion_ida_y_vuelta() -> void:
	for accion in [Accion.guardar(), Accion.invocar(_GUARDADA, _CASILLA)]:
		var datos: Dictionary = JSON.parse_string(JSON.stringify(accion.a_diccionario()))
		var vuelta: Accion = Accion.desde_diccionario(datos)
		assert_object(vuelta).is_not_null()
		assert_dict(vuelta.a_diccionario()).is_equal(accion.a_diccionario())
	assert_object(Accion.desde_diccionario({"tipo": "invocar", "criatura": _GUARDADA})).is_null()
	assert_object(Accion.desde_diccionario({"tipo": "guardar", "criatura": _GUARDADA})).is_null()


# (9) Sistema.md 7.2: la invocada en el tablero suma hambre al cerrar la ronda;
# la que se guardo antes del cierre, no (hambre.json de prueba: cada 5 rondas).
func test_hambre_de_combate() -> void:
	var mesa: MesaGuardar = MesaGuardar.new({"rodauva_1": Vector2i(5, 7)})
	assert_bool(mesa.turno("rodauva_1").aplicar(Accion.guardar()).valida).is_true()
	assert_bool(mesa.turno().aplicar(Accion.invocar(_GUARDADA, Vector2i(5, 5))).valida).is_true()
	var hambre: HambreCombate = HambreCombate.desde_datos(DatosFixture.cargar()["datos"]["tablas/hambre.json"])
	var cambios: Array = hambre.cerrar_ronda(5, mesa.plantel)
	var unidades: Array = cambios.map(func(cambio: Dictionary) -> String: return cambio["unidad"])
	assert_bool(unidades.has(_GUARDADA)).is_true()
	assert_bool(unidades.has("rodauva_1")).is_false()
	assert_int(mesa.plantel.criatura("rodauva_1").hambre).is_equal(3)
	# Dentro del Combate: la invocada de la ronda 1 suma al cerrar la 5.
	var combate: Combate = _combate()
	_aplicar_valida(combate, Accion.terminar())
	_aplicar_valida(combate, Accion.invocar(_GUARDADA, Vector2i(6, 1)))
	while not combate.terminado() and combate.instantanea()["ronda"] <= 5:
		_aplicar_valida(combate, Accion.terminar())
	var hambres: Array = combate.registro().lineas().filter(func(linea: Dictionary) -> bool:
			return linea["tipo"] == "hambre_combate")
	assert_int(hambres.size()).is_equal(1)
	var con_cambio: Array = (hambres[0]["cambios"] as Array).map(func(c: Dictionary) -> String: return c["unidad"])
	assert_bool(con_cambio.has(_GUARDADA)).is_true()


func _cierre() -> Cierre:
	var datos: Dictionary = DatosFixture.cargar()["datos"]
	return Cierre.desde_datos(datos["tablas/combate.json"], datos["tablas/lealtad.json"],
			Relaciones.new(datos["relaciones.json"]))


func _con_cambio(resultado: ResultadoCierre) -> Array:
	return resultado.lealtad.map(func(cambio: CambioLealtad) -> String: return cambio.criatura_id)


# (10) Sistema.md 5.2: en una victoria, la guardada no recibe el +1 y la invocada
# (suelta al terminar) si.
func test_cierre_victoria() -> void:
	var mesa: MesaGuardar = MesaGuardar.new({"rodauva_1": Vector2i(5, 7)})
	assert_bool(mesa.turno("rodauva_1").aplicar(Accion.guardar()).valida).is_true()
	assert_bool(mesa.turno().aplicar(Accion.invocar(_GUARDADA, Vector2i(5, 5))).valida).is_true()
	for id_enemiga in ["ocarra_s1", "zancajunco_s1"]:
		VidaCero.sacar_del_tablero(mesa.plantel.criatura(id_enemiga), mesa.surcos)
	var resultado: ResultadoCierre = _cierre().cerrar(mesa.plantel, FinCombate.Fin.VICTORIA)
	assert_bool(resultado.valido).is_true()
	var con_cambio: Array = _con_cambio(resultado)
	assert_bool(con_cambio.has(_GUARDADA)).is_true()
	assert_bool(con_cambio.has("rodauva_1")).is_false()
	assert_int(mesa.plantel.criatura("rodauva_1").lealtad).is_equal(5)


# (10) Sistema.md 11.5: en una derrota, la guardada sigue viva y su pergamino no arde.
func test_cierre_derrota() -> void:
	var mesa: MesaGuardar = MesaGuardar.new({"rodauva_1": Vector2i(5, 7)})
	assert_bool(mesa.turno("rodauva_1").aplicar(Accion.guardar()).valida).is_true()
	mesa.plantel.maestro.vida = 0
	mesa.plantel.maestro.caido = true
	var resultado: ResultadoCierre = _cierre().cerrar(mesa.plantel, FinCombate.Fin.DERROTA_POR_CAIDA)
	assert_bool(resultado.valido).is_true()
	var guardada: Criatura = mesa.plantel.criatura("rodauva_1")
	assert_int(guardada.estado).is_equal(Criatura.Estado.GUARDADA)
	assert_bool(resultado.muertas.has("rodauva_1")).is_false()
	assert_int(mesa.plantel.pergamino(guardada.pergamino_id).estado).is_equal(Pergamino.Estado.OCUPADO)
