# Arquitectura.md A.2.1 y B.2 (T13): las claves de texto que usa la pantalla,
# para el chequeo del Cargador (avisa de las que faltan en textos/es.json).
# Constantes mas las que se arman desde los datos: por especie, por estado de
# hambre, por rasgo y por evento de lealtad. Las variantes (.maestro,
# .<especie>) y los complementos (caida.<especie>) los resuelve el armador.
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
# Sesion 2: botones, sucesos, desglose y resultado.
const ACCION_MOVER: String = "accion.mover"
const ACCION_ATACAR: String = "accion.atacar"
const ACCION_ESPERAR: String = "accion.esperar"
const ACCION_TERMINAR: String = "accion.terminar"
const CAIDA: String = "caida"
const CAIDA_LEVANTARSE: String = "caida.levantarse"
const MAESTRO_CAIDA: String = "maestro.caida"
const COMBATE_VICTORIA: String = "combate.victoria"
const MARCA_FUERA: String = "marca.fuera"
const DESGLOSE_BASE: String = "desglose.base"
const DESGLOSE_TOTAL: String = "desglose.total"
const DESGLOSE_MINIMO: String = "desglose.minimo"
const ENFERMO: String = "enfermo.nombre"
const RESULTADO_TITULO: String = "resultado.titulo"
const RESULTADO_RONDAS: String = "resultado.rondas"
const RESULTADO_LEALTAD: String = "resultado.lealtad"
const RESULTADO_VOLVER: String = "resultado.volver"

const FIJAS: Array[String] = [
	MAESTRO_NOMBRE, RONDA, COLA_TITULO, MARCA_CAZA, MARCA_CUENTA,
	PANEL_VIDA, PANEL_LEALTAD, PANEL_HAMBRE, MARCA_CAIDA, MARCA_ERIZADA,
	ACCION_MOVER, ACCION_ATACAR, ACCION_ESPERAR, ACCION_TERMINAR,
	CAIDA, CAIDA_LEVANTARSE, MAESTRO_CAIDA, COMBATE_VICTORIA, MARCA_FUERA,
	DESGLOSE_BASE, DESGLOSE_TOTAL, DESGLOSE_MINIMO, ENFERMO,
	RESULTADO_TITULO, RESULTADO_RONDAS, RESULTADO_LEALTAD, RESULTADO_VOLVER,
]
# Sistema.md 5.1: los estados de lealtad son fijos en el codigo (EstadosUnidad).
const _ESTADOS_LEALTAD: Array[String] = [
	EstadosUnidad.LEALTAD_DESLEAL, EstadosUnidad.LEALTAD_DUDOSA,
	EstadosUnidad.LEALTAD_NEUTRAL, EstadosUnidad.LEALTAD_LEAL,
]
# FinCombate: los desenlaces que hoy pueden pasar (huida es de T26).
const _DESENLACES: Array[String] = ["victoria", "derrota_por_caida"]
# ModificadorDanio.Fuente sin texto propio en es.json (hambre y rasgos lo tienen).
const _FUENTES_DESGLOSE: Array[String] = ["combo", "afinidad", "encono", "cobardia"]

const _PREFIJO_ESPECIES: String = "especies/"
const _TABLA_HAMBRE: String = "tablas/hambre.json"
const _TABLA_LEALTAD: String = "tablas/lealtad.json"
# Marca de la cola (EntradaCola.marca) -> clave.
const _MARCAS: Dictionary = {"caza": MARCA_CAZA, "cuenta": MARCA_CUENTA}


static func nombre_especie(especie_id: String) -> String:
	return "especie.%s.nombre" % especie_id


static func estado_hambre(estado_id: String) -> String:
	return "hambre.estado.%s" % estado_id


static func estado_lealtad(estado_id: String) -> String:
	return "lealtad.estado.%s" % estado_id


static func nombre_rasgo(rasgo_id: String) -> String:
	return "rasgo.%s.nombre" % rasgo_id


static func tooltip_rasgo(rasgo_id: String) -> String:
	return "rasgo.%s.tooltip" % rasgo_id


# estado: el de Plantel.nombre_estado (suelta, guardada, caida, fuera, muerta).
static func estado_unidad(estado: String) -> String:
	return "estado.%s" % estado


static func desenlace(nombre: String) -> String:
	return "resultado.desenlace.%s" % nombre


# motivo: una clave de tablas/lealtad.json eventos (P-019).
static func motivo_lealtad(motivo: String) -> String:
	return "lealtad.motivo.%s" % motivo


static func fuente_desglose(fuente: String) -> String:
	return "desglose.fuente.%s" % fuente


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
	for estado in Criatura.Estado.keys():
		_sumar(claves, estado_unidad((estado as String).to_lower()))
	for nombre in _DESENLACES:
		_sumar(claves, desenlace(nombre))
	for fuente in _FUENTES_DESGLOSE:
		_sumar(claves, fuente_desglose(fuente))
	var rutas: Array = datos.keys()
	rutas.sort()
	for ruta in rutas:
		var ruta_str: String = ruta as String
		if ruta_str.begins_with(_PREFIJO_ESPECIES):
			var especie: Dictionary = datos[ruta]
			_sumar(claves, nombre_especie(especie["id"]))
			_sumar(claves, nombre_rasgo(especie["rasgo"]["id"]))
			_sumar(claves, tooltip_rasgo(especie["rasgo"]["id"]))
	if datos.has(_TABLA_HAMBRE):
		for estado in (datos[_TABLA_HAMBRE] as Dictionary)["estados"]:
			_sumar(claves, estado_hambre(estado["id"]))
	if datos.has(_TABLA_LEALTAD):
		for evento in ((datos[_TABLA_LEALTAD] as Dictionary)["eventos"] as Dictionary).keys():
			if not (evento as String).begins_with("_"):
				_sumar(claves, motivo_lealtad(evento))
	return claves


static func _sumar(claves: Array[String], clave: String) -> void:
	if not claves.has(clave):
		claves.append(clave)
