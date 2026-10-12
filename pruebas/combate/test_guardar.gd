extends GdUnitTestSuite

# Arquitectura.md B.4 (T26), criterios 2 a 4: guardar en combate con turnos
# sueltos y fixtures (A.6). Sistema.md 3.1 (guardar: la accion de la criatura,
# junto al Maestro en las 4 ortogonales, 11.3), 10.4 (distraida), 10.5
# (enconada), 10.6 (acobardada), 10.3 (afinidad), 11.2.1 (surcos) y 11.2.2
# (oculto). Lecturas declaradas S-54 (puede moverse antes; termina el turno; no
# la enconada ni la distraida; la acobardada si) y S-55 (que conserva).
# escenario_guardar.json: el Maestro en [5,6]; cada test acomoda a las que usa.
const _RIVAL_100: String = "combate_rival_100.json"


func _motivo(turno: Turno, accion: Accion) -> String:
	return MesaGuardar.motivo(turno.validar(accion))


# Aplica guardar, que tiene que rechazarse con `motivo`, y comprueba que no cambio
# nada; la consulta dice lo mismo.
func _rechazada(mesa: MesaGuardar, turno: Turno, motivo: String) -> void:
	var antes: String = mesa.foto(turno)
	assert_str(ResultadoAccion.Motivo.keys()[turno.motivo_guardar()]).is_equal(motivo)
	var resultado: ResultadoAccion = turno.aplicar(Accion.guardar())
	assert_bool(resultado.valida).is_false()
	assert_str(MesaGuardar.motivo(resultado)).is_equal(motivo)
	assert_str(mesa.foto(turno)).is_equal(antes)


# Guarda y comprueba lo de (2): guardada, sin posicion, con su pergamino ocupado,
# y el turno terminado.
func _guardar_valida(mesa: MesaGuardar, turno: Turno, id_criatura: String) -> void:
	var criatura: Criatura = mesa.plantel.criatura(id_criatura)
	var pergamino_id: String = criatura.pergamino_id
	assert_int(turno.motivo_guardar()).is_equal(ResultadoAccion.Motivo.NINGUNO)
	assert_bool(turno.validar(Accion.guardar()).valida).is_true()
	assert_bool(turno.aplicar(Accion.guardar()).valida).is_true()
	assert_int(criatura.estado).is_equal(Criatura.Estado.GUARDADA)
	assert_that(criatura.posicion).is_equal(Criatura.SIN_POSICION)
	assert_str(criatura.pergamino_id).is_equal(pergamino_id)
	var pergamino: Pergamino = mesa.plantel.pergamino(pergamino_id)
	assert_int(pergamino.estado).is_equal(Pergamino.Estado.OCUPADO)
	assert_str(pergamino.ocupante_id).is_equal(id_criatura)
	assert_bool(turno.terminado).is_true()
	assert_str(_motivo(turno, Accion.terminar())).is_equal("TURNO_TERMINADO")


# (2) Ortogonal al Maestro, sin moverse.
func test_guardar_junto_al_maestro() -> void:
	var mesa: MesaGuardar = MesaGuardar.new({"rodauva_1": Vector2i(5, 7)})
	_guardar_valida(mesa, mesa.turno("rodauva_1"), "rodauva_1")


# (2) S-54: se mueve hasta el lado del Maestro y despues se guarda.
func test_guardar_despues_de_moverse() -> void:
	var mesa: MesaGuardar = MesaGuardar.new({"rodauva_1": Vector2i(5, 9)})
	var turno: Turno = mesa.turno("rodauva_1")
	assert_str(ResultadoAccion.Motivo.keys()[turno.motivo_guardar()]).is_equal("CASILLA_NO_ADYACENTE")
	assert_bool(turno.aplicar(Accion.mover(Vector2i(4, 6))).valida).is_true()
	_guardar_valida(mesa, turno, "rodauva_1")


# (3) 11.3 v1.6: el cuerpo mira 4. En diagonal y a distancia 2, no.
func test_lejos_del_maestro_no() -> void:
	for casilla in [Vector2i(6, 7), Vector2i(5, 8)]:
		var mesa: MesaGuardar = MesaGuardar.new({"rodauva_1": casilla})
		_rechazada(mesa, mesa.turno("rodauva_1"), "CASILLA_NO_ADYACENTE")


# (3) 3.1: cuesta la accion. Despues de atacar, no.
func test_despues_de_atacar_no() -> void:
	var mesa: MesaGuardar = MesaGuardar.new({"rodauva_1": Vector2i(5, 7), "ocarra_s1": Vector2i(4, 7)})
	var turno: Turno = mesa.turno("rodauva_1")
	assert_bool(turno.aplicar(Accion.atacar("ocarra_s1")).valida).is_true()
	_rechazada(mesa, turno, "ACCION_USADA")


