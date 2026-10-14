extends GdUnitTestSuite

# Arquitectura.md B.4 (T30, sesion 2), criterios 9 a 14: el destino de la atacante
# nocturna dentro del Combate, con fixtures (A.6). escenario_destino_combate.json
# con la Ocarra atacante en 0 (MesaDestino): victoria sin rondas y destino
# pendiente. Sistema.md 9.3, 4.4, 2.3, 5.2 (suma y recorte unicos, S-65) y P-002;
# A.7 (registro) y D-005 (consultas = validar = aplicar). Lealtades de partida:
# leal 8, neutral 6, la de 10, la afin 5 y la guardada 6 (balanza 2: Leal desde 7).
const _CARPETA_DATOS: String = "res://datos"


func _pendiente(escenario: Dictionary = {}, mana: int = -1) -> Combate:
	var combate: Combate = MesaDestino.combate(escenario, mana)
	assert_str(combate.error()).is_empty()
	assert_bool(combate.esperando_destino()).is_true()
	return combate


func _aplicar_valida(combate: Combate, accion: Accion) -> ResultadoAccion:
	var resultado: ResultadoAccion = combate.aplicar(accion)
	assert_bool(resultado.valida).override_failure_message("%s: %s" % [str(accion.a_diccionario()),
			ResultadoAccion.Motivo.keys()[resultado.motivo]]).is_true()
	assert_str(combate.error()).is_empty()
	return resultado


func _rechazada(combate: Combate, accion: Accion, motivo: ResultadoAccion.Motivo) -> void:
	var foto: Dictionary = combate.instantanea()
	var lineas: int = combate.registro().lineas().size()
	var grabadas: int = combate.acciones_jugador().size()
	var resultado: ResultadoAccion = combate.aplicar(accion)
	assert_bool(resultado.valida).override_failure_message(str(accion.a_diccionario())).is_false()
	assert_str(ResultadoAccion.Motivo.keys()[resultado.motivo]).is_equal(ResultadoAccion.Motivo.keys()[motivo])
	assert_dict(combate.instantanea()).is_equal(foto)
	assert_int(combate.registro().lineas().size()).is_equal(lineas)
	assert_int(combate.acciones_jugador().size()).is_equal(grabadas)


func _valida_esquema(valor: Dictionary, nombre: String) -> Dictionary:
	var esquema: Dictionary = Cargador.new().esquema_resuelto(_CARPETA_DATOS, nombre)["esquema"]
	var leida: Dictionary = Validador.new().validar(JSON.parse_string(JSON.stringify(valor)), esquema, nombre)
	assert_array(leida["errores"] as Array).override_failure_message(str(leida["errores"])).is_empty()
	return leida


# (9) Victoria con la atacante caida: terminado, esperando el destino, y toda otra
# accion se rechaza sin cambios. Mientras espera, el resultado la deja pendiente y
# la lealtad de la noche todavia no se aplico (el cierre la deja abierta, S-65).
func test_victoria_con_la_atacante_caida_espera_el_destino() -> void:
	var combate: Combate = _pendiente()
	assert_bool(combate.terminado()).is_true()
	assert_int(combate.fin()).is_equal(FinCombate.Fin.VICTORIA)
	assert_bool(combate.esperando_jugador()).is_false()
	assert_int(MesaDestino.criatura(combate, MesaDestino.ATACANTE).estado).is_equal(Criatura.Estado.CAIDA)
	for accion in [Accion.terminar(), Accion.atacar(MesaDestino.ATACANTE), Accion.huir(),
			Accion.sellar(MesaDestino.ATACANTE), Accion.mover(Vector2i(3, 5))]:
		_rechazada(combate, accion, ResultadoAccion.Motivo.COMBATE_TERMINADO)
	assert_bool(combate.esperando_destino()).is_true()
	var resultado: Dictionary = combate.resultado().a_diccionario()
	assert_str(resultado["atacante_pendiente"]).is_equal(MesaDestino.ATACANTE)
	assert_object(resultado["destino_atacante"]).is_null()
	assert_array(resultado["lealtad_cambios"]).is_empty()
	_valida_esquema(resultado, "resultado")
	assert_dict(MesaDestino.lealtades(combate)).is_equal({MesaDestino.LEAL: 8, MesaDestino.NEUTRAL: 6,
			MesaDestino.DE_DIEZ: 10, MesaDestino.AFIN: 5, MesaDestino.GUARDADA: 6})
	var cierre: Array[Dictionary] = MesaDestino.lineas_desde(combate, "cierre")
	assert_int(cierre.size()).is_equal(1)
	assert_array(cierre[0]["lealtad"]).is_empty()


