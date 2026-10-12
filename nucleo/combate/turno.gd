# Sistema.md 11.3, Turno de una unidad: el turno de una entrada de la cola (T07).
# 1 movimiento y 1 accion, en cualquier orden, sin partir el movimiento, salvo
# lo que diga el modo de la unidad (11.2.3): los pasos y los ataques del turno
# salen de ahi. Toda accion se valida con la misma funcion que la aplica, sin
# modificar nada; una accion invalida no cambia nada.
class_name Turno
extends RefCounted

# Sistema.md 11.2: el efecto de rasgo que habilita Erizarse. Nunca se mira el id.
const EFECTO_ERIZARSE: String = "erizarse"
# S-35 (T19): lo que obliga el Encono en este turno. ATACAR: alcanza a alguna
# rival del chequeo; ACERCARSE: no alcanza a ninguna.
enum Obligacion { NINGUNA, ATACAR, ACERCARSE }

# Arquitectura.md A.7 (T18): el resultado del evento incidente.
const RESULTADO_DISTRAIDA: String = "distraida"
const RESULTADO_GOLPE: String = "golpe"
# T24: los motivos de una objetivo de _motivo_sellar, en el orden en que los
# revisa (despues de los del Maestro). Lo usa motivo_sellar para decir el que
# mas lejos llego; el test del orden lo comprueba contra _motivo_sellar.
const _ORDEN_SELLAR: Array[ResultadoAccion.Motivo] = [
	ResultadoAccion.Motivo.OBJETIVO_INEXISTENTE,
	ResultadoAccion.Motivo.OBJETIVO_ALIADO,
	ResultadoAccion.Motivo.OBJETIVO_FUERA_DEL_TABLERO,
	ResultadoAccion.Motivo.OBJETIVO_CAIDO,
	ResultadoAccion.Motivo.OBJETIVO_OCULTO,
	ResultadoAccion.Motivo.OBJETIVO_NO_SALVAJE,
	ResultadoAccion.Motivo.FUERA_DE_ALCANCE,
	ResultadoAccion.Motivo.NO_SELLABLE,
	ResultadoAccion.Motivo.RANGO_ALTO,
	ResultadoAccion.Motivo.MANA_INSUFICIENTE,
]
# T27: los motivos de una caida de _motivo_guardar_caida, en el orden en que los
# revisa (despues de los del Maestro). Lo usa motivo_guardar_caida, como _ORDEN_SELLAR.
const _ORDEN_GUARDAR_CAIDA: Array[ResultadoAccion.Motivo] = [
	ResultadoAccion.Motivo.OBJETIVO_INEXISTENTE,
	ResultadoAccion.Motivo.OBJETIVO_FUERA_DEL_TABLERO,
	ResultadoAccion.Motivo.OBJETIVO_NO_CAIDO,
	ResultadoAccion.Motivo.OBJETIVO_ENEMIGO,
	ResultadoAccion.Motivo.FUERA_DE_ALCANCE,
	ResultadoAccion.Motivo.MANA_INSUFICIENTE,
]

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
# Sistema.md 10.4 (T18): {rivales, porcentaje, resultado, objetivo} si el inicio
# de este turno tuvo un incidente; si no, {}. resultado: RESULTADO_DISTRAIDA o
# RESULTADO_GOLPE; objetivo: la rival golpeada o null.
var incidente: Dictionary = {}
# El golpe del incidente para el registro: {desglose, vida_antes, vida_despues}, o {}.
var golpe_incidente: Dictionary = {}
# Sistema.md 10.5 y 10.6 (T19): {tipo, rivales, porcentaje, tiro, resultado} si el
# inicio de este turno tuvo chequeo de rival enemiga (tirada o enconada segura); si no, {}.
var chequeo_rival: Dictionary = {}
# Sistema.md 2.1 (T21): {de, a} si el inicio de este turno le cambio el mana al
# Maestro (paso 1 de 11.3); si no, {}.
var mana: Dictionary = {}
# Sistema.md 11.7 (T25): {porcentaje, tiro, resultado} si el inicio de este turno
# tiro huida (paso 2 de 11.3); si no, {}. resultado: Huida.RESULTADO_HUYE o
# RESULTADO_SE_QUEDA.
var huida: Dictionary = {}
# Estados del turno (duran este turno): los ven las consultas, nunca se guardan.
var enconada: bool = false
var acobardada: bool = false
var obligacion: Obligacion = Obligacion.NINGUNA

var _ataques_hechos: int = 0
var _movimiento_partido: bool = false
# Sistema.md 11.2.2, Limite: si se oculto en este turno (lo guarda el fin del turno).
var _se_oculto: bool = false
# Arquitectura.md A.7: los eventos de las acciones aplicadas (Junco y encono), en orden.
var _eventos: Array[Dictionary] = []
# Sistema.md 10.5 y 10.6: las rivales del chequeo y la casilla donde empezo el turno.
var _rivales_chequeo: Array[String] = []
var _casilla_inicial: Vector2i = Criatura.SIN_POSICION

var _plantel: Plantel
var _tablero: Tablero
var _danio: Danio
# Los del combate (los guarda el Combate, T37).
var _surcos: Surcos
# La regla de la afinidad (T15), como _danio: no guarda nada del combate.
var _afinidad: Afinidad
# La del combate (la guarda el Combate, T16): solo un ataque aplicado la avanza.
var _cadena: Cadena
# La del combate (la guarda el Combate, T17): solo Secundar aplicado la cambia.
var _cola: ColaIniciativa
# La regla del incidente (T18), como _afinidad, y el generador de combate del
# contexto (A.8): el unico azar del turno son las tiradas de los pasos 3 y 4 de
# 11.3. El chequeo de rival enemiga (T19), como _incidente.
var _incidente: Incidente
var _chequeo: ChequeoRival
# La regla de la regeneracion de mana (T21), como _incidente.
var _regla_mana: RegeneracionMana
# Los hechizos del Maestro (T22), como _incidente.
var _hechizos: Hechizos
# La regla de sellar (T24), como _hechizos.
var _sellado: Sellado
# La regla de la huida de las salvajes (T25), como _sellado.
var _huida: Huida
# Los costos de mana con descuento (T26: invocar), como _sellado.
var _costos: CostosMana
# La regla de guardar a una caida (T27), como _sellado.
var _guardado_caida: GuardadoCaida
var _azar: GeneradorAzar


func _init(entrada: EntradaCola, plantel: Plantel, tablero: Tablero, surcos: Surcos, cadena: Cadena,
		cola: ColaIniciativa, reglas: ReglasCombate, azar: GeneradorAzar) -> void:
	unidad_id = entrada.unidad_id
	marca = entrada.marca
	_plantel = plantel
	_tablero = tablero
	_surcos = surcos
	_cadena = cadena
	_cola = cola
	_danio = reglas.danio
	_afinidad = reglas.afinidad
	_incidente = reglas.incidente
	_chequeo = reglas.chequeo_rival
	_regla_mana = reglas.regeneracion_mana
	_hechizos = reglas.hechizos
	_sellado = reglas.sellado
	_huida = reglas.huida
	_costos = reglas.costos_mana
	_guardado_caida = reglas.guardado_caida
	_azar = azar


# Crea el turno de la entrada y corre el inicio del turno. surcos: los del
# combate (un turno suelto de los tests pasa unos vacios). cadena: la del combate
# (un turno suelto, una nueva). cola: la del combate (un turno suelto, una vacia:
# no puede Secundar). reglas: las del ContextoCombate (D-008; un turno suelto,
# DatosFixture.reglas). azar: el generador de combate (un turno suelto, uno propio).
# Sistema.md 11.3 y S-31 (P-033): el inicio del turno corre una sola vez por
# ronda. La entrada que vuelve despues de Secundar (EntradaCola.vuelve) sigue el
# turno sin repetirlo; por S-29 ese turno estaba sin usar, asi que se prepara igual.
# La obligacion del Encono (S-35) y el incidente (paso 4) van despues de
# preparar: miran los pasos y los ataques del modo. Si la huida sale (paso 2),
# el turno termina ahi: no hay nada que preparar.
static func empezar(entrada: EntradaCola, plantel: Plantel, tablero: Tablero, surcos: Surcos,
		cadena: Cadena, cola: ColaIniciativa, reglas: ReglasCombate, azar: GeneradorAzar) -> Turno:
	var turno: Turno = Turno.new(entrada, plantel, tablero, surcos, cadena, cola, reglas, azar)
	if not entrada.vuelve:
		turno._inicio_del_turno()
	if turno.terminado:
		return turno
	turno._preparar()
	if not entrada.vuelve:
		turno._fijar_obligacion()
		turno._chequear_incidente()
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
# del movimiento. tras_primer_ataque (T20, para la IA): el ataque que seguiria al
# primero del turno (Caza), sin la obligacion del Encono, que es solo del
# primero (10.5, Tasajero enconado en Caza); sin un segundo ataque, ACCION_USADA.
# Se calcula con el tablero de ahora, antes del primer golpe.
func previsualizar_ataque(desde: Vector2i, objetivo_id: String, tras_primer_ataque: bool = false) -> ResultadoAccion:
	if desde != _posicion(unidad_id):
		var movimiento: ResultadoAccion = validar(Accion.mover(desde))
		if not movimiento.valida:
			return movimiento
	var fin: FinCombate.Fin = FinCombate.evaluar(_plantel)
	if fin != FinCombate.Fin.EN_CURSO:
		var rechazo: ResultadoAccion = ResultadoAccion.rechazada(ResultadoAccion.Motivo.COMBATE_TERMINADO)
		rechazo.fin = fin
		return rechazo
	return _atacar_desde(desde, objetivo_id, false, false, tras_primer_ataque)


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


