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
# A.7: el tipo de la accion `hechizo` en el registro.
const _ACCION_HECHIZO: String = "hechizo"
# A.7 (T24): el tipo de la accion `sellar` en el registro.
const _ACCION_SELLAR: String = "sellar"
const _ACCION_GUARDAR: String = "guardar"
# A.7 (T27): el tipo de la accion `guardar_caida` en el registro.
const _ACCION_GUARDAR_CAIDA: String = "guardar_caida"
# T27 (Mundo.md 5): el hueco de rol del suceso guardar_caida ({caida}, {caida_la}).
const _HUECO_CAIDA: String = "caida"
# A.7 (T28): el tipo de la accion `huir` en el registro.
const _ACCION_HUIR: String = "huir"

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
	var rescatista: Variant = _rescatista_a_la_vista()
	if foto_maestro["posicion"] != null:
		var marcas_maestro: Array[String] = []
		if foto_maestro["caido"]:
			marcas_maestro.append(_armador.armar(ClavesTextos.MARCA_CAIDA, {}, Maestro.ID))
		# T28 (Sistema.md 11.7): declaro la huida y se va al cerrar la ronda.
		if foto_maestro["huida_declarada"]:
			marcas_maestro.append(_armador.armar(ClavesTextos.MARCA_HUIDA_DECLARADA))
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
		# T24 (Sistema.md 4.1): el % de sellado sobre la salvaje (Combate.porcentaje_sellado).
		var porcentaje: Variant = _combate.porcentaje_sellado(criatura.id)
		if porcentaje != null:
			marcas.append(marca_sellado(porcentaje))
		# T25 (Sistema.md 11.7, "la probabilidad se muestra sobre la unidad"): el % de
		# huida de Combate.porcentaje_huida, solo si es mayor que 0.
		var huida: int = _combate.porcentaje_huida(criatura.id)
		if huida > 0:
			marcas.append(marca_huida(huida))
		# T29 (Sistema.md 6): quien rescataria ahora (Combate.rescatista_ahora).
		if rescatista != null and criatura.id == rescatista:
			marcas.append(_armador.armar(ClavesTextos.MARCA_RESCATISTA, {}, criatura.especie.id()))
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
	# T28 (Sistema.md 11.7): con la huida declarada, que se va al cerrar la ronda.
	if _combate.instantanea()["maestro"]["huida_declarada"]:
		lineas.append(_armador.armar(ClavesTextos.PANEL_HUIDA_DECLARADA))
	var rescate: String = linea_rescatista()
	if not rescate.is_empty():
		lineas.append(rescate)
	var motivo: String = boton_terminar()["motivo"]
	if not motivo.is_empty():
		lineas.append(motivo)
	return lineas


# T29 (Sistema.md 6, Vision 6.6): la linea fija de quien rescataria si el Maestro
# cayera ahora (Combate.rescatista_ahora), solo en el turno del jugador: "Te
# rescataria: <nombre>" (el nombre se ve aunque falte la clave) o "Nadie te
# rescataria". Fuera del turno del jugador, "".
func linea_rescatista() -> String:
	if not _combate.esperando_jugador():
		return ""
	var rescatista: Variant = _combate.rescatista_ahora()
	if rescatista == null:
		return _armador.armar(ClavesTextos.PANEL_SIN_RESCATISTA)
	return "%s: %s" % [_armador.armar(ClavesTextos.PANEL_RESCATISTA), nombre(rescatista)]


