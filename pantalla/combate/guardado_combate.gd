# Arquitectura.md A.7 y B.2 (T13, sesion 2): al terminar el combate, la pantalla
# guarda sola la grabacion (.json) y el registro (.jsonl, una linea por evento)
# como <escenario>_<semilla>_<n>. n es el primer numero libre de la carpeta, asi
# no se pisa una partida anterior. Lo reproduce herramientas/reproducir.gd.
class_name GuardadoCombate
extends RefCounted


# Devuelve la ruta sin extension, o "" si no se pudo escribir.
static func guardar(combate: Combate, carpeta: String) -> String:
	DirAccess.make_dir_recursive_absolute(carpeta)
	var prefijo: String = "%s_%d_" % [combate.contexto().escenario_id, combate.contexto().semilla]
	var n: int = 1
	while FileAccess.file_exists(carpeta.path_join(prefijo + str(n)) + ".json"):
		n += 1
	var base: String = carpeta.path_join(prefijo + str(n))
	var grabacion: Dictionary = Grabacion.desde_combate(combate).a_diccionario()
	if not _escribir(base + ".json", JSON.stringify(grabacion, "\t", true)):
		return ""
	var lineas: Array[String] = combate.registro().lineas_json()
	if not _escribir(base + ".jsonl", "\n".join(lineas) + "\n"):
		return ""
	return base


static func _escribir(ruta: String, contenido: String) -> bool:
	var archivo: FileAccess = FileAccess.open(ruta, FileAccess.WRITE)
	if archivo == null:
		push_error("No se pudo escribir " + ruta)
		return false
	archivo.store_string(contenido)
	archivo.close()
	return true
