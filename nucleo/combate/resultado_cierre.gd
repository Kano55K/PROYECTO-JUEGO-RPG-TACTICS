# Lo que devuelve Cierre.cerrar: como termino el combate y que le hizo a la
# tribu. T12 lo serializa. Si no vale, el motivo dice por que y nada cambio.
class_name ResultadoCierre
extends RefCounted

enum Motivo {
	NINGUNO,
	COMBATE_EN_CURSO,
	# El cierre corre una sola vez por combate.
	YA_CERRADO,
	# La huida es de T26.
	NO_IMPLEMENTADO,
	# El fin recibido no es el que da FinCombate.evaluar sobre el Plantel.
	FIN_NO_COINCIDE,
}

var valido: bool
var motivo: Motivo
var fin: FinCombate.Fin
# Sistema.md 6: el cierre solo dice que cayo; rescate y permadeath no son de T10.
var maestro_caido: bool = false
# ids, en el orden de la tribu. Las muertas son tambien las de pergamino ardido.
var levantadas: Array[String] = []
var muertas: Array[String] = []
var lealtad: Array[CambioLealtad] = []


func _init(es_valido: bool, motivo_rechazo: Motivo, fin_combate: FinCombate.Fin) -> void:
	valido = es_valido
	motivo = motivo_rechazo
	fin = fin_combate
