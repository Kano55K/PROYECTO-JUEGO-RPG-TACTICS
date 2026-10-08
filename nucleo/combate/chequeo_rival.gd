# Sistema.md 10.5, 10.6 y 11.3 (paso 3), v1.6: el chequeo de rival enemiga. Una
# criatura con alguna rival enemiga a su alcance hace una sola tirada al inicio
# de su turno (S-37); segun el rol de su ficha es Encono (combate y mixta) o
# cobardia (trabajo), nunca segun el id (K-06). Tambien el contador del Encono,
# que suma con todo golpe aplicado a una rival enemiga, de cualquier bando. Sin
# estado de combate: los estados enconada y acobardada viven en el Turno, el
# contador en la Criatura, y la misma consulta la usa la pantalla
# (Combate.rival_en): calcular sin aplicar.
class_name ChequeoRival
extends RefCounted

# Arquitectura.md A.7 (T19): el tipo y el resultado del evento chequeo_rival.
const TIPO_ENCONO: String = "encono"
const TIPO_COBARDIA: String = "cobardia"
const RESULTADO_ENCONADA: String = "enconada"
const RESULTADO_NO_ENCONADA: String = "no_enconada"
const RESULTADO_ACOBARDADA: String = "acobardada"
const RESULTADO_RESISTIDA: String = "resistida"
# Los nombres del enum rol del esquema especie (Sistema.md 4.3).
const _ROL_TRABAJO: String = "trabajo"
const _PCT_MAXIMO: int = 100

var _encono: Dictionary
var _cobardia: Dictionary
var _afines: Dictionary
var _por_tramo: Dictionary
var _con_toggle: bool
var _arrimo: Arrimo
var _relaciones: Relaciones
var _obediencia: Obediencia
var _afinidad: Afinidad


func _init(tabla_combate: Dictionary, arrimo: Arrimo, relaciones: Relaciones, obediencia: Obediencia,
		afinidad: Afinidad, afines_contra_cobardia: bool) -> void:
	_encono = (tabla_combate["encono"] as Dictionary).duplicate(true)
	_cobardia = (tabla_combate["cobardia"] as Dictionary).duplicate(true)
	_afines = (tabla_combate["afines_contra_cobardia"] as Dictionary).duplicate(true)
	_por_tramo = (tabla_combate["obediencia"] as Dictionary).duplicate(true)
	_con_toggle = afines_contra_cobardia
	_arrimo = arrimo
	_relaciones = relaciones
	_obediencia = obediencia
	_afinidad = afinidad


# tabla_combate: tablas/combate.json (encono, cobardia, afines_contra_cobardia y
# obediencia, 10.5, 10.6 y 5.4). arrimo: tablas/arrimo.json (1.3).
# afines_contra_cobardia: el toggle del escenario (10.6, PROPUESTA).
static func desde_datos(tabla_combate: Dictionary, arrimo: Arrimo, relaciones: Relaciones,
		obediencia: Obediencia, afinidad: Afinidad, afines_contra_cobardia: bool) -> ChequeoRival:
	return ChequeoRival.new(tabla_combate, arrimo, relaciones, obediencia, afinidad, afines_contra_cobardia)


# Sistema.md 10.5 y 10.6: la rama sale del rol de la ficha.
static func tipo(criatura: Criatura) -> String:
	return TIPO_COBARDIA if criatura.especie.rol() == _ROL_TRABAJO else TIPO_ENCONO


# Sistema.md 10.5, 10.7 y 10.8: de bandos distintos y su par de especies es "mal".
# Solo criaturas: el Maestro no tiene relaciones de especie.
func es_rival_enemiga(a_id: String, b_id: String, plantel: Plantel) -> bool:
	var a: Criatura = plantel.criatura(a_id)
	var b: Criatura = plantel.criatura(b_id)
	if a == null or b == null or a.bando == b.bando:
		return false
	return _relaciones.relacion(a.especie.id(), b.especie.id()) == Relaciones.Relacion.MAL


