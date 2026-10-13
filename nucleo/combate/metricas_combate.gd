# Sistema.md 11.9, "Metricas por combate", y D-011 (T23): las metricas salen solo
# del registro. Del escenario se toma solo de que bando es cada id (el Maestro y
# la tribu, o las enemigas); nunca se reconstruyen posiciones ni estados, y nunca
# se mira una especie: la activa sale del tipo de la accion. Sin estado. La
# salida tiene solo enteros, null, listas y diccionarios: un promedio va como
# suma y cantidad, asi dos reproducciones dan exactamente lo mismo.
class_name MetricasCombate
extends RefCounted

const BANDO_TRIBU: String = "tribu"
const BANDO_ENEMIGAS: String = "enemigas"
# Las activas de la metrica 14, por el tipo de su accion (Accion.a_diccionario).
const ACTIVAS: Array[String] = ["erizarse", "cavar", "hacerse_junco"]

# Valores del registro que se cuentan (A.7).
const _A_CAIDA: Array[String] = ["caida", "caido"]
const _ENCONADA: String = "enconada"
const _ACOBARDADA: String = "acobardada"
const _RESISTIDA: String = "resistida"
const _COBARDIA: String = "cobardia"
const _DISTRAIDA: String = "distraida"
const _GOLPE: String = "golpe"
const _CONTACTO: String = "contacto"
const _FUENTE_RASGO_ATACANTE: String = "rasgo_atacante"
const _FUERA: String = "fuera"
const _SALVAJE: String = "salvaje"
# Los motivos de la metrica 8 (T25).
const MOTIVO_HUIDA: String = "huida"
const MOTIVO_CERO: String = "cero"
const _MINIMO_ESLABONES: int = 2


# escenario: el diccionario del escenario jugado (el de la grabacion).
# lineas: el registro, en orden (RegistroCombate.lineas()).
static func calcular(escenario: Dictionary, lineas: Array[Dictionary]) -> Dictionary:
	var bandos: Dictionary = _bandos(escenario)
	var salvajes: Array[String] = _salvajes(escenario)
	var primer_ataque: Variant = null
	var totales: int = 0
	var secundar: int = 0
	var eslabones: Dictionary = {"cadenas": 0, "suma": 0, "maximo": 0}
	var incidentes: Dictionary = {BANDO_TRIBU: {_DISTRAIDA: 0, _GOLPE: 0}, BANDO_ENEMIGAS: {_DISTRAIDA: 0, _GOLPE: 0}}
	var encono: Dictionary = {BANDO_TRIBU: 0, BANDO_ENEMIGAS: 0}
	var cobardia: Dictionary = {BANDO_TRIBU: {_ACOBARDADA: 0, _RESISTIDA: 0},
			BANDO_ENEMIGAS: {_ACOBARDADA: 0, _RESISTIDA: 0}}
	var caidas: Array = []
	# 7 (T24): {objetivo, porcentaje, logrado} de cada evento sellado, en orden.
	var sellados: Array = []
	# 8 (T25): {unidad, motivo, ronda} de cada salvaje que sale del tablero sin
	# ser sellada. El motivo sale del evento que precede a su estado fuera (A.7):
	# las unidades con un huida que salio o un sellado logrado pendientes.
	var capturas_perdidas: Array = []
	# 10 (T27): {unidad, ronda} de cada evento guardado_caida, en orden.
	var caidas_guardadas: Array = []
	# 12 (T29): {rescatista} del evento rescate; null si el Maestro no cayo.
	var rescate: Variant = null
	var huyendo: Dictionary = {}
	var selladas: Dictionary = {}
	var muertas: Array = []
	var desenlace: Variant = null
	# [ronda, distancia] de cada distancia_maestro no nula: se filtran al final,
	# cuando ya se sabe la ronda del primer ataque.
	var distancias: Array = []
	var usos: Dictionary = {}
	var encierros: Dictionary = {}
	var activas: Dictionary = {"surcos": 0, "ocultos": 0, "destapes_contacto": 0, "bonos_cobrados": 0,
			"bonos_perdidos": 0, "cambios_modo": []}

	for linea in lineas:
		var ronda: int = linea["ronda"]
		match linea["tipo"]:
			"ronda":
				totales = ronda
			"ataque":
				if primer_ataque == null:
					primer_ataque = ronda
				if _tiene_rasgo_atacante(linea["desglose"]):
					activas["bonos_cobrados"] += 1
			"rescate":
				rescate = {"rescatista": linea["rescatista"]}
			"guardado_caida":
				caidas_guardadas.append({"unidad": linea["unidad"], "ronda": ronda})
			"secundar":
				secundar += 1
			"cadena_cortada":
				var cantidad: int = linea["eslabones"]
				if cantidad >= _MINIMO_ESLABONES:
					eslabones["cadenas"] += 1
					eslabones["suma"] += cantidad
					eslabones["maximo"] = maxi(eslabones["maximo"], cantidad)
			"incidente":
				var de_incidentes: Dictionary = incidentes[bandos[linea["unidad"]]]
				de_incidentes[linea["resultado"]] += 1
			"chequeo_rival":
				var bando: String = bandos[linea["unidad"]]
				if linea["resultado"] == _ENCONADA:
					encono[bando] += 1
				elif linea["tipo_chequeo"] == _COBARDIA:
					(cobardia[bando] as Dictionary)[linea["resultado"]] += 1
			"estado":
				if _A_CAIDA.has(linea["a"]):
					caidas.append({"unidad": linea["unidad"], "ronda": ronda})
				elif linea["a"] == _FUERA:
					var unidad_fuera: String = linea["unidad"]
					if huyendo.has(unidad_fuera):
						capturas_perdidas.append({"unidad": unidad_fuera, "motivo": MOTIVO_HUIDA, "ronda": ronda})
					elif not selladas.has(unidad_fuera) and salvajes.has(unidad_fuera):
						capturas_perdidas.append({"unidad": unidad_fuera, "motivo": MOTIVO_CERO, "ronda": ronda})
					huyendo.erase(unidad_fuera)
					selladas.erase(unidad_fuera)
			"huida":
				if linea["resultado"] == Huida.RESULTADO_HUYE:
					huyendo[linea["unidad"]] = true
			"fin":
				desenlace = linea["desenlace"]
			"cierre":
				muertas = linea["muertas"]
			"distancia_maestro":
				if linea["distancia"] != null:
					distancias.append([ronda, linea["distancia"]])
			"accion":
				var tipo_accion: String = linea["accion"]["tipo"]
				if ACTIVAS.has(tipo_accion):
					var de_la_unidad: Dictionary = usos.get(linea["unidad"], {})
					de_la_unidad[tipo_accion] = de_la_unidad.get(tipo_accion, 0) + 1
					usos[linea["unidad"]] = de_la_unidad
			"surco":
				activas["surcos"] += 1
			"oculto":
				activas["ocultos"] += 1
			"destape":
				if linea["motivo"] == _CONTACTO:
					activas["destapes_contacto"] += 1
			"bono_perdido":
				activas["bonos_perdidos"] += 1
			"cambio_modo":
				(activas["cambios_modo"] as Array).append({"unidad": linea["unidad"], "de": linea["de"],
						"a": linea["a"], "ronda": ronda})
			"encierro":
				encierros[linea["unidad"]] = encierros.get(linea["unidad"], 0) + 1
			"sellado":
				sellados.append({"objetivo": linea["objetivo"], "porcentaje": linea["porcentaje"],
						"logrado": linea["resultado"] == Sellado.RESULTADO_LOGRADO})
				if linea["resultado"] == Sellado.RESULTADO_LOGRADO:
					selladas[linea["objetivo"]] = true

	var distancia_maestro: Dictionary = {"turnos": 0, "suma": 0}
	if primer_ataque != null:
		for par in distancias:
			if (par[0] as int) >= (primer_ataque as int):
				distancia_maestro["turnos"] += 1
				distancia_maestro["suma"] += par[1]
	var muertes: Array = []
	for unidad_id in muertas:
		muertes.append({"unidad": unidad_id, "causa": desenlace})
	activas["usos"] = _usos_en_orden(bandos, usos)
	activas["encierros"] = _encierros_en_orden(bandos, encierros)

	return {
		# 1
		"rondas": {"totales": totales, "primer_ataque": primer_ataque,
				"de_pelea": 0 if primer_ataque == null else totales - (primer_ataque as int) + 1},
		# 2
		"secundar": {"usos": secundar},
		# 3
		"eslabones": eslabones,
		# 4, 5 y 6, por bando
		"incidentes": incidentes,
		"encono": encono,
		"cobardia": cobardia,
		# 7 (T24): sellados intentados y logrados, con el % mostrado
		"sellados": sellados,
		# 8 (T25): por huida en su turno o por llegar a 0; las selladas no cuentan
		"capturas_perdidas": capturas_perdidas,
		# 9 (P-043: tambien el Maestro)
		"caidas": caidas,
		# 10 (T27): las caidas que el Maestro guardo
		"caidas_guardadas": caidas_guardadas,
		# 11
		"muertes": muertes,
		# 12 (T29): quien rescato (o null si fue permadeath); null si no cayo
		"rescate": rescate,
		# 13, desde la ronda del primer ataque (11.9 v1.6)
		"distancia_maestro": distancia_maestro,
		# 14
		"activas": activas,
	}


