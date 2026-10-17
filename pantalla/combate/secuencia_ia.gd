# Arquitectura.md B.2.1 (T40, sesion 2): el ritmo de la IA. Los turnos de la IA
# ya los resolvio el nucleo; esto solo copia del registro (A.7) los eventos
# `movimiento` y `ataque` de las acciones con origen "ia", en orden, para que la
# vista los muestre de a uno. No decide ni calcula nada. T20: cada paso lleva
# el resultado del chequeo_rival del turno de esa unidad si la dejo enconada o
# acobardada (la marca que muestra su ficha mientras dura la secuencia).
class_name SecuenciaIA
extends RefCounted

const MOVIMIENTO: String = "movimiento"
const ATAQUE: String = "ataque"
const _ORIGEN_IA: String = "ia"
const _ESTADOS: Array[String] = [ChequeoRival.RESULTADO_ENCONADA, ChequeoRival.RESULTADO_ACOBARDADA]


# lineas: RegistroCombate.lineas(). desde: la primera linea a leer.
# Cada paso: {tipo: MOVIMIENTO, unidad, desde, hasta} (casillas Vector2i) o
# {tipo: ATAQUE, unidad, objetivo, vida_despues}. Los dos con `estado`: "enconada",
# "acobardada" o "" (el turno vuelto de Secundar sigue con el del inicio, S-31).
static func pasos(lineas: Array[Dictionary], desde: int) -> Array[Dictionary]:
	var resultado: Array[Dictionary] = []
	# El origen de la ultima `accion`: los eventos que la siguen son suyos.
	var de_la_ia: bool = false
	# Unidad -> estado de su turno en curso.
	var estados: Dictionary = {}
	for indice in range(desde, lineas.size()):
		var linea: Dictionary = lineas[indice]
		match linea["tipo"]:
			"turno":
				estados[linea["unidad"]] = ""
			"chequeo_rival":
				if linea["resultado"] in _ESTADOS:
					estados[linea["unidad"]] = linea["resultado"]
			"accion":
				de_la_ia = linea["origen"] == _ORIGEN_IA
			MOVIMIENTO:
				if de_la_ia:
					resultado.append({"tipo": MOVIMIENTO, "unidad": linea["unidad"],
							"desde": _casilla(linea["desde"]), "hasta": _casilla(linea["hasta"]),
							"estado": estados.get(linea["unidad"], "")})
			ATAQUE:
				if de_la_ia:
					resultado.append({"tipo": ATAQUE, "unidad": linea["atacante"],
							"objetivo": linea["objetivo"], "vida_despues": linea["vida_despues"],
							"estado": estados.get(linea["atacante"], "")})
	return resultado


static func _casilla(lista: Array) -> Vector2i:
	return Vector2i(lista[0], lista[1])