# (9) Sin destino pendiente, la accion de destino se rechaza: con el combate en
# curso (tambien en el Turno, que no la toma por terminar), con la derrota y
# despues de resolverlo.
func test_sin_destino_pendiente_se_rechaza() -> void:
	var en_curso: Combate = MesaDestino.combate(MesaDestino.escenario(false))
	assert_bool(en_curso.esperando_jugador()).is_true()
	assert_bool(en_curso.esperando_destino()).is_false()
	assert_int(en_curso.motivo_destino(DestinoAtacante.OPCION_PERDONAR)) \
			.is_equal(ResultadoAccion.Motivo.SIN_DESTINO_PENDIENTE)
	_rechazada(en_curso, Accion.destino_atacante(DestinoAtacante.OPCION_PERDONAR),
			ResultadoAccion.Motivo.SIN_DESTINO_PENDIENTE)
	var en_turno: ResultadoAccion = en_curso.turno_actual().validar(Accion.destino_atacante(DestinoAtacante.OPCION_COMER))
	assert_bool(en_turno.valida).is_false()
	assert_int(en_turno.motivo).is_equal(ResultadoAccion.Motivo.SIN_DESTINO_PENDIENTE)
	assert_bool(en_curso.turno_actual().terminado).is_false()

	var derrota: Combate = MesaDestino.combate(MesaDestino.escenario(false), -1, {}, 0)
	assert_int(derrota.fin()).is_equal(FinCombate.Fin.DERROTA_POR_CAIDA)
	assert_bool(derrota.esperando_destino()).is_false()
	_rechazada(derrota, Accion.destino_atacante(DestinoAtacante.OPCION_COMER),
			ResultadoAccion.Motivo.SIN_DESTINO_PENDIENTE)

	var resuelto: Combate = _pendiente()
	_aplicar_valida(resuelto, Accion.destino_atacante(DestinoAtacante.OPCION_PERDONAR))
	assert_bool(resuelto.esperando_destino()).is_false()
	_rechazada(resuelto, Accion.destino_atacante(DestinoAtacante.OPCION_COMER),
			ResultadoAccion.Motivo.SIN_DESTINO_PENDIENTE)


# (9) Una opcion que no existe.
func test_opcion_invalida() -> void:
	var combate: Combate = _pendiente()
	assert_int(combate.motivo_destino("liberar")).is_equal(ResultadoAccion.Motivo.OPCION_INVALIDA)
	_rechazada(combate, Accion.destino_atacante("liberar"), ResultadoAccion.Motivo.OPCION_INVALIDA)


# (10) Perdonar: se va libre (fuera), su pergamino arde y +1 solo a las leales,
# medidas antes de la victoria (S-65): la neutral de 6, que con la victoria llega
# a 7, no lo recibe. La de 10 queda en 10 (10 + 1 + 1, un recorte). La guardada no cambia.
func test_perdonar() -> void:
	var combate: Combate = _pendiente()
	_aplicar_valida(combate, Accion.destino_atacante(DestinoAtacante.OPCION_PERDONAR))
	var atacante: Criatura = MesaDestino.criatura(combate, MesaDestino.ATACANTE)
	assert_int(atacante.estado).is_equal(Criatura.Estado.FUERA)
	assert_that(atacante.posicion).is_equal(Criatura.SIN_POSICION)
	assert_str(atacante.pergamino_id).is_empty()
	assert_int(MesaDestino.pergamino(combate, MesaDestino.PERGAMINO_ATACANTE).estado).is_equal(Pergamino.Estado.ARDIDO)
	assert_int(MesaDestino.pergamino(combate, MesaDestino.PERGAMINO_EN_BLANCO).estado) \
			.is_equal(Pergamino.Estado.EN_BLANCO)
	assert_dict(MesaDestino.lealtades(combate)).is_equal({MesaDestino.LEAL: 10, MesaDestino.NEUTRAL: 7,
			MesaDestino.DE_DIEZ: 10, MesaDestino.AFIN: 6, MesaDestino.GUARDADA: 6})
	assert_dict(MesaDestino.motivos(combate)).is_equal({
		MesaDestino.LEAL: ["victoria", "perdon_a_leales"],
		MesaDestino.NEUTRAL: ["victoria"],
		MesaDestino.DE_DIEZ: ["victoria", "perdon_a_leales"],
		MesaDestino.AFIN: ["victoria"],
	})
	var resultado: Dictionary = combate.resultado().a_diccionario()
	assert_dict(resultado["destino_atacante"]).is_equal({"opcion": "perdonar", "resultado": "perdonada"})
	assert_object(resultado["atacante_pendiente"]).is_null()
	assert_array(resultado["pergaminos"]["ardidos"]).contains_exactly([MesaDestino.PERGAMINO_ATACANTE])
	_valida_esquema(resultado, "resultado")


