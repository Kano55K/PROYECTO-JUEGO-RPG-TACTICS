extends GdUnitTestSuite

# Arquitectura.md B.3 (T23) y D-011: lo que escribe herramientas/reproducir.gd
# (SalidaReproduccion), con fixtures (A.6). Test (10) del criterio de terminado:
# una grabacion terminada deja su _resultado.json, que valida; una cortada con
# N, no.
const _VICTORIA: String = "res://pruebas/fixtures/combate/contrato/contrato_victoria.json"


func _grabacion() -> Grabacion:
	var datos: Dictionary = DatosFixture.cargar()["datos"]
	var escenario: Dictionary = LectorFixture.leer(_VICTORIA, "escenario")["datos"]
	var combate: Combate = Combate.empezar(ContextoCombate.armar(escenario, datos))
	assert_bool(combate.aplicar(Accion.mover(Vector2i(2, 5))).valida).is_true()
	assert_bool(combate.aplicar(Accion.atacar("ocarra_s1")).valida).is_true()
	assert_bool(combate.terminado()).is_true()
	return Grabacion.desde_combate(combate)


func test_t23_escribe_el_resultado_de_una_grabacion_terminada() -> void:
	var reproduccion: Reproductor = Reproductor.reproducir(_grabacion(), DatosFixture.cargar()["datos"])
	assert_str(reproduccion.error).is_empty()
	var carpeta: String = create_temp_dir("t23_reproducir")
	var salidas: Array[String] = SalidaReproduccion.escribir(reproduccion.combate, "c:/algo/partida_vieja.json", -1,
			carpeta)
	assert_int(salidas.size()).is_equal(2)
	assert_str(salidas[0].get_file()).is_equal("partida_vieja.jsonl")
	assert_str(salidas[1].get_file()).is_equal("partida_vieja_resultado.json")
	var leido: Variant = JSON.parse_string(FileAccess.get_file_as_string(carpeta.path_join("partida_vieja_resultado.json")))
	var esquema: Dictionary = Cargador.new().esquema_resuelto("res://datos", "resultado")["esquema"]
	var validacion: Dictionary = Validador.new().validar(leido, esquema, "resultado")
	assert_array(validacion["errores"] as Array).override_failure_message(str(validacion["errores"])).is_empty()
	assert_dict(validacion["datos"]).is_equal(reproduccion.combate.resultado().a_diccionario())


func test_t23_cortada_con_n_no_escribe_resultado() -> void:
	var reproduccion: Reproductor = Reproductor.reproducir(_grabacion(), DatosFixture.cargar()["datos"], 1)
	assert_bool(reproduccion.combate.terminado()).is_false()
	var carpeta: String = create_temp_dir("t23_reproducir_n")
	var salidas: Array[String] = SalidaReproduccion.escribir(reproduccion.combate, "partida.json", 1, carpeta)
	assert_int(salidas.size()).is_equal(1)
	assert_str(salidas[0].get_file()).is_equal("partida_hasta_1.jsonl")
	assert_bool(FileAccess.file_exists(carpeta.path_join("partida_hasta_1_resultado.json"))).is_false()
