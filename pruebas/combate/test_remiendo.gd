extends GdUnitTestSuite

# Arquitectura.md B.3 (T22), criterios 7, 9 y 10: el Remiendo, con fixtures
# (A.6). Sistema.md 1.6, 7.8, 11.2.2 (S-22), 11.3 v1.6 y 11.5, y S-45. Numeros de
# los fixtures (escala vieja, D-009): cura 3 + 1 x Poder (4 con Poder 1, 6 con
# Poder 3), costo 4; Maestro de balanza 2 con 20 de vida maxima y 8 de mana;
# Rodauva con 8 y Zancajunco con 12.
const _R: String = "remiendo"


func _valida(resultado: ResultadoAccion) -> void:
	assert_bool(resultado.valida).override_failure_message(
			"rechazada: " + ResultadoAccion.Motivo.keys()[resultado.motivo]).is_true()


func _rechazada(resultado: ResultadoAccion, motivo: ResultadoAccion.Motivo) -> void:
	assert_bool(resultado.valida).is_false()
	assert_str(ResultadoAccion.Motivo.keys()[resultado.motivo]).is_equal(ResultadoAccion.Motivo.keys()[motivo])


# Aplica el Remiendo; lo previsto es lo aplicado. Devuelve el evento.
func _remendar(turno: Turno, objetivo_id: String) -> Dictionary:
	var previsto: ResultadoAccion = turno.previsualizar_hechizo(_R, objetivo_id)
	_valida(previsto)
	var aplicado: ResultadoAccion = turno.aplicar(Accion.hechizo(_R, objetivo_id))
	_valida(aplicado)
	assert_dict(aplicado.evento).is_equal(previsto.evento)
	assert_dict(aplicado.mana).is_equal(previsto.mana)
	return aplicado.evento


# Criterio 7: sobre el Maestro mismo (incluye_si_mismo): 10 + 4.
func test_sobre_el_maestro() -> void:
	var mesa: MesaHechizos = MesaHechizos.new({Maestro.ID: Vector2i(3, 4)})
	var turno: Turno = mesa.turno()
	mesa.plantel.maestro.vida = 10
	assert_dict(_remendar(turno, Maestro.ID)).is_equal({"tipo": "remiendo", "objetivo": Maestro.ID, "de": 10, "a": 14})
	assert_int(mesa.plantel.maestro.vida).is_equal(14)
	assert_int(mesa.plantel.maestro.mana).is_equal(4)


# Criterio 7 y 11.3 v1.6: sobre una aliada en las 4 ortogonales, si (2 + 4); en diagonal, no.
func test_aliada_ortogonal_si_y_diagonal_no() -> void:
	var mesa: MesaHechizos = MesaHechizos.new({Maestro.ID: Vector2i(3, 4), "rodauva_1": Vector2i(4, 5)})
	var turno: Turno = mesa.turno()
	mesa.plantel.criatura("rodauva_1").vida = 2
	_rechazada(turno.validar(Accion.hechizo(_R, "rodauva_1")), ResultadoAccion.Motivo.FUERA_DE_ALCANCE)
	mesa.plantel.criatura("rodauva_1").posicion = Vector2i(3, 5)
	assert_int(_remendar(turno, "rodauva_1")["a"]).is_equal(6)
	assert_int(mesa.plantel.criatura("rodauva_1").vida).is_equal(6)


# Criterio 7: ni sobre una enemiga ni sobre una caida (1.6, 11.5); un sentido sobra.
func test_enemiga_y_caida_no() -> void:
	var mesa: MesaHechizos = MesaHechizos.new({Maestro.ID: Vector2i(3, 4), "rodauva_s1": Vector2i(3, 3),
			"rodauva_1": Vector2i(2, 4)})
	var turno: Turno = mesa.turno()
	var foto: String = mesa.foto(turno)
	_rechazada(turno.aplicar(Accion.hechizo(_R, "rodauva_s1")), ResultadoAccion.Motivo.OBJETIVO_ENEMIGO)
	_rechazada(turno.aplicar(Accion.hechizo(_R, "rodauva_1", "empujar")), ResultadoAccion.Motivo.SENTIDO_INVALIDO)
	assert_str(mesa.foto(turno)).is_equal(foto)
	var caida: Criatura = mesa.plantel.criatura("rodauva_1")
	caida.estado = Criatura.Estado.CAIDA
	caida.vida = 0
	_rechazada(turno.validar(Accion.hechizo(_R, "rodauva_1")), ResultadoAccion.Motivo.OBJETIVO_CAIDO)
	assert_array(turno.objetivos_para_hechizo(_R)).contains_exactly([Maestro.ID])


