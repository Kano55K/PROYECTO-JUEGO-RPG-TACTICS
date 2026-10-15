extends GdUnitTestSuite

# T33, sesion 3, criterio (12): SalidaInformePlaytest (lo que hace
# herramientas/informe_playtest.gd) sobre una carpeta de fixtures copiada a una
# carpeta temporal, sin lanzar Godot. pruebas/fixtures/playtest/informe/: dos
# partidas de A (j1 y j2, sin cambios), una de C con cambios (jugador con coma y
# comillas, para el CSV), una de C sin ficha (semilla fuera de la lista) y un
# resultado roto. Datos de prueba de MesaPlaytest (semillas 11 a 20).
const _FIXTURES: String = "res://pruebas/fixtures/playtest/informe"
const _CSV_ESPERADO: String = "res://pruebas/fixtures/playtest/informe_esperado.csv"


func _copia(nombre: String) -> String:
	var carpeta: String = create_temp_dir(nombre)
	for archivo in DirAccess.get_files_at(_FIXTURES):
		if archivo.ends_with(".json"):
			DirAccess.copy_absolute(ProjectSettings.globalize_path(_FIXTURES.path_join(archivo)),
					carpeta.path_join(archivo))
	return carpeta


func _grupo(informe: Dictionary, escenario: String, variante: Variant) -> Dictionary:
	for grupo in (informe["grupos"] as Array):
		if grupo["escenario"] == escenario and grupo["variante"] == variante:
			return grupo
	return {}


func _tipos_aviso(informe: Dictionary) -> Array:
	return (informe["avisos"] as Array).map(func(aviso: Dictionary) -> String: return aviso["tipo"])


# Ningun float en todo el informe (D-015: solo enteros).
func _floats(valor: Variant, ruta: String = "") -> Array[String]:
	var encontrados: Array[String] = []
	if valor is float:
		encontrados.append(ruta)
	elif valor is Dictionary:
		for clave in (valor as Dictionary).keys():
			encontrados.append_array(_floats(valor[clave], ruta + "." + str(clave)))
	elif valor is Array:
		for i in range((valor as Array).size()):
			encontrados.append_array(_floats(valor[i], "%s[%d]" % [ruta, i]))
	return encontrados


func test_lee_resultados_fichas_y_avisos() -> void:
	var lectura: Dictionary = SalidaInformePlaytest.leer(_copia("t33_informe_leer"), MesaPlaytest.semillas())
	assert_array(lectura["archivos"] as Array).is_equal(
			["a_dia_1_11_1", "a_dia_1_12_1", "c_tasajero_99_1", "c_tasajero_editado_11_1"])
	assert_int((lectura["resultados"] as Array).size()).is_equal(4)
	# Sin ficha: jugador y variante desconocidos.
	assert_dict((lectura["fichas"] as Array)[2] as Dictionary).is_equal(
			{"escenario": "c_tasajero", "variante": null, "semilla": 99, "indice_semilla": null, "jugador": null})
	# Validados contra su esquema: los numeros son int.
	assert_int(typeof(((lectura["resultados"] as Array)[0] as Dictionary)["semilla"])).is_equal(TYPE_INT)
	var avisos: Array = lectura["avisos"]
	assert_array(avisos.map(func(aviso: Dictionary) -> String: return aviso["tipo"])).is_equal(
			[SalidaInformePlaytest.AVISO_SIN_FICHA, SalidaInformePlaytest.AVISO_RESULTADO_INVALIDO])
	assert_str((avisos[0] as Dictionary)["archivo"] as String).is_equal("c_tasajero_99_1_resultado.json")
	assert_str((avisos[1] as Dictionary)["archivo"] as String).is_equal("roto_resultado.json")