# D-005 (T20): las de pasos_para_retirarse(desde) a las que `mover` dejaria ir
# despues de moverse a `desde` y atacar a `objetivo_id`, con lo que el Encono y
# la cobardia prohiben (10.5, 10.6, S-35, S-36). Lo unico que el golpe cambia
# para esas reglas es si la objetivo cae: se mira con la previsualizacion. Con
# P-038 en la lectura de hoy (la restriccion de la enconada dura todo el turno),
# la enconada solo se retira a casillas desde donde sigue golpeando a una rival.
# `desde` no se incluye. No modifica nada.
func casillas_para_retirarse(desde: Vector2i, objetivo_id: String) -> Dictionary:
	var golpe: ResultadoAccion = previsualizar_ataque(desde, objetivo_id)
	var cae: String = objetivo_id if golpe.valida and golpe.danio >= _vida(objetivo_id) else ""
	var resultado: Dictionary = {}
	var pasos: Dictionary = pasos_para_retirarse(desde)
	for casilla: Vector2i in pasos.keys():
		if casilla != desde and _motivo_destino_rival(casilla, cae) == ResultadoAccion.Motivo.NINGUNO:
			resultado[casilla] = pasos[casilla]
	return resultado


func puede_erizarse() -> bool:
	return validar(Accion.erizarse()).valida


# Copia de los eventos de las acciones aplicadas en este turno (encono, oculto,
# destape, bono_perdido), para que el Combate registre los nuevos.
func eventos() -> Array[Dictionary]:
	return _eventos.duplicate(true)


func puede_terminar() -> bool:
	return validar(Accion.terminar()).valida


# Sistema.md 10.1: si la unidad del turno puede Secundar, sin mirar a quien.
func puede_secundar() -> bool:
	return _motivo_puede_secundar() == ResultadoAccion.Motivo.NINGUNO


# Las aliadas a las que `secundar` vale ahora, en el orden del Plantel (el
# Maestro y despues las criaturas), para la pantalla.
func aliadas_para_secundar() -> Array[String]:
	var resultado: Array[String] = []
	var ids: Array[String] = [Maestro.ID]
	for criatura in _plantel.criaturas():
		ids.append(criatura.id)
	for id_aliada in ids:
		if validar(Accion.secundar(id_aliada)).valida:
			resultado.append(id_aliada)
	return resultado


# Sistema.md 10.1, calcular sin aplicar: la cola de la ronda como quedaria si
# Secundara a la aliada (la misma cuenta que aplica la cola), o [] si no vale.
# Las entradas son las de la cola: de solo lectura.
func cola_si_secunda(aliado_id: String) -> Array[EntradaCola]:
	if not validar(Accion.secundar(aliado_id)).valida:
		return []
	return _cola.orden_si_secunda(unidad_id, aliado_id)


# Sistema.md 1.6 (T22, D-005): las unidades sobre las que el hechizo vale ahora,
# en el orden del Plantel (el Maestro y despues las criaturas). La Lanzadera
# vale si vale en algun sentido.
func objetivos_para_hechizo(hechizo_id: String) -> Array[String]:
	var resultado: Array[String] = []
	var ids: Array[String] = [Maestro.ID]
	for criatura in _plantel.criaturas():
		ids.append(criatura.id)
	for id_objetivo in ids:
		if not sentidos_para_hechizo(hechizo_id, id_objetivo).is_empty():
			resultado.append(id_objetivo)
	return resultado


# Los sentidos en los que el hechizo vale sobre la objetivo, en el orden de sus
# `modos` (hechizos.json). Un hechizo sin modos: [""] si vale, [] si no.
func sentidos_para_hechizo(hechizo_id: String, objetivo_id: String) -> Array[String]:
	var sentidos: Array[String] = []
	sentidos.assign(_hechizos.hechizo(hechizo_id).get("modos", [""]))
	var resultado: Array[String] = []
	for sentido in sentidos:
		if validar(Accion.hechizo(hechizo_id, objetivo_id, sentido)).valida:
			resultado.append(sentido)
	return resultado


# T22, sesion 2 (calcular sin aplicar): por que el hechizo no se puede lanzar
# ahora, con los mismos chequeos que _hechizo y en el mismo orden; si pasan y no
# vale sobre ninguna unidad, SIN_OBJETIVOS. NINGUNO si se puede.
func motivo_hechizo(hechizo_id: String) -> ResultadoAccion.Motivo:
	var motivo: ResultadoAccion.Motivo = _motivo_lanzar(hechizo_id)
	if motivo == ResultadoAccion.Motivo.NINGUNO and objetivos_para_hechizo(hechizo_id).is_empty():
		return ResultadoAccion.Motivo.SIN_OBJETIVOS
	return motivo


# Calcular sin aplicar (A.6, D-005): lo mismo que validar el hechizo. Trae el
# desglose del Martillazo, el evento de la Lanzadera (destino o choque, danio y
# vida resultante) y del Remiendo, las ocultas que destaparia y el mana.
func previsualizar_hechizo(hechizo_id: String, objetivo_id: String, sentido: String = "") -> ResultadoAccion:
	return validar(Accion.hechizo(hechizo_id, objetivo_id, sentido))


# Sistema.md 4.1 (T24, D-005): las unidades que se pueden sellar ahora, en el
# orden del Plantel.
func objetivos_para_sellar() -> Array[String]:
	var resultado: Array[String] = []
	for criatura in _plantel.criaturas():
		if _motivo_sellar(criatura.id) == ResultadoAccion.Motivo.NINGUNO:
			resultado.append(criatura.id)
	return resultado


# T24 (calcular sin aplicar): por que el Maestro no puede sellar ahora, con el
# mismo chequeo que la accion (_motivo_sellar). NINGUNO si alguna enemiga se
# puede sellar. Si no, el motivo de la enemiga que mas lejos llego en el orden de
# _motivo_sellar (empate: la primera del Plantel), asi la pantalla dice por que
# (fuera de alcance, mana); sin enemigas, SIN_OBJETIVOS.
func motivo_sellar() -> ResultadoAccion.Motivo:
	var motivo: ResultadoAccion.Motivo = _motivo_puede_sellar()
	if motivo != ResultadoAccion.Motivo.NINGUNO:
		return motivo
	var mejor: ResultadoAccion.Motivo = ResultadoAccion.Motivo.SIN_OBJETIVOS
	var mejor_paso: int = -1
	for criatura in _plantel.criaturas():
		if criatura.bando != Criatura.Bando.ENEMIGA:
			continue
		var de_esta: ResultadoAccion.Motivo = _motivo_sellar(criatura.id)
		if de_esta == ResultadoAccion.Motivo.NINGUNO:
			return de_esta
		var paso: int = _ORDEN_SELLAR.find(de_esta)
		if paso > mejor_paso:
			mejor = de_esta
			mejor_paso = paso
	return mejor


# Calcular sin aplicar (A.6, D-005): lo mismo que validar el sellado. Trae el
# porcentaje, el costo y el mana; el motivo si no vale.
func previsualizar_sellar(objetivo_id: String) -> ResultadoAccion:
	return validar(Accion.sellar(objetivo_id))


# Sistema.md 3.1 (T26, D-005): por que la criatura del turno no puede guardarse
# ahora, con el mismo chequeo que la accion. NINGUNO si puede.
func motivo_guardar() -> ResultadoAccion.Motivo:
	return _motivo_guardar()


# Sistema.md 3.1 (T26, D-005): las guardadas que el Maestro puede invocar ahora
# (en alguna casilla), en el orden del Plantel.
func guardadas_para_invocar() -> Array[String]:
	var resultado: Array[String] = []
	for criatura in _plantel.criaturas():
		if _motivo_invocar(criatura.id) == ResultadoAccion.Motivo.NINGUNO:
			resultado.append(criatura.id)
	return resultado


# Sistema.md 3.1 y 11.3 (T26, D-005): las casillas donde el Maestro puede invocar
# ahora, en orden de lectura: las que pasan la parte del chequeo que mira la
# casilla. [] si el Maestro no puede invocar en este turno.
func casillas_para_invocar() -> Array[Vector2i]:
	var resultado: Array[Vector2i] = []
	if _motivo_puede_invocar() != ResultadoAccion.Motivo.NINGUNO:
		return resultado
	return _casillas_libres_junto_al_maestro()


