extends GdUnitTestSuite

# Arquitectura.md B.4 (T27), criterios 3, 5, 6, 7 y 8: guardar a una caida con
# turnos sueltos y fixtures (A.6). Sistema.md 11.5 (el Maestro gasta su accion y
# el costo, a distancia <= 2; queda guardada con la vida del dato y sobrevive si
# el Maestro cae), 3.1, 2.3, 1.6 (el Remiendo no cura caidas), 7.2 (hambre de
# combate), 5.2 (+1 de victoria) y 11.2.1 (surcos). P-025 (clase CAIDA_PROPIA).
# Lecturas declaradas S-55 (que conserva) y S-57 (Manhattan, sin mirar la linea).
# escenario_guardar_caida.json: el Maestro en [5,6], balanza 2 (reserva 8); el
# combate.json de fixtures deja a la guardada con 1 de vida (D-009).
const _ESCENARIO: String = "escenario_guardar_caida.json"
const _VIDA_FIXTURE: int = 1
const _COSTO_RODAUVA: int = 2


func _mesa(ubicar: Dictionary = {}) -> MesaGuardar:
	return MesaGuardar.new(ubicar, _ESCENARIO)


# Sistema.md 11.5: la unidad llega a 0 en `casilla` por el mismo camino que un golpe.
func _tumbar(mesa: MesaGuardar, unidad_id: String, casilla: Vector2i) -> void:
	var criatura: Criatura = mesa.plantel.criatura(unidad_id)
	criatura.posicion = casilla
	criatura.vida = 0
	VidaCero.resolver(unidad_id, mesa.plantel, mesa.surcos)


func _nombre(motivo: ResultadoAccion.Motivo) -> String:
	return ResultadoAccion.Motivo.keys()[motivo]


# Aplica guardar a la caida, que tiene que rechazarse con `motivo`, y comprueba
# que no cambio nada; la previsualizacion dice lo mismo.
func _rechazada(mesa: MesaGuardar, turno: Turno, objetivo_id: String, motivo: String) -> void:
	var antes: String = mesa.foto(turno)
	assert_str(MesaGuardar.motivo(turno.previsualizar_guardar_caida(objetivo_id))).is_equal(motivo)
	var resultado: ResultadoAccion = turno.aplicar(Accion.guardar_caida(objetivo_id))
	assert_bool(resultado.valida).is_false()
	assert_str(MesaGuardar.motivo(resultado)).is_equal(motivo)
	assert_str(mesa.foto(turno)).is_equal(antes)
	assert_bool(turno.objetivos_para_guardar_caida().has(objetivo_id)).is_false()


# Guarda a la caida y comprueba (5): guardada, sin posicion, con la vida del
# fixture, su pergamino ocupado, el mana bajo el costo y el movimiento intacto.
func _guardar_valida(mesa: MesaGuardar, turno: Turno, objetivo_id: String) -> ResultadoAccion:
	var criatura: Criatura = mesa.plantel.criatura(objetivo_id)
	var pergamino_id: String = criatura.pergamino_id
	var mana: int = mesa.plantel.maestro.mana
	assert_int(turno.motivo_guardar_caida()).is_equal(ResultadoAccion.Motivo.NINGUNO)
	assert_array(turno.objetivos_para_guardar_caida()).contains([objetivo_id])
	var resultado: ResultadoAccion = turno.aplicar(Accion.guardar_caida(objetivo_id))
	assert_bool(resultado.valida).override_failure_message(MesaGuardar.motivo(resultado)).is_true()
	assert_int(resultado.costo).is_equal(_COSTO_RODAUVA)
	assert_int(criatura.estado).is_equal(Criatura.Estado.GUARDADA)
	assert_that(criatura.posicion).is_equal(Criatura.SIN_POSICION)
	assert_int(criatura.vida).is_equal(_VIDA_FIXTURE)
	assert_str(criatura.pergamino_id).is_equal(pergamino_id)
	var pergamino: Pergamino = mesa.plantel.pergamino(pergamino_id)
	assert_int(pergamino.estado).is_equal(Pergamino.Estado.OCUPADO)
	assert_str(pergamino.ocupante_id).is_equal(objetivo_id)
	assert_int(mesa.plantel.maestro.mana).is_equal(mana - _COSTO_RODAUVA)
	assert_bool(turno.accion_usada).is_true()
	assert_bool(turno.movimiento_usado).is_false()
	assert_bool(turno.terminado).is_false()
	return resultado


