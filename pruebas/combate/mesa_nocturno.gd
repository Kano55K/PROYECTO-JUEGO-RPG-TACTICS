# Ayudante de los tests de T30 (sesion 1) con escenario_nocturno_combate.json:
# arma el Combate con los cambios en memoria que pide cada test.
class_name MesaNocturno
extends RefCounted

const CARPETA: String = "res://pruebas/fixtures/combate/"
const ARCHIVO: String = "escenario_nocturno_combate.json"
const CARPETA_DATOS: String = "res://datos"
const ATACANTE: String = "ocarra_1"
const AFIN: String = "surcon_s1"
const SUELTA: String = "rodauva_1"


static func escenario() -> Dictionary:
	return LectorFixture.leer(CARPETA + ARCHIVO, "escenario")["datos"]


# velocidad_maestro: la de maestro.json subida en memoria (0 = la del fixture).
static func datos(velocidad_maestro: int = 0) -> Dictionary:
	var datos_fixture: Dictionary = DatosFixture.cargar()["datos"]
	if velocidad_maestro > 0:
		datos_fixture["maestro.json"]["velocidad"] = velocidad_maestro
	return datos_fixture


# vidas: id -> vida puesta a mano antes de empezar (Maestro.ID para el Maestro).
static func combate(escenario_combate: Dictionary, vidas: Dictionary = {}, datos_combate: Dictionary = {}) -> Combate:
	var contexto: ContextoCombate = ContextoCombate.armar(escenario_combate,
			datos() if datos_combate.is_empty() else datos_combate)
	for unidad_id: String in vidas.keys():
		if unidad_id == Maestro.ID:
			contexto.plantel.maestro.vida = vidas[unidad_id]
		else:
			contexto.plantel.criatura(unidad_id).vida = vidas[unidad_id]
	return Combate.empezar(contexto)


static func lineas_de_tipo(combate_jugado: Combate, tipo: String) -> Array[Dictionary]:
	var resultado: Array[Dictionary] = []
	for linea in combate_jugado.registro().lineas():
		if linea["tipo"] == tipo:
			resultado.append(linea)
	return resultado


static func errores_esquema(valor: Variant, nombre_esquema: String) -> Array[Dictionary]:
	var esquema: Dictionary = Cargador.new().esquema_resuelto(CARPETA_DATOS, nombre_esquema)["esquema"]
	return Validador.new().validar(valor, esquema, nombre_esquema)["errores"]