# T26 (calcular sin aplicar): por que el Maestro no puede invocar ahora a la
# criatura, con el mismo chequeo que la accion, sin mirar la casilla. NINGUNO si puede.
func motivo_invocar(criatura_id: String) -> ResultadoAccion.Motivo:
	return _motivo_invocar(criatura_id)


# Calcular sin aplicar (A.6, D-005): lo mismo que validar la invocacion. Trae el
# costo, el mana, las ocultas que destaparia y el evento; el motivo si no vale.
func previsualizar_invocar(criatura_id: String, casilla: Vector2i) -> ResultadoAccion:
	return validar(Accion.invocar(criatura_id, casilla))


# Sistema.md 11.5 (T27, D-005): las caidas que el Maestro puede guardar ahora, en
# el orden del Plantel.
func objetivos_para_guardar_caida() -> Array[String]:
	var resultado: Array[String] = []
	for criatura in _plantel.criaturas():
		if _motivo_guardar_caida(criatura.id) == ResultadoAccion.Motivo.NINGUNO:
			resultado.append(criatura.id)
	return resultado


# T27 (calcular sin aplicar): por que el Maestro no puede guardar a una caida
# ahora, con el mismo chequeo que la accion (_motivo_guardar_caida). Primero lo
# del Maestro; despues mira solo a las caidas de la tribu (las que la consulta
# unica acepta como CAIDA_PROPIA): NINGUNO si alguna vale y, si no, el motivo de
# la que mas lejos llego en _ORDEN_GUARDAR_CAIDA (empate: la primera del
# Plantel), asi la pantalla dice por que (fuera de alcance, mana). Sin caidas de
# la tribu, SIN_OBJETIVOS.
func motivo_guardar_caida() -> ResultadoAccion.Motivo:
	var motivo: ResultadoAccion.Motivo = _motivo_puede_guardar_caida()
	if motivo != ResultadoAccion.Motivo.NINGUNO:
		return motivo
	var mejor: ResultadoAccion.Motivo = ResultadoAccion.Motivo.SIN_OBJETIVOS
	var mejor_paso: int = -1
	for criatura in _plantel.criaturas():
		if criatura.bando != Criatura.Bando.TRIBU \
				or not Objetivos.puede_ser_objetivo(criatura.id, Objetivos.Clase.CAIDA_PROPIA, _plantel):
			continue
		var de_esta: ResultadoAccion.Motivo = _motivo_guardar_caida(criatura.id)
		if de_esta == ResultadoAccion.Motivo.NINGUNO:
			return de_esta
		var paso: int = _ORDEN_GUARDAR_CAIDA.find(de_esta)
		if paso > mejor_paso:
			mejor = de_esta
			mejor_paso = paso
	return mejor


# Calcular sin aplicar (A.6, D-005): lo mismo que validar guardar a la caida. Trae
# el costo, el mana, la vida (de -> a) y el evento; el motivo si no vale.
func previsualizar_guardar_caida(objetivo_id: String) -> ResultadoAccion:
	return validar(Accion.guardar_caida(objetivo_id))


# Sistema.md 11.3, Inicio del turno. Primero se borra la marca de erizada: dura
# hasta el inicio de su proximo turno (11.2, S-15). Despues van los chequeos de
# 11.3, en este orden:
#   1. Regeneracion de mana del Maestro (2.1, T21): RegeneracionMana, con la ronda
#      del turno y el hambre de ahora (7.2).
#   2. Huida de las salvajes con vida <= 25% (11.7, T25): _huir. Si sale, el turno
#      termina ahi. Es una regla, no una decision de la IA (11.8 paso 1).
#   Cambio de modo (11.2.3, 11.8 paso 2): una regla, no una decision de la IA.
#   3. Rival enemiga a su alcance: Encono (10.5) o cobardia (10.6): _chequear_rival.
#   4. Incidente con rival aliada (10.4): _chequear_incidente, despues de _preparar.
func _inicio_del_turno() -> void:
	if unidad_id == Maestro.ID:
		mana = _regla_mana.aplicar(_plantel.maestro, _cola.ronda)
	var criatura: Criatura = _plantel.criatura(unidad_id)
	if criatura != null:
		criatura.erizada = false
		if _huir(criatura):
			return
		cambio_modo = CambioModo.aplicar(criatura)
		_chequear_rival()


# Sistema.md 11.7 y 11.3 paso 2: una tirada (Huida; con 0 % no hay). Si sale,
# deja el tablero como la salvaje en 0 (VidaCero.sacar_del_tablero: fuera y sus
# surcos cerrados) y gasta el turno: sus otras entradas de la ronda se saltean
# solas (ColaIniciativa). Devuelve si huyo.
func _huir(criatura: Criatura) -> bool:
	huida = _huida.tirar(unidad_id, _plantel, _azar)
	if huida.is_empty() or huida["resultado"] != Huida.RESULTADO_HUYE:
		return false
	VidaCero.sacar_del_tablero(criatura, _surcos)
	movimiento_usado = true
	accion_usada = true
	terminado = true
	return true


# Sistema.md 10.5, 10.6, 10.7 y 11.3 paso 3: una sola tirada aunque tenga varias
# rivales (S-37; ChequeoRival), de cualquier bando (T20). Quedan las rivales del
# chequeo y la casilla de inicio.
func _chequear_rival() -> void:
	_casilla_inicial = _posicion(unidad_id)
	chequeo_rival = _chequeo.tirar(unidad_id, _plantel, _azar)
	if chequeo_rival.is_empty():
		return
	_rivales_chequeo.assign(chequeo_rival["rivales"])
	enconada = chequeo_rival["resultado"] == ChequeoRival.RESULTADO_ENCONADA
	acobardada = chequeo_rival["resultado"] == ChequeoRival.RESULTADO_ACOBARDADA


# S-35: si la enconada golpea a alguna rival del chequeo desde su casilla o desde
# una a la que llega, esta obligada a atacar; si no, a acercarse, y pierde la
# accion como la distraida (10.5: "si no llega, se acerca lo mas posible y pierde
# la accion"). Las casillas salen de Tablero, sin pasar por _mover.
func _fijar_obligacion() -> void:
	if not enconada:
		return
	if _casilla_golpea_rival(_posicion(unidad_id)):
		obligacion = Obligacion.ATACAR
		return
	for casilla in _pasos_desde(_posicion(unidad_id)).keys():
		if _casilla_golpea_rival(casilla):
			obligacion = Obligacion.ATACAR
			return
	obligacion = Obligacion.ACERCARSE
	accion_usada = true
	ataques_restantes = 0


# S-35: si desde `casilla` golpearia a alguna rival del chequeo, con lo mismo que
# mira el ataque: la consulta unica de objetivo (Objetivos) y las casillas que
# golpea (Tablero). No mira los ataques que quedan: la restriccion de casillas
# dura todo el turno. sin_rival: una rival que no se cuenta (la que caeria con un
# golpe previsto, casillas_para_retirarse); "" para todas.
func _casilla_golpea_rival(casilla: Vector2i, sin_rival: String = "") -> bool:
	for rival in _rivales_chequeo:
		if rival == sin_rival or not Objetivos.puede_ser_objetivo(rival, Objetivos.Clase.HOSTIL, _plantel):
			continue
		if _tablero.golpeables(casilla, _alcance(), _bando(unidad_id), _plantel).has(_posicion(rival)):
			return true
	return false


# S-35, la que no alcanza: la menor distancia (Manhattan, Tablero) de `casilla`
# a la rival del chequeo mas cercana que sigue de pie (sin_rival como en
# _casilla_golpea_rival).
func _distancia_a_rival(casilla: Vector2i, sin_rival: String = "") -> int:
	var menor: int = -1
	for rival in _rivales_chequeo:
		if rival == sin_rival or not Objetivos.de_pie(rival, _plantel):
			continue
		var distancia: int = Tablero.distancia(casilla, _posicion(rival))
		if menor < 0 or distancia < menor:
			menor = distancia
	return menor


# S-35: la menor distancia a la rival que puede lograr con los pasos que quedan
# (la casilla actual incluida).
func _distancia_minima_alcanzable(sin_rival: String = "") -> int:
	var menor: int = _distancia_a_rival(_posicion(unidad_id), sin_rival)
	for casilla in _pasos_desde(_posicion(unidad_id)).keys():
		menor = mini(menor, _distancia_a_rival(casilla, sin_rival))
	return menor


# Sistema.md 10.6 y S-36: si `casilla` queda mas cerca de alguna rival del
# chequeo (de pie) que la casilla donde empezo el turno (sin_rival como en
# _casilla_golpea_rival).
func _mas_cerca_de_rival(casilla: Vector2i, sin_rival: String = "") -> bool:
	for rival in _rivales_chequeo:
		if rival == sin_rival or not Objetivos.de_pie(rival, _plantel):
			continue
		var hasta: Vector2i = _posicion(rival)
		if Tablero.distancia(casilla, hasta) < Tablero.distancia(_casilla_inicial, hasta):
			return true
	return false