# (3) P-025: CAIDA_PROPIA acepta a una caida y rechaza a una de pie, a una
# guardada, a una que salio del tablero y a una que no existe.
func test_clase_caida_propia() -> void:
	var mesa: MesaGuardar = _mesa({"rodauva_2": Vector2i(3, 3)})
	_tumbar(mesa, "rodauva_1", Vector2i(5, 7))
	var plantel: Plantel = mesa.plantel
	var clase: Objetivos.Clase = Objetivos.Clase.CAIDA_PROPIA
	assert_str(_nombre(Objetivos.motivo("rodauva_1", clase, plantel))).is_equal("NINGUNO")
	assert_str(_nombre(Objetivos.motivo("rodauva_2", clase, plantel))).is_equal("OBJETIVO_NO_CAIDO")
	assert_str(_nombre(Objetivos.motivo(Maestro.ID, clase, plantel))).is_equal("OBJETIVO_NO_CAIDO")
	plantel.criatura("surcon_1").estado = Criatura.Estado.GUARDADA
	plantel.criatura("surcon_1").posicion = Criatura.SIN_POSICION
	assert_str(_nombre(Objetivos.motivo("surcon_1", clase, plantel))).is_equal("OBJETIVO_FUERA_DEL_TABLERO")
	VidaCero.sacar_del_tablero(plantel.criatura("ocarra_s1"), mesa.surcos)
	assert_str(_nombre(Objetivos.motivo("ocarra_s1", clase, plantel))).is_equal("OBJETIVO_FUERA_DEL_TABLERO")
	assert_str(_nombre(Objetivos.motivo("no_existe", clase, plantel))).is_equal("OBJETIVO_INEXISTENTE")


# (3) 1.6: ALIADA no cambia, sigue dejando afuera a la caida, y el Remiendo no la cura.
func test_aliada_sigue_rechazando_a_la_caida() -> void:
	var mesa: MesaGuardar = _mesa()
	_tumbar(mesa, "rodauva_1", Vector2i(5, 7))
	assert_str(_nombre(Objetivos.motivo("rodauva_1", Objetivos.Clase.ALIADA, mesa.plantel))) \
			.is_equal("OBJETIVO_CAIDO")
	var turno: Turno = mesa.turno()
	var remiendo: String = ""
	for id_hechizo in mesa.reglas.hechizos.ids():
		if mesa.reglas.hechizos.hechizo(id_hechizo)["efecto"] == Hechizos.EFECTO_CURA:
			remiendo = id_hechizo
	assert_str(remiendo).is_not_empty()
	var antes: String = mesa.foto(turno)
	var resultado: ResultadoAccion = turno.aplicar(Accion.hechizo(remiendo, "rodauva_1"))
	assert_bool(resultado.valida).is_false()
	assert_str(MesaGuardar.motivo(resultado)).is_equal("OBJETIVO_CAIDO")
	assert_str(mesa.foto(turno)).is_equal(antes)


# (5) A distancia 1 y 2 (tambien en diagonal: Manhattan 2), y despues el Maestro
# se mueve.
func test_guardar_a_distancia_1_y_2() -> void:
	for casilla in [Vector2i(5, 7), Vector2i(5, 8), Vector2i(6, 7), Vector2i(3, 6)]:
		var mesa: MesaGuardar = _mesa()
		_tumbar(mesa, "rodauva_1", casilla)
		var turno: Turno = mesa.turno()
		_guardar_valida(mesa, turno, "rodauva_1")
		assert_bool(turno.aplicar(Accion.mover(Vector2i(5, 4))).valida) \
				.override_failure_message(str(casilla)).is_true()
		assert_that(mesa.plantel.maestro.posicion).is_equal(Vector2i(5, 4))


# (5) S-57: por encima de una enemiga (y de un surco), sin mirar la linea.
func test_guardar_por_encima_de_una_enemiga() -> void:
	var mesa: MesaGuardar = _mesa({"ocarra_s1": Vector2i(5, 7)})
	_tumbar(mesa, "rodauva_1", Vector2i(5, 8))
	_guardar_valida(mesa, mesa.turno(), "rodauva_1")


