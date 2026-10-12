# Arquitectura.md A.7 y B.2 (T12): el bucle del combate. Es dueno de la cola
# (T07) y del turno actual (T08): juega solos los turnos de las enemigas
# (IASalvaje, tambien la atacante nocturna) y se detiene en cada turno del
# jugador. Se corta con FinCombate, no con la cola. Escribe el registro: las
# reglas nunca lo tocan. Al terminar, el Cierre (T10) corre una sola vez.
class_name Combate
extends RefCounted

const _ORIGEN_JUGADOR: String = "jugador"
const _ORIGEN_IA: String = "ia"
const _MAESTRO_EN_PIE: String = "en_pie"
const _MAESTRO_CAIDO: String = "caido"

var _contexto: ContextoCombate
var _plantel: Plantel
var _cola: ColaIniciativa = ColaIniciativa.new()
var _turno: Turno = null
var _registro: RegistroCombate = RegistroCombate.new()
var _fin: FinCombate.Fin = FinCombate.Fin.EN_CURSO
var _resultado: ResultadoCombate = null
# "" mientras no hubo un error de programacion (accion invalida de la IA,
# registro con un float...). Con error, el combate se detiene.
var _error: String = ""
# Lo que guarda la Grabacion: {unidad, accion} de cada accion valida del jugador.
var _acciones_jugador: Array[Dictionary] = []
# Tiradas del generador de combate ya volcadas al registro.
var _tiradas_volcadas: int = 0
# Sistema.md 11.2.1: los surcos son del combate y desaparecen con el (B.2.1, T37).
var _surcos: Surcos = Surcos.new()
# Eventos del historial de los surcos ya volcados al registro.
var _surcos_volcados: int = 0
# Eventos de Junco del turno en curso ya volcados al registro (vuelve a 0 con cada turno).
var _junco_volcados: int = 0
# Sistema.md 10.2: la cadena de combos es del combate (T16), como los surcos.
var _cadena: Cadena
# Eventos cadena_cortada ya volcados al registro.
var _cadena_volcados: int = 0


func _init(contexto_combate: ContextoCombate) -> void:
	_contexto = contexto_combate
	_plantel = contexto_combate.plantel
	_cadena = Cadena.new(contexto_combate.combo)


# Arma el combate y lo juega hasta el primer turno del jugador (o el fin).
# contexto: uno valido (ContextoCombate.armar).
static func empezar(contexto_combate: ContextoCombate) -> Combate:
	var combate: Combate = Combate.new(contexto_combate)
	combate._arrancar()
	return combate


func esperando_jugador() -> bool:
	return _error.is_empty() and _fin == FinCombate.Fin.EN_CURSO and _turno != null \
			and not _turno.terminado and _es_del_jugador(_turno.unidad_id)


# El turno en curso, con las consultas de T08 para la pantalla. Las acciones se
# aplican con Combate.aplicar, nunca con el Turno directamente.
func turno_actual() -> Turno:
	return _turno


# Solo en turno del jugador. Una accion invalida no cambia nada y no se registra
# ni se graba. `terminar` cierra el turno y el bucle sigue hasta el proximo
# turno del jugador o el fin.
func aplicar(accion: Accion) -> ResultadoAccion:
	if _fin != FinCombate.Fin.EN_CURSO:
		var rechazo: ResultadoAccion = ResultadoAccion.rechazada(ResultadoAccion.Motivo.COMBATE_TERMINADO)
		rechazo.fin = _fin
		return rechazo
	if not esperando_jugador():
		return ResultadoAccion.rechazada(ResultadoAccion.Motivo.FUERA_DE_TURNO)
	var unidad_id: String = _turno.unidad_id
	var resultado: ResultadoAccion = _ejecutar(accion, _ORIGEN_JUGADOR, null)
	if not resultado.valida:
		return resultado
	_acciones_jugador.append({"unidad": unidad_id, "accion": accion.a_diccionario()})
	if _error.is_empty() and _fin == FinCombate.Fin.EN_CURSO and _turno.terminado:
		_avanzar()
	return resultado


func terminado() -> bool:
	return _fin != FinCombate.Fin.EN_CURSO


func fin() -> FinCombate.Fin:
	return _fin


# La salida del combate (A.7), o null mientras no termino (o si el cierre se
# rechazo: entonces hay error()).
func resultado() -> ResultadoCombate:
	return _resultado


func registro() -> RegistroCombate:
	return _registro


func error() -> String:
	return _error


func contexto() -> ContextoCombate:
	return _contexto


# La cola de la ronda en curso, en orden (Sistema.md 11.3), para mostrarla.
# Las entradas son de solo lectura: la cola la edita solo el combate.
func cola() -> Array[EntradaCola]:
	return _cola.entradas()


# Indice en cola() de la entrada del turno en curso, o -1 si no hay turno.
func entrada_actual() -> int:
	if _turno == null or _cola.lugar() == 0:
		return -1
	return _cola.lugar() - 1


