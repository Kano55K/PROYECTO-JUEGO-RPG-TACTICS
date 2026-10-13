# Lo que devuelve Cierre.cerrar: como termino el combate y que le hizo a la
# tribu. T12 lo serializa. Si no vale, el motivo dice por que y nada cambio.
class_name ResultadoCierre
extends RefCounted

enum Motivo {
	NINGUNO,
	COMBATE_EN_CURSO,
	# El cierre corre una sola vez por combate.
	YA_CERRADO,
	# El fin recibido no es el que da FinCombate.evaluar sobre el Plantel.
	FIN_NO_COINCIDE,
}

var valido: bool
var motivo: Motivo
var fin: FinCombate.Fin
var maestro_caido: bool = false
# Sistema.md 6 (T29), solo si cayo el Maestro: el id de la rescatista, o "" si no
# hubo; permadeath, si cayo sin rescatista.
var rescatista: String = ""
var permadeath: bool = false
# ids, en el orden de la tribu. Las muertas son tambien las de pergamino ardido.
var levantadas: Array[String] = []
var muertas: Array[String] = []
var lealtad: Array[CambioLealtad] = []
# Sistema.md 9.2 paso 6 (P-024, S-66; T30): ids de las atacantes nocturnas que se
# fueron con la derrota o la huida.
var se_fueron: Array[String] = []
# Sistema.md 9.3 y 5.2 (T30, S-65): con la victoria y la atacante nocturna caida,
# su id y el acumulador de la noche sin aplicar (lealtad queda vacia): el
# destino suma ahi lo suyo y recorta una sola vez. Si no, "" y null.
var destino_pendiente: String = ""
var acumulador: AcumuladorLealtad = null


func _init(es_valido: bool, motivo_rechazo: Motivo, fin_combate: FinCombate.Fin) -> void:
	valido = es_valido
	motivo = motivo_rechazo
	fin = fin_combate
