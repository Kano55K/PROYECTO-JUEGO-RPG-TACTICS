# Sistema.md 11.3, Turno de una unidad: el turno de una entrada de la cola (T07).
# 1 movimiento y 1 accion, en cualquier orden, sin partir el movimiento, salvo
# lo que diga el modo de la unidad (11.2.3): los pasos y los ataques del turno
# salen de ahi. Toda accion se valida con la misma funcion que la aplica, sin
# modificar nada; una accion invalida no cambia nada.
class_name Turno
extends RefCounted

# Sistema.md 11.2: el efecto de rasgo que habilita Erizarse. Nunca se mira el id.
const _EFECTO_ERIZARSE: String = "erizarse"

var unidad_id: String
# La de la entrada: "caza", "cuenta" o "". Es el modo al armar la ronda; el
# turno juega con el modo actual de la criatura (puede cambiar al empezar).
var marca: String
# Los pasos que le quedan: el Movimiento de la ficha o de maestro.json. Sin
# movimiento partido, el primer `mover` los gasta todos (11.3).
var pasos_restantes: int = 0
# Los ataques que le quedan: los del modo (1 por defecto, 11.2.3).
var ataques_restantes: int = 0
# true cuando ya no le quedan pasos (los gasto o un rasgo cerro el movimiento).
var movimiento_usado: bool = false
# true cuando ya uso alguna accion (en Caza, desde el primer ataque).
var accion_usada: bool = false
var terminado: bool = false
# Sistema.md 11.2.3: {de, a} si el inicio de este turno le cambio el modo; si no, {}.
var cambio_modo: Dictionary = {}
# true desde su primer `mover` aplicado (cavar exige no haberse movido, 11.2.1).
var se_movio: bool = false

var _ataques_hechos: int = 0
var _movimiento_partido: bool = false
# Sistema.md 11.2.2, Limite: si se oculto en este turno (lo guarda el fin del turno).
var _se_oculto: bool = false
# Arquitectura.md A.7: los eventos de Junco de las acciones aplicadas, en orden.
var _eventos: Array[Dictionary] = []

var _plantel: Plantel
var _tablero: Tablero
var _danio: Danio
# Los del combate (los guarda el Combate, T37).
var _surcos: Surcos


func _init(entrada: EntradaCola, plantel: Plantel, tablero: Tablero, danio: Danio, surcos: Surcos) -> void:
	unidad_id = entrada.unidad_id
	marca = entrada.marca
	_plantel = plantel
	_tablero = tablero
	_danio = danio
	_surcos = surcos


# Crea el turno de la entrada y corre el inicio del turno. surcos: los del
# combate (un turno suelto de los tests pasa unos vacios).
static func empezar(entrada: EntradaCola, plantel: Plantel, tablero: Tablero, danio: Danio,
		surcos: Surcos) -> Turno:
	var turno: Turno = Turno.new(entrada, plantel, tablero, danio, surcos)
	turno._inicio_del_turno()
	turno._preparar()
	return turno


# Dice si la accion vale (y que haria) sin cambiar el Plantel ni el turno.
func validar(accion: Accion) -> ResultadoAccion:
	return _resolver(accion, false)


func aplicar(accion: Accion) -> ResultadoAccion:
	return _resolver(accion, true)


# Para la pantalla y la IA: lo que la unidad puede hacer ahora, sin modificar nada.
func casillas_para_mover() -> Array[Vector2i]:
	var resultado: Array[Vector2i] = []
	for casilla in _tablero.alcanzables(_posicion(unidad_id), pasos_restantes, _bando(unidad_id), _plantel,
			_surcos, Surcos.es_surcon(unidad_id, _plantel)):
		if validar(Accion.mover(casilla)).valida:
			resultado.append(casilla)
	return resultado


# Ids en el orden del Plantel: el Maestro y despues las criaturas.
func objetivos_para_atacar() -> Array[String]:
	var resultado: Array[String] = []
	var ids: Array[String] = [Maestro.ID]
	for criatura in _plantel.criaturas():
		ids.append(criatura.id)
	for id_objetivo in ids:
		if validar(Accion.atacar(id_objetivo)).valida:
			resultado.append(id_objetivo)
	return resultado


