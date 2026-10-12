extends GdUnitTestSuite

# Arquitectura.md B.4 (T26), criterios 5, 6, 8 y 12: invocar en combate con
# turnos sueltos y fixtures (A.6). Sistema.md 3.1 (gasta el turno completo del
# Maestro; casilla libre adyacente en las 4 ortogonales; Maestro rodeado no
# invoca), 2.3 (costo por rango; balanza 2: Rodauva 2, Surcon 3), 11.3 (casilla
# libre, S-25) y 11.2.2 (destape por contacto, S-24). Lecturas declaradas S-53
# (solo con el turno sin usar) y S-56 (en la misma ronda en que se guardo).
# escenario_guardar.json: el Maestro en [5,6] con 8 de mana; guardadas rodauva_g
# y surcon_g.
const _JUNTO: Array[Vector2i] = [Vector2i(5, 5), Vector2i(4, 6), Vector2i(6, 6), Vector2i(5, 7)]


func _rechazada(mesa: MesaGuardar, turno: Turno, accion: Accion, motivo: String) -> void:
	var antes: String = mesa.foto(turno)
	var resultado: ResultadoAccion = turno.aplicar(accion)
	assert_bool(resultado.valida).override_failure_message(str(accion.a_diccionario())).is_false()
	assert_str(MesaGuardar.motivo(resultado)).override_failure_message(str(accion.a_diccionario())).is_equal(motivo)
	assert_str(mesa.foto(turno)).is_equal(antes)


# (5) Con el turno sin usar, en una casilla ortogonal libre: suelta ahi y el mana
# baja el costo. Despues, mover, atacar, un hechizo, sellar y Secundar se
# rechazan, y terminar vale sin ser esperar.
func test_invocar_con_el_turno_sin_usar() -> void:
	var mesa: MesaGuardar = MesaGuardar.new({"ocarra_s1": Vector2i(6, 5)})
	var turno: Turno = mesa.turno()
	assert_array(turno.casillas_para_invocar()).is_equal(_JUNTO)
	assert_array(turno.guardadas_para_invocar()).is_equal(["rodauva_g", "surcon_g"])
	var resultado: ResultadoAccion = turno.aplicar(Accion.invocar("rodauva_g", Vector2i(5, 7)))
	assert_bool(resultado.valida).is_true()
	assert_int(resultado.costo).is_equal(2)
	assert_dict(resultado.mana).is_equal({"de": 8, "a": 6})
	assert_int(mesa.plantel.maestro.mana).is_equal(6)
	var invocada: Criatura = mesa.plantel.criatura("rodauva_g")
	assert_int(invocada.estado).is_equal(Criatura.Estado.SUELTA)
	assert_that(invocada.posicion).is_equal(Vector2i(5, 7))
	assert_str(MesaGuardar.motivo(turno.validar(Accion.mover(Vector2i(4, 6))))).is_equal("MOVIMIENTO_USADO")
	assert_str(MesaGuardar.motivo(turno.validar(Accion.atacar("ocarra_s1")))).is_equal("ACCION_USADA")
	var hechizo: String = mesa.reglas.hechizos.ids()[0]
	assert_str(MesaGuardar.motivo(turno.validar(Accion.hechizo(hechizo, "ocarra_s1")))).is_equal("ACCION_USADA")
	assert_str(MesaGuardar.motivo(turno.validar(Accion.sellar("ocarra_s1")))).is_equal("ACCION_USADA")
	assert_str(MesaGuardar.motivo(turno.validar(Accion.secundar("rodauva_1")))).is_equal("ACCION_USADA")
	assert_str(MesaGuardar.motivo(turno.validar(Accion.invocar("surcon_g", Vector2i(5, 5))))).is_equal("ACCION_USADA")
	assert_bool(Accion.invocar("rodauva_g", Vector2i(5, 7)).gasta_turno_completo()).is_true()
	var fin: ResultadoAccion = turno.aplicar(Accion.terminar())
	assert_bool(fin.valida).is_true()
	assert_bool(fin.espero).is_false()