# Sistema.md 10.5, 11.2.2 y 11.5: las rivales enemigas a su alcance si la unidad
# estuviera en `casilla` (Objetivos: ni caida, ni guardada, ni fuera, ni oculta),
# en el orden del Plantel. De cualquier bando (10.7 y 9.2 punto 3, T20): la
# rival de una enemiga es una criatura de la tribu; el Maestro, que no tiene
# especie, nunca es rival.
func rivales_a_su_alcance(unidad_id: String, casilla: Vector2i, plantel: Plantel) -> Array[String]:
	var resultado: Array[String] = []
	if plantel.criatura(unidad_id) == null:
		return resultado
	for otra in plantel.criaturas():
		if es_rival_enemiga(unidad_id, otra.id, plantel) \
				and Objetivos.cuenta_como_rival_a_su_alcance(unidad_id, otra.id, plantel, casilla):
			resultado.append(otra.id)
	return resultado


# {tipo, rivales, porcentaje, seguro} si la unidad empezara su turno en `casilla`
# con el tablero de ahora. Sin rivales, porcentaje 0. Una sola probabilidad,
# aunque tenga varias (S-37). seguro: Encono con el contador en el maximo ("con
# 3, queda enconada seguro", 10.5), y entonces el porcentaje es 100. La usan la
# tirada y la pantalla. No modifica nada.
func consulta(unidad_id: String, casilla: Vector2i, plantel: Plantel) -> Dictionary:
	var criatura: Criatura = plantel.criatura(unidad_id)
	var rivales: Array[String] = []
	if criatura == null:
		return {"tipo": "", "rivales": rivales, "porcentaje": 0, "seguro": false}
	var tipo_chequeo: String = tipo(criatura)
	rivales = rivales_a_su_alcance(unidad_id, casilla, plantel)
	var porcentaje: int = 0
	var seguro: bool = false
	if not rivales.is_empty():
		if tipo_chequeo == TIPO_ENCONO:
			seguro = criatura.encono >= (_encono["max_puntos"] as int)
			porcentaje = _PCT_MAXIMO if seguro else _pct_encono(criatura, plantel)
		else:
			porcentaje = _pct_cobardia(criatura, casilla, plantel)
	return {"tipo": tipo_chequeo, "rivales": rivales, "porcentaje": porcentaje, "seguro": seguro}


# Sistema.md 10.5, 10.6 y 11.3 paso 3: la tirada del inicio del turno, desde la
# casilla actual. {} si no tiene rivales a su alcance o si da 0 % (no toca el
# generador). Si es seguro, enconada sin tirar. Si no, una tirada con
# Porcentajes.tirar. Devuelve {tipo, rivales, porcentaje, tiro, resultado}.
func tirar(unidad_id: String, plantel: Plantel, azar: GeneradorAzar) -> Dictionary:
	var criatura: Criatura = plantel.criatura(unidad_id)
	if criatura == null:
		return {}
	var datos: Dictionary = consulta(unidad_id, criatura.posicion, plantel)
	if (datos["rivales"] as Array).is_empty() or (datos["porcentaje"] == 0 and not datos["seguro"]):
		return {}
	var sale: bool = true
	var tiro: bool = not datos["seguro"]
	if tiro:
		sale = Porcentajes.tirar(azar, datos["porcentaje"])
	var resultado: String
	if datos["tipo"] == TIPO_ENCONO:
		resultado = RESULTADO_ENCONADA if sale else RESULTADO_NO_ENCONADA
	else:
		resultado = RESULTADO_ACOBARDADA if sale else RESULTADO_RESISTIDA
	return {"tipo": datos["tipo"], "rivales": datos["rivales"], "porcentaje": datos["porcentaje"], "tiro": tiro,
			"resultado": resultado}


# Sistema.md 10.5, Cada golpe a la rival: un golpe aplicado de una criatura de
# combate o mixta a su rival enemiga suma 1 hasta el maximo, este enconada o no y
# sea del bando que sea. Devuelve el evento encono de A.7 ({tipo, unidad, de, a,
# rival}), o {} si el contador no cambio.
func sumar_golpe(atacante_id: String, objetivo_id: String, plantel: Plantel) -> Dictionary:
	var atacante: Criatura = plantel.criatura(atacante_id)
	if atacante == null or tipo(atacante) != TIPO_ENCONO or not es_rival_enemiga(atacante_id, objetivo_id, plantel):
		return {}
	var antes: int = atacante.encono
	atacante.encono = mini(antes + 1, _encono["max_puntos"])
	if atacante.encono == antes:
		return {}
	return {"tipo": "encono", "unidad": atacante_id, "de": antes, "a": atacante.encono, "rival": objetivo_id}


