extends GdUnitTestSuite

# Arquitectura.md A.7 y B.2 (T13, sesion 2): el guardado de la grabacion (.json)
# y el registro (.jsonl) con el nombre <escenario>_<semilla>_<n>, sin nodos y
# con fixtures (A.6). n es el primer numero libre de la carpeta.
const _ESCENARIO: String = "res://pruebas/fixtures/combate/escenario_turno.json"


func _combate() -> Combate:
	var lectura: Dictionary = DatosFixture.cargar()
	assert_array(lectura["errores"]).override_failure_message(str(lectura["errores"])).is_empty()
	var escenario: Dictionary = LectorFixture.leer(_ESCENARIO, "escenario")["datos"]
	var contexto: ContextoCombate = ContextoCombate.armar(escenario, lectura["datos"])
	assert_bool(contexto.valido).is_true()
	return Combate.empezar(contexto)


func test_guarda_grabacion_y_registro_con_numero_libre() -> void:
	var combate: Combate = _combate()
	var carpeta: String = create_temp_dir("t13_guardado")
	var primera: String = GuardadoCombate.guardar(combate, carpeta)
	var segunda: String = GuardadoCombate.guardar(combate, carpeta)
	var nombre: String = "%s_%d_" % [combate.contexto().escenario_id, combate.contexto().semilla]
	assert_str(primera).is_equal(carpeta.path_join(nombre + "1"))
	assert_str(segunda).is_equal(carpeta.path_join(nombre + "2"))

	var lineas: PackedStringArray = FileAccess.get_file_as_string(primera + ".jsonl").split("\n", false)
	assert_array(Array(lineas)).is_equal(Array(combate.registro().lineas_json()))
	var grabacion: Variant = JSON.parse_string(FileAccess.get_file_as_string(primera + ".json"))
	assert_dict(grabacion).contains_keys(["version", "escenario", "huella", "acciones"])
	assert_str(grabacion["huella"]).is_equal(combate.contexto().huella)


func test_crea_la_carpeta_si_no_existe() -> void:
	var carpeta: String = create_temp_dir("t13_guardado_nueva").path_join("registros")
	assert_bool(DirAccess.dir_exists_absolute(carpeta)).is_false()
	assert_str(GuardadoCombate.guardar(_combate(), carpeta)).is_not_empty()
	assert_bool(DirAccess.dir_exists_absolute(carpeta)).is_true()


# (10) T23 (D-011): un combate terminado guarda tambien su resultado, con las
# metricas, en <escenario>_<semilla>_<n>_resultado.json, y valida contra el
# esquema. Uno sin terminar no lo escribe.
func test_t23_guarda_el_resultado() -> void:
	var lectura: Dictionary = DatosFixture.cargar()
	var escenario: Dictionary = LectorFixture.leer("res://pruebas/fixtures/combate/contrato/contrato_victoria.json",
			"escenario")["datos"]
	var combate: Combate = Combate.empezar(ContextoCombate.armar(escenario, lectura["datos"]))
	assert_bool(combate.aplicar(Accion.mover(Vector2i(2, 5))).valida).is_true()
	assert_bool(combate.aplicar(Accion.atacar("ocarra_s1")).valida).is_true()
	assert_bool(combate.terminado()).is_true()
	var carpeta: String = create_temp_dir("t23_guardado")
	var base: String = GuardadoCombate.guardar(combate, carpeta)
	assert_str(base).is_not_empty()
	var ruta: String = base + GuardadoCombate.SUFIJO_RESULTADO
	assert_str(ruta.get_file()).is_equal("contrato_victoria_%d_1_resultado.json" % combate.contexto().semilla)
	var leido: Variant = JSON.parse_string(FileAccess.get_file_as_string(ruta))
	var esquema: Dictionary = Cargador.new().esquema_resuelto("res://datos", "resultado")["esquema"]
	var validacion: Dictionary = Validador.new().validar(leido, esquema, "resultado")
	assert_array(validacion["errores"] as Array).override_failure_message(str(validacion["errores"])).is_empty()
	assert_dict(validacion["datos"]).is_equal(combate.resultado().a_diccionario())

	# Sin terminar: grabacion y registro, sin resultado.
	var a_medias: String = GuardadoCombate.guardar(_combate(), carpeta)
	assert_bool(FileAccess.file_exists(a_medias + ".json")).is_true()
	assert_bool(FileAccess.file_exists(a_medias + GuardadoCombate.SUFIJO_RESULTADO)).is_false()


