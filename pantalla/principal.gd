# Arquitectura.md A.2 y B.2 (T13): la escena principal. Carga los datos con el
# Cargador desde una carpeta que llega por parametro y, con un solo error, no
# arranca: muestra archivo, campo y valor esperado de cada error y nada mas.
# Los avisos van a la consola y al panel de depuracion, sin bloquear. El
# selector y la pantalla de error son de desarrollo: muestran ids sin textos.
# La accion `recargar` vuelve a leer los datos del disco y reinicia el
# escenario abierto, asi un cambio de balance se prueba sin cerrar el juego.
# T31: el selector abre el panel de parametros del escenario, y Jugar juega la
# variante. Las variantes viven en memoria (una por escenario) y la recarga las
# rearma sobre los datos nuevos.
# T33 (D-015): el campo "Jugador" (junto al selector) y la variante del panel van
# a la vista para la ficha de playtest; el panel recibe las semillas de playtest.
class_name Principal
extends Control

const _ESCENA_VISTA: PackedScene = preload("res://pantalla/combate/vista_combate.tscn")
const _PREFIJO_ESCENARIOS: String = "escenarios/"
const _ACCION_RECARGAR: String = "recargar"
const _ESQUEMA_ESCENARIO: String = "escenario"

# Vacia: se usa la linea de comandos (`-- --datos=<carpeta>`) o res://datos.
@export var carpeta_datos: String = ""
# Vacia: res://registros (donde la vista guarda grabacion y registro).
@export var carpeta_registros: String = ""
# T32 (D-013). Vacia: se usa la linea de comandos (`-- --vista=<nombre>`) o la
# vista por defecto de VistasTablero.
@export var vista_tablero: String = ""

var _carpeta: String = ""
var _datos: Dictionary = {}
var _errores: Array[Dictionary] = []
var _avisos: Array[Dictionary] = []
var _vista: VistaCombate = null
# El id del escenario abierto (sigue aunque una recarga muestre errores), o "".
var _escenario_actual: String = ""
# T31: el esquema escenario resuelto (para EdicionEscenario) y la variante de
# cada escenario abierto en el panel (id -> EdicionEscenario). Se pierden al
# cerrar el juego.
var _esquema_escenario: Dictionary = {}
var _variantes: Dictionary = {}

@onready var _pantalla_error: Control = $PantallaError
@onready var _texto_errores: Label = $PantallaError/TextoErrores
@onready var _selector: VBoxContainer = $SelectorEscenario
# T33 (D-015): quien juega, para la ficha de playtest. Junto al selector y fuera
# de SelectorEscenario (que solo tiene los botones). En memoria.
@onready var _campo_jugador: HBoxContainer = $CampoJugador
@onready var _jugador: LineEdit = $CampoJugador/Jugador
@onready var _panel: PanelParametros = $PanelParametros
@onready var _contenedor_vista: Node = $ContenedorVista


func _ready() -> void:
	_panel.jugar.connect(_jugar_variante)
	_panel.volver.connect(_volver_al_selector)
	_carpeta = carpeta_datos
	if _carpeta.is_empty():
		_carpeta = ArgumentosPantalla.carpeta_datos(OS.get_cmdline_user_args())
	if vista_tablero.is_empty():
		vista_tablero = ArgumentosPantalla.vista(OS.get_cmdline_user_args())
	if not _vista_valida():
		return
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


func panel() -> PanelParametros:
	return _panel


# T33: lo escrito en "Jugador", o null si esta vacio.
func jugador() -> Variant:
	var nombre: String = _jugador.text.strip_edges()
	return null if nombre.is_empty() else nombre


func campo_jugador() -> LineEdit:
	return _jugador


# T31: la variante del escenario (la ultima que se edito, o una copia del
# archivo la primera vez).
func variante(escenario_id: String) -> EdicionEscenario:
	if not _variantes.has(escenario_id):
		_variantes[escenario_id] = EdicionEscenario.new(_escenario(escenario_id), _datos, _esquema_escenario)
	return _variantes[escenario_id]


# T31: el panel de parametros del escenario. no_aplicados: los cambios que
# una recarga no pudo volver a aplicar.
func abrir_panel(escenario_id: String, no_aplicados: Array[Dictionary] = []) -> PanelParametros:
	_cerrar_vista()
	_ver_selector(false)
	_escenario_actual = escenario_id
	_panel.abrir(variante(escenario_id), no_aplicados, _semillas_playtest())
	_panel.visible = true
	return _panel


# Juega la variante del escenario si se abrio su panel; si no, el archivo.
func abrir_escenario(escenario_id: String) -> VistaCombate:
	_cerrar_vista()
	_ver_selector(false)
	_panel.visible = false
	_escenario_actual = escenario_id
	var escenario: Dictionary = _escenario(escenario_id)
	var editado: bool = false
	var cambios: Dictionary = {}
	if _variantes.has(escenario_id):
		var edicion: EdicionEscenario = _variantes[escenario_id]
		escenario = edicion.escenario()
		editado = edicion.difiere()
		cambios = edicion.cambios()
	_vista = _ESCENA_VISTA.instantiate()
	_vista.vista_tablero = vista_tablero
	_contenedor_vista.add_child(_vista)
	_vista.volver.connect(_volver_al_selector)
	_vista.empezar(escenario, _datos, _avisos, carpeta_registros, editado, cambios, jugador())
	return _vista


