# Sistema.md 5.1 y 7.1: el estado de lealtad y de hambre de una unidad, leido
# de las tablas. Es la unica busqueda de los tramos de hambre (la usa Danio) y
# la consulta que la pantalla necesita para mostrar el estado sin calcularlo.
# Desde T14 tambien es el unico lugar de los cortes que comparten la lealtad y
# la obediencia (Sistema.md 5.4, P-003): corte().
class_name EstadosUnidad
extends RefCounted

const LEALTAD_DESLEAL: String = "desleal"
const LEALTAD_DUDOSA: String = "dudosa"
const LEALTAD_NEUTRAL: String = "neutral"
const LEALTAD_LEAL: String = "leal"

# Sistema.md 5.4: los tres tramos de los cortes. Debajo de Neutral, la lealtad
# distingue Desleal y Dudosa; la obediencia no ("<= 3").
enum Corte { DEBAJO_DE_NEUTRAL, NEUTRAL, LEAL }

var _estados_hambre: Array = []
var _desleal_hasta: int
var _neutral_desde: int


func _init(estados_hambre: Array, desleal_hasta: int, neutral_desde: int) -> void:
	_estados_hambre = estados_hambre
	_desleal_hasta = desleal_hasta
	_neutral_desde = neutral_desde


# tabla_hambre: tablas/hambre.json. tabla_lealtad: tablas/lealtad.json.
static func desde_datos(tabla_hambre: Dictionary, tabla_lealtad: Dictionary) -> EstadosUnidad:
	return EstadosUnidad.new(tabla_hambre["estados"], tabla_lealtad["desleal_hasta"], tabla_lealtad["neutral_desde"])


# Sistema.md 5.1 y 5.4 (P-003): la unica comparacion con los cortes. Neutral
# desde el piso de tablas/lealtad.json; Leal desde el umbral de rescate de la
# balanza (Maestro.fila_balanza()).
static func corte(valor: int, neutral_desde: int, umbral_rescate: int) -> Corte:
	if valor < neutral_desde:
		return Corte.DEBAJO_DE_NEUTRAL
	if valor < umbral_rescate:
		return Corte.NEUTRAL
	return Corte.LEAL


# Sistema.md 7.1: la fila del tramo que contiene el valor, o {} si ninguno (el
# Cargador ya exige que los tramos cubran la escala sin huecos).
static func fila_hambre(estados_hambre: Array, valor: int) -> Dictionary:
	for estado in estados_hambre:
		if valor >= estado["desde"] and valor <= estado["hasta"]:
			return estado
	return {}


# El id del estado de hambre ("saciado", "normal"...), o "" si no hay tramo.
func hambre(valor: int) -> String:
	return fila_hambre(_estados_hambre, valor).get("id", "")


# Sistema.md 5.1: los cortes de corte(); debajo de Neutral, Desleal hasta su
# corte fijo y Dudosa el resto.
func lealtad(valor: int, umbral_rescate: int) -> String:
	match corte(valor, _neutral_desde, umbral_rescate):
		Corte.DEBAJO_DE_NEUTRAL:
			return LEALTAD_DESLEAL if valor <= _desleal_hasta else LEALTAD_DUDOSA
		Corte.NEUTRAL:
			return LEALTAD_NEUTRAL
	return LEALTAD_LEAL
