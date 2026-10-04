# Lo que devuelve un Turno al validar o aplicar una Accion: lo mismo en los dos
# casos ("calcular sin aplicar"). Si no vale, el motivo dice por que.
class_name ResultadoAccion
extends RefCounted

enum Motivo {
	NINGUNO,
	TURNO_TERMINADO,
	MOVIMIENTO_USADO,
	# Sistema.md 11.2: la erizada no se mueve por si misma.
	ERIZADA,
	MISMA_CASILLA,
	CASILLA_NO_ALCANZABLE,
	ACCION_USADA,
	OBJETIVO_INEXISTENTE,
	OBJETIVO_ALIADO,
	OBJETIVO_CAIDO,
	# Guardada o sin posicion.
	OBJETIVO_FUERA_DEL_TABLERO,
	# Sistema.md 11.3, Alcance 2: en linea y a distancia, pero con una enemiga en medio.
	LINEA_BLOQUEADA,
	FUERA_DE_ALCANCE,
	SIN_RASGO,
}

var valida: bool
var motivo: Motivo
# Solo al atacar: el danio que hace o haria el golpe.
var danio: int = 0
# Solo al terminar: true si el turno se cierra sin haber usado la accion (P-015).
var espero: bool = false


func _init(es_valida: bool, motivo_rechazo: Motivo) -> void:
	valida = es_valida
	motivo = motivo_rechazo


static func aceptada() -> ResultadoAccion:
	return ResultadoAccion.new(true, Motivo.NINGUNO)


static func rechazada(motivo_rechazo: Motivo) -> ResultadoAccion:
	return ResultadoAccion.new(false, motivo_rechazo)
