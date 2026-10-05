# Arquitectura.md A.7: la salida del combate, armada desde el Plantel y el
# ResultadoCierre (T10). El nucleo la calcula, la pantalla solo la muestra y en
# 0b el loop la aplica. Su diccionario valida contra resultado.schema.json.
class_name ResultadoCombate
extends RefCounted

const _BANDO_TRIBU: String = "tribu"
const _BANDO_ENEMIGA: String = "enemiga"

var contexto_id: String
var semilla: int
var desenlace: FinCombate.Fin
var rondas: int
var maestro_caido: bool
# ids en el orden de la tribu.
var levantadas: Array[String] = []
var muertas: Array[String] = []
var lealtad: Array[CambioLealtad] = []
# ids de los pergaminos que ardieron en este combate.
var pergaminos_ardidos: Array[String] = []
var pergaminos_en_blanco: int = 0
# id de la atacante nocturna caida al terminar, o "" (su destino es de T30).
var atacante_pendiente: String = ""
# Estado final, en el orden del Plantel (diccionarios del esquema).
var _maestro: Dictionary = {}
var _unidades: Array = []


# Se arma una vez, con el combate ya cerrado. ardidos: los pergaminos que
# ardieron en este combate (Combate los conoce porque mira antes y despues).
static func armar(contexto: ContextoCombate, cierre: ResultadoCierre, rondas_jugadas: int, ardidos: Array[String]) -> ResultadoCombate:
	var plantel: Plantel = contexto.plantel
	var resultado: ResultadoCombate = ResultadoCombate.new()
	resultado.contexto_id = contexto.escenario_id
	resultado.semilla = contexto.semilla
	resultado.desenlace = cierre.fin
	resultado.rondas = rondas_jugadas
	resultado.maestro_caido = plantel.maestro.caido
	resultado.levantadas = cierre.levantadas.duplicate()
	resultado.muertas = cierre.muertas.duplicate()
	resultado.lealtad = cierre.lealtad.duplicate()
	resultado.pergaminos_ardidos = ardidos.duplicate()
	for pergamino in plantel.pergaminos():
		if pergamino.estado == Pergamino.Estado.EN_BLANCO:
			resultado.pergaminos_en_blanco += 1
	# Lectura literal de B.2 (T12): la atacante caida, sea cual sea el desenlace (P-024, S-20).
	for criatura in plantel.criaturas():
		if criatura.comportamiento == Criatura.Comportamiento.ATACANTE_NOCTURNA \
				and criatura.estado == Criatura.Estado.CAIDA:
			resultado.atacante_pendiente = criatura.id
			break
	resultado._maestro = {
		"vida": plantel.maestro.vida,
		"posicion": Plantel.casilla_a_lista(plantel.maestro.posicion),
		# Lo llena T21.
		"mana": null,
		"hambre": plantel.maestro.hambre,
	}
	for criatura in plantel.criaturas():
		var es_tribu: bool = criatura.bando == Criatura.Bando.TRIBU
		resultado._unidades.append({
			"id": criatura.id,
			"especie": criatura.especie.id(),
			"bando": _BANDO_TRIBU if es_tribu else _BANDO_ENEMIGA,
			"estado": Plantel.nombre_estado(criatura.estado),
			"vida": criatura.vida,
			"lealtad": criatura.lealtad if es_tribu else null,
			"posicion": Plantel.casilla_a_lista(criatura.posicion),
		})
	return resultado


# Arquitectura.md A.7. Los campos de tareas futuras van en null o lista vacia:
# rescatista y permadeath (T29), capturas (T24, T30), metricas (T23, T33).
func a_diccionario() -> Dictionary:
	return {
		"contexto_id": contexto_id,
		"semilla": semilla,
		"desenlace": (FinCombate.Fin.keys()[desenlace] as String).to_lower(),
		"rondas": rondas,
		"maestro_caido": maestro_caido,
		"rescatista": null,
		"permadeath": null,
		"maestro": _maestro.duplicate(true),
		"unidades": _unidades.duplicate(true),
		"levantadas": levantadas.duplicate(),
		"muertas": muertas.duplicate(),
		"capturas": [],
		"lealtad_cambios": cambios_a_lista(lealtad),
		"pergaminos": {"en_blanco": pergaminos_en_blanco, "ardidos": pergaminos_ardidos.duplicate()},
		"atacante_pendiente": null if atacante_pendiente.is_empty() else atacante_pendiente,
		"metricas": null,
	}


# Los cambios de lealtad como diccionarios: los usan el resultado y el evento
# `cierre` del registro.
static func cambios_a_lista(cambios: Array[CambioLealtad]) -> Array:
	var lista: Array = []
	for cambio in cambios:
		var anotaciones: Array = []
		for anotacion in cambio.anotaciones:
			anotaciones.append({"cambio": anotacion.cambio, "motivo": anotacion.motivo})
		lista.append({"id": cambio.criatura_id, "antes": cambio.antes,
				"cambio": cambio.cambio, "despues": cambio.despues, "anotaciones": anotaciones})
	return lista
