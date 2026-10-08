# Arquitectura.md B.2.1 (T38): la consulta unica de objetivo. Toda eleccion de
# objetivo (ataque, IA, previsualizacion y, despues, Encono, hechizos, sellar y
# guardar) pasa por aca: ninguna otra clase mira por su cuenta si una unidad
# esta caida, fuera, guardada u oculta. Solo consultas: no modifica el Plantel.
# El bando no esta aca: cada accion dice el suyo (la Lanzadera vale sobre
# aliadas y enemigas, Sistema.md 1.6).
class_name Objetivos
extends RefCounted

# Sistema.md 11.2.2, Acciones hostiles y aliadas. HOSTIL: ataque, Martillazo,
# Lanzadera, sellar y Encono (S-21). ALIADA: Remiendo y guardar (S-22).
enum Clase { HOSTIL, ALIADA }


# NINGUNO si la unidad puede ser objetivo de una accion de esa clase; si no, por
# que. Una oculta solo queda afuera de las hostiles. La aliada tambien deja
# afuera a la caida (Remiendo, 1.6); guardar a una caida es de T26 (P-025).
static func motivo(objetivo_id: String, clase: Clase, plantel: Plantel) -> ResultadoAccion.Motivo:
	if objetivo_id != Maestro.ID and plantel.criatura(objetivo_id) == null:
		return ResultadoAccion.Motivo.OBJETIVO_INEXISTENTE
	if not _en_el_tablero(objetivo_id, plantel):
		return ResultadoAccion.Motivo.OBJETIVO_FUERA_DEL_TABLERO
	if not de_pie(objetivo_id, plantel):
		return ResultadoAccion.Motivo.OBJETIVO_CAIDO
	if clase == Clase.HOSTIL and objetivo_id != Maestro.ID and plantel.criatura(objetivo_id).oculta:
		return ResultadoAccion.Motivo.OBJETIVO_OCULTO
	return ResultadoAccion.Motivo.NINGUNO


static func puede_ser_objetivo(objetivo_id: String, clase: Clase, plantel: Plantel) -> bool:
	return motivo(objetivo_id, clase, plantel) == ResultadoAccion.Motivo.NINGUNO


# En el tablero y no caida: el Maestro sin caer o una suelta con posicion. Es
# "de pie" para las reglas que no eligen objetivo (enemiga de pie adyacente).
static func de_pie(unidad_id: String, plantel: Plantel) -> bool:
	if not _en_el_tablero(unidad_id, plantel):
		return false
	if unidad_id == Maestro.ID:
		return not plantel.maestro.caido
	return plantel.criatura(unidad_id).estado == Criatura.Estado.SUELTA


# Sistema.md 10.5 (para T19): una rival enemiga "a su alcance" esta a distancia
# Manhattan <= Movimiento + Alcance de la criatura. Una oculta no cuenta
# (Rival oculta, 11.2.2): es la misma regla que la de los objetivos hostiles.
# Que sean rivales (relaciones.json) lo mira quien llama. desde: la casilla desde
# la que se mide (T19, Combate.rival_en: calcular sin aplicar); sin ella, la suya.
static func cuenta_como_rival_a_su_alcance(unidad_id: String, rival_id: String, plantel: Plantel,
		desde: Vector2i = Criatura.SIN_POSICION) -> bool:
	if not puede_ser_objetivo(rival_id, Clase.HOSTIL, plantel):
		return false
	var criatura: Criatura = plantel.criatura(unidad_id)
	var casilla: Vector2i = criatura.posicion if desde == Criatura.SIN_POSICION else desde
	var alcance: int = criatura.especie.movimiento() + criatura.especie.alcance()
	return Tablero.distancia(casilla, _posicion(rival_id, plantel)) <= alcance


# Ocupa una casilla: no esta guardada ni fuera, y tiene posicion.
static func _en_el_tablero(unidad_id: String, plantel: Plantel) -> bool:
	if unidad_id != Maestro.ID:
		var criatura: Criatura = plantel.criatura(unidad_id)
		if criatura.estado in [Criatura.Estado.GUARDADA, Criatura.Estado.FUERA]:
			return false
	return _posicion(unidad_id, plantel) != Criatura.SIN_POSICION


static func _posicion(unidad_id: String, plantel: Plantel) -> Vector2i:
	if unidad_id == Maestro.ID:
		return plantel.maestro.posicion
	return plantel.criatura(unidad_id).posicion
