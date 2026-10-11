# Sistema.md 11.3, Turno de una unidad: una accion del turno, como dato. Son las
# mismas para el jugador y para la IA (T11), y asi las graba el registro (T12).
class_name Accion
extends RefCounted

# Sellar, guardar, invocar y huir son tipos nuevos en T24 y T26 a T28.
# HECHIZO (T22): un solo tipo para todos; el hechizo es un parametro (su id de
# hechizos.json), asi la pantalla los arma desde los datos.
enum Tipo { MOVER, ATACAR, ERIZARSE, TERMINAR, CAVAR, HACERSE_JUNCO, SECUNDAR, HECHIZO }

var tipo: Tipo
# Para MOVER, la casilla de destino; para CAVAR, la del surco.
var casilla: Vector2i = Criatura.SIN_POSICION
# Para ATACAR y HECHIZO: el id de la unidad objetivo.
var objetivo_id: String = ""
# Solo para HECHIZO: el id del hechizo (hechizos.json) y, en la Lanzadera, el
# sentido ("empujar" o "atraer"; "" en los demas).
var hechizo_id: String = ""
var sentido: String = ""
# Solo para SECUNDAR: el id de la aliada detras de la que va a actuar.
var aliado_id: String = ""


func _init(tipo_accion: Tipo) -> void:
	tipo = tipo_accion


static func mover(destino: Vector2i) -> Accion:
	var accion: Accion = Accion.new(Tipo.MOVER)
	accion.casilla = destino
	return accion


static func atacar(id_objetivo: String) -> Accion:
	var accion: Accion = Accion.new(Tipo.ATACAR)
	accion.objetivo_id = id_objetivo
	return accion


static func erizarse() -> Accion:
	return Accion.new(Tipo.ERIZARSE)


# Sistema.md 11.2.1: cavar un surco en `casilla` (solo con el efecto surco).
static func cavar(casilla_surco: Vector2i) -> Accion:
	var accion: Accion = Accion.new(Tipo.CAVAR)
	accion.casilla = casilla_surco
	return accion


# Sistema.md 11.2.2: Hacerse junco (solo con el efecto ocultarse).
static func hacerse_junco() -> Accion:
	return Accion.new(Tipo.HACERSE_JUNCO)


# Sistema.md 10.1: actuar justo despues de la aliada `id_aliado`, que todavia no
# actuo en la ronda.
static func secundar(id_aliado: String) -> Accion:
	var accion: Accion = Accion.new(Tipo.SECUNDAR)
	accion.aliado_id = id_aliado
	return accion


# Sistema.md 1.6 (T22): el Maestro lanza `id_hechizo` sobre `id_objetivo`. sentido: el
# de la Lanzadera; "" para los demas.
static func hechizo(id_hechizo: String, id_objetivo: String, sentido_hechizo: String = "") -> Accion:
	var accion: Accion = Accion.new(Tipo.HECHIZO)
	accion.hechizo_id = id_hechizo
	accion.objetivo_id = id_objetivo
	accion.sentido = sentido_hechizo
	return accion


# Cierra el turno. Sin haber usado la accion, es "esperar" (P-015).
static func terminar() -> Accion:
	return Accion.new(Tipo.TERMINAR)


# Arquitectura.md A.7: la accion como diccionario, para el registro y la
# grabacion. Solo enteros y textos; ida y vuelta exacta con desde_diccionario.
func a_diccionario() -> Dictionary:
	var resultado: Dictionary = {"tipo": (Tipo.keys()[tipo] as String).to_lower()}
	match tipo:
		Tipo.MOVER, Tipo.CAVAR:
			resultado["casilla"] = [casilla.x, casilla.y]
		Tipo.ATACAR:
			resultado["objetivo"] = objetivo_id
		Tipo.SECUNDAR:
			resultado["aliado"] = aliado_id
		Tipo.HECHIZO:
			resultado["hechizo"] = hechizo_id
			resultado["objetivo"] = objetivo_id
			if not sentido.is_empty():
				resultado["sentido"] = sentido
	return resultado


# null si el diccionario no es una accion valida (tipo desconocido, falta o
# sobra un campo, casilla mal formada).
static func desde_diccionario(datos: Dictionary) -> Accion:
	if not datos.get("tipo") is String:
		return null
	var nombre: String = (datos["tipo"] as String).to_upper()
	if not Tipo.has(nombre) or datos["tipo"] != nombre.to_lower():
		return null
	var tipo_accion: Tipo = Tipo[nombre]
	match tipo_accion:
		Tipo.MOVER, Tipo.CAVAR:
			if datos.size() != 2 or not _es_casilla(datos.get("casilla")):
				return null
			var par: Array = datos["casilla"]
			var con_casilla: Accion = Accion.new(tipo_accion)
			con_casilla.casilla = Vector2i(int(par[0]), int(par[1]))
			return con_casilla
		Tipo.ATACAR:
			if datos.size() != 2 or not datos.get("objetivo") is String:
				return null
			return atacar(datos["objetivo"])
		Tipo.SECUNDAR:
			if datos.size() != 2 or not datos.get("aliado") is String:
				return null
			return secundar(datos["aliado"])
		Tipo.HECHIZO:
			var con_sentido: bool = datos.has("sentido")
			if datos.size() != (4 if con_sentido else 3) or not datos.get("hechizo") is String \
					or not datos.get("objetivo") is String:
				return null
			if con_sentido and (not datos["sentido"] is String or (datos["sentido"] as String).is_empty()):
				return null
			return hechizo(datos["hechizo"], datos["objetivo"], datos.get("sentido", ""))
	if datos.size() != 1:
		return null
	return Accion.new(tipo_accion)


# Un par [x, y] de enteros (un JSON leido sin validar los trae como 3.0).
static func _es_casilla(valor: Variant) -> bool:
	if not valor is Array or (valor as Array).size() != 2:
		return false
	for coordenada in (valor as Array):
		if not (coordenada is int or coordenada is float) or coordenada != floorf(coordenada):
			return false
	return true


# Sistema.md 11.3: invocar, huir y cavar un surco gastan el turno completo. Los
# tipos de T26 a T28 se suman aca.
func gasta_turno_completo() -> bool:
	return tipo == Tipo.CAVAR