# Sistema.md 10.5: el tope del contador ("contador de 0 a 3"), para la pantalla.
func maximo_encono() -> int:
	return _encono["max_puntos"]


# Sistema.md 10.5 y 11.4 paso 3: el bono de la enconada, contando el punto que
# suma ese golpe (maximo el tope). Se calcula antes de subir el contador, asi
# validar, previsualizar y aplicar dan lo mismo.
func aporte_encono(criatura: Criatura) -> ModificadorDanio:
	var puntos: int = mini(criatura.encono + 1, _encono["max_puntos"])
	return ModificadorDanio.new(ModificadorDanio.Fuente.ENCONO, ModificadorDanio.Tipo.PLANO,
			puntos * (_encono["danio_plano_por_punto"] as int))


# Sistema.md 10.6 y 11.4 paso 1: el porcentaje de la acobardada.
func aporte_cobardia() -> ModificadorDanio:
	return ModificadorDanio.new(ModificadorDanio.Fuente.COBARDIA, ModificadorDanio.Tipo.PORCENTAJE,
			_cobardia["danio_pct"])


# Sistema.md 10.5: base + por punto x contador, Arrimo (1.3; las enemigas no
# tienen, 10.7) y tramo (5.4; las enemigas, baja), entre 0 y 100.
func _pct_encono(criatura: Criatura, plantel: Plantel) -> int:
	var pct: int = (_encono["base_pct"] as int) + (_encono["por_punto_pct"] as int) * criatura.encono \
			+ _arrimo.ajuste(Arrimo.pasos_de(criatura, plantel.maestro), Arrimo.Uso.ENCONO) \
			+ _ajuste_tramo(criatura, plantel, "encono_pts")
	return clampi(pct, 0, _PCT_MAXIMO)


# Sistema.md 10.6: base, Arrimo, tramo y el Maestro de pie vecino en 8 (11.3
# v1.6). Con el toggle, cada afin de pie vecina en 8 sin contar al Maestro
# (P-008), con su tope y su minimo; sin el toggle, piso 0. Lectura declarada
# S-41 (T20): el -10 del Maestro es sosten de su tribu; una enemiga junto al
# Maestro no lo recibe. Sus afines del toggle son de su bando (Afinidad).
func _pct_cobardia(criatura: Criatura, casilla: Vector2i, plantel: Plantel) -> int:
	var pct: int = (_cobardia["base_pct"] as int) \
			+ _arrimo.ajuste(Arrimo.pasos_de(criatura, plantel.maestro), Arrimo.Uso.COBARDIA) \
			+ _ajuste_tramo(criatura, plantel, "cobardia_pts")
	if criatura.bando == Criatura.Bando.TRIBU and Objetivos.de_pie(Maestro.ID, plantel) \
			and Tablero.es_vecina_en_8(plantel.maestro.posicion, casilla):
		pct += _cobardia["maestro_adyacente_pts"] as int
	var piso: int = 0
	if _con_toggle:
		var afines: Array[String] = _afinidad.afines_vecinas(criatura.id, casilla, plantel)
		afines.erase(Maestro.ID)
		# Los puntos son negativos: el tope es el mayor descuento.
		pct += maxi(_afines["tope_pts"] as int, afines.size() * (_afines["por_afin_pts"] as int))
		piso = _afines["minimo_pct"]
	return clampi(pct, piso, _PCT_MAXIMO)


# Sistema.md 5.4: leal o baja suman lo suyo; neutral, nada.
func _ajuste_tramo(criatura: Criatura, plantel: Plantel, campo: String) -> int:
	var tramo: String = _obediencia.tramo(criatura, plantel.maestro)
	if not _por_tramo.has(tramo):
		return 0
	return (_por_tramo[tramo] as Dictionary)[campo]
