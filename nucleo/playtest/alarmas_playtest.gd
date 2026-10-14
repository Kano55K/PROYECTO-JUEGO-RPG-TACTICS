# Sistema.md 11.9 ("Como se mide" y "Umbrales de alarma") y D-015 (T33): mide un
# lote de partidas, no decide reglas. Agrupa por escenario + variante (los
# cambios del panel sin la semilla), cuenta partidas y jugadores, y evalua cada
# alarma de playtest/alarmas.json en todas las variantes de sus escenarios. Un
# calculo se reconoce por su "calculo", nunca por el id de la alarma o del
# escenario; sus numeros son dato. Solo enteros: una proporcion compara
# cuenta x 100 contra umbral x n, y un promedio va en decimas. Sin estado.
class_name AlarmasPlaytest
extends RefCounted

const ARCHIVO: String = "playtest/alarmas.json"

const ESTADO_OK: String = "ok"
const ESTADO_ALARMA: String = "alarma"
const ESTADO_INSUFICIENTE: String = "insuficiente"

const AVISO_SEMILLA_FUERA: String = "semilla_fuera_de_la_lista"

# El catalogo cerrado de calculos (D-015). Cada uno, programado una vez.
const CALCULO_PRIMER_SELLADO_MISMO_TRAMO: String = "primer_sellado_mismo_tramo"
const CALCULO_DESENLACE_PROPORCION: String = "desenlace_proporcion"
const CALCULO_RONDAS_PELEA_MAYOR_QUE: String = "rondas_pelea_mayor_que"
const CALCULO_RONDAS_PELEA_PROMEDIO_FUERA: String = "rondas_pelea_promedio_fuera"
const CALCULO_MUERE_SI_EMPEZO_SUELTA: String = "muere_si_empezo_suelta"
const CALCULO_COMBATES_CON_INCIDENTE: String = "combates_con_incidente"
const CALCULO_GOLPES_INCIDENTE_PROMEDIO: String = "golpes_incidente_promedio"

# Los parametros de cada calculo: el cargador revisa que esten todos y ninguno
# ajeno (como los rasgos, A.2.2). Es la unica lista.
const PARAMETROS: Dictionary = {
	CALCULO_PRIMER_SELLADO_MISMO_TRAMO: ["umbral_pct"],
	CALCULO_DESENLACE_PROPORCION: ["desenlaces", "comparacion", "umbral_pct"],
	CALCULO_RONDAS_PELEA_MAYOR_QUE: ["rondas", "umbral_pct"],
	CALCULO_RONDAS_PELEA_PROMEDIO_FUERA: ["desde_decimas", "hasta_decimas"],
	CALCULO_MUERE_SI_EMPEZO_SUELTA: ["especie", "umbral_pct"],
	CALCULO_COMBATES_CON_INCIDENTE: ["bando", "umbral_pct"],
	CALCULO_GOLPES_INCIDENTE_PROMEDIO: ["bando", "umbral_decimas"],
}

const COMPARACION_MAYOR_QUE: String = "mayor_que"
const COMPARACION_MENOR_QUE: String = "menor_que"

# La ruta de EdicionEscenario de la semilla, que no forma parte de la variante
# (D-015), y la del estado de una criatura de la tribu.
const _RUTA_SEMILLA: String = "semilla"
const _RUTA_ESTADO_TRIBU: String = "tribu.%s.estado"
const _ESTADO_SUELTA: String = "suelta"
const _CIEN: int = 100
const _DECIMAS: int = 10


# resultados: los diccionarios del esquema resultado. fichas: las fichas de
# playtest (esquema playtest), una por resultado y en el mismo orden. datos: los
# datos cargados (playtest/alarmas.json y escenarios/). Devuelve {grupos,
# avisos}; cada grupo: {escenario, variante, partidas, jugadores, semillas,
# semillas_fuera, alarmas}, y cada alarma: {id, calculo, valor, umbral, n,
# estado}. Los grupos, por escenario y despues por variante.
static func calcular(resultados: Array[Dictionary], fichas: Array[Dictionary], datos: Dictionary) -> Dictionary:
	var config: Dictionary = datos[ARCHIVO]
	var por_clave: Dictionary = {}
	for i in range(resultados.size()):
		var ficha: Dictionary = fichas[i]
		var variante: Dictionary = _sin_semilla(ficha["variante"])
		var clave: String = "%s|%s" % [ficha["escenario"], JSON.stringify(variante, "", true)]
		if not por_clave.has(clave):
			por_clave[clave] = {"escenario": ficha["escenario"], "variante": variante, "partidas": []}
		((por_clave[clave] as Dictionary)["partidas"] as Array).append({"resultado": resultados[i], "ficha": ficha})

	var claves: Array = por_clave.keys()
	claves.sort()
	var grupos: Array[Dictionary] = []
	var avisos: Array[Dictionary] = []
	for clave in claves:
		grupos.append(_grupo(por_clave[clave], config, datos, avisos))
	return {"grupos": grupos, "avisos": avisos}


