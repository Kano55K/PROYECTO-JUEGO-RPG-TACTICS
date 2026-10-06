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


func _init(contexto_combate: ContextoCombate) -> void:
	_contexto = contexto_combate
	_plantel = contexto_combate.plantel


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
				_cola.terminar_ronda()
				_registrar({"tipo": "fin_ronda"})
			_cola.empezar_ronda(_plantel)
			_registrar({"tipo": "ronda"})
			continue
		# Antes de empezar el turno: las tiradas de su inicio (T18 a T25) van despues.
		_registrar({"tipo": "turno", "unidad": entrada.unidad_id,
				"marca": null if entrada.marca.is_empty() else entrada.marca})
		_turno = Turno.empezar(entrada, _plantel, _contexto.tablero, _contexto.danio, _surcos)
		_junco_volcados = 0
		# Sistema.md 11.2.3: el cambio de modo del inicio del turno (A.7).
		if not _turno.cambio_modo.is_empty():
			_registrar({"tipo": "cambio_modo", "unidad": entrada.unidad_id,
					"de": _turno.cambio_modo["de"], "a": _turno.cambio_modo["a"]})


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
	if accion.tipo == Accion.Tipo.ATACAR:
		vida_antes = _vida(accion.objetivo_id)

	var resultado: ResultadoAccion = _turno.aplicar(accion)
	if not resultado.valida:
		_error = "validar y aplicar no coinciden: " + str(accion.a_diccionario())
		return resultado
	match accion.tipo:
		Accion.Tipo.MOVER:
			_registrar({"tipo": "movimiento", "unidad": unidad_id,
					"desde": Plantel.casilla_a_lista(desde), "hasta": Plantel.casilla_a_lista(accion.casilla)})
		Accion.Tipo.ATACAR:
			_registrar({"tipo": "ataque", "atacante": unidad_id, "objetivo": accion.objetivo_id,
					"desglose": resultado.desglose.a_diccionario(),
					"vida_antes": vida_antes, "vida_despues": _vida(accion.objetivo_id)})
	_registrar_junco()
	_registrar_estados(estados_antes)
	_registrar_surcos()

	_fin = resultado.fin
	if _fin != FinCombate.Fin.EN_CURSO:
		_terminar()
	elif accion.tipo == Accion.Tipo.TERMINAR:
		_registrar({"tipo": "fin_turno", "unidad": unidad_id,
				"posicion": Plantel.casilla_a_lista(_posicion(unidad_id))})
	return resultado


# Sistema.md 11.5: el combate termino. Se registra el desenlace y el Cierre
# corre una sola vez; no se juega ninguna entrada mas.
func _terminar() -> void:
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


# Arquitectura.md A.7: antes de cada evento se vuelcan las tiradas nuevas del
# generador de combate (lo que registra T02), asi quedan en orden.
func _registrar(evento: Dictionary) -> void:
	var historial: Array[Dictionary] = _contexto.azar_combate.historial()
	for indice in range(_tiradas_volcadas, historial.size()):
		var tirada: Dictionary = historial[indice]
		_agregar({"tipo": "tirada", "ronda": _cola.ronda, "indice": tirada["indice"],
				"metodo": tirada["metodo"], "parametros": tirada["parametros"],
				"resultado": tirada["resultado"]})
	_tiradas_volcadas = historial.size()
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


# Arquitectura.md A.7 (B.2.1): los eventos `oculto`, `destape` y `bono_perdido`
# nuevos del turno, en el orden en que pasaron, despues del evento de la accion.
func _registrar_junco() -> void:
	var eventos: Array[Dictionary] = _turno.eventos()
	for indice in range(_junco_volcados, eventos.size()):
		_registrar(eventos[indice])
	_junco_volcados = eventos.size()


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
