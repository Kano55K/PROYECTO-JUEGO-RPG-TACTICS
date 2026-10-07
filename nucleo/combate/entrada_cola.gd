# Un turno en la cola de iniciativa. Apunta a la unidad por id (Arquitectura.md A.5).
class_name EntradaCola
extends RefCounted

var unidad_id: String
# "" = sin marca; si no, el id del modo de la criatura al armar la ronda
# ("caza" / "cuenta", Sistema.md 11.2.3).
var marca: String
var velocidad: int
var actuo: bool = false
# Sistema.md 10.1 (T17): true si la unidad Secundo y esta entrada es la del turno
# que vuelve. Solo la pone la cola al moverla; la cola se arma de nuevo en cada
# ronda, asi que no pasa a la siguiente. Con ella, el inicio del turno no se
# repite (S-31, P-033).
var vuelve: bool = false


func _init(id_unidad: String, marca_turno: String, velocidad_turno: int) -> void:
	unidad_id = id_unidad
	marca = marca_turno
	velocidad = velocidad_turno