# (5) La vista previa = validar = aplicar: costo, mana, vida y evento, sin cambiar nada.
func test_previsualizar_es_lo_que_aplica() -> void:
	var mesa: MesaGuardar = _mesa()
	_tumbar(mesa, "rodauva_1", Vector2i(5, 7))
	var turno: Turno = mesa.turno()
	var antes: String = mesa.foto(turno)
	var previa: ResultadoAccion = turno.previsualizar_guardar_caida("rodauva_1")
	assert_str(mesa.foto(turno)).is_equal(antes)
	assert_bool(previa.valida).is_true()
	assert_int(previa.costo).is_equal(_COSTO_RODAUVA)
	assert_dict(previa.mana).is_equal({"de": 8, "a": 8 - _COSTO_RODAUVA})
	assert_dict(previa.vida).is_equal({"de": 0, "a": _VIDA_FIXTURE})
	assert_dict(previa.evento).is_equal({"tipo": "guardado_caida", "unidad": "rodauva_1", "vida": _VIDA_FIXTURE})
	var aplicada: ResultadoAccion = turno.aplicar(Accion.guardar_caida("rodauva_1"))
	assert_int(aplicada.costo).is_equal(previa.costo)
	assert_dict(aplicada.mana).is_equal(previa.mana)
	assert_dict(aplicada.vida).is_equal(previa.vida)
	assert_dict(aplicada.evento).is_equal(previa.evento)


# (6) Rechazos: a distancia 3, una de pie, la atacante nocturna caida, con la
# accion usada, sin mana y una criatura que lo intenta.
func test_a_distancia_3_no() -> void:
	for casilla in [Vector2i(5, 9), Vector2i(7, 7), Vector2i(2, 6)]:
		var mesa: MesaGuardar = _mesa()
		_tumbar(mesa, "rodauva_1", casilla)
		var turno: Turno = mesa.turno()
		assert_str(_nombre(turno.motivo_guardar_caida())).is_equal("FUERA_DE_ALCANCE")
		_rechazada(mesa, turno, "rodauva_1", "FUERA_DE_ALCANCE")


func test_una_de_pie_no() -> void:
	var mesa: MesaGuardar = _mesa({"rodauva_1": Vector2i(5, 7)})
	_rechazada(mesa, mesa.turno(), "rodauva_1", "OBJETIVO_NO_CAIDO")


# 9.3: la atacante nocturna caida no es de la tribu (su destino es T30).
func test_la_atacante_nocturna_caida_no() -> void:
	var mesa: MesaGuardar = _mesa()
	_tumbar(mesa, "ocarra_a1", Vector2i(5, 7))
	assert_int(mesa.plantel.criatura("ocarra_a1").estado).is_equal(Criatura.Estado.CAIDA)
	var turno: Turno = mesa.turno()
	assert_str(_nombre(turno.motivo_guardar_caida())).is_equal("SIN_OBJETIVOS")
	_rechazada(mesa, turno, "ocarra_a1", "OBJETIVO_ENEMIGO")


# 3.1: cuesta la accion. Despues de atacar, no.
func test_con_la_accion_usada_no() -> void:
	var mesa: MesaGuardar = _mesa({"ocarra_s1": Vector2i(4, 6)})
	_tumbar(mesa, "rodauva_1", Vector2i(5, 7))
	var turno: Turno = mesa.turno()
	assert_bool(turno.aplicar(Accion.atacar("ocarra_s1")).valida).is_true()
	assert_str(_nombre(turno.motivo_guardar_caida())).is_equal("ACCION_USADA")
	_rechazada(mesa, turno, "rodauva_1", "ACCION_USADA")


func test_sin_mana_no() -> void:
	var mesa: MesaGuardar = _mesa()
	_tumbar(mesa, "rodauva_1", Vector2i(5, 7))
	var turno: Turno = mesa.turno()
	# Despues de empezar el turno: el inicio regenera el mana (11.3 paso 1).
	mesa.plantel.maestro.mana = _COSTO_RODAUVA - 1
	assert_str(_nombre(turno.motivo_guardar_caida())).is_equal("MANA_INSUFICIENTE")
	_rechazada(mesa, turno, "rodauva_1", "MANA_INSUFICIENTE")