# Sistema.md 11.2.3, "el umbral se muestra sobre la unidad": la vida a la que
# cambia de modo, o null (sin modos, ya en el modo final, o el Maestro).
func vida_de_cambio(unidad_id: String) -> Variant:
	var criatura: Criatura = _plantel.criatura(unidad_id)
	return null if criatura == null else CambioModo.vida_de_cambio(criatura)


# T40, zona de Caza (Sistema.md 11.2.3 y 15): las casillas donde la unidad puede
# golpear en su proximo turno con las posiciones de ahora. Es lo que golpea
# (Tablero.golpeables) desde cada casilla a la que llega (Tablero.alcanzables),
# sin la suya, en orden de lectura. Vacio si no esta de pie en el tablero. No
# modifica nada.
func zona_amenaza(unidad_id: String) -> Array[Vector2i]:
	var resultado: Array[Vector2i] = []
	if not Objetivos.de_pie(unidad_id, _plantel):
		return resultado
	var tablero: Tablero = _contexto.tablero
	var desde: Vector2i = _posicion(unidad_id)
	var bando: Criatura.Bando = Criatura.Bando.TRIBU
	var movimiento: int = _plantel.maestro.movimiento
	var alcance: int = _plantel.maestro.alcance
	var criatura: Criatura = _plantel.criatura(unidad_id)
	if criatura != null:
		bando = criatura.bando
		movimiento = criatura.especie.movimiento()
		alcance = criatura.especie.alcance()
	var vistas: Dictionary = {}
	for casilla in tablero.alcanzables(desde, movimiento, bando, _plantel, _surcos,
			Surcos.es_surcon(unidad_id, _plantel)):
		for golpeada in tablero.golpeables(casilla, alcance, bando, _plantel):
			if golpeada != desde and not vistas.has(golpeada):
				vistas[golpeada] = true
				resultado.append(golpeada)
	resultado.sort_custom(func(a: Vector2i, b: Vector2i) -> bool: return a.y < b.y or (a.y == b.y and a.x < b.x))
	return resultado


# T40, aviso al mover junto a una oculta (Sistema.md 11.2.2): las ocultas que la
# unidad destaparia si terminara su movimiento en `casilla` (Junco.destaparia).
func destaparia(unidad_id: String, casilla: Vector2i) -> Array[String]:
	return Junco.destaparia(unidad_id, casilla, _plantel)


# T41 (Sistema.md 10.3 y 15, v1.6): las unidades que le darian afinidad a la
# unidad si golpeara desde `casilla` (Afinidad.afines_vecinas, en el orden del
# Plantel). Calcula sin aplicar.
func afines_desde(unidad_id: String, casilla: Vector2i) -> Array[String]:
	return _contexto.afinidad.afines_vecinas(unidad_id, casilla, _plantel)


# T18 (Sistema.md 10.4: "la probabilidad se muestra en la casilla antes de
# mover"): {rivales, porcentaje} que tendria la unidad al empezar su proximo
# turno parada en `casilla`, con el tablero de ahora (Incidente.consulta, la
# misma cuenta que la tirada). Calcula sin aplicar.
func incidente_en(unidad_id: String, casilla: Vector2i) -> Dictionary:
	return _contexto.incidente.consulta(unidad_id, casilla, _plantel)


# T19 (Sistema.md 10.5: "el jugador ve la probabilidad antes de acercarla"):
# {tipo, rivales, porcentaje, seguro} del chequeo de rival enemiga que tendria la
# unidad al empezar su proximo turno parada en `casilla`, con el tablero de ahora
# (ChequeoRival.consulta, la misma cuenta que la tirada). Calcula sin aplicar.
func rival_en(unidad_id: String, casilla: Vector2i) -> Dictionary:
	return _contexto.chequeo_rival.consulta(unidad_id, casilla, _plantel)


# Sistema.md 4.1 (T24, "el porcentaje se muestra antes de gastar el mana"): el %
# de sellado de una salvaje con su vida de ahora (Sellado), sin mirar distancia,
# mana ni pergaminos. null si no es una salvaje de pie (oculta incluida), si no
# es sellable o si su rango no alcanza con la balanza del Maestro.
func porcentaje_sellado(unidad_id: String) -> Variant:
	var criatura: Criatura = _sellable(unidad_id)
	return null if criatura == null else _contexto.sellado.porcentaje_de(criatura)


# Sistema.md 2.3 (T24): el costo de sellarla, con las mismas condiciones que
# porcentaje_sellado.
func costo_sellado(unidad_id: String) -> Variant:
	var criatura: Criatura = _sellable(unidad_id)
	return null if criatura == null else _contexto.sellado.costo(criatura.especie, _plantel.maestro)