# Sistema.md 10.4 v1.6 y 11.3, paso 4: una sola tirada (Incidente). Si sale, con
# obediencia leal o neutral se distrae: pierde la accion y conserva el
# movimiento. Con obediencia baja golpea, sin moverse y con su alcance normal, a
# la rival de menos vida que alcanza desde su casilla (empate: la primera en el
# orden del Plantel, que es el de la tribu o el de la lista de enemigas, P-011);
# si no alcanza a ninguna, se distrae. Las rivales golpeables pasan por la
# misma validacion del ataque (Objetivos HOSTIL: una oculta provoca pero no se
# golpea, S-32 / P-034). El golpe gasta la accion entera (S-34 / P-036). Las
# enemigas tiran igual, siempre con obediencia baja (10.7, T20).
func _chequear_incidente() -> void:
	var criatura: Criatura = _plantel.criatura(unidad_id)
	if criatura == null:
		return
	# Sistema.md 10.4 y 11.3 paso 4: la enconada no tira incidente.
	if enconada:
		return
	var datos: Dictionary = _incidente.tirar(unidad_id, _plantel, _azar)
	if datos.is_empty():
		return
	var objetivo: Variant = null
	if not _incidente.se_distrae(criatura, _plantel.maestro):
		var desde: Vector2i = _posicion(unidad_id)
		for rival in datos["rivales"]:
			if not _atacar_desde(desde, rival, false, true).valida:
				continue
			if objetivo == null or _vida(rival) < _vida(objetivo):
				objetivo = rival
	incidente = {"rivales": datos["rivales"], "porcentaje": datos["porcentaje"],
			"resultado": RESULTADO_DISTRAIDA if objetivo == null else RESULTADO_GOLPE, "objetivo": objetivo}
	if objetivo == null:
		accion_usada = true
		ataques_restantes = 0
		return
	var vida_antes: int = _vida(objetivo)
	var golpe: ResultadoAccion = _atacar_desde(_posicion(unidad_id), objetivo, true, true)
	golpe_incidente = {"desglose": golpe.desglose, "vida_antes": vida_antes, "vida_despues": _vida(objetivo)}


# Despues del inicio: el turno se juega con el modo que quedo (11.2.3, "juega
# ese turno en Cuenta").
func _preparar() -> void:
	pasos_restantes = _movimiento()
	ataques_restantes = 1
	var criatura: Criatura = _plantel.criatura(unidad_id)
	if criatura != null:
		ataques_restantes = criatura.especie.ataques_por_turno(criatura.modo)
		_movimiento_partido = criatura.especie.movimiento_partido(criatura.modo)


# Punto de fin del turno: aca se enchufa T23 (esperar no corta la cadena, 10.2). Sistema.md 11.2.2, Limite: queda anotado si se oculto en
# este turno, para el proximo.
func _fin_del_turno() -> void:
	var criatura: Criatura = _plantel.criatura(unidad_id)
	if criatura != null:
		criatura.junco_turno_anterior = _se_oculto


# Sistema.md 11.5: con el combate terminado se rechaza todo. Despues de cada
# accion aplicada se mira si la objetivo de la cadena sigue siendo objetivo
# hostil (10.2) y si el combate termino, y el resultado dice como.
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
		Accion.Tipo.SECUNDAR:
			resultado = _secundar(accion.aliado_id, aplica)
		Accion.Tipo.HECHIZO:
			resultado = _hechizo(accion, aplica)
		Accion.Tipo.SELLAR:
			resultado = _sellar(accion.objetivo_id, aplica)
		Accion.Tipo.GUARDAR:
			resultado = _guardar(aplica)
		Accion.Tipo.GUARDAR_CAIDA:
			resultado = _guardar_caida(accion.objetivo_id, aplica)
		Accion.Tipo.INVOCAR:
			resultado = _invocar(accion.criatura_id, accion.casilla, aplica)
		_:
			resultado = _terminar(aplica)
	if aplica and resultado.valida:
		_cadena.revisar_objetivo(_plantel)
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
	var motivo_rival: ResultadoAccion.Motivo = _motivo_destino_rival(destino)
	if motivo_rival != ResultadoAccion.Motivo.NINGUNO:
		return ResultadoAccion.rechazada(motivo_rival)
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


# Sistema.md 10.5, 10.6, S-35 y S-36: lo que el Encono o la cobardia le prohiben
# a un destino ya alcanzable. NINGUNO si no le prohiben nada. sin_rival: la que
# no se cuenta (la que caeria con un golpe previsto, T20); "" para todas.
func _motivo_destino_rival(destino: Vector2i, sin_rival: String = "") -> ResultadoAccion.Motivo:
	if obligacion == Obligacion.ATACAR and not _casilla_golpea_rival(destino, sin_rival):
		return ResultadoAccion.Motivo.CASILLA_SIN_RIVAL
	if obligacion == Obligacion.ACERCARSE \
			and _distancia_a_rival(destino, sin_rival) != _distancia_minima_alcanzable(sin_rival):
		return ResultadoAccion.Motivo.CASILLA_NO_ACERCA
	if acobardada and _mas_cerca_de_rival(destino, sin_rival):
		return ResultadoAccion.Motivo.MAS_CERCA_DE_RIVAL
	return ResultadoAccion.Motivo.NINGUNO


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
# por_incidente (10.4, T18): el golpe a una rival aliada. La objetivo es del mismo
# bando; no suma combo, no tiene eslabon y corta la cadena sin empezar otra
# (S-33 / P-035), y gasta la accion entera (S-34 / P-036).
# tras_primer_ataque: solo para previsualizar (previsualizar_ataque); el ataque
# como si ya hubiera hecho el primero del turno.
func _atacar_desde(desde: Vector2i, objetivo_id: String, aplica: bool, por_incidente: bool = false,
		tras_primer_ataque: bool = false) -> ResultadoAccion:
	if terminado:
		return ResultadoAccion.rechazada(ResultadoAccion.Motivo.TURNO_TERMINADO)
	if ataques_restantes == 0 or (tras_primer_ataque and _ataques_hechos == 0 and ataques_restantes < 2):
		return ResultadoAccion.rechazada(ResultadoAccion.Motivo.ACCION_USADA)
	var motivo: ResultadoAccion.Motivo = Objetivos.motivo(objetivo_id, Objetivos.Clase.HOSTIL, _plantel)
	if motivo == ResultadoAccion.Motivo.OBJETIVO_INEXISTENTE:
		return ResultadoAccion.rechazada(motivo)
	if (_bando(objetivo_id) == _bando(unidad_id)) != por_incidente:
		return ResultadoAccion.rechazada(ResultadoAccion.Motivo.OBJETIVO_ALIADO)
	if motivo != ResultadoAccion.Motivo.NINGUNO:
		return ResultadoAccion.rechazada(motivo)
	# S-35 y 10.5 (Tasajero enconado en Caza): la enconada que alcanza solo ataca a
	# las rivales del chequeo; el primer ataque es el obligado.
	if obligacion == Obligacion.ATACAR and _ataques_hechos == 0 and not por_incidente and not tras_primer_ataque \
			and not _rivales_chequeo.has(objetivo_id):
		return ResultadoAccion.rechazada(ResultadoAccion.Motivo.OBJETIVO_NO_RIVAL)
	var hasta: Vector2i = _posicion(objetivo_id)
	var bando: Criatura.Bando = _bando(unidad_id)
	if not _tablero.golpeables(desde, _alcance(), bando, _plantel).has(hasta):
		if _tablero.en_linea(desde, hasta) and Tablero.distancia(desde, hasta) <= _alcance() \
				and _tablero.linea_bloqueada(desde, hasta, bando, _plantel):
			return ResultadoAccion.rechazada(ResultadoAccion.Motivo.LINEA_BLOQUEADA)
		return ResultadoAccion.rechazada(ResultadoAccion.Motivo.FUERA_DE_ALCANCE)
	return _golpear(desde, objetivo_id, null, aplica, por_incidente, tras_primer_ataque)


