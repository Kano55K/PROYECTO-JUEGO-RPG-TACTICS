# Arquitectura.md A.6: los datos de prueba con las mismas claves que entrega
# Cargador.cargar_carpeta()["datos"], para que ContextoCombate reciba fixtures
# por el mismo camino que datos/. Cada archivo se valida con su esquema real.
# No extiende GdUnitTestSuite: es un ayudante, no una suite.
class_name DatosFixture
extends RefCounted

const _CARPETA_COMBATE: String = "res://pruebas/fixtures/combate/"
const _CARPETA_UNIDADES: String = "res://pruebas/fixtures/unidades/"
const _ESPECIES: Array[String] = ["ocarra", "rodauva", "surcon", "tasajero", "zancajunco"]


# Devuelve {"errores": Array[Dictionary], "datos": Dictionary}. combate: el
# fixture de tablas/combate.json (T18: con el incidente en 100 o en 0).
static func cargar(combate: String = "combate.json") -> Dictionary:
	var errores: Array[Dictionary] = []
	var datos: Dictionary = {}
	var archivos: Dictionary = {
		"tablas/combate.json": [_CARPETA_COMBATE + combate, "combate"],
		"tablas/hambre.json": [_CARPETA_COMBATE + "hambre.json", "hambre"],
		"tablas/arrimo.json": [_CARPETA_COMBATE + "arrimo.json", "arrimo"],
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


# La Afinidad de los fixtures (T15), armada como en ContextoCombate, para los
# tests que crean un Turno suelto. relaciones: otro fixture de relaciones.json
# ya leido, o {} para el de siempre.
static func afinidad(relaciones: Dictionary = {}) -> Afinidad:
	var datos: Dictionary = cargar()["datos"]
	var tabla_combate: Dictionary = datos["tablas/combate.json"]
	var obediencia: Obediencia = Obediencia.desde_datos(datos["tablas/hambre.json"], datos["tablas/lealtad.json"],
			tabla_combate)
	return Afinidad.desde_datos(tabla_combate,
			Relaciones.new(datos["relaciones.json"] if relaciones.is_empty() else relaciones), obediencia)


# Una Cadena nueva (T16) con el Combo de los fixtures, armada como en
# ContextoCombate y Combate, para los tests que crean un Turno suelto: como
# Surcos.new(), un turno suelto no encadena con nada anterior. relaciones: otro
# fixture de relaciones.json ya leido, o {} para el de siempre.
static func cadena(relaciones: Dictionary = {}) -> Cadena:
	return Cadena.new(combo(relaciones))


# El Incidente de los fixtures (T18), armado como en ContextoCombate, para los
# tests que crean un Turno suelto. combate: el fixture de tablas/combate.json.
static func incidente(combate: String = "combate.json") -> Incidente:
	var datos: Dictionary = cargar(combate)["datos"]
	var tabla_combate: Dictionary = datos["tablas/combate.json"]
	var obediencia: Obediencia = Obediencia.desde_datos(datos["tablas/hambre.json"], datos["tablas/lealtad.json"],
			tabla_combate)
	return Incidente.desde_datos(tabla_combate, Arrimo.desde_datos(datos["tablas/arrimo.json"]),
			Relaciones.new(datos["relaciones.json"]), obediencia)


# El ChequeoRival de los fixtures (T19), armado como en ContextoCombate, para los
# tests que crean un Turno suelto. combate: el fixture de tablas/combate.json.
# toggle: afines_contra_cobardia del escenario. relaciones: otro fixture de
# relaciones.json ya leido, o {} para el de siempre.
static func chequeo_rival(combate: String = "combate.json", toggle: bool = false,
		relaciones: Dictionary = {}) -> ChequeoRival:
	var datos: Dictionary = cargar(combate)["datos"]
	var tabla_combate: Dictionary = datos["tablas/combate.json"]
	var obediencia: Obediencia = Obediencia.desde_datos(datos["tablas/hambre.json"], datos["tablas/lealtad.json"],
			tabla_combate)
	var tabla_relaciones: Relaciones = Relaciones.new(datos["relaciones.json"] if relaciones.is_empty() else relaciones)
	return ChequeoRival.desde_datos(tabla_combate, Arrimo.desde_datos(datos["tablas/arrimo.json"]), tabla_relaciones,
			obediencia, Afinidad.desde_datos(tabla_combate, tabla_relaciones, obediencia), toggle)


# La RegeneracionMana de los fixtures (T21), armada como en ContextoCombate,
# para los tests que crean un Turno suelto.
static func regeneracion_mana() -> RegeneracionMana:
	return RegeneracionMana.desde_datos(cargar()["datos"]["tablas/hambre.json"])


# El Combo de los fixtures (T16), armado como en ContextoCombate.
static func combo(relaciones: Dictionary = {}) -> Combo:
	var datos: Dictionary = cargar()["datos"]
	return Combo.desde_datos(datos["tablas/combate.json"], Arrimo.desde_datos(datos["tablas/arrimo.json"]),
			afinidad(relaciones))
