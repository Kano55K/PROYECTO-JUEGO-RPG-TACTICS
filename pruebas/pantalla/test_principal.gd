extends GdUnitTestSuite

# Arquitectura.md A.6 y B.2 (T13, sesion 1): la escena principal, con el runner
# de escenas de GdUnit4. Arranque bloqueado con datos rotos, selector con los
# escenarios reales y lista de claves usadas que llega al Cargador.
const _ESCENA: String = "res://pantalla/principal.tscn"
const _DATOS_ROTOS: String = "res://pruebas/fixtures/cargador/un_error_ningun_dato"


func _principal(carpeta: String) -> GdUnitSceneRunner:
	# Con una instancia, el runner no la libera: auto_free la libera al terminar.
	var principal: Principal = auto_free(load(_ESCENA).instantiate())
	principal.carpeta_datos = carpeta
	return scene_runner(principal)


# (1) Con datos rotos, el juego no arranca: pantalla de error con archivo y campo.
func test_datos_rotos_muestran_error() -> void:
	var runner: GdUnitSceneRunner = _principal(_DATOS_ROTOS)
	await runner.simulate_frames(1)
	assert_bool(runner.find_child("PantallaError").visible).is_true()
	assert_str((runner.find_child("TextoErrores") as Label).text).contains("especies/rodauva.json").contains("vida")
	assert_bool(runner.find_child("SelectorEscenario").visible).is_false()
	assert_object((runner.scene() as Principal).vista()).is_null()


# (2) Con datos/ real arranca sin errores y lista los 11 escenarios.
func test_datos_reales_listan_los_escenarios() -> void:
	var runner: GdUnitSceneRunner = _principal("res://datos")
	await runner.simulate_frames(1)
	var principal: Principal = runner.scene()
	assert_array(principal.errores()).override_failure_message(str(principal.errores())).is_empty()
	assert_bool(runner.find_child("PantallaError").visible).is_false()
	assert_bool(runner.find_child("SelectorEscenario").visible).is_true()
	var ids: Array[String] = principal.ids_escenarios()
	assert_int(ids.size()).is_equal(11)
	var textos_botones: Array[String] = []
	for boton in runner.find_child("SelectorEscenario").get_children():
		textos_botones.append((boton as Button).text)
	assert_array(textos_botones).is_equal(ids)
	assert_array(ids).contains(["a_dia_1", "c_tasajero", "g_ataque_nocturno"])


# (5) La lista de claves usadas llega al Cargador: una clave que falta en un
# fixture de textos aparece como aviso, y no bloquea el arranque.
func test_clave_faltante_es_un_aviso() -> void:
	var runner: GdUnitSceneRunner = _principal("res://pruebas/fixtures/pantalla/textos_incompletos")
	await runner.simulate_frames(1)
	var principal: Principal = runner.scene()
	assert_array(principal.errores()).is_empty()
	var faltantes: Array[String] = []
	for aviso in principal.avisos():
		if aviso["esperado"] == "presente en el archivo":
			faltantes.append(aviso["campo"])
	assert_array(faltantes).contains([ClavesTextos.MARCA_CAZA, ClavesTextos.MAESTRO_NOMBRE])
	assert_array(faltantes).not_contains([ClavesTextos.MARCA_CUENTA])
	assert_bool(runner.find_child("SelectorEscenario").visible).is_true()