# (3) S-54 y 10.5: la enconada no (su obligacion). La Ocarra con su rival
# (Ocarra salvaje) al lado y el Encono en 100 (escenario_rival.json, tramo neutral).
func test_enconada_no() -> void:
	var reglas: ReglasCombate = DatosFixture.reglas({"incidente": DatosFixture.incidente(_RIVAL_100),
			"chequeo_rival": DatosFixture.chequeo_rival(_RIVAL_100)})
	var mesa: MesaGuardar = MesaGuardar.new({"ocarra_1": Vector2i(3, 3), "ocarra_s1": Vector2i(3, 4),
			Maestro.ID: Vector2i(2, 3)}, "escenario_rival.json", reglas)
	var turno: Turno = mesa.turno("ocarra_1")
	assert_bool(turno.enconada).is_true()
	_rechazada(mesa, turno, "ENCONADA")


# (3) S-54 y 10.4: la distraida perdio la accion. El Zancajunco con la Ocarra
# rival al lado y el incidente en 100 (escenario_incidente.json, tramo neutral).
func test_distraida_no() -> void:
	var reglas: ReglasCombate = DatosFixture.reglas({
			"incidente": DatosFixture.incidente("combate_incidente_100.json"),
			"chequeo_rival": DatosFixture.chequeo_rival("combate_sin_rival.json")})
	var mesa: MesaGuardar = MesaGuardar.new({"zancajunco_1": Vector2i(3, 3), "ocarra_1": Vector2i(3, 2),
			Maestro.ID: Vector2i(2, 3)}, "escenario_incidente.json", reglas)
	var turno: Turno = mesa.turno("zancajunco_1")
	assert_str(turno.incidente["resultado"]).is_equal(Turno.RESULTADO_DISTRAIDA)
	_rechazada(mesa, turno, "ACCION_USADA")


# (3) 3.1: guardar es de una criatura de la tribu: ni una salvaje ni el Maestro.
func test_salvaje_y_maestro_no() -> void:
	var mesa: MesaGuardar = MesaGuardar.new({"ocarra_s1": Vector2i(5, 5)})
	_rechazada(mesa, mesa.turno("ocarra_s1"), "SOLO_CRIATURA_DE_LA_TRIBU")
	var otra: MesaGuardar = MesaGuardar.new()
	_rechazada(otra, otra.turno(Maestro.ID), "SOLO_CRIATURA_DE_LA_TRIBU")


# (3) S-54: la acobardada si. La Rodauva con el Tasajero (su rival) a su alcance
# y la cobardia en 100 (escenario_rival.json); el Maestro empieza lejos de su
# casilla (sin el -10 del Maestro vecino) y ella se mueve a su lado, alejandose.
func test_acobardada_si() -> void:
	var reglas: ReglasCombate = DatosFixture.reglas({"incidente": DatosFixture.incidente(_RIVAL_100),
			"chequeo_rival": DatosFixture.chequeo_rival(_RIVAL_100)})
	var mesa: MesaGuardar = MesaGuardar.new({"rodauva_1": Vector2i(3, 3), "tasajero_s1": Vector2i(3, 6),
			Maestro.ID: Vector2i(3, 1)}, "escenario_rival.json", reglas)
	var turno: Turno = mesa.turno("rodauva_1")
	assert_bool(turno.acobardada).is_true()
	assert_bool(turno.aplicar(Accion.mover(Vector2i(3, 2))).valida).is_true()
	_guardar_valida(mesa, turno, "rodauva_1")


# (4) 10.3: la guardada deja de dar afinidad en el acto. El golpe previsto de la
# Rodauva 2 a la Ocarra lleva la afinidad de la Rodauva 1 (vecina en 8, se llevan
# bien) antes de que se guarde, y no despues.
func test_deja_de_dar_afinidad() -> void:
	var mesa: MesaGuardar = MesaGuardar.new({"rodauva_1": Vector2i(5, 7), "rodauva_2": Vector2i(6, 8),
			"ocarra_s1": Vector2i(6, 9)})
	var de_la_2: Turno = mesa.turno("rodauva_2")
	var antes: ResultadoAccion = de_la_2.previsualizar_ataque(Vector2i(6, 8), "ocarra_s1")
	assert_object(_fuente(antes.desglose, ModificadorDanio.Fuente.AFINIDAD)).is_not_null()
	assert_bool(mesa.turno("rodauva_1").aplicar(Accion.guardar()).valida).is_true()
	var despues: ResultadoAccion = de_la_2.previsualizar_ataque(Vector2i(6, 8), "ocarra_s1")
	assert_object(_fuente(despues.desglose, ModificadorDanio.Fuente.AFINIDAD)).is_null()
	assert_int(despues.danio).is_less(antes.danio)