# Sistema.md 11.4: el golpe ya validado, desde el danio. Lo comparten el ataque y
# el Martillazo (1.6, T22: "es un ataque"), asi el resto de 11.4, la cadena, el
# Encono, Hacerse junco y la vida en 0 existen una sola vez. base: null para el
# Danio base de la ficha o la balanza; el del hechizo, si no.
func _golpear(desde: Vector2i, objetivo_id: String, base: Variant, aplica: bool, por_incidente: bool = false,
		tras_primer_ataque: bool = false) -> ResultadoAccion:
	var resultado: ResultadoAccion = ResultadoAccion.aceptada()
	var aportes: Array[ModificadorDanio] = _aportes(desde, objetivo_id, por_incidente, tras_primer_ataque)
	if base == null:
		resultado.desglose = _danio.calcular(unidad_id, objetivo_id, _plantel, aportes)
	else:
		resultado.desglose = _danio.calcular_con_base(base, unidad_id, objetivo_id, _plantel, aportes)
	resultado.danio = resultado.desglose.total
	resultado.eslabon = null if por_incidente else _cadena.eslabon_para(unidad_id, objetivo_id, _plantel)
	if aplica:
		_poner_vida(objetivo_id, maxi(0, _vida(objetivo_id) - resultado.danio))
		# Sistema.md 10.2: solo el ataque aplicado avanza la cadena (nunca validar
		# ni previsualizar), antes de resolver la vida en 0. El golpe de un
		# incidente la corta y no empieza otra (S-33).
		if por_incidente:
			_cadena.cortar(Cadena.MOTIVO_OTRO_OBJETIVO)
		else:
			_cadena.atacar(unidad_id, objetivo_id, _plantel)
			# Sistema.md 10.5: todo golpe a una rival enemiga sube el Encono (el danio ya
			# se calculo con el punto que suma). Su evento va detras del ataque.
			var encono: Dictionary = _chequeo.sumar_golpe(unidad_id, objetivo_id, _plantel)
			if not encono.is_empty():
				_eventos.append(encono)
		# Sistema.md 11.2.2: la atacante se destapa y cobra su bono; la objetivo
		# destapada pierde el suyo.
		_eventos.append_array(Junco.atacar(unidad_id, _plantel))
		_eventos.append_array(Junco.recibir_ataque(objetivo_id, unidad_id, _plantel))
		VidaCero.resolver(objetivo_id, _plantel, _surcos)
		ataques_restantes = 0 if por_incidente else ataques_restantes - 1
		_ataques_hechos += 1
		accion_usada = true
	return resultado


# Los aportes externos del danio (11.4) para un ataque desde `desde`: la
# afinidad (10.3, mirada desde `desde`) y el combo del eslabon siguiente (10.2;
# nunca en el golpe de un incidente, S-33), la cobardia (10.6: en todos sus
# ataques, tambien el golpe del incidente) y el Encono (10.5: la enconada contra
# una rival del chequeo). El ataque real y la previsualizacion los ven igual.
# tras_primer_ataque (T20): el segundo golpe de Caza previsto antes del primero.
# La enconada que alcanza da el primero a una rival del chequeo (OBJETIVO_NO_RIVAL),
# asi que el contador ya habra subido 1 (10.5): se cuenta, como al aplicar.
func _aportes(desde: Vector2i, objetivo_id: String, por_incidente: bool = false,
		tras_primer_ataque: bool = false) -> Array[ModificadorDanio]:
	var aportes: Array[ModificadorDanio] = []
	var afinidad: ModificadorDanio = _afinidad.aporte(unidad_id, desde, _plantel)
	if afinidad != null:
		aportes.append(afinidad)
	if acobardada:
		aportes.append(_chequeo.aporte_cobardia())
	if por_incidente:
		return aportes
	if enconada and _rivales_chequeo.has(objetivo_id):
		var golpes_previos: int = 1 if tras_primer_ataque and _ataques_hechos == 0 \
				and obligacion == Obligacion.ATACAR else 0
		aportes.append(_chequeo.aporte_encono(_plantel.criatura(unidad_id), golpes_previos))
	var combo: ModificadorDanio = _cadena.aporte(unidad_id, objetivo_id, _plantel)
	if combo != null:
		aportes.append(combo)
	return aportes


# Sistema.md 11.2, Erizarse: solo con el rasgo de la ficha; gasta la accion.
# Queda erizada hasta el inicio de su proximo turno y mientras tanto no se mueve
# por si misma: si ya se movio, vale; si no, pierde el movimiento (S-15, P-014).
# El -50% es de T09; que la Lanzadera la mueva, de T22.
func _erizarse(aplica: bool) -> ResultadoAccion:
	if terminado:
		return ResultadoAccion.rechazada(ResultadoAccion.Motivo.TURNO_TERMINADO)
	if enconada:
		return ResultadoAccion.rechazada(ResultadoAccion.Motivo.ENCONADA)
	if accion_usada:
		return ResultadoAccion.rechazada(ResultadoAccion.Motivo.ACCION_USADA)
	var criatura: Criatura = _plantel.criatura(unidad_id)
	if criatura == null or criatura.especie.rasgo()["efecto"] != EFECTO_ERIZARSE:
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
	if enconada:
		return ResultadoAccion.rechazada(ResultadoAccion.Motivo.ENCONADA)
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
	if enconada:
		return ResultadoAccion.rechazada(ResultadoAccion.Motivo.ENCONADA)
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


# Sistema.md 10.1, Restricciones, y S-29 (P-031): el unico lugar de la regla de
# quien puede Secundar. Solo la tribu (Maestro o criatura) y con el turno sin
# usar: Secundar aplaza el turno entero, no lo parte.
func _motivo_puede_secundar() -> ResultadoAccion.Motivo:
	if terminado:
		return ResultadoAccion.Motivo.TURNO_TERMINADO
	if _bando(unidad_id) != Criatura.Bando.TRIBU:
		return ResultadoAccion.Motivo.SALVAJE_NO_SECUNDA
	# Sistema.md 10.1: no Secunda una enconada ni una acobardada.
	if enconada:
		return ResultadoAccion.Motivo.ENCONADA
	if acobardada:
		return ResultadoAccion.Motivo.ACOBARDADA
	if se_movio:
		return ResultadoAccion.Motivo.YA_SE_MOVIO
	if accion_usada:
		return ResultadoAccion.Motivo.ACCION_USADA
	return ResultadoAccion.Motivo.NINGUNO


# Sistema.md 10.1: actuar justo despues de una aliada (mismo bando, otra unidad)
# que todavia tiene su entrada pendiente en la ronda. Al aplicar, la cola mueve
# la entrada y el turno queda cerrado sin el fin del turno: el turno sigue
# cuando la entrada vuelve (S-31). No es un ataque y no toca la cadena (10.2).
func _secundar(aliado_id: String, aplica: bool) -> ResultadoAccion:
	var motivo: ResultadoAccion.Motivo = _motivo_puede_secundar()
	if motivo != ResultadoAccion.Motivo.NINGUNO:
		return ResultadoAccion.rechazada(motivo)
	if aliado_id != Maestro.ID and _plantel.criatura(aliado_id) == null:
		return ResultadoAccion.rechazada(ResultadoAccion.Motivo.OBJETIVO_INEXISTENTE)
	if aliado_id == unidad_id:
		return ResultadoAccion.rechazada(ResultadoAccion.Motivo.SECUNDAR_A_SI_MISMA)
	if _bando(aliado_id) != _bando(unidad_id):
		return ResultadoAccion.rechazada(ResultadoAccion.Motivo.ALIADA_DE_OTRO_BANDO)
	if not _cola.pendiente(aliado_id, _plantel) or _cola.orden_si_secunda(unidad_id, aliado_id).is_empty():
		return ResultadoAccion.rechazada(ResultadoAccion.Motivo.ALIADA_SIN_ENTRADA_PENDIENTE)
	if aplica:
		_cola.secundar(unidad_id, aliado_id)
		terminado = true
	return ResultadoAccion.aceptada()


# Sistema.md 1.6 y 11.3 (T22): solo el Maestro, con la accion sin usar y el mana
# del costo (sin descuento de la balanza, 2.3). La objetivo pasa por Objetivos
# (HOSTIL para danio y empuje, ALIADA para la cura; el bando lo mira cada
# efecto) y por la geometria del hechizo. Gasta la accion y conserva el
# movimiento. El comportamiento sale del efecto, nunca del id.
func _hechizo(accion: Accion, aplica: bool) -> ResultadoAccion:
	var motivo: ResultadoAccion.Motivo = _motivo_lanzar(accion.hechizo_id)
	if motivo != ResultadoAccion.Motivo.NINGUNO:
		return ResultadoAccion.rechazada(motivo)
	var hechizo: Dictionary = _hechizos.hechizo(accion.hechizo_id)
	var maestro: Maestro = _plantel.maestro
	var costo: int = hechizo["costo"]
	motivo = _motivo_objetivo_hechizo(hechizo, accion.objetivo_id)
	if motivo == ResultadoAccion.Motivo.NINGUNO:
		motivo = _motivo_sentido(hechizo, accion.sentido)
	if motivo != ResultadoAccion.Motivo.NINGUNO:
		return ResultadoAccion.rechazada(motivo)

	var resultado: ResultadoAccion
	match hechizo["efecto"]:
		Hechizos.EFECTO_DANIO:
			resultado = _golpear(_posicion(unidad_id), accion.objetivo_id,
					_hechizos.valor(accion.hechizo_id, maestro.poder), aplica)
		Hechizos.EFECTO_EMPUJE:
			resultado = _lanzadera(hechizo, accion.objetivo_id, accion.sentido, aplica)
		_:
			resultado = _remiendo(accion.hechizo_id, accion.objetivo_id, aplica)
	if not resultado.valida:
		return resultado
	if costo != 0:
		resultado.mana = {"de": maestro.mana, "a": maestro.mana - costo}
	if aplica:
		maestro.mana -= costo
		accion_usada = true
		ataques_restantes = 0
	return resultado


