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
