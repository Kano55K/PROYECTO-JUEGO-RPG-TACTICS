# Arquitectura.md B.2 (T13): traduce el estado del combate en lo que la vista
# dibuja, sin nodos. No calcula reglas: lee instantanea(), la cola, el Plantel
# y las consultas del nucleo (EstadosUnidad, vida_max_real, fila_balanza), y
# pide cada texto al ArmadorTextos. Se rearma en cada redibujo: no guarda estado.
# Desde la sesion 2 tambien arma los sucesos del registro, el desglose de un
# ataque y la pantalla de resultado, siempre con los numeros que da el nucleo.
class_name LecturaCombate
extends RefCounted

const _ESTADO_SUELTA: String = "suelta"
const _ESTADO_CAIDA: String = "caida"
const _ESTADO_FUERA: String = "fuera"
const _ESTADO_MUERTA: String = "muerta"
# Nombres del registro y del resultado (A.7).
const _MAESTRO_CAIDO: String = "caido"
const _DESENLACE_VICTORIA: String = "victoria"
const _TIPO_PORCENTAJE: String = "porcentaje"
const _SEPARADOR: String = " · "

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
			texto += _SEPARADOR + _armador.armar(clave_marca)
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


# T13, sesion 2: las lineas de lo nuevo del registro, desde la linea `desde`.
func sucesos(desde: int) -> Array[String]:
	var lineas: Array[String] = []
	var registro: Array[Dictionary] = _combate.registro().lineas()
	for indice in range(desde, registro.size()):
		lineas.append_array(suceso(registro[indice]))
	return lineas


# Un evento del registro (A.7) como lineas para el jugador; [] si no se muestra
# (tiradas, turnos, rondas: estan en el panel de depuracion).
func suceso(evento: Dictionary) -> Array[String]:
	match evento["tipo"]:
		"movimiento":
			return [_SEPARADOR.join([nombre(evento["unidad"]), _armador.armar(ClavesTextos.ACCION_MOVER)])]
		"ataque":
			return [_SEPARADOR.join([nombre(evento["atacante"]), _armador.armar(ClavesTextos.ACCION_ATACAR),
					"%s −%d (%d → %d)" % [nombre(evento["objetivo"]), evento["desglose"]["total"],
					evento["vida_antes"], evento["vida_despues"]]])]
		"accion":
			if evento["accion"]["tipo"] == "erizarse":
				return [_SEPARADOR.join([nombre(evento["unidad"]), _armador.armar(_clave_rasgo(evento["unidad"]))])]
		"estado":
			return _suceso_estado(evento["unidad"], evento["a"])
		"fin":
			if evento["desenlace"] == _DESENLACE_VICTORIA:
				return [_armador.armar(ClavesTextos.COMBATE_VICTORIA)]
		"cierre":
			var lineas: Array[String] = []
			for id_unidad in evento["levantadas"]:
				lineas.append(_armador.armar(ClavesTextos.CAIDA_LEVANTARSE, _hueco(id_unidad), _sujeto(id_unidad)))
			for id_unidad in evento["muertas"]:
				lineas.append(_SEPARADOR.join([nombre(id_unidad), _armador.armar(ClavesTextos.estado_unidad(_ESTADO_MUERTA))]))
			return lineas
	return []


# El desglose de Sistema.md 11.4 (DesgloseDanio.a_diccionario()) tal como viene:
# base, cada modificador con su fuente, total y si actuo el minimo.
func desglose(datos: Dictionary, atacante_id: String) -> Array[String]:
	var lineas: Array[String] = ["%s: %d" % [_armador.armar(ClavesTextos.DESGLOSE_BASE), datos["base"]]]
	for modificador in datos["modificadores"]:
		var fuente: String = _fuente(modificador, atacante_id)
		if modificador["tipo"] == _TIPO_PORCENTAJE:
			lineas.append("%s: %+d%%" % [fuente, modificador["valor"]])
		else:
			lineas.append("%s: %+d" % [fuente, modificador["valor"]])
	var total: String = "%s: %d" % [_armador.armar(ClavesTextos.DESGLOSE_TOTAL), datos["total"]]
	if datos["minimo_aplicado"]:
		total += " (%s)" % _armador.armar(ClavesTextos.DESGLOSE_MINIMO)
	lineas.append(total)
	return lineas


