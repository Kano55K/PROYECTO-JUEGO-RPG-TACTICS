# Sistema.md 1.3: el Arrimo, efecto del polo Barro. La cantidad de pasos sale de
# la fila de la balanza (1.2) y el efecto de cada paso de tablas/arrimo.json; la
# tabla por posicion de 1.3 es derivada y no se guarda (A.2.2). Es una consulta:
# la leen el combo (T16), el incidente (T18) y el Encono y la cobardia (T19).
# Las salvajes no tienen Arrimo (10.7): pasos_de da 0 para las enemigas.
class_name Arrimo
extends RefCounted

enum Uso { INCIDENTE, ENCONO, COBARDIA, COMBO }

# Campo de tablas/arrimo.json por_paso para cada uso.
const _CAMPOS: Dictionary = {
	Uso.INCIDENTE: "incidente_pts",
	Uso.ENCONO: "encono_pts",
	Uso.COBARDIA: "cobardia_pts",
	Uso.COMBO: "combo_pts",
}

var _por_paso: Dictionary = {}


func _init(por_paso: Dictionary) -> void:
	_por_paso = por_paso


# tabla_arrimo: tablas/arrimo.json.
static func desde_datos(tabla_arrimo: Dictionary) -> Arrimo:
	return Arrimo.new((tabla_arrimo["por_paso"] as Dictionary).duplicate(true))


# Sistema.md 1.2: los pasos de la posicion actual de la balanza.
static func pasos(maestro: Maestro) -> int:
	return maestro.fila_balanza()["pasos_arrimo"]


# Sistema.md 10.7 y 9.2 punto 3: los pasos que valen para una criatura. Las
# enemigas (salvajes y la atacante nocturna) no tienen Arrimo: 0. El unico lugar
# de esa regla; lo usan el incidente y el chequeo de rival enemiga (T20).
static func pasos_de(criatura: Criatura, maestro: Maestro) -> int:
	return pasos(maestro) if criatura.bando == Criatura.Bando.TRIBU else 0


# Sistema.md 1.3: puntos que suma (o resta) el Arrimo a la probabilidad o al
# bono del uso pedido.
func ajuste(cantidad_pasos: int, uso: Uso) -> int:
	return cantidad_pasos * (_por_paso[_CAMPOS[uso]] as int)
