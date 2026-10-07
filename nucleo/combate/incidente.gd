# Sistema.md 10.4 v1.6: incidente entre rivales aliadas. Una criatura de la tribu
# con al menos una rival aliada en sus 8 vecinas (11.3 v1.6, D-001) hace una sola
# tirada al inicio de su turno (paso 4 de 11.3). La probabilidad es la base de
# tablas/combate.json mas el Arrimo (1.3), con piso 0; con 0 no se tira. Sin
# estado de combate: la regla la aplica el Turno (el golpe pasa por el ataque) y
# la misma consulta la usa la pantalla (Combate.incidente_en): calcular sin aplicar.
class_name Incidente
extends RefCounted

var _base_pct: int
var _arrimo: Arrimo
var _relaciones: Relaciones
var _obediencia: Obediencia


func _init(base_pct: int, arrimo: Arrimo, relaciones: Relaciones, obediencia: Obediencia) -> void:
	_base_pct = base_pct
	_arrimo = arrimo
	_relaciones = relaciones
	_obediencia = obediencia


# tabla_combate: tablas/combate.json (incidente.base_pct, 10.4). arrimo: el de
# tablas/arrimo.json (incidente_pts, 1.3).
static func desde_datos(tabla_combate: Dictionary, arrimo: Arrimo, relaciones: Relaciones,
		obediencia: Obediencia) -> Incidente:
	return Incidente.new((tabla_combate["incidente"] as Dictionary)["base_pct"], arrimo, relaciones, obediencia)


# Sistema.md 10.4, 10.8, 11.2.2 y 11.5: las rivales aliadas de la unidad en las 8
# vecinas de `casilla`, en el orden del Plantel. Mismo bando, de pie (una oculta
# si; una caida, guardada o fuera no) y su par de especies es "mal". La unidad
# no cuenta como su propia rival. Hoy solo tiran las criaturas de la tribu: los
# incidentes de las salvajes son de T20 (10.7, sin Arrimo).
func rivales_vecinas(unidad_id: String, casilla: Vector2i, plantel: Plantel) -> Array[String]:
	var resultado: Array[String] = []
	var criatura: Criatura = plantel.criatura(unidad_id)
	if criatura == null or criatura.bando != Criatura.Bando.TRIBU:
		return resultado
	for otra in plantel.criaturas():
		if otra.id == unidad_id or otra.bando != criatura.bando or not Objetivos.de_pie(otra.id, plantel):
			continue
		if Tablero.es_vecina_en_8(otra.posicion, casilla) \
				and _relaciones.relacion(criatura.especie.id(), otra.especie.id()) == Relaciones.Relacion.MAL:
			resultado.append(otra.id)
	return resultado


# Sistema.md 10.4 y 1.3: {rivales, porcentaje} si la unidad empezara su turno en
# `casilla` con el tablero de ahora. Sin rivales, 0. Una sola probabilidad,
# aunque tenga varias. La usan la tirada y la pantalla. No modifica nada.
func consulta(unidad_id: String, casilla: Vector2i, plantel: Plantel) -> Dictionary:
	var rivales: Array[String] = rivales_vecinas(unidad_id, casilla, plantel)
	var porcentaje: int = 0
	if not rivales.is_empty():
		porcentaje = maxi(0, _base_pct + _arrimo.ajuste(Arrimo.pasos(plantel.maestro), Arrimo.Uso.INCIDENTE))
	return {"rivales": rivales, "porcentaje": porcentaje}


# Sistema.md 10.4: la tirada del inicio del turno, desde la casilla actual. {} si
# no tira (0 %) o si no sale; si sale, {rivales, porcentaje}. Con 0 % no toca el
# generador. azar: el de combate (A.8).
func tirar(unidad_id: String, plantel: Plantel, azar: GeneradorAzar) -> Dictionary:
	var criatura: Criatura = plantel.criatura(unidad_id)
	if criatura == null:
		return {}
	var datos: Dictionary = consulta(unidad_id, criatura.posicion, plantel)
	if datos["porcentaje"] == 0 or not Porcentajes.tirar(azar, datos["porcentaje"]):
		return {}
	return datos


# Sistema.md 5.4 y 10.4: con obediencia leal o neutral se distrae; con baja
# golpea a una rival (si la alcanza). Preguntada en el momento.
func se_distrae(criatura: Criatura, maestro: Maestro) -> bool:
	return _obediencia.tramo(criatura, maestro) != Obediencia.TRAMO_BAJA