# La pantalla de resultado desde ResultadoCombate.a_diccionario() (A.7).
func resultado(datos: Dictionary) -> Array[String]:
	var etiqueta_vida: String = _armador.armar(ClavesTextos.PANEL_VIDA)
	var lineas: Array[String] = [
		_armador.armar(ClavesTextos.RESULTADO_TITULO),
		_armador.armar(ClavesTextos.desenlace(datos["desenlace"])),
		"%s: %d" % [_armador.armar(ClavesTextos.RESULTADO_RONDAS), datos["rondas"]],
	]
	var linea_maestro: Array[String] = [nombre(Maestro.ID), "%s: %d" % [etiqueta_vida, datos["maestro"]["vida"]]]
	if datos["maestro_caido"]:
		linea_maestro.append(_armador.armar(ClavesTextos.MARCA_CAIDA))
	lineas.append(_SEPARADOR.join(linea_maestro))
	for unidad in datos["unidades"]:
		lineas.append(_SEPARADOR.join([_armador.armar(ClavesTextos.nombre_especie(unidad["especie"])),
				_armador.armar(ClavesTextos.estado_unidad(unidad["estado"])),
				"%s: %d" % [etiqueta_vida, unidad["vida"]]]))
	if not (datos["lealtad_cambios"] as Array).is_empty():
		lineas.append(_armador.armar(ClavesTextos.RESULTADO_LEALTAD))
		for cambio in datos["lealtad_cambios"]:
			lineas.append("%s: %d → %d" % [_nombre_en_resultado(datos, cambio["id"]), cambio["antes"], cambio["despues"]])
			for anotacion in cambio["anotaciones"]:
				lineas.append("  %s: %+d" % [_armador.armar(ClavesTextos.motivo_lealtad(anotacion["motivo"])),
						anotacion["cambio"]])
	return lineas


# El boton de terminar: "esperar" si la accion no se uso (P-015), si no "terminar".
func texto_terminar() -> String:
	var turno: Turno = _combate.turno_actual()
	if turno != null and turno.accion_usada:
		return _armador.armar(ClavesTextos.ACCION_TERMINAR)
	return _armador.armar(ClavesTextos.ACCION_ESPERAR)


# Nombre y tooltip del rasgo de la unidad del turno (el boton de Erizarse).
# ["", ""] si no hay turno o es el Maestro.
func boton_rasgo() -> Array[String]:
	var turno: Turno = _combate.turno_actual()
	if turno == null or turno.unidad_id == Maestro.ID:
		return ["", ""]
	var rasgo_id: String = _plantel.criatura(turno.unidad_id).especie.rasgo()["id"]
	return [_armador.armar(ClavesTextos.nombre_rasgo(rasgo_id)), _armador.armar(ClavesTextos.tooltip_rasgo(rasgo_id))]


func _suceso_estado(id_unidad: String, estado: String) -> Array[String]:
	if id_unidad == Maestro.ID:
		if estado == _MAESTRO_CAIDO:
			return [_armador.armar(ClavesTextos.MAESTRO_CAIDA)]
		return []
	if estado == _ESTADO_CAIDA:
		# caida.* es complemento (A.2.1): la base y la linea de la especie.
		return _armador.armar_lineas(ClavesTextos.CAIDA, _hueco(id_unidad), _sujeto(id_unidad))
	if estado == _ESTADO_FUERA:
		return [_SEPARADOR.join([nombre(id_unidad), _armador.armar(ClavesTextos.MARCA_FUERA)])]
	return []


# Sistema.md 11.4: la fuente de un modificador. Hambre y rasgos tienen su texto
# en es.json; las demas fuentes, su propia clave.
func _fuente(modificador: Dictionary, atacante_id: String) -> String:
	match modificador["fuente"]:
		"hambre":
			return _armador.armar(ClavesTextos.estado_hambre(modificador["detalle"]), {}, _sujeto(atacante_id))
		"enfermedad":
			return _armador.armar(ClavesTextos.ENFERMO)
		"rasgo_atacante", "rasgo_objetivo":
			return _armador.armar(ClavesTextos.nombre_rasgo(modificador["detalle"]))
	return _armador.armar(ClavesTextos.fuente_desglose(modificador["fuente"]))


func _clave_rasgo(id_unidad: String) -> String:
	return ClavesTextos.nombre_rasgo(_plantel.criatura(id_unidad).especie.rasgo()["id"])


# El sujeto de las variantes de texto: "maestro" o el id de la especie.
func _sujeto(id_unidad: String) -> String:
	if id_unidad == Maestro.ID:
		return Maestro.ID
	return _plantel.criatura(id_unidad).especie.id()


func _hueco(id_unidad: String) -> Dictionary:
	return {"criatura": HuecoCriatura.new(_plantel.criatura(id_unidad).especie.id())}


func _nombre_en_resultado(datos: Dictionary, id_unidad: String) -> String:
	for unidad in datos["unidades"]:
		if unidad["id"] == id_unidad:
			return _armador.armar(ClavesTextos.nombre_especie(unidad["especie"]))
	return id_unidad
