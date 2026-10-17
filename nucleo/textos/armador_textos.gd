# Arquitectura.md A.2.1 / Mundo.md 1.5: arma el texto que ve el jugador desde
# una clave de textos/es.json y los datos de sus huecos. Variantes por sujeto,
# complementos, variantes al azar, huecos gramaticales y mayusculas. Lo que
# falta no rompe: se muestra [FALTA: ...] y queda un aviso.
class_name ArmadorTextos
extends RefCounted

enum Motivo {
	# Pedidos (avisos()).
	CLAVE_FALTANTE,
	HUECO_SIN_DATO,
	# Una forma de rol ({a_rival}, {criatura_la}...) sobre un valor que no es HuecoCriatura.
	HUECO_NO_ES_CRIATURA,
	# Falta especie.<id>.articulo o .nombre, o el articulo no es "el" ni "la".
	ESPECIE_SIN_TEXTO,
	# Revision estatica (revisar()).
	HUECO_MAL_FORMADO,
	LLAVE_SIN_CERRAR,
	CORCHETE_SIN_CONVERTIR,
}

# A.2.1: claves cuya variante del sujeto va despues de la base, como otra linea.
const PREFIJOS_COMPLEMENTO: Array[String] = ["caida.", "nocturno.base.", "nocturno.raso."]

# Mundo.md 1.5, tabla de huecos gramaticales: formas que dependen del articulo.
# "a" y "de" llevan el nombre detras (con la contraccion al / del).
const _FORMAS_POR_ARTICULO: Dictionary = {
	"el": {"a": "al", "de": "del", "o": "o", "la": "lo", "ella": "él"},
	"la": {"a": "a la", "de": "de la", "o": "a", "la": "la", "ella": "ella"},
}
const _PREFIJOS_FORMA: Dictionary = {"a_": "a", "de_": "de"}
const _SUFIJOS_FORMA: Dictionary = {"_o": "o", "_la": "la", "_ella": "ella"}
# Forma {rol} sola: articulo y nombre.
const _FORMA_ROL: String = ""

# Mundo.md 1.5: mayuscula al principio y despues de estos signos.
const _SIGNOS_MAYUSCULA: String = ".?!¿¡"
# Lo que se saltea antes de la letra que sube.
const _SALTEABLES: String = " \n\t¿¡«“\"('"

const _CLAVES_NO_TEXTO: Array[String] = ["$schema", "_nota"]
const _PATRON_HUECO: String = "^[a-z0-9_]+$"
const _PATRON_CORCHETE: String = "\\[[^\\]]+\\]"

var _textos: Dictionary = {}
var _generador: GeneradorAzar
# especie_id -> {forma: texto} o {"falta": clave de texto que falta}. Se arma una vez.
var _formas_por_especie: Dictionary = {}
var _avisos: Array[Dictionary] = []


# textos: Cargador.cargar_carpeta()["datos"]["textos/es.json"].
# generador: el de textos (ContextoCombate.azar_textos), nunca el de combate (A.8).
static func desde_datos(textos: Dictionary, generador: GeneradorAzar) -> ArmadorTextos:
	var armador: ArmadorTextos = ArmadorTextos.new()
	armador._textos = textos
	armador._generador = generador
	return armador


# sujeto: id de especie o "maestro", para las variantes <clave>.<sujeto>.
func armar(clave: String, datos: Dictionary = {}, sujeto: String = "") -> String:
	return "\n".join(armar_lineas(clave, datos, sujeto))


# La base y, si es un complemento, la variante del sujeto: la pantalla decide
# como mostrarlas.
func armar_lineas(clave: String, datos: Dictionary = {}, sujeto: String = "") -> Array[String]:
	var lineas: Array[String] = []
	for clave_linea in _claves_a_mostrar(clave, sujeto):
		lineas.append(_armar_linea(clave_linea, datos))
	return lineas


# T19: si la clave tiene texto (sin avisar), para elegir entre una linea propia
# y la general cuando la variante no sigue la forma <clave>.<sujeto>.
func tiene(clave: String) -> bool:
	return _es_texto(clave)


