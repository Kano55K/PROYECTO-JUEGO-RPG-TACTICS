# Sistema.md 5.4: obediencia = lealtad - penalizacion por el estado de hambre.
# Nunca se guarda: se calcula cada vez que se pregunta, asi el "recalculo en el
# acto" de 7.2 no necesita codigo. Vive en unidades/ porque tambien la usan las
# guardias y el campamento de 0b (9.4). Los tramos usan los cortes de la
# lealtad (EstadosUnidad.corte, P-003). El Maestro no tiene obediencia.
class_name Obediencia
extends RefCounted

# Los nombres del enum de tablas/combate.json (salvajes.tramo_obediencia).
const TRAMO_BAJA: String = "baja"
const TRAMO_NEUTRAL: String = "neutral"
const TRAMO_LEAL: String = "leal"
const TRAMOS: Array[String] = [TRAMO_BAJA, TRAMO_NEUTRAL, TRAMO_LEAL]

var _estados_hambre: Array = []
var _neutral_desde: int
var _tramo_enemigas: String


func _init(estados_hambre: Array, neutral_desde: int, tramo_enemigas: String) -> void:
	_estados_hambre = estados_hambre
	_neutral_desde = neutral_desde
	_tramo_enemigas = tramo_enemigas


# tabla_hambre: tablas/hambre.json. tabla_lealtad: tablas/lealtad.json.
# tabla_combate: tablas/combate.json.
static func desde_datos(tabla_hambre: Dictionary, tabla_lealtad: Dictionary, tabla_combate: Dictionary) -> Obediencia:
	return Obediencia.new(tabla_hambre["estados"], tabla_lealtad["neutral_desde"],
			(tabla_combate["salvajes"] as Dictionary)["tramo_obediencia"])


# Sistema.md 5.4: la penalizacion esta guardada en negativo en cada estado de
# hambre (tablas/hambre.json). Sin recorte: puede dar negativa y solo se compara
# con los cortes (lectura tecnica, B.3). null en las enemigas: no se calcula.
func valor(criatura: Criatura) -> Variant:
	if criatura.bando != Criatura.Bando.TRIBU:
		return null
	var estado: Dictionary = EstadosUnidad.fila_hambre(_estados_hambre, criatura.hambre)
	return criatura.lealtad + (estado["obediencia"] as int)


# Sistema.md 5.4. Las enemigas (salvajes y la atacante nocturna) tienen el tramo
# de tablas/combate.json aunque traigan lealtad (10.7 y 9.2 punto 3).
func tramo(criatura: Criatura, maestro: Maestro) -> String:
	if criatura.bando != Criatura.Bando.TRIBU:
		return _tramo_enemigas
	match EstadosUnidad.corte(valor(criatura) as int, _neutral_desde, maestro.fila_balanza()["umbral_rescate"]):
		EstadosUnidad.Corte.DEBAJO_DE_NEUTRAL:
			return TRAMO_BAJA
		EstadosUnidad.Corte.NEUTRAL:
			return TRAMO_NEUTRAL
	return TRAMO_LEAL