static func _grupo(armado: Dictionary, config: Dictionary, datos: Dictionary, avisos: Array[Dictionary]) -> Dictionary:
	var escenario: String = armado["escenario"]
	var partidas: Array = armado["partidas"]
	var jugadores: Dictionary = {}
	var semillas: Array[int] = []
	for partida in partidas:
		var jugador: Variant = (partida["ficha"] as Dictionary)["jugador"]
		if jugador != null:
			jugadores[jugador] = true
		var semilla: int = (partida["resultado"] as Dictionary)["semilla"]
		if not semillas.has(semilla):
			semillas.append(semilla)
	semillas.sort()
	var semillas_fuera: Array[int] = []
	for semilla in semillas:
		if not (config["semillas"] as Array).has(semilla):
			semillas_fuera.append(semilla)
			avisos.append({"tipo": AVISO_SEMILLA_FUERA, "escenario": escenario, "variante": armado["variante"],
					"semilla": semilla})

	# 11.9: 10 partidas por escenario y variante, al menos 3 jugadores.
	var suficiente: bool = partidas.size() >= (config["partidas_por_grupo"] as int) \
			and jugadores.size() >= (config["jugadores_minimos"] as int)
	var alarmas: Array[Dictionary] = []
	for alarma in (config["alarmas"] as Array):
		# Una alarma de un escenario vale para todas sus variantes.
		if not (alarma["escenarios"] as Array).has(escenario):
			continue
		var medida: Dictionary = _medir(alarma, partidas, escenario, datos)
		var estado: String = ESTADO_INSUFICIENTE
		if suficiente and (medida["n"] as int) > 0:
			estado = ESTADO_ALARMA if medida["salta"] else ESTADO_OK
		alarmas.append({"id": alarma["id"], "calculo": alarma["calculo"], "valor": medida["valor"],
				"umbral": medida["umbral"], "n": medida["n"], "estado": estado})

	return {"escenario": escenario, "variante": armado["variante"], "partidas": partidas.size(),
			"jugadores": jugadores.size(), "semillas": semillas, "semillas_fuera": semillas_fuera,
			"alarmas": alarmas}


# {valor, umbral, n, salta}. valor es null si n = 0.
static func _medir(alarma: Dictionary, partidas: Array, escenario: String, datos: Dictionary) -> Dictionary:
	var parametros: Dictionary = alarma["parametros"]
	match alarma["calculo"]:
		CALCULO_PRIMER_SELLADO_MISMO_TRAMO:
			return _primer_sellado_mismo_tramo(parametros, partidas)
		CALCULO_DESENLACE_PROPORCION:
			var cuenta: int = 0
			for partida in partidas:
				if (parametros["desenlaces"] as Array).has(_resultado(partida)["desenlace"]):
					cuenta += 1
			return _proporcion(cuenta, partidas.size(), parametros["umbral_pct"], parametros["comparacion"])
		CALCULO_RONDAS_PELEA_MAYOR_QUE:
			var largas: int = 0
			for partida in partidas:
				if _rondas_de_pelea(partida) > (parametros["rondas"] as int):
					largas += 1
			return _proporcion(largas, partidas.size(), parametros["umbral_pct"], COMPARACION_MAYOR_QUE)
		CALCULO_RONDAS_PELEA_PROMEDIO_FUERA:
			return _rondas_pelea_promedio_fuera(parametros, partidas)
		CALCULO_MUERE_SI_EMPEZO_SUELTA:
			return _muere_si_empezo_suelta(parametros, partidas, escenario, datos)
		CALCULO_COMBATES_CON_INCIDENTE:
			var con_incidente: int = 0
			for partida in partidas:
				var del_bando: Dictionary = _metricas(partida)["incidentes"][parametros["bando"]]
				if (del_bando["distraida"] as int) + (del_bando["golpe"] as int) >= 1:
					con_incidente += 1
			return _proporcion(con_incidente, partidas.size(), parametros["umbral_pct"], COMPARACION_MENOR_QUE)
		CALCULO_GOLPES_INCIDENTE_PROMEDIO:
			# 11.9: "3 o mas" golpes por combate, en promedio.
			var golpes: int = 0
			for partida in partidas:
				golpes += _metricas(partida)["incidentes"][parametros["bando"]]["golpe"] as int
			var n: int = partidas.size()
			var umbral: int = parametros["umbral_decimas"]
			return {"valor": _decimas(golpes, n), "umbral": umbral, "n": n,
					"salta": golpes * _DECIMAS >= umbral * n}
	push_error("AlarmasPlaytest: calculo desconocido %s" % [alarma["calculo"]])
	return {"valor": null, "umbral": null, "n": 0, "salta": false}


