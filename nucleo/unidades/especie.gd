# Sistema.md 11.2: la ficha de una especie. De solo lectura: se comparte como
# objeto entre todas las criaturas de esa especie (Arquitectura.md A.5).
# Recibe la ficha ya validada por el Cargador; no lee archivos.
class_name Especie
extends RefCounted

var _ficha: Dictionary


func _init(ficha: Dictionary) -> void:
	# Copia propia: cambiar el diccionario de origen no cambia la especie.
	_ficha = ficha.duplicate(true)


func id() -> String:
	return _ficha["id"]


func rol() -> String:
	return _ficha["rol"]


func rango() -> int:
	return _ficha["rango"]


func sellable() -> bool:
	return _ficha["sellable"]


func vida() -> int:
	return _ficha["vida"]


func danio() -> int:
	return _ficha["danio"]


func movimiento() -> int:
	return _ficha["movimiento"]


func alcance() -> int:
	return _ficha["alcance"]


func huida_pct() -> int:
	return _ficha["huida_pct"]


# Una entrada por turno en la ronda, {velocidad, marca}; el Tasajero tiene dos
# (Caza y Cuenta). Devuelve copias para que nadie cambie la ficha desde afuera.
func turnos() -> Array[Dictionary]:
	var resultado: Array[Dictionary] = []
	for turno in _ficha["turnos"]:
		resultado.append((turno as Dictionary).duplicate(true))
	return resultado


func rasgo() -> Dictionary:
	return (_ficha["rasgo"] as Dictionary).duplicate(true)
