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
const CALCULO_TASA_ACOBARDADAS_FUERA: String = "tasa_acobardadas_fuera"
const CALCULO_TOGGLE_AFINES: String = "toggle_afines"
const CALCULO_MAESTRO_CAE_SIN_RESCATISTA: String = "maestro_cae_sin_rescatista"
const CALCULO_SIN_CAIDAS_GUARDADAS: String = "sin_caidas_guardadas"
const CALCULO_DESTINO_ATACANTE_PROPORCION: String = "destino_atacante_proporcion"
const CALCULO_VICTORIAS_DIFERENCIA: String = "victorias_diferencia"
const CALCULO_DISTANCIA_MAESTRO_MAYOR_QUE: String = "distancia_maestro_mayor_que"
const CALCULO_ACTIVA_POCO_USADA: String = "activa_poco_usada"
const CALCULO_ENCIERRO_DE_EFECTO: String = "encierro_de_efecto"

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
	CALCULO_TASA_ACOBARDADAS_FUERA: ["bando", "desde_pct", "hasta_pct"],
	CALCULO_TOGGLE_AFINES: ["comparado_con", "bando", "supera_pct", "desde_pct", "hasta_pct"],
	CALCULO_MAESTRO_CAE_SIN_RESCATISTA: ["umbral_pct"],
	CALCULO_SIN_CAIDAS_GUARDADAS: ["umbral_pct"],
	CALCULO_DESTINO_ATACANTE_PROPORCION: ["opciones", "umbral_pct"],
	CALCULO_VICTORIAS_DIFERENCIA: ["comparado_con", "umbral_puntos"],
	CALCULO_DISTANCIA_MAESTRO_MAYOR_QUE: ["umbral_decimas", "umbral_pct"],
	CALCULO_ACTIVA_POCO_USADA: ["efecto", "umbral_pct"],
	CALCULO_ENCIERRO_DE_EFECTO: ["efecto", "umbral_pct"],
}

# Los que comparan dos escenarios (cada uno con su grupo sin cambios, 11.9): no
# se evaluan por grupo. Las comparaciones van en "comparaciones"; las
# informativas (deciden algo, no son una alarma), en "informativas".
const _COMPARACIONES: Array[String] = [CALCULO_VICTORIAS_DIFERENCIA]
const _INFORMATIVAS: Array[String] = [CALCULO_TOGGLE_AFINES]

# Resultado de una informativa (toggle_afines).
const RESULTADO_APROBADO: String = "aprobado"
const RESULTADO_NO_APROBADO: String = "no_aprobado"

# Metrica 14: la accion de cada efecto con activa (los tipos de
# MetricasCombate.ACTIVAS). Un efecto sin activa no esta: lo revisa el cargador.
const ACCION_DE_EFECTO: Dictionary = {
	Turno.EFECTO_ERIZARSE: "erizarse",
	Surcos.EFECTO: "cavar",
	Junco.EFECTO: "hacerse_junco",
}

const COMPARACION_MAYOR_QUE: String = "mayor_que"
const COMPARACION_MENOR_QUE: String = "menor_que"

# La ruta de EdicionEscenario de la semilla, que no forma parte de la variante
# (D-015), y la del estado de una criatura de la tribu.
const _RUTA_SEMILLA: String = "semilla"
const _RUTA_ESTADO_TRIBU: String = "tribu.%s.estado"
const _ESTADO_SUELTA: String = "suelta"
const _ESTADO_GUARDADA: String = "guardada"
const _BANDO_TRIBU: String = "tribu"
const _VICTORIA: String = "victoria"
const _CIEN: int = 100
const _DECIMAS: int = 10