# (6) S-53: despues de moverse, o de usar la accion, no.
func test_con_el_turno_usado_no() -> void:
	var mesa: MesaGuardar = MesaGuardar.new()
	var se_mueve: Turno = mesa.turno()
	assert_bool(se_mueve.aplicar(Accion.mover(Vector2i(5, 5))).valida).is_true()
	_rechazada(mesa, se_mueve, Accion.invocar("rodauva_g", Vector2i(5, 6)), "YA_SE_MOVIO")
	assert_array(se_mueve.casillas_para_invocar()).is_empty()
	var otra: MesaGuardar = MesaGuardar.new({"ocarra_s1": Vector2i(6, 6)})
	var ataca: Turno = otra.turno()
	assert_bool(ataca.aplicar(Accion.atacar("ocarra_s1")).valida).is_true()
	_rechazada(otra, ataca, Accion.invocar("rodauva_g", Vector2i(5, 7)), "ACCION_USADA")
	assert_str(ResultadoAccion.Motivo.keys()[ataca.motivo_invocar("rodauva_g")]).is_equal("ACCION_USADA")


# (6) 3.1 y S-25: la casilla es ortogonal al Maestro y libre: ni en diagonal, ni
# a 2, ni ocupada (de pie o caida), ni con surco, ni fuera del tablero.
func test_casillas_que_no_valen() -> void:
	var mesa: MesaGuardar = MesaGuardar.new({"rodauva_1": Vector2i(5, 7), "rodauva_2": Vector2i(4, 6)})
	var caida: Criatura = mesa.plantel.criatura("rodauva_2")
	caida.vida = 0
	caida.estado = Criatura.Estado.CAIDA
	mesa.surcos.cavar(Vector2i(6, 6), "surcon_1", 2)
	var turno: Turno = mesa.turno()
	_rechazada(mesa, turno, Accion.invocar("rodauva_g", Vector2i(6, 7)), "CASILLA_NO_ADYACENTE")
	_rechazada(mesa, turno, Accion.invocar("rodauva_g", Vector2i(5, 8)), "CASILLA_NO_ADYACENTE")
	_rechazada(mesa, turno, Accion.invocar("rodauva_g", Vector2i(5, 7)), "CASILLA_NO_LIBRE")
	_rechazada(mesa, turno, Accion.invocar("rodauva_g", Vector2i(4, 6)), "CASILLA_NO_LIBRE")
	_rechazada(mesa, turno, Accion.invocar("rodauva_g", Vector2i(6, 6)), "CASILLA_NO_LIBRE")
	assert_array(turno.casillas_para_invocar()).is_equal([Vector2i(5, 5)])
	var borde: MesaGuardar = MesaGuardar.new({Maestro.ID: Vector2i(0, 6)})
	_rechazada(borde, borde.turno(), Accion.invocar("rodauva_g", Vector2i(-1, 6)), "CASILLA_NO_LIBRE")


# (6) 3.1: un Maestro rodeado no recibe refuerzos (motivo propio).
func test_maestro_rodeado() -> void:
	var mesa: MesaGuardar = MesaGuardar.new({"rodauva_1": Vector2i(5, 5), "rodauva_2": Vector2i(4, 6),
			"surcon_1": Vector2i(6, 6), "zancajunco_1": Vector2i(5, 7)})
	var turno: Turno = mesa.turno()
	_rechazada(mesa, turno, Accion.invocar("rodauva_g", Vector2i(5, 7)), "SIN_CASILLA_LIBRE")
	assert_str(ResultadoAccion.Motivo.keys()[turno.motivo_invocar("rodauva_g")]).is_equal("SIN_CASILLA_LIBRE")
	assert_array(turno.casillas_para_invocar()).is_empty()
	assert_array(turno.guardadas_para_invocar()).is_empty()


