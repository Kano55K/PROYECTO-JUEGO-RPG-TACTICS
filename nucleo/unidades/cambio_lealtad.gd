# Lo que un AcumuladorLealtad le hizo a una criatura: cambio es la suma de sus
# anotaciones y despues, antes + cambio recortado a la escala (Sistema.md 5.2).
class_name CambioLealtad
extends RefCounted

var criatura_id: String
var antes: int
var cambio: int
var despues: int
var anotaciones: Array[AnotacionLealtad] = []


func _init(id_criatura: String, lealtad_antes: int) -> void:
	criatura_id = id_criatura
	antes = lealtad_antes
