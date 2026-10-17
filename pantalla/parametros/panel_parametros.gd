# Arquitectura.md B.4 (T31, sesion 2): el panel de parametros de un escenario.
# Pantalla de desarrollo (como el selector y el de depuracion): muestra rutas e
# ids, sin claves de texto. Se arma desde EdicionEscenario (un control por campo
# editable, con los limites del esquema) y no calcula nada: cada cambio va a la
# edicion y los errores salen de su validar(), que es la del Cargador. Los
# numeros nunca se recortan: un valor fuera de rango queda y se ve el error.
class_name PanelParametros
extends Control

signal jugar
signal volver

const _RUTA_SEMILLA: String = "semilla"
const _COLOR_ERROR: Color = Color(1, 0.45, 0.45, 1)
# T33: la opcion del selector de semilla de playtest cuando la semilla no es de
# la lista (la primera; las demas son "1" a "10").
const SIN_SEMILLA_PLAYTEST: String = "playtest -"

var _edicion: EdicionEscenario = null
# ruta -> el control del valor (SpinBox, OptionButton o CheckButton).
var _controles: Dictionary = {}
# ruta -> CheckBox "por defecto" (solo los campos que admiten null).
var _por_defecto: Dictionary = {}
# ruta -> Label con el nombre y los limites, y ruta -> Label del error.
var _nombres: Dictionary = {}
var _errores: Dictionary = {}
# ruta -> el motivo por el que el ultimo cambio de ese campo no se aplico.
var _motivos: Dictionary = {}
# [{ruta, motivo}] de los cambios que una recarga no pudo volver a aplicar.
var _no_aplicados: Array[Dictionary] = []
var _rutas: Array[String] = []
var _puede_jugar: bool = false
# T33 (D-015): las semillas de playtest/alarmas.json y su selector (null sin lista).
var _semillas_playtest: Array = []
var _semilla_playtest: OptionButton = null

@onready var _titulo: Label = $Contenido/Titulo
@onready var _boton_volver: Button = $Contenido/Botones/Volver
@onready var _boton_restaurar: Button = $Contenido/Botones/Restaurar
@onready var _boton_jugar: Button = $Contenido/Botones/Jugar
@onready var _errores_generales: Label = $Contenido/ErroresGenerales
@onready var _campos: GridContainer = $Contenido/Desplazable/Campos


func _ready() -> void:
	_boton_volver.pressed.connect(volver.emit)
	_boton_restaurar.pressed.connect(pulsar_restaurar)
	_boton_jugar.pressed.connect(pulsar_jugar)


# Arma los controles de la edicion. no_aplicados: los cambios que una recarga
# no pudo volver a aplicar (EdicionEscenario.sobre), para mostrarlos.
# semillas_playtest (T33): las de playtest/alarmas.json; vacia = sin selector.
func abrir(edicion: EdicionEscenario, no_aplicados: Array[Dictionary] = [], semillas_playtest: Array = []) -> void:
	_edicion = edicion
	_no_aplicados = no_aplicados.duplicate()
	_semillas_playtest = semillas_playtest.duplicate()
	_motivos.clear()
	_armar()
	_mostrar()


func edicion() -> EdicionEscenario:
	return _edicion


# Las rutas con control, en el orden de EdicionEscenario.campos().
func rutas() -> Array[String]:
	return _rutas


# El control del valor de la ruta, o null.
func control(ruta: String) -> Control:
	return _controles.get(ruta)


# El CheckBox "por defecto" de la ruta, o null si el campo no admite null.
func control_por_defecto(ruta: String) -> CheckBox:
	return _por_defecto.get(ruta)


# Lo que se muestra junto al campo ("" sin errores).
func texto_error(ruta: String) -> String:
	var etiqueta: Label = _errores.get(ruta)
	return "" if etiqueta == null else etiqueta.text


func puede_jugar() -> bool:
	return _puede_jugar


func pulsar_jugar() -> bool:
	if not _puede_jugar:
		return false
	jugar.emit()
	return true


func pulsar_restaurar() -> void:
	_edicion.restaurar()
	_motivos.clear()
	_no_aplicados.clear()
	_mostrar()


