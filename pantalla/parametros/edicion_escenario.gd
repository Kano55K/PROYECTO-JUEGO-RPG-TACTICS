# Arquitectura.md B.4 (T31): edita una copia de un escenario para jugar una
# variante sin tocar el archivo (Sistema.md 11.9: "escenarios fijos + panel de
# parametros + semilla"). Es herramienta de prueba, no regla: los rangos y los
# toggles salen del esquema escenario (y el tope del mana de entrada, de la
# balanza), y la validacion es la del Cargador. Nunca corrige un valor en
# silencio ni escribe en disco.
#
# Rutas de los campos: "semilla", "maestro.<campo>", "tribu.<id>.<campo>",
# "enemigas.<id>.<campo>", "pergaminos_en_blanco" y "toggles.<nombre>".
class_name EdicionEscenario
extends RefCounted

const TIPO_ENTERO: String = "entero"
const TIPO_BOOLEANO: String = "booleano"
const TIPO_OPCION: String = "opcion"

const MOTIVO_CAMPO_NO_EDITABLE: String = "campo_no_editable"
# P-023: una guardada no tiene posicion; soltarla le devuelve la del archivo.
const MOTIVO_SIN_POSICION_EN_ARCHIVO: String = "sin_posicion_en_archivo"

const ESTADO_SUELTA: String = "suelta"
const ESTADO_GUARDADA: String = "guardada"

# Los campos que el panel edita (T31, Alcance). Los toggles son todos los del
# esquema.
const _SEMILLA: String = "semilla"
const _PERGAMINOS: String = "pergaminos_en_blanco"
const _CAMPOS_MAESTRO: Array[String] = ["balanza", "poder", "regeneracion", "vida", "mana_entrada", "hambre",
		"enfermedades"]
const _CAMPOS_POR_LISTA: Dictionary = {
	"tribu": ["estado", "lealtad", "hambre", "enfermedades", "vida"],
	"enemigas": ["vida"],
}
const _MAESTRO: String = "maestro"
const _TOGGLES: String = "toggles"
const _NOTA: String = "_nota"
const _BALANZA: String = "tablas/balanza.json"
const _PREFIJO_REF: String = "#/$defs/"

var _original: Dictionary
var _escenario: Dictionary
var _datos: Dictionary
var _esquema: Dictionary


# original: el escenario como lo entrega el Cargador. datos: los datos
# cargados. esquema: el de escenario, de Cargador.esquema_resuelto.
func _init(original: Dictionary, datos: Dictionary, esquema: Dictionary) -> void:
	_original = original.duplicate(true)
	_escenario = original.duplicate(true)
	_datos = datos
	_esquema = esquema


# Un diccionario por campo editable: {ruta, tipo, minimo, maximo, admite_nulo,
# opciones}. minimo y maximo son null si el esquema no los fija. Un campo que
# el esquema no declara no aparece.
func campos() -> Array[Dictionary]:
	var lista: Array[Dictionary] = []
	var propiedades: Dictionary = _propiedades(_esquema)
	_sumar_campo(lista, _SEMILLA, propiedades.get(_SEMILLA))
	if propiedades.has(_MAESTRO):
		var del_maestro: Dictionary = _propiedades(propiedades[_MAESTRO])
		for nombre in _CAMPOS_MAESTRO:
			_sumar_campo(lista, "%s.%s" % [_MAESTRO, nombre], del_maestro.get(nombre))
	for lista_nombre in _CAMPOS_POR_LISTA.keys():
		if not propiedades.has(lista_nombre):
			continue
		var de_la_unidad: Dictionary = _propiedades(_resolver(propiedades[lista_nombre] as Dictionary).get("items", {}))
		for unidad in (_escenario.get(lista_nombre, []) as Array):
			for nombre in (_CAMPOS_POR_LISTA[lista_nombre] as Array):
				_sumar_campo(lista, "%s.%s.%s" % [lista_nombre, (unidad as Dictionary)["id"], nombre],
						de_la_unidad.get(nombre))
	_sumar_campo(lista, _PERGAMINOS, propiedades.get(_PERGAMINOS))
	if propiedades.has(_TOGGLES):
		var toggles: Dictionary = _propiedades(propiedades[_TOGGLES])
		for nombre in toggles.keys():
			if nombre != _NOTA:
				_sumar_campo(lista, "%s.%s" % [_TOGGLES, nombre], toggles[nombre])
	return lista


