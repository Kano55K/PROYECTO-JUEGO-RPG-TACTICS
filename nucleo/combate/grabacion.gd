# Arquitectura.md A.7, Grabacion: version de formato, escenario entero tal como
# se jugo, huella de los datos y acciones del jugador en orden, cada una con el
# id de su unidad. No guarda decisiones de la IA ni tiradas: salen del estado y
# de la semilla. Su diccionario valida contra grabacion.schema.json.
class_name Grabacion
extends RefCounted

# Version del formato del archivo (no es un numero de balance).
const FORMATO: int = 1

var version: int = FORMATO
var escenario: Dictionary = {}
var huella: String = ""
# {unidad, accion}: la accion como Accion.a_diccionario().
var acciones: Array[Dictionary] = []


static func desde_combate(combate: Combate) -> Grabacion:
	var grabacion: Grabacion = Grabacion.new()
	grabacion.escenario = combate.contexto().escenario.duplicate(true)
	grabacion.huella = combate.contexto().huella
	grabacion.acciones = combate.acciones_jugador()
	return grabacion


func a_diccionario() -> Dictionary:
	return {
		"version": version,
		"escenario": escenario.duplicate(true),
		"huella": huella,
		"acciones": acciones.duplicate(true),
	}


# datos: ya validado contra grabacion.schema.json (enteros convertidos).
static func desde_diccionario(datos: Dictionary) -> Grabacion:
	var grabacion: Grabacion = Grabacion.new()
	grabacion.version = datos["version"]
	grabacion.escenario = (datos["escenario"] as Dictionary).duplicate(true)
	grabacion.huella = datos["huella"]
	for accion in (datos["acciones"] as Array):
		grabacion.acciones.append((accion as Dictionary).duplicate(true))
	return grabacion
