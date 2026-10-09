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
# T40: los tipos de boton de activa (botones_activas).
const ACTIVA_ERIZARSE: String = "erizarse"
const ACTIVA_HACERSE_JUNCO: String = "hacerse_junco"
const ACTIVA_CAVAR: String = "cavar"

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
# {id, casilla: Vector2i, tribu: bool, maestro: bool, caida: bool, oculta: bool,
# nombre, vida, vida_max, marcas: Array[String]}. T40: las marcas suman el modo,
# oculta y el bono pendiente; las etiquetas concuerdan con la especie (A.2.1).
func fichas() -> Array[Dictionary]:
	var lista: Array[Dictionary] = []
	var foto: Dictionary = _combate.instantanea()
	var foto_maestro: Dictionary = foto["maestro"]
	if foto_maestro["posicion"] != null:
		var marcas_maestro: Array[String] = []
		if foto_maestro["caido"]:
			marcas_maestro.append(_armador.armar(ClavesTextos.MARCA_CAIDA, {}, Maestro.ID))
		var ficha_maestro: Dictionary = _ficha(Maestro.ID, foto_maestro["posicion"], true, true, foto_maestro["caido"],
				foto_maestro["vida"], _plantel.maestro.vida_max_real(), marcas_maestro)
		lista.append(ficha_maestro)
	for foto_criatura in foto["criaturas"]:
		var estado: String = foto_criatura["estado"]
		if foto_criatura["posicion"] == null or not estado in [_ESTADO_SUELTA, _ESTADO_CAIDA]:
			continue
		var criatura: Criatura = _plantel.criatura(foto_criatura["id"])
		var marcas: Array[String] = []
		if estado == _ESTADO_CAIDA:
			marcas.append(_armador.armar(ClavesTextos.MARCA_CAIDA, {}, criatura.especie.id()))
		marcas.append_array(_marcas_rasgo(foto_criatura))
		marcas.append_array(_marcas_turno(criatura.id))
		# T19: en la ficha, el contador solo cuando ya subio.
		var linea_encono: String = _linea_encono(foto_criatura)
		if (foto_criatura["encono"] as int) > 0 and not linea_encono.is_empty():
			marcas.append(linea_encono)
		var ficha: Dictionary = _ficha(criatura.id, foto_criatura["posicion"], criatura.bando == Criatura.Bando.TRIBU,
				false, estado == _ESTADO_CAIDA, foto_criatura["vida"], criatura.vida_max_real(), marcas)
		ficha["oculta"] = foto_criatura["oculta"]
		lista.append(ficha)
	return lista


# T40: lo que el rasgo deja a la vista (Sistema.md 11.2.2, 11.2.3): el modo,
# erizada, oculta y el bono pendiente, tal como vienen en la instantanea.
func _marcas_rasgo(foto_criatura: Dictionary) -> Array[String]:
	var marcas: Array[String] = []
	if foto_criatura["modo"] != null:
		marcas.append(_armador.armar(ClavesTextos.modo(foto_criatura["modo"])))
	if foto_criatura["erizada"]:
		marcas.append(_armador.armar(ClavesTextos.MARCA_ERIZADA))
	if foto_criatura["oculta"]:
		marcas.append(_armador.armar(ClavesTextos.MARCA_OCULTO))
	if foto_criatura["bono_junco"]:
		marcas.append(_armador.armar(ClavesTextos.MARCA_BONO))
	return marcas


# T19 (Sistema.md 10.5 y 10.6): enconada o acobardada, solo en su turno (los
# estados viven en el Turno). Concuerdan con la especie (A.2.1).
func _marcas_turno(id_unidad: String) -> Array[String]:
	var marcas: Array[String] = []
	var turno: Turno = _combate.turno_actual()
	if turno == null or turno.unidad_id != id_unidad:
		return marcas
	if turno.enconada:
		marcas.append(marca_estado(id_unidad, ChequeoRival.RESULTADO_ENCONADA))
	if turno.acobardada:
		marcas.append(marca_estado(id_unidad, ChequeoRival.RESULTADO_ACOBARDADA))
	return marcas


