# Arquitectura.md A.2.1 y B.2 (T13): las claves de texto que usa la pantalla,
# para el chequeo del Cargador (avisa de las que faltan en textos/es.json).
# Constantes mas las que se arman desde los datos: por especie, por estado de
# hambre, por rasgo, por modo y por evento de lealtad. Las variantes (.maestro,
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
# T40: rasgos de la v1.3 (Arquitectura.md 10.5, claves confirmadas).
const ACCION_CAVAR: String = "accion.cavar"
const MARCA_OCULTO: String = "marca.oculto"
const MARCA_BONO: String = "marca.bono"
const SUCESO_SURCO_CAVAR: String = "suceso.surco.cavar"
const SUCESO_SURCO_CERRAR: String = "suceso.surco.cerrar"
const SUCESO_OCULTO: String = "suceso.oculto"
const SUCESO_PIERDE_BONO: String = "suceso.pierde_bono"
const AVISO_CUENTA_UMBRAL: String = "aviso.cuenta.umbral"
const AVISO_DESTAPAR: String = "aviso.destapar"
# T14: obediencia en el panel (clave propuesta, falta en es.json) y el suceso
# del hambre de combate (Mundo.md, "Hechizos, hambre y cierre del combate").
const PANEL_OBEDIENCIA: String = "panel.obediencia"
const COMBATE_HAMBRE: String = "combate.hambre"
# T16: la cadena en curso en el panel (clave propuesta, falta en es.json).
const PANEL_CADENA: String = "panel.cadena"
# T41: el aviso de afinidad al pasar el mouse por una casilla (Mundo.md 9.2 v1.2).
const AFINIDAD_TOOLTIP: String = "afinidad.tooltip"
# T17: el boton de Secundar y su suceso (Sistema.md 10.1).
const ACCION_SECUNDAR: String = "accion.secundar"
# T18: el aviso del incidente y su suceso (Mundo.md 9.2 v1.2). Los sucesos tienen
# variantes por par de especies (incidente.<resultado>.<especie>.<rival>).
const INCIDENTE_TOOLTIP: String = "incidente.tooltip"
const INCIDENTE_DISTRAIDA: String = "incidente.distraida"
const INCIDENTE_ATAQUE: String = "incidente.ataque"

const FIJAS: Array[String] = [
	MAESTRO_NOMBRE, RONDA, COLA_TITULO, MARCA_CAZA, MARCA_CUENTA,
	PANEL_VIDA, PANEL_LEALTAD, PANEL_HAMBRE, MARCA_CAIDA, MARCA_ERIZADA,
	ACCION_MOVER, ACCION_ATACAR, ACCION_ESPERAR, ACCION_TERMINAR,
	CAIDA, CAIDA_LEVANTARSE, MAESTRO_CAIDA, COMBATE_VICTORIA, MARCA_FUERA,
	DESGLOSE_BASE, DESGLOSE_TOTAL, DESGLOSE_MINIMO, ENFERMO,
	RESULTADO_TITULO, RESULTADO_RONDAS, RESULTADO_LEALTAD, RESULTADO_VOLVER,
	ACCION_CAVAR, MARCA_OCULTO, MARCA_BONO, SUCESO_SURCO_CAVAR, SUCESO_SURCO_CERRAR,
	SUCESO_OCULTO, SUCESO_PIERDE_BONO, AVISO_CUENTA_UMBRAL, AVISO_DESTAPAR,
	PANEL_OBEDIENCIA, COMBATE_HAMBRE, PANEL_CADENA, AFINIDAD_TOOLTIP, ACCION_SECUNDAR,
	INCIDENTE_TOOLTIP, INCIDENTE_DISTRAIDA, INCIDENTE_ATAQUE,
]
# Sistema.md 5.1: los estados de lealtad son fijos en el codigo (EstadosUnidad).
const _ESTADOS_LEALTAD: Array[String] = [
	EstadosUnidad.LEALTAD_DESLEAL, EstadosUnidad.LEALTAD_DUDOSA,
	EstadosUnidad.LEALTAD_NEUTRAL, EstadosUnidad.LEALTAD_LEAL,
]
# FinCombate: los desenlaces que hoy pueden pasar (huida es de T26).
const _DESENLACES: Array[String] = ["victoria", "derrota_por_caida"]
# ModificadorDanio.Fuente sin texto propio en es.json (hambre, rasgos y modo lo tienen).
const _FUENTES_DESGLOSE: Array[String] = ["combo", "afinidad", "encono", "cobardia"]
# Arquitectura.md A.7: motivos del evento destape.
const _MOTIVOS_DESTAPE: Array[String] = [Junco.MOTIVO_MOVER, Junco.MOTIVO_ATACAR, Junco.MOTIVO_CONTACTO]

const _PREFIJO_ESPECIES: String = "especies/"
const _PREFIJO_TEXTOS: String = "textos/"
const _TABLA_HAMBRE: String = "tablas/hambre.json"
const _TABLA_LEALTAD: String = "tablas/lealtad.json"


static func nombre_especie(especie_id: String) -> String:
	return "especie.%s.nombre" % especie_id


static func estado_hambre(estado_id: String) -> String:
	return "hambre.estado.%s" % estado_id