# Sistema.md 2.3 y 3.1 (T26): el costo de invocar a la criatura, o null si no es
# una guardada de la tribu. No mira el turno, el mana ni las casillas.
func costo_invocar(unidad_id: String) -> Variant:
	var criatura: Criatura = _plantel.criatura(unidad_id)
	if criatura == null or criatura.bando != Criatura.Bando.TRIBU or criatura.estado != Criatura.Estado.GUARDADA:
		return null
	return _contexto.costos_mana.invocar(criatura.especie, _plantel.maestro)


# Sistema.md 2.3 y 11.5 (T27): el costo de guardar a la unidad si es una caida de
# la tribu (la consulta unica, Objetivos CAIDA_PROPIA); si no, null. No mira el
# turno, el mana ni la distancia.
func costo_guardar_caida(unidad_id: String) -> Variant:
	var criatura: Criatura = _plantel.criatura(unidad_id)
	if criatura == null or criatura.bando != Criatura.Bando.TRIBU \
			or not Objetivos.puede_ser_objetivo(unidad_id, Objetivos.Clase.CAIDA_PROPIA, _plantel):
		return null
	return _contexto.guardado_caida.costo(criatura.especie, _plantel.maestro)


# Sistema.md 11.7 (T25, "la probabilidad se muestra sobre la unidad"): el % de
# huida que tiraria la unidad si su turno empezara ahora (Huida, la misma cuenta
# que la tirada); 0 si no tira.
func porcentaje_huida(unidad_id: String) -> int:
	return _contexto.huida.porcentaje_al_empezar(unidad_id, _plantel)


# Sistema.md 11.7, "previsualizacion al declarar" (T28, D-005, S-61): lo que
# arriesga el Maestro si declara la huida ahora. Calcula sin aplicar: no cambia
# el Plantel, la cola ni el generador. Devuelve:
#   enemigas: [{unidad, alcanza, danio}], las enemigas con entrada pendiente en
#     la ronda que pueden actuar, en el orden de la cola. alcanza: si lo golpea
#     en su turno moviendose y atacando, como la IA (pasos_para_mover y
#     previsualizar_ataque); danio: el de la casilla que mas le pega, por los
#     ataques de su modo actual (0 si no alcanza).
#   danio_maximo: la suma; vida: la del Maestro; puede_caer: danio_maximo >= vida;
#   caidas: las de la tribu que moririan (Cierre.caidas_que_mueren), por id.
# Lectura S-61: con el tablero de ahora, sin lo que depende de tiradas (huida,
# Encono, cobardia, incidente) ni de como se muevan las demas.
func previsualizar_huida() -> Dictionary:
	var enemigas: Array[Dictionary] = []
	var total: int = 0
	var entradas: Array[EntradaCola] = _cola.entradas()
	for indice in range(_cola.lugar(), entradas.size()):
		var entrada: EntradaCola = entradas[indice]
		if _es_del_jugador(entrada.unidad_id) or not _cola.pendiente(entrada.unidad_id, _plantel):
			continue
		var danio: int = _danio_maximo_al_maestro(entrada)
		var alcanza: bool = danio >= 0
		danio = maxi(danio, 0)
		enemigas.append({"unidad": entrada.unidad_id, "alcanza": alcanza, "danio": danio})
		total += danio
	var caidas: Array[String] = []
	for criatura in Cierre.caidas_que_mueren(_plantel):
		caidas.append(criatura.id)
	var vida: int = _plantel.maestro.vida
	return {"enemigas": enemigas, "danio_maximo": total, "vida": vida, "puede_caer": total >= vida,
			"caidas": caidas}


# T28 (S-61): el mayor danio que la unidad de la entrada le haria al Maestro en
# su turno, desde alguna casilla a la que llega, con un turno de consulta
# (Turno.para_consulta: sin inicio del turno, sin azar). Por los ataques de su
# modo: el primero y, si tiene mas, los siguientes como el segundo de Caza
# (previsualizar_ataque con tras_primer_ataque). -1 si no lo alcanza. El danio sale
# del mismo camino que el ataque real (Danio y los aportes del Turno).
func _danio_maximo_al_maestro(entrada: EntradaCola) -> int:
	var consulta: Turno = Turno.para_consulta(entrada, _plantel, _contexto.tablero, _surcos, _cadena, _cola,
			_contexto.reglas)
	var mejor: int = -1
	for casilla: Vector2i in consulta.pasos_para_mover().keys():
		var primero: ResultadoAccion = consulta.previsualizar_ataque(casilla, Maestro.ID)
		if not primero.valida:
			continue
		var danio: int = primero.danio
		if consulta.ataques_restantes > 1:
			var siguiente: ResultadoAccion = consulta.previsualizar_ataque(casilla, Maestro.ID, true)
			if siguiente.valida:
				danio += siguiente.danio * (consulta.ataques_restantes - 1)
		mejor = maxi(mejor, danio)
	return mejor


func acciones_jugador() -> Array[Dictionary]:
	return _acciones_jugador.duplicate(true)


