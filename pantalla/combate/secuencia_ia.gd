# Arquitectura.md B.2.1 (T40, sesion 2): el ritmo de la IA. Los turnos de la IA
# ya los resolvio el nucleo; esto solo copia del registro (A.7) los eventos
# `movimiento` y `ataque` de las acciones con origen "ia", en orden, para que la
# vista los muestre de a uno. No decide ni calcula nada.
class_name SecuenciaIA
extends RefCounted

const MOVIMIENTO: String = "movimiento"
const ATAQUE: String = "ataque"
const _ORIGEN_IA: String = "ia"


# lineas: RegistroCombate.lineas(). desde: la primera linea a leer.
# Cada paso: {tipo: MOVIMIENTO, unidad, desde, hasta} (casillas Vector2i) o
# {tipo: ATAQUE, unidad, objetivo, vida_despues}.
static func pasos(lineas: Array[Dictionary], desde: int) -> Array[Dictionary]:
	var resultado: Array[Dictionary] = []
	# El origen de la ultima `accion`: los eventos que la siguen son suyos.
	var de_la_ia: bool = false
	for indice in range(desde, lineas.size()):
		var linea: Dictionary = lineas[indice]
		match linea["tipo"]:
			"accion":
				de_la_ia = linea["origen"] == _ORIGEN_IA
			MOVIMIENTO:
				if de_la_ia:
					resultado.append({"tipo": MOVIMIENTO, "unidad": linea["unidad"],
							"desde": _casilla(linea["desde"]), "hasta": _casilla(linea["hasta"])})
			ATAQUE:
				if de_la_ia:
					resultado.append({"tipo": ATAQUE, "unidad": linea["atacante"],
							"objetivo": linea["objetivo"], "vida_despues": linea["vida_despues"]})
	return resultado


static func _casilla(lista: Array) -> Vector2i:
	return Vector2i(lista[0], lista[1])