# El campo de esa ruta, o {} si no es editable.
func campo(ruta: String) -> Dictionary:
	for candidato in campos():
		if candidato["ruta"] == ruta:
			return candidato
	return {}


# El valor actual del campo en la copia, o null si el escenario no lo tiene.
func valor(ruta: String) -> Variant:
	var contenedor: Dictionary = _contenedor(_escenario, ruta)
	return contenedor.get(_nombre(ruta))


# Cambia el campo en la copia. Devuelve "" o el motivo por el que no se
# cambio. No mira rangos: un valor fuera de rango queda y lo informa validar().
func cambiar(ruta: String, nuevo: Variant) -> String:
	if campo(ruta).is_empty():
		return MOTIVO_CAMPO_NO_EDITABLE
	var contenedor: Dictionary = _contenedor(_escenario, ruta)
	if _nombre(ruta) == "estado":
		# P-023: guardada sin posicion; suelta, con la del archivo.
		if nuevo == ESTADO_GUARDADA:
			contenedor["posicion"] = null
		elif nuevo == ESTADO_SUELTA:
			var del_archivo: Variant = _contenedor(_original, ruta).get("posicion")
			if del_archivo == null:
				return MOTIVO_SIN_POSICION_EN_ARCHIVO
			contenedor["posicion"] = (del_archivo as Array).duplicate()
	if ruta.begins_with(_TOGGLES + ".") and not _escenario.has(_TOGGLES):
		_escenario[_TOGGLES] = contenedor
	contenedor[_nombre(ruta)] = nuevo
	return ""


# Una copia de la variante, para ContextoCombate.armar.
func escenario() -> Dictionary:
	return _escenario.duplicate(true)


# Si la variante difiere del escenario del archivo (T31: nombre de lo guardado).
func difiere() -> bool:
	return _escenario != _original


# T31, sesion 2: "Restaurar del archivo".
func restaurar() -> void:
	_escenario = _original.duplicate(true)


# Las rutas cuyo valor difiere del archivo, en el orden de campos(): {ruta:
# valor}. La posicion de una guardada no es un campo: la sigue su estado.
func cambios() -> Dictionary:
	var resultado: Dictionary = {}
	for candidato in campos():
		var ruta: String = candidato["ruta"]
		var actual: Variant = valor(ruta)
		if actual != _contenedor(_original, ruta).get(_nombre(ruta)):
			resultado[ruta] = actual
	return resultado


# T31, sesion 2 (recarga): una edicion nueva sobre el escenario y los datos
# recien leidos, con los cambios de esta. Devuelve {edicion, no_aplicados}:
# no_aplicados = [{ruta, motivo}] de los cambios que el archivo nuevo ya no
# admite (nunca se pierden en silencio). Esta edicion no cambia.
func sobre(original: Dictionary, datos: Dictionary, esquema: Dictionary) -> Dictionary:
	var nueva: EdicionEscenario = EdicionEscenario.new(original, datos, esquema)
	var no_aplicados: Array[Dictionary] = []
	var pendientes: Dictionary = cambios()
	for ruta in pendientes.keys():
		var motivo: String = nueva.cambiar(ruta, pendientes[ruta])
		if not motivo.is_empty():
			no_aplicados.append({"ruta": ruta, "motivo": motivo})
	return {"edicion": nueva, "no_aplicados": no_aplicados}


# Los errores de la variante, del Cargador (mismo validador y mismos chequeos
# cruzados que un archivo). Cada error suma "ruta": la del campo editable que
# lo causa, o "" si no es de un campo editable.
func validar() -> Array[Dictionary]:
	var resultado: Dictionary = Cargador.new().validar_escenario(_escenario, _esquema, _datos)
	var errores: Array[Dictionary] = []
	var rutas: Dictionary = {}
	for candidato in campos():
		rutas[candidato["ruta"]] = true
	for error in (resultado["errores"] as Array):
		var con_ruta: Dictionary = (error as Dictionary).duplicate()
		var ruta: String = _ruta_de_campo(con_ruta["campo"] as String)
		con_ruta["ruta"] = ruta if rutas.has(ruta) else ""
		errores.append(con_ruta)
	return errores


