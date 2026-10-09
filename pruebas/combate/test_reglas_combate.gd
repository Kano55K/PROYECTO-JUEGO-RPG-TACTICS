extends GdUnitTestSuite

# Arquitectura.md A.11, D-008, y B.3 (T21-ajustes), criterio 1: ReglasCombate se
# crea con todas sus reglas; sin alguna, falla con el nombre de la que falta.
# Un solo test por la construccion incompleta, que recorre ReglasCombate.REGLAS.


func _armar(completas: ReglasCombate, sin: String) -> ReglasCombate:
	var de: Callable = func(nombre: String) -> Variant: return null if nombre == sin else completas.get(nombre)
	return ReglasCombate.new(de.call("danio"), de.call("afinidad"), de.call("combo"), de.call("incidente"),
			de.call("chequeo_rival"), de.call("regeneracion_mana"))


func test_construccion_incompleta_falla_con_el_nombre_de_la_que_falta() -> void:
	var completas: ReglasCombate = DatosFixture.reglas()
	assert_str(completas.falta).is_empty()
	for nombre in ReglasCombate.REGLAS:
		var incompletas: Array[ReglasCombate] = []
		await assert_error(func() -> void: incompletas.append(_armar(completas, nombre))) \
				.is_push_error("ReglasCombate: falta la regla " + nombre)
		assert_str(incompletas[0].falta).override_failure_message(nombre).is_equal(nombre)