# T29: el id de quien rescataria, solo en el turno del jugador; si no, null.
func _rescatista_a_la_vista() -> Variant:
	if not _combate.esperando_jugador():
		return null
	return _combate.rescatista_ahora()


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
			return [_linea_ataque(evento)]
		# T30 (Sistema.md 9.2, Mundo.md 4.6): el despertar (base y la linea de la
		# especie, complemento) y el golpe con sus numeros.
		"golpe_inicial":
			var lineas_golpe: Array[String] = _armador.armar_lineas(ClavesTextos.NOCTURNO_BASE,
					_hueco(evento["atacante"]), _sujeto(evento["atacante"]))
			lineas_golpe.append(_linea_ataque(evento))
			return lineas_golpe
		"destino_atacante":
			return lineas_destino(evento)
		"accion":
			if evento["accion"]["tipo"] == "erizarse":
				return [_SEPARADOR.join([nombre(evento["unidad"]), _armador.armar(_clave_rasgo(evento["unidad"]))])]
			# T22: el hechizo se nombra antes de su ataque, lanzadera o remiendo.
			if evento["accion"]["tipo"] == _ACCION_HECHIZO:
				return [_SEPARADOR.join([nombre(evento["unidad"]),
						_armador.armar(ClavesTextos.nombre_hechizo(evento["accion"]["hechizo"]))])]
			# T24: quien sella, antes de su `sellado`.
			if evento["accion"]["tipo"] == _ACCION_SELLAR:
				return [_SEPARADOR.join([nombre(evento["unidad"]), _armador.armar(ClavesTextos.ACCION_SELLAR)])]
			# T26 (Sistema.md 3.1): la criatura que se guarda, con su hueco.
			if evento["accion"]["tipo"] == _ACCION_GUARDAR:
				return [_armador.armar(ClavesTextos.GUARDAR, _hueco(evento["unidad"]), _sujeto(evento["unidad"]))]
			# T27: el Maestro nombra la accion antes de su `guardado_caida`.
			if evento["accion"]["tipo"] == _ACCION_GUARDAR_CAIDA:
				return [_SEPARADOR.join([nombre(evento["unidad"]), _armador.armar(ClavesTextos.ACCION_GUARDAR_CAIDA)])]
			# T28 (Sistema.md 11.7, Mundo.md 9): el Maestro declara la huida.
			if evento["accion"]["tipo"] == _ACCION_HUIR:
				return [_armador.armar(ClavesTextos.HUIDA_MAESTRO_DECLARAR)]
		# T26: la invocada, cuando ya esta en el tablero.
		"invocacion":
			return [_armador.armar(ClavesTextos.INVOCAR, _hueco(evento["unidad"]), _sujeto(evento["unidad"]))]
		# T27 (Sistema.md 11.5): la caida que el Maestro guardo, con el hueco {caida}.
		"guardado_caida":
			return [_armador.armar(ClavesTextos.GUARDAR_CAIDA, {_HUECO_CAIDA: HuecoCriatura.new(
					_plantel.criatura(evento["unidad"]).especie.id())}, _sujeto(evento["unidad"]))]
		"sellado":
			return [_suceso_sellado(evento)]
		"huida":
			return _suceso_huida(evento)
		"lanzadera":
			return [_suceso_lanzadera(evento)]
		# T22 (Sistema.md 1.6): la vida de la curada, de -> a.
		"remiendo":
			return [_SEPARADOR.join([nombre(evento["objetivo"]), _linea_vida(evento["de"], evento["a"])])]
		"estado":
			return _suceso_estado(evento["unidad"], evento["a"])
		"fin":
			if evento["desenlace"] == _DESENLACE_VICTORIA:
				return [_armador.armar(ClavesTextos.COMBATE_VICTORIA)]
		"cierre":
			var lineas: Array[String] = _sucesos_huida_maestro(evento)
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


# "Atacante · Atacar · Objetivo −danio (antes → despues)", con los numeros del
# evento (`ataque` o `golpe_inicial`, A.7).
func _linea_ataque(evento: Dictionary) -> String:
	return _SEPARADOR.join([nombre(evento["atacante"]), _armador.armar(ClavesTextos.ACCION_ATACAR),
			"%s −%d (%d → %d)" % [nombre(evento["objetivo"]), evento["desglose"]["total"],
			evento["vida_antes"], evento["vida_despues"]]])


# T30 (Sistema.md 9.3 y 4.4, Mundo.md 4.6): las lineas de una salida del destino
# (evento `destino_atacante`): perdonada, la de perdonar y la de la tribu;
# sellada, la del nuevo sello; comida, la de comer y la de cada especie suelta de
# la tribu que tenga su clave (comer_suelta); sellado fallido, la del sellado en
# combate (4.6 no tiene una propia).
func lineas_destino(evento: Dictionary) -> Array[String]:
	var atacante: String = evento["atacante"]
	match evento["resultado"]:
		DestinoAtacante.RESULTADO_PERDONADA:
			return [_armador.armar(ClavesTextos.NOCTURNO_PERDONAR, _hueco(atacante)),
					_armador.armar(ClavesTextos.NOCTURNO_PERDONAR_TRIBU)]
		DestinoAtacante.RESULTADO_SELLADA:
			return [_armador.armar(ClavesTextos.NOCTURNO_SELLAR, _hueco(atacante))]
		DestinoAtacante.RESULTADO_COMIDA:
			var lineas: Array[String] = [_armador.armar(ClavesTextos.NOCTURNO_COMER, _hueco(atacante))]
			var vistas: Array[String] = []
			for criatura in _plantel.criaturas():
				var clave: String = ClavesTextos.comer_suelta(criatura.especie.id())
				if criatura.bando == Criatura.Bando.TRIBU and criatura.estado == Criatura.Estado.SUELTA \
						and not vistas.has(clave) and _armador.tiene(clave):
					vistas.append(clave)
					lineas.append(_armador.armar(clave))
			return lineas
		DestinoAtacante.RESULTADO_SELLADO_FALLIDO:
			return [_armador.armar(ClavesTextos.SELLAR_FALLO, _hueco(atacante), _sujeto(atacante))]
	return []