# Vuelve a leer la carpeta de datos. Con un error, solo la pantalla de error;
# si no, reinicia el escenario abierto (o el selector, si no habia ninguno o
# ya no existe). T31: las variantes se rearman sobre los datos nuevos; si la
# del escenario abierto ya no valida (o un cambio no se pudo volver a aplicar),
# o si se estaba en el panel, vuelve al panel con el error.
func recargar() -> void:
	if not _vista_valida():
		return
	var en_panel: bool = _panel.visible
	_cerrar_vista()
	_panel.visible = false
	print("[datos] recargando ", _carpeta)
	if not _cargar():
		return
	var no_aplicados: Dictionary = _rearmar_variantes()
	if not ids_escenarios().has(_escenario_actual):
		_escenario_actual = ""
		_mostrar_selector()
		return
	var pendientes: Array[Dictionary] = no_aplicados.get(_escenario_actual, [] as Array[Dictionary])
	var invalida: bool = _variantes.has(_escenario_actual) \
			and not (_variantes[_escenario_actual] as EdicionEscenario).validar().is_empty()
	if en_panel or invalida or not pendientes.is_empty():
		abrir_panel(_escenario_actual, pendientes)
	else:
		abrir_escenario(_escenario_actual)


# T31: cada variante pasa a los datos recien leidos con sus cambios. Las de
# escenarios que ya no existen se descartan. Devuelve id -> [{ruta, motivo}].
func _rearmar_variantes() -> Dictionary:
	var no_aplicados: Dictionary = {}
	var existentes: Array[String] = ids_escenarios()
	for escenario_id in _variantes.keys():
		if not existentes.has(escenario_id):
			_variantes.erase(escenario_id)
			continue
		var rearmada: Dictionary = (_variantes[escenario_id] as EdicionEscenario).sobre(
				_escenario(escenario_id), _datos, _esquema_escenario)
		_variantes[escenario_id] = rearmada["edicion"]
		no_aplicados[escenario_id] = rearmada["no_aplicados"]
	return no_aplicados


func _jugar_variante() -> void:
	abrir_escenario(_escenario_actual)


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
	# Los datos validaron contra este mismo esquema: no puede faltar.
	_esquema_escenario = cargador.esquema_resuelto(_carpeta, _ESQUEMA_ESCENARIO)["esquema"]
	_pantalla_error.visible = false
	_informar_avisos(ClavesTextos.usadas(_datos))
	return true


func _escenario(escenario_id: String) -> Dictionary:
	for ruta in _datos.keys():
		if (ruta as String).begins_with(_PREFIJO_ESCENARIOS) and (_datos[ruta] as Dictionary)["id"] == escenario_id:
			return _datos[ruta]
	return {}


# T33: las semillas de playtest/alarmas.json (vacia si los datos no lo traen).
func _semillas_playtest() -> Array:
	return (_datos.get(AlarmasPlaytest.ARCHIVO, {}) as Dictionary).get("semillas", [])


func _ver_selector(visible_ahora: bool) -> void:
	_selector.visible = visible_ahora
	_campo_jugador.visible = visible_ahora


func _cerrar_vista() -> void:
	if _vista == null:
		return
	_contenedor_vista.remove_child(_vista)
	_vista.queue_free()
	_vista = null


func _volver_al_selector() -> void:
	_cerrar_vista()
	_panel.visible = false
	_escenario_actual = ""
	_mostrar_selector()


# T32 (D-013): con una vista desconocida el juego no arranca: solo la pantalla
# de error (de desarrollo), sin datos ni selector.
func _vista_valida() -> bool:
	var error: String = VistasTablero.error(vista_tablero)
	if error.is_empty():
		return true
	printerr("[vista] ", error)
	_texto_errores.text = error
	_pantalla_error.visible = true
	_ver_selector(false)
	_panel.visible = false
	return false


func _mostrar_errores() -> void:
	var lineas: Array[String] = ["Los datos de %s tienen errores. El juego no arranca." % _carpeta, ""]
	for error in _errores:
		var linea: String = "%s · %s · esperado: %s · recibido: %s" % [error["archivo"], error["campo"],
				error["esperado"], str(error["recibido"])]
		lineas.append(linea)
		printerr("[datos] ", linea)
	_texto_errores.text = "\n".join(lineas)
	_pantalla_error.visible = true
	_ver_selector(false)
	_panel.visible = false


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
		boton.pressed.connect(abrir_panel.bind(escenario_id, [] as Array[Dictionary]))
		_selector.add_child(boton)
	_ver_selector(true)