# (6) 2.3: con menos mana que el costo, no. Con 2, la Rodauva si y el Surcon no.
# El mana se baja despues del inicio del turno (la regeneracion de 2.1 ya corrio).
func test_mana_insuficiente() -> void:
	var mesa: MesaGuardar = MesaGuardar.new()
	var turno: Turno = mesa.turno()
	mesa.plantel.maestro.mana = 2
	_rechazada(mesa, turno, Accion.invocar("surcon_g", Vector2i(5, 7)), "MANA_INSUFICIENTE")
	assert_str(ResultadoAccion.Motivo.keys()[turno.motivo_invocar("surcon_g")]).is_equal("MANA_INSUFICIENTE")
	assert_array(turno.guardadas_para_invocar()).is_equal(["rodauva_g"])


# (6) 3.1: solo una guardada de la tribu: ni una suelta, ni una caida, ni una
# enemiga, ni una que no existe.
func test_criaturas_que_no_se_invocan() -> void:
	var mesa: MesaGuardar = MesaGuardar.new({"rodauva_2": Vector2i(0, 5)})
	var caida: Criatura = mesa.plantel.criatura("rodauva_2")
	caida.vida = 0
	caida.estado = Criatura.Estado.CAIDA
	var turno: Turno = mesa.turno()
	_rechazada(mesa, turno, Accion.invocar("rodauva_1", Vector2i(5, 7)), "NO_GUARDADA")
	_rechazada(mesa, turno, Accion.invocar("rodauva_2", Vector2i(5, 7)), "NO_GUARDADA")
	_rechazada(mesa, turno, Accion.invocar("ocarra_s1", Vector2i(5, 7)), "OBJETIVO_ENEMIGO")
	_rechazada(mesa, turno, Accion.invocar("nadie", Vector2i(5, 7)), "OBJETIVO_INEXISTENTE")
	_rechazada(mesa, turno, Accion.invocar(Maestro.ID, Vector2i(5, 7)), "OBJETIVO_INEXISTENTE")


# (6) 3.1: invoca el Maestro; una criatura no.
func test_una_criatura_no_invoca() -> void:
	var mesa: MesaGuardar = MesaGuardar.new({"rodauva_1": Vector2i(5, 7)})
	var turno: Turno = mesa.turno("rodauva_1")
	_rechazada(mesa, turno, Accion.invocar("rodauva_g", Vector2i(5, 5)), "SOLO_MAESTRO")
	assert_array(turno.casillas_para_invocar()).is_empty()
	assert_array(turno.guardadas_para_invocar()).is_empty()


# (6) S-56: la que se guardo en este combate se invoca despues, tambien en la
# misma ronda.
func test_guardada_en_este_combate() -> void:
	var mesa: MesaGuardar = MesaGuardar.new({"rodauva_1": Vector2i(5, 7)})
	assert_bool(mesa.turno("rodauva_1").aplicar(Accion.guardar()).valida).is_true()
	var turno: Turno = mesa.turno()
	assert_array(turno.guardadas_para_invocar()).is_equal(["rodauva_1", "rodauva_g", "surcon_g"])
	assert_bool(turno.aplicar(Accion.invocar("rodauva_1", Vector2i(5, 7))).valida).is_true()
	assert_that(mesa.plantel.criatura("rodauva_1").posicion).is_equal(Vector2i(5, 7))


# (8) S-24: invocarla junto a un Zancajunco salvaje oculto lo destapa por
# contacto, y la previsualizacion lo avisa.
func test_destapa_por_contacto() -> void:
	var mesa: MesaGuardar = MesaGuardar.new({"zancajunco_s1": Vector2i(4, 7)})
	Junco.ocultar(mesa.plantel.criatura("zancajunco_s1"))
	var turno: Turno = mesa.turno()
	assert_array(turno.previsualizar_invocar("rodauva_g", Vector2i(5, 7)).destaparia).is_equal(["zancajunco_s1"])
	assert_array(turno.previsualizar_invocar("rodauva_g", Vector2i(5, 5)).destaparia).is_empty()
	assert_bool(turno.aplicar(Accion.invocar("rodauva_g", Vector2i(5, 7))).valida).is_true()
	assert_bool(mesa.plantel.criatura("zancajunco_s1").oculta).is_false()
	assert_bool(mesa.plantel.criatura("zancajunco_s1").bono_junco).is_true()
	assert_array(turno.eventos()).is_equal([{"tipo": "destape", "unidad": "zancajunco_s1", "motivo": "contacto",
			"por": "rodauva_g"}])