# T30 (Sistema.md 9.3 y 4.4): los botones del destino de la atacante, [{opcion,
# texto, tooltip, habilitado}] en el orden de DestinoAtacante.OPCIONES, solo si el
# combate espera el destino. Si ya fallo un sellado, sellar no esta (quedan
# perdonar y comer). Sellar lleva el costo y el % que da la regla; habilitado y el
# motivo del tooltip salen de Combate.motivo_destino.
func botones_destino() -> Array[Dictionary]:
	var botones: Array[Dictionary] = []
	if not _combate.esperando_destino():
		return botones
	var regla: DestinoAtacante = _combate.contexto().destino_atacante
	var especie: Especie = _plantel.criatura(_combate.resultado().atacante_pendiente).especie
	for opcion in DestinoAtacante.OPCIONES:
		var motivo: ResultadoAccion.Motivo = _combate.motivo_destino(opcion)
		if motivo == ResultadoAccion.Motivo.SELLAR_YA_FALLO:
			continue
		var texto: String = _armador.armar(ClavesTextos.boton_destino(opcion))
		if opcion == DestinoAtacante.OPCION_SELLAR:
			texto += " (%d %s · %d%%)" % [regla.costo(especie, _plantel.maestro), _armador.armar(ClavesTextos.PANEL_MANA),
					regla.porcentaje(especie)]
		var tooltip: Array[String] = [_armador.armar(ClavesTextos.tooltip_destino(opcion))]
		var clave_motivo: String = ClavesTextos.motivo_destino(motivo)
		if not clave_motivo.is_empty():
			tooltip.append(_armador.armar(clave_motivo))
		botones.append({"opcion": opcion, "texto": texto, "tooltip": "\n".join(tooltip),
				"habilitado": motivo == ResultadoAccion.Motivo.NINGUNO})
	return botones


# T30-fix: los eventos `destino_atacante` del registro, en orden (un sellado
# fallido y, si ya se eligio, la salida que cerro la noche).
func _eventos_destino() -> Array[Dictionary]:
	var eventos: Array[Dictionary] = []
	for evento in _combate.registro().lineas():
		if evento["tipo"] == "destino_atacante":
			eventos.append(evento)
	return eventos


# T19 (Sistema.md 10.5 y 10.6, Mundo.md 5), con la primera de sus rivales. La
# reaccion del par (Encono) o de la especie (cobardia) reemplaza a la linea
# general; resistir usa la variante de la especie. No enconarse no tiene linea.
# T44 (A.7, Mundo.md 9.2 v1.3): la resistida dice quien la sostuvo segun el
# evento (sostenida_por y afin, P-041); sin la clave (o null), la general.
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
			clave = ClavesTextos.COBARDIA_RESISTE
			match evento.get("sostenida_por"):
				ChequeoRival.SOSTENIDA_MAESTRO:
					clave = ClavesTextos.COBARDIA_RESISTE_MAESTRO
				ChequeoRival.SOSTENIDA_AFIN:
					clave = ClavesTextos.COBARDIA_RESISTE_AFIN
					datos["afin"] = HuecoCriatura.new(_sujeto(evento["afin"]))
			return [_armador.armar(clave, datos, _sujeto(unidad))]
		_:
			return []
	return [_armador.armar(clave, datos)]


# T22 (Sistema.md 1.6, A.7): sin choque, la movida se mueve; con choque, la
# linea segun contra quien fue (P-042: una criatura, el Maestro, o null si fue
# el borde o un surco), con el danio y la vida que da el evento.
func _suceso_lanzadera(evento: Dictionary) -> String:
	var objetivo: String = evento["objetivo"]
	if not evento["choque"]:
		return _SEPARADOR.join([nombre(objetivo), _armador.armar(ClavesTextos.ACCION_MOVER)])
	var datos: Dictionary = {"unidad": HuecoCriatura.new(_sujeto(objetivo))}
	var contra: Variant = evento.get("contra")
	var linea: String
	if contra == null:
		linea = _armador.armar(ClavesTextos.LANZADERA_CHOQUE_OBSTACULO, datos)
	elif contra == Maestro.ID:
		linea = _armador.armar(ClavesTextos.LANZADERA_CHOQUE_MAESTRO, datos)
	else:
		datos["otra"] = HuecoCriatura.new(_sujeto(contra))
		linea = _armador.armar(ClavesTextos.LANZADERA_CHOQUE, datos, _sujeto(objetivo))
	return "%s (−%d · %s)" % [linea, evento["danio"], _linea_vida(evento["vida_antes"], evento["vida_despues"])]


