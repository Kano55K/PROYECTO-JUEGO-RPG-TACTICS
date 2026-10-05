# Arquitectura.md A.2 y B.2 (T13): la escena principal. Carga los datos con el
# Cargador desde una carpeta que llega por parametro y, con un solo error, no
# arranca: muestra archivo, campo y valor esperado de cada error y nada mas.
# Los avisos van a la consola y al panel de depuracion, sin bloquear. El
# selector y la pantalla de error son de desarrollo: muestran ids sin textos.
# La accion `recargar` vuelve a leer los datos del disco y reinicia el
# escenario abierto, asi un cambio de balance se prueba sin cerrar el juego.
class_name Principal
extends Control

const _ESCENA_VISTA: PackedScene = preload("res://pantalla/combate/vista_combate.tscn")
const _PREFIJO_ESCENARIOS: String = "escenarios/"
const _ACCION_RECARGAR: String = "recargar"

# Vacia: se usa la linea de comandos (`-- --datos=<carpeta>`) o res://datos.
@export var carpeta_datos: String = ""
# Vacia: res://registros (donde la vista guarda grabacion y registro).
@export var carpeta_registros: String = ""

var _carpeta: String = ""
var _datos: Dictionary = {}
var _errores: Array[Dictionary] = []
var _avisos: Array[Dictionary] = []
var _vista: VistaCombate = null
# El id del escenario abierto (sigue aunque una recarga muestre errores), o "".
var _escenario_actual: String = ""

@onready var _pantalla_error: Control = $PantallaError
@onready var _texto_errores: Label = $PantallaError/TextoErrores
@onready var _selector: VBoxContainer = $SelectorEscenario
@onready var _contenedor_vista: Node = $ContenedorVista


func _ready() -> void:
	_carpeta = carpeta_datos
	if _carpeta.is_empty():
		_carpeta = ArgumentosPantalla.carpeta_datos(OS.get_cmdline_user_args())
	if _cargar():
		_mostrar_selector()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(_ACCION_RECARGAR):
		get_viewport().set_input_as_handled()
		recargar()


func errores() -> Array[Dictionary]:
	return _errores


func avisos() -> Array[Dictionary]:
	return _avisos


# Los id de los escenarios cargados, en orden.
func ids_escenarios() -> Array[String]:
	var ids: Array[String] = []
	for ruta in _datos.keys():
		if (ruta as String).begins_with(_PREFIJO_ESCENARIOS):
			ids.append((_datos[ruta] as Dictionary)["id"])
	ids.sort()
	return ids


# null mientras no se eligio un escenario.
func vista() -> VistaCombate:
	return _vista


func abrir_escenario(escenario_id: String) -> VistaCombate:
	_cerrar_vista()
	_selector.visible = false
	_escenario_actual = escenario_id
	_vista = _ESCENA_VISTA.instantiate()
	_contenedor_vista.add_child(_vista)
	_vista.volver.connect(_volver_al_selector)
	_vista.empezar(_escenario(escenario_id), _datos, _avisos, carpeta_registros)
	return _vista


# Vuelve a leer la carpeta de datos. Con un error, solo la pantalla de error;
# si no, reinicia el escenario abierto (o el selector, si no habia ninguno o
# ya no existe).
func recargar() -> void:
	_cerrar_vista()
	print("[datos] recargando ", _carpeta)
	if not _cargar():
		return
	if ids_escenarios().has(_escenario_actual):
		abrir_escenario(_escenario_actual)
	else:
		_escenario_actual = ""
		_mostrar_selector()


# Carga en dos pasos: las claves por especie y por estado de hambre salen de
# los datos, asi que la lista de claves va en la segunda. false si hubo errores
# (entonces queda la pantalla de error).
func _cargar() -> bool:
	var cargador: Cargador = Cargador.new()
	var primera: Dictionary = cargador.cargar_carpeta(_carpeta)
	var carga: Dictionary = primera
	if (primera["errores"] as Array).is_empty():
		carga = cargador.cargar_carpeta(_carpeta, ClavesTextos.usadas(primera["datos"]))
	_errores = carga["errores"]
	_avisos = carga["avisos"]
	if not _errores.is_empty():
		_datos = {}
		_mostrar_errores()
		return false
	_datos = carga["datos"]
	_pantalla_error.visible = false
	_informar_avisos(ClavesTextos.usadas(_datos))
	return true


func _escenario(escenario_id: String) -> Dictionary:
	for ruta in _datos.keys():
		if (ruta as String).begins_with(_PREFIJO_ESCENARIOS) and (_datos[ruta] as Dictionary)["id"] == escenario_id:
			return _datos[ruta]
	return {}


func _cerrar_vista() -> void:
	if _vista == null:
		return
	_contenedor_vista.remove_child(_vista)
	_vista.queue_free()
	_vista = null


func _volver_al_selector() -> void:
	_cerrar_vista()
	_escenario_actual = ""
	_mostrar_selector()


func _mostrar_errores() -> void:
	var lineas: Array[String] = ["Los datos de %s tienen errores. El juego no arranca." % _carpeta, ""]
	for error in _errores:
		var linea: String = "%s · %s · esperado: %s · recibido: %s" % [error["archivo"], error["campo"],
				error["esperado"], str(error["recibido"])]
		lineas.append(linea)
		printerr("[datos] ", linea)
	_texto_errores.text = "\n".join(lineas)
	_pantalla_error.visible = true
	_selector.visible = false


# Las claves faltantes una por una; de las sobrantes (en 0a, los textos de 0b),
# solo la cantidad. La lista entera queda en avisos() y en el panel de depuracion.
func _informar_avisos(claves_usadas: Array[String]) -> void:
	var sobrantes: int = 0
	for aviso in _avisos:
		if claves_usadas.has(aviso["campo"]):
			print("[textos] falta la clave %s en %s" % [aviso["campo"], aviso["archivo"]])
		else:
			sobrantes += 1
	if sobrantes > 0:
		print("[datos] %d avisos mas (claves de texto sin usar todavia)" % sobrantes)


# Rearma los botones: tras una recarga, los escenarios pueden ser otros.
func _mostrar_selector() -> void:
	_pantalla_error.visible = false
	for hijo in _selector.get_children():
		_selector.remove_child(hijo)
		hijo.queue_free()
	for escenario_id in ids_escenarios():
		var boton: Button = Button.new()
		boton.text = escenario_id
		boton.pressed.connect(abrir_escenario.bind(escenario_id))
		_selector.add_child(boton)
	_selector.visible = true
