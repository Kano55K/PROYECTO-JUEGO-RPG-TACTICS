extends GdUnitTestSuite

# Arquitectura.md B.2 (T04, sesion 2): el contenido fijo de datos/ (especies,
# maestro, hechizos y relaciones) carga sin errores con el Cargador de T03.
# Cada caso copia los esquemas reales y solo los archivos que prueba a una
# carpeta temporal: asi pasan tambien los chequeos cruzados aunque el resto
# de datos/ (tablas y escenarios de la sesion 3) todavia no cargue.
const _CARPETA_DATOS: String = "res://datos"

const _ESPECIES: Array[String] = [
	"especies/ocarra.json", "especies/rodauva.json", "especies/surcon.json",
	"especies/tasajero.json", "especies/zancajunco.json",
]


# Arma user://tmp/<caso>/ con datos/_esquemas/ y los archivos pedidos.
func _armar_carpeta(caso: String, archivos: Array[String]) -> String:
	var carpeta: String = create_temp_dir("t04_contenido_fijo/" + caso)
	DirAccess.make_dir_recursive_absolute(carpeta.path_join("_esquemas"))
	for nombre in DirAccess.get_files_at(_CARPETA_DATOS.path_join("_esquemas")):
		if nombre.ends_with(".json"):
			_copiar("_esquemas/" + nombre, carpeta)
	for archivo in archivos:
		_copiar(archivo, carpeta)
	return carpeta


func _copiar(ruta_relativa: String, carpeta_destino: String) -> void:
	var destino: String = carpeta_destino.path_join(ruta_relativa)
	DirAccess.make_dir_recursive_absolute(destino.get_base_dir())
	var contenido: String = FileAccess.get_file_as_string(_CARPETA_DATOS.path_join(ruta_relativa))
	var archivo: FileAccess = FileAccess.open(destino, FileAccess.WRITE)
	archivo.store_string(contenido)
	archivo.close()


func _cargar_sin_errores(caso: String, archivos: Array[String]) -> Dictionary:
	var resultado: Dictionary = Cargador.new().cargar_carpeta(_armar_carpeta(caso, archivos))
	var errores: Array[Dictionary] = resultado["errores"]
	assert_array(errores).override_failure_message(str(errores)).is_empty()
	assert_object(resultado["datos"]).is_not_null()
	return resultado


func test_especies_cargan_sin_errores() -> void:
	var resultado: Dictionary = _cargar_sin_errores("especies", _ESPECIES)
	assert_int((resultado["datos"] as Dictionary).size()).is_equal(_ESPECIES.size())


func test_maestro_carga_sin_errores() -> void:
	_cargar_sin_errores("maestro", ["maestro.json"])


func test_hechizos_cargan_sin_errores() -> void:
	_cargar_sin_errores("hechizos", ["hechizos.json"])


# Con las especies, para que corran "especies existentes" y "pares sin repetir".
func test_relaciones_cargan_sin_errores() -> void:
	var archivos: Array[String] = _ESPECIES.duplicate()
	archivos.append("relaciones.json")
	_cargar_sin_errores("relaciones", archivos)


func test_contenido_fijo_junto_sin_errores_ni_avisos() -> void:
	var archivos: Array[String] = _ESPECIES.duplicate()
	archivos.append_array(["maestro.json", "hechizos.json", "relaciones.json"])
	var resultado: Dictionary = _cargar_sin_errores("junto", archivos)
	var avisos: Array[Dictionary] = resultado["avisos"]
	assert_array(avisos).override_failure_message(str(avisos)).is_empty()
	assert_int((resultado["datos"] as Dictionary).size()).is_equal(archivos.size())


# El cargador no cruza maestro.hechizos con hechizos.json; se cuida aca.
func test_hechizos_del_maestro_existen() -> void:
	var resultado: Dictionary = _cargar_sin_errores("hechizos_del_maestro", ["maestro.json", "hechizos.json"])
	var datos: Dictionary = resultado["datos"]
	var ids_hechizos: Array = []
	for hechizo in ((datos["hechizos.json"] as Dictionary)["hechizos"] as Array):
		ids_hechizos.append((hechizo as Dictionary)["id"])
	var del_maestro: Array = (datos["maestro.json"] as Dictionary)["hechizos"] as Array
	assert_array(del_maestro).is_not_empty()
	for id in del_maestro:
		assert_array(ids_hechizos).override_failure_message("falta el hechizo %s" % [id]).contains([id])