# (4) 11.2.1: el Surcon guardado cierra sus surcos (duenio_fuera).
func test_surcon_cierra_sus_surcos() -> void:
	var mesa: MesaGuardar = MesaGuardar.new({"surcon_1": Vector2i(5, 7)})
	var cava: Turno = mesa.turno("surcon_1")
	assert_bool(cava.aplicar(Accion.cavar(Vector2i(4, 7))).valida).is_true()
	assert_bool(cava.aplicar(Accion.terminar()).valida).is_true()
	assert_array(mesa.surcos.de("surcon_1")).is_equal([Vector2i(4, 7)])
	assert_bool(mesa.turno("surcon_1").aplicar(Accion.guardar()).valida).is_true()
	assert_array(mesa.surcos.de("surcon_1")).is_empty()
	var ultimo: Dictionary = mesa.surcos.historial().back()
	assert_str(ultimo["tipo"]).is_equal("surco_cerrado")
	assert_str(ultimo["motivo"]).is_equal(Surcos.MOTIVO_DUENIO_FUERA)


# (4) 11.2.2 y S-55: la oculta pierde el estado, el bono y el limite del junco.
func test_oculta_pierde_estado_y_bono() -> void:
	var mesa: MesaGuardar = MesaGuardar.new({"zancajunco_1": Vector2i(5, 7)})
	var se_oculta: Turno = mesa.turno("zancajunco_1")
	assert_bool(se_oculta.aplicar(Accion.hacerse_junco()).valida).is_true()
	assert_bool(se_oculta.aplicar(Accion.terminar()).valida).is_true()
	var criatura: Criatura = mesa.plantel.criatura("zancajunco_1")
	assert_bool(criatura.oculta and criatura.bono_junco and criatura.junco_turno_anterior).is_true()
	assert_bool(mesa.turno("zancajunco_1").aplicar(Accion.guardar()).valida).is_true()
	assert_bool(criatura.oculta).is_false()
	assert_bool(criatura.bono_junco).is_false()
	assert_bool(criatura.junco_turno_anterior).is_false()


# (4) S-55: la erizada pierde la marca. Hoy ninguna regla deja a una criatura
# erizada al guardarse (el inicio de su turno la borra, 11.2); la marca se pone a
# mano para cubrir el efecto que T27 reusa (guardar a una caida).
func test_erizada_pierde_la_marca() -> void:
	var mesa: MesaGuardar = MesaGuardar.new({"rodauva_1": Vector2i(5, 7)})
	var turno: Turno = mesa.turno("rodauva_1")
	var criatura: Criatura = mesa.plantel.criatura("rodauva_1")
	criatura.erizada = true
	assert_bool(turno.aplicar(Accion.guardar()).valida).is_true()
	assert_bool(criatura.erizada).is_false()


# (4) S-55: conserva vida, hambre, lealtad, enfermedades, contador de Encono y modo.
func test_conserva_lo_suyo() -> void:
	var mesa: MesaGuardar = MesaGuardar.new({"rodauva_1": Vector2i(5, 7)})
	var criatura: Criatura = mesa.plantel.criatura("rodauva_1")
	criatura.vida = 5
	criatura.hambre = 4
	criatura.lealtad = 7
	criatura.enfermedades = 1
	criatura.encono = 2
	var modo: String = criatura.modo
	assert_bool(mesa.turno("rodauva_1").aplicar(Accion.guardar()).valida).is_true()
	assert_array([criatura.vida, criatura.hambre, criatura.lealtad, criatura.enfermedades, criatura.encono]) \
			.is_equal([5, 4, 7, 1, 2])
	assert_str(criatura.modo).is_equal(modo)


# Ni guardar ni invocar tocan la cadena (10.2): guardarse no la corta.
func test_no_toca_la_cadena() -> void:
	var mesa: MesaGuardar = MesaGuardar.new({"rodauva_1": Vector2i(5, 7), "rodauva_2": Vector2i(4, 8),
			"ocarra_s1": Vector2i(4, 9)})
	var pega: Turno = mesa.turno("rodauva_2")
	assert_bool(pega.aplicar(Accion.atacar("ocarra_s1")).valida).is_true()
	var cadena: Variant = mesa.cadena.instantanea()
	assert_that(cadena).is_not_null()
	assert_bool(mesa.turno("rodauva_1").aplicar(Accion.guardar()).valida).is_true()
	assert_that(mesa.cadena.instantanea()).is_equal(cadena)
	assert_array(mesa.cadena.historial()).is_empty()


func _fuente(desglose: DesgloseDanio, fuente: ModificadorDanio.Fuente) -> ModificadorDanio:
	for modificador in desglose.modificadores:
		if modificador.fuente == fuente:
			return modificador
	return null