# "Vida: antes → despues", con los numeros que da el nucleo.
func _linea_vida(antes: int, despues: int) -> String:
	return "%s: %d → %d" % [_armador.armar(ClavesTextos.PANEL_VIDA), antes, despues]


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


# La pantalla de resultado desde ResultadoCombate.a_diccionario() (A.7). T29: con
# la rescatista (y su linea de Mundo.md 9) o permadeath, las muertas con su causa
# (metrica 11), las levantadas, las caidas guardadas (metrica 10), las capturas y
# la atacante pendiente. Un bloque sin nada no se muestra.
func resultado(datos: Dictionary) -> Array[String]:
	var etiqueta_vida: String = _armador.armar(ClavesTextos.PANEL_VIDA)
	var lineas: Array[String] = [
		_armador.armar(ClavesTextos.RESULTADO_TITULO),
		_armador.armar(ClavesTextos.desenlace(datos["desenlace"])),
	]
	if datos.get("rescatista") != null:
		var especie: String = _especie_en_resultado(datos, datos["rescatista"])
		lineas.append("%s: %s" % [_armador.armar(ClavesTextos.RESULTADO_RESCATISTA),
				_nombre_en_resultado(datos, datos["rescatista"])])
		lineas.append(_armador.armar(ClavesTextos.RESCATE, {"criatura": HuecoCriatura.new(especie)}, especie))
	if datos.get("permadeath", false):
		lineas.append(_armador.armar(ClavesTextos.PERMADEATH))
	lineas.append("%s: %d" % [_armador.armar(ClavesTextos.RESULTADO_RONDAS), datos["rondas"]])
	var linea_maestro: Array[String] = [nombre(Maestro.ID), "%s: %d" % [etiqueta_vida, datos["maestro"]["vida"]]]
	if datos["maestro_caido"]:
		linea_maestro.append(_armador.armar(ClavesTextos.MARCA_CAIDA, {}, Maestro.ID))
	lineas.append(_SEPARADOR.join(linea_maestro))
	for unidad in datos["unidades"]:
		lineas.append(_SEPARADOR.join([_armador.armar(ClavesTextos.nombre_especie(unidad["especie"])),
				_armador.armar(ClavesTextos.estado_unidad(unidad["estado"]), {}, unidad["especie"]),
				"%s: %d" % [etiqueta_vida, unidad["vida"]]]))
	var metricas: Dictionary = datos.get("metricas", {})
	var muertes: Array = metricas.get("muertes", [])
	if not muertes.is_empty():
		lineas.append(_armador.armar(ClavesTextos.RESULTADO_MUERTAS))
		for muerte: Dictionary in muertes:
			lineas.append(_SEPARADOR.join([_nombre_en_resultado(datos, muerte["unidad"]),
					_armador.armar(ClavesTextos.causa_muerte(muerte["causa"]))]))
	_bloque_resultado(lineas, ClavesTextos.RESULTADO_LEVANTADAS, datos, datos.get("levantadas", []))
	var guardadas: Array = []
	for guardada: Dictionary in metricas.get("caidas_guardadas", []):
		guardadas.append(guardada["unidad"])
	_bloque_resultado(lineas, ClavesTextos.RESULTADO_CAIDAS_GUARDADAS, datos, guardadas)
	if not (datos.get("capturas", []) as Array).is_empty():
		lineas.append(_armador.armar(ClavesTextos.RESULTADO_CAPTURAS))
		for captura: Dictionary in datos["capturas"]:
			lineas.append(_SEPARADOR.join([_nombre_en_resultado(datos, captura["unidad"]),
					"%s: %d" % [_armador.armar(ClavesTextos.PANEL_LEALTAD), captura["lealtad"]]]))
	if datos.get("atacante_pendiente") != null:
		lineas.append("%s: %s" % [_armador.armar(ClavesTextos.RESULTADO_ATACANTE_PENDIENTE),
				_nombre_en_resultado(datos, datos["atacante_pendiente"])])
		# T30 (Mundo.md 4.6): mientras espera su destino.
		if _combate.esperando_destino():
			lineas.append(_armador.armar(ClavesTextos.NOCTURNO_ATACANTE_CAIDA, _hueco(datos["atacante_pendiente"])))
	# T30: las lineas de cada salida del destino, en orden, antes de la lealtad de
	# la noche. T30-fix: tambien la de un sellado fallido mientras sigue esperando,
	# con el mana que le quedo al Maestro (antes no se veia).
	for destino in _eventos_destino():
		lineas.append_array(lineas_destino(destino))
		if destino["resultado"] == DestinoAtacante.RESULTADO_SELLADO_FALLIDO:
			lineas.append("%s: %d" % [_armador.armar(ClavesTextos.PANEL_MANA), datos["maestro"]["mana"]])
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