# (11) Sin pergamino en blanco o sin mana: rechazo sin cambios, y el destino
# sigue pendiente. Las otras dos opciones siguen valiendo.
func test_sellar_sin_pergamino_o_sin_mana() -> void:
	var sin_blanco: Dictionary = MesaDestino.escenario()
	sin_blanco["pergaminos_en_blanco"] = 0
	var combate: Combate = _pendiente(sin_blanco)
	assert_int(combate.motivo_destino(DestinoAtacante.OPCION_SELLAR)).is_equal(ResultadoAccion.Motivo.SIN_PERGAMINO)
	_rechazada(combate, Accion.destino_atacante(DestinoAtacante.OPCION_SELLAR), ResultadoAccion.Motivo.SIN_PERGAMINO)
	assert_bool(combate.esperando_destino()).is_true()
	assert_int(combate.motivo_destino(DestinoAtacante.OPCION_COMER)).is_equal(ResultadoAccion.Motivo.NINGUNO)

	var sin_mana: Combate = _pendiente({}, 1)
	assert_int(sin_mana.motivo_destino(DestinoAtacante.OPCION_SELLAR)).is_equal(ResultadoAccion.Motivo.MANA_INSUFICIENTE)
	_rechazada(sin_mana, Accion.destino_atacante(DestinoAtacante.OPCION_SELLAR),
			ResultadoAccion.Motivo.MANA_INSUFICIENTE)
	assert_bool(sin_mana.esperando_destino()).is_true()
	# Con el costo justo (2) alcanza.
	assert_int(_pendiente({}, 2).motivo_destino(DestinoAtacante.OPCION_SELLAR)).is_equal(ResultadoAccion.Motivo.NINGUNO)


# (11) Sellar de nuevo con la semilla del fixture (tiro 54 con 80 %): paga 2, ocupa
# el pergamino en blanco y queda guardada de la tribu, con lealtad 1 (balanza 2) y
# la vida al resellar (1 en el fixture, P-046). Su pergamino viejo arde. La
# lealtad de la noche es solo la victoria.
func test_sellar_de_nuevo_sale() -> void:
	var combate: Combate = _pendiente()
	var resultado_accion: ResultadoAccion = _aplicar_valida(combate, Accion.destino_atacante(DestinoAtacante.OPCION_SELLAR))
	assert_int(resultado_accion.costo).is_equal(2)
	assert_int(resultado_accion.porcentaje).is_equal(80)
	assert_bool(combate.esperando_destino()).is_false()
	var atacante: Criatura = MesaDestino.criatura(combate, MesaDestino.ATACANTE)
	assert_int(atacante.estado).is_equal(Criatura.Estado.GUARDADA)
	assert_int(atacante.bando).is_equal(Criatura.Bando.TRIBU)
	assert_int(atacante.comportamiento).is_equal(Criatura.Comportamiento.NINGUNO)
	assert_that(atacante.posicion).is_equal(Criatura.SIN_POSICION)
	assert_int(atacante.lealtad).is_equal(1)
	assert_int(atacante.vida).is_equal(1)
	assert_str(atacante.pergamino_id).is_equal(MesaDestino.PERGAMINO_EN_BLANCO)
	var nuevo: Pergamino = MesaDestino.pergamino(combate, MesaDestino.PERGAMINO_EN_BLANCO)
	assert_int(nuevo.estado).is_equal(Pergamino.Estado.OCUPADO)
	assert_str(nuevo.ocupante_id).is_equal(MesaDestino.ATACANTE)
	assert_int(MesaDestino.pergamino(combate, MesaDestino.PERGAMINO_ATACANTE).estado).is_equal(Pergamino.Estado.ARDIDO)
	assert_int(combate.contexto().plantel.maestro.mana).is_equal(6)
	assert_dict(MesaDestino.lealtades(combate)).is_equal({MesaDestino.LEAL: 9, MesaDestino.NEUTRAL: 7,
			MesaDestino.DE_DIEZ: 10, MesaDestino.AFIN: 6, MesaDestino.GUARDADA: 6})
	var resultado: Dictionary = combate.resultado().a_diccionario()
	assert_dict(resultado["destino_atacante"]).is_equal({"opcion": "sellar", "resultado": "sellada"})
	assert_int(resultado["pergaminos"]["en_blanco"]).is_equal(0)
	assert_int(resultado["maestro"]["mana"]).is_equal(6)
	_valida_esquema(resultado, "resultado")


