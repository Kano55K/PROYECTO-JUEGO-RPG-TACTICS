# Arquitectura.md B.2 (T13): la carpeta de datos sale de un parametro. Por
# defecto res://datos; por linea de comandos, `-- --datos=<carpeta>`.
class_name ArgumentosPantalla
extends RefCounted

const CARPETA_POR_DEFECTO: String = "res://datos"
const _PREFIJO_DATOS: String = "--datos="


# args: OS.get_cmdline_user_args(), los argumentos que van despues de `--`.
static func carpeta_datos(args: PackedStringArray) -> String:
	for argumento in args:
		if argumento.begins_with(_PREFIJO_DATOS) and argumento.length() > _PREFIJO_DATOS.length():
			return argumento.substr(_PREFIJO_DATOS.length())
	return CARPETA_POR_DEFECTO