func test_una_criatura_que_lo_intenta_no() -> void:
	var mesa: MesaGuardar = _mesa({"rodauva_2": Vector2i(4, 7)})
	_tumbar(mesa, "rodauva_1", Vector2i(5, 7))
	var turno: Turno = mesa.turno("rodauva_2")
	assert_str(_nombre(turno.motivo_guardar_caida())).is_equal("SOLO_MAESTRO")
	_rechazada(mesa, turno, "rodauva_1", "SOLO_MAESTRO")


# (6) motivo_guardar_caida: sin caidas de la tribu, SIN_OBJETIVOS; si no, el de la
# que mas lejos llego en el orden de _motivo_guardar_caida (una lejos y otra cerca
# sin mana: MANA_INSUFICIENTE). Cada caso coincide con el chequeo de la accion.
func test_motivo_es_el_mas_avanzado() -> void:
	var sin_caidas: MesaGuardar = _mesa()
	assert_str(_nombre(sin_caidas.turno().motivo_guardar_caida())).is_equal("SIN_OBJETIVOS")

	var dos: MesaGuardar = _mesa()
	_tumbar(dos, "rodauva_1", Vector2i(5, 10))
	_tumbar(dos, "surcon_1", Vector2i(5, 7))
	var turno: Turno = dos.turno()
	dos.plantel.maestro.mana = _COSTO_RODAUVA
	assert_str(MesaGuardar.motivo(turno.validar(Accion.guardar_caida("rodauva_1")))).is_equal("FUERA_DE_ALCANCE")
	assert_str(MesaGuardar.motivo(turno.validar(Accion.guardar_caida("surcon_1")))).is_equal("MANA_INSUFICIENTE")
	assert_str(_nombre(turno.motivo_guardar_caida())).is_equal("MANA_INSUFICIENTE")
	assert_array(turno.objetivos_para_guardar_caida()).is_empty()

	dos.plantel.maestro.mana = 8
	var con_mana: Turno = dos.turno()
	assert_str(_nombre(con_mana.motivo_guardar_caida())).is_equal("NINGUNO")
	assert_array(con_mana.objetivos_para_guardar_caida()).is_equal(["surcon_1"])


# (7) 11.2.1: el Surcon caido guardado cierra sus surcos, y su casilla queda
# libre: otra unidad llega ahi y termina su turno.
func test_surcon_caido_cierra_sus_surcos() -> void:
	var mesa: MesaGuardar = _mesa({"rodauva_2": Vector2i(5, 10)})
	mesa.surcos.cavar(Vector2i(4, 8), "surcon_1", 2)
	mesa.surcos.cavar(Vector2i(6, 8), "surcon_1", 2)
	_tumbar(mesa, "surcon_1", Vector2i(5, 8))
	assert_int(mesa.surcos.de("surcon_1").size()).is_equal(2)
	var turno: Turno = mesa.turno()
	assert_bool(turno.aplicar(Accion.guardar_caida("surcon_1")).valida).is_true()
	assert_array(mesa.surcos.de("surcon_1")).is_empty()
	assert_bool(mesa.surcos.hay_en(Vector2i(4, 8))).is_false()
	assert_bool(mesa.tablero.es_casilla_libre(Vector2i(5, 8), mesa.plantel, mesa.surcos)).is_true()
	var cierres: Array = mesa.surcos.historial().filter(func(evento: Dictionary) -> bool:
			return evento["tipo"] == "surco_cerrado")
	assert_int(cierres.size()).is_equal(2)
	for evento: Dictionary in cierres:
		assert_str(evento["motivo"]).is_equal("duenio_fuera")
	assert_bool(turno.aplicar(Accion.terminar()).valida).is_true()

	var otra: Turno = mesa.turno("rodauva_2")
	assert_bool(otra.casillas_para_mover().has(Vector2i(5, 8))).is_true()
	assert_bool(otra.aplicar(Accion.mover(Vector2i(5, 8))).valida).is_true()
	assert_bool(otra.aplicar(Accion.terminar()).valida).is_true()
	assert_that(mesa.plantel.criatura("rodauva_2").posicion).is_equal(Vector2i(5, 8))