# T20: la marca de un estado del chequeo de rival (ChequeoRival.RESULTADO_ENCONADA o
# RESULTADO_ACOBARDADA), con la especie como sujeto. La usan las marcas del turno
# y, durante la secuencia de la IA, la ficha de una enemiga (SecuenciaIA). Otro
# resultado: "".
func marca_estado(id_unidad: String, estado: String) -> String:
	match estado:
		ChequeoRival.RESULTADO_ENCONADA:
			return _armador.armar(ClavesTextos.MARCA_ENCONADA, {}, _sujeto(id_unidad))
		ChequeoRival.RESULTADO_ACOBARDADA:
			return _armador.armar(ClavesTextos.MARCA_ACOBARDADA, {}, _sujeto(id_unidad))
	return ""


# T19 (Sistema.md 10.5): el contador del Encono, "Encono: n/max", con el tope que
# da el nucleo (ChequeoRival.maximo_encono). "" si la criatura es de cobardia.
func _linea_encono(foto_criatura: Dictionary) -> String:
	var criatura: Criatura = _plantel.criatura(foto_criatura["id"])
	if ChequeoRival.tipo(criatura) != ChequeoRival.TIPO_ENCONO:
		return ""
	return "%s: %d/%d" % [_armador.armar(ClavesTextos.PANEL_ENCONO), foto_criatura["encono"] as int,
			_combate.contexto().chequeo_rival.maximo_encono()]


# Una fila por entrada de la cola de la ronda, en orden:
# {unidad_id, marca, texto, actual: bool, actuo: bool}.
func filas_cola() -> Array[Dictionary]:
	var actual: int = _combate.entrada_actual()
	var entradas: Array[EntradaCola] = _combate.cola()
	var filas: Array[Dictionary] = []
	for i in range(entradas.size()):
		filas.append(_fila_cola(entradas[i], i == actual, entradas[i].actuo))
	return filas


# T17 (Sistema.md 10.1): las filas de la cola como quedaria si la unidad del
# turno Secundara a la aliada (Turno.cola_si_secunda: el nucleo hace la cuenta).
# La unidad del turno va como actual en su lugar nuevo. [] si no vale.
func filas_cola_si_secunda(aliado_id: String) -> Array[Dictionary]:
	var filas: Array[Dictionary] = []
	var turno: Turno = _combate.turno_actual()
	if turno == null:
		return filas
	for entrada in turno.cola_si_secunda(aliado_id):
		var es_la_del_turno: bool = entrada.unidad_id == turno.unidad_id
		filas.append(_fila_cola(entrada, es_la_del_turno, entrada.actuo and not es_la_del_turno))
	return filas


func _fila_cola(entrada: EntradaCola, actual: bool, actuo: bool) -> Dictionary:
	var texto: String = nombre(entrada.unidad_id)
	var clave_marca: String = ClavesTextos.marca_cola(entrada.marca)
	if not clave_marca.is_empty():
		texto += _SEPARADOR + _armador.armar(clave_marca)
	return {"unidad_id": entrada.unidad_id, "marca": entrada.marca, "texto": texto, "actual": actual,
			"actuo": actuo}


# T17: el boton de Secundar {texto}, o {} si no hay ninguna aliada a
# la que se pueda Secundar ahora (Turno.aliadas_para_secundar).
func boton_secundar() -> Dictionary:
	var turno: Turno = _combate.turno_actual()
	if turno == null or turno.aliadas_para_secundar().is_empty():
		return {}
	return {"texto": _armador.armar(ClavesTextos.ACCION_SECUNDAR)}


func titulo_cola() -> String:
	return _armador.armar(ClavesTextos.COLA_TITULO)


func texto_ronda() -> String:
	return _armador.armar(ClavesTextos.RONDA, {"n": _combate.instantanea()["ronda"]})


