# Arquitectura.md A.6 y B.2 (T12): reproduce un archivo de grabacion por consola
# y escribe el registro en registros/ como .jsonl (una linea por evento). T23:
# si el combate reproducido termino, tambien su resultado con las metricas
# (<nombre>_resultado.json, D-011). La escritura vive en SalidaReproduccion.
#
#   "%GODOT_BIN%" --headless --path . --script res://herramientas/reproducir.gd -- <grabacion.json> [N]
#
# N: detenerse despues de la N-esima accion del jugador (por defecto, todas).
# Usa los datos de res://datos. Sale con codigo 1 si algo falla.
extends SceneTree

const _CARPETA_DATOS: String = "res://datos"
const _CARPETA_REGISTROS: String = "res://registros"


func _initialize() -> void:
	quit(_correr(OS.get_cmdline_user_args()))


func _correr(argumentos: PackedStringArray) -> int:
	if argumentos.is_empty() or argumentos.size() > 2:
		printerr("Uso: --script res://herramientas/reproducir.gd -- <grabacion.json> [N]")
		return 1
	var ruta: String = argumentos[0]
	var hasta_n: int = -1
	if argumentos.size() == 2:
		if not argumentos[1].is_valid_int() or argumentos[1].to_int() < 0:
			printerr("N tiene que ser un entero >= 0: " + argumentos[1])
			return 1
		hasta_n = argumentos[1].to_int()

	var carga: Dictionary = Cargador.new().cargar_carpeta(_CARPETA_DATOS)
	if carga["datos"] == null:
		for error in (carga["errores"] as Array):
			printerr("datos: " + str(error))
		return 1

	if not FileAccess.file_exists(ruta):
		printerr("No existe la grabacion: " + ruta)
		return 1
	var texto: Variant = JSON.parse_string(FileAccess.get_file_as_string(ruta))
	if texto == null:
		printerr("La grabacion no es JSON valido: " + ruta)
		return 1
	var esquema: Dictionary = Cargador.new().esquema_resuelto(_CARPETA_DATOS, "grabacion")["esquema"]
	var validacion: Dictionary = Validador.new().validar(texto, esquema, ruta.get_file())
	if not (validacion["errores"] as Array).is_empty():
		for error in (validacion["errores"] as Array):
			printerr("grabacion: " + str(error))
		return 1

	var reproduccion: Reproductor = Reproductor.reproducir(
			Grabacion.desde_diccionario(validacion["datos"]), carga["datos"], hasta_n)
	if reproduccion.aviso_huella:
		print("AVISO: la huella de los datos no es la de la grabacion (cambiaron los datos)")
	if reproduccion.combate != null:
		var salidas: Array[String] = SalidaReproduccion.escribir(reproduccion.combate, ruta, hasta_n,
				_CARPETA_REGISTROS)
		if salidas.is_empty():
			return 1
		print("Registro: " + salidas[0])
		if salidas.size() > 1:
			print("Resultado: " + salidas[1])
	if not reproduccion.error.is_empty():
		printerr("ERROR: " + reproduccion.error)
		return 1
	return 0
