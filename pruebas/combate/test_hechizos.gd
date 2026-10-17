extends GdUnitTestSuite

# Arquitectura.md B.3 (T22), criterios 1 y 11, y D-010: la regla Hechizos con el
# fixture de hechizos.json (escala vieja, D-009) y la accion `hechizo` de ida y
# vuelta por diccionario. Sistema.md 1.6 y 2.3.
const _CARPETA: String = "res://pruebas/fixtures/combate/"
const _FUENTES: Array[String] = ["res://nucleo/combate/hechizos.gd"]
const _AZAR_PROHIBIDO: Array[String] = ["GeneradorAzar", "randi", "randf", "RandomNumberGenerator"]


func _tabla() -> Dictionary:
	var lectura: Dictionary = LectorFixture.leer(_CARPETA + "hechizos.json", "hechizos")
	var errores: Array[Dictionary] = lectura["errores"]
	assert_array(errores).override_failure_message(str(errores)).is_empty()
	return lectura["datos"]


func _maestro() -> Dictionary:
	return DatosFixture.cargar()["datos"]["maestro.json"]


# D-010: base + por_poder x Poder (Martillazo 2 + 1 x Poder, Remiendo 3 + 1 x Poder).
func test_valor_segun_poder() -> void:
	var hechizos: Hechizos = Hechizos.desde_datos(_tabla(), _maestro())
	assert_array(hechizos.ids()).contains_exactly(["martillazo", "lanzadera", "remiendo"])
	assert_int(hechizos.valor("martillazo", 1)).is_equal(3)
	assert_int(hechizos.valor("martillazo", 3)).is_equal(5)
	assert_int(hechizos.valor("remiendo", 1)).is_equal(4)
	assert_int(hechizos.valor("remiendo", 3)).is_equal(6)
	assert_int(hechizos.hechizo("lanzadera")["danio_choque"]).is_equal(1)
	assert_dict(hechizos.hechizo("bola_de_fuego")).is_empty()


# Sin tabla, sin un hechizo del Maestro o sin los parametros de su efecto: null.
func test_sin_datos_completos_no_se_arma() -> void:
	assert_object(Hechizos.desde_datos({}, _maestro())).is_null()
	var maestro: Dictionary = _maestro()
	maestro["hechizos"] = ["martillazo", "soplido"]
	assert_object(Hechizos.desde_datos(_tabla(), maestro)).is_null()
	for parametro in ["base", "por_poder"]:
		var tabla: Dictionary = _tabla()
		((tabla["hechizos"] as Array)[0] as Dictionary).erase(parametro)
		assert_object(Hechizos.desde_datos(tabla, _maestro())).override_failure_message(parametro).is_null()
	for parametro in ["danio_choque", "casillas", "modos"]:
		var tabla: Dictionary = _tabla()
		((tabla["hechizos"] as Array)[1] as Dictionary).erase(parametro)
		assert_object(Hechizos.desde_datos(tabla, _maestro())).override_failure_message(parametro).is_null()


# Criterio 11: la accion va y vuelve por diccionario; lo mal formado da null.
func test_accion_hechizo_ida_y_vuelta() -> void:
	for accion in [Accion.hechizo("martillazo", "ocarra_s1"), Accion.hechizo("lanzadera", "rodauva_1", "atraer")]:
		var dicc: Dictionary = (accion as Accion).a_diccionario()
		var vuelta: Accion = Accion.desde_diccionario(dicc)
		assert_object(vuelta).is_not_null()
		assert_dict(vuelta.a_diccionario()).is_equal(dicc)
	assert_dict(Accion.hechizo("remiendo", Maestro.ID).a_diccionario()).is_equal(
			{"tipo": "hechizo", "hechizo": "remiendo", "objetivo": Maestro.ID})
	assert_dict(Accion.hechizo("lanzadera", "ocarra_s1", "empujar").a_diccionario()).is_equal(
			{"tipo": "hechizo", "hechizo": "lanzadera", "objetivo": "ocarra_s1", "sentido": "empujar"})
	for mal in [{"tipo": "hechizo", "hechizo": "martillazo"}, {"tipo": "hechizo", "objetivo": "ocarra_s1"},
			{"tipo": "hechizo", "hechizo": "lanzadera", "objetivo": "ocarra_s1", "sentido": 1},
			{"tipo": "hechizo", "hechizo": "lanzadera", "objetivo": "ocarra_s1", "sentido": ""},
			{"tipo": "hechizo", "hechizo": "martillazo", "objetivo": "ocarra_s1", "casilla": [1, 1]}]:
		assert_object(Accion.desde_diccionario(mal)).override_failure_message(str(mal)).is_null()


# Sin azar (requisito de T22): la regla no usa ningun generador.
func test_la_regla_no_usa_azar() -> void:
	for ruta in _FUENTES:
		var texto: String = FileAccess.get_file_as_string(ruta)
		for prohibido in _AZAR_PROHIBIDO:
			assert_bool(texto.contains(prohibido)).override_failure_message(ruta + ": " + prohibido).is_false()