# (12) Consultas = validar = aplicar, sin cambiar la instantanea, el mana ni el
# generador: cada consulta, en cada casilla junto al Maestro y con cada criatura.
func test_consultas_igual_que_validar_y_aplicar() -> void:
	var mesa: MesaGuardar = MesaGuardar.new({"rodauva_1": Vector2i(5, 5), "zancajunco_s1": Vector2i(3, 6)})
	Junco.ocultar(mesa.plantel.criatura("zancajunco_s1"))
	var turno: Turno = mesa.turno()
	mesa.plantel.maestro.mana = 2
	var antes: String = mesa.foto(turno)
	var ids: Array[String] = ["rodauva_1", "rodauva_g", "surcon_g", "ocarra_s1"]
	var casillas: Array[Vector2i] = [Vector2i(5, 5), Vector2i(4, 6), Vector2i(6, 6), Vector2i(5, 7), Vector2i(6, 7)]
	for id_criatura in ids:
		var motivo: ResultadoAccion.Motivo = turno.motivo_invocar(id_criatura)
		assert_bool(turno.guardadas_para_invocar().has(id_criatura)).is_equal(motivo == ResultadoAccion.Motivo.NINGUNO)
		for casilla in casillas:
			var previa: ResultadoAccion = turno.previsualizar_invocar(id_criatura, casilla)
			var validada: ResultadoAccion = turno.validar(Accion.invocar(id_criatura, casilla))
			assert_int(previa.motivo).is_equal(validada.motivo)
			assert_int(previa.costo).is_equal(validada.costo)
			assert_array(previa.destaparia).is_equal(validada.destaparia)
			if motivo != ResultadoAccion.Motivo.NINGUNO:
				assert_int(previa.motivo).is_equal(motivo)
			elif previa.valida:
				assert_bool(turno.casillas_para_invocar().has(casilla)).is_true()
	assert_str(mesa.foto(turno)).is_equal(antes)
	var previa_valida: ResultadoAccion = turno.previsualizar_invocar("rodauva_g", Vector2i(4, 6))
	assert_array(previa_valida.destaparia).is_equal(["zancajunco_s1"])
	var aplicada: ResultadoAccion = turno.aplicar(Accion.invocar("rodauva_g", Vector2i(4, 6)))
	assert_int(aplicada.costo).is_equal(previa_valida.costo)
	assert_dict(aplicada.mana).is_equal(previa_valida.mana)
	assert_array(aplicada.destaparia).is_equal(previa_valida.destaparia)
	assert_dict(aplicada.evento).is_equal(previa_valida.evento)
	assert_array(mesa.azar.historial()).is_empty()


# (12) La consulta de guardar = validar = aplicar, sin cambiar nada.
func test_consulta_de_guardar_igual_que_validar() -> void:
	for casilla in [Vector2i(5, 7), Vector2i(6, 7)]:
		var mesa: MesaGuardar = MesaGuardar.new({"rodauva_1": casilla})
		var turno: Turno = mesa.turno("rodauva_1")
		var antes: String = mesa.foto(turno)
		var motivo: ResultadoAccion.Motivo = turno.motivo_guardar()
		assert_int(turno.validar(Accion.guardar()).motivo).is_equal(motivo)
		assert_str(mesa.foto(turno)).is_equal(antes)
		assert_int(turno.aplicar(Accion.guardar()).motivo).is_equal(motivo)