# Casilla -> pasos: la actual (0) y cada destino que `mover` acepta (11.8, "la de
# menos movimiento"). Los pasos son los del camino que da Tablero.
func pasos_para_mover() -> Dictionary:
	var desde: Vector2i = _posicion(unidad_id)
	var pasos: Dictionary = _pasos_desde(desde)
	var resultado: Dictionary = {desde: 0}
	for casilla in casillas_para_mover():
		resultado[casilla] = pasos[casilla]
	return resultado


# Sistema.md 11.8, "puede tumbar" y "puede alcanzar" (S-8): el ataque como si la
# unidad se hubiera movido a `desde`, sin modificar nada. Pasa por la misma
# funcion que el ataque real (mismas comprobaciones, mismo danio y aportes) y no
# cambia el estado de nadie. Si no puede llegar a `desde`, se rechaza con el motivo
# del movimiento.
func previsualizar_ataque(desde: Vector2i, objetivo_id: String) -> ResultadoAccion:
	if desde != _posicion(unidad_id):
		var movimiento: ResultadoAccion = validar(Accion.mover(desde))
		if not movimiento.valida:
			return movimiento
	var fin: FinCombate.Fin = FinCombate.evaluar(_plantel)
	if fin != FinCombate.Fin.EN_CURSO:
		var rechazo: ResultadoAccion = ResultadoAccion.rechazada(ResultadoAccion.Motivo.COMBATE_TERMINADO)
		rechazo.fin = fin
		return rechazo
	return _atacar_desde(desde, objetivo_id, false)


# Sistema.md 11.2.1: las casillas donde `cavar` vale ahora, en orden de lectura
# (la IA del paso 7 de 11.8 y la pantalla, T40).
func casillas_para_cavar() -> Array[Vector2i]:
	var resultado: Array[Vector2i] = []
	for casilla in _tablero.vecinas(_posicion(unidad_id)):
		if validar(Accion.cavar(casilla)).valida:
			resultado.append(casilla)
	resultado.sort_custom(func(a: Vector2i, b: Vector2i) -> bool: return a.y < b.y or (a.y == b.y and a.x < b.x))
	return resultado


# Los surcos de la unidad, del mas viejo al mas nuevo (11.2.1, Tope).
func surcos_propios() -> Array[Vector2i]:
	return _surcos.de(unidad_id)


# Sistema.md 11.8, retirada de la Cuenta: casilla -> pasos a los que llegaria
# despues de moverse a `desde` y atacar, con los pasos que le quedarian. Sin
# movimiento partido no le queda ninguno: solo `desde`. La casilla que deja
# cuenta como vacia. Atacar no cambia quien ocupa casillas (la de la tribu que
# cae sigue en la suya, 11.5), asi que se puede calcular antes. No modifica nada.
func pasos_para_retirarse(desde: Vector2i) -> Dictionary:
	var origen: Vector2i = _posicion(unidad_id)
	var hasta_desde: Dictionary = _pasos_desde(origen)
	if not _movimiento_partido or not hasta_desde.has(desde):
		return {desde: 0}
	return _tablero.pasos_hasta(desde, pasos_restantes - hasta_desde[desde], _bando(unidad_id), _plantel,
			_surcos, Surcos.es_surcon(unidad_id, _plantel), origen)


func puede_erizarse() -> bool:
	return validar(Accion.erizarse()).valida


# Copia de los eventos de Junco (oculto, destape, bono_perdido) de las acciones
# aplicadas en este turno, para que el Combate registre los nuevos.
func eventos() -> Array[Dictionary]:
	return _eventos.duplicate(true)


func puede_terminar() -> bool:
	return validar(Accion.terminar()).valida