# Sin reloj ni azar del sistema: la semilla siguiente.
func pulsar_semilla_mas_uno() -> void:
	_aplicar(_RUTA_SEMILLA, int(_edicion.valor(_RUTA_SEMILLA)) + 1)


# T33: el selector "Semilla de playtest", o null si no hay lista.
func control_semilla_playtest() -> OptionButton:
	return _semilla_playtest


# T33: pone la semilla de playtest numero indice (1 a 10) de la lista; 0 no
# cambia nada.
func pulsar_semilla_playtest(indice: int) -> void:
	if indice < 1 or indice > _semillas_playtest.size():
		_mostrar()
		return
	_aplicar(_RUTA_SEMILLA, _semillas_playtest[indice - 1])


# --- Armado ------------------------------------------------------------------

func _armar() -> void:
	for hijo in _campos.get_children():
		_campos.remove_child(hijo)
		hijo.queue_free()
	_controles.clear()
	_por_defecto.clear()
	_nombres.clear()
	_errores.clear()
	_rutas.clear()
	_semilla_playtest = null
	for campo in _edicion.campos():
		var ruta: String = campo["ruta"]
		_rutas.append(ruta)
		var nombre: Label = Label.new()
		_nombres[ruta] = nombre
		_campos.add_child(nombre)
		var fila: HBoxContainer = HBoxContainer.new()
		fila.add_child(_control_para(campo))
		if campo["admite_nulo"]:
			var nulo: CheckBox = CheckBox.new()
			nulo.text = "por defecto"
			nulo.toggled.connect(_al_cambiar_por_defecto.bind(ruta))
			_por_defecto[ruta] = nulo
			fila.add_child(nulo)
		if ruta == _RUTA_SEMILLA:
			var mas_uno: Button = Button.new()
			mas_uno.name = "SemillaMasUno"
			mas_uno.text = "+1"
			mas_uno.pressed.connect(pulsar_semilla_mas_uno)
			fila.add_child(mas_uno)
			if not _semillas_playtest.is_empty():
				_semilla_playtest = OptionButton.new()
				_semilla_playtest.name = "SemillaPlaytest"
				_semilla_playtest.add_item(SIN_SEMILLA_PLAYTEST)
				for i in range(_semillas_playtest.size()):
					_semilla_playtest.add_item(str(i + 1))
				_semilla_playtest.item_selected.connect(pulsar_semilla_playtest)
				fila.add_child(_semilla_playtest)
		_campos.add_child(fila)
		var error: Label = Label.new()
		error.add_theme_color_override("font_color", _COLOR_ERROR)
		_errores[ruta] = error
		_campos.add_child(error)


func _control_para(campo: Dictionary) -> Control:
	var ruta: String = campo["ruta"]
	var control_nuevo: Control
	match campo["tipo"]:
		EdicionEscenario.TIPO_OPCION:
			var lista: OptionButton = OptionButton.new()
			for opcion in (campo["opciones"] as Array):
				lista.add_item(str(opcion))
			lista.item_selected.connect(_al_elegir.bind(ruta))
			control_nuevo = lista
		EdicionEscenario.TIPO_BOOLEANO:
			var interruptor: CheckButton = CheckButton.new()
			interruptor.toggled.connect(_al_cambiar_interruptor.bind(ruta))
			control_nuevo = interruptor
		_:
			var numero: SpinBox = SpinBox.new()
			numero.step = 1
			numero.rounded = true
			# Nunca recorta: un valor fuera de rango lo informa la validacion.
			numero.allow_greater = true
			numero.allow_lesser = true
			numero.value = _inicial(campo)
			numero.value_changed.connect(_al_cambiar_numero.bind(ruta))
			control_nuevo = numero
	_controles[ruta] = control_nuevo
	return control_nuevo


# El numero que muestra un campo en null hasta que se destilda "por defecto":
# el maximo, el minimo o 0 (el valor por defecto real lo resuelve el nucleo).
func _inicial(campo: Dictionary) -> int:
	var actual: Variant = _edicion.valor(campo["ruta"])
	if actual != null:
		return int(actual)
	if campo["maximo"] != null:
		return campo["maximo"]
	if campo["minimo"] != null:
		return campo["minimo"]
	return 0


# --- Cambios -----------------------------------------------------------------

