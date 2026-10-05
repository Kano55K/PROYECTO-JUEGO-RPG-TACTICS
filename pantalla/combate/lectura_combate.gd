# Arquitectura.md B.2 (T13): traduce el estado del combate en lo que la vista
# dibuja, sin nodos. No calcula reglas: lee instantanea(), la cola, el Plantel
# y las consultas del nucleo (EstadosUnidad, vida_max_real, fila_balanza), y
# pide cada texto al ArmadorTextos. Se rearma en cada redibujo: no guarda estado.
class_name LecturaCombate
extends RefCounted

const _ESTADO_SUELTA: String = "suelta"
const _ESTADO_CAIDA: String = "caida"

var _combate: Combate
var _plantel: Plantel
var _armador: ArmadorTextos
var _estados: EstadosUnidad


func _init(combate: Combate, armador: ArmadorTextos, estados: EstadosUnidad) -> void:
	_combate = combate
	_plantel = combate.contexto().plantel
	_armador = armador
	_estados = estados


# Una ficha por unidad en el tablero (de pie o caida), el Maestro primero:
# {id, casilla: Vector2i, tribu: bool, maestro: bool, caida: bool, nombre, vida,
# vida_max, marcas: Array[String]}.
func fichas() -> Array[Dictionary]:
	var lista: Array[Dictionary] = []
	var foto: Dictionary = _combate.instantanea()
	var foto_maestro: Dictionary = foto["maestro"]
	if foto_maestro["posicion"] != null:
		var marcas_maestro: Array[String] = []
		if foto_maestro["caido"]:
			marcas_maestro.append(_armador.armar(ClavesTextos.MARCA_CAIDA))
		lista.append(_ficha(Maestro.ID, foto_maestro["posicion"], true, true, foto_maestro["caido"],
				foto_maestro["vida"], _plantel.maestro.vida_max_real(), marcas_maestro))
	for foto_criatura in foto["criaturas"]:
		var estado: String = foto_criatura["estado"]
		if foto_criatura["posicion"] == null or not estado in [_ESTADO_SUELTA, _ESTADO_CAIDA]:
			continue
		var criatura: Criatura = _plantel.criatura(foto_criatura["id"])
		var marcas: Array[String] = []
		if estado == _ESTADO_CAIDA:
			marcas.append(_armador.armar(ClavesTextos.MARCA_CAIDA))
		if foto_criatura["erizada"]:
			marcas.append(_armador.armar(ClavesTextos.MARCA_ERIZADA))
		lista.append(_ficha(criatura.id, foto_criatura["posicion"], criatura.bando == Criatura.Bando.TRIBU,
				false, estado == _ESTADO_CAIDA, foto_criatura["vida"], criatura.vida_max_real(), marcas))
	return lista


# Una fila por entrada de la cola de la ronda, en orden:
# {unidad_id, marca, texto, actual: bool, actuo: bool}.
func filas_cola() -> Array[Dictionary]:
	var filas: Array[Dictionary] = []
	var actual: int = _combate.entrada_actual()
	var entradas: Array[EntradaCola] = _combate.cola()
	for i in range(entradas.size()):
		var entrada: EntradaCola = entradas[i]
		var texto: String = nombre(entrada.unidad_id)
		var clave_marca: String = ClavesTextos.marca_cola(entrada.marca)
		if not clave_marca.is_empty():
			texto += " · " + _armador.armar(clave_marca)
		filas.append({"unidad_id": entrada.unidad_id, "marca": entrada.marca, "texto": texto,
				"actual": i == actual, "actuo": entrada.actuo})
	return filas


func titulo_cola() -> String:
	return _armador.armar(ClavesTextos.COLA_TITULO)


func texto_ronda() -> String:
	return _armador.armar(ClavesTextos.RONDA, {"n": _combate.instantanea()["ronda"]})


# Lineas del panel de la unidad del turno: nombre, vida y, si los tiene,
# lealtad y hambre con su estado. Vacio si no hay turno.
func panel_turno() -> Array[String]:
	var turno: Turno = _combate.turno_actual()
	if turno == null:
		return []
	var id_unidad: String = turno.unidad_id
	var lineas: Array[String] = [nombre(id_unidad)]
	var etiqueta_vida: String = _armador.armar(ClavesTextos.PANEL_VIDA)
	var etiqueta_hambre: String = _armador.armar(ClavesTextos.PANEL_HAMBRE)
	if id_unidad == Maestro.ID:
		var maestro: Maestro = _plantel.maestro
		lineas.append("%s: %d/%d" % [etiqueta_vida, maestro.vida, maestro.vida_max_real()])
		lineas.append(_linea_hambre(etiqueta_hambre, maestro.hambre, Maestro.ID))
		return lineas
	var criatura: Criatura = _plantel.criatura(id_unidad)
	lineas.append("%s: %d/%d" % [etiqueta_vida, criatura.vida, criatura.vida_max_real()])
	# Las enemigas no tienen lealtad ni hambre en el escenario (S-17).
	if criatura.bando == Criatura.Bando.TRIBU:
		var umbral: int = _plantel.maestro.fila_balanza()["umbral_rescate"]
		var estado_lealtad: String = _estados.lealtad(criatura.lealtad, umbral)
		lineas.append("%s: %d (%s)" % [_armador.armar(ClavesTextos.PANEL_LEALTAD), criatura.lealtad,
				_armador.armar(ClavesTextos.estado_lealtad(estado_lealtad))])
		lineas.append(_linea_hambre(etiqueta_hambre, criatura.hambre, criatura.especie.id()))
	return lineas


# El nombre que ve el jugador: el del Maestro o el de la especie.
func nombre(id_unidad: String) -> String:
	if id_unidad == Maestro.ID:
		return _armador.armar(ClavesTextos.MAESTRO_NOMBRE)
	return _armador.armar(ClavesTextos.nombre_especie(_plantel.criatura(id_unidad).especie.id()))


func _linea_hambre(etiqueta: String, valor: int, sujeto: String) -> String:
	var estado: String = _estados.hambre(valor)
	return "%s: %d (%s)" % [etiqueta, valor, _armador.armar(ClavesTextos.estado_hambre(estado), {}, sujeto)]


func _ficha(id_unidad: String, posicion: Array, tribu: bool, es_maestro: bool, caida: bool, vida: int,
		vida_max: int, marcas: Array[String]) -> Dictionary:
	return {"id": id_unidad, "casilla": Vector2i(posicion[0], posicion[1]), "tribu": tribu,
			"maestro": es_maestro, "caida": caida, "nombre": nombre(id_unidad), "vida": vida, "vida_max": vida_max,
			"marcas": marcas}
