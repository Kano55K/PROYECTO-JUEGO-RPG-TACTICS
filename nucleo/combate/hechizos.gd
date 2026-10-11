# Sistema.md 1.6 (T22): los hechizos del Maestro, como datos de solo lectura. Sin
# estado del combate: el Turno los lanza. El comportamiento sale del `efecto` y
# de la `geometria` de hechizos.json, nunca del id (Arquitectura.md A.2.2); los
# numeros (costo, alcance, base, por_poder, casillas, danio_choque), de ahi.
class_name Hechizos
extends RefCounted

# Sistema.md 1.6: los efectos programados (hechizos.schema.json).
const EFECTO_DANIO: String = "danio"
const EFECTO_EMPUJE: String = "empuje"
const EFECTO_CURA: String = "cura"
# D-001: la geometria es codigo. Manhattan sin bloqueo; linea recta que no
# atraviesa enemigas; las 4 ortogonales (11.3 v1.6).
const GEOMETRIA_DISTANCIA_LIBRE: String = "distancia_libre"
const GEOMETRIA_LINEA: String = "linea_bloqueo_enemigas"
const GEOMETRIA_ADYACENTE: String = "adyacente"
# Sistema.md 1.6, Lanzadera.
const SENTIDO_EMPUJAR: String = "empujar"
const SENTIDO_ATRAER: String = "atraer"
# Arquitectura.md A.7 y D-007: el motivo del evento `mana` que paga un hechizo.
const MOTIVO_HECHIZO: String = "hechizo"

# Los parametros que pide cada efecto (el esquema no tiene oneOf, A.2).
const _PARAMETROS: Dictionary = {
	EFECTO_DANIO: ["base", "por_poder"],
	EFECTO_CURA: ["base", "por_poder"],
	EFECTO_EMPUJE: ["danio_choque", "casillas", "modos"],
}

# id -> ficha del hechizo, solo los del Maestro.
var _hechizos: Dictionary = {}
var _ids: Array[String] = []


# tabla_hechizos: hechizos.json. ficha_maestro: maestro.json (sus `hechizos`).
# null si falta la tabla, si un hechizo del Maestro no esta en ella o si no trae
# los parametros de su efecto: sin valores por defecto (leccion de T09 y T37).
static func desde_datos(tabla_hechizos: Dictionary, ficha_maestro: Dictionary) -> Hechizos:
	if not tabla_hechizos.has("hechizos") or not ficha_maestro.has("hechizos"):
		return null
	var por_id: Dictionary = {}
	for hechizo in (tabla_hechizos["hechizos"] as Array):
		por_id[hechizo["id"]] = hechizo
	var regla: Hechizos = Hechizos.new()
	for id_hechizo in (ficha_maestro["hechizos"] as Array):
		if not por_id.has(id_hechizo):
			return null
		var hechizo: Dictionary = por_id[id_hechizo]
		for parametro in _PARAMETROS.get(hechizo["efecto"], []):
			if not hechizo.has(parametro):
				return null
		regla._hechizos[id_hechizo] = hechizo.duplicate(true)
		regla._ids.append(id_hechizo)
	return regla


# Los del Maestro, en el orden de maestro.json (la pantalla arma un boton por cada uno).
func ids() -> Array[String]:
	return _ids.duplicate()


# Copia de la ficha del hechizo, o {} si el Maestro no lo tiene.
func hechizo(id_hechizo: String) -> Dictionary:
	return (_hechizos.get(id_hechizo, {}) as Dictionary).duplicate(true)


# D-010: el efecto de un hechizo que escala con Poder (danio del Martillazo, cura
# del Remiendo) es base + por_poder x Poder. El unico lugar de la formula.
func valor(id_hechizo: String, poder: int) -> int:
	var ficha: Dictionary = _hechizos[id_hechizo]
	return ficha["base"] + ficha["por_poder"] * poder