func test_escribe_el_informe_json_y_csv() -> void:
	var carpeta: String = _copia("t33_informe")
	var salida: Dictionary = SalidaInformePlaytest.escribir(carpeta, MesaPlaytest.datos())
	assert_array(salida["escritas"] as Array).is_equal([
			carpeta.path_join(SalidaInformePlaytest.ARCHIVO_JSON), carpeta.path_join(SalidaInformePlaytest.ARCHIVO_CSV)])

	var esperado: String = FileAccess.get_file_as_string(_CSV_ESPERADO)
	assert_str(FileAccess.get_file_as_string(carpeta.path_join(SalidaInformePlaytest.ARCHIVO_CSV))).is_equal(esperado)

	var informe: Dictionary = JSON.parse_string(
			FileAccess.get_file_as_string(carpeta.path_join(SalidaInformePlaytest.ARCHIVO_JSON)))
	assert_int(int(informe["partidas"])).is_equal(4)
	assert_int((informe["grupos"] as Array).size()).is_equal(3)
	var a: Dictionary = _grupo(informe, "a_dia_1", {})
	assert_int(int(a["partidas"])).is_equal(2)
	assert_int(int(a["jugadores"])).is_equal(2)
	for alarma in (a["alarmas"] as Array):
		assert_str(alarma["estado"] as String).override_failure_message(alarma["id"]).is_equal(
				AlarmasPlaytest.ESTADO_INSUFICIENTE)
		if alarma["id"] == "a_mismo_tramo":
			assert_int(int(alarma["valor"])).is_equal(100)
			assert_int(int(alarma["n"])).is_equal(1)
			assert_int(int(alarma["umbral"])).is_equal(80)
	var desconocida: Dictionary = _grupo(informe, "c_tasajero", null)
	assert_int(int(desconocida["partidas"])).is_equal(1)
	assert_int(int(desconocida["jugadores"])).is_equal(0)
	var editada: Dictionary = _grupo(informe, "c_tasajero",
			{"maestro.balanza": 4.0, "tribu.rodauva_1.estado": "guardada"})
	assert_int(int(editada["jugadores"])).is_equal(1)
	assert_array(_tipos_aviso(informe)).contains_exactly_in_any_order([AlarmasPlaytest.AVISO_SEMILLA_FUERA,
			SalidaInformePlaytest.AVISO_RESULTADO_INVALIDO, SalidaInformePlaytest.AVISO_SIN_FICHA])
	assert_bool(informe.has("comparaciones")).is_true()
	assert_bool(informe.has("informativas")).is_true()

	# En memoria, antes de escribir: ningun float.
	var lectura: Dictionary = SalidaInformePlaytest.leer(carpeta, MesaPlaytest.semillas())
	var en_memoria: Dictionary = SalidaInformePlaytest.informe(lectura, MesaPlaytest.datos())
	assert_array(_floats(en_memoria)).is_empty()

	# El resumen de la consola: por grupo, partidas, jugadores y las que saltaron.
	var resumen: String = "\n".join(salida["resumen"] as Array)
	assert_str(resumen).contains("a_dia_1 (sin cambios): 2 partidas, 2 jugadores")
	assert_str(resumen).contains("c_tasajero (variante desconocida): 1 partidas, 0 jugadores")
	assert_str(resumen).contains("Avisos: 3")


# Dentro del proyecto (registros/), el CSV va con su .import "keep": si no, el
# editor lo importa como archivo de traducciones. Fuera, no hace falta.
func test_dentro_del_proyecto() -> void:
	assert_bool(SalidaInformePlaytest.dentro_del_proyecto("res://registros")).is_true()
	assert_bool(SalidaInformePlaytest.dentro_del_proyecto(ProjectSettings.globalize_path("res://registros"))).is_true()
	assert_bool(SalidaInformePlaytest.dentro_del_proyecto(create_temp_dir("t33_fuera"))).is_false()
	var carpeta: String = _copia("t33_informe_import")
	SalidaInformePlaytest.escribir(carpeta, MesaPlaytest.datos())
	assert_bool(FileAccess.file_exists(carpeta.path_join(SalidaInformePlaytest.ARCHIVO_CSV + ".import"))).is_false()


func test_carpeta_vacia_o_inexistente() -> void:
	for carpeta in [create_temp_dir("t33_informe_vacia"), create_temp_dir("t33_informe_x").path_join("no_existe")]:
		var salida: Dictionary = SalidaInformePlaytest.escribir(carpeta, MesaPlaytest.datos())
		assert_array(salida["escritas"] as Array).is_empty()
		assert_str("\n".join(salida["resumen"] as Array)).contains("No hay resultados")
		assert_bool(FileAccess.file_exists(carpeta.path_join(SalidaInformePlaytest.ARCHIVO_JSON))).is_false()
		assert_bool(FileAccess.file_exists(carpeta.path_join(SalidaInformePlaytest.ARCHIVO_CSV))).is_false()
