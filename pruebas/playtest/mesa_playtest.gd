# T33 (D-015): arma partidas de playtest a mano (resultado + ficha) para los
# tests de AlarmasPlaytest, con datos de prueba propios: el fixture de alarmas
# con los numeros de Sistema.md 11.9 y la copia del escenario C. Cada partida
# valida contra los esquemas resultado y playtest (errores()). No es una suite.
class_name MesaPlaytest
extends RefCounted

const _CARPETA_ESQUEMAS: String = "res://datos"
const _FIXTURE_ALARMAS: String = "res://pruebas/fixtures/playtest/alarmas.json"
const _FIXTURE_C: String = "res://pruebas/fixtures/combate/escenario_c.json"
const _CARPETA_UNIDADES: String = "res://pruebas/fixtures/unidades/"
# T33, sesion 2: escenario -> fixture. Los que no tienen fixture van con la
# tribu vacia (la alarma de "todos" los nombra; ningun test mira su tribu).
const _ESCENARIOS: Dictionary = {
	"a_dia_1": _CARPETA_UNIDADES + "escenario_a.json",
	"b_muro": _CARPETA_UNIDADES + "escenario_b.json",
	"c_tasajero": _FIXTURE_C,
	"d_rivales_normal": "",
	"d_rivales_hambriento": "",
	"e_cobardia": _CARPETA_UNIDADES + "escenario_e.json",
	"e_cobardia_afines": _CARPETA_UNIDADES + "escenario_e.json",
	"f_rescate": "",
	"g_ataque_nocturno": _CARPETA_UNIDADES + "escenario_g.json",
	"h_soplo": "",
}
const _ESPECIES: Array[String] = ["ocarra", "rodauva", "surcon", "tasajero", "zancajunco"]
# Otro id con el efecto ocultarse (T40): el calculo mira el efecto, nunca el id.
const _FIXTURE_ESPECIE_PRUEBA: String = "res://pruebas/fixtures/pantalla/especie_prueba.json"


# Los datos que lee AlarmasPlaytest, como los entrega el Cargador.
static func datos() -> Dictionary:
	var datos_armados: Dictionary = {
		AlarmasPlaytest.ARCHIVO: LectorFixture.leer(_FIXTURE_ALARMAS, "alarmas")["datos"],
	}
	for id in _ESCENARIOS.keys():
		var escenario: Dictionary = {"id": id, "tribu": [], "enemigas": []}
		if not (_ESCENARIOS[id] as String).is_empty():
			escenario = (LectorFixture.leer(_ESCENARIOS[id], "escenario")["datos"] as Dictionary).duplicate(true)
			escenario["id"] = id
		datos_armados["escenarios/%s.json" % [id]] = escenario
	for id in _ESPECIES:
		datos_armados["especies/%s.json" % [id]] = LectorFixture.leer(_CARPETA_UNIDADES + id + ".json", "especie")["datos"]
	datos_armados["especies/especie_prueba.json"] = LectorFixture.leer(_FIXTURE_ESPECIE_PRUEBA, "especie")["datos"]
	return datos_armados


static func semillas() -> Array:
	return (datos()[AlarmasPlaytest.ARCHIVO] as Dictionary)["semillas"]


# Una partida terminada en victoria, sin nada que medir: metricas en cero.
static func partida(escenario: String, jugador: Variant, semilla: int, variante: Dictionary = {}) -> Dictionary:
	var indice: Variant = null
	var lista: Array = semillas()
	if lista.has(semilla):
		indice = lista.find(semilla) + 1
	var resultado: Dictionary = {
		"contexto_id": escenario, "semilla": semilla, "desenlace": "victoria", "rondas": 0,
		"maestro_caido": false, "rescatista": null, "permadeath": false,
		"maestro": {"vida": 10, "posicion": [0, 0], "mana": 0, "hambre": 3},
		"unidades": [], "levantadas": [], "muertas": [], "capturas": [], "lealtad_cambios": [],
		"pergaminos": {"en_blanco": 0, "ardidos": []},
		"atacante_pendiente": null, "destino_atacante": null,
		"metricas": {
			"rondas": {"totales": 0, "primer_ataque": null, "de_pelea": 0},
			"secundar": {"usos": 0},
			"eslabones": {"cadenas": 0, "suma": 0, "maximo": 0},
			"incidentes": {"tribu": {"distraida": 0, "golpe": 0}, "enemigas": {"distraida": 0, "golpe": 0}},
			"encono": {"tribu": 0, "enemigas": 0},
			"cobardia": {"tribu": {"acobardada": 0, "resistida": 0}, "enemigas": {"acobardada": 0, "resistida": 0}},
			"sellados": [], "capturas_perdidas": [], "caidas": [], "caidas_guardadas": [], "muertes": [],
			"rescate": null, "distancia_maestro": {"turnos": 0, "suma": 0},
			"activas": {"usos": [], "surcos": 0, "ocultos": 0, "destapes_contacto": 0, "bonos_cobrados": 0,
					"bonos_perdidos": 0, "cambios_modo": [], "encierros": [], "invocaciones": {}},
		},
	}
	var ficha: Dictionary = {"escenario": escenario, "variante": variante.duplicate(true), "semilla": semilla,
			"indice_semilla": indice, "jugador": jugador}
	return {"resultado": resultado, "ficha": ficha}


