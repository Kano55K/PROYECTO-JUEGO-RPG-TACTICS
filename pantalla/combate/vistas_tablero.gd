# Arquitectura.md D-013 (T32): el unico lugar que elige el TileSet del tablero.
# La isometrica es la vista por defecto; la cenital de T13 queda como vista de
# desarrollo (`-- --vista=cenital`). Tamanios y colores son presentacion, no
# datos de balance: viven en los .tres.
class_name VistasTablero
extends RefCounted

const ISOMETRICA: String = "isometrica"
const CENITAL: String = "cenital"
const POR_DEFECTO: String = ISOMETRICA
const NOMBRES: Array[String] = [ISOMETRICA, CENITAL]
const _TILE_SETS: Dictionary = {
	ISOMETRICA: "res://pantalla/combate/casillas_isometrica.tres",
	CENITAL: "res://pantalla/combate/casillas_cenital.tres",
}


static func existe(nombre: String) -> bool:
	return NOMBRES.has(nombre)


# null si la vista no existe.
static func tile_set(nombre: String) -> TileSet:
	if not existe(nombre):
		return null
	return load(_TILE_SETS[nombre]) as TileSet


# "" si la vista existe; si no, el error (pantalla de desarrollo, sin claves de texto).
static func error(nombre: String) -> String:
	if existe(nombre):
		return ""
	return "Vista desconocida: %s. Valores: %s." % [nombre, ", ".join(NOMBRES)]