# Metrica 7. Entre las partidas con algun intento de sellado, cuantos primeros
# intentos caen en el tramo mas frecuente. Tramo = el % mostrado (P-048).
static func _primer_sellado_mismo_tramo(parametros: Dictionary, partidas: Array) -> Dictionary:
	var por_tramo: Dictionary = {}
	var n: int = 0
	for partida in partidas:
		var sellados: Array = _metricas(partida)["sellados"]
		if sellados.is_empty():
			continue
		n += 1
		var tramo: int = (sellados[0] as Dictionary)["porcentaje"]
		por_tramo[tramo] = (por_tramo.get(tramo, 0) as int) + 1
	var mas_frecuente: int = 0
	for tramo in por_tramo.keys():
		mas_frecuente = maxi(mas_frecuente, por_tramo[tramo] as int)
	return _proporcion(mas_frecuente, n, parametros["umbral_pct"], COMPARACION_MAYOR_QUE)


# Metrica 1. Fuera del rango: por debajo de desde o por encima de hasta (los
# bordes no saltan).
static func _rondas_pelea_promedio_fuera(parametros: Dictionary, partidas: Array) -> Dictionary:
	var suma: int = 0
	for partida in partidas:
		suma += _rondas_de_pelea(partida)
	var n: int = partidas.size()
	var desde: int = parametros["desde_decimas"]
	var hasta: int = parametros["hasta_decimas"]
	return {"valor": _decimas(suma, n), "umbral": {"desde": desde, "hasta": hasta}, "n": n,
			"salta": suma * _DECIMAS < desde * n or suma * _DECIMAS > hasta * n}


# Metrica 11. n = las partidas en que alguna criatura de la tribu de esa
# especie empezo suelta; cuenta = las que alguna de ellas murio. El escenario
# jugado es el de datos con los cambios de la variante.
static func _muere_si_empezo_suelta(parametros: Dictionary, partidas: Array, escenario: String,
		datos: Dictionary) -> Dictionary:
	var archivo: Dictionary = datos["escenarios/%s.json" % [escenario]]
	var n: int = 0
	var murio: int = 0
	for partida in partidas:
		var variante: Dictionary = (partida["ficha"] as Dictionary)["variante"]
		var sueltas: Array[String] = []
		for criatura in (archivo["tribu"] as Array):
			if criatura["especie"] != parametros["especie"]:
				continue
			var estado: Variant = variante.get(_RUTA_ESTADO_TRIBU % [criatura["id"]], criatura["estado"])
			if estado == _ESTADO_SUELTA:
				sueltas.append(criatura["id"])
		if sueltas.is_empty():
			continue
		n += 1
		for muerte in (_metricas(partida)["muertes"] as Array):
			if sueltas.has(muerte["unidad"]):
				murio += 1
				break
	return _proporcion(murio, n, parametros["umbral_pct"], COMPARACION_MAYOR_QUE)


static func _proporcion(cuenta: int, n: int, umbral_pct: int, comparacion: String) -> Dictionary:
	var salta: bool = cuenta * _CIEN > umbral_pct * n
	if comparacion == COMPARACION_MENOR_QUE:
		salta = cuenta * _CIEN < umbral_pct * n
	var valor: Variant = null
	if n > 0:
		@warning_ignore("integer_division")
		valor = cuenta * _CIEN / n
	return {"valor": valor, "umbral": umbral_pct, "n": n, "salta": salta}


# El promedio en decimas, truncado (solo para mostrar: la comparacion es exacta).
static func _decimas(suma: int, n: int) -> Variant:
	if n == 0:
		return null
	@warning_ignore("integer_division")
	return suma * _DECIMAS / n


static func _sin_semilla(variante: Dictionary) -> Dictionary:
	var copia: Dictionary = variante.duplicate(true)
	copia.erase(_RUTA_SEMILLA)
	return copia


static func _resultado(partida: Dictionary) -> Dictionary:
	return partida["resultado"]


static func _metricas(partida: Dictionary) -> Dictionary:
	return _resultado(partida)["metricas"]


static func _rondas_de_pelea(partida: Dictionary) -> int:
	return (_metricas(partida)["rondas"] as Dictionary)["de_pelea"]