# Avisos de los pedidos hechos hasta ahora: {clave, hueco, motivo}.
func avisos() -> Array[Dictionary]:
	return _avisos.duplicate(true)


static func es_complemento(clave: String) -> bool:
	for prefijo in PREFIJOS_COMPLEMENTO:
		if (clave + ".").begins_with(prefijo):
			return true
	return false


# A.2.1: revision estatica de todo el archivo. Devuelve {clave, fragmento, motivo}.
static func revisar(textos: Dictionary) -> Array[Dictionary]:
	var avisos_revision: Array[Dictionary] = []
	var hueco_valido: RegEx = RegEx.create_from_string(_PATRON_HUECO)
	var corchete: RegEx = RegEx.create_from_string(_PATRON_CORCHETE)
	for clave in textos.keys():
		if _CLAVES_NO_TEXTO.has(clave):
			continue
		var valor: Variant = textos[clave]
		var lista: Array = valor if valor is Array else [valor]
		for texto in lista:
			_revisar_texto(clave, str(texto), hueco_valido, corchete, avisos_revision)
	return avisos_revision


# Mundo.md 1.5: la variante del sujeto reemplaza a la base, salvo en los
# complementos, que van despues.
func _claves_a_mostrar(clave: String, sujeto: String) -> Array[String]:
	var variante: String = clave + "." + sujeto
	var hay_variante: bool = not sujeto.is_empty() and _es_texto(variante)
	var claves: Array[String] = []
	if es_complemento(clave):
		claves.append(clave)
		if hay_variante:
			claves.append(variante)
	else:
		claves.append(variante if hay_variante else clave)
	return claves


func _es_texto(clave: String) -> bool:
	return _textos.has(clave) and not _CLAVES_NO_TEXTO.has(clave)


func _armar_linea(clave: String, datos: Dictionary) -> String:
	if not _es_texto(clave):
		_avisar(clave, "", Motivo.CLAVE_FALTANTE)
		return "[FALTA: %s]" % clave
	return _mayusculas(_llenar_huecos(clave, _elegir(_textos[clave]), datos))


# A.2.1: una lista se elige con el generador de textos; un texto suelto no tira.
func _elegir(valor: Variant) -> String:
	if valor is Array:
		var lista: Array = valor
		return str(lista[_generador.entero(0, lista.size() - 1)])
	return str(valor)


# Un solo recorrido: lo insertado no se vuelve a mirar. Una llave sin cerrar
# queda tal cual (la avisa revisar).
func _llenar_huecos(clave: String, texto: String, datos: Dictionary) -> String:
	var partes: PackedStringArray = []
	var desde: int = 0
	while desde < texto.length():
		var abre: int = texto.find("{", desde)
		var cierra: int = texto.find("}", abre) if abre != -1 else -1
		if cierra == -1:
			partes.append(texto.substr(desde))
			break
		partes.append(texto.substr(desde, abre - desde))
		partes.append(_hueco(clave, texto.substr(abre + 1, cierra - abre - 1), datos))
		desde = cierra + 1
	return "".join(partes)


# {duracion} (tiempo.dia / tiempo.dias) es de 0b: hoy es un hueco mas, sin dato.
func _hueco(clave: String, nombre: String, datos: Dictionary) -> String:
	if datos.has(nombre):
		var valor: Variant = datos[nombre]
		if valor is HuecoCriatura:
			return _forma(clave, nombre, (valor as HuecoCriatura).especie_id, _FORMA_ROL)
		return str(valor)
	for prefijo in _PREFIJOS_FORMA.keys():
		if nombre.begins_with(prefijo):
			var rol: String = nombre.substr(prefijo.length())
			if datos.has(rol):
				return _forma_de_rol(clave, nombre, datos[rol], _PREFIJOS_FORMA[prefijo])
	for sufijo in _SUFIJOS_FORMA.keys():
		if nombre.ends_with(sufijo):
			var rol: String = nombre.substr(0, nombre.length() - sufijo.length())
			if datos.has(rol):
				return _forma_de_rol(clave, nombre, datos[rol], _SUFIJOS_FORMA[sufijo])
	_avisar(clave, nombre, Motivo.HUECO_SIN_DATO)
	return "[FALTA: %s]" % nombre