# Lineas del panel de la unidad del turno: nombre, vida y, si los tiene,
# lealtad y hambre con su estado; al final, la cadena en curso y (T19) por que no
# puede terminar el turno, si es por el Encono. Vacio si no hay turno.
func panel_turno() -> Array[String]:
	var turno: Turno = _combate.turno_actual()
	if turno == null:
		return []
	var lineas: Array[String] = _panel_unidad(turno.unidad_id)
	var cadena: Variant = _combate.instantanea()["cadena"]
	if cadena != null:
		lineas.append(_linea_cadena(cadena))
	var motivo: String = boton_terminar()["motivo"]
	if not motivo.is_empty():
		lineas.append(motivo)
	return lineas


# T16 (Sistema.md 10.2): la cadena tal como la da el nucleo: la objetivo y el
# eslabon al que llego (el desglose del mouse muestra el bono del siguiente).
func _linea_cadena(cadena: Dictionary) -> String:
	return "%s: %s (%d)" % [_armador.armar(ClavesTextos.PANEL_CADENA), nombre(cadena["objetivo"]),
			cadena["eslabon"]]


func _panel_unidad(id_unidad: String) -> Array[String]:
	var lineas: Array[String] = [nombre(id_unidad)]
	var etiqueta_vida: String = _armador.armar(ClavesTextos.PANEL_VIDA)
	var etiqueta_hambre: String = _armador.armar(ClavesTextos.PANEL_HAMBRE)
	if id_unidad == Maestro.ID:
		var maestro: Maestro = _plantel.maestro
		lineas.append("%s: %d/%d" % [etiqueta_vida, maestro.vida, maestro.vida_max_real()])
		lineas.append(_linea_mana(maestro.mana))
		lineas.append(_linea_hambre(etiqueta_hambre, maestro.hambre, Maestro.ID))
		return lineas
	var criatura: Criatura = _plantel.criatura(id_unidad)
	lineas.append("%s: %d/%d" % [etiqueta_vida, criatura.vida, criatura.vida_max_real()])
	# Las enemigas no tienen lealtad ni hambre en el escenario (S-17).
	if criatura.bando == Criatura.Bando.TRIBU:
		var umbral: int = _plantel.maestro.fila_balanza()["umbral_rescate"]
		var estado_lealtad: String = _estados.lealtad(criatura.lealtad, umbral)
		lineas.append("%s: %d (%s)" % [_armador.armar(ClavesTextos.PANEL_LEALTAD), criatura.lealtad,
				_armador.armar(ClavesTextos.estado_lealtad(estado_lealtad), {}, criatura.especie.id())])
		lineas.append(_linea_obediencia(criatura))
		lineas.append(_linea_hambre(etiqueta_hambre, criatura.hambre, criatura.especie.id()))
	return lineas


# T21 (Sistema.md 2.1): el mana del Maestro, actual/tope. El tope es el mana con
# el que entro (Maestro.mana_entrada), tal como lo resolvio el nucleo.
func _linea_mana(actual: int) -> String:
	return "%s: %d/%d" % [_armador.armar(ClavesTextos.PANEL_MANA), actual, _plantel.maestro.mana_entrada]