# resultados: los diccionarios del esquema resultado. fichas: las fichas de
# playtest (esquema playtest; o FichaPlaytest.desconocida, con variante null),
# una por resultado y en el mismo orden. datos: los
# datos cargados (playtest/alarmas.json, escenarios/ y especies/). Devuelve
# {grupos, comparaciones, informativas, avisos}; cada grupo: {escenario,
# variante, partidas, jugadores, semillas, semillas_fuera, alarmas}, y cada
# alarma: {id, calculo, valor, umbral, n, estado}. Los grupos, por escenario y
# despues por variante. Cada comparacion: {id, calculo, escenario,
# comparado_con, valor, umbral, n, n_comparado, estado}; cada informativa, lo
# mismo con resultado en lugar de estado.
static func calcular(resultados: Array[Dictionary], fichas: Array[Dictionary], datos: Dictionary) -> Dictionary:
	var config: Dictionary = datos[ARCHIVO]
	var por_clave: Dictionary = {}
	for i in range(resultados.size()):
		var ficha: Dictionary = fichas[i]
		var variante: Variant = _sin_semilla(ficha["variante"])
		var clave: String = _clave(ficha["escenario"], variante)
		if not por_clave.has(clave):
			por_clave[clave] = {"escenario": ficha["escenario"], "variante": variante, "partidas": []}
		((por_clave[clave] as Dictionary)["partidas"] as Array).append({"resultado": resultados[i], "ficha": ficha})

	var claves: Array = por_clave.keys()
	claves.sort()
	var grupos: Array[Dictionary] = []
	var avisos: Array[Dictionary] = []
	for clave in claves:
		grupos.append(_grupo(por_clave[clave], config, datos, avisos))

	# 11.9: las que comparan escenarios usan el grupo sin cambios de cada uno.
	var comparaciones: Array[Dictionary] = []
	var informativas: Array[Dictionary] = []
	for alarma in (config["alarmas"] as Array):
		var calculo: String = alarma["calculo"]
		if not _COMPARACIONES.has(calculo) and not _INFORMATIVAS.has(calculo):
			continue
		var parametros: Dictionary = alarma["parametros"]
		for escenario in (alarma["escenarios"] as Array):
			var propias: Array = _partidas_sin_cambios(por_clave, escenario)
			var comparadas: Array = _partidas_sin_cambios(por_clave, parametros["comparado_con"])
			var suficiente: bool = _suficiente(propias, config) and _suficiente(comparadas, config)
			var entrada: Dictionary = {"id": alarma["id"], "calculo": calculo, "escenario": escenario,
					"comparado_con": parametros["comparado_con"], "n": propias.size(),
					"n_comparado": comparadas.size()}
			if calculo == CALCULO_TOGGLE_AFINES:
				informativas.append(_toggle_afines(entrada, parametros, propias, comparadas, suficiente))
			else:
				comparaciones.append(_victorias_diferencia(entrada, parametros, propias, comparadas, suficiente))
	return {"grupos": grupos, "comparaciones": comparaciones, "informativas": informativas, "avisos": avisos}


static func _grupo(armado: Dictionary, config: Dictionary, datos: Dictionary, avisos: Array[Dictionary]) -> Dictionary:
	var escenario: String = armado["escenario"]
	var partidas: Array = armado["partidas"]
	var semillas: Array[int] = []
	for partida in partidas:
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

	var suficiente: bool = _suficiente(partidas, config)
	var alarmas: Array[Dictionary] = []
	for alarma in (config["alarmas"] as Array):
		# Una alarma de un escenario vale para todas sus variantes.
		if not (alarma["escenarios"] as Array).has(escenario):
			continue
		if _COMPARACIONES.has(alarma["calculo"]) or _INFORMATIVAS.has(alarma["calculo"]):
			continue
		var medida: Dictionary = _medir(alarma, partidas, escenario, datos)
		var estado: String = ESTADO_INSUFICIENTE
		if suficiente and (medida["n"] as int) > 0:
			estado = ESTADO_ALARMA if medida["salta"] else ESTADO_OK
		alarmas.append({"id": alarma["id"], "calculo": alarma["calculo"], "valor": medida["valor"],
				"umbral": medida["umbral"], "n": medida["n"], "estado": estado})

	return {"escenario": escenario, "variante": armado["variante"], "partidas": partidas.size(),
			"jugadores": _jugadores(partidas), "semillas": semillas, "semillas_fuera": semillas_fuera,
			"alarmas": alarmas}


# 11.9: 10 partidas por escenario y variante, al menos 3 jugadores.
static func _suficiente(partidas: Array, config: Dictionary) -> bool:
	return partidas.size() >= (config["partidas_por_grupo"] as int) 			and _jugadores(partidas) >= (config["jugadores_minimos"] as int)


# Jugadores distintos; un jugador null (desconocido) no cuenta.
static func _jugadores(partidas: Array) -> int:
	var jugadores: Dictionary = {}
	for partida in partidas:
		var jugador: Variant = (partida["ficha"] as Dictionary)["jugador"]
		if jugador != null:
			jugadores[jugador] = true
	return jugadores.size()


static func _clave(escenario: String, variante: Variant) -> String:
	return "%s|%s" % [escenario, JSON.stringify(variante, "", true)]


