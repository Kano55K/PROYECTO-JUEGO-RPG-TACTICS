# Un cambio de lealtad anotado en un AcumuladorLealtad, con su motivo: el nombre
# del evento (claves de tablas/lealtad.json; "victoria" para el +1, P-019).
class_name AnotacionLealtad
extends RefCounted

var criatura_id: String
var cambio: int
var motivo: String


func _init(id_criatura: String, cambio_lealtad: int, motivo_cambio: String) -> void:
	criatura_id = id_criatura
	cambio = cambio_lealtad
	motivo = motivo_cambio