# T14 (Sistema.md 5.4): la obediencia de una criatura de la tribu, numero y
# tramo, tal como la da el nucleo (Obediencia: se pregunta cada vez).
func _linea_obediencia(criatura: Criatura) -> String:
	var obediencia: Obediencia = _combate.contexto().obediencia
	var tramo: String = obediencia.tramo(criatura, _plantel.maestro)
	return "%s: %d (%s)" % [_armador.armar(ClavesTextos.PANEL_OBEDIENCIA), obediencia.valor(criatura) as int,
			_armador.armar(ClavesTextos.tramo_obediencia(tramo))]


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
			"maestro": es_maestro, "caida": caida, "oculta": false, "nombre": nombre(id_unidad), "vida": vida,
			"vida_max": vida_max, "marcas": marcas}


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
				lineas.append(_SEPARADOR.join([nombre(id_unidad),
						_armador.armar(ClavesTextos.estado_unidad(_ESTADO_MUERTA), {}, _sujeto(id_unidad))]))
			return lineas
		# T40: los eventos de los rasgos de la v1.3 (A.7), una linea cada uno.
		"surco":
			return [_armador.armar(ClavesTextos.SUCESO_SURCO_CAVAR)]
		"surco_cerrado":
			return [_armador.armar(ClavesTextos.SUCESO_SURCO_CERRAR)]
		"oculto":
			return [_armador.armar(ClavesTextos.SUCESO_OCULTO)]
		"destape":
			return [_armador.armar(ClavesTextos.suceso_destape(evento["motivo"]))]
		"bono_perdido":
			return [_armador.armar(ClavesTextos.SUCESO_PIERDE_BONO)]
		"cambio_modo":
			return [_armador.armar(ClavesTextos.suceso_cambio(evento["a"]))]
		"hambre_combate":
			return _suceso_hambre_combate(evento["cambios"])
		# T17 (Sistema.md 10.1): quien Secundo y detras de quien.
		"secundar":
			return [_SEPARADOR.join([nombre(evento["unidad"]), _armador.armar(ClavesTextos.ACCION_SECUNDAR),
					nombre(evento["detras_de"])])]
		# T18 (Sistema.md 10.4): con la rival golpeada o, si se distrajo, la
		# primera de sus rivales. El par de especies elige la variante.
		"incidente":
			var rival: String = evento["rivales"][0] if evento["objetivo"] == null else evento["objetivo"]
			var clave: String = ClavesTextos.INCIDENTE_DISTRAIDA if evento["objetivo"] == null \
					else ClavesTextos.INCIDENTE_ATAQUE
			var datos: Dictionary = _hueco(evento["unidad"])
			datos["rival"] = HuecoCriatura.new(_sujeto(rival))
			return [_armador.armar(clave, datos, "%s.%s" % [_sujeto(evento["unidad"]), _sujeto(rival)])]
		"chequeo_rival":
			return _suceso_chequeo_rival(evento)
		# T19 (Sistema.md 10.5): el contador subio.
		"encono":
			return [_armador.armar(ClavesTextos.ENCONO_SUBE, _hueco(evento["unidad"]))]
	return []


# T19 (Sistema.md 10.5 y 10.6, Mundo.md 5), con la primera de sus rivales. La
# reaccion del par (Encono) o de la especie (cobardia) reemplaza a la linea
# general; resistir usa la variante de la especie. No enconarse no tiene linea.
func _suceso_chequeo_rival(evento: Dictionary) -> Array[String]:
	var unidad: String = evento["unidad"]
	var rival: String = evento["rivales"][0]
	var datos: Dictionary = _hueco(unidad)
	datos["rival"] = HuecoCriatura.new(_sujeto(rival))
	var clave: String = ""
	match evento["resultado"]:
		ChequeoRival.RESULTADO_ENCONADA:
			clave = ClavesTextos.encono_par(_sujeto(unidad), _sujeto(rival))
			if not _armador.tiene(clave):
				clave = ClavesTextos.ENCONO_INICIO
		ChequeoRival.RESULTADO_ACOBARDADA:
			clave = ClavesTextos.cobardia_especie(_sujeto(unidad))
			if not _armador.tiene(clave):
				clave = ClavesTextos.COBARDIA_INICIO
		ChequeoRival.RESULTADO_RESISTIDA:
			return [_armador.armar(ClavesTextos.COBARDIA_RESISTE, datos, _sujeto(unidad))]
		_:
			return []
	return [_armador.armar(clave, datos)]