static func estado_lealtad(estado_id: String) -> String:
	return "lealtad.estado.%s" % estado_id


# T14: tramo de Obediencia (Obediencia.TRAMOS). Sin concordancia: califica a la
# obediencia, no a la unidad.
static func tramo_obediencia(tramo: String) -> String:
	return "obediencia.tramo.%s" % tramo


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


# T40: el nombre de un modo (rasgo.modos[].id) en la cola, la ficha y el desglose
# (Arquitectura.md 10.5: iniciativa.caza e iniciativa.cuenta).
static func modo(modo_id: String) -> String:
	return "iniciativa.%s" % modo_id


# "" si la entrada no tiene marca.
static func marca_cola(marca: String) -> String:
	return "" if marca.is_empty() else modo(marca)


# motivo: Junco.MOTIVO_* (A.7).
static func suceso_destape(motivo: String) -> String:
	return "suceso.destape.%s" % motivo


# a: el modo al que pasa (evento cambio_modo, A.7).
static func suceso_cambio(a: String) -> String:
	return "suceso.%s.cambio" % a


# datos: Cargador.cargar_carpeta()["datos"]. Sin repetidos, en orden estable.
static func usadas(datos: Dictionary) -> Array[String]:
	var claves: Array[String] = []
	for fija in FIJAS:
		_sumar(claves, fija)
	for estado in _ESTADOS_LEALTAD:
		_sumar(claves, estado_lealtad(estado))
	for tramo in Obediencia.TRAMOS:
		_sumar(claves, tramo_obediencia(tramo))
	for estado in Criatura.Estado.keys():
		_sumar(claves, estado_unidad((estado as String).to_lower()))
	for nombre in _DESENLACES:
		_sumar(claves, desenlace(nombre))
	for fuente in _FUENTES_DESGLOSE:
		_sumar(claves, fuente_desglose(fuente))
	for motivo in _MOTIVOS_DESTAPE:
		_sumar(claves, suceso_destape(motivo))
	var rutas: Array = datos.keys()
	rutas.sort()
	var especies: Array[String] = []
	for ruta in rutas:
		var ruta_str: String = ruta as String
		if ruta_str.begins_with(_PREFIJO_ESPECIES):
			var especie: Dictionary = datos[ruta]
			var rasgo: Dictionary = especie["rasgo"]
			especies.append(especie["id"])
			_sumar(claves, nombre_especie(especie["id"]))
			_sumar(claves, nombre_rasgo(rasgo["id"]))
			_sumar(claves, tooltip_rasgo(rasgo["id"]))
			var modos: Array = rasgo.get("modos", [])
			for datos_modo in modos:
				_sumar(claves, modo(datos_modo["id"]))
				# Sistema.md 11.2.3: se pasa a los modos que no son el inicial.
				if datos_modo["id"] != rasgo["modo_inicial"]:
					_sumar(claves, suceso_cambio(datos_modo["id"]))
	if datos.has(_TABLA_HAMBRE):
		for estado in (datos[_TABLA_HAMBRE] as Dictionary)["estados"]:
			_sumar(claves, estado_hambre(estado["id"]))
	if datos.has(_TABLA_LEALTAD):
		for evento in ((datos[_TABLA_LEALTAD] as Dictionary)["eventos"] as Dictionary).keys():
			if not (evento as String).begins_with("_"):
				_sumar(claves, motivo_lealtad(evento))
	_sumar_variantes(claves, datos, especies)
	return claves


# Arquitectura.md A.2.1, concordancia de las etiquetas: hambre.estado.*,
# lealtad.estado.*, estado.* y marca.caida se piden con la especie (o maestro)
# como sujeto. Una variante es opcional (sin ella sale la base): solo se suman
# las que estan en algun archivo de textos, asi no aparecen como faltantes.
static func _sumar_variantes(claves: Array[String], datos: Dictionary, especies: Array[String]) -> void:
	var existentes: Dictionary = {}
	for ruta in datos.keys():
		if (ruta as String).begins_with(_PREFIJO_TEXTOS):
			for clave in (datos[ruta] as Dictionary).keys():
				existentes[clave] = true
	var sujetos: Array[String] = [Maestro.ID]
	sujetos.append_array(especies)
	for base in claves.duplicate():
		if not _es_etiqueta(base):
			continue
		for sujeto in sujetos:
			var variante: String = "%s.%s" % [base, sujeto]
			if existentes.has(variante):
				_sumar(claves, variante)
	# T18: los sucesos del incidente se piden con el par de especies como sujeto.
	for base in [INCIDENTE_DISTRAIDA, INCIDENTE_ATAQUE]:
		for especie in especies:
			for rival in especies:
				var variante: String = "%s.%s.%s" % [base, especie, rival]
				if existentes.has(variante):
					_sumar(claves, variante)


static func _es_etiqueta(clave: String) -> bool:
	return clave == MARCA_CAIDA or clave.begins_with("hambre.estado.") \
			or clave.begins_with("lealtad.estado.") or clave.begins_with("estado.")


static func _sumar(claves: Array[String], clave: String) -> void:
	if not claves.has(clave):
		claves.append(clave)