# (11) Con 90 falla: el mana se pierde, sigue caida y pendiente, el pergamino en
# blanco no se gasta y desde ahi solo valen perdonar y comer.
func test_sellar_de_nuevo_falla_y_quedan_perdonar_y_comer() -> void:
	var escenario: Dictionary = MesaDestino.escenario()
	escenario["semilla"] = MesaDestino.SEMILLA_FALLA
	var combate: Combate = _pendiente(escenario)
	_aplicar_valida(combate, Accion.destino_atacante(DestinoAtacante.OPCION_SELLAR))
	assert_bool(combate.esperando_destino()).is_true()
	assert_int(combate.contexto().plantel.maestro.mana).is_equal(6)
	assert_int(MesaDestino.criatura(combate, MesaDestino.ATACANTE).estado).is_equal(Criatura.Estado.CAIDA)
	assert_int(MesaDestino.pergamino(combate, MesaDestino.PERGAMINO_EN_BLANCO).estado) \
			.is_equal(Pergamino.Estado.EN_BLANCO)
	assert_int(combate.motivo_destino(DestinoAtacante.OPCION_SELLAR)).is_equal(ResultadoAccion.Motivo.SELLAR_YA_FALLO)
	_rechazada(combate, Accion.destino_atacante(DestinoAtacante.OPCION_SELLAR), ResultadoAccion.Motivo.SELLAR_YA_FALLO)
	assert_int(combate.motivo_destino(DestinoAtacante.OPCION_PERDONAR)).is_equal(ResultadoAccion.Motivo.NINGUNO)
	assert_int(combate.motivo_destino(DestinoAtacante.OPCION_COMER)).is_equal(ResultadoAccion.Motivo.NINGUNO)
	# Mientras espera, el resultado sigue pendiente, con el mana ya gastado.
	var pendiente: Dictionary = combate.resultado().a_diccionario()
	assert_str(pendiente["atacante_pendiente"]).is_equal(MesaDestino.ATACANTE)
	assert_object(pendiente["destino_atacante"]).is_null()
	assert_int(pendiente["maestro"]["mana"]).is_equal(6)
	_aplicar_valida(combate, Accion.destino_atacante(DestinoAtacante.OPCION_PERDONAR))
	assert_bool(combate.esperando_destino()).is_false()
	assert_dict(combate.resultado().a_diccionario()["destino_atacante"]).is_equal({"opcion": "perdonar",
			"resultado": "perdonada"})


# (12) y P-002: comer -2 a todas las sueltas, tambien a la afin de la Ocarra (sin
# -4 ni -3). Queda muerta; su pergamino arde. No es una muerte del grupo (metrica 11).
func test_comer() -> void:
	var combate: Combate = _pendiente()
	_aplicar_valida(combate, Accion.destino_atacante(DestinoAtacante.OPCION_COMER))
	var atacante: Criatura = MesaDestino.criatura(combate, MesaDestino.ATACANTE)
	assert_int(atacante.estado).is_equal(Criatura.Estado.MUERTA)
	assert_that(atacante.posicion).is_equal(Criatura.SIN_POSICION)
	assert_int(MesaDestino.pergamino(combate, MesaDestino.PERGAMINO_ATACANTE).estado).is_equal(Pergamino.Estado.ARDIDO)
	assert_dict(MesaDestino.lealtades(combate)).is_equal({MesaDestino.LEAL: 7, MesaDestino.NEUTRAL: 5,
			MesaDestino.DE_DIEZ: 9, MesaDestino.AFIN: 4, MesaDestino.GUARDADA: 6})
	assert_array(MesaDestino.motivos(combate)[MesaDestino.AFIN]).is_equal(["victoria", "comer_atacante"])
	var resultado: Dictionary = combate.resultado().a_diccionario()
	assert_dict(resultado["destino_atacante"]).is_equal({"opcion": "comer", "resultado": "comida"})
	assert_array(resultado["metricas"]["muertes"]).is_empty()
	_valida_esquema(resultado, "resultado")


