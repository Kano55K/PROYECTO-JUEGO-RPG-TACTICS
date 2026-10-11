# Arquitectura.md A.6 (T22): ayudante de los tests de hechizos con fixtures. Arma
# el plantel de escenario_hechizos.json con las posiciones que pide cada test y
# turnos sueltos con los Surcos, la Cadena y las ReglasCombate que se le pasen.
# No extiende GdUnitTestSuite: es un ayudante, no una suite.
class_name MesaHechizos
extends RefCounted

const _CARPETA: String = "res://pruebas/fixtures/combate/"
const _CARPETA_UNIDADES: String = "res://pruebas/fixtures/unidades/"
const _ESPECIES: Array[String] = ["ocarra", "rodauva", "surcon", "tasajero", "zancajunco"]

var tablero: Tablero
var surcos: Surcos = Surcos.new()
var cadena: Cadena = DatosFixture.cadena()
var reglas: ReglasCombate = DatosFixture.reglas()
var plantel: Plantel


# ubicar: {id: casilla} para acomodar a las que usa el test.
func _init(ubicar: Dictionary = {}) -> void:
	var tabla_combate: Dictionary = LectorFixture.leer(_CARPETA + "combate.json", "combate")["datos"]
	tablero = Tablero.desde_datos({"ancho": 8, "alto": 8}, tabla_combate)
	var especies: Dictionary = {}
	for id_especie in _ESPECIES:
		especies[id_especie] = Especie.new(LectorFixture.leer(_CARPETA_UNIDADES + id_especie + ".json",
				"especie")["datos"])
	var tabla: TablaBalanza = TablaBalanza.new(LectorFixture.leer(_CARPETA_UNIDADES + "balanza_1_2.json",
			"balanza")["datos"])
	plantel = Plantel.desde_escenario(LectorFixture.leer(_CARPETA + "escenario_hechizos.json", "escenario")["datos"],
			especies, tabla, LectorFixture.leer(_CARPETA_UNIDADES + "maestro.json", "maestro")["datos"])
	for id_unidad in ubicar.keys():
		if id_unidad == Maestro.ID:
			plantel.maestro.posicion = ubicar[id_unidad]
		else:
			plantel.criatura(id_unidad).posicion = ubicar[id_unidad]


# El turno de la unidad, con el inicio del turno ya corrido (el Maestro arranca
# con el mana en el tope: la regeneracion no cambia nada).
func turno(unidad_id: String = Maestro.ID) -> Turno:
	return Turno.empezar(EntradaCola.new(unidad_id, "", 0), plantel, tablero, surcos, cadena, ColaIniciativa.new(),
			reglas, GeneradorAzar.new(1))


# Todo lo que una accion invalida no puede cambiar: el Plantel (con el mana), los
# surcos, la cadena y el turno.
func foto(de_turno: Turno) -> String:
	return JSON.stringify([plantel.instantanea(), surcos.instantanea(), cadena.instantanea(),
			de_turno.movimiento_usado, de_turno.accion_usada, de_turno.pasos_restantes, de_turno.ataques_restantes])