# n partidas con las semillas de la lista, en orden, y jugadores j1..jk en ronda.
static func lote(escenario: String, n: int, jugadores: int = 3, variante: Dictionary = {}) -> Array[Dictionary]:
	var lista: Array = semillas()
	var partidas: Array[Dictionary] = []
	for i in range(n):
		partidas.append(partida(escenario, "j%d" % [i % jugadores + 1], lista[i % lista.size()], variante))
	return partidas


static func metricas(partida_armada: Dictionary) -> Dictionary:
	return (partida_armada["resultado"] as Dictionary)["metricas"]


# Los errores de la partida contra los esquemas resultado y playtest.
static func errores(partida_armada: Dictionary) -> Array[Dictionary]:
	var cargador: Cargador = Cargador.new()
	var lista: Array[Dictionary] = []
	for par in [["resultado", "resultado"], ["ficha", "playtest"]]:
		var esquema: Dictionary = cargador.esquema_resuelto(_CARPETA_ESQUEMAS, par[1])["esquema"]
		var validacion: Dictionary = Validador.new().validar(partida_armada[par[0]], esquema, par[1])
		for error in (validacion["errores"] as Array):
			lista.append(error)
	return lista


# AlarmasPlaytest.calcular sobre las partidas, con los datos de prueba.
static func calcular(partidas: Array[Dictionary]) -> Dictionary:
	var resultados: Array[Dictionary] = []
	var fichas: Array[Dictionary] = []
	for partida_armada in partidas:
		resultados.append(partida_armada["resultado"])
		fichas.append(partida_armada["ficha"])
	return AlarmasPlaytest.calcular(resultados, fichas, datos())


# El grupo de ese escenario y variante, o {}.
static func grupo(informe: Dictionary, escenario: String, variante: Dictionary = {}) -> Dictionary:
	for candidato in (informe["grupos"] as Array):
		if candidato["escenario"] == escenario and candidato["variante"] == variante:
			return candidato
	return {}


# La alarma de ese id en el grupo, o {}.
static func alarma(informe: Dictionary, escenario: String, id: String, variante: Dictionary = {}) -> Dictionary:
	for candidata in (grupo(informe, escenario, variante).get("alarmas", []) as Array):
		if candidata["id"] == id:
			return candidata
	return {}


# T33, sesion 2: una fila de resultado.unidades (bando "tribu" o "enemiga").
static func unidad(id: String, especie: String, bando: String, estado: String = "suelta") -> Dictionary:
	var de_la_tribu: bool = bando == "tribu"
	return {"id": id, "especie": especie, "bando": bando, "estado": estado, "vida": 10,
			"lealtad": 8 if de_la_tribu else null, "hambre": 3 if de_la_tribu else null,
			"posicion": null if estado == "guardada" else [0, 0]}


# La comparacion entre escenarios de ese id, o {}.
static func comparacion(informe: Dictionary, id: String) -> Dictionary:
	for candidata in (informe["comparaciones"] as Array):
		if candidata["id"] == id:
			return candidata
	return {}


# La alarma informativa de ese id, o {}.
static func informativa(informe: Dictionary, id: String) -> Dictionary:
	for candidata in (informe["informativas"] as Array):
		if candidata["id"] == id:
			return candidata
	return {}
