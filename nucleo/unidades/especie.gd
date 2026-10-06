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


func rasgo() -> Dictionary:
	return (_ficha["rasgo"] as Dictionary).duplicate(true)


# Sistema.md 11.2.3: el modo con el que empieza el combate; "" sin modos.
func modo_inicial() -> String:
	return (_ficha["rasgo"] as Dictionary).get("modo_inicial", "")


# Sistema.md 11.2 y 11.2.3: los valores del modo dado (Criatura.modo). Sin
# modos, la Velocidad de la ficha y los valores neutros: un ataque, sin partir
# el movimiento, sin porcentaje ni plano.
func velocidad(modo: String) -> int:
	var datos_modo: Dictionary = _modo(modo)
	return datos_modo["velocidad"] if not datos_modo.is_empty() else _ficha["velocidad"]


func ataques_por_turno(modo: String) -> int:
	return _modo(modo).get("ataques_por_turno", 1)


func movimiento_partido(modo: String) -> bool:
	return _modo(modo).get("movimiento_partido", false)


func recibido_pct(modo: String) -> int:
	return _modo(modo).get("recibido_pct", 0)


func danio_plano(modo: String) -> int:
	return _modo(modo).get("danio_plano", 0)


# El modo con ese id, o {} si la ficha no tiene modos (o el id esta vacio).
func _modo(modo: String) -> Dictionary:
	for datos_modo in (_ficha["rasgo"] as Dictionary).get("modos", []):
		if (datos_modo as Dictionary)["id"] == modo:
			return datos_modo
	return {}
