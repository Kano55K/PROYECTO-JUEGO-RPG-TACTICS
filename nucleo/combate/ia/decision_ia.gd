# Lo que decide la IA de una salvaje para su turno (Sistema.md 11.8): la lista
# de Accion que va a jugar (las mismas del jugador, T08) y, para depurar, que
# paso eligio, contra quien y desde donde. La IA no aplica nada: quien llama
# aplica las acciones con Turno y corta si el combate termina.
class_name DecisionIA
extends RefCounted

# Huida y Encono (pasos 1 y 2) entran en T25 y T19/T20.
enum Paso { ERIZARSE, REMATE, CERCANA, ACERCARSE }

var paso: Paso
var acciones: Array[Accion] = []
# "" si se eriza o si no hay a quien acercarse.
var objetivo_id: String = ""
# Donde termina el turno: la casilla desde la que golpea, o a la que se mueve.
var casilla: Vector2i = Criatura.SIN_POSICION
# 0 si no ataca.
var danio_previsto: int = 0


func _init(paso_elegido: Paso) -> void:
	paso = paso_elegido


# Solo para depurar (registro, consola): nunca es un texto para el jugador.
func describir() -> String:
	var texto: String = "%s %s desde %s" % [Paso.keys()[paso], objetivo_id, casilla]
	if paso in [Paso.REMATE, Paso.CERCANA]:
		texto += ": danio %d" % danio_previsto
	var tipos: Array[String] = []
	for accion in acciones:
		var tipo: String = Accion.Tipo.keys()[accion.tipo]
		match accion.tipo:
			Accion.Tipo.MOVER:
				tipo += " %s" % accion.casilla
			Accion.Tipo.ATACAR:
				tipo += " " + accion.objetivo_id
		tipos.append(tipo)
	return texto + " | " + ", ".join(tipos)
