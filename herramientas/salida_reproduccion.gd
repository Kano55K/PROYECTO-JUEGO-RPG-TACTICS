# Arquitectura.md A.6 y B.2 (T12; T23): lo que escribe herramientas/reproducir.gd
# al reproducir una grabacion: el registro (.jsonl) y, si el combate termino, el
# resultado con sus metricas (_resultado.json, D-011), asi se miden grabaciones
# viejas. Separado del script de consola para poder probarlo sin lanzar Godot.
class_name SalidaReproduccion
extends RefCounted


# combate: el reproducido. ruta_grabacion: el archivo leido (de ahi sale el
# nombre). hasta_n: el de la reproduccion (-1 = todas). carpeta: donde escribir.
# Devuelve las rutas escritas, en orden; vacio si algo no se pudo escribir.
static func escribir(combate: Combate, ruta_grabacion: String, hasta_n: int, carpeta: String) -> Array[String]:
	var escritas: Array[String] = []
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(carpeta))
	var nombre: String = ruta_grabacion.get_file().get_basename()
	if hasta_n >= 0:
		nombre += "_hasta_%d" % hasta_n
	var base: String = carpeta.path_join(nombre)
	var archivo: FileAccess = FileAccess.open(base + ".jsonl", FileAccess.WRITE)
	if archivo == null:
		printerr("No se pudo escribir " + base + ".jsonl")
		return []
	for linea in combate.registro().lineas_json():
		archivo.store_line(linea)
	archivo.close()
	escritas.append(ProjectSettings.globalize_path(base + ".jsonl"))
	if combate.terminado():
		if not GuardadoCombate.guardar_resultado(combate, base):
			printerr("No se pudo escribir " + base + GuardadoCombate.SUFIJO_RESULTADO)
			return []
		escritas.append(ProjectSettings.globalize_path(base + GuardadoCombate.SUFIJO_RESULTADO))
	return escritas
