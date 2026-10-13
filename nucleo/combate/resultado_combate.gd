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
# Sistema.md 6 (T29): el id de la rescatista ("" si no hubo) y si fue permadeath.
var rescatista: String = ""
var permadeath: bool = false
# ids en el orden de la tribu.
var levantadas: Array[String] = []
var muertas: Array[String] = []
var lealtad: Array[CambioLealtad] = []
# ids de los pergaminos que ardieron en este combate.
var pergaminos_ardidos: Array[String] = []
var pergaminos_en_blanco: int = 0
const DESTINO_SE_FUE: String = "se_fue"

# id de la atacante nocturna caida tras una victoria, que espera su destino
# (Sistema.md 9.3), o "".
var atacante_pendiente: String = ""
# Sistema.md 9.2 y 9.3 (T30): {opcion, resultado} o {} (null en el diccionario).
# Con la derrota o la huida (P-024, S-66), {opcion: null, resultado: se_fue}. Con
# la victoria, lo pone el Combate cuando el destino se decide (perdonada, sellada
# o comida); mientras espera, {} y atacante_pendiente.
var destino_atacante: Dictionary = {}
# Sistema.md 11.9 (T23, D-011): MetricasCombate.calcular sobre el registro
# completo. La llena el Combate despues del evento `cierre`.
var metricas: Dictionary = {}
# Sistema.md 4.1 y 4.2 (T24): las salvajes selladas en este combate, en el orden de
# sus pergaminos: {unidad, especie, pergamino, lealtad} (lealtad inicial del
# camino de combate). Salen guardadas: el Cierre no les da el +1 (5.2).
var capturas: Array = []
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
	resultado.rescatista = cierre.rescatista
	resultado.permadeath = cierre.permadeath
	resultado.levantadas = cierre.levantadas.duplicate()
	resultado.muertas = cierre.muertas.duplicate()
	resultado.lealtad = cierre.lealtad.duplicate()
	resultado.pergaminos_ardidos = ardidos.duplicate()
	for pergamino in plantel.pergaminos():
		if pergamino.estado == Pergamino.Estado.EN_BLANCO:
			resultado.pergaminos_en_blanco += 1
		# Un pergamino ocupado por una salvaje es una captura de este combate (T24).
		elif pergamino.estado == Pergamino.Estado.OCUPADO:
			var ocupante: Criatura = plantel.criatura(pergamino.ocupante_id)
			if ocupante != null and ocupante.comportamiento == Criatura.Comportamiento.SALVAJE:
				resultado.capturas.append({"unidad": ocupante.id, "especie": ocupante.especie.id(),
						"pergamino": pergamino.id, "lealtad": contexto.sellado.lealtad_inicial(plantel.maestro)})
	# Sistema.md 9.3 y P-024 (T30): solo con la victoria la atacante caida espera su
	# destino; con la derrota o la huida se fue (el Cierre ya la saco). Despues del
	# destino ya no esta caida (o lo sigue, si fallo el sellado: sigue esperando).
	if cierre.fin == FinCombate.Fin.VICTORIA:
		var atacante: Criatura = Cierre.atacante_caida(plantel)
		if atacante != null:
			resultado.atacante_pendiente = atacante.id
	if not cierre.se_fueron.is_empty():
		resultado.destino_atacante = {"opcion": null, "resultado": DESTINO_SE_FUE}
	resultado._maestro = {
		"vida": plantel.maestro.vida,
		"posicion": Plantel.casilla_a_lista(plantel.maestro.posicion),
		# Sistema.md 2.1 (T21): el mana actual al terminar.
		"mana": plantel.maestro.mana,
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
			# Arquitectura.md A.7 (T14): con el hambre de combate (Sistema.md 7.2).
			"hambre": criatura.hambre if es_tribu else null,
			"posicion": Plantel.casilla_a_lista(criatura.posicion),
		})
	return resultado


# Arquitectura.md A.7. rescatista y permadeath, desde T29 (Sistema.md 6).
# capturas: las de T24 (el resellado de T30 no es una captura: vuelve de la tribu, 4.4).
func a_diccionario() -> Dictionary:
	return {
		"contexto_id": contexto_id,
		"semilla": semilla,
		"desenlace": (FinCombate.Fin.keys()[desenlace] as String).to_lower(),
		"rondas": rondas,
		"maestro_caido": maestro_caido,
		"rescatista": null if rescatista.is_empty() else rescatista,
		"permadeath": permadeath,
		"maestro": _maestro.duplicate(true),
		"unidades": _unidades.duplicate(true),
		"levantadas": levantadas.duplicate(),
		"muertas": muertas.duplicate(),
		"capturas": capturas.duplicate(true),
		"lealtad_cambios": cambios_a_lista(lealtad),
		"pergaminos": {"en_blanco": pergaminos_en_blanco, "ardidos": pergaminos_ardidos.duplicate()},
		"atacante_pendiente": null if atacante_pendiente.is_empty() else atacante_pendiente,
		"destino_atacante": null if destino_atacante.is_empty() else destino_atacante.duplicate(),
		"metricas": metricas.duplicate(true),
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