# La del Plantel, mas donde va el combate: ronda, lugar en la cola y el turno.
func instantanea() -> Dictionary:
	var foto: Dictionary = _plantel.instantanea()
	foto["ronda"] = _cola.ronda
	foto["lugar_en_cola"] = _cola.lugar()
	foto["turno"] = null
	if _turno != null:
		foto["turno"] = {
			"unidad": _turno.unidad_id,
			"movimiento_usado": _turno.movimiento_usado,
			"accion_usada": _turno.accion_usada,
			"terminado": _turno.terminado,
		}
	# Arquitectura.md A.7 (B.2.1): los surcos del combate.
	foto["surcos"] = _surcos.instantanea()
	# A.7 (T16): la cadena actual, o null.
	foto["cadena"] = _cadena.instantanea()
	return foto


# Antes de la ronda 1, en este orden (B.2, T12): golpe inicial, unidades en 0 y
# fin del combate (base de S-10).
func _arrancar() -> void:
	_registrar({"tipo": "inicio", "escenario": _contexto.escenario_id,
			"semilla": _contexto.semilla, "huella": _contexto.huella})
	_golpe_inicial()
	var antes: Dictionary = _estados()
	# Sistema.md 11.5, en el orden del Plantel. Solo las del tablero: una
	# guardada no esta en juego y el cierre tampoco la toca.
	VidaCero.resolver(Maestro.ID, _plantel, _surcos)
	for criatura in _plantel.criaturas():
		if criatura.estado == Criatura.Estado.SUELTA and criatura.vida == 0:
			VidaCero.resolver(criatura.id, _plantel, _surcos)
	_registrar_estados(antes)
	_registrar_surcos()
	_fin = FinCombate.evaluar(_plantel)
	if _fin != FinCombate.Fin.EN_CURSO:
		_terminar()
	else:
		_avanzar()


# Punto vacio: Sistema.md 9.2, el golpe inicial como primer evento, antes de la
# ronda 1 (T30). En T12 el campo se lee (ContextoCombate) y no se resuelve.
func _golpe_inicial() -> void:
	pass


# Juega entradas hasta un turno del jugador, el fin o un error.
func _avanzar() -> void:
	while _error.is_empty() and _fin == FinCombate.Fin.EN_CURSO:
		if _turno != null and not _turno.terminado:
			if _es_del_jugador(_turno.unidad_id):
				return
			_jugar_ia()
			continue
		var entrada: EntradaCola = _cola.siguiente(_plantel)
		if entrada == null:
			if _cola.ronda > 0:
				_cerrar_ronda()
				# Sistema.md 11.7 (T28): la huida termina el combate al cerrar la ronda.
				if _fin != FinCombate.Fin.EN_CURSO:
					continue
			_cola.empezar_ronda(_plantel)
			_registrar({"tipo": "ronda"})
			continue
		# Sistema.md 10.1 (T17): la entrada de la unidad que Secundo vuelve. El
		# turno sigue sin un inicio nuevo (S-31), asi que no lleva otro `turno`
		# (A.7: uno por ronda) y la tribu no corta la cadena.
		if entrada.vuelve:
			_registrar({"tipo": "turno_vuelve", "unidad": entrada.unidad_id})
			_turno = _empezar_turno(entrada)
			_junco_volcados = 0
			continue
		# Antes de empezar el turno: las tiradas de su inicio (T18 a T25) van despues.
		_registrar({"tipo": "turno", "unidad": entrada.unidad_id,
				"marca": null if entrada.marca.is_empty() else entrada.marca})
		# Sistema.md 10.2 y 10.7: el turno de una enemiga corta la cadena, haga lo
		# que haga (tambien el Tasajero en sus dos modos).
		if not _es_del_jugador(entrada.unidad_id):
			_cadena.cortar(Cadena.MOTIVO_ENEMIGA)
			_registrar_cadena()
		var estados_antes: Dictionary = _estados()
		_turno = _empezar_turno(entrada)
		_junco_volcados = 0
		# Sistema.md 2.1 y 11.3 paso 1 (T21, D-007): la regeneracion del Maestro,
		# justo detras de su `turno` y solo si el mana cambio. Paso antes que toda
		# tirada del inicio del turno: no las vuelca.
		if not _turno.mana.is_empty():
			_registrar({"tipo": "mana", "unidad": entrada.unidad_id, "de": _turno.mana["de"],
					"a": _turno.mana["a"], "motivo": RegeneracionMana.MOTIVO_REGENERACION}, 0)
		# Sistema.md 11.7 y 11.3 paso 2 (T25): la huida, detras de su propia tirada.
		if _registrar_huida(estados_antes):
			continue
		# Sistema.md 11.2.3: el cambio de modo del inicio del turno (A.7). Paso
		# antes que las tiradas de los pasos 3 y 4 de 11.3: se registra sin
		# volcarlas, asi el orden del registro es el de lo que paso.
		if not _turno.cambio_modo.is_empty():
			_registrar({"tipo": "cambio_modo", "unidad": entrada.unidad_id,
					"de": _turno.cambio_modo["de"], "a": _turno.cambio_modo["a"]}, 0)
		_registrar_chequeo_rival()
		_registrar_incidente(estados_antes)


