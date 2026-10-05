# Arquitectura.md A.2.1 y B.2 (T13): las claves de texto que usa la pantalla,
# para el chequeo del Cargador (avisa de las que faltan en textos/es.json).
# Constantes mas las que se arman desde los datos: una por especie y una por
# estado de hambre. Las variantes (.maestro, .<especie>) las resuelve el armador.
class_name ClavesTextos
extends RefCounted

const MAESTRO_NOMBRE: String = "maestro.nombre"
const RONDA: String = "combate.ronda"
const COLA_TITULO: String = "iniciativa.titulo"
const MARCA_CAZA: String = "iniciativa.caza"
const MARCA_CUENTA: String = "iniciativa.cuenta"
const PANEL_VIDA: String = "panel.vida"
const PANEL_LEALTAD: String = "panel.lealtad"
const PANEL_HAMBRE: String = "panel.hambre"
const MARCA_CAIDA: String = "marca.caida"
const MARCA_ERIZADA: String = "marca.erizada"

const FIJAS: Array[String] = [
	MAESTRO_NOMBRE, RONDA, COLA_TITULO, MARCA_CAZA, MARCA_CUENTA,
	PANEL_VIDA, PANEL_LEALTAD, PANEL_HAMBRE, MARCA_CAIDA, MARCA_ERIZADA,
]
# Sistema.md 5.1: los estados de lealtad son fijos en el codigo (EstadosUnidad).
const _ESTADOS_LEALTAD: Array[String] = [
	EstadosUnidad.LEALTAD_DESLEAL, EstadosUnidad.LEALTAD_DUDOSA,
	EstadosUnidad.LEALTAD_NEUTRAL, EstadosUnidad.LEALTAD_LEAL,
]

const _PREFIJO_ESPECIES: String = "especies/"
const _TABLA_HAMBRE: String = "tablas/hambre.json"
# Marca de la cola (EntradaCola.marca) -> clave.
const _MARCAS: Dictionary = {"caza": MARCA_CAZA, "cuenta": MARCA_CUENTA}


static func nombre_especie(especie_id: String) -> String:
	return "especie.%s.nombre" % especie_id


static func estado_hambre(estado_id: String) -> String:
	return "hambre.estado.%s" % estado_id


static func estado_lealtad(estado_id: String) -> String:
	return "lealtad.estado.%s" % estado_id


# "" si la entrada no tiene marca o la marca no tiene clave.
static func marca_cola(marca: String) -> String:
	return _MARCAS.get(marca, "")


# datos: Cargador.cargar_carpeta()["datos"]. Sin repetidos, en orden estable.
static func usadas(datos: Dictionary) -> Array[String]:
	var claves: Array[String] = []
	for fija in FIJAS:
		_sumar(claves, fija)
	for estado in _ESTADOS_LEALTAD:
		_sumar(claves, estado_lealtad(estado))
	var rutas: Array = datos.keys()
	rutas.sort()
	for ruta in rutas:
		var ruta_str: String = ruta as String
		if ruta_str.begins_with(_PREFIJO_ESPECIES):
			_sumar(claves, nombre_especie((datos[ruta] as Dictionary)["id"]))
	if datos.has(_TABLA_HAMBRE):
		for estado in (datos[_TABLA_HAMBRE] as Dictionary)["estados"]:
			_sumar(claves, estado_hambre(estado["id"]))
	return claves


static func _sumar(claves: Array[String], clave: String) -> void:
	if not claves.has(clave):
		claves.append(clave)