# T22 (Sistema.md 1.6): un boton por hechizo del Maestro, en el orden de
# Hechizos.ids() (maestro.json): [{id, texto, tooltip, habilitado}]. El texto
# lleva el costo de hechizos.json; habilitado y el motivo del tooltip salen de
# Turno.motivo_hechizo. Nada se decide por el id. Vacio fuera del turno del Maestro.
func botones_hechizos() -> Array[Dictionary]:
	var botones: Array[Dictionary] = []
	var turno: Turno = _combate.turno_actual()
	if turno == null or turno.unidad_id != Maestro.ID:
		return botones
	var hechizos: Hechizos = _combate.contexto().hechizos
	for hechizo_id in hechizos.ids():
		var motivo: ResultadoAccion.Motivo = turno.motivo_hechizo(hechizo_id)
		var tooltip: Array[String] = [_armador.armar(ClavesTextos.tooltip_hechizo(hechizo_id))]
		var clave_motivo: String = ClavesTextos.motivo_hechizo(motivo)
		if not clave_motivo.is_empty():
			tooltip.append(_armador.armar(clave_motivo))
		botones.append({"id": hechizo_id, "tooltip": "\n".join(tooltip),
				"habilitado": motivo == ResultadoAccion.Motivo.NINGUNO,
				"texto": "%s (%d %s)" % [_armador.armar(ClavesTextos.nombre_hechizo(hechizo_id)),
						hechizos.hechizo(hechizo_id)["costo"] as int, _armador.armar(ClavesTextos.PANEL_MANA)]})
	return botones


# T22: las lineas de lo que haria el hechizo sobre una objetivo, desde las
# previsualizaciones del Turno ({sentido: ResultadoAccion}, en el orden de sus
# modos). Lo que se muestra sale de lo que trae cada una: el desglose (un ataque),
# o el evento `lanzadera` (por sentido: el destino o el choque con su danio y la
# vida, y el aviso de destapar) o `remiendo` (la vida de -> a).
func vista_previa_hechizo(previas: Dictionary) -> Array[String]:
	var lineas: Array[String] = []
	for sentido in previas.keys():
		var previa: ResultadoAccion = previas[sentido]
		if previa.desglose != null:
			lineas.append_array(desglose(previa.desglose.a_diccionario(), Maestro.ID))
			continue
		var evento: Dictionary = previa.evento
		var prefijo: String = "" if (sentido as String).is_empty() \
				else _armador.armar(ClavesTextos.sentido_hechizo(sentido)) + ": "
		match evento.get("tipo"):
			"lanzadera":
				if evento["choque"]:
					lineas.append("%s−%d · %s" % [prefijo, evento["danio"],
							_linea_vida(evento["vida_antes"], evento["vida_despues"])])
				else:
					lineas.append(prefijo + _armador.armar(ClavesTextos.ACCION_MOVER))
				if not previa.destaparia.is_empty():
					lineas.append(_armador.armar(ClavesTextos.AVISO_DESTAPAR))
			"remiendo":
				lineas.append(prefijo + _linea_vida(evento["de"], evento["a"]))
	return lineas


# T24 (Sistema.md 4.1 y 2.3): el boton Sellar, {texto, tooltip, habilitado}, o {}
# fuera del turno del Maestro. El texto lleva los costos distintos de las
# salvajes que se podrian sellar (Combate.costo_sellado, de menor a mayor);
# habilitado y el motivo del tooltip salen de Turno.motivo_sellar.
func boton_sellar() -> Dictionary:
	var turno: Turno = _combate.turno_actual()
	if turno == null or turno.unidad_id != Maestro.ID:
		return {}
	var costos: Array[int] = []
	for criatura in _plantel.criaturas():
		var costo: Variant = _combate.costo_sellado(criatura.id)
		if costo != null and not costos.has(costo):
			costos.append(costo)
	costos.sort()
	var texto: String = _armador.armar(ClavesTextos.ACCION_SELLAR)
	if not costos.is_empty():
		texto += " (%s %s)" % ["/".join(costos.map(func(costo: int) -> String: return str(costo))),
				_armador.armar(ClavesTextos.PANEL_MANA)]
	var motivo: ResultadoAccion.Motivo = turno.motivo_sellar()
	var clave_motivo: String = ClavesTextos.motivo_sellar(motivo)
	return {"texto": texto, "habilitado": motivo == ResultadoAccion.Motivo.NINGUNO,
			"tooltip": "" if clave_motivo.is_empty() else _armador.armar(clave_motivo)}


