# Ayudante de los tests de T30 (sesion 2) con escenario_destino_combate.json: arma
# el Combate con la atacante en 0 en el escenario (asi la grabacion la lleva):
# queda caida, victoria sin rondas y su destino pendiente (Sistema.md 9.3).
class_name MesaDestino
extends RefCounted

const ARCHIVO: String = "res://pruebas/fixtures/combate/escenario_destino_combate.json"
const ATACANTE: String = "ocarra_1"
const LEAL: String = "rodauva_1"
const NEUTRAL: String = "rodauva_2"
const DE_DIEZ: String = "zancajunco_1"
const AFIN: String = "surcon_1"
const GUARDADA: String = "rodauva_g"
# Plantel: un pergamino por cada una de la tribu, despues el de la atacante y
# despues los en blanco (Plantel.desde_escenario).
const PERGAMINO_ATACANTE: String = "pergamino_6"
const PERGAMINO_EN_BLANCO: String = "pergamino_7"
# La semilla del fixture saca 54 (sale con 80); esta, 90 (falla).
const SEMILLA_FALLA: int = 26


# atacante_en_cero: false deja a la atacante con la vida de su ficha (combate en curso).
static func escenario(atacante_en_cero: bool = true) -> Dictionary:
	var datos: Dictionary = LectorFixture.leer(ARCHIVO, "escenario")["datos"]
	if atacante_en_cero:
		((datos["enemigas"] as Array)[0] as Dictionary)["vida"] = 0
	return datos


static func datos() -> Dictionary:
	return DatosFixture.cargar()["datos"]


# mana: el del Maestro puesto a mano antes de empezar (-1 = el de entrada).
# vida_maestro: la del Maestro puesta a mano (-1 = la de la ficha).
static func combate(escenario_combate: Dictionary = {}, mana: int = -1, datos_combate: Dictionary = {},
		vida_maestro: int = -1) -> Combate:
	var contexto: ContextoCombate = ContextoCombate.armar(escenario() if escenario_combate.is_empty() else escenario_combate,
			datos() if datos_combate.is_empty() else datos_combate)
	if mana >= 0:
		contexto.plantel.maestro.mana = mana
	if vida_maestro >= 0:
		contexto.plantel.maestro.vida = vida_maestro
	return Combate.empezar(contexto)


static func criatura(combate_jugado: Combate, id_criatura: String) -> Criatura:
	return combate_jugado.contexto().plantel.criatura(id_criatura)


static func pergamino(combate_jugado: Combate, id_pergamino: String) -> Pergamino:
	return combate_jugado.contexto().plantel.pergamino(id_pergamino)


# id -> lealtad de las cinco de la tribu.
static func lealtades(combate_jugado: Combate) -> Dictionary:
	var resultado: Dictionary = {}
	for id_criatura in [LEAL, NEUTRAL, DE_DIEZ, AFIN, GUARDADA]:
		resultado[id_criatura] = criatura(combate_jugado, id_criatura).lealtad
	return resultado


# Las lineas del registro desde la primera de ese tipo (incluida), sin n ni ronda.
static func lineas_desde(combate_jugado: Combate, tipo: String) -> Array[Dictionary]:
	var resultado: Array[Dictionary] = []
	var copiando: bool = false
	for linea in combate_jugado.registro().lineas():
		copiando = copiando or linea["tipo"] == tipo
		if copiando:
			var copia: Dictionary = linea.duplicate(true)
			copia.erase("n")
			copia.erase("ronda")
			resultado.append(copia)
	return resultado


static func tipos(lineas: Array[Dictionary]) -> Array:
	return lineas.map(func(linea: Dictionary) -> String: return linea["tipo"])


# {id: [motivos]} de lealtad_cambios del resultado.
static func motivos(combate_jugado: Combate) -> Dictionary:
	var resultado: Dictionary = {}
	for cambio in (combate_jugado.resultado().a_diccionario()["lealtad_cambios"] as Array):
		resultado[cambio["id"]] = (cambio["anotaciones"] as Array).map(func(a: Dictionary) -> String: return a["motivo"])
	return resultado
