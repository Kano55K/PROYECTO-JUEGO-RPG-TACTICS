# Arquitectura.md A.6 (T25): ayudante de los tests de huida con fixtures. Arma
# el plantel de escenario_huida.json (con las dos especies inventadas de T25)
# con la vida y la casilla que pide cada test, y turnos sueltos con los Surcos,
# la Cadena, las ReglasCombate y el generador que se le pasen.
# No extiende GdUnitTestSuite: es un ayudante, no una suite.
class_name MesaHuida
extends RefCounted

const _CARPETA: String = "res://pruebas/fixtures/combate/"
const _CARPETA_UNIDADES: String = "res://pruebas/fixtures/unidades/"
const _ESPECIES: Array[String] = ["ocarra", "rodauva", "surcon", "tasajero", "zancajunco"]
const _ESPECIES_T25: Array[String] = ["especie_huida_100", "especie_huida_1"]

var tablero: Tablero
var surcos: Surcos = Surcos.new()
var cadena: Cadena = DatosFixture.cadena()
var reglas: ReglasCombate = DatosFixture.reglas()
var plantel: Plantel


# vidas: {id: vida} para herir a las que usa el test.
func _init(vidas: Dictionary = {}) -> void:
	var tabla_combate: Dictionary = LectorFixture.leer(_CARPETA + "combate.json", "combate")["datos"]
	var escenario: Dictionary = LectorFixture.leer(_CARPETA + "escenario_huida.json", "escenario")["datos"]
	tablero = Tablero.desde_datos(escenario["tablero"], tabla_combate)
	var tabla: TablaBalanza = TablaBalanza.new(LectorFixture.leer(_CARPETA_UNIDADES + "balanza_1_2.json",
			"balanza")["datos"])
	plantel = Plantel.desde_escenario(escenario, especies(), tabla,
			LectorFixture.leer(_CARPETA_UNIDADES + "maestro.json", "maestro")["datos"])
	for id_unidad in vidas.keys():
		if id_unidad == Maestro.ID:
			plantel.maestro.vida = vidas[id_unidad]
		else:
			plantel.criatura(id_unidad).vida = vidas[id_unidad]


# Las especies de la fixture mas las dos inventadas de T25: id -> Especie.
static func especies() -> Dictionary:
	var resultado: Dictionary = {}
	for id_especie in _ESPECIES:
		resultado[id_especie] = Especie.new(LectorFixture.leer(_CARPETA_UNIDADES + id_especie + ".json",
				"especie")["datos"])
	for id_especie in _ESPECIES_T25:
		resultado[id_especie] = Especie.new(LectorFixture.leer(_CARPETA + id_especie + ".json", "especie")["datos"])
	return resultado


# Las fichas de las dos especies inventadas, para sumarlas a los datos de un
# ContextoCombate (claves como las del Cargador).
static func fichas_t25() -> Dictionary:
	var resultado: Dictionary = {}
	for id_especie in _ESPECIES_T25:
		resultado["especies/%s.json" % id_especie] = LectorFixture.leer(_CARPETA + id_especie + ".json",
				"especie")["datos"]
	return resultado


# El turno de la unidad, con el inicio del turno ya corrido. azar: el generador
# de combate del turno (la tirada de huida sale de ahi). cola: la de la ronda
# (una vacia si no se pasa).
func turno(unidad_id: String, azar: GeneradorAzar = null, cola: ColaIniciativa = null) -> Turno:
	return Turno.empezar(EntradaCola.new(unidad_id, "", 0), plantel, tablero, surcos, cadena,
			cola if cola != null else ColaIniciativa.new(), reglas, azar if azar != null else GeneradorAzar.new(1))