# Lo que se chequea antes de mirar la objetivo, en este orden: turno terminado,
# solo el Maestro, que tenga el hechizo, la accion sin usar y el mana del costo.
# Lo comparten _hechizo y motivo_hechizo.
func _motivo_lanzar(hechizo_id: String) -> ResultadoAccion.Motivo:
	if terminado:
		return ResultadoAccion.Motivo.TURNO_TERMINADO
	if unidad_id != Maestro.ID:
		return ResultadoAccion.Motivo.SOLO_MAESTRO
	var hechizo: Dictionary = _hechizos.hechizo(hechizo_id)
	if hechizo.is_empty():
		return ResultadoAccion.Motivo.HECHIZO_INEXISTENTE
	if accion_usada:
		return ResultadoAccion.Motivo.ACCION_USADA
	if _plantel.maestro.mana < (hechizo["costo"] as int):
		return ResultadoAccion.Motivo.MANA_INSUFICIENTE
	return ResultadoAccion.Motivo.NINGUNO


# La objetivo del hechizo, sin mirar el sentido. Sistema.md 1.6 y S-47: el
# danio solo va a enemigas; el empuje, a cualquier bando salvo el Maestro mismo
# (y nunca a una oculta: HOSTIL); la cura, al Maestro mismo (incluye_si_mismo) o
# a una aliada (ALIADA: una oculta vale, S-22; una caida no, 11.5).
func _motivo_objetivo_hechizo(hechizo: Dictionary, objetivo_id: String) -> ResultadoAccion.Motivo:
	var efecto: String = hechizo["efecto"]
	if objetivo_id == unidad_id and not hechizo.get("incluye_si_mismo", false):
		return ResultadoAccion.Motivo.OBJETIVO_PROPIO
	var clase: Objetivos.Clase = Objetivos.Clase.ALIADA if efecto == Hechizos.EFECTO_CURA else Objetivos.Clase.HOSTIL
	var motivo: ResultadoAccion.Motivo = Objetivos.motivo(objetivo_id, clase, _plantel)
	if motivo == ResultadoAccion.Motivo.OBJETIVO_INEXISTENTE:
		return motivo
	var mismo_bando: bool = _bando(objetivo_id) == _bando(unidad_id)
	if efecto == Hechizos.EFECTO_DANIO and mismo_bando:
		return ResultadoAccion.Motivo.OBJETIVO_ALIADO
	if efecto == Hechizos.EFECTO_CURA and not mismo_bando:
		return ResultadoAccion.Motivo.OBJETIVO_ENEMIGO
	if motivo != ResultadoAccion.Motivo.NINGUNO:
		return motivo
	return _motivo_geometria(hechizo, objetivo_id)


# D-001: la geometria del hechizo es codigo; el alcance, dato. Distancia libre:
# Manhattan <= alcance, sin bloqueo (ni enemigas ni surcos, 11.2.1). Linea: misma
# fila o columna a <= alcance, sin una enemiga en el medio (la linea de Tablero).
# Adyacente: las 4 ortogonales (11.3 v1.6); el Maestro mismo, si el hechizo lo incluye.
func _motivo_geometria(hechizo: Dictionary, objetivo_id: String) -> ResultadoAccion.Motivo:
	var desde: Vector2i = _posicion(unidad_id)
	var hasta: Vector2i = _posicion(objetivo_id)
	var alcance: int = hechizo["alcance"]
	var distancia: int = Tablero.distancia(desde, hasta)
	match hechizo["geometria"]:
		Hechizos.GEOMETRIA_DISTANCIA_LIBRE:
			if distancia > alcance:
				return ResultadoAccion.Motivo.FUERA_DE_ALCANCE
		Hechizos.GEOMETRIA_LINEA:
			if not _tablero.en_linea(desde, hasta) or distancia > alcance:
				return ResultadoAccion.Motivo.FUERA_DE_ALCANCE
			if _tablero.linea_bloqueada(desde, hasta, _bando(unidad_id), _plantel):
				return ResultadoAccion.Motivo.LINEA_BLOQUEADA
		Hechizos.GEOMETRIA_ADYACENTE:
			if objetivo_id != unidad_id and (not _tablero.en_linea(desde, hasta) or distancia > alcance):
				return ResultadoAccion.Motivo.FUERA_DE_ALCANCE
		_:
			return ResultadoAccion.Motivo.FUERA_DE_ALCANCE
	return ResultadoAccion.Motivo.NINGUNO


# Sistema.md 1.6: la Lanzadera lleva uno de sus `modos`; un hechizo sin modos, ninguno.
func _motivo_sentido(hechizo: Dictionary, sentido: String) -> ResultadoAccion.Motivo:
	var modos: Array = hechizo.get("modos", [])
	if (modos.is_empty() and not sentido.is_empty()) or (not modos.is_empty() and not modos.has(sentido)):
		return ResultadoAccion.Motivo.SENTIDO_INVALIDO
	return ResultadoAccion.Motivo.NINGUNO


# Sistema.md 1.6, Lanzadera, y sus casos borde. Empujar aleja `casillas` en la
# linea Maestro-objetivo; atraer acerca (S-48), y no vale si la llevaria hasta el
# Maestro o mas alla (atraer a una adyacente). Si el destino esta fuera, ocupado
# (de pie o caida) o en un surco que no pisa (Tablero.bloquea_desplazamiento),
# no se mueve y recibe danio_choque fijo: sin Danio ni modificadores, tambien
# erizada (S-46); vida con piso 0 y VidaCero. Si se mueve, una erizada conserva
# la marca y se revisa el contacto con las ocultas (S-24). No es un ataque: no
# toca la cadena, el Encono ni el bono de Hacerse junco.
func _lanzadera(hechizo: Dictionary, objetivo_id: String, sentido: String, aplica: bool) -> ResultadoAccion:
	var maestro_en: Vector2i = _posicion(unidad_id)
	var desde: Vector2i = _posicion(objetivo_id)
	var casillas: int = hechizo["casillas"]
	if sentido == Hechizos.SENTIDO_ATRAER and Tablero.distancia(maestro_en, desde) <= casillas:
		return ResultadoAccion.rechazada(ResultadoAccion.Motivo.ATRAER_ADYACENTE)
	var direccion: Vector2i = (desde - maestro_en).sign()
	if sentido == Hechizos.SENTIDO_ATRAER:
		direccion = -direccion
	var hasta: Vector2i = desde + direccion * casillas
	var choque: bool = _tablero.bloquea_desplazamiento(hasta, objetivo_id, _plantel, _surcos)
	var vida_antes: int = _vida(objetivo_id)
	var danio: int = hechizo["danio_choque"] if choque else 0
	var resultado: ResultadoAccion = ResultadoAccion.aceptada()
	resultado.danio = danio
	resultado.evento = {"tipo": "lanzadera", "objetivo": objetivo_id, "sentido": sentido,
			"desde": Plantel.casilla_a_lista(desde), "hasta": null if choque else Plantel.casilla_a_lista(hasta),
			"choque": choque, "danio": danio, "vida_antes": vida_antes, "vida_despues": maxi(0, vida_antes - danio)}
	# P-042: contra quien choco (de pie o caida), o null si fue el borde o un surco.
	if choque:
		resultado.evento["contra"] = _tablero.ocupante_en(hasta, _plantel)
	else:
		resultado.destaparia = Junco.destaparia(objetivo_id, hasta, _plantel)
	if aplica:
		if choque:
			_poner_vida(objetivo_id, maxi(0, vida_antes - danio))
			VidaCero.resolver(objetivo_id, _plantel, _surcos)
		else:
			_poner_posicion(objetivo_id, hasta)
			_eventos.append_array(Junco.revisar_contacto(objetivo_id, _plantel))
	return resultado


# Sistema.md 1.6, Remiendo: cura base + por_poder x Poder (D-010), con tope en la
# vida maxima (el Maestro, la de su balanza; una criatura, la de su ficha). Con
# la vida completa vale y cura 0 (S-45). No es un ataque.
func _remiendo(hechizo_id: String, objetivo_id: String, aplica: bool) -> ResultadoAccion:
	var maximo: int = _plantel.maestro.vida_max_real() if objetivo_id == Maestro.ID \
			else _plantel.criatura(objetivo_id).vida_max_real()
	var de: int = _vida(objetivo_id)
	var a: int = maxi(de, mini(maximo, de + _hechizos.valor(hechizo_id, _plantel.maestro.poder)))
	var resultado: ResultadoAccion = ResultadoAccion.aceptada()
	resultado.evento = {"tipo": "remiendo", "objetivo": objetivo_id, "de": de, "a": a}
	if aplica:
		_poner_vida(objetivo_id, a)
	return resultado


