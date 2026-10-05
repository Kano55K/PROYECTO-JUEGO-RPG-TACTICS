# Arquitectura.md B.2 (T13, sesion 2): traduce la casilla clicada en la Accion
# que corresponde, sin nodos. No tiene reglas propias: usa las consultas del
# Turno (T08) y las posiciones de instantanea(). Casilla con una objetivo
# atacable -> atacar; casilla alcanzable -> mover; cualquier otra -> null.
class_name InterpreteClic
extends RefCounted


# foto: Combate.instantanea() (o Plantel.instantanea()). null si no hay accion.
static func accion(turno: Turno, foto: Dictionary, casilla: Vector2i) -> Accion:
	var objetivo: String = objetivo_en(turno, foto, casilla)
	if not objetivo.is_empty():
		return Accion.atacar(objetivo)
	if turno.casillas_para_mover().has(casilla):
		return Accion.mover(casilla)
	return null


# El id de la objetivo atacable que esta en la casilla, o "".
static func objetivo_en(turno: Turno, foto: Dictionary, casilla: Vector2i) -> String:
	var objetivos: Array[String] = turno.objetivos_para_atacar()
	if objetivos.is_empty():
		return ""
	var casilla_lista: Array = [casilla.x, casilla.y]
	if objetivos.has(Maestro.ID) and foto["maestro"]["posicion"] == casilla_lista:
		return Maestro.ID
	for criatura in foto["criaturas"]:
		if objetivos.has(criatura["id"]) and criatura["posicion"] == casilla_lista:
			return criatura["id"]
	return ""
