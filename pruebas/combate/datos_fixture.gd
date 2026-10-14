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
		"hechizos.json": [_CARPETA_COMBATE + "hechizos.json", "hechizos"],
		"tablas/sellado.json": [_CARPETA_COMBATE + "sellado.json", "sellado"],
		"tablas/costos_mana.json": [_CARPETA_COMBATE + "costos_mana.json", "costos_mana"],
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


# Los Hechizos de los fixtures (T22), armados como en ContextoCombate. archivo:
# otro fixture de hechizos.json en la carpeta de combate (hechizos_choque_4.json).
static func hechizos(archivo: String = "hechizos.json") -> Hechizos:
	var tabla: Dictionary = LectorFixture.leer(_CARPETA_COMBATE + archivo, "hechizos")["datos"]
	return Hechizos.desde_datos(tabla, cargar()["datos"]["maestro.json"])


# Las ReglasCombate de los fixtures (D-008), armadas como en ContextoCombate, para
# los tests que crean un Turno suelto. reemplazos: {nombre de ReglasCombate.REGLAS:
# regla} para cambiar alguna (por ejemplo, el chequeo de rival con
# combate_rival_100.json). Un nombre que no existe da null, nunca la de siempre.
static func reglas(reemplazos: Dictionary = {}) -> ReglasCombate:
	for nombre in reemplazos.keys():
		if not ReglasCombate.REGLAS.has(nombre):
			push_error("DatosFixture.reglas: no existe la regla " + str(nombre))
			return null
	var datos: Dictionary = cargar()["datos"]
	return ReglasCombate.new(
			reemplazos.get("danio", Danio.desde_datos(datos["tablas/combate.json"], datos["tablas/hambre.json"])),
			reemplazos.get("afinidad", afinidad()),
			reemplazos.get("combo", combo()),
			reemplazos.get("incidente", incidente()),
			reemplazos.get("chequeo_rival", chequeo_rival()),
			reemplazos.get("regeneracion_mana", regeneracion_mana()),
			reemplazos.get("hechizos", hechizos()),
			reemplazos.get("sellado", sellado()),
			reemplazos.get("huida", huida()),
			reemplazos.get("costos_mana", costos_mana()),
			reemplazos.get("guardado_caida", guardado_caida()))


# El Combo de los fixtures (T16), armado como en ContextoCombate.
static func combo(relaciones: Dictionary = {}) -> Combo:
	var datos: Dictionary = cargar()["datos"]
	return Combo.desde_datos(datos["tablas/combate.json"], Arrimo.desde_datos(datos["tablas/arrimo.json"]),
			afinidad(relaciones))


# El Sellado de los fixtures (T24), armado como en ContextoCombate. costos: otro
# fixture de tablas/costos_mana.json en la carpeta de combate (costos_mana_chico.json).
static func sellado(costos: String = "costos_mana.json") -> Sellado:
	var datos: Dictionary = cargar()["datos"]
	return Sellado.desde_datos(datos["tablas/sellado.json"], costos_mana(costos), datos["tablas/lealtad.json"],
			datos["tablas/combate.json"])


# Los CostosMana de los fixtures (T26), armados como en ContextoCombate. costos:
# otro fixture de tablas/costos_mana.json en la carpeta de combate.
static func costos_mana(costos: String = "costos_mana.json") -> CostosMana:
	return CostosMana.desde_datos(LectorFixture.leer(_CARPETA_COMBATE + costos, "costos_mana")["datos"])


# La Huida de los fixtures (T25), armada como en ContextoCombate. combate: el
# fixture de tablas/combate.json.
static func huida(combate: String = "combate.json") -> Huida:
	return Huida.desde_datos(cargar(combate)["datos"]["tablas/combate.json"])


# El GuardadoCaida de los fixtures (T27), armado como en ContextoCombate. costos:
# otro fixture de tablas/costos_mana.json en la carpeta de combate.
static func guardado_caida(costos: String = "costos_mana.json") -> GuardadoCaida:
	return GuardadoCaida.desde_datos(cargar()["datos"]["tablas/combate.json"], costos_mana(costos))


# El DestinoAtacante de los fixtures (T30), armado como en ContextoCombate: con los
# mismos CostosMana que su Sellado. costos: otro fixture de tablas/costos_mana.json.
static func destino_atacante(costos: String = "costos_mana.json") -> DestinoAtacante:
	var datos: Dictionary = cargar()["datos"]
	var regla_costos: CostosMana = costos_mana(costos)
	var regla_sellado: Sellado = Sellado.desde_datos(datos["tablas/sellado.json"], regla_costos,
			datos["tablas/lealtad.json"], datos["tablas/combate.json"])
	return DestinoAtacante.desde_datos(datos["tablas/combate.json"], datos["tablas/lealtad.json"], regla_costos,
			regla_sellado)
