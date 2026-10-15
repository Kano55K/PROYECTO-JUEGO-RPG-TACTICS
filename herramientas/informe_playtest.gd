# Arquitectura.md D-015 (T33, sesion 3): junta un lote de partidas de playtest
# y escribe el informe de las alarmas de Sistema.md 11.9. Lee los
# <nombre>_resultado.json de la carpeta y sus <nombre>_playtest.json, y escribe
# en la misma carpeta informe_playtest.json e informe_playtest.csv (una fila por
# combate). La escritura vive en SalidaInformePlaytest; las cuentas, en
# AlarmasPlaytest.
#
#   "%GODOT_BIN%" --headless --path . --script res://herramientas/informe_playtest.gd -- [carpeta]
#
# carpeta: por defecto res://registros; una ruta relativa sale de la raiz del
# proyecto. Usa los datos de res://datos (umbrales de playtest/alarmas.json).
# Sale con codigo 1 si los datos no cargan o los argumentos estan mal.
extends SceneTree

const _CARPETA_DATOS: String = "res://datos"
const _CARPETA_REGISTROS: String = "res://registros"


func _initialize() -> void:
	quit(_correr(OS.get_cmdline_user_args()))


func _correr(argumentos: PackedStringArray) -> int:
	if argumentos.size() > 1:
		printerr("Uso: --script res://herramientas/informe_playtest.gd -- [carpeta]")
		return 1
	var carpeta: String = _CARPETA_REGISTROS
	if argumentos.size() == 1:
		carpeta = argumentos[0]
		if carpeta.is_relative_path():
			carpeta = "res://" + carpeta
	var carga: Dictionary = Cargador.new().cargar_carpeta(_CARPETA_DATOS)
	if carga["datos"] == null:
		for error in (carga["errores"] as Array):
			printerr("datos: " + str(error))
		return 1
	var salida: Dictionary = SalidaInformePlaytest.escribir(ProjectSettings.globalize_path(carpeta), carga["datos"])
	for linea in (salida["resumen"] as Array):
		print(linea)
	for ruta in (salida["escritas"] as Array):
		print("Escrito: " + str(ruta))
	return 0
