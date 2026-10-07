# Arquitectura.md B.2 (T13, sesion 2): traduce la casilla clicada en la Accion
# que corresponde, sin nodos. No tiene reglas propias: usa las consultas del
# Turno (T08) y las posiciones de instantanea(). Casilla con una objetivo
# atacable -> atacar; casilla alcanzable -> mover; cualquier otra -> null.
class_name InterpreteClic
extends RefCounted


# foto: Combate.instantanea() (o Plantel.instantanea()). null si no hay accion.
# T40: con modo_cavar (el jugador pulso Cavar), solo una casilla donde `cavar`
# vale (Turno.casillas_para_cavar) da la accion; cualquier otra, null.
# T17: con modo_secundar (el jugador pulso Secundar), solo una aliada a la que
# `secundar` vale (Turno.aliadas_para_secundar) da la accion; cualquier otra, null.
static func accion(turno: Turno, foto: Dictionary, casilla: Vector2i, modo_cavar: bool = false,
		modo_secundar: bool = false) -> Accion:
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
