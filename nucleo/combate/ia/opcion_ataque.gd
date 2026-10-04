# Sistema.md 11.8 (S-8): un ataque posible del turno completo de una salvaje,
# moverse a `casilla` y golpear a `objetivo_id`. El danio sale de
# Turno.previsualizar_ataque, el mismo camino que el ataque real.
class_name OpcionAtaque
extends RefCounted

var casilla: Vector2i
# Pasos del camino hasta `casilla` (0 si es la suya).
var pasos: int
var objetivo_id: String
var danio: int
var vida_objetivo: int
# Manhattan desde la posicion actual de la salvaje: "la mas cercana".
var distancia_objetivo: int
# Manhattan desde `casilla` hasta la objetivo: "la Ocarra prefiere la distancia 2".
var distancia_golpe: int


func _init(casilla_golpe: Vector2i, pasos_hasta: int, id_objetivo: String, danio_previsto: int,
		vida: int, distancia: int, distancia_desde_casilla: int) -> void:
	casilla = casilla_golpe
	pasos = pasos_hasta
	objetivo_id = id_objetivo
	danio = danio_previsto
	vida_objetivo = vida
	distancia_objetivo = distancia
	distancia_golpe = distancia_desde_casilla


func puede_tumbar() -> bool:
	return danio >= vida_objetivo
