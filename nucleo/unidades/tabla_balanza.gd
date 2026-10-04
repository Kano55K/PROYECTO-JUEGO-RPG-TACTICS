# Sistema.md 1.2: la tabla de la balanza, de solo lectura. Todo lo que depende
# de la posicion (vida, danio, umbral de rescate, reserva...) se lee de la fila
# en el momento y nunca se guarda en otra entidad (M-01).
class_name TablaBalanza
extends RefCounted

var _posiciones: Array[Dictionary] = []


# Recibe el contenido ya validado de tablas/balanza.json.
func _init(tabla: Dictionary) -> void:
	for fila_tabla in tabla["posiciones"]:
		_posiciones.append((fila_tabla as Dictionary).duplicate(true))


# Busca por el campo posicion, no por indice. {} si no existe: el Cargador ya
# exige las posiciones 1 a 5.
func fila(posicion: int) -> Dictionary:
	for fila_tabla in _posiciones:
		if fila_tabla["posicion"] == posicion:
			return fila_tabla.duplicate(true)
	return {}