# Sistema.md 4.1 a 4.3 y 2.3 (T24): el Maestro sella a una salvaje de pie. Gasta
# la accion y conserva el movimiento. El % sale de la vida de ahora (Sellado);
# erizada no lo cambia (S-51). Se paga el mana; con % > 0, una tirada del
# generador de combate; con 0, sin tirada y falla (S-50). Si falla, el pergamino
# no se gasta (S-49). Si sale, el primer pergamino en blanco queda ocupado por
# ella y deja el tablero como fuera (sus surcos se cierran). La cadena (10.2) y
# el fin (11.5) los mira _resolver despues, como en cualquier accion.
func _sellar(objetivo_id: String, aplica: bool) -> ResultadoAccion:
	var motivo: ResultadoAccion.Motivo = _motivo_sellar(objetivo_id)
	if motivo != ResultadoAccion.Motivo.NINGUNO:
		return ResultadoAccion.rechazada(motivo)
	var maestro: Maestro = _plantel.maestro
	var criatura: Criatura = _plantel.criatura(objetivo_id)
	var resultado: ResultadoAccion = ResultadoAccion.aceptada()
	resultado.porcentaje = _sellado.porcentaje_de(criatura)
	resultado.costo = _sellado.costo(criatura.especie, maestro)
	if resultado.costo != 0:
		resultado.mana = {"de": maestro.mana, "a": maestro.mana - resultado.costo}
	if not aplica:
		return resultado
	maestro.mana -= resultado.costo
	accion_usada = true
	ataques_restantes = 0
	var tiro: Variant = null
	var logrado: bool = false
	if (resultado.porcentaje as int) > 0:
		tiro = Porcentajes.tiro(_azar)
		logrado = Porcentajes.sale(tiro, resultado.porcentaje)
	var pergamino_id: Variant = null
	if logrado:
		var pergamino: Pergamino = _plantel.pergamino_en_blanco()
		pergamino.ocupar(objetivo_id)
		criatura.pergamino_id = pergamino.id
		pergamino_id = pergamino.id
		VidaCero.sacar_del_tablero(criatura, _surcos)
	resultado.evento = {"tipo": "sellado", "objetivo": objetivo_id, "porcentaje": resultado.porcentaje, "tiro": tiro,
			"resultado": Sellado.RESULTADO_LOGRADO if logrado else Sellado.RESULTADO_FALLIDO, "pergamino": pergamino_id}
	return resultado


# Sistema.md 4.1 (T24): el unico chequeo de sellar, compartido por la accion, las
# consultas y la pantalla. Primero lo del Maestro (_motivo_puede_sellar); despues
# la objetivo, en el orden de _ORDEN_SELLAR: la consulta unica (Objetivos HOSTIL:
# de pie y no oculta, S-21; el bando lo mira la accion), salvaje, distancia
# Manhattan <= alcance, ficha sellable, rango <= el maximo de la balanza y, al
# final, el mana del costo de esa objetivo. Nada se decide por el id.
func _motivo_sellar(objetivo_id: String) -> ResultadoAccion.Motivo:
	var motivo: ResultadoAccion.Motivo = _motivo_puede_sellar()
	if motivo != ResultadoAccion.Motivo.NINGUNO:
		return motivo
	motivo = Objetivos.motivo(objetivo_id, Objetivos.Clase.HOSTIL, _plantel)
	if motivo == ResultadoAccion.Motivo.OBJETIVO_INEXISTENTE:
		return motivo
	if _bando(objetivo_id) == _bando(unidad_id):
		return ResultadoAccion.Motivo.OBJETIVO_ALIADO
	if motivo != ResultadoAccion.Motivo.NINGUNO:
		return motivo
	var criatura: Criatura = _plantel.criatura(objetivo_id)
	if criatura.comportamiento != Criatura.Comportamiento.SALVAJE:
		return ResultadoAccion.Motivo.OBJETIVO_NO_SALVAJE
	if Tablero.distancia(_posicion(unidad_id), criatura.posicion) > _sellado.alcance():
		return ResultadoAccion.Motivo.FUERA_DE_ALCANCE
	if not criatura.especie.sellable():
		return ResultadoAccion.Motivo.NO_SELLABLE
	if not _sellado.rango_permitido(criatura.especie, _plantel.maestro):
		return ResultadoAccion.Motivo.RANGO_ALTO
	if _plantel.maestro.mana < _sellado.costo(criatura.especie, _plantel.maestro):
		return ResultadoAccion.Motivo.MANA_INSUFICIENTE
	return ResultadoAccion.Motivo.NINGUNO


# Lo de sellar que no depende de la objetivo, en este orden: turno terminado,
# solo el Maestro, la accion sin usar y un pergamino en blanco (4.1).
func _motivo_puede_sellar() -> ResultadoAccion.Motivo:
	if terminado:
		return ResultadoAccion.Motivo.TURNO_TERMINADO
	if unidad_id != Maestro.ID:
		return ResultadoAccion.Motivo.SOLO_MAESTRO
	if accion_usada:
		return ResultadoAccion.Motivo.ACCION_USADA
	if _plantel.pergamino_en_blanco() == null:
		return ResultadoAccion.Motivo.SIN_PERGAMINO
	return ResultadoAccion.Motivo.NINGUNO


# Sistema.md 3.1 (T26) y S-54: la criatura se guarda en su pergamino. Gasta su
# accion (puede haberse movido antes) y termina su turno: ya no esta en el
# tablero. No cuesta mana y no es un ataque: no toca la cadena, el Encono ni el bono.
func _guardar(aplica: bool) -> ResultadoAccion:
	var motivo: ResultadoAccion.Motivo = _motivo_guardar()
	if motivo != ResultadoAccion.Motivo.NINGUNO:
		return ResultadoAccion.rechazada(motivo)
	if aplica:
		_dejar_guardada(_plantel.criatura(unidad_id))
		accion_usada = true
		ataques_restantes = 0
		_gastar_pasos(pasos_restantes)
		terminado = true
		_fin_del_turno()
	return ResultadoAccion.aceptada()


# Sistema.md 3.1 (T26): el unico chequeo de guardar, compartido por la accion y la
# consulta, en este orden: turno terminado, una criatura de la tribu, no enconada
# (su obligacion, 10.5), la accion sin usar (la distraida ya la perdio, 10.4) y
# ortogonalmente adyacente al Maestro en este momento (11.3). La acobardada puede
# (S-54).
func _motivo_guardar() -> ResultadoAccion.Motivo:
	if terminado:
		return ResultadoAccion.Motivo.TURNO_TERMINADO
	if unidad_id == Maestro.ID or _bando(unidad_id) != Criatura.Bando.TRIBU:
		return ResultadoAccion.Motivo.SOLO_CRIATURA_DE_LA_TRIBU
	if enconada:
		return ResultadoAccion.Motivo.ENCONADA
	if accion_usada:
		return ResultadoAccion.Motivo.ACCION_USADA
	if not _tablero.adyacentes(_posicion(unidad_id), _plantel.maestro.posicion):
		return ResultadoAccion.Motivo.CASILLA_NO_ADYACENTE
	return ResultadoAccion.Motivo.NINGUNO


# Sistema.md 3.1 y S-55: la criatura deja el tablero guardada, con su pergamino
# ocupado. Sus surcos se cierran (11.2.1) y pierde las marcas que solo existen en
# el tablero (erizada, oculta, bono de Hacerse junco y el limite del junco).
# Conserva vida, hambre, lealtad, enfermedades, contador de Encono y modo.
func _dejar_guardada(criatura: Criatura) -> void:
	criatura.estado = Criatura.Estado.GUARDADA
	criatura.posicion = Criatura.SIN_POSICION
	criatura.erizada = false
	criatura.oculta = false
	criatura.bono_junco = false
	criatura.junco_turno_anterior = false
	_surcos.cerrar_de(criatura.id)


# Sistema.md 3.1, 2.3 y 11.3 (T26): el Maestro invoca a una guardada en una
# casilla libre a su lado y paga el costo de su rango (CostosMana). Gasta el
# turno completo, como cavar (S-53): despues solo vale terminar, que no es
# esperar. La invocada queda suelta ahi y entra en la cola desde la ronda
# siguiente (la cola se arma al empezar cada ronda). Despues se revisa el
# contacto con las ocultas (S-24). No es un ataque: no toca la cadena, el Encono
# ni el bono.
func _invocar(criatura_id: String, casilla: Vector2i, aplica: bool) -> ResultadoAccion:
	var motivo: ResultadoAccion.Motivo = _motivo_invocar(criatura_id, casilla)
	if motivo != ResultadoAccion.Motivo.NINGUNO:
		return ResultadoAccion.rechazada(motivo)
	var maestro: Maestro = _plantel.maestro
	var criatura: Criatura = _plantel.criatura(criatura_id)
	var resultado: ResultadoAccion = ResultadoAccion.aceptada()
	resultado.costo = _costos.invocar(criatura.especie, maestro)
	if resultado.costo != 0:
		resultado.mana = {"de": maestro.mana, "a": maestro.mana - resultado.costo}
	resultado.destaparia = Junco.destaparia_al_entrar(criatura_id, casilla, _plantel)
	resultado.evento = {"tipo": "invocacion", "unidad": criatura_id, "casilla": Plantel.casilla_a_lista(casilla)}
	if aplica:
		maestro.mana -= resultado.costo
		criatura.estado = Criatura.Estado.SUELTA
		criatura.posicion = casilla
		_eventos.append_array(Junco.revisar_contacto(criatura_id, _plantel))
		accion_usada = true
		ataques_restantes = 0
		_gastar_pasos(pasos_restantes)
	return resultado