# T26 (Sistema.md 3.1): el boton Guardar {texto, tooltip}, o {} si la criatura
# del turno no puede guardarse ahora (Turno.motivo_guardar).
func boton_guardar() -> Dictionary:
	var turno: Turno = _combate.turno_actual()
	if turno == null or turno.motivo_guardar() != ResultadoAccion.Motivo.NINGUNO:
		return {}
	return {"texto": _armador.armar(ClavesTextos.ACCION_GUARDAR), "tooltip": _armador.armar(ClavesTextos.GUARDAR_TOOLTIP)}


# T26 (Sistema.md 3.1 y 2.3): un boton de invocar por guardada de la tribu
# (Combate.costo_invocar no nulo), en el orden del Plantel, solo en el turno del
# Maestro: {criatura, texto (nombre y costo), tooltip (invocar.tooltip y, si no
# se puede, el motivo de Turno.motivo_invocar), habilitado}.
func botones_invocar() -> Array[Dictionary]:
	var botones: Array[Dictionary] = []
	var turno: Turno = _combate.turno_actual()
	if turno == null or turno.unidad_id != Maestro.ID:
		return botones
	for criatura in _plantel.criaturas():
		var costo: Variant = _combate.costo_invocar(criatura.id)
		if costo == null:
			continue
		var motivo: ResultadoAccion.Motivo = turno.motivo_invocar(criatura.id)
		var tooltip: Array[String] = [_armador.armar(ClavesTextos.INVOCAR_TOOLTIP)]
		var clave_motivo: String = ClavesTextos.motivo_invocar(motivo)
		if not clave_motivo.is_empty():
			tooltip.append(_armador.armar(clave_motivo))
		botones.append({"criatura": criatura.id, "habilitado": motivo == ResultadoAccion.Motivo.NINGUNO,
				"tooltip": "\n".join(tooltip),
				"texto": "%s %s (%d %s)" % [_armador.armar(ClavesTextos.ACCION_INVOCAR), nombre(criatura.id),
						costo as int, _armador.armar(ClavesTextos.PANEL_MANA)]})
	return botones


# T27 (Sistema.md 11.5 y 2.3): el boton de guardar a una caida, {texto, tooltip,
# habilitado}, o {} fuera del turno del Maestro. El texto lleva los costos
# distintos de las caidas de la tribu (Combate.costo_guardar_caida, de menor a
# mayor); habilitado y el motivo del tooltip salen de Turno.motivo_guardar_caida.
func boton_guardar_caida() -> Dictionary:
	var turno: Turno = _combate.turno_actual()
	if turno == null or turno.unidad_id != Maestro.ID:
		return {}
	var costos: Array[int] = []
	for criatura in _plantel.criaturas():
		var costo: Variant = _combate.costo_guardar_caida(criatura.id)
		if costo != null and not costos.has(costo):
			costos.append(costo)
	costos.sort()
	var texto: String = _armador.armar(ClavesTextos.ACCION_GUARDAR_CAIDA)
	if not costos.is_empty():
		texto += " (%s %s)" % ["/".join(costos.map(func(costo: int) -> String: return str(costo))),
				_armador.armar(ClavesTextos.PANEL_MANA)]
	var motivo: ResultadoAccion.Motivo = turno.motivo_guardar_caida()
	var tooltip: Array[String] = [_armador.armar(ClavesTextos.GUARDAR_CAIDA_TOOLTIP)]
	var clave_motivo: String = ClavesTextos.motivo_guardar_caida(motivo)
	if not clave_motivo.is_empty():
		tooltip.append(_armador.armar(clave_motivo))
	return {"texto": texto, "habilitado": motivo == ResultadoAccion.Motivo.NINGUNO, "tooltip": "\n".join(tooltip)}


# T27: lo que haria guardar a la caida (Turno.previsualizar_guardar_caida): el
# mana de -> a que paga y la vida de -> a con la que queda. [] si no vale.
func vista_previa_guardar_caida(previa: ResultadoAccion) -> Array[String]:
	var lineas: Array[String] = []
	if not previa.valida:
		return lineas
	if not previa.mana.is_empty():
		lineas.append("%s: %d → %d" % [_armador.armar(ClavesTextos.PANEL_MANA), previa.mana["de"], previa.mana["a"]])
	lineas.append(_linea_vida(previa.vida["de"], previa.vida["a"]))
	return lineas


