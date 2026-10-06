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
	# Sistema.md 11.2.3 (S-23): sin movimiento partido y con mas de un ataque, no
	# se mueve entre el primero y el ultimo.
	MOVER_ENTRE_ATAQUES,
	# Sistema.md 11.2.1, Costo: se cava sin haberse movido en el turno.
	YA_SE_MOVIO,
	# Sistema.md 11.2.1, Donde: ortogonalmente adyacente.
	CASILLA_NO_ADYACENTE,
	# Sistema.md 11.3, Casilla libre: fuera del tablero, con unidad o con surco (S-25).
	CASILLA_NO_LIBRE,
	# Sistema.md 11.2.2, Oculto: no es objetivo de una accion hostil (Objetivos).
	OBJETIVO_OCULTO,
	# Sistema.md 11.2.2, Activar: con una enemiga de pie adyacente no se oculta.
	ENEMIGA_ADYACENTE,
	# Sistema.md 11.2.2, Limite: no se oculta dos turnos seguidos.
	JUNCO_TURNO_ANTERIOR,
	# Sistema.md 11.5: con el combate terminado no se acepta ninguna accion.
	COMBATE_TERMINADO,
	# Combate.aplicar: no es el turno de una unidad del jugador (o el combate se
	# detuvo por un error).
	FUERA_DE_TURNO,
}

var valida: bool
var motivo: Motivo
# Solo al atacar: el danio que hace o haria el golpe.
var danio: int = 0
# Solo al atacar: el desglose de 11.4 (danio == desglose.total). Lo lee el registro.
var desglose: DesgloseDanio = null
# Solo al terminar: true si el turno se cierra sin haber usado la accion (P-015).
var espero: bool = false
# Como esta el combate: despues de aplicar, o el motivo de un rechazo por
# COMBATE_TERMINADO. Al validar no se adelanta: la vida en 0 se resuelve al aplicar.
var fin: FinCombate.Fin = FinCombate.Fin.EN_CURSO


func _init(es_valida: bool, motivo_rechazo: Motivo) -> void:
	valida = es_valida
	motivo = motivo_rechazo


static func aceptada() -> ResultadoAccion:
	return ResultadoAccion.new(true, Motivo.NINGUNO)


static func rechazada(motivo_rechazo: Motivo) -> ResultadoAccion:
	return ResultadoAccion.new(false, motivo_rechazo)