func _al_cambiar_numero(nuevo: float, ruta: String) -> void:
	_aplicar(ruta, int(nuevo))


func _al_cambiar_por_defecto(por_defecto: bool, ruta: String) -> void:
	var numero: SpinBox = _controles[ruta]
	_aplicar(ruta, null if por_defecto else int(numero.value))


func _al_elegir(indice: int, ruta: String) -> void:
	_aplicar(ruta, (_edicion.campo(ruta)["opciones"] as Array)[indice])


func _al_cambiar_interruptor(encendido: bool, ruta: String) -> void:
	_aplicar(ruta, encendido)


func _aplicar(ruta: String, nuevo: Variant) -> void:
	_motivos.clear()
	var motivo: String = _edicion.cambiar(ruta, nuevo)
	if not motivo.is_empty():
		_motivos[ruta] = motivo
	_mostrar()


# --- Redibujo desde la edicion ----------------------------------------------

# Los controles, los limites y los errores salen de la edicion, sin seniales
# (un valor que no se aplico vuelve a mostrar el de la edicion).
func _mostrar() -> void:
	_titulo.text = "Parametros de %s%s" % [_edicion.escenario().get("id", ""),
			" (editado)" if _edicion.difiere() else ""]
	for campo in _edicion.campos():
		var ruta: String = campo["ruta"]
		if not _controles.has(ruta):
			continue
		(_nombres[ruta] as Label).text = "%s %s" % [ruta, _texto_limites(campo)]
		_mostrar_valor(campo)
	if _semilla_playtest != null:
		var indice: Variant = FichaPlaytest.indice(int(_edicion.valor(_RUTA_SEMILLA)), _semillas_playtest)
		_semilla_playtest.select(0 if indice == null else indice)

	var por_ruta: Dictionary = {}
	var generales: Array[String] = []
	for aviso in _no_aplicados:
		generales.append("No se volvio a aplicar %s: %s" % [aviso["ruta"], aviso["motivo"]])
	var errores: Array[Dictionary] = _edicion.validar()
	for error in errores:
		var linea: String = "esperado: %s · recibido: %s" % [error["esperado"], str(error["recibido"])]
		var ruta_error: String = error["ruta"]
		if _errores.has(ruta_error):
			if not por_ruta.has(ruta_error):
				por_ruta[ruta_error] = []
			(por_ruta[ruta_error] as Array).append(linea)
		else:
			generales.append("%s · %s · %s" % [error["archivo"], error["campo"], linea])
	for ruta in _errores.keys():
		var lineas: Array = (por_ruta.get(ruta, []) as Array).duplicate()
		if _motivos.has(ruta):
			lineas.push_front("no se aplico: %s" % _motivos[ruta])
		(_errores[ruta] as Label).text = "\n".join(lineas)
	_errores_generales.text = "\n".join(generales)
	_errores_generales.visible = not generales.is_empty()
	_puede_jugar = errores.is_empty()
	_boton_jugar.disabled = not _puede_jugar


func _mostrar_valor(campo: Dictionary) -> void:
	var ruta: String = campo["ruta"]
	var actual: Variant = _edicion.valor(ruta)
	var control_actual: Control = _controles[ruta]
	if control_actual is SpinBox:
		var numero: SpinBox = control_actual
		if campo["minimo"] != null:
			numero.min_value = campo["minimo"]
		if campo["maximo"] != null:
			numero.max_value = campo["maximo"]
		if actual != null:
			numero.set_value_no_signal(int(actual))
		numero.editable = actual != null
		if _por_defecto.has(ruta):
			(_por_defecto[ruta] as CheckBox).set_pressed_no_signal(actual == null)
	elif control_actual is OptionButton:
		var lista: OptionButton = control_actual
		lista.select((campo["opciones"] as Array).find(actual))
	elif control_actual is CheckButton:
		(control_actual as CheckButton).set_pressed_no_signal(actual == true)


func _texto_limites(campo: Dictionary) -> String:
	if campo["tipo"] != EdicionEscenario.TIPO_ENTERO:
		return ""
	var minimo: String = "-" if campo["minimo"] == null else str(campo["minimo"])
	var maximo: String = "-" if campo["maximo"] == null else str(campo["maximo"])
	return "[%s .. %s]" % [minimo, maximo]
