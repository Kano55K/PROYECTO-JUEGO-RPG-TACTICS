extends GdUnitTestSuite

# Arquitectura.md B.4 (T28), criterio 1: declarar la huida con turnos sueltos y
# fixtures (A.6). Sistema.md 11.7 (en su turno; gasta el turno completo; sigue en
# el tablero) y 11.3 (invocar, huir y cavar gastan el turno completo). Lectura
# declarada S-59: como invocar (S-53), solo con el turno sin usar. Mesa:
# escenario_guardar.json (MesaGuardar), el Maestro en [5,6].


func _rechazada(mesa: MesaGuardar, turno: Turno, accion: Accion, motivo: String) -> void:
	var antes: String = mesa.foto(turno)
	var resultado: ResultadoAccion = turno.aplicar(accion)
	assert_bool(resultado.valida).override_failure_message(str(accion.a_diccionario())).is_false()
	assert_str(MesaGuardar.motivo(resultado)).override_failure_message(str(accion.a_diccionario())).is_equal(motivo)
	assert_str(mesa.foto(turno)).is_equal(antes)


func _motivo_huir(turno: Turno) -> String:
	return ResultadoAccion.Motivo.keys()[turno.motivo_huir()]


# (1) Con el turno sin usar vale: queda declarada (en el Maestro y en la
# instantanea), el Maestro sigue en su casilla y despues solo vale terminar, que
# no es esperar.
func test_declarar_con_el_turno_sin_usar() -> void:
	var mesa: MesaGuardar = MesaGuardar.new({"ocarra_s1": Vector2i(6, 6)})
	var turno: Turno = mesa.turno()
	assert_str(_motivo_huir(turno)).is_equal("NINGUNO")
	assert_bool(turno.validar(Accion.huir()).valida).is_true()
	assert_bool(mesa.plantel.maestro.huida_declarada).is_false()
	var resultado: ResultadoAccion = turno.aplicar(Accion.huir())
	assert_bool(resultado.valida).is_true()
	assert_bool(mesa.plantel.maestro.huida_declarada).is_true()
	assert_bool(mesa.plantel.maestro.se_fue).is_false()
	assert_bool(mesa.plantel.instantanea()["maestro"]["huida_declarada"]).is_true()
	assert_that(mesa.plantel.maestro.posicion).is_equal(Vector2i(5, 6))
	assert_int(FinCombate.evaluar(mesa.plantel)).is_equal(FinCombate.Fin.EN_CURSO)
	assert_bool(Accion.huir().gasta_turno_completo()).is_true()

	assert_str(MesaGuardar.motivo(turno.validar(Accion.mover(Vector2i(5, 5))))).is_equal("MOVIMIENTO_USADO")
	assert_str(MesaGuardar.motivo(turno.validar(Accion.atacar("ocarra_s1")))).is_equal("ACCION_USADA")
	var hechizo: String = mesa.reglas.hechizos.ids()[0]
	assert_str(MesaGuardar.motivo(turno.validar(Accion.hechizo(hechizo, "ocarra_s1")))).is_equal("ACCION_USADA")
	assert_str(MesaGuardar.motivo(turno.validar(Accion.sellar("ocarra_s1")))).is_equal("ACCION_USADA")
	assert_str(MesaGuardar.motivo(turno.validar(Accion.invocar("rodauva_g", Vector2i(5, 5))))).is_equal("ACCION_USADA")
	assert_str(MesaGuardar.motivo(turno.validar(Accion.huir()))).is_equal("ACCION_USADA")
	assert_str(_motivo_huir(turno)).is_equal("ACCION_USADA")
	var fin: ResultadoAccion = turno.aplicar(Accion.terminar())
	assert_bool(fin.valida).is_true()
	assert_bool(fin.espero).is_false()


# (1) S-59: despues de moverse, o de usar la accion, no; sin cambiar nada.
func test_con_el_turno_usado_no() -> void:
	var mesa: MesaGuardar = MesaGuardar.new()
	var se_mueve: Turno = mesa.turno()
	assert_bool(se_mueve.aplicar(Accion.mover(Vector2i(5, 5))).valida).is_true()
	_rechazada(mesa, se_mueve, Accion.huir(), "YA_SE_MOVIO")
	assert_str(_motivo_huir(se_mueve)).is_equal("YA_SE_MOVIO")
	var otra: MesaGuardar = MesaGuardar.new({"ocarra_s1": Vector2i(6, 6)})
	var ataca: Turno = otra.turno()
	assert_bool(ataca.aplicar(Accion.atacar("ocarra_s1")).valida).is_true()
	_rechazada(otra, ataca, Accion.huir(), "ACCION_USADA")
	assert_str(_motivo_huir(ataca)).is_equal("ACCION_USADA")
	assert_bool(otra.plantel.maestro.huida_declarada).is_false()


# (1) Una criatura no huye (11.7: es del Maestro), y con el turno terminado tampoco.
func test_criatura_y_turno_terminado() -> void:
	var mesa: MesaGuardar = MesaGuardar.new()
	var criatura: Turno = mesa.turno("rodauva_1")
	_rechazada(mesa, criatura, Accion.huir(), "SOLO_MAESTRO")
	assert_str(_motivo_huir(criatura)).is_equal("SOLO_MAESTRO")
	var terminado: Turno = mesa.turno()
	assert_bool(terminado.aplicar(Accion.terminar()).valida).is_true()
	_rechazada(mesa, terminado, Accion.huir(), "TURNO_TERMINADO")
	assert_str(_motivo_huir(terminado)).is_equal("TURNO_TERMINADO")


# (7) S-61: el turno de consulta (Turno.para_consulta) no corre el inicio del
# turno ni toca el generador, pero cuenta el borrado de Erizarse (11.3): una
# Rodauva erizada se puede mover en la consulta, y sigue erizada.
func test_turno_de_consulta_sin_inicio() -> void:
	var mesa: MesaGuardar = MesaGuardar.new({"rodauva_1": Vector2i(5, 9)})
	var rodauva: Criatura = mesa.plantel.criatura("rodauva_1")
	rodauva.erizada = true
	var antes: String = JSON.stringify([mesa.plantel.instantanea(), mesa.azar.historial()])
	var consulta: Turno = Turno.para_consulta(EntradaCola.new("rodauva_1", "", 0), mesa.plantel, mesa.tablero,
			mesa.surcos, mesa.cadena, ColaIniciativa.new(), mesa.reglas)
	assert_int(consulta.pasos_para_mover().size()).is_greater(1)
	assert_bool(rodauva.erizada).is_true()
	assert_str(JSON.stringify([mesa.plantel.instantanea(), mesa.azar.historial()])).is_equal(antes)


# (8) La accion como diccionario: ida y vuelta exacta, y sin campos de mas.
func test_huir_como_diccionario() -> void:
	var dic: Dictionary = Accion.huir().a_diccionario()
	assert_dict(dic).is_equal({"tipo": "huir"})
	assert_int(Accion.desde_diccionario(dic).tipo).is_equal(Accion.Tipo.HUIR)
	assert_object(Accion.desde_diccionario({"tipo": "huir", "objetivo": "x"})).is_null()
