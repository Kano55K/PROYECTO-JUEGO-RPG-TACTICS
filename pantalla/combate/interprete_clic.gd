# Arquitectura.md B.2 (T13, sesion 2): traduce la casilla clicada en la Accion
# que corresponde, sin nodos. No tiene reglas propias: usa las consultas del
# Turno (T08) y las posiciones de instantanea(). Casilla con una objetivo
# atacable -> atacar; casilla alcanzable -> mover; cualquier otra -> null. En el
# modo de un hechizo (T22), la objetivo -> hechizo.
class_name InterpreteClic
extends RefCounted


# foto: Combate.instantanea() (o Plantel.instantanea()). null si no hay accion.
# T40: con modo_cavar (el jugador pulso Cavar), solo una casilla donde `cavar`
# vale (Turno.casillas_para_cavar) da la accion; cualquier otra, null.
# T17: con modo_secundar (el jugador pulso Secundar), solo una aliada a la que
# `secundar` vale (Turno.aliadas_para_secundar) da la accion; cualquier otra, null.
# T22: con hechizo_id (el jugador pulso el boton de un hechizo), solo una objetivo
# de Turno.objetivos_para_hechizo da la accion. alterno: el clic derecho
# (`seleccionar_alterno`). Un hechizo sin modos va con el clic izquierdo; uno con
# modos, el izquierdo empuja y el derecho atrae, si ese sentido esta en
# Turno.sentidos_para_hechizo. Fuera del modo hechizo, el clic derecho no hace nada.
# T24: con modo_sellar (el jugador pulso Sellar), solo una objetivo de
# Turno.objetivos_para_sellar da la accion, con el clic izquierdo.
# T26: con criatura_invocar (el jugador pulso el boton de invocar de esa
# guardada), solo una casilla donde la invocacion vale (Turno.previsualizar_invocar)
# da la accion, con el clic izquierdo.
static func accion(turno: Turno, foto: Dictionary, casilla: Vector2i, modo_cavar: bool = false,
		modo_secundar: bool = false, hechizo_id: String = "", alterno: bool = false,
		modo_sellar: bool = false, criatura_invocar: String = "") -> Accion:
	if not hechizo_id.is_empty():
		return _accion_hechizo(turno, foto, casilla, hechizo_id, alterno)
	if alterno:
		return null
	if not criatura_invocar.is_empty():
		return Accion.invocar(criatura_invocar, casilla) \
				if turno.previsualizar_invocar(criatura_invocar, casilla).valida else null
	if modo_sellar:
		var objetivo_sellar: String = objetivo_sellar_en(turno, foto, casilla)
		return null if objetivo_sellar.is_empty() else Accion.sellar(objetivo_sellar)
	if modo_cavar:
		return Accion.cavar(casilla) if turno.casillas_para_cavar().has(casilla) else null
	if modo_secundar:
		var aliada: String = aliada_en(turno, foto, casilla)
		return null if aliada.is_empty() else Accion.secundar(aliada)
	var objetivo: String = objetivo_en(turno, foto, casilla)
	if not objetivo.is_empty():
		return Accion.atacar(objetivo)
	if turno.casillas_para_mover().has(casilla):
		return Accion.mover(casilla)
	return null


# El id de la objetivo atacable que esta en la casilla, o "".
static func objetivo_en(turno: Turno, foto: Dictionary, casilla: Vector2i) -> String:
	return _unidad_de(turno.objetivos_para_atacar(), foto, casilla)


# T17: el id de la aliada que se puede Secundar en la casilla, o "".
static func aliada_en(turno: Turno, foto: Dictionary, casilla: Vector2i) -> String:
	return _unidad_de(turno.aliadas_para_secundar(), foto, casilla)


# T22: el id de la objetivo del hechizo que esta en la casilla, o "".
static func objetivo_hechizo_en(turno: Turno, foto: Dictionary, casilla: Vector2i, hechizo_id: String) -> String:
	return _unidad_de(turno.objetivos_para_hechizo(hechizo_id), foto, casilla)


# T24: el id de la objetivo del sellado que esta en la casilla, o "".
static func objetivo_sellar_en(turno: Turno, foto: Dictionary, casilla: Vector2i) -> String:
	return _unidad_de(turno.objetivos_para_sellar(), foto, casilla)


static func _accion_hechizo(turno: Turno, foto: Dictionary, casilla: Vector2i, hechizo_id: String,
		alterno: bool) -> Accion:
	var objetivo: String = objetivo_hechizo_en(turno, foto, casilla, hechizo_id)
	if objetivo.is_empty():
		return null
	var sentidos: Array[String] = turno.sentidos_para_hechizo(hechizo_id, objetivo)
	if sentidos.has(""):
		return null if alterno else Accion.hechizo(hechizo_id, objetivo)
	var sentido: String = Hechizos.SENTIDO_ATRAER if alterno else Hechizos.SENTIDO_EMPUJAR
	return Accion.hechizo(hechizo_id, objetivo, sentido) if sentidos.has(sentido) else null


# La unidad de `ids` que esta en la casilla, o "".
static func _unidad_de(ids: Array[String], foto: Dictionary, casilla: Vector2i) -> String:
	if ids.is_empty():
		return ""
	var casilla_lista: Array = [casilla.x, casilla.y]
	if ids.has(Maestro.ID) and foto["maestro"]["posicion"] == casilla_lista:
		return Maestro.ID
	for criatura in foto["criaturas"]:
		if ids.has(criatura["id"]) and criatura["posicion"] == casilla_lista:
			return criatura["id"]
	return ""