# Sistema.md 11.3, Inicio del turno. Primero se borra la marca de erizada: dura
# hasta el inicio de su proximo turno (11.2, S-15). Despues van los chequeos de
# 11.3, en este orden:
#   1. Regeneracion de mana del Maestro (2.1): T21.
#   2. Huida de las salvajes con vida <= 25% (11.7): T25. Si sale, el turno termina ahi.
#   Cambio de modo (11.2.3, 11.8 paso 2): una regla, no una decision de la IA.
#   3. Rival enemiga a su alcance: Encono (10.5) o cobardia (10.6): T19.
#   4. Incidente con rival aliada (10.4), solo si no quedo enconada: T18.
func _inicio_del_turno() -> void:
	var criatura: Criatura = _plantel.criatura(unidad_id)
	if criatura != null:
		criatura.erizada = false
		cambio_modo = CambioModo.aplicar(criatura)


# Despues del inicio: el turno se juega con el modo que quedo (11.2.3, "juega
# ese turno en Cuenta").
func _preparar() -> void:
	pasos_restantes = _movimiento()
	ataques_restantes = 1
	var criatura: Criatura = _plantel.criatura(unidad_id)
	if criatura != null:
		ataques_restantes = criatura.especie.ataques_por_turno(criatura.modo)
		_movimiento_partido = criatura.especie.movimiento_partido(criatura.modo)


# Punto de fin del turno: aca se enchufan T16 (cadena de combos y registro de
# "esperar") y T23. Sistema.md 11.2.2, Limite: queda anotado si se oculto en
# este turno, para el proximo.
func _fin_del_turno() -> void:
	var criatura: Criatura = _plantel.criatura(unidad_id)
	if criatura != null:
		criatura.junco_turno_anterior = _se_oculto


# Sistema.md 11.5: con el combate terminado se rechaza todo. Despues de cada
# accion aplicada se mira si termino, y el resultado dice como.
func _resolver(accion: Accion, aplica: bool) -> ResultadoAccion:
	var fin: FinCombate.Fin = FinCombate.evaluar(_plantel)
	if fin != FinCombate.Fin.EN_CURSO:
		var rechazo: ResultadoAccion = ResultadoAccion.rechazada(ResultadoAccion.Motivo.COMBATE_TERMINADO)
		rechazo.fin = fin
		return rechazo
	var resultado: ResultadoAccion
	match accion.tipo:
		Accion.Tipo.MOVER:
			resultado = _mover(accion.casilla, aplica)
		Accion.Tipo.ATACAR:
			resultado = _atacar_desde(_posicion(unidad_id), accion.objetivo_id, aplica)
		Accion.Tipo.ERIZARSE:
			resultado = _erizarse(aplica)
		Accion.Tipo.CAVAR:
			resultado = _cavar(accion.casilla, aplica)
		Accion.Tipo.HACERSE_JUNCO:
			resultado = _hacerse_junco(aplica)
		_:
			resultado = _terminar(aplica)
	if aplica and resultado.valida:
		resultado.fin = FinCombate.evaluar(_plantel)
	return resultado


# Sistema.md 11.3, Movimiento: a una casilla alcanzable (Tablero) con los pasos
# que quedan. Sin movimiento partido se gasta entero aunque sobren pasos; con
# movimiento partido (Cuenta, 11.2.3) gasta los del camino mas corto y puede
# volver a moverse, antes y despues de atacar. Sin partir y con mas de un
# ataque (Caza), no se mueve entre el primero y el ultimo (S-23).
func _mover(destino: Vector2i, aplica: bool) -> ResultadoAccion:
	if terminado:
		return ResultadoAccion.rechazada(ResultadoAccion.Motivo.TURNO_TERMINADO)
	if _inmovil(unidad_id):
		return ResultadoAccion.rechazada(ResultadoAccion.Motivo.ERIZADA)
	if movimiento_usado:
		return ResultadoAccion.rechazada(ResultadoAccion.Motivo.MOVIMIENTO_USADO)
	if not _movimiento_partido and _ataques_hechos > 0 and ataques_restantes > 0:
		return ResultadoAccion.rechazada(ResultadoAccion.Motivo.MOVER_ENTRE_ATAQUES)
	var desde: Vector2i = _posicion(unidad_id)
	if destino == desde:
		return ResultadoAccion.rechazada(ResultadoAccion.Motivo.MISMA_CASILLA)
	var pasos: Dictionary = _pasos_desde(desde)
	if not pasos.has(destino):
		return ResultadoAccion.rechazada(ResultadoAccion.Motivo.CASILLA_NO_ALCANZABLE)
	if aplica:
		_poner_posicion(unidad_id, destino)
		_gastar_pasos(pasos[destino] if _movimiento_partido else pasos_restantes)
		se_movio = true
		# Sistema.md 11.2.2: moverse destapa (conserva el bono). Despues, el
		# contacto: este movimiento termino aca (en Cuenta, cada tramo).
		var criatura: Criatura = _plantel.criatura(unidad_id)
		if criatura != null:
			_eventos.append_array(Junco.destapar(criatura, Junco.MOTIVO_MOVER))
		_eventos.append_array(Junco.revisar_contacto(unidad_id, _plantel))
	return ResultadoAccion.aceptada()