# Sistema.md 11.7 (T25, A.7): el evento huida, detras del turno y de su tirada
# (solo la suya: las de los pasos 3 y 4 van despues), solo si tiro. Si huyo,
# siguen el estado y los surcos cerrados, y el turno termina: con el combate en
# curso, su fin_turno (sin posicion, ya no esta en el tablero, asi que no hay
# encierro que medir); si era la ultima enemiga, el fin, sin fin_turno, como
# cualquier accion que gana. Devuelve si el turno termino ahi.
func _registrar_huida(estados_antes: Dictionary) -> bool:
	var huida: Dictionary = _turno.huida
	if huida.is_empty():
		return false
	var unidad_id: String = _turno.unidad_id
	_registrar({"tipo": "huida", "unidad": unidad_id, "porcentaje": huida["porcentaje"], "tiro": huida["tiro"],
			"resultado": huida["resultado"]}, 1)
	if huida["resultado"] != Huida.RESULTADO_HUYE:
		return false
	_registrar_estados(estados_antes)
	_registrar_surcos()
	_fin = FinCombate.evaluar(_plantel)
	if _fin != FinCombate.Fin.EN_CURSO:
		_terminar()
	else:
		_registrar({"tipo": "fin_turno", "unidad": unidad_id, "posicion": Plantel.casilla_a_lista(_posicion(unidad_id))})
	return true


func _empezar_turno(entrada: EntradaCola) -> Turno:
	return Turno.empezar(entrada, _plantel, _contexto.tablero, _surcos, _cadena, _cola, _contexto.reglas,
			_contexto.azar_combate)


# Sistema.md 10.5 y 10.6 (T19, A.7): el chequeo de rival enemiga, detras del
# `turno` (y del `cambio_modo`) y de su propia `tirada`, si tiro; antes de todo
# lo del incidente, cuya tirada queda sin volcar hasta su evento. T44: la
# resistida suma sostenida_por (y afin, P-041), solo si ChequeoRival los trae.
func _registrar_chequeo_rival() -> void:
	var chequeo: Dictionary = _turno.chequeo_rival
	if chequeo.is_empty():
		return
	var evento: Dictionary = {"tipo": "chequeo_rival", "unidad": _turno.unidad_id, "tipo_chequeo": chequeo["tipo"],
			"rivales": (chequeo["rivales"] as Array).duplicate(), "porcentaje": chequeo["porcentaje"],
			"tiro": chequeo["tiro"], "resultado": chequeo["resultado"]}
	for clave in ["sostenida_por", "afin"]:
		if chequeo.has(clave):
			evento[clave] = chequeo[clave]
	_registrar(evento, 1 if chequeo["tiro"] else 0)


# Sistema.md 10.4 (T18, A.7): el incidente del inicio del turno, detras del
# `turno` y de su `tirada` (se vuelca sola). Si golpea, el golpe va como un
# `ataque` normal (sin eslabon, S-33) con lo que dispara: Junco, estados, surcos
# y el corte de la cadena. Si la tirada no sale, solo queda la `tirada`.
func _registrar_incidente(estados_antes: Dictionary) -> void:
	if _turno.incidente.is_empty():
		return
	var unidad_id: String = _turno.unidad_id
	_registrar({"tipo": "incidente", "unidad": unidad_id, "rivales": _turno.incidente["rivales"].duplicate(),
			"porcentaje": _turno.incidente["porcentaje"], "resultado": _turno.incidente["resultado"],
			"objetivo": _turno.incidente["objetivo"]})
	if _turno.golpe_incidente.is_empty():
		return
	_registrar({"tipo": "ataque", "atacante": unidad_id, "objetivo": _turno.incidente["objetivo"],
			"desglose": (_turno.golpe_incidente["desglose"] as DesgloseDanio).a_diccionario(), "eslabon": null,
			"vida_antes": _turno.golpe_incidente["vida_antes"], "vida_despues": _turno.golpe_incidente["vida_despues"]})
	_registrar_eventos_turno()
	_registrar_estados(estados_antes)
	_registrar_surcos()
	_registrar_cadena()
	# Una rival de la tribu que cae no termina el combate (11.5), pero se mira igual.
	_fin = FinCombate.evaluar(_plantel)
	if _fin != FinCombate.Fin.EN_CURSO:
		_terminar()