# --- Esquema -----------------------------------------------------------------

func _sumar_campo(lista: Array[Dictionary], ruta: String, esquema_campo: Variant) -> void:
	if not (esquema_campo is Dictionary):
		return
	var sub: Dictionary = _resolver(esquema_campo as Dictionary)
	var tipos: Array = sub["type"] if sub.get("type") is Array else [sub.get("type")]
	var tipo: String = TIPO_ENTERO
	var opciones: Array = []
	if sub.has("enum"):
		tipo = TIPO_OPCION
		opciones = (sub["enum"] as Array).duplicate()
	elif tipos.has("boolean"):
		tipo = TIPO_BOOLEANO
	var minimo: Variant = _entero_o_null(sub.get("minimum"))
	var maximo: Variant = _entero_o_null(sub.get("maximum"))
	if ruta == "%s.mana_entrada" % [_MAESTRO]:
		maximo = _tope_mana(maximo)
	lista.append({"ruta": ruta, "tipo": tipo, "minimo": minimo, "maximo": maximo,
			"admite_nulo": tipos.has("null"), "opciones": opciones})


# Sistema.md 2.1 (T21): el mana de entrada llega como mucho a la reserva de la
# balanza actual. Sin la tabla o sin la fila, queda el maximo del esquema.
func _tope_mana(maximo_esquema: Variant) -> Variant:
	var balanza: Variant = (_escenario.get(_MAESTRO, {}) as Dictionary).get("balanza")
	var tabla: Dictionary = _datos.get(_BALANZA, {})
	for fila in (tabla.get("posiciones", []) as Array):
		var fila_dic: Dictionary = fila as Dictionary
		if fila_dic.get("posicion") == balanza and fila_dic.has("reserva_mana"):
			var reserva: int = fila_dic["reserva_mana"] as int
			return reserva if maximo_esquema == null else mini(reserva, maximo_esquema as int)
	return maximo_esquema


func _propiedades(esquema_nodo: Variant) -> Dictionary:
	if not (esquema_nodo is Dictionary):
		return {}
	return _resolver(esquema_nodo as Dictionary).get("properties", {})


# Sigue una referencia local (#/$defs/...) del esquema; las de otros archivos
# ya las resolvio el Cargador.
func _resolver(esquema_nodo: Dictionary) -> Dictionary:
	var ref: String = str(esquema_nodo.get("$ref", ""))
	if not ref.begins_with(_PREFIJO_REF):
		return esquema_nodo
	return (_esquema.get("$defs", {}) as Dictionary).get(ref.substr(_PREFIJO_REF.length()), {})


func _entero_o_null(numero: Variant) -> Variant:
	return null if numero == null else int(numero)


# --- Rutas -------------------------------------------------------------------

func _nombre(ruta: String) -> String:
	var partes: PackedStringArray = ruta.split(".")
	return partes[partes.size() - 1]


# El diccionario que guarda el campo final de la ruta. Para un toggle que el
# escenario no tiene, un diccionario nuevo (cambiar lo agrega).
func _contenedor(escenario_base: Dictionary, ruta: String) -> Dictionary:
	var partes: PackedStringArray = ruta.split(".")
	if partes.size() == 1:
		return escenario_base
	if partes.size() == 2:
		var objeto: Variant = escenario_base.get(partes[0])
		return objeto if objeto is Dictionary else {}
	for unidad in (escenario_base.get(partes[0], []) as Array):
		if (unidad as Dictionary).get("id") == partes[1]:
			return unidad
	return {}


# "tribu[0].lealtad" (Validador) -> "tribu.<id>.lealtad". Los chequeos
# cruzados ya usan el id.
func _ruta_de_campo(campo_error: String) -> String:
	var expresion: RegEx = RegEx.create_from_string("^(tribu|enemigas)\\[(\\d+)\\]")
	var hallado: RegExMatch = expresion.search(campo_error)
	if hallado == null:
		return campo_error
	var lista: Array = _escenario.get(hallado.get_string(1), [])
	var indice: int = hallado.get_string(2).to_int()
	if indice >= lista.size() or not (lista[indice] is Dictionary):
		return campo_error
	return "%s.%s%s" % [hallado.get_string(1), (lista[indice] as Dictionary).get("id"),
			campo_error.substr(hallado.get_string(0).length())]
