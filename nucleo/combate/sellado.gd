# Sistema.md 4.1 a 4.3 y 2.3 (T24): la regla de sellar en combate, sin estado (y,
# desde T30, el porcentaje y la lealtad al resellar de 4.4).
# Los numeros salen de tablas/sellado.json (tramos x rango), CostosMana (T26: el
# costo de sellar con el descuento), tablas/balanza.json (rango maximo sellable y
# ajuste a la lealtad inicial, leidos de la fila del Maestro),
# tablas/lealtad.json (lealtad inicial del camino de combate) y tablas/combate.json
# (alcance). La tirada y el pergamino los resuelve el Turno.
class_name Sellado
extends RefCounted

# Arquitectura.md A.7 y D-007: el motivo del evento `mana` que paga un sellado.
const MOTIVO_SELLAR: String = "sellar"
# Arquitectura.md A.7: el resultado del evento `sellado`.
const RESULTADO_LOGRADO: String = "logrado"
const RESULTADO_FALLIDO: String = "fallido"

const _CIEN: int = 100
const _CAMINO_COMBATE: String = "combate"

# [{hasta_vida_pct, pct_por_rango}], de menor a mayor vida (el Cargador lo revisa).
var _tramos: Array = []
# T26: la regla de los costos de mana, compartida con invocar (ReglasCombate).
var _costos: CostosMana
var _lealtad_base: int = 0
# Sistema.md 4.4 (T30): la lealtad base al resellar (tablas/lealtad.json).
var _lealtad_resellar: int = 0
var _lealtad_minima: int = 0
var _alcance: int = 0


# null si falta un dato: sin valores por defecto (leccion de T09 y T37).
# costos: la de ReglasCombate (T26), o null si no se pudo armar.
static func desde_datos(tabla_sellado: Dictionary, costos: CostosMana, tabla_lealtad: Dictionary,
		tabla_combate: Dictionary) -> Sellado:
	if not tabla_sellado.has("tramos") or costos == null \
			or not tabla_lealtad.has("minimo") or not tabla_lealtad.has("resellar") \
			or not tabla_combate.has("alcance_sellar"):
		return null
	var caminos: Dictionary = tabla_lealtad.get("inicial_por_camino", {})
	if not caminos.has(_CAMINO_COMBATE):
		return null
	var regla: Sellado = Sellado.new()
	regla._tramos = (tabla_sellado["tramos"] as Array).duplicate(true)
	regla._costos = costos
	regla._lealtad_base = caminos[_CAMINO_COMBATE]
	regla._lealtad_minima = tabla_lealtad["minimo"]
	regla._lealtad_resellar = tabla_lealtad["resellar"]
	regla._alcance = tabla_combate["alcance_sellar"]
	return regla


# Sistema.md 4.1: la celda del primer tramo cuyo limite (incluido) alcanza la vida
# actual sobre la maxima, comparando en enteros (vida x 100 <= limite x vida_max),
# y del rango de la especie.
func porcentaje(vida: int, vida_max: int, rango: int) -> int:
	for tramo in _tramos:
		if vida * _CIEN <= (tramo["hasta_vida_pct"] as int) * vida_max:
			return (tramo["pct_por_rango"] as Array)[rango - 1]
	var ultimo: Dictionary = _tramos[_tramos.size() - 1]
	return (ultimo["pct_por_rango"] as Array)[rango - 1]


# El de una criatura con su vida de ahora y la maxima de su ficha.
func porcentaje_de(criatura: Criatura) -> int:
	return porcentaje(criatura.vida, criatura.vida_max_real(), criatura.especie.rango())


# Sistema.md 2.3: el costo del rango menos el descuento de la balanza, con el
# minimo. La cuenta es de CostosMana (T26).
func costo(especie: Especie, maestro: Maestro) -> int:
	return _costos.sellar(especie, maestro)


# Sistema.md 4.2: la base del camino de combate mas el ajuste de la balanza,
# nunca menos que el minimo de la escala (5.1).
func lealtad_inicial(maestro: Maestro) -> int:
	return maxi(_lealtad_minima, _lealtad_base + (maestro.fila_balanza()["ajuste_lealtad_inicial"] as int))


# Sistema.md 4.1: solo se sellan las de rango <= el maximo de la balanza.
func rango_permitido(especie: Especie, maestro: Maestro) -> bool:
	return especie.rango() <= (maestro.fila_balanza()["rango_max_sellable"] as int)


# Sistema.md 4.1: la distancia Manhattan maxima del Maestro a la objetivo.
func alcance() -> int:
	return _alcance


# Sistema.md 4.4 (T30): resellar tira con la fila de vida <= 25 %, el primer
# tramo (el Cargador los exige de menor a mayor vida), del rango de la especie.
func porcentaje_resellar(especie: Especie) -> int:
	return ((_tramos[0] as Dictionary)["pct_por_rango"] as Array)[especie.rango() - 1]


# Sistema.md 4.4 (T30): la lealtad al resellar mas el ajuste de la balanza, nunca
# menos que el minimo de la escala (5.1), como lealtad_inicial.
func lealtad_resellar(maestro: Maestro) -> int:
	return maxi(_lealtad_minima, _lealtad_resellar + (maestro.fila_balanza()["ajuste_lealtad_inicial"] as int))