# Fin de ronda (T07): el punto de la cola y, despues del fin_ronda, el hambre de
# combate (Sistema.md 7.2, T14), con el numero de la ronda que se cierra (A.7).
# En una ronda que la dispara, el evento va aunque nadie cambie (todas en el
# tope): lectura tecnica de T14. Un combate que termina a mitad de ronda no
# llega aca, asi que no suma. Despues, la cadena se corta: nunca pasa a la ronda
# siguiente (10.2). Al final, la huida del Maestro (11.7, T28, S-60): si la
# declaro y el combate sigue en curso, se va y el combate termina en huida (fin
# y cierre, sin evento nuevo, A.7). Si antes cayo o no quedo ninguna enemiga en
# pie, el combate ya habia terminado y no llega aca.
func _cerrar_ronda() -> void:
	_cola.terminar_ronda()
	_registrar({"tipo": "fin_ronda"})
	var cambios: Variant = _contexto.hambre_combate.cerrar_ronda(_cola.ronda, _plantel)
	if cambios != null:
		_registrar({"tipo": "hambre_combate", "cambios": cambios})
	_cadena.cortar(Cadena.MOTIVO_FIN_RONDA)
	_registrar_cadena()
	if _plantel.maestro.huida_declarada and _fin == FinCombate.Fin.EN_CURSO:
		_plantel.maestro.se_fue = true
		_fin = FinCombate.evaluar(_plantel)
		_terminar()


# Sistema.md 11.8: las acciones de la IA, una por una. Corta si el combate
# termina; una accion invalida es un error de programacion y detiene el combate.
func _jugar_ia() -> void:
	var decision: DecisionIA = IASalvaje.decidir(_turno, _plantel, _cola)
	var paso: String = (DecisionIA.Paso.keys()[decision.paso] as String).to_lower()
	for accion in decision.acciones:
		var resultado: ResultadoAccion = _ejecutar(accion, _ORIGEN_IA, paso)
		if not resultado.valida:
			_error = "accion invalida de la IA: %s -> %s" % [decision.describir(),
					ResultadoAccion.Motivo.keys()[resultado.motivo]]
			return
		if not _error.is_empty() or _fin != FinCombate.Fin.EN_CURSO:
			return
	if not _turno.terminado:
		_error = "la IA no cerro el turno: " + decision.describir()


# Valida sin aplicar; si vale, registra la accion, la aplica y registra lo que
# paso. paso: el de la IA, o null si es del jugador.
func _ejecutar(accion: Accion, origen: String, paso: Variant) -> ResultadoAccion:
	var validacion: ResultadoAccion = _turno.validar(accion)
	if not validacion.valida:
		return validacion
	var unidad_id: String = _turno.unidad_id
	_registrar({"tipo": "accion", "unidad": unidad_id, "origen": origen,
			"accion": accion.a_diccionario(), "paso": paso})
	var estados_antes: Dictionary = _estados()
	var desde: Vector2i = _posicion(unidad_id)
	var vida_antes: int = 0
	if accion.tipo == Accion.Tipo.ATACAR or accion.tipo == Accion.Tipo.HECHIZO:
		vida_antes = _vida(accion.objetivo_id)

	var resultado: ResultadoAccion = _turno.aplicar(accion)
	if not resultado.valida:
		_error = "validar y aplicar no coinciden: " + str(accion.a_diccionario())
		return resultado
	# Sistema.md 1.6, 4.1, 3.1 y 11.5, D-007 (T22, T24, T26 y T27): el mana que paga un
	# hechizo, un sellado, una invocacion o guardar a una caida, justo detras de su `accion`. Se
	# registra sin volcar tiradas: la del sellado va despues, detras de la que se
	# pago (A.7). Despues, el Martillazo es un `ataque` normal (es un ataque) y la
	# Lanzadera, el Remiendo y el sellado, su propio evento.
	if not resultado.mana.is_empty():
		_registrar({"tipo": "mana", "unidad": unidad_id, "de": resultado.mana["de"], "a": resultado.mana["a"],
				"motivo": _motivo_mana(accion)}, 0)
	if accion.tipo == Accion.Tipo.HECHIZO:
		if resultado.desglose != null:
			_registrar_ataque(unidad_id, accion.objetivo_id, resultado, vida_antes)
		else:
			_registrar(resultado.evento.duplicate(true))
	match accion.tipo:
		Accion.Tipo.MOVER:
			_registrar({"tipo": "movimiento", "unidad": unidad_id,
					"desde": Plantel.casilla_a_lista(desde), "hasta": Plantel.casilla_a_lista(accion.casilla)})
		Accion.Tipo.ATACAR:
			_registrar_ataque(unidad_id, accion.objetivo_id, resultado, vida_antes)
		# Sistema.md 10.1 (T17, A.7): detras de quien y en que lugar de la cola
		# quedo (desde 0). El turno no termino: no hay fin_turno.
		Accion.Tipo.SECUNDAR:
			_registrar({"tipo": "secundar", "unidad": unidad_id, "detras_de": accion.aliado_id,
					"lugar": _cola.lugar_de(unidad_id)})
		# Sistema.md 4.1 (T24, A.7): el `sellado`, detras de su `tirada` (se vuelca sola).
		Accion.Tipo.SELLAR:
			_registrar(resultado.evento.duplicate(true))
		# Sistema.md 3.1 (T26, A.7): la invocada pasa a suelta y despues va la
		# `invocacion`; los destapes por contacto, detras.
		Accion.Tipo.INVOCAR:
			_registrar_estados(estados_antes)
			estados_antes = _estados()
			_registrar(resultado.evento.duplicate(true))
		# Sistema.md 11.5 (T27, A.7): la caida pasa a guardada y despues va el
		# `guardado_caida`; sus surcos cerrados, detras (_registrar_surcos).
		Accion.Tipo.GUARDAR_CAIDA:
			_registrar_estados(estados_antes)
			estados_antes = _estados()
			_registrar(resultado.evento.duplicate(true))
	_registrar_eventos_turno()
	_registrar_estados(estados_antes)
	_registrar_surcos()
	# Los cortes de la accion (otra objetivo, objetivo que ya no es hostil).
	_registrar_cadena()

	_fin = resultado.fin
	if _fin != FinCombate.Fin.EN_CURSO:
		_terminar()
	elif accion.tipo == Accion.Tipo.TERMINAR:
		_registrar({"tipo": "fin_turno", "unidad": unidad_id,
				"posicion": Plantel.casilla_a_lista(_posicion(unidad_id))})
		_registrar_tras_fin_turno(unidad_id)
	# Sistema.md 3.1 y S-54 (T26, A.7): guardarse termina el turno. Su fin_turno va
	# sin posicion (ya no esta en el tablero), asi que no hay encierro que medir.
	elif accion.tipo == Accion.Tipo.GUARDAR:
		_registrar({"tipo": "fin_turno", "unidad": unidad_id, "posicion": null})
	return resultado