# Juega contrato_victoria (o su variante) hasta la victoria, como el test (10).
func _jugar_contrato(escenario: Dictionary, datos: Dictionary) -> Combate:
	var combate: Combate = Combate.empezar(ContextoCombate.armar(escenario, datos))
	assert_bool(combate.aplicar(Accion.mover(Vector2i(2, 5))).valida).is_true()
	assert_bool(combate.aplicar(Accion.atacar("ocarra_s1")).valida).is_true()
	assert_bool(combate.terminado()).is_true()
	return combate


# (8) T31 (Arquitectura.md B.4): una variante editada en el panel guarda
# grabacion, registro y resultado como <escenario>_editado_<semilla>_<n>, y la
# grabacion se reproduce con el mismo registro (lleva el escenario entero, A.7).
# Sin cambios, el nombre es el de siempre.
func test_t31_variante_editada_lleva_sufijo_y_se_reproduce() -> void:
	var datos: Dictionary = DatosFixture.cargar()["datos"]
	var original: Dictionary = LectorFixture.leer("res://pruebas/fixtures/combate/contrato/contrato_victoria.json",
			"escenario")["datos"]
	var esquema: Dictionary = Cargador.new().esquema_resuelto("res://datos", "escenario")["esquema"]
	var carpeta: String = create_temp_dir("t31_guardado")

	var edicion: EdicionEscenario = EdicionEscenario.new(original, datos, esquema)
	assert_str(edicion.cambiar("pergaminos_en_blanco", 1)).is_empty()
	assert_bool(edicion.difiere()).is_true()
	assert_array(edicion.validar()).is_empty()
	var combate: Combate = _jugar_contrato(edicion.escenario(), datos)
	var base: String = GuardadoCombate.guardar(combate, carpeta, edicion.difiere())
	var semilla: int = combate.contexto().semilla
	assert_str(base.get_file()).is_equal("contrato_victoria%s_%d_1" % [GuardadoCombate.SUFIJO_EDITADO, semilla])
	for extension in [".json", ".jsonl", GuardadoCombate.SUFIJO_RESULTADO]:
		assert_bool(FileAccess.file_exists(base + extension)).override_failure_message(extension).is_true()

	var esquema_grabacion: Dictionary = Cargador.new().esquema_resuelto("res://datos", "grabacion")["esquema"]
	var validacion: Dictionary = Validador.new().validar(
			JSON.parse_string(FileAccess.get_file_as_string(base + ".json")), esquema_grabacion, "grabacion")
	assert_array(validacion["errores"] as Array).override_failure_message(str(validacion["errores"])).is_empty()
	var grabacion: Grabacion = Grabacion.desde_diccionario(validacion["datos"])
	var reproduccion: Reproductor = Reproductor.reproducir(grabacion, datos)
	assert_str(reproduccion.error).is_empty()
	assert_array(Array(reproduccion.combate.registro().lineas_json())) \
			.is_equal(Array(FileAccess.get_file_as_string(base + ".jsonl").split("\n", false)))
	assert_int(reproduccion.combate.contexto().escenario["pergaminos_en_blanco"] as int).is_equal(1)

	# Sin cambios: el nombre de siempre.
	var sin_cambios: EdicionEscenario = EdicionEscenario.new(original, datos, esquema)
	assert_bool(sin_cambios.difiere()).is_false()
	var base_archivo: String = GuardadoCombate.guardar(_jugar_contrato(sin_cambios.escenario(), datos), carpeta,
			sin_cambios.difiere())
	assert_str(base_archivo.get_file()).is_equal("contrato_victoria_%d_1" % semilla)
