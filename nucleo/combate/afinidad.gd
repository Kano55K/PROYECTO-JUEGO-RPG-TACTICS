# Sistema.md 10.3 v1.6: afinidad entre vecinas. La atacante suma el plano de
# tablas/combate.json si tiene al menos una afin en las 8 casillas alrededor de
# la casilla desde la que golpea (11.3 v1.6, D-001); nunca mas de una vez por ataque. Es un aporte externo de Danio
# (T09): lo pide Turno._aportes para el ataque real, validar, previsualizar y la
# IA. Sin estado de combate: las relaciones, la obediencia y las posiciones se
# preguntan en el momento (7.2, "en el acto").
class_name Afinidad
extends RefCounted

var _plano: int
var _relaciones: Relaciones
var _obediencia: Obediencia


func _init(plano: int, relaciones: Relaciones, obediencia: Obediencia) -> void:
	_plano = plano
	_relaciones = relaciones
	_obediencia = obediencia


# tabla_combate: tablas/combate.json (afinidad_danio_plano, 10.3 y 10.7).
static func desde_datos(tabla_combate: Dictionary, relaciones: Relaciones, obediencia: Obediencia) -> Afinidad:
	return Afinidad.new(tabla_combate["afinidad_danio_plano"], relaciones, obediencia)


# Sistema.md 10.3: "se mira la posicion del atacante al golpear", o sea `desde`,
# no la casilla actual. Se mira a la atacante, nunca a la objetivo. +1 como
# maximo, aunque tenga varias afines vecinas. null si no tiene ninguna.
func aporte(atacante_id: String, desde: Vector2i, plantel: Plantel) -> ModificadorDanio:
	if afines_vecinas(atacante_id, desde, plantel).is_empty():
		return null
	return ModificadorDanio.new(ModificadorDanio.Fuente.AFINIDAD, ModificadorDanio.Tipo.PLANO, _plano)


# Sistema.md 10.3 y 11.3 v1.6: los ids de las afines de pie en las 8 vecinas de
# `desde`, en el orden del Plantel. La atacante no cuenta como su propia afin
# (desde una casilla vecina veria la suya). La usan el aporte y la pantalla
# (Combate.afines_desde).
func afines_vecinas(atacante_id: String, desde: Vector2i, plantel: Plantel) -> Array[String]:
	var resultado: Array[String] = []
	for otra_id in _ids(plantel):
		if otra_id == atacante_id or not Objetivos.de_pie(otra_id, plantel):
			continue
		if Tablero.es_vecina_en_8(_posicion(otra_id, plantel), desde) and son_afines(atacante_id, otra_id, plantel):
			resultado.append(otra_id)
	return resultado


# Sistema.md 10.3, 10.7, 10.8, 11.2.2 y 11.5: la relacion y las dos de pie (ni
# caida, ni guardada, ni fuera; una oculta si).
func son_afines(a_id: String, b_id: String, plantel: Plantel) -> bool:
	if not Objetivos.de_pie(a_id, plantel) or not Objetivos.de_pie(b_id, plantel):
		return false
	return relacion_afin(a_id, b_id, plantel)


# Que es "afin", sin posicion ni estado: lo usan la afinidad (con de pie) y el
# combo (10.2, S-28: sin adyacencia ni de pie). Mismo bando; entre criaturas, su
# par de especies es "bien" (incluida la misma especie). El Maestro y una
# criatura de la tribu, si su obediencia esta en tramo leal, preguntado ahora:
# en los dos sentidos.
func relacion_afin(a_id: String, b_id: String, plantel: Plantel) -> bool:
	if a_id == b_id or _bando(a_id, plantel) != _bando(b_id, plantel):
		return false
	if a_id == Maestro.ID or b_id == Maestro.ID:
		var criatura: Criatura = plantel.criatura(b_id if a_id == Maestro.ID else a_id)
		return _obediencia.tramo(criatura, plantel.maestro) == Obediencia.TRAMO_LEAL
	return _relaciones.relacion(plantel.criatura(a_id).especie.id(), plantel.criatura(b_id).especie.id()) \
			== Relaciones.Relacion.BIEN


static func _ids(plantel: Plantel) -> Array[String]:
	var ids: Array[String] = [Maestro.ID]
	for criatura in plantel.criaturas():
		ids.append(criatura.id)
	return ids


static func _bando(unidad_id: String, plantel: Plantel) -> Criatura.Bando:
	if unidad_id == Maestro.ID:
		return Criatura.Bando.TRIBU
	return plantel.criatura(unidad_id).bando


static func _posicion(unidad_id: String, plantel: Plantel) -> Vector2i:
	if unidad_id == Maestro.ID:
		return plantel.maestro.posicion
	return plantel.criatura(unidad_id).posicion
