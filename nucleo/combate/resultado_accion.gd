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
	# Sistema.md 10.1, Restricciones: las salvajes no Secundan.
	SALVAJE_NO_SECUNDA,
	# Sistema.md 10.1: se Secunda a otra unidad, nunca a si misma.
	SECUNDAR_A_SI_MISMA,
	# Sistema.md 10.1: la elegida es una aliada (del mismo bando).
	ALIADA_DE_OTRO_BANDO,
	# Sistema.md 10.1: la aliada todavia no actuo en la ronda (ni cayo, ni fue
	# guardada); asi tampoco se Secunda mas alla del final de la ronda.
	ALIADA_SIN_ENTRADA_PENDIENTE,
	# Sistema.md 10.5 y 10.1 (T19): la enconada no usa otra accion que atacar a su
	# rival, y no Secunda.
	ENCONADA,
	# Sistema.md 10.1: la acobardada no Secunda.
	ACOBARDADA,
	# S-35: la enconada que alcanza a su rival solo se mueve a casillas desde
	# donde golpea a alguna rival del chequeo.
	CASILLA_SIN_RIVAL,
	# S-35: la enconada solo ataca a las rivales del chequeo (en Caza, el primer ataque).
	OBJETIVO_NO_RIVAL,
	# S-35: la enconada que alcanza no termina sin atacar a su rival.
	DEBE_ATACAR_RIVAL,
	# S-35: la enconada que no alcanza solo se mueve a las casillas de menor
	# distancia a la rival mas cercana.
	CASILLA_NO_ACERCA,
	# S-35: la enconada que no alcanza no termina mientras pueda acercarse.
	DEBE_ACERCARSE,
	# Sistema.md 10.6 y S-36: la acobardada no termina un movimiento mas cerca de
	# ninguna rival del chequeo que donde empezo el turno.
	MAS_CERCA_DE_RIVAL,
	# Sistema.md 1.6 (T22): solo el Maestro lanza hechizos.
	SOLO_MAESTRO,
	# El Maestro no tiene ese hechizo (maestro.json, hechizos.json).
	HECHIZO_INEXISTENTE,
	# Sistema.md 1.6 y 2.3: el maná actual no alcanza el costo.
	MANA_INSUFICIENTE,
	# Sistema.md 1.6: el hechizo no vale sobre el Maestro mismo (la Lanzadera).
	OBJETIVO_PROPIO,
	# Sistema.md 1.6: el Remiendo es para el Maestro o una aliada.
	OBJETIVO_ENEMIGO,
	# Sistema.md 1.6, casos borde de la Lanzadera: atraer a una unidad adyacente.
	ATRAER_ADYACENTE,
	# Sistema.md 1.6: la Lanzadera lleva un sentido de sus modos; los demas, ninguno.
	SENTIDO_INVALIDO,
	# Turno.motivo_hechizo (T22, sesion 2): el hechizo no vale sobre ninguna unidad ahora.
	SIN_OBJETIVOS,
	# Sistema.md 4.1 (T24): toda captura exige un pergamino en blanco en el Plantel.
	SIN_PERGAMINO,
	# Sistema.md 4.1: se sella a una salvaje; la atacante nocturna se resella despues
	# del combate (9.3, T30).
	OBJETIVO_NO_SALVAJE,
	# Sistema.md 4.3: la ficha no es sellable (el Tasajero).
	NO_SELLABLE,
	# Sistema.md 4.1: el rango de la especie pasa el maximo sellable de la balanza.
	RANGO_ALTO,
}

var valida: bool
var motivo: Motivo
# Solo al atacar: el danio que hace o haria el golpe.
var danio: int = 0
# Solo al atacar: el desglose de 11.4 (danio == desglose.total). Lo lee el registro.
var desglose: DesgloseDanio = null
# Solo al atacar (Sistema.md 10.2, T16): el eslabon de la cadena que es (o seria)
# el golpe, desde 1; null en las enemigas, que no encadenan. Lo lee el registro.
var eslabon: Variant = null
# Solo en un hechizo o un sellado (Sistema.md 1.6 y 4.1, T22 y T24): {de, a} del
# mana que paga, o {} si no cambia (D-007).
var mana: Dictionary = {}
# Solo en un hechizo que no es ataque: el evento de A.7 que produce (`lanzadera`
# o `remiendo`), con su tipo. Lo mismo al validar y al aplicar. En un sellado
# (T24), el evento `sellado`, solo al aplicar: la tirada existe solo al aplicar.
var evento: Dictionary = {}
# Solo en un sellado valido (Sistema.md 4.1 y 2.3, T24): el % que se muestra antes
# de gastar el mana y el costo. Lo mismo al validar y al aplicar.
var porcentaje: Variant = null
var costo: int = 0
# Solo en la Lanzadera: las ocultas que la movida destaparia por contacto al
# llegar (Junco.destaparia), en el orden del Plantel; [] si choca.
var destaparia: Array[String] = []
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