# (13) 5.2: un solo recorte en la noche. La de 10: +1 de la victoria y -2 de
# comer = 9 (10 + 1 - 2), no 8 (recortar a 10 despues de la victoria y restar 2).
func test_un_solo_recorte_en_la_noche() -> void:
	var combate: Combate = _pendiente()
	_aplicar_valida(combate, Accion.destino_atacante(DestinoAtacante.OPCION_COMER))
	var cambios: Array = combate.resultado().a_diccionario()["lealtad_cambios"]
	var de_diez: Array = cambios.filter(func(c: Dictionary) -> bool: return c["id"] == MesaDestino.DE_DIEZ)
	assert_dict(de_diez[0]).is_equal({"id": MesaDestino.DE_DIEZ, "antes": 10, "cambio": -1, "despues": 9,
			"anotaciones": [{"cambio": 1, "motivo": "victoria"}, {"cambio": -2, "motivo": "comer_atacante"}]})


# (14) A.7: cierre -> accion -> destino_atacante -> estado; al sellar, la accion
# lleva detras su mana (resellar) y su tirada. destino_atacante lleva los cambios
# de lealtad de la noche (vacios en el sellado fallido).
func test_registro_en_el_orden_de_a7() -> void:
	var perdon: Combate = _pendiente()
	_aplicar_valida(perdon, Accion.destino_atacante(DestinoAtacante.OPCION_PERDONAR))
	var lineas: Array[Dictionary] = MesaDestino.lineas_desde(perdon, "cierre")
	assert_array(MesaDestino.tipos(lineas)).is_equal(["cierre", "accion", "destino_atacante", "estado"])
	assert_dict(lineas[1]).is_equal({"tipo": "accion", "unidad": Maestro.ID, "origen": "jugador",
			"accion": {"tipo": "destino_atacante", "opcion": "perdonar"}, "paso": null})
	assert_str(lineas[2]["atacante"]).is_equal(MesaDestino.ATACANTE)
	assert_str(lineas[2]["opcion"]).is_equal("perdonar")
	assert_str(lineas[2]["resultado"]).is_equal("perdonada")
	assert_array(lineas[2]["lealtad"]).is_equal(perdon.resultado().a_diccionario()["lealtad_cambios"])
	assert_dict(lineas[3]).is_equal({"tipo": "estado", "unidad": MesaDestino.ATACANTE, "de": "caida", "a": "fuera"})

	var escenario: Dictionary = MesaDestino.escenario()
	escenario["semilla"] = MesaDestino.SEMILLA_FALLA
	var sellar: Combate = _pendiente(escenario)
	_aplicar_valida(sellar, Accion.destino_atacante(DestinoAtacante.OPCION_SELLAR))
	_aplicar_valida(sellar, Accion.destino_atacante(DestinoAtacante.OPCION_COMER))
	var registro: Array[Dictionary] = MesaDestino.lineas_desde(sellar, "cierre")
	assert_array(MesaDestino.tipos(registro)).is_equal(["cierre", "accion", "mana", "tirada", "destino_atacante",
			"accion", "destino_atacante", "estado"])
	assert_dict(registro[2]).is_equal({"tipo": "mana", "unidad": Maestro.ID, "de": 8, "a": 6, "motivo": "resellar"})
	assert_int(registro[3]["resultado"]).is_equal(90)
	assert_dict(registro[4]).is_equal({"tipo": "destino_atacante", "atacante": MesaDestino.ATACANTE,
			"opcion": "sellar", "resultado": "sellado_fallido", "lealtad": []})
	assert_str(registro[6]["resultado"]).is_equal("comida")
	assert_int((registro[6]["lealtad"] as Array).size()).is_equal(4)
	assert_dict(registro[7]).is_equal({"tipo": "estado", "unidad": MesaDestino.ATACANTE, "de": "caida", "a": "muerta"})

	var sale: Combate = _pendiente()
	_aplicar_valida(sale, Accion.destino_atacante(DestinoAtacante.OPCION_SELLAR))
	var logrado: Array[Dictionary] = MesaDestino.lineas_desde(sale, "cierre")
	assert_array(MesaDestino.tipos(logrado)).is_equal(["cierre", "accion", "mana", "tirada", "destino_atacante", "estado"])
	assert_str(logrado[4]["resultado"]).is_equal("sellada")
	assert_dict(logrado[5]).is_equal({"tipo": "estado", "unidad": MesaDestino.ATACANTE, "de": "caida", "a": "guardada"})