# T28 (Sistema.md 11.7): el boton Huir {texto, habilitado, tooltip}, o {} fuera
# del turno del Maestro o con la huida ya declarada. habilitado y el motivo del
# tooltip salen de Turno.motivo_huir.
func boton_huir() -> Dictionary:
	var turno: Turno = _combate.turno_actual()
	if turno == null or turno.unidad_id != Maestro.ID or _plantel.maestro.huida_declarada:
		return {}
	var motivo: ResultadoAccion.Motivo = turno.motivo_huir()
	var clave_motivo: String = ClavesTextos.motivo_huir(motivo)
	return {"texto": _armador.armar(ClavesTextos.ACCION_HUIR), "habilitado": motivo == ResultadoAccion.Motivo.NINGUNO,
			"tooltip": "" if clave_motivo.is_empty() else _armador.armar(clave_motivo)}


# T28 (Sistema.md 11.7, "previsualizacion al declarar"): las lineas de
# Combate.previsualizar_huida, con los numeros que da el nucleo. T30 (Mundo.md
# 1.5 v1.4): el titulo; las que actuan antes del cierre (con su danio si lo
# alcanzan) o la linea de ninguna; si alguna alcanza, el danio maximo total ({n});
# si no, la de ninguna llega; la vida del Maestro, el aviso si cae y las caidas
# que moririan.
func vista_previa_huida(previa: Dictionary) -> Array[String]:
	var lineas: Array[String] = [_armador.armar(ClavesTextos.HUIDA_PREVIA_TITULO)]
	var enemigas: Array = previa["enemigas"]
	if enemigas.is_empty():
		lineas.append(_armador.armar(ClavesTextos.HUIDA_PREVIA_NINGUNA))
	else:
		lineas.append(_armador.armar(ClavesTextos.HUIDA_PREVIA_ACTUAN))
	var alguna_alcanza: bool = false
	for enemiga: Dictionary in enemigas:
		if enemiga["alcanza"]:
			alguna_alcanza = true
			lineas.append("%s −%d" % [nombre(enemiga["unidad"]), enemiga["danio"]])
		else:
			lineas.append(nombre(enemiga["unidad"]))
	if alguna_alcanza:
		lineas.append(_armador.armar(ClavesTextos.HUIDA_PREVIA_ALCANZAN, {"n": previa["danio_maximo"]}))
	elif not enemigas.is_empty():
		lineas.append(_armador.armar(ClavesTextos.HUIDA_PREVIA_NO_ALCANZAN))
	lineas.append("%s: %d" % [_armador.armar(ClavesTextos.PANEL_VIDA), previa["vida"]])
	if previa["puede_caer"]:
		lineas.append(_armador.armar(ClavesTextos.HUIDA_PREVIA_CAES))
	var caidas: Array = previa["caidas"]
	if not caidas.is_empty():
		lineas.append("%s: %s" % [_armador.armar(ClavesTextos.HUIDA_PREVIA_CAIDAS),
				", ".join(caidas.map(func(id_caida: String) -> String: return nombre(id_caida)))])
	return lineas


# T28 (Sistema.md 11.7, Mundo.md 9): con el combate terminado en huida, la linea
# de irse antes de las del cierre: sin caidas, huida.maestro.sin_caidas; si no,
# huida.maestro.con_caidas por cada muerta (hueco {caida}). [] en otro desenlace.
func _sucesos_huida_maestro(cierre: Dictionary) -> Array[String]:
	var lineas: Array[String] = []
	if _combate.fin() != FinCombate.Fin.HUIDA:
		return lineas
	if (cierre["muertas"] as Array).is_empty():
		lineas.append(_armador.armar(ClavesTextos.HUIDA_MAESTRO_SIN_CAIDAS))
	for id_unidad in cierre["muertas"]:
		lineas.append(_armador.armar(ClavesTextos.HUIDA_MAESTRO_CON_CAIDAS, {_HUECO_CAIDA: HuecoCriatura.new(
				_plantel.criatura(id_unidad).especie.id())}, _sujeto(id_unidad)))
	return lineas


# T24: lo que haria el sellado sobre la objetivo (Turno.previsualizar_sellar): el %
# con sellar.tooltip y el mana de -> a que paga. [] si no vale.
func vista_previa_sellar(previa: ResultadoAccion, objetivo_id: String) -> Array[String]:
	var lineas: Array[String] = []
	if not previa.valida:
		return lineas
	lineas.append(linea_sellado(objetivo_id, previa.porcentaje))
	if not previa.mana.is_empty():
		lineas.append("%s: %d → %d" % [_armador.armar(ClavesTextos.PANEL_MANA), previa.mana["de"], previa.mana["a"]])
	return lineas


# T24: el % de sellado como marca de la ficha.
func marca_sellado(porcentaje: int) -> String:
	return "%d%%" % porcentaje


