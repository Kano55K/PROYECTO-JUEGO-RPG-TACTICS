# Lo que decide la IA de una salvaje para su turno (Sistema.md 11.8): la lista
# de Accion que va a jugar (las mismas del jugador, T08) y, para depurar, que
# paso eligio, contra quien y desde donde. La IA no aplica nada: quien llama
# aplica las acciones con Turno y corta si el combate termina.
class_name DecisionIA
extends RefCounted

# La huida (paso 1) entra en T25. ENCONO es el 3 (T20); CAZA es el 6b
# (reemplaza a 5 y 6); PREPARARSE, el 7 (ocultarse o cavar).
enum Paso { ENCONO, ERIZARSE, REMATE, CERCANA, CAZA, PREPARARSE, ACERCARSE }
# El numero de cada paso en la lista de Sistema.md 11.8 v1.3.
const _NUMERO: Dictionary = {
	Paso.ENCONO: "3", Paso.ERIZARSE: "4", Paso.REMATE: "5", Paso.CERCANA: "6", Paso.CAZA: "6b",
	Paso.PREPARARSE: "7", Paso.ACERCARSE: "8",
}

var paso: Paso
var acciones: Array[Accion] = []
# La primera de `objetivos`; "" si no ataca ni tiene a quien acercarse.
var objetivo_id: String = ""
# Una por ataque planeado, en orden (en Caza, hasta dos).
var objetivos: Array[String] = []
# Donde termina el turno: la casilla desde la que golpea, o a la que se mueve.
var casilla: Vector2i = Criatura.SIN_POSICION
# Sistema.md 11.8, retirada de la Cuenta: a donde va despues de golpear, o
# SIN_POSICION si no se retira.
var retirada: Vector2i = Criatura.SIN_POSICION
# La suma de los golpes planeados; 0 si no ataca.
var danio_previsto: int = 0
# Paso 2 de 11.8: el modo con que juega el turno ("" sin modos) y el cambio que
# hizo el inicio del turno ({de, a} o {}). Lo resuelve el Turno, no la IA.
var modo: String = ""
var cambio_modo: Dictionary = {}


func _init(paso_elegido: Paso) -> void:
	paso = paso_elegido


# Solo para depurar (registro, consola): nunca es un texto para el jugador.
func describir() -> String:
	var texto: String = "paso %s %s" % [_NUMERO[paso], Paso.keys()[paso]]
	if not modo.is_empty():
		texto += " [%s]" % modo
	if not cambio_modo.is_empty():
		texto += " (paso 2: %s->%s)" % [cambio_modo["de"], cambio_modo["a"]]
	texto += " %s desde %s" % [", ".join(objetivos) if not objetivos.is_empty() else objetivo_id, casilla]
	if not objetivos.is_empty():
		texto += ": danio %d" % danio_previsto
	if retirada != Criatura.SIN_POSICION:
		texto += ", se retira a %s" % retirada
	var tipos: Array[String] = []
	for accion in acciones:
		var tipo: String = Accion.Tipo.keys()[accion.tipo]
		match accion.tipo:
			Accion.Tipo.MOVER, Accion.Tipo.CAVAR:
				tipo += " %s" % accion.casilla
			Accion.Tipo.ATACAR:
				tipo += " " + accion.objetivo_id
		tipos.append(tipo)
	return texto + " | " + ", ".join(tipos)


# Anota un ataque planeado contra `id_objetivo` con su danio previsto.
func sumar_ataque(id_objetivo: String, danio: int) -> void:
	if objetivos.is_empty():
		objetivo_id = id_objetivo
	objetivos.append(id_objetivo)
	danio_previsto += danio
	acciones.append(Accion.atacar(id_objetivo))