# Sistema.md 3.1 (T26): el unico chequeo de invocar, compartido por la accion y
# las consultas. Primero lo del Maestro (_motivo_puede_invocar); despues la
# criatura (de la tribu y guardada: la del escenario o la guardada antes en este
# combate, tambien en esta ronda, S-56), que haya alguna casilla libre junto al
# Maestro y el mana del costo. Con la casilla de la accion, al final la casilla:
# ortogonalmente adyacente al Maestro y libre (S-25). Sin casilla (SIN_POSICION),
# es la consulta motivo_invocar.
func _motivo_invocar(criatura_id: String, casilla: Vector2i = Criatura.SIN_POSICION) -> ResultadoAccion.Motivo:
	var motivo: ResultadoAccion.Motivo = _motivo_puede_invocar()
	if motivo != ResultadoAccion.Motivo.NINGUNO:
		return motivo
	var criatura: Criatura = _plantel.criatura(criatura_id)
	if criatura == null:
		return ResultadoAccion.Motivo.OBJETIVO_INEXISTENTE
	if criatura.bando != Criatura.Bando.TRIBU:
		return ResultadoAccion.Motivo.OBJETIVO_ENEMIGO
	if criatura.estado != Criatura.Estado.GUARDADA:
		return ResultadoAccion.Motivo.NO_GUARDADA
	if _casillas_libres_junto_al_maestro().is_empty():
		return ResultadoAccion.Motivo.SIN_CASILLA_LIBRE
	if _plantel.maestro.mana < _costos.invocar(criatura.especie, _plantel.maestro):
		return ResultadoAccion.Motivo.MANA_INSUFICIENTE
	if casilla == Criatura.SIN_POSICION:
		return ResultadoAccion.Motivo.NINGUNO
	if not _tablero.adyacentes(_plantel.maestro.posicion, casilla):
		return ResultadoAccion.Motivo.CASILLA_NO_ADYACENTE
	if not _tablero.es_casilla_libre(casilla, _plantel, _surcos):
		return ResultadoAccion.Motivo.CASILLA_NO_LIBRE
	return ResultadoAccion.Motivo.NINGUNO


# Lo de invocar que no depende de la criatura, en este orden: turno terminado,
# solo el Maestro y el turno sin usar (S-53: sin la accion ni haberse movido).
func _motivo_puede_invocar() -> ResultadoAccion.Motivo:
	if terminado:
		return ResultadoAccion.Motivo.TURNO_TERMINADO
	if unidad_id != Maestro.ID:
		return ResultadoAccion.Motivo.SOLO_MAESTRO
	if accion_usada:
		return ResultadoAccion.Motivo.ACCION_USADA
	if se_movio:
		return ResultadoAccion.Motivo.YA_SE_MOVIO
	return ResultadoAccion.Motivo.NINGUNO


# Sistema.md 3.1 y 11.3: las casillas libres (S-25) en las 4 ortogonales del
# Maestro, en orden de lectura.
func _casillas_libres_junto_al_maestro() -> Array[Vector2i]:
	var resultado: Array[Vector2i] = []
	for casilla in _tablero.vecinas(_plantel.maestro.posicion):
		if _tablero.es_casilla_libre(casilla, _plantel, _surcos):
			resultado.append(casilla)
	resultado.sort_custom(func(a: Vector2i, b: Vector2i) -> bool: return a.y < b.y or (a.y == b.y and a.x < b.x))
	return resultado


# Sistema.md 11.5, 3.1 y 2.3 (T27): el Maestro guarda a una caida de la tribu y
# paga el costo de su fila (GuardadoCaida). Gasta la accion y conserva el
# movimiento, como sellar. La caida deja el tablero guardada, como al guardarse
# (_dejar_guardada, S-55: sus surcos se cierran y su casilla queda libre), con su
# pergamino (ya era suyo) y la vida del dato. Lo que le pasa despues (hambre de
# combate, +1 de victoria, sobrevivir a la derrota, invocarla, S-58) es lo de
# toda guardada. No es un ataque: no toca la cadena, el Encono ni el bono.
func _guardar_caida(objetivo_id: String, aplica: bool) -> ResultadoAccion:
	var motivo: ResultadoAccion.Motivo = _motivo_guardar_caida(objetivo_id)
	if motivo != ResultadoAccion.Motivo.NINGUNO:
		return ResultadoAccion.rechazada(motivo)
	var maestro: Maestro = _plantel.maestro
	var criatura: Criatura = _plantel.criatura(objetivo_id)
	var resultado: ResultadoAccion = ResultadoAccion.aceptada()
	resultado.costo = _guardado_caida.costo(criatura.especie, maestro)
	if resultado.costo != 0:
		resultado.mana = {"de": maestro.mana, "a": maestro.mana - resultado.costo}
	resultado.vida = {"de": criatura.vida, "a": _guardado_caida.vida()}
	resultado.evento = {"tipo": "guardado_caida", "unidad": objetivo_id, "vida": _guardado_caida.vida()}
	if aplica:
		maestro.mana -= resultado.costo
		_dejar_guardada(criatura)
		criatura.vida = _guardado_caida.vida()
		accion_usada = true
		ataques_restantes = 0
	return resultado


# Sistema.md 11.5 (T27): el unico chequeo de guardar a una caida, compartido por
# la accion y las consultas. Primero lo del Maestro (_motivo_puede_guardar_caida);
# despues la caida, en el orden de _ORDEN_GUARDAR_CAIDA: la consulta unica
# (Objetivos CAIDA_PROPIA, P-025), de la tribu (la atacante nocturna caida no,
# 9.3), distancia Manhattan <= alcance sin mirar la linea (S-57) y, al final, el
# mana del costo de esa caida. Nada se decide por el id.
func _motivo_guardar_caida(objetivo_id: String) -> ResultadoAccion.Motivo:
	var motivo: ResultadoAccion.Motivo = _motivo_puede_guardar_caida()
	if motivo != ResultadoAccion.Motivo.NINGUNO:
		return motivo
	motivo = Objetivos.motivo(objetivo_id, Objetivos.Clase.CAIDA_PROPIA, _plantel)
	if motivo != ResultadoAccion.Motivo.NINGUNO:
		return motivo
	var criatura: Criatura = _plantel.criatura(objetivo_id)
	if criatura.bando != Criatura.Bando.TRIBU:
		return ResultadoAccion.Motivo.OBJETIVO_ENEMIGO
	if Tablero.distancia(_posicion(unidad_id), criatura.posicion) > _guardado_caida.alcance():
		return ResultadoAccion.Motivo.FUERA_DE_ALCANCE
	if _plantel.maestro.mana < _guardado_caida.costo(criatura.especie, _plantel.maestro):
		return ResultadoAccion.Motivo.MANA_INSUFICIENTE
	return ResultadoAccion.Motivo.NINGUNO


# Lo de guardar a una caida que no depende de la caida, en este orden: turno
# terminado, solo el Maestro y la accion sin usar (3.1).
func _motivo_puede_guardar_caida() -> ResultadoAccion.Motivo:
	if terminado:
		return ResultadoAccion.Motivo.TURNO_TERMINADO
	if unidad_id != Maestro.ID:
		return ResultadoAccion.Motivo.SOLO_MAESTRO
	if accion_usada:
		return ResultadoAccion.Motivo.ACCION_USADA
	return ResultadoAccion.Motivo.NINGUNO


# Sistema.md 11.3: lo que no se uso se pierde. Sin haber usado la accion es
# "esperar" (10.2, P-015): el resultado lo dice para el registro. No corta la cadena.
func _terminar(aplica: bool) -> ResultadoAccion:
	if terminado:
		return ResultadoAccion.rechazada(ResultadoAccion.Motivo.TURNO_TERMINADO)
	# S-35: la enconada que alcanza no termina sin atacar; la que no alcanza, mientras
	# pueda acercarse y no se haya movido.
	if obligacion == Obligacion.ATACAR and _ataques_hechos == 0:
		return ResultadoAccion.rechazada(ResultadoAccion.Motivo.DEBE_ATACAR_RIVAL)
	if obligacion == Obligacion.ACERCARSE and not se_movio and not movimiento_usado \
			and _distancia_minima_alcanzable() < _distancia_a_rival(_posicion(unidad_id)):
		return ResultadoAccion.rechazada(ResultadoAccion.Motivo.DEBE_ACERCARSE)
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