# Criterio 7 y S-22: una aliada oculta si se puede remendar: 5 + 4.
func test_aliada_oculta_si() -> void:
	var mesa: MesaHechizos = MesaHechizos.new({Maestro.ID: Vector2i(3, 4), "zancajunco_1": Vector2i(4, 4)})
	var turno: Turno = mesa.turno()
	var zancajunco: Criatura = mesa.plantel.criatura("zancajunco_1")
	zancajunco.oculta = true
	zancajunco.vida = 5
	assert_int(_remendar(turno, "zancajunco_1")["a"]).is_equal(9)
	assert_bool(zancajunco.oculta).is_true()


# Criterio 7: cura segun Poder (3 + 1 x 3 = 6).
func test_cura_segun_poder() -> void:
	var mesa: MesaHechizos = MesaHechizos.new({Maestro.ID: Vector2i(3, 4)})
	mesa.plantel.maestro.poder = 3
	var turno: Turno = mesa.turno()
	mesa.plantel.maestro.vida = 10
	assert_int(_remendar(turno, Maestro.ID)["a"]).is_equal(16)


# Criterio 7: tope en la vida maxima, del Maestro (20, su balanza) y de una criatura (8, su ficha).
func test_tope_en_la_vida_maxima() -> void:
	var mesa: MesaHechizos = MesaHechizos.new({Maestro.ID: Vector2i(3, 4)})
	var turno: Turno = mesa.turno()
	mesa.plantel.maestro.vida = 18
	assert_dict(_remendar(turno, Maestro.ID)).is_equal({"tipo": "remiendo", "objetivo": Maestro.ID, "de": 18, "a": 20})

	mesa = MesaHechizos.new({Maestro.ID: Vector2i(3, 4), "rodauva_1": Vector2i(3, 3)})
	turno = mesa.turno()
	mesa.plantel.criatura("rodauva_1").vida = 6
	assert_int(_remendar(turno, "rodauva_1")["a"]).is_equal(8)


# Criterio 7 y S-45: con la vida completa vale, gasta el mana y la accion, y cura 0.
func test_con_la_vida_completa_cura_0() -> void:
	var mesa: MesaHechizos = MesaHechizos.new({Maestro.ID: Vector2i(3, 4), "rodauva_1": Vector2i(3, 3)})
	var turno: Turno = mesa.turno()
	assert_dict(_remendar(turno, "rodauva_1")).is_equal({"tipo": "remiendo", "objetivo": "rodauva_1", "de": 8, "a": 8})
	assert_int(mesa.plantel.maestro.mana).is_equal(4)
	assert_bool(turno.accion_usada).is_true()


# Criterios 8 y 9: con 3 de mana no alcanza (costo 4). Despues del Remiendo,
# atacar u otro hechizo dan ACCION_USADA; mover vale.
func test_mana_y_despues_del_remiendo() -> void:
	var mesa: MesaHechizos = MesaHechizos.new({Maestro.ID: Vector2i(3, 4), "ocarra_s1": Vector2i(3, 3)})
	var turno: Turno = mesa.turno()
	mesa.plantel.maestro.mana = 3
	_rechazada(turno.validar(Accion.hechizo(_R, Maestro.ID)), ResultadoAccion.Motivo.MANA_INSUFICIENTE)
	_valida(turno.validar(Accion.hechizo("martillazo", "ocarra_s1")))
	mesa.plantel.maestro.mana = 4
	_remendar(turno, Maestro.ID)
	assert_int(mesa.plantel.maestro.mana).is_equal(0)
	mesa.plantel.maestro.mana = 8
	_rechazada(turno.validar(Accion.atacar("ocarra_s1")), ResultadoAccion.Motivo.ACCION_USADA)
	_rechazada(turno.validar(Accion.hechizo("martillazo", "ocarra_s1")), ResultadoAccion.Motivo.ACCION_USADA)
	_valida(turno.validar(Accion.mover(Vector2i(4, 4))))
