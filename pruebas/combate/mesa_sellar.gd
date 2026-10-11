# Arquitectura.md A.6 (T24): ayudante de los tests de sellar con fixtures. Arma
# el plantel de escenario_sellar.json (con las dos especies inventadas de T24)
# con las posiciones que pide cada test, y turnos sueltos con los Surcos, la
# Cadena, las ReglasCombate y el generador que se le pasen.
# No extiende GdUnitTestSuite: es un ayudante, no una suite.
class_name MesaSellar
extends RefCounted

const _CARPETA: String = "res://pruebas/fixtures/combate/"
const _CARPETA_UNIDADES: String = "res://pruebas/fixtures/unidades/"
const _ESPECIES: Array[String] = ["ocarra", "rodauva", "surcon", "tasajero", "zancajunco"]
const _ESPECIES_T24: Array[String] = ["especie_sellar_r2", "especie_no_sellable"]

var tablero: Tablero
var surcos: Surcos = Surcos.new()
var cadena: Cadena = DatosFixture.cadena()
var reglas: ReglasCombate = DatosFixture.reglas()
var plantel: Plantel


# ubicar: {id: casilla} para acomodar a las que usa el test. balanza: otra
# posicion de la balanza del Maestro (0: la del escenario, 2).
func _init(ubicar: Dictionary = {}, balanza: int = 0) -> void:
	var tabla_combate: Dictionary = LectorFixture.leer(_CARPETA + "combate.json", "combate")["datos"]
	var escenario: Dictionary = LectorFixture.leer(_CARPETA + "escenario_sellar.json", "escenario")["datos"]
	if balanza > 0:
		escenario["maestro"]["balanza"] = balanza
	tablero = Tablero.desde_datos(escenario["tablero"], tabla_combate)
	var tabla: TablaBalanza = TablaBalanza.new(LectorFixture.leer(_CARPETA_UNIDADES + "balanza_1_2.json",
			"balanza")["datos"])
	plantel = Plantel.desde_escenario(escenario, especies(), tabla,
			LectorFixture.leer(_CARPETA_UNIDADES + "maestro.json", "maestro")["datos"])
	for id_unidad in ubicar.keys():
		if id_unidad == Maestro.ID:
			plantel.maestro.posicion = ubicar[id_unidad]
		else:
			plantel.criatura(id_unidad).posicion = ubicar[id_unidad]


# Las especies de la fixture mas las dos inventadas de T24: id -> Especie.
static func especies() -> Dictionary:
	var resultado: Dictionary = {}
	for id_especie in _ESPECIES:
		resultado[id_especie] = Especie.new(LectorFixture.leer(_CARPETA_UNIDADES + id_especie + ".json",
				"especie")["datos"])
	for id_especie in _ESPECIES_T24:
		resultado[id_especie] = Especie.new(LectorFixture.leer(_CARPETA + id_especie + ".json", "especie")["datos"])
	return resultado


# Las fichas de las dos especies inventadas, para sumarlas a los datos de un
# ContextoCombate (claves como las del Cargador).
static func fichas_t24() -> Dictionary:
	var resultado: Dictionary = {}
	for id_especie in _ESPECIES_T24:
		resultado["especies/%s.json" % id_especie] = LectorFixture.leer(_CARPETA + id_especie + ".json",
				"especie")["datos"]
	return resultado


# El turno de la unidad, con el inicio del turno ya corrido. azar: el generador
# de combate del turno (la tirada del sellado sale de ahi).
func turno(unidad_id: String = Maestro.ID, azar: GeneradorAzar = null) -> Turno:
	return Turno.empezar(EntradaCola.new(unidad_id, "", 0), plantel, tablero, surcos, cadena, ColaIniciativa.new(),
			reglas, azar if azar != null else GeneradorAzar.new(1))


# Todo lo que una accion invalida no puede cambiar: el Plantel (con el mana y los
# pergaminos), los surcos, la cadena y el turno.
func foto(de_turno: Turno) -> String:
	return JSON.stringify([plantel.instantanea(), surcos.instantanea(), cadena.instantanea(),
			de_turno.movimiento_usado, de_turno.accion_usada, de_turno.pasos_restantes, de_turno.ataques_restantes])
