# Un modificador del danio de un ataque (Sistema.md 11.4): de las fuentes que
# Danio calcula sola o un aporte externo que llega por parametro (combo T16,
# afinidad T15, Encono y cobardia T19).
class_name ModificadorDanio
extends RefCounted

enum Fuente { HAMBRE, ENFERMEDAD, RASGO_ATACANTE, RASGO_OBJETIVO, COMBO, AFINIDAD, ENCONO, COBARDIA }
# PORCENTAJE: paso 1 de 11.4, en puntos (+25 = +25%). PLANO: paso 3.
enum Tipo { PORCENTAJE, PLANO }

var fuente: Fuente
var tipo: Tipo
var valor: int
# Para mostrarlo: id del estado de hambre o del rasgo (clave de texto). "" si no hace falta.
var detalle: String


func _init(fuente_modificador: Fuente, tipo_modificador: Tipo, valor_modificador: int, detalle_modificador: String = "") -> void:
	fuente = fuente_modificador
	tipo = tipo_modificador
	valor = valor_modificador
	detalle = detalle_modificador


# Para el registro (Arquitectura.md A.7). Fuente y tipo, en minusculas.
func a_diccionario() -> Dictionary:
	return {
		"fuente": (Fuente.keys()[fuente] as String).to_lower(),
		"tipo": (Tipo.keys()[tipo] as String).to_lower(),
		"valor": valor,
		"detalle": detalle,
	}
