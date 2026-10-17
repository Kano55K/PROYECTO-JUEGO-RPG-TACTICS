# Arquitectura.md A.6 (T26): ayudante de los tests de guardar e invocar con
# fixtures. Arma el plantel de un escenario de fixtures (escenario_guardar.json
# por defecto; escenario_rival.json o escenario_incidente.json para la enconada,
# la acobardada y la distraida) con las posiciones que pide cada test, y turnos
# sueltos con los Surcos, la Cadena, las ReglasCombate y el generador de la mesa.
# No extiende GdUnitTestSuite: es un ayudante, no una suite.
class_name MesaGuardar
extends RefCounted

const _CARPETA: String = "res://pruebas/fixtures/combate/"
const _CARPETA_UNIDADES: String = "res://pruebas/fixtures/unidades/"
const _ESPECIES: Array[String] = ["ocarra", "rodauva", "surcon", "tasajero", "zancajunco"]

var tablero: Tablero
var surcos: Surcos = Surcos.new()
var cadena: Cadena = DatosFixture.cadena()
var reglas: ReglasCombate
var azar: GeneradorAzar = GeneradorAzar.new(1)
var plantel: Plantel


# ubicar: {id: casilla} para acomodar a las que usa el test. reglas_mesa: otras
# ReglasCombate (DatosFixture.reglas con reemplazos), o null para las de siempre.
func _init(ubicar: Dictionary = {}, escenario_archivo: String = "escenario_guardar.json",
		reglas_mesa: ReglasCombate = null) -> void:
	var tabla_combate: Dictionary = LectorFixture.leer(_CARPETA + "combate.json", "combate")["datos"]
	var escenario: Dictionary = LectorFixture.leer(_CARPETA + escenario_archivo, "escenario")["datos"]
	tablero = Tablero.desde_datos(escenario["tablero"], tabla_combate)
	reglas = reglas_mesa if reglas_mesa != null else DatosFixture.reglas()
	var especies: Dictionary = {}
	for id_especie in _ESPECIES:
		especies[id_especie] = Especie.new(LectorFixture.leer(_CARPETA_UNIDADES + id_especie + ".json",
				"especie")["datos"])
	var tabla: TablaBalanza = TablaBalanza.new(LectorFixture.leer(_CARPETA_UNIDADES + "balanza_1_2.json",
			"balanza")["datos"])
	plantel = Plantel.desde_escenario(escenario, especies, tabla,
			LectorFixture.leer(_CARPETA_UNIDADES + "maestro.json", "maestro")["datos"])
	for id_unidad in ubicar.keys():
		if id_unidad == Maestro.ID:
			plantel.maestro.posicion = ubicar[id_unidad]
		else:
			plantel.criatura(id_unidad).posicion = ubicar[id_unidad]


# El turno de la unidad, con el inicio del turno ya corrido. cola: la de la mesa
# (una vacia si no se pasa).
func turno(unidad_id: String = Maestro.ID, cola: ColaIniciativa = null) -> Turno:
	return Turno.empezar(EntradaCola.new(unidad_id, "", 0), plantel, tablero, surcos, cadena,
			cola if cola != null else ColaIniciativa.new(), reglas, azar)


# Todo lo que una accion invalida o una consulta no pueden cambiar: el Plantel
# (con el mana y los pergaminos), los surcos, la cadena, el generador y el turno.
func foto(de_turno: Turno) -> String:
	return JSON.stringify([plantel.instantanea(), surcos.instantanea(), cadena.instantanea(), azar.historial(),
			de_turno.movimiento_usado, de_turno.accion_usada, de_turno.pasos_restantes, de_turno.ataques_restantes,
			de_turno.terminado])


static func motivo(resultado: ResultadoAccion) -> String:
	return ResultadoAccion.Motivo.keys()[resultado.motivo]
