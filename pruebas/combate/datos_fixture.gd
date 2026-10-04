# Arquitectura.md A.6: los datos de prueba con las mismas claves que entrega
# Cargador.cargar_carpeta()["datos"], para que ContextoCombate reciba fixtures
# por el mismo camino que datos/. Cada archivo se valida con su esquema real.
# No extiende GdUnitTestSuite: es un ayudante, no una suite.
class_name DatosFixture
extends RefCounted

const _CARPETA_COMBATE: String = "res://pruebas/fixtures/combate/"
const _CARPETA_UNIDADES: String = "res://pruebas/fixtures/unidades/"
const _ESPECIES: Array[String] = ["ocarra", "rodauva", "surcon", "tasajero", "zancajunco"]


# Devuelve {"errores": Array[Dictionary], "datos": Dictionary}.
static func cargar() -> Dictionary:
	var errores: Array[Dictionary] = []
	var datos: Dictionary = {}
	var archivos: Dictionary = {
		"tablas/combate.json": [_CARPETA_COMBATE + "combate.json", "combate"],
		"tablas/hambre.json": [_CARPETA_COMBATE + "hambre.json", "hambre"],
		"tablas/lealtad.json": [_CARPETA_UNIDADES + "lealtad.json", "lealtad"],
		"tablas/balanza.json": [_CARPETA_UNIDADES + "balanza_1_2.json", "balanza"],
		"maestro.json": [_CARPETA_UNIDADES + "maestro.json", "maestro"],
		"relaciones.json": [_CARPETA_UNIDADES + "relaciones.json", "relaciones"],
	}
	for id_especie in _ESPECIES:
		archivos["especies/%s.json" % id_especie] = [_CARPETA_UNIDADES + id_especie + ".json", "especie"]
	for clave in archivos.keys():
		var lectura: Dictionary = LectorFixture.leer(archivos[clave][0], archivos[clave][1])
		errores.append_array(lectura["errores"])
		datos[clave] = lectura["datos"]
	return {"errores": errores, "datos": datos}
