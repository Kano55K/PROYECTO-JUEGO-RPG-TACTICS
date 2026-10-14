# Arquitectura.md B.2 (T13): la carpeta de datos sale de un parametro. Por
# defecto res://datos; por linea de comandos, `-- --datos=<carpeta>`.
# T32 (D-013): la vista del tablero, `-- --vista=<nombre>`; por defecto la de
# VistasTablero. Un nombre desconocido se devuelve tal cual: lo rechaza VistasTablero.
class_name ArgumentosPantalla
extends RefCounted

const CARPETA_POR_DEFECTO: String = "res://datos"
const _PREFIJO_DATOS: String = "--datos="
const _PREFIJO_VISTA: String = "--vista="


# args: OS.get_cmdline_user_args(), los argumentos que van despues de `--`.
static func carpeta_datos(args: PackedStringArray) -> String:
	return _valor(args, _PREFIJO_DATOS, CARPETA_POR_DEFECTO)


static func vista(args: PackedStringArray) -> String:
	return _valor(args, _PREFIJO_VISTA, VistasTablero.POR_DEFECTO)


# Un argumento vacio (`--datos=`) se ignora.
static func _valor(args: PackedStringArray, prefijo: String, por_defecto: String) -> String:
	for argumento in args:
		if argumento.begins_with(prefijo) and argumento.length() > prefijo.length():
			return argumento.substr(prefijo.length())
	return por_defecto