func _gastar_pasos(cantidad: int) -> void:
	pasos_restantes -= cantidad
	movimiento_usado = pasos_restantes == 0


# Los caminos de Tablero con los pasos que quedan, los surcos del combate y si
# la unidad los pisa (11.2.1, Transito: un Surcon de cualquier bando).
func _pasos_desde(desde: Vector2i) -> Dictionary:
	return _tablero.pasos_hasta(desde, pasos_restantes, _bando(unidad_id), _plantel,
			_surcos, Surcos.es_surcon(unidad_id, _plantel))


# Sistema.md 11.3: atacar gasta uno de los ataques del turno (dos en Caza,
# 11.2.3: separados, a una o a dos presas). La objetivo es una enemiga que la
# consulta unica acepta para una accion hostil (Objetivos: no caida, fuera,
# guardada ni oculta), en una casilla que la unidad golpea desde donde esta. La
# consulta se hace en el momento del ataque: la que se destapo al moverse en
# este turno ya vale (destapar y pegar, 11.2.2 v1.4). La vida no baja de 0, y
# en 0 se resuelve en el acto, solo al aplicar (11.5, VidaCero). `desde` es la
# casilla de la unidad; otra solo para previsualizar (nunca se aplica desde otra).
func _atacar_desde(desde: Vector2i, objetivo_id: String, aplica: bool) -> ResultadoAccion:
	if terminado:
		return ResultadoAccion.rechazada(ResultadoAccion.Motivo.TURNO_TERMINADO)
	if ataques_restantes == 0:
		return ResultadoAccion.rechazada(ResultadoAccion.Motivo.ACCION_USADA)
	var motivo: ResultadoAccion.Motivo = Objetivos.motivo(objetivo_id, Objetivos.Clase.HOSTIL, _plantel)
	if motivo == ResultadoAccion.Motivo.OBJETIVO_INEXISTENTE:
		return ResultadoAccion.rechazada(motivo)
	if _bando(objetivo_id) == _bando(unidad_id):
		return ResultadoAccion.rechazada(ResultadoAccion.Motivo.OBJETIVO_ALIADO)
	if motivo != ResultadoAccion.Motivo.NINGUNO:
		return ResultadoAccion.rechazada(motivo)
	var hasta: Vector2i = _posicion(objetivo_id)
	var bando: Criatura.Bando = _bando(unidad_id)
	if not _tablero.golpeables(desde, _alcance(), bando, _plantel).has(hasta):
		if _tablero.en_linea(desde, hasta) and Tablero.distancia(desde, hasta) <= _alcance() \
				and _tablero.linea_bloqueada(desde, hasta, bando, _plantel):
			return ResultadoAccion.rechazada(ResultadoAccion.Motivo.LINEA_BLOQUEADA)
		return ResultadoAccion.rechazada(ResultadoAccion.Motivo.FUERA_DE_ALCANCE)

	var resultado: ResultadoAccion = ResultadoAccion.aceptada()
	resultado.desglose = _danio.calcular(unidad_id, objetivo_id, _plantel, _aportes(desde, objetivo_id))
	resultado.danio = resultado.desglose.total
	if aplica:
		_poner_vida(objetivo_id, maxi(0, _vida(objetivo_id) - resultado.danio))
		# Sistema.md 11.2.2: la atacante se destapa y cobra su bono; la objetivo
		# destapada pierde el suyo.
		_eventos.append_array(Junco.atacar(unidad_id, _plantel))
		_eventos.append_array(Junco.recibir_ataque(objetivo_id, unidad_id, _plantel))
		VidaCero.resolver(objetivo_id, _plantel, _surcos)
		ataques_restantes -= 1
		_ataques_hechos += 1
		accion_usada = true
	return resultado


