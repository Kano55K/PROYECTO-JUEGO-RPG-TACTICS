# Sistema.md 3.2: un pergamino de la tribu. Apunta a su criatura por id
# (ocupante_id), nunca guardando el objeto (Arquitectura.md A.5). El lado de la
# criatura (pergamino_id) lo asigna el Plantel.
class_name Pergamino
extends RefCounted

enum Estado { EN_BLANCO, OCUPADO, ARDIDO }

var id: String
var estado: Estado = Estado.EN_BLANCO
# "" salvo cuando esta OCUPADO.
var ocupante_id: String = ""


func _init(id_pergamino: String) -> void:
	id = id_pergamino


# Solo un pergamino en blanco se ocupa. Devuelve false sin cambiar nada si no.
func ocupar(id_criatura: String) -> bool:
	if estado != Estado.EN_BLANCO:
		return false
	estado = Estado.OCUPADO
	ocupante_id = id_criatura
	return true


# Sistema.md 3.2: arde cuando se rompe el vinculo, asi que solo arde uno
# ocupado. Ardido no vuelve a usarse. Devuelve false sin cambiar nada si no.
func arder() -> bool:
	if estado != Estado.OCUPADO:
		return false
	estado = Estado.ARDIDO
	ocupante_id = ""
	return true