# T14 (Sistema.md 7.2, A.7): la linea del hambre de combate y, por cada unidad
# cuyo estado de hambre cambio, su nombre y el estado nuevo (con su sujeto).
func _suceso_hambre_combate(cambios: Array) -> Array[String]:
	var lineas: Array[String] = [_armador.armar(ClavesTextos.COMBATE_HAMBRE)]
	for cambio in cambios:
		var estado: String = _estados.hambre(cambio["a"])
		if estado != _estados.hambre(cambio["de"]):
			lineas.append(_SEPARADOR.join([nombre(cambio["unidad"]),
					_armador.armar(ClavesTextos.estado_hambre(estado), {}, _sujeto(cambio["unidad"]))]))
	return lineas


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
		linea_maestro.append(_armador.armar(ClavesTextos.MARCA_CAIDA, {}, Maestro.ID))
	lineas.append(_SEPARADOR.join(linea_maestro))
	for unidad in datos["unidades"]:
		lineas.append(_SEPARADOR.join([_armador.armar(ClavesTextos.nombre_especie(unidad["especie"])),
				_armador.armar(ClavesTextos.estado_unidad(unidad["estado"]), {}, unidad["especie"]),
				"%s: %d" % [etiqueta_vida, unidad["vida"]]]))
	if not (datos["lealtad_cambios"] as Array).is_empty():
		lineas.append(_armador.armar(ClavesTextos.RESULTADO_LEALTAD))
		for cambio in datos["lealtad_cambios"]:
			lineas.append("%s: %d → %d" % [_nombre_en_resultado(datos, cambio["id"]), cambio["antes"], cambio["despues"]])
			for anotacion in cambio["anotaciones"]:
				lineas.append("  %s: %+d" % [_armador.armar(ClavesTextos.motivo_lealtad(anotacion["motivo"])),
						anotacion["cambio"]])
	return lineas


# El boton de terminar {texto, habilitado, motivo}: "esperar" si la accion no se
# uso (P-015), si no "terminar". T19: habilitado segun Turno.puede_terminar; si
# una obligacion del Encono no lo deja (S-35), motivo dice por que; si no, "".
func boton_terminar() -> Dictionary:
	var turno: Turno = _combate.turno_actual()
	var clave: String = ClavesTextos.ACCION_TERMINAR if turno != null and turno.accion_usada \
			else ClavesTextos.ACCION_ESPERAR
	var datos: Dictionary = {"texto": _armador.armar(clave), "habilitado": turno != null and turno.puede_terminar(),
			"motivo": ""}
	if turno != null and not datos["habilitado"]:
		var clave_motivo: String = ClavesTextos.motivo_terminar(turno.validar(Accion.terminar()).motivo)
		if not clave_motivo.is_empty():
			datos["motivo"] = _armador.armar(clave_motivo)
	return datos


# T40: los botones de las activas de la unidad del turno, [{tipo, texto,
# tooltip, habilitado}]. Que botones hay lo dice el efecto del rasgo de la ficha
# (nunca el id); si se pueden usar ahora, las consultas del Turno. Vacio si no
# hay turno o es el Maestro.
func botones_activas() -> Array[Dictionary]:
	var botones: Array[Dictionary] = []
	var turno: Turno = _combate.turno_actual()
	if turno == null or turno.unidad_id == Maestro.ID:
		return botones
	var rasgo: Dictionary = _plantel.criatura(turno.unidad_id).especie.rasgo()
	var nombre_rasgo: String = _armador.armar(ClavesTextos.nombre_rasgo(rasgo["id"]))
	var tooltip: String = _armador.armar(ClavesTextos.tooltip_rasgo(rasgo["id"]))
	match rasgo["efecto"]:
		Turno.EFECTO_ERIZARSE:
			botones.append(_boton(ACTIVA_ERIZARSE, nombre_rasgo, tooltip, turno.puede_erizarse()))
		Junco.EFECTO:
			botones.append(_boton(ACTIVA_HACERSE_JUNCO, nombre_rasgo, tooltip,
					turno.validar(Accion.hacerse_junco()).valida))
		Surcos.EFECTO:
			# Arquitectura.md 10.5: el boton de cavar tiene su clave propia.
			botones.append(_boton(ACTIVA_CAVAR, _armador.armar(ClavesTextos.ACCION_CAVAR), tooltip,
					not turno.casillas_para_cavar().is_empty()))
	return botones


