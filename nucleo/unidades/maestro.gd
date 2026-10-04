# El Maestro en el combate. Su vida maxima y su danio cuerpo a cuerpo salen de
# la balanza y se leen de la tabla cada vez: nunca se guardan (M-01).
# Los cambios por regla llegan en las tareas siguientes.
class_name Maestro
extends RefCounted

var balanza: int
var poder: int = 0
var regeneracion: int = 0
var vida: int
var hambre: int = 0
var enfermedades: int = 0
# Coordenadas de grilla [x, y], con y = 0 arriba.
var posicion: Vector2i = Criatura.SIN_POSICION
# int o null, tal cual llega del escenario; se resuelve en T21.
var mana_entrada: Variant = null

# Compartida y de solo lectura, como la ficha de una especie.
var _tabla_balanza: TablaBalanza


func _init(tabla_balanza: TablaBalanza, balanza_inicial: int) -> void:
	_tabla_balanza = tabla_balanza
	balanza = balanza_inicial
	vida = vida_max_real()


func fila_balanza() -> Dictionary:
	return _tabla_balanza.fila(balanza)


# Sistema.md 1.2 y 7.8
func vida_max_real() -> int:
	return fila_balanza()["vida_max_real"]


# Sistema.md 1.2 y 11.2
func danio_cuerpo() -> int:
	return fila_balanza()["danio_cuerpo"]
