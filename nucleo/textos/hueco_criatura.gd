# Arquitectura.md A.2.1 / Mundo.md 1.5: el valor de un hueco de criatura en un
# rol ({criatura}, {rival}...). Solo lleva el id de especie: el armador saca de
# ahi las seis formas gramaticales.
class_name HuecoCriatura
extends RefCounted

var especie_id: String


func _init(id_especie: String) -> void:
	especie_id = id_especie