# Punto vacio: los aportes externos del danio (11.4) para un ataque desde
# `desde`. Aca se enchufan afinidad (T15, depende de la casilla), combo (T16) y
# Encono o cobardia (T19); el ataque real y la previsualizacion los ven igual.
func _aportes(_desde: Vector2i, _objetivo_id: String) -> Array[ModificadorDanio]:
	return []


# Sistema.md 11.2, Erizarse: solo con el rasgo de la ficha; gasta la accion.
# Queda erizada hasta el inicio de su proximo turno y mientras tanto no se mueve
# por si misma: si ya se movio, vale; si no, pierde el movimiento (S-15, P-014).
# El -50% es de T09; que la Lanzadera la mueva, de T22.
func _erizarse(aplica: bool) -> ResultadoAccion:
	if terminado:
		return ResultadoAccion.rechazada(ResultadoAccion.Motivo.TURNO_TERMINADO)
	if accion_usada:
		return ResultadoAccion.rechazada(ResultadoAccion.Motivo.ACCION_USADA)
	var criatura: Criatura = _plantel.criatura(unidad_id)
	if criatura == null or criatura.especie.rasgo()["efecto"] != _EFECTO_ERIZARSE:
		return ResultadoAccion.rechazada(ResultadoAccion.Motivo.SIN_RASGO)
	if aplica:
		criatura.erizada = true
		accion_usada = true
		ataques_restantes = 0
		if _inmovil(unidad_id):
			_gastar_pasos(pasos_restantes)
	return ResultadoAccion.aceptada()


# Sistema.md 11.2.1, El surco: solo con el efecto surco de la ficha, sin haberse
# movido ni usado la accion, en una casilla ortogonalmente adyacente y libre
# (11.3, S-25). Puede estar junto a enemigas. Gasta el turno completo: despues
# solo vale terminar. Si el Surcon pasa su tope, se cierra su surco mas viejo.
func _cavar(casilla: Vector2i, aplica: bool) -> ResultadoAccion:
	if terminado:
		return ResultadoAccion.rechazada(ResultadoAccion.Motivo.TURNO_TERMINADO)
	if not Surcos.es_surcon(unidad_id, _plantel):
		return ResultadoAccion.rechazada(ResultadoAccion.Motivo.SIN_RASGO)
	if accion_usada:
		return ResultadoAccion.rechazada(ResultadoAccion.Motivo.ACCION_USADA)
	if se_movio:
		return ResultadoAccion.rechazada(ResultadoAccion.Motivo.YA_SE_MOVIO)
	if not _tablero.adyacentes(_posicion(unidad_id), casilla):
		return ResultadoAccion.rechazada(ResultadoAccion.Motivo.CASILLA_NO_ADYACENTE)
	if not _tablero.es_casilla_libre(casilla, _plantel, _surcos):
		return ResultadoAccion.rechazada(ResultadoAccion.Motivo.CASILLA_NO_LIBRE)
	if aplica:
		_surcos.cavar(casilla, unidad_id, _plantel.criatura(unidad_id).especie.rasgo()["tope"])
		accion_usada = true
		ataques_restantes = 0
		_gastar_pasos(pasos_restantes)
	return ResultadoAccion.aceptada()