# (8) 7.2: al cerrar la ronda del hambre de combate, la guardada no suma; la
# caida que no se guardo, si.
func test_la_guardada_no_suma_hambre_de_combate() -> void:
	var mesa: MesaGuardar = _mesa()
	_tumbar(mesa, "rodauva_1", Vector2i(5, 7))
	_tumbar(mesa, "rodauva_2", Vector2i(5, 10))
	assert_bool(mesa.turno().aplicar(Accion.guardar_caida("rodauva_1")).valida).is_true()
	var hambre: HambreCombate = HambreCombate.desde_datos(DatosFixture.cargar()["datos"]["tablas/hambre.json"])
	var antes: int = mesa.plantel.criatura("rodauva_1").hambre
	var cambios: Array = hambre.cerrar_ronda(5, mesa.plantel)
	var unidades: Array = cambios.map(func(cambio: Dictionary) -> String: return cambio["unidad"])
	assert_bool(unidades.has("rodauva_1")).is_false()
	assert_bool(unidades.has("rodauva_2")).is_true()
	assert_int(mesa.plantel.criatura("rodauva_1").hambre).is_equal(antes)


func _cierre() -> Cierre:
	var datos: Dictionary = DatosFixture.cargar()["datos"]
	return Cierre.desde_datos(datos["tablas/combate.json"], datos["tablas/lealtad.json"],
			Relaciones.new(datos["relaciones.json"]))


# (8) 11.5: si despues cae el Maestro, la guardada sobrevive (no muerta, pergamino
# ocupado) y no hay anotaciones de muerte por ella; la caida que no se guardo
# muere y da la suya.
func test_la_guardada_sobrevive_si_cae_el_maestro() -> void:
	var mesa: MesaGuardar = _mesa()
	_tumbar(mesa, "rodauva_1", Vector2i(5, 7))
	_tumbar(mesa, "rodauva_2", Vector2i(5, 10))
	assert_bool(mesa.turno().aplicar(Accion.guardar_caida("rodauva_1")).valida).is_true()
	var guardada: Criatura = mesa.plantel.criatura("rodauva_1")
	var pergamino_id: String = guardada.pergamino_id
	mesa.plantel.maestro.vida = 0
	VidaCero.resolver(Maestro.ID, mesa.plantel, mesa.surcos)
	var cierre: ResultadoCierre = _cierre().cerrar(mesa.plantel, FinCombate.Fin.DERROTA_POR_CAIDA)
	assert_bool(cierre.valido).is_true()
	assert_array(cierre.muertas).is_equal(["rodauva_2"])
	assert_int(guardada.estado).is_equal(Criatura.Estado.GUARDADA)
	assert_int(guardada.vida).is_equal(_VIDA_FIXTURE)
	assert_str(guardada.pergamino_id).is_equal(pergamino_id)
	assert_int(mesa.plantel.pergamino(pergamino_id).estado).is_equal(Pergamino.Estado.OCUPADO)
	# Una sola muerta: el Surcon suelto lleva una sola anotacion de muerte, y la
	# guardada ninguna.
	for cambio in cierre.lealtad:
		assert_str(cambio.criatura_id).is_not_equal("rodauva_1")
		if cambio.criatura_id == "surcon_1":
			assert_int(cambio.anotaciones.size()).is_equal(1)


# (8) 5.2: en una victoria, la guardada no recibe el +1 (las sueltas si).
func test_en_una_victoria_no_recibe_el_mas_uno() -> void:
	var mesa: MesaGuardar = _mesa()
	_tumbar(mesa, "rodauva_1", Vector2i(5, 7))
	assert_bool(mesa.turno().aplicar(Accion.guardar_caida("rodauva_1")).valida).is_true()
	for enemiga in ["ocarra_s1", "ocarra_a1"]:
		VidaCero.sacar_del_tablero(mesa.plantel.criatura(enemiga), mesa.surcos)
	var lealtad: int = mesa.plantel.criatura("rodauva_1").lealtad
	var cierre: ResultadoCierre = _cierre().cerrar(mesa.plantel, FinCombate.Fin.VICTORIA)
	assert_bool(cierre.valido).is_true()
	var con_cambio: Array = cierre.lealtad.map(func(cambio: CambioLealtad) -> String: return cambio.criatura_id)
	assert_bool(con_cambio.has("rodauva_1")).is_false()
	assert_bool(con_cambio.has("surcon_1")).is_true()
	assert_int(mesa.plantel.criatura("rodauva_1").lealtad).is_equal(lealtad)
	assert_int(mesa.plantel.criatura("rodauva_1").estado).is_equal(Criatura.Estado.GUARDADA)