static func _partidas_sin_cambios(por_clave: Dictionary, escenario: String) -> Array:
	return (por_clave.get(_clave(escenario, {}), {"partidas": []}) as Dictionary)["partidas"]


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
		CALCULO_TASA_ACOBARDADAS_FUERA:
			# Metrica 6, de las tiradas del bando (Arquitectura.md 10.5: la tribu).
			# Fuera: por debajo de desde o por encima de hasta (los bordes no saltan).
			var tasa: Dictionary = _tasa_acobardadas(partidas, parametros["bando"])
			var acobardadas: int = tasa["acobardadas"]
			var tiradas: int = tasa["tiradas"]
			var desde: int = parametros["desde_pct"]
			var hasta: int = parametros["hasta_pct"]
			return {"valor": tasa["valor"], "umbral": {"desde": desde, "hasta": hasta}, "n": tasa["n"],
					"salta": acobardadas * _CIEN < desde * tiradas or acobardadas * _CIEN > hasta * tiradas}
		CALCULO_MAESTRO_CAE_SIN_RESCATISTA:
			# Metricas 9 (el Maestro esta, P-043) y 12 (sin rescatista de pie).
			var cayo: int = 0
			var sin_rescatista: int = 0
			for partida in partidas:
				if not _cayo(partida, Maestro.ID):
					continue
				cayo += 1
				var rescate: Variant = _metricas(partida)["rescate"]
				if rescate == null or (rescate as Dictionary)["rescatista"] == null:
					sin_rescatista += 1
			return _proporcion(sin_rescatista, cayo, parametros["umbral_pct"], COMPARACION_MAYOR_QUE)
		CALCULO_SIN_CAIDAS_GUARDADAS:
			# Metricas 9 y 10. Partidas con caidas = alguna criatura de la tribu
			# cayo (P-050): el Maestro y las enemigas no se pueden guardar.
			var con_caidas: int = 0
			var sin_guardar: int = 0
			for partida in partidas:
				var tribu: Array[String] = _unidades(partida, _BANDO_TRIBU, "", datos)
				var alguna: bool = false
				for caida in (_metricas(partida)["caidas"] as Array):
					alguna = alguna or tribu.has(caida["unidad"])
				if not alguna:
					continue
				con_caidas += 1
				if (_metricas(partida)["caidas_guardadas"] as Array).is_empty():
					sin_guardar += 1
			return _proporcion(sin_guardar, con_caidas, parametros["umbral_pct"], COMPARACION_MAYOR_QUE)
		CALCULO_DESTINO_ATACANTE_PROPORCION:
			# Sobre las partidas con un destino elegido (P-051): sin atacante
			# caida, o si se fue (opcion null), no entra.
			var elegido: int = 0
			var de_la_lista: int = 0
			for partida in partidas:
				var destino: Variant = _resultado(partida)["destino_atacante"]
				if destino == null or (destino as Dictionary)["opcion"] == null:
					continue
				elegido += 1
				if (parametros["opciones"] as Array).has((destino as Dictionary)["opcion"]):
					de_la_lista += 1
			return _proporcion(de_la_lista, elegido, parametros["umbral_pct"], COMPARACION_MAYOR_QUE)
		CALCULO_DISTANCIA_MAESTRO_MAYOR_QUE:
			# Metrica 13: el promedio de cada combate (suma / turnos) mayor que
			# el umbral en decimas. Sin turnos desde el primer ataque, no entra.
			var con_turnos: int = 0
			var lejos: int = 0
			for partida in partidas:
				var distancia: Dictionary = _metricas(partida)["distancia_maestro"]
				var turnos: int = distancia["turnos"]
				if turnos == 0:
					continue
				con_turnos += 1
				if (distancia["suma"] as int) * _DECIMAS > (parametros["umbral_decimas"] as int) * turnos:
					lejos += 1
			return _proporcion(lejos, con_turnos, parametros["umbral_pct"], COMPARACION_MAYOR_QUE)
		CALCULO_ACTIVA_POCO_USADA:
			return _activa_poco_usada(parametros, partidas, escenario, datos)
		CALCULO_ENCIERRO_DE_EFECTO:
			# Metrica 14: n = partidas con alguna unidad (cualquier bando) cuya
			# ficha tiene el efecto; cuenta = alguna de ellas termino encerrada.
			var con_efecto: int = 0
			var encerrada: int = 0
			for partida in partidas:
				var ids: Array[String] = _unidades(partida, "", parametros["efecto"], datos)
				if ids.is_empty():
					continue
				con_efecto += 1
				for encierro in (_metricas(partida)["activas"]["encierros"] as Array):
					if ids.has(encierro["unidad"]) and (encierro["turnos"] as int) > 0:
						encerrada += 1
						break
			return _proporcion(encerrada, con_efecto, parametros["umbral_pct"], COMPARACION_MAYOR_QUE)
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
		var variante: Variant = (partida["ficha"] as Dictionary)["variante"]
		var sueltas: Array[String] = []
		for criatura in (archivo["tribu"] as Array):
			if criatura["especie"] == parametros["especie"] 					and _estado_inicial(criatura["id"], variante, archivo) == _ESTADO_SUELTA:
				sueltas.append(criatura["id"])
		if sueltas.is_empty():
			continue
		n += 1
		for muerte in (_metricas(partida)["muertes"] as Array):
			if sueltas.has(muerte["unidad"]):
				murio += 1
				break
	return _proporcion(murio, n, parametros["umbral_pct"], COMPARACION_MAYOR_QUE)