# id -> bando, en el orden del escenario: el Maestro, la tribu y las enemigas.
static func _bandos(escenario: Dictionary) -> Dictionary:
	var bandos: Dictionary = {Maestro.ID: BANDO_TRIBU}
	for criatura in (escenario["tribu"] as Array):
		bandos[criatura["id"]] = BANDO_TRIBU
	for criatura in (escenario["enemigas"] as Array):
		bandos[criatura["id"]] = BANDO_ENEMIGAS
	return bandos


# Los ids de las enemigas salvajes del escenario (la atacante nocturna no es
# una captura: 9.3).
static func _salvajes(escenario: Dictionary) -> Array[String]:
	var ids: Array[String] = []
	for criatura in (escenario["enemigas"] as Array):
		if criatura["comportamiento"] == _SALVAJE:
			ids.append(criatura["id"])
	return ids


# Sistema.md 11.4 y 11.2.2: el bono de Hacerse junco es el unico modificador de
# fuente "rasgo de la atacante" (Danio._rasgo_atacante).
static func _tiene_rasgo_atacante(desglose: Dictionary) -> bool:
	for modificador in (desglose["modificadores"] as Array):
		if modificador["fuente"] == _FUENTE_RASGO_ATACANTE:
			return true
	return false


# Solo las unidades con algun uso, en el orden del escenario.
static func _usos_en_orden(bandos: Dictionary, usos: Dictionary) -> Array:
	var lista: Array = []
	for unidad_id in bandos.keys():
		if not usos.has(unidad_id):
			continue
		var fila: Dictionary = {"unidad": unidad_id}
		for activa in ACTIVAS:
			fila[activa] = (usos[unidad_id] as Dictionary).get(activa, 0)
		lista.append(fila)
	return lista


# Solo las unidades con algun encierro, en el orden del escenario.
static func _encierros_en_orden(bandos: Dictionary, encierros: Dictionary) -> Array:
	var lista: Array = []
	for unidad_id in bandos.keys():
		if encierros.has(unidad_id):
			lista.append({"unidad": unidad_id, "turnos": encierros[unidad_id]})
	return lista
