# Un turno en la cola de iniciativa. Apunta a la unidad por id (Arquitectura.md A.5).
class_name EntradaCola
extends RefCounted

var unidad_id: String
# "" = sin marca; "caza" / "cuenta" tal cual vienen de los turnos de la ficha.
var marca: String
var velocidad: int
var actuo: bool = false


func _init(id_unidad: String, marca_turno: String, velocidad_turno: int) -> void:
	unidad_id = id_unidad
	marca = marca_turno
	velocidad = velocidad_turno
