# Arquitectura.md A.7 y B.2 (T13, sesion 2): al terminar el combate, la pantalla
# guarda sola la grabacion (.json) y el registro (.jsonl, una linea por evento)
# como <escenario>_<semilla>_<n>. n es el primer numero libre de la carpeta, asi
# no se pisa una partida anterior. Lo reproduce herramientas/reproducir.gd.
# T23 (D-011): ademas, el resultado con sus metricas, como <...>_<n>_resultado.json.
class_name GuardadoCombate
extends RefCounted

const SUFIJO_RESULTADO: String = "_resultado.json"
# T31: una variante editada en el panel se guarda como
# <escenario>_editado_<semilla>_<n>, para no mezclarla con las del archivo.
const SUFIJO_EDITADO: String = "_editado"


# Devuelve la ruta sin extension, o "" si no se pudo escribir. editado: si el
# escenario jugado difiere del archivo (EdicionEscenario.difiere).
static func guardar(combate: Combate, carpeta: String, editado: bool = false) -> String:
	DirAccess.make_dir_recursive_absolute(carpeta)
	var prefijo: String = "%s%s_%d_" % [combate.contexto().escenario_id, SUFIJO_EDITADO if editado else "",
			combate.contexto().semilla]
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
	if combate.resultado() != null and not guardar_resultado(combate, base):
		return ""
	return base


# T23: el resultado del combate (A.7), con las metricas, en base + SUFIJO_RESULTADO.
# Lo usa tambien herramientas/reproducir.gd. false si el combate no tiene
# resultado (no termino) o no se pudo escribir.
static func guardar_resultado(combate: Combate, base: String) -> bool:
	if combate.resultado() == null:
		return false
	return _escribir(base + SUFIJO_RESULTADO, JSON.stringify(combate.resultado().a_diccionario(), "\t", true))


static func _escribir(ruta: String, contenido: String) -> bool:
	var archivo: FileAccess = FileAccess.open(ruta, FileAccess.WRITE)
	if archivo == null:
		push_error("No se pudo escribir " + ruta)
		return false
	archivo.store_string(contenido)
	archivo.close()
	return true