# Metrica 14. Disponible (Arquitectura.md 10.5) = una criatura de la tribu cuya
# ficha tiene el efecto estuvo en el tablero: empezo suelta, termino fuera de
# su pergamino (la invocaron) o uso la activa (P-052). n = partidas con alguna
# disponible; cuenta = alguna de ellas la uso. Salta por debajo del umbral.
static func _activa_poco_usada(parametros: Dictionary, partidas: Array, escenario: String,
		datos: Dictionary) -> Dictionary:
	var efecto: String = parametros["efecto"]
	var accion: String = ACCION_DE_EFECTO[efecto]
	var archivo: Dictionary = datos["escenarios/%s.json" % [escenario]]
	var disponible: int = 0
	var usada: int = 0
	for partida in partidas:
		var variante: Variant = (partida["ficha"] as Dictionary)["variante"]
		var usos: Dictionary = {}
		for fila in (_metricas(partida)["activas"]["usos"] as Array):
			usos[fila["unidad"]] = fila[accion]
		var alguna_disponible: bool = false
		var alguna_usada: bool = false
		for unidad in (_resultado(partida)["unidades"] as Array):
			if unidad["bando"] != _BANDO_TRIBU or _efecto_de(unidad["especie"], datos) != efecto:
				continue
			var usos_propios: int = usos.get(unidad["id"], 0)
			if _estado_inicial(unidad["id"], variante, archivo) != _ESTADO_SUELTA 					and unidad["estado"] == _ESTADO_GUARDADA and usos_propios == 0:
				continue
			alguna_disponible = true
			alguna_usada = alguna_usada or usos_propios > 0
		if alguna_disponible:
			disponible += 1
			if alguna_usada:
				usada += 1
	return _proporcion(usada, disponible, parametros["umbral_pct"], COMPARACION_MENOR_QUE)


# Metrica 6: acobardadas y tiradas del bando sumadas en todas las partidas; n =
# partidas con alguna tirada. valor = % de acobardadas, o null sin tiradas.
static func _tasa_acobardadas(partidas: Array, bando: String) -> Dictionary:
	var acobardadas: int = 0
	var tiradas: int = 0
	var n: int = 0
	for partida in partidas:
		var del_bando: Dictionary = _metricas(partida)["cobardia"][bando]
		var de_esta: int = (del_bando["acobardada"] as int) + (del_bando["resistida"] as int)
		if de_esta == 0:
			continue
		n += 1
		acobardadas += del_bando["acobardada"] as int
		tiradas += de_esta
	var valor: Variant = null
	if tiradas > 0:
		@warning_ignore("integer_division")
		valor = acobardadas * _CIEN / tiradas
	return {"acobardadas": acobardadas, "tiradas": tiradas, "n": n, "valor": valor}


# 11.9, toggle de afines (10.6): aprobado si en el escenario comparado (sin el
# toggle) se supera supera_pct y en el propio (con el toggle) la tasa queda
# entre desde_pct y hasta_pct, los bordes incluidos. Informativo.
static func _toggle_afines(entrada: Dictionary, parametros: Dictionary, propias: Array, comparadas: Array,
		suficiente: bool) -> Dictionary:
	var con: Dictionary = _tasa_acobardadas(propias, parametros["bando"])
	var sin: Dictionary = _tasa_acobardadas(comparadas, parametros["bando"])
	var supera: int = parametros["supera_pct"]
	var desde: int = parametros["desde_pct"]
	var hasta: int = parametros["hasta_pct"]
	var resultado: String = ESTADO_INSUFICIENTE
	if suficiente and (con["n"] as int) > 0 and (sin["n"] as int) > 0:
		var con_acobardadas: int = (con["acobardadas"] as int) * _CIEN
		var con_tiradas: int = con["tiradas"]
		var aprobado: bool = (sin["acobardadas"] as int) * _CIEN > supera * (sin["tiradas"] as int) 				and con_acobardadas >= desde * con_tiradas and con_acobardadas <= hasta * con_tiradas
		resultado = RESULTADO_APROBADO if aprobado else RESULTADO_NO_APROBADO
	entrada["valor"] = {"escenario": con["valor"], "comparado_con": sin["valor"]}
	entrada["umbral"] = {"supera": supera, "desde": desde, "hasta": hasta}
	entrada["resultado"] = resultado
	return entrada