func _boton(tipo: String, texto: String, tooltip: String, habilitado: bool) -> Dictionary:
	return {"tipo": tipo, "texto": texto, "tooltip": tooltip, "habilitado": habilitado}


# T40: el tooltip de cualquier unidad en el tablero, propia o enemiga: nombre,
# vida, rasgo (nombre y texto) y el estado del rasgo (Vision 6.2, Sistema.md
# 11.2.1 a 11.2.3). Todo sale de la instantanea y de consultas del nucleo.
func tooltip_unidad(id_unidad: String) -> Array[String]:
	var foto: Dictionary = _combate.instantanea()
	var etiqueta_vida: String = _armador.armar(ClavesTextos.PANEL_VIDA)
	if id_unidad == Maestro.ID:
		return [nombre(Maestro.ID), "%s: %d/%d" % [etiqueta_vida, foto["maestro"]["vida"],
				_plantel.maestro.vida_max_real()], _linea_mana(foto["maestro"]["mana"])]
	var criatura: Criatura = _plantel.criatura(id_unidad)
	var foto_criatura: Dictionary = {}
	for entrada in foto["criaturas"]:
		if entrada["id"] == id_unidad:
			foto_criatura = entrada
	var rasgo: Dictionary = criatura.especie.rasgo()
	var lineas: Array[String] = [nombre(id_unidad),
			"%s: %d/%d" % [etiqueta_vida, foto_criatura["vida"], criatura.vida_max_real()]]
	# T14: solo la tribu tiene obediencia propia (Sistema.md 5.4 y 10.7).
	if criatura.bando == Criatura.Bando.TRIBU:
		lineas.append(_linea_obediencia(criatura))
	lineas.append(_armador.armar(ClavesTextos.nombre_rasgo(rasgo["id"])))
	lineas.append(_armador.armar(ClavesTextos.tooltip_rasgo(rasgo["id"])))
	lineas.append_array(_marcas_rasgo(foto_criatura))
	lineas.append_array(_marcas_turno(id_unidad))
	# T19 (Sistema.md 10.5): el contador, tambien en 0, en las de Encono.
	var linea_encono: String = _linea_encono(foto_criatura)
	if not linea_encono.is_empty():
		lineas.append(linea_encono)
	# T20 (Sistema.md 10.5 a 10.7): una enemiga, el % del chequeo que tiraria si
	# empezara su turno ahora (Combate.rival_en en su casilla). Con 0 %, nada.
	if criatura.bando != Criatura.Bando.TRIBU and Objetivos.de_pie(id_unidad, _plantel):
		var rival: Dictionary = _combate.rival_en(id_unidad, criatura.posicion)
		if rival["porcentaje"] > 0:
			var clave_rival: String = ClavesTextos.ENCONO_TOOLTIP \
					if rival["tipo"] == ChequeoRival.TIPO_ENCONO else ClavesTextos.COBARDIA_TOOLTIP
			lineas.append(_armador.armar(clave_rival, {"porcentaje": rival["porcentaje"]}, _sujeto(id_unidad)))
	# Sistema.md 11.2.3: "el umbral se muestra sobre la unidad".
	var vida_de_cambio: Variant = _combate.vida_de_cambio(id_unidad)
	if vida_de_cambio != null:
		lineas.append(_armador.armar(ClavesTextos.AVISO_CUENTA_UMBRAL, {"n": vida_de_cambio}))
	# Sistema.md 11.2.1, Tope: sus surcos contra el tope de la ficha.
	if Surcos.es_surcon(id_unidad, _plantel):
		var propios: int = 0
		for surco in foto["surcos"]:
			if surco["duenio"] == id_unidad:
				propios += 1
		lineas.append("%s: %d/%d" % [_armador.armar(ClavesTextos.nombre_rasgo(rasgo["id"])), propios, rasgo["tope"]])
	return lineas


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
		# T40 (Arquitectura.md 10.5): el modo se nombra como en la cola.
		"modo":
			return _armador.armar(ClavesTextos.modo(modificador["detalle"]))
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
