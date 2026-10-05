# Arquitectura.md B.2 (T13): una unidad en el tablero, con placeholders. Pinta
# lo que le da LecturaCombate.fichas(); la posicion la pone la vista con
# map_to_local. Colores y tamanios son de presentacion, no de reglas.
class_name FichaUnidad
extends Node2D

const _COLOR_TRIBU: Color = Color(0.35, 0.6, 0.95)
const _COLOR_ENEMIGA: Color = Color(0.9, 0.35, 0.3)
const _COLOR_CAIDA: Color = Color(0.5, 0.5, 0.5)

var unidad_id: String = ""

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
	_vida.text = "%d/%d" % [ficha["vida"], ficha["vida_max"]]
	_marcas.text = " · ".join(marcas)
