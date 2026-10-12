extends GdUnitTestSuite

# Arquitectura.md B.4 (T27), criterio 1: el dato nuevo vida_al_guardar_caida
# (Sistema.md 11.5 y 11.1 v1.7) y la regla GuardadoCaida con fixtures (A.6). El
# combate.json de fixtures lo lleva en 1 (D-009) y el alcance en 2. La carga de
# datos/ real esta en pruebas/datos/test_guardar_caida_a.gd.
const _COMBATE: String = "res://pruebas/fixtures/combate/combate.json"


func test_la_regla_lee_vida_y_alcance_del_fixture() -> void:
	var regla: GuardadoCaida = DatosFixture.guardado_caida()
	assert_object(regla).is_not_null()
	assert_int(regla.vida()).is_equal(1)
	assert_int(regla.alcance()).is_equal(2)


# A.2.2: un combate.json sin el campo no valida contra el esquema, y sin el dato
# (o sin los costos) no hay regla.
func test_sin_el_campo_no_valida_ni_arma() -> void:
	var lectura: Dictionary = LectorFixture.leer(_COMBATE, "combate")
	assert_array(lectura["errores"]).is_empty()
	var tabla: Dictionary = lectura["datos"]
	var sin: Dictionary = tabla.duplicate(true)
	sin.erase("vida_al_guardar_caida")
	var esquema: Dictionary = Cargador.new().esquema_resuelto("res://datos", "combate")["esquema"]
	var errores: Array = Validador.new().validar(sin, esquema, "combate.json")["errores"]
	assert_array(errores).is_not_empty()
	assert_str(str(errores)).contains("vida_al_guardar_caida")
	assert_object(GuardadoCaida.desde_datos(sin, DatosFixture.costos_mana())).is_null()
	var sin_alcance: Dictionary = tabla.duplicate(true)
	sin_alcance.erase("alcance_guardar_caida")
	assert_object(GuardadoCaida.desde_datos(sin_alcance, DatosFixture.costos_mana())).is_null()
	assert_object(GuardadoCaida.desde_datos(tabla, null)).is_null()
