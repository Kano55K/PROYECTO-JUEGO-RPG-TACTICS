# Arquitectura.md D-015 (T33, sesion 3): la ficha de playtest de un combate
# (esquema playtest): de que grupo es la partida y quien la jugo. La escribe la
# pantalla junto al resultado y la lee AlarmasPlaytest. Es el unico lugar que
# la arma. Sin estado.
class_name FichaPlaytest
extends RefCounted

const _RUTA_SEMILLA: String = "semilla"


# cambios: los del panel (EdicionEscenario.cambios); la semilla nunca es parte
# de la variante (D-015). semillas_playtest: las de playtest/alarmas.json (vacia
# si no estan). jugador: lo escrito en el selector; vacio o null -> null.
static func armar(escenario_id: String, cambios: Dictionary, semilla: int, semillas_playtest: Array,
		jugador: Variant) -> Dictionary:
	var variante: Dictionary = cambios.duplicate(true)
	variante.erase(_RUTA_SEMILLA)
	var nombre: Variant = null
	if jugador != null and not (jugador as String).strip_edges().is_empty():
		nombre = (jugador as String).strip_edges()
	return {"escenario": escenario_id, "variante": variante, "semilla": semilla,
			"indice_semilla": indice(semilla, semillas_playtest), "jugador": nombre}


# La posicion (desde 1) de la semilla en la lista de playtest, o null.
static func indice(semilla: int, semillas_playtest: Array) -> Variant:
	var posicion: int = semillas_playtest.find(semilla)
	return null if posicion < 0 else posicion + 1


# Para un resultado sin ficha: el escenario y la semilla salen del resultado;
# la variante y el jugador quedan desconocidos (null). No valida contra el
# esquema playtest: AlarmasPlaytest la agrupa aparte.
static func desconocida(resultado: Dictionary, semillas_playtest: Array) -> Dictionary:
	var semilla: int = resultado["semilla"]
	return {"escenario": resultado["contexto_id"], "variante": null, "semilla": semilla,
			"indice_semilla": indice(semilla, semillas_playtest), "jugador": null}