# T24: sellar.tooltip con el % que da el nucleo y la objetivo como hueco.
func linea_sellado(objetivo_id: String, porcentaje: int) -> String:
	var datos: Dictionary = _hueco(objetivo_id)
	datos["porcentaje"] = porcentaje
	return _armador.armar(ClavesTextos.SELLAR_TOOLTIP, datos, _sujeto(objetivo_id))


# T24 (Sistema.md 4.1, Mundo.md 5): logrado, sellar.exito; fallido con la objetivo
# erizada ahora (instantanea del nucleo, S-51), sellar.fallo.erizada; si no,
# sellar.fallo con la especie como sujeto (su variante, si existe).
func _suceso_sellado(evento: Dictionary) -> String:
	var objetivo: String = evento["objetivo"]
	if evento["resultado"] == Sellado.RESULTADO_LOGRADO:
		return _armador.armar(ClavesTextos.SELLAR_EXITO, _hueco(objetivo), _sujeto(objetivo))
	for foto_criatura in _combate.instantanea()["criaturas"]:
		if foto_criatura["id"] == objetivo and foto_criatura["erizada"]:
			return _armador.armar(ClavesTextos.SELLAR_FALLO_ERIZADA, _hueco(objetivo))
	return _armador.armar(ClavesTextos.SELLAR_FALLO, _hueco(objetivo), _sujeto(objetivo))


# T25: el % de huida como marca de la ficha. El numero va fuera de la clave: se
# ve aunque la clave falte.
func marca_huida(porcentaje: int) -> String:
	return "%s %d%%" % [_armador.armar(ClavesTextos.MARCA_HUIDA), porcentaje]


# T25: huida.salvaje.porcentaje con el % que da el nucleo y la salvaje como hueco.
func linea_huida(unidad_id: String, porcentaje: int) -> String:
	var datos: Dictionary = _hueco(unidad_id)
	datos["porcentaje"] = porcentaje
	return _armador.armar(ClavesTextos.HUIDA_PORCENTAJE, datos, _sujeto(unidad_id))


# T25 (Sistema.md 11.7): huye, huida.salvaje con la variante de su especie; se
# queda, huida.salvaje.se_queda (o su variante) solo si existe.
func _suceso_huida(evento: Dictionary) -> Array[String]:
	var unidad: String = evento["unidad"]
	var sujeto: String = _sujeto(unidad)
	if evento["resultado"] == Huida.RESULTADO_HUYE:
		return [_armador.armar(ClavesTextos.HUIDA_SALVAJE, _hueco(unidad), sujeto)]
	if not _armador.tiene(ClavesTextos.HUIDA_SE_QUEDA) 			and not _armador.tiene("%s.%s" % [ClavesTextos.HUIDA_SE_QUEDA, sujeto]):
		return []
	return [_armador.armar(ClavesTextos.HUIDA_SE_QUEDA, _hueco(unidad), sujeto)]


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
	# T24 (Sistema.md 4.1): el % de sellado de una salvaje, desde el principio.
	var porcentaje: Variant = _combate.porcentaje_sellado(id_unidad)
	if porcentaje != null:
		lineas.append(linea_sellado(id_unidad, porcentaje))
	# T25 (Sistema.md 11.7): el % de huida, si es mayor que 0.
	var huida: int = _combate.porcentaje_huida(id_unidad)
	if huida > 0:
		lineas.append(linea_huida(id_unidad, huida))
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
		# T30 (Mundo.md 4.6): la atacante nocturna cae con su linea propia, en lugar
		# de la de caida (las dos dicen que cae y no se levanta).
		if _plantel.criatura(id_unidad).comportamiento == Criatura.Comportamiento.ATACANTE_NOCTURNA:
			return [_armador.armar(ClavesTextos.NOCTURNO_ATACANTE_CAIDA, _hueco(id_unidad))]
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
	var especie: String = _especie_en_resultado(datos, id_unidad)
	if especie.is_empty():
		return id_unidad
	return _armador.armar(ClavesTextos.nombre_especie(especie))


func _especie_en_resultado(datos: Dictionary, id_unidad: String) -> String:
	for unidad in datos["unidades"]:
		if unidad["id"] == id_unidad:
			return unidad["especie"]
	return ""


# T29: un bloque del resultado, su titulo y un nombre por linea; nada si ids esta vacio.
func _bloque_resultado(lineas: Array[String], clave_titulo: String, datos: Dictionary, ids: Array) -> void:
	if ids.is_empty():
		return
	lineas.append(_armador.armar(clave_titulo))
	for id_unidad in ids:
		lineas.append(_nombre_en_resultado(datos, id_unidad))
