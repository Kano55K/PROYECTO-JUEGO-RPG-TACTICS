extends GdUnitTestSuite

# Arquitectura.md A.11, D-008, y B.3 (T21-ajustes), criterio 1: ReglasCombate se
# crea con todas sus reglas; sin alguna, falla con el nombre de la que falta.
# Un solo test por la construccion incompleta, que recorre ReglasCombate.REGLAS.


func _armar(completas: ReglasCombate, sin: String) -> ReglasCombate:
	var de: Callable = func(nombre: String) -> Variant: return null if nombre == sin else completas.get(nombre)
	return ReglasCombate.new(de.call("danio"), de.call("afinidad"), de.call("combo"), de.call("incidente"),
			de.call("chequeo_rival"), de.call("regeneracion_mana"), de.call("hechizos"), de.call("sellado"),
			de.call("huida"), de.call("costos_mana"), de.call("guardado_caida"))


func test_construccion_incompleta_falla_con_el_nombre_de_la_que_falta() -> void:
	var completas: ReglasCombate = DatosFixture.reglas()
	assert_str(completas.falta).is_empty()
	for nombre in ReglasCombate.REGLAS:
		var incompletas: Array[ReglasCombate] = []
		await assert_error(func() -> void: incompletas.append(_armar(completas, nombre))) \
				.is_push_error("ReglasCombate: falta la regla " + nombre)
		assert_str(incompletas[0].falta).override_failure_message(nombre).is_equal(nombre)


# Arquitectura.md B.3 (T22), criterio 12b: ContextoCombate.armar con una regla que
# no se puede armar (datos sin hechizos.json) no es valido, con su motivo y el
# nombre de la regla; con todas, arma igual que antes.
func test_contexto_sin_una_regla_se_rechaza() -> void:
	var lectura: Dictionary = DatosFixture.cargar()
	var datos: Dictionary = lectura["datos"]
	var escenario: Dictionary = LectorFixture.leer("res://pruebas/fixtures/combate/escenario_hechizos.json",
			"escenario")["datos"]
	var completo: ContextoCombate = ContextoCombate.armar(escenario, datos)
	assert_bool(completo.valido).is_true()
	assert_int(completo.motivo).is_equal(ContextoCombate.Motivo.NINGUNO)
	assert_str(completo.regla_faltante).is_empty()
	assert_object(completo.hechizos).is_not_null()

	datos.erase("hechizos.json")
	var contextos: Array[ContextoCombate] = []
	await assert_error(func() -> void: contextos.append(ContextoCombate.armar(escenario, datos))) \
			.is_push_error("ReglasCombate: falta la regla hechizos")
	assert_bool(contextos[0].valido).is_false()
	assert_int(contextos[0].motivo).is_equal(ContextoCombate.Motivo.REGLA_FALTANTE)
	assert_str(contextos[0].regla_faltante).is_equal("hechizos")


# Arquitectura.md B.4 (T27), criterio 2 (deuda de T26): sin tablas/costos_mana.json
# tambien llegan nulas las reglas que la usan (sellado y guardado_caida), pero el
# rechazo nombra a la que de verdad falta.
func test_contexto_sin_costos_mana_nombra_costos_mana() -> void:
	var datos: Dictionary = DatosFixture.cargar()["datos"]
	var escenario: Dictionary = LectorFixture.leer("res://pruebas/fixtures/combate/escenario_hechizos.json",
			"escenario")["datos"]
	var completo: ContextoCombate = ContextoCombate.armar(escenario, datos)
	assert_bool(completo.valido).is_true()
	assert_object(completo.guardado_caida).is_not_null()

	datos.erase("tablas/costos_mana.json")
	var contextos: Array[ContextoCombate] = []
	await assert_error(func() -> void: contextos.append(ContextoCombate.armar(escenario, datos))) \
			.is_push_error("ReglasCombate: falta la regla costos_mana")
	assert_bool(contextos[0].valido).is_false()
	assert_int(contextos[0].motivo).is_equal(ContextoCombate.Motivo.REGLA_FALTANTE)
	assert_str(contextos[0].regla_faltante).is_equal("costos_mana")
