# Sistema.md 5.1 y 7.1: el estado de lealtad y de hambre de una unidad, leido
# de las tablas. Es la unica busqueda de los tramos de hambre (la usa Danio) y
# la consulta que la pantalla necesita para mostrar el estado sin calcularlo.
class_name EstadosUnidad
extends RefCounted

const LEALTAD_DESLEAL: String = "desleal"
const LEALTAD_DUDOSA: String = "dudosa"
const LEALTAD_NEUTRAL: String = "neutral"
const LEALTAD_LEAL: String = "leal"

var _estados_hambre: Array = []
var _desleal_hasta: int
var _dudosa_hasta: int


func _init(estados_hambre: Array, desleal_hasta: int, dudosa_hasta: int) -> void:
	_estados_hambre = estados_hambre
	_desleal_hasta = desleal_hasta
	_dudosa_hasta = dudosa_hasta


# tabla_hambre: tablas/hambre.json. tabla_lealtad: tablas/lealtad.json.
static func desde_datos(tabla_hambre: Dictionary, tabla_lealtad: Dictionary) -> EstadosUnidad:
	return EstadosUnidad.new(tabla_hambre["estados"], tabla_lealtad["desleal_hasta"], tabla_lealtad["dudosa_hasta"])


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


# Sistema.md 5.1: Desleal y Dudosa con cortes fijos; Neutral hasta umbral - 1;
# Leal desde el umbral de rescate de la balanza (Maestro.fila_balanza()).
func lealtad(valor: int, umbral_rescate: int) -> String:
	if valor <= _desleal_hasta:
		return LEALTAD_DESLEAL
	if valor <= _dudosa_hasta:
		return LEALTAD_DUDOSA
	if valor < umbral_rescate:
		return LEALTAD_NEUTRAL
	return LEALTAD_LEAL