# (14) La accion va y vuelve por diccionario; la grabacion con un sellado fallido
# y comer valida, pasa por JSON y se reproduce con el mismo registro y estado.
func test_grabacion_se_reproduce_igual() -> void:
	var accion: Accion = Accion.destino_atacante(DestinoAtacante.OPCION_SELLAR)
	assert_dict(accion.a_diccionario()).is_equal({"tipo": "destino_atacante", "opcion": "sellar"})
	assert_dict(Accion.desde_diccionario(accion.a_diccionario()).a_diccionario()).is_equal(accion.a_diccionario())
	assert_object(Accion.desde_diccionario({"tipo": "destino_atacante"})).is_null()
	assert_object(Accion.desde_diccionario({"tipo": "destino_atacante", "opcion": 3})).is_null()

	var escenario: Dictionary = MesaDestino.escenario()
	escenario["semilla"] = MesaDestino.SEMILLA_FALLA
	var en_vivo: Combate = _pendiente(escenario)
	_aplicar_valida(en_vivo, Accion.destino_atacante(DestinoAtacante.OPCION_SELLAR))
	_aplicar_valida(en_vivo, Accion.destino_atacante(DestinoAtacante.OPCION_COMER))
	var leida: Dictionary = _valida_esquema(Grabacion.desde_combate(en_vivo).a_diccionario(), "grabacion")
	assert_array(leida["datos"]["acciones"]).is_equal([
		{"unidad": Maestro.ID, "accion": {"tipo": "destino_atacante", "opcion": "sellar"}},
		{"unidad": Maestro.ID, "accion": {"tipo": "destino_atacante", "opcion": "comer"}},
	])
	var reproduccion: Reproductor = Reproductor.reproducir(Grabacion.desde_diccionario(leida["datos"]), MesaDestino.datos())
	assert_str(reproduccion.error).is_empty()
	assert_array(reproduccion.combate.registro().lineas_json()).is_equal(en_vivo.registro().lineas_json())
	assert_dict(reproduccion.combate.instantanea()).is_equal(en_vivo.instantanea())
	assert_dict(reproduccion.combate.resultado().a_diccionario()).is_equal(en_vivo.resultado().a_diccionario())
	# Hasta la primera: el destino sigue pendiente.
	var hasta_una: Reproductor = Reproductor.reproducir(Grabacion.desde_diccionario(leida["datos"]), MesaDestino.datos(), 1)
	assert_str(hasta_una.error).is_empty()
	assert_bool(hasta_una.combate.esperando_destino()).is_true()


# (14) D-005: previsualizar_destino = validar = aplicar en las tres opciones:
# costo, porcentaje, mana y los cambios de lealtad que quedarian, sin cambiar nada.
func test_previsualizar_es_lo_que_se_aplica() -> void:
	for opcion in DestinoAtacante.OPCIONES:
		var combate: Combate = _pendiente()
		var foto: Dictionary = combate.instantanea()
		var lineas: int = combate.registro().lineas().size()
		var previa: ResultadoAccion = combate.previsualizar_destino(opcion)
		assert_bool(previa.valida).is_true()
		assert_dict(combate.instantanea()).is_equal(foto)
		assert_int(combate.registro().lineas().size()).is_equal(lineas)
		var aplicada: ResultadoAccion = _aplicar_valida(combate, Accion.destino_atacante(opcion))
		assert_int(previa.costo).is_equal(aplicada.costo)
		assert_that(previa.porcentaje).is_equal(aplicada.porcentaje)
		assert_dict(previa.mana).is_equal(aplicada.mana)
		assert_array(ResultadoCombate.cambios_a_lista(previa.lealtad)) \
				.is_equal(combate.resultado().a_diccionario()["lealtad_cambios"])
	var sellar: ResultadoAccion = _pendiente().previsualizar_destino(DestinoAtacante.OPCION_SELLAR)
	assert_int(sellar.costo).is_equal(2)
	assert_int(sellar.porcentaje).is_equal(80)
	assert_dict(sellar.mana).is_equal({"de": 8, "a": 6})
	# Un rechazo dice lo mismo que motivo_destino.
	var sin_mana: Combate = _pendiente({}, 1)
	assert_int(sin_mana.previsualizar_destino(DestinoAtacante.OPCION_SELLAR).motivo) \
			.is_equal(sin_mana.motivo_destino(DestinoAtacante.OPCION_SELLAR))