func _forma_de_rol(clave: String, nombre: String, valor: Variant, forma: String) -> String:
	if valor is not HuecoCriatura:
		_avisar(clave, nombre, Motivo.HUECO_NO_ES_CRIATURA)
		return "[FALTA: %s]" % nombre
	return _forma(clave, nombre, (valor as HuecoCriatura).especie_id, forma)


func _forma(clave: String, nombre: String, especie_id: String, forma: String) -> String:
	var formas: Dictionary = _formas_de_especie(especie_id)
	if formas.has("falta"):
		_avisar(clave, nombre, Motivo.ESPECIE_SIN_TEXTO)
		return "[FALTA: %s]" % formas["falta"]
	return formas[forma]


# Mundo.md 1.5: las seis formas, armadas una sola vez por especie desde
# especie.<id>.articulo y especie.<id>.nombre.
func _formas_de_especie(especie_id: String) -> Dictionary:
	if _formas_por_especie.has(especie_id):
		return _formas_por_especie[especie_id]
	var clave_articulo: String = "especie.%s.articulo" % especie_id
	var clave_nombre: String = "especie.%s.nombre" % especie_id
	var formas: Dictionary = {}
	if _textos.get(clave_articulo) is not String or not _FORMAS_POR_ARTICULO.has(_textos[clave_articulo]):
		formas["falta"] = clave_articulo
	elif _textos.get(clave_nombre) is not String:
		formas["falta"] = clave_nombre
	else:
		var articulo: String = _textos[clave_articulo]
		var nombre: String = _textos[clave_nombre]
		var tabla: Dictionary = _FORMAS_POR_ARTICULO[articulo]
		formas[_FORMA_ROL] = articulo + " " + nombre
		formas["a"] = tabla["a"] + " " + nombre
		formas["de"] = tabla["de"] + " " + nombre
		for forma in ["o", "la", "ella"]:
			formas[forma] = tabla[forma]
	_formas_por_especie[especie_id] = formas
	return formas


# Mundo.md 1.5: mayuscula en la primera letra del texto y en la primera letra
# despues de . ? ! ¿ ¡ (salteando espacios y signos de apertura). Si lo primero
# no es una letra, no se toca. El resto queda igual.
func _mayusculas(texto: String) -> String:
	var letras: PackedStringArray = []
	var subir: bool = true
	for i in range(texto.length()):
		var letra: String = texto[i]
		if subir and not _SALTEABLES.contains(letra):
			if letra.to_upper() != letra.to_lower():
				letra = letra.to_upper()
			subir = false
		if _SIGNOS_MAYUSCULA.contains(letra):
			subir = true
		letras.append(letra)
	return "".join(letras)


func _avisar(clave: String, hueco: String, motivo: Motivo) -> void:
	_avisos.append({"clave": clave, "hueco": hueco, "motivo": motivo})


static func _revisar_texto(clave: String, texto: String, hueco_valido: RegEx, corchete: RegEx, avisos_revision: Array[Dictionary]) -> void:
	var desde: int = 0
	while true:
		var abre: int = texto.find("{", desde)
		if abre == -1:
			break
		var siguiente: int = texto.find("{", abre + 1)
		var cierra: int = texto.find("}", abre + 1)
		if cierra == -1 or (siguiente != -1 and siguiente < cierra):
			var hasta: int = siguiente if siguiente != -1 else texto.length()
			avisos_revision.append({"clave": clave, "fragmento": texto.substr(abre, hasta - abre), "motivo": Motivo.LLAVE_SIN_CERRAR})
			desde = abre + 1
			continue
		if hueco_valido.search(texto.substr(abre + 1, cierra - abre - 1)) == null:
			avisos_revision.append({"clave": clave, "fragmento": texto.substr(abre, cierra - abre + 1), "motivo": Motivo.HUECO_MAL_FORMADO})
		desde = cierra + 1
	for encontrado in corchete.search_all(texto):
		avisos_revision.append({"clave": clave, "fragmento": encontrado.get_string(), "motivo": Motivo.CORCHETE_SIN_CONVERTIR})
