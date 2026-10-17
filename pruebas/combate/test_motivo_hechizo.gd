extends GdUnitTestSuite

# Arquitectura.md B.3 (T22, sesion 2), criterio 1: Turno.motivo_hechizo dice,
# sin aplicar, por que un hechizo no se puede lanzar ahora (NINGUNO si se puede),
# con los mismos chequeos que validar. Fixtures (A.6): escenario_hechizos.json y
# hechizos.json de prueba (costos 2, 2 y 4; Martillazo a 3). Sistema.md 1.6 y 2.3.
const _HECHIZOS: Array[String] = ["martillazo", "lanzadera", "remiendo"]


func _nombre(motivo: ResultadoAccion.Motivo) -> String:
	return ResultadoAccion.Motivo.keys()[motivo]


func _assert_motivo(turno: Turno, hechizo_id: String, esperado: ResultadoAccion.Motivo) -> void:
	assert_str(_nombre(turno.motivo_hechizo(hechizo_id))).override_failure_message(
			"%s: %s" % [hechizo_id, _nombre(turno.motivo_hechizo(hechizo_id))]).is_equal(_nombre(esperado))


# Los ids de todas las unidades del plantel (el Maestro primero).
func _ids(mesa: MesaHechizos) -> Array[String]:
	var ids: Array[String] = [Maestro.ID]
	for criatura in mesa.plantel.criaturas():
		ids.append(criatura.id)
	return ids


# Con objetivos, mana y la accion sin usar: NINGUNO en los tres.
func test_se_puede_lanzar() -> void:
	var mesa: MesaHechizos = MesaHechizos.new({Maestro.ID: Vector2i(3, 4), "ocarra_s1": Vector2i(3, 2)})
	var turno: Turno = mesa.turno()
	for hechizo_id in _HECHIZOS:
		_assert_motivo(turno, hechizo_id, ResultadoAccion.Motivo.NINGUNO)


# Sin ninguna objetivo valida: SIN_OBJETIVOS, y validar rechaza a todas las
# unidades. Con las enemigas estacionadas en la fila 0, el Martillazo no llega.
func test_sin_objetivos() -> void:
	var mesa: MesaHechizos = MesaHechizos.new()
	var turno: Turno = mesa.turno()
	assert_array(turno.objetivos_para_hechizo("martillazo")).is_empty()
	_assert_motivo(turno, "martillazo", ResultadoAccion.Motivo.SIN_OBJETIVOS)
	for id_unidad in _ids(mesa):
		assert_bool(turno.validar(Accion.hechizo("martillazo", id_unidad)).valida).override_failure_message(
				id_unidad).is_false()
	_assert_motivo(turno, "remiendo", ResultadoAccion.Motivo.NINGUNO)


# Sistema.md 2.3: sin el mana del costo, MANA_INSUFICIENTE, como validar.
func test_sin_mana() -> void:
	var mesa: MesaHechizos = MesaHechizos.new({Maestro.ID: Vector2i(3, 4), "ocarra_s1": Vector2i(3, 2)})
	var turno: Turno = mesa.turno()
	# Despues del inicio del turno (la regeneracion ya corrio).
	mesa.plantel.maestro.mana = 3
	_assert_motivo(turno, "martillazo", ResultadoAccion.Motivo.NINGUNO)
	_assert_motivo(turno, "remiendo", ResultadoAccion.Motivo.MANA_INSUFICIENTE)
	assert_int(turno.validar(Accion.hechizo("remiendo", Maestro.ID)).motivo).is_equal(
			turno.motivo_hechizo("remiendo"))
	mesa.plantel.maestro.mana = 1
	for hechizo_id in _HECHIZOS:
		_assert_motivo(turno, hechizo_id, ResultadoAccion.Motivo.MANA_INSUFICIENTE)
		assert_int(turno.validar(Accion.hechizo(hechizo_id, "ocarra_s1", "empujar" if hechizo_id == "lanzadera" else ""))
				.motivo).is_equal(turno.motivo_hechizo(hechizo_id))


# Sistema.md 1.6: despues de un hechizo, ACCION_USADA, como validar; la
# consulta no cambia nada.
func test_accion_usada() -> void:
	var mesa: MesaHechizos = MesaHechizos.new({Maestro.ID: Vector2i(3, 4), "ocarra_s1": Vector2i(3, 2)})
	var turno: Turno = mesa.turno()
	assert_bool(turno.aplicar(Accion.hechizo("martillazo", "ocarra_s1")).valida).is_true()
	var foto: String = mesa.foto(turno)
	for hechizo_id in _HECHIZOS:
		_assert_motivo(turno, hechizo_id, ResultadoAccion.Motivo.ACCION_USADA)
		assert_int(turno.validar(Accion.hechizo(hechizo_id, Maestro.ID)).motivo).is_equal(
				turno.motivo_hechizo(hechizo_id))
	assert_str(mesa.foto(turno)).is_equal(foto)


# Una criatura no lanza hechizos (SOLO_MAESTRO); con el turno terminado,
# TURNO_TERMINADO. Siempre como validar.
func test_solo_maestro_y_turno_terminado() -> void:
	var mesa: MesaHechizos = MesaHechizos.new({Maestro.ID: Vector2i(3, 4), "rodauva_1": Vector2i(3, 3)})
	var turno: Turno = mesa.turno("rodauva_1")
	_assert_motivo(turno, "remiendo", ResultadoAccion.Motivo.SOLO_MAESTRO)
	assert_int(turno.validar(Accion.hechizo("remiendo", "rodauva_1")).motivo).is_equal(
			turno.motivo_hechizo("remiendo"))
	var del_maestro: Turno = mesa.turno()
	assert_bool(del_maestro.aplicar(Accion.terminar()).valida).is_true()
	_assert_motivo(del_maestro, "remiendo", ResultadoAccion.Motivo.TURNO_TERMINADO)
	assert_int(del_maestro.validar(Accion.hechizo("remiendo", Maestro.ID)).motivo).is_equal(
			del_maestro.motivo_hechizo("remiendo"))