# D-007: el motivo del evento `mana` que paga la accion.
func _motivo_mana(accion: Accion) -> String:
	match accion.tipo:
		Accion.Tipo.SELLAR:
			return Sellado.MOTIVO_SELLAR
		Accion.Tipo.INVOCAR:
			return CostosMana.MOTIVO_INVOCAR
		Accion.Tipo.GUARDAR_CAIDA:
			return GuardadoCaida.MOTIVO_GUARDAR_CAIDA
	return Hechizos.MOTIVO_HECHIZO


# Sistema.md 11.9, metricas 13 y 14 (T23, D-011, A.7): los dos datos que el
# registro no tenia, calculados por el Tablero en el momento y escritos justo
# detras del `fin_turno`: la distancia del Maestro a la enemiga de pie mas
# cercana (en todos sus turnos) y el encierro (solo cuando pasa). Con los dos,
# primero la distancia.
func _registrar_tras_fin_turno(unidad_id: String) -> void:
	var tablero: Tablero = _contexto.tablero
	var casilla: Vector2i = _posicion(unidad_id)
	if unidad_id == Maestro.ID:
		_registrar({"tipo": "distancia_maestro",
				"distancia": tablero.distancia_a_enemiga_de_pie(casilla, Criatura.Bando.TRIBU, _plantel)})
	if tablero.encerrada(casilla, _plantel, _surcos):
		_registrar({"tipo": "encierro", "unidad": unidad_id, "casilla": Plantel.casilla_a_lista(casilla)})


# Arquitectura.md A.7: el evento `ataque` de un ataque o del Martillazo.
func _registrar_ataque(atacante_id: String, objetivo_id: String, resultado: ResultadoAccion, vida_antes: int) -> void:
	_registrar({"tipo": "ataque", "atacante": atacante_id, "objetivo": objetivo_id,
			"desglose": resultado.desglose.a_diccionario(), "eslabon": resultado.eslabon,
			"vida_antes": vida_antes, "vida_despues": _vida(objetivo_id)})


# Sistema.md 11.5: el combate termino. Se registra el desenlace y el Cierre
# corre una sola vez; no se juega ninguna entrada mas. Antes, la cadena que
# quede se corta: toda cadena termina con su cadena_cortada (A.7).
func _terminar() -> void:
	_cadena.cortar(Cadena.MOTIVO_FIN_COMBATE)
	_registrar_cadena()
	_registrar({"tipo": "fin", "desenlace": (FinCombate.Fin.keys()[_fin] as String).to_lower()})
	var ardidos_antes: Array[String] = _pergaminos_ardidos()
	var cierre: ResultadoCierre = _contexto.cierre.cerrar(_plantel, _fin)
	if not cierre.valido:
		_error = "cierre rechazado: " + ResultadoCierre.Motivo.keys()[cierre.motivo]
		return
	var ardidos: Array[String] = []
	for id_pergamino in _pergaminos_ardidos():
		if not ardidos_antes.has(id_pergamino):
			ardidos.append(id_pergamino)
	_resultado = ResultadoCombate.armar(_contexto, cierre, _cola.ronda, ardidos)
	_registrar({"tipo": "cierre", "levantadas": cierre.levantadas.duplicate(),
			"muertas": cierre.muertas.duplicate(), "pergaminos_ardidos": ardidos.duplicate(),
			"lealtad": ResultadoCombate.cambios_a_lista(cierre.lealtad)})
	# Sistema.md 11.9 y D-011 (T23): las metricas, sobre el registro completo.
	_resultado.metricas = MetricasCombate.calcular(_contexto.escenario, _registro.lineas())


