# Arquitectura.md B.2 (T13): una unidad en el tablero, con placeholders. Pinta
# lo que le da LecturaCombate.fichas(); la posicion la pone la vista con
# map_to_local. Colores y tamanios son de presentacion, no de reglas.
class_name FichaUnidad
extends Node2D

const _COLOR_TRIBU: Color = Color(0.35, 0.6, 0.95)
const _COLOR_ENEMIGA: Color = Color(0.9, 0.35, 0.3)
const _COLOR_CAIDA: Color = Color(0.5, 0.5, 0.5)

var unidad_id: String = ""
# La vida maxima que se mostro, para mostrar_vida.
var _vida_max: int = 0
# Las marcas que se mostraron, para mostrar_marca.
var _marcas_base: Array[String] = []

@onready var _figura: Sprite2D = $Figura
@onready var _aro: Sprite2D = $Aro
@onready var _nombre: Label = $Nombre
@onready var _vida: Label = $Vida
@onready var _marcas: Label = $Marcas


# ficha: una entrada de LecturaCombate.fichas().
func mostrar(ficha: Dictionary) -> void:
	unidad_id = ficha["id"]
	name = unidad_id
	var marcas: Array[String] = ficha["marcas"]
	_figura.modulate = _COLOR_TRIBU if ficha["tribu"] else _COLOR_ENEMIGA
	if ficha["caida"]:
		_figura.modulate = _COLOR_CAIDA
	_aro.visible = ficha["maestro"]
	_nombre.text = ficha["nombre"]
	_vida_max = ficha["vida_max"]
	mostrar_vida(ficha["vida"])
	_marcas_base = marcas.duplicate()
	_marcas.text = " · ".join(marcas)


# T40 (ritmo de la IA): la vida que deja un ataque, leida del registro.
func mostrar_vida(vida: int) -> void:
	_vida.text = "%d/%d" % [vida, _vida_max]


func texto_vida() -> String:
	return _vida.text


# T20 (ritmo de la IA): una marca de mas, leida del registro (enconada o
# acobardada en su turno), sobre las que se mostraron. Mostrarla otra vez no la
# repite; el proximo `mostrar` la saca.
func mostrar_marca(marca: String) -> void:
	var marcas: Array[String] = _marcas_base.duplicate()
	if not marca.is_empty():
		marcas.append(marca)
	_marcas.text = " · ".join(marcas)


func texto_marcas() -> String:
	return _marcas.text
