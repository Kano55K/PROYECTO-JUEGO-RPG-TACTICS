# Sistema.md 10.2 y 1.3: el bono de combo de un eslabon. Es la regla, sin estado
# de combate (la cadena la guarda Cadena): la base del par que encadena (sin
# relacion o afines, tablas/combate.json) mas el Arrimo de los pasos del Maestro
# (tablas/arrimo.json y balanza.json), y cada eslabon vale la mitad que el
# anterior, con piso y sin tope. La relacion y la balanza se preguntan en el
# momento (S-28, 1.2).
class_name Combo
extends RefCounted

var _sin_relacion_pct: int
var _afines_pct: int
var _divisor: int
var _arrimo: Arrimo
var _afinidad: Afinidad


func _init(sin_relacion_pct: int, afines_pct: int, divisor: int, arrimo: Arrimo, afinidad: Afinidad) -> void:
	_sin_relacion_pct = sin_relacion_pct
	_afines_pct = afines_pct
	_divisor = divisor
	_arrimo = arrimo
	_afinidad = afinidad


# tabla_combate: tablas/combate.json (combo). arrimo y afinidad: los del ContextoCombate.
static func desde_datos(tabla_combate: Dictionary, arrimo: Arrimo, afinidad: Afinidad) -> Combo:
	var combo: Dictionary = tabla_combate["combo"]
	return Combo.new(combo["sin_relacion_pct"], combo["afines_pct"], combo["divisor_por_eslabon"], arrimo, afinidad)


# Sistema.md 10.2 y 1.3: el bono base del par (el ultimo atacante y el actual)
# mas el Arrimo. S-28: solo la relacion, sin adyacencia ni de pie.
func bono_par(anterior_id: String, atacante_id: String, plantel: Plantel) -> int:
	var base: int = _afines_pct if _afinidad.relacion_afin(anterior_id, atacante_id, plantel) else _sin_relacion_pct
	return base + _arrimo.ajuste(Arrimo.pasos(plantel.maestro), Arrimo.Uso.COMBO)


# S-27 (lectura declarada): el eslabon k (desde 2) usa la base de su par,
# dividida k - 2 veces, en enteros. Dividir de a una con piso da lo mismo que
# dividir una vez por el divisor elevado a k - 2.
func bono(eslabon: int, anterior_id: String, atacante_id: String, plantel: Plantel) -> int:
	var resultado: int = bono_par(anterior_id, atacante_id, plantel)
	for _i in range(eslabon - 2):
		resultado = resultado / _divisor
	return resultado