# Arquitectura.md A.7: antes de cada evento se vuelcan las tiradas nuevas del
# generador de combate (lo que registra T02), asi quedan en orden.
# tiradas: cuantas de las pendientes se vuelcan antes (-1, todas). Menos solo
# para un evento que paso antes que alguna tirada pendiente: el cambio de modo
# (0, antes de las tiradas de los pasos 3 y 4, T18) y el chequeo de rival (solo
# la suya, antes de la del incidente, T19).
func _registrar(evento: Dictionary, tiradas: int = -1) -> void:
	var historial: Array[Dictionary] = _contexto.azar_combate.historial()
	var hasta: int = historial.size() if tiradas < 0 else mini(historial.size(), _tiradas_volcadas + tiradas)
	for indice in range(_tiradas_volcadas, hasta):
		var tirada: Dictionary = historial[indice]
		_agregar({"tipo": "tirada", "ronda": _cola.ronda, "indice": tirada["indice"],
				"metodo": tirada["metodo"], "parametros": tirada["parametros"],
				"resultado": tirada["resultado"]})
	_tiradas_volcadas = maxi(_tiradas_volcadas, hasta)
	evento["ronda"] = _cola.ronda
	_agregar(evento)


func _agregar(evento: Dictionary) -> void:
	if not _registro.agregar(evento) and _error.is_empty():
		_error = "registro: " + _registro.error


# id -> nombre del estado, en el orden del Plantel (el Maestro primero).
func _estados() -> Dictionary:
	var estados: Dictionary = {Maestro.ID: _MAESTRO_CAIDO if _plantel.maestro.caido else _MAESTRO_EN_PIE}
	for criatura in _plantel.criaturas():
		estados[criatura.id] = Plantel.nombre_estado(criatura.estado)
	return estados


# Un evento `estado` por cada unidad que cambio desde `antes`.
func _registrar_estados(antes: Dictionary) -> void:
	var ahora: Dictionary = _estados()
	for id_unidad in antes.keys():
		if antes[id_unidad] != ahora[id_unidad]:
			_registrar({"tipo": "estado", "unidad": id_unidad, "de": antes[id_unidad], "a": ahora[id_unidad]})


# Arquitectura.md A.7: los eventos `surco` y `surco_cerrado` nuevos, en el orden
# en que pasaron (al cavar, el nuevo antes que el cerrado por el tope).
func _registrar_surcos() -> void:
	var historial: Array[Dictionary] = _surcos.historial()
	for indice in range(_surcos_volcados, historial.size()):
		_registrar(historial[indice])
	_surcos_volcados = historial.size()


# Arquitectura.md A.7 (B.2.1 y T19): los eventos `encono`, `oculto`, `destape` y
# `bono_perdido` nuevos del turno, en el orden en que pasaron, despues del evento
# de la accion (el `encono`, justo detras del `ataque` que sube el contador).
func _registrar_eventos_turno() -> void:
	var eventos: Array[Dictionary] = _turno.eventos()
	for indice in range(_junco_volcados, eventos.size()):
		_registrar(eventos[indice])
	_junco_volcados = eventos.size()


# Arquitectura.md A.7 (T16): los eventos cadena_cortada nuevos, en orden.
func _registrar_cadena() -> void:
	var historial: Array[Dictionary] = _cadena.historial()
	for indice in range(_cadena_volcados, historial.size()):
		_registrar(historial[indice])
	_cadena_volcados = historial.size()


func _pergaminos_ardidos() -> Array[String]:
	var ids: Array[String] = []
	for pergamino in _plantel.pergaminos():
		if pergamino.estado == Pergamino.Estado.ARDIDO:
			ids.append(pergamino.id)
	return ids


func _es_del_jugador(unidad_id: String) -> bool:
	return unidad_id == Maestro.ID or _plantel.criatura(unidad_id).bando == Criatura.Bando.TRIBU


func _posicion(unidad_id: String) -> Vector2i:
	if unidad_id == Maestro.ID:
		return _plantel.maestro.posicion
	return _plantel.criatura(unidad_id).posicion


func _vida(unidad_id: String) -> int:
	if unidad_id == Maestro.ID:
		return _plantel.maestro.vida
	return _plantel.criatura(unidad_id).vida


# T24: la criatura si es una salvaje de pie, sellable y de un rango que la
# balanza alcanza; si no, null.
func _sellable(unidad_id: String) -> Criatura:
	var criatura: Criatura = _plantel.criatura(unidad_id)
	if criatura == null or criatura.comportamiento != Criatura.Comportamiento.SALVAJE \
			or not Objetivos.de_pie(unidad_id, _plantel) or not criatura.especie.sellable() \
			or not _contexto.sellado.rango_permitido(criatura.especie, _plantel.maestro):
		return null
	return criatura