# Sistema.md 11.2.2, Hacerse junco: solo con el efecto ocultarse de la ficha;
# gasta la accion. Sin haberse movido en el turno, sin ninguna enemiga de pie
# adyacente y no si se oculto en su turno anterior. Cierra el movimiento que
# quede, como Erizarse (S-26). Queda oculta y con el bono (Junco).
func _hacerse_junco(aplica: bool) -> ResultadoAccion:
	if terminado:
		return ResultadoAccion.rechazada(ResultadoAccion.Motivo.TURNO_TERMINADO)
	if not Junco.es_junco(unidad_id, _plantel):
		return ResultadoAccion.rechazada(ResultadoAccion.Motivo.SIN_RASGO)
	if accion_usada:
		return ResultadoAccion.rechazada(ResultadoAccion.Motivo.ACCION_USADA)
	if se_movio:
		return ResultadoAccion.rechazada(ResultadoAccion.Motivo.YA_SE_MOVIO)
	if _enemiga_de_pie_adyacente():
		return ResultadoAccion.rechazada(ResultadoAccion.Motivo.ENEMIGA_ADYACENTE)
	var criatura: Criatura = _plantel.criatura(unidad_id)
	if criatura.junco_turno_anterior:
		return ResultadoAccion.rechazada(ResultadoAccion.Motivo.JUNCO_TURNO_ANTERIOR)
	if aplica:
		_eventos.append_array(Junco.ocultar(criatura))
		_se_oculto = true
		accion_usada = true
		ataques_restantes = 0
		_gastar_pasos(pasos_restantes)
	return ResultadoAccion.aceptada()


func _enemiga_de_pie_adyacente() -> bool:
	var posicion: Vector2i = _posicion(unidad_id)
	var ids: Array[String] = [Maestro.ID]
	for otra in _plantel.criaturas():
		ids.append(otra.id)
	for id_otra in ids:
		if _bando(id_otra) != _bando(unidad_id) and Objetivos.de_pie(id_otra, _plantel) \
				and Tablero.distancia(_posicion(id_otra), posicion) == 1:
			return true
	return false


# Sistema.md 11.3: lo que no se uso se pierde. Sin haber usado la accion es
# "esperar" (10.2, P-015): el resultado lo dice para el registro y para T16.
func _terminar(aplica: bool) -> ResultadoAccion:
	if terminado:
		return ResultadoAccion.rechazada(ResultadoAccion.Motivo.TURNO_TERMINADO)
	var resultado: ResultadoAccion = ResultadoAccion.aceptada()
	resultado.espero = not accion_usada
	if aplica:
		terminado = true
		_fin_del_turno()
	return resultado


# Erizada con un rasgo que la deja inmovil (dato de la ficha).
func _inmovil(id_unidad: String) -> bool:
	var criatura: Criatura = _plantel.criatura(id_unidad)
	return criatura != null and criatura.erizada and criatura.especie.rasgo().get("inmovil", false)


# Lectura y escritura de una unidad por id: el Maestro o una criatura (A.5).
func _bando(id_unidad: String) -> Criatura.Bando:
	if id_unidad == Maestro.ID:
		return Criatura.Bando.TRIBU
	return _plantel.criatura(id_unidad).bando


func _posicion(id_unidad: String) -> Vector2i:
	if id_unidad == Maestro.ID:
		return _plantel.maestro.posicion
	return _plantel.criatura(id_unidad).posicion


func _poner_posicion(id_unidad: String, casilla: Vector2i) -> void:
	if id_unidad == Maestro.ID:
		_plantel.maestro.posicion = casilla
	else:
		_plantel.criatura(id_unidad).posicion = casilla


func _vida(id_unidad: String) -> int:
	if id_unidad == Maestro.ID:
		return _plantel.maestro.vida
	return _plantel.criatura(id_unidad).vida


func _poner_vida(id_unidad: String, valor: int) -> void:
	if id_unidad == Maestro.ID:
		_plantel.maestro.vida = valor
	else:
		_plantel.criatura(id_unidad).vida = valor


# Sistema.md 11.2: de la ficha, o de maestro.json, sin modificadores.
func _movimiento() -> int:
	if unidad_id == Maestro.ID:
		return _plantel.maestro.movimiento
	return _plantel.criatura(unidad_id).especie.movimiento()


func _alcance() -> int:
	if unidad_id == Maestro.ID:
		return _plantel.maestro.alcance
	return _plantel.criatura(unidad_id).especie.alcance()