# 11.9, H contra C: victorias del escenario (en %) menos las del comparado, en
# puntos; salta por encima del umbral. Exacto en enteros con el producto
# cruzado; valor, truncado hacia 0 (puede ser negativo).
static func _victorias_diferencia(entrada: Dictionary, parametros: Dictionary, propias: Array, comparadas: Array,
		suficiente: bool) -> Dictionary:
	var n: int = propias.size()
	var n_comparado: int = comparadas.size()
	var umbral: int = parametros["umbral_puntos"]
	var valor: Variant = null
	var salta: bool = false
	if n > 0 and n_comparado > 0:
		var diferencia: int = _victorias(propias) * _CIEN * n_comparado - _victorias(comparadas) * _CIEN * n
		@warning_ignore("integer_division")
		valor = diferencia / (n * n_comparado)
		salta = diferencia > umbral * n * n_comparado
	var estado: String = ESTADO_INSUFICIENTE
	if suficiente and valor != null:
		estado = ESTADO_ALARMA if salta else ESTADO_OK
	entrada["valor"] = valor
	entrada["umbral"] = umbral
	entrada["estado"] = estado
	return entrada


static func _victorias(partidas: Array) -> int:
	var victorias: int = 0
	for partida in partidas:
		if _resultado(partida)["desenlace"] == _VICTORIA:
			victorias += 1
	return victorias


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


# La variante sin la semilla. null (desconocida: un resultado sin ficha, T33
# sesion 3) sigue null: es su propio grupo y nunca el "sin cambios".
static func _sin_semilla(variante: Variant) -> Variant:
	if variante == null:
		return null
	var copia: Dictionary = (variante as Dictionary).duplicate(true)
	copia.erase(_RUTA_SEMILLA)
	return copia


# El estado al empezar de una criatura de la tribu: el de la variante si lo
# cambia, si no el del archivo del escenario (null si no esta en el archivo).
# Con la variante desconocida (null) tampoco se sabe: null.
static func _estado_inicial(id: String, variante: Variant, archivo: Dictionary) -> Variant:
	if variante == null:
		return null
	var del_archivo: Variant = null
	for criatura in (archivo["tribu"] as Array):
		if criatura["id"] == id:
			del_archivo = criatura["estado"]
	return (variante as Dictionary).get(_RUTA_ESTADO_TRIBU % [id], del_archivo)


# El efecto del rasgo de la ficha en especies/, o "" si no tiene rasgo.
static func _efecto_de(especie: String, datos: Dictionary) -> String:
	var ficha: Dictionary = datos.get("especies/%s.json" % [especie], {})
	if not ficha.has("rasgo"):
		return ""
	return (ficha["rasgo"] as Dictionary)["efecto"]


# Los ids de resultado.unidades del bando (tribu o enemiga; "" = cualquiera)
# cuya ficha tiene el efecto ("" = cualquiera).
static func _unidades(partida: Dictionary, bando: String, efecto: String, datos: Dictionary) -> Array[String]:
	var ids: Array[String] = []
	for unidad in (_resultado(partida)["unidades"] as Array):
		if not bando.is_empty() and unidad["bando"] != bando:
			continue
		if not efecto.is_empty() and _efecto_de(unidad["especie"], datos) != efecto:
			continue
		ids.append(unidad["id"])
	return ids


static func _cayo(partida: Dictionary, id: String) -> bool:
	for caida in (_metricas(partida)["caidas"] as Array):
		if caida["unidad"] == id:
			return true
	return false


static func _resultado(partida: Dictionary) -> Dictionary:
	return partida["resultado"]


static func _metricas(partida: Dictionary) -> Dictionary:
	return _resultado(partida)["metricas"]


static func _rondas_de_pelea(partida: Dictionary) -> int:
	return (_metricas(partida)["rondas"] as Dictionary)["de_pelea"]
