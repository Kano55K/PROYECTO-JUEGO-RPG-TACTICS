# Sistema.md 11.3, Turno de una unidad: el turno de una entrada de la cola (T07).
# 1 movimiento y 1 accion, en cualquier orden, sin partir el movimiento. Toda
# accion se valida con la misma funcion que la aplica, sin modificar nada; una
# accion invalida no cambia nada. El Tasajero juega un Turno por cada entrada.
class_name Turno
extends RefCounted

# Sistema.md 11.2: el efecto de rasgo que habilita Erizarse. Nunca se mira el id.
const _EFECTO_ACCION_DEFENSA: String = "accion_defensa"

var unidad_id: String
# La de la entrada: "caza", "cuenta" o "".
var marca: String
var movimiento_usado: bool = false
var accion_usada: bool = false
var terminado: bool = false

var _plantel: Plantel
var _tablero: Tablero
var _danio: Danio


func _init(entrada: EntradaCola, plantel: Plantel, tablero: Tablero, danio: Danio) -> void:
	unidad_id = entrada.unidad_id
	marca = entrada.marca
	_plantel = plantel
	_tablero = tablero
	_danio = danio


# Crea el turno de la entrada y corre el inicio del turno.
static func empezar(entrada: EntradaCola, plantel: Plantel, tablero: Tablero, danio: Danio) -> Turno:
	var turno: Turno = Turno.new(entrada, plantel, tablero, danio)
	turno._inicio_del_turno()
	return turno


# Dice si la accion vale (y que haria) sin cambiar el Plantel ni el turno.
func validar(accion: Accion) -> ResultadoAccion:
	return _resolver(accion, false)


func aplicar(accion: Accion) -> ResultadoAccion:
	return _resolver(accion, true)


# Para la pantalla y la IA: lo que la unidad puede hacer ahora, sin modificar nada.
func casillas_para_mover() -> Array[Vector2i]:
	var resultado: Array[Vector2i] = []
	for casilla in _tablero.alcanzables(_posicion(unidad_id), _movimiento(), _bando(unidad_id), _plantel):
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


func puede_erizarse() -> bool:
	return validar(Accion.erizarse()).valida


func puede_terminar() -> bool:
	return validar(Accion.terminar()).valida


# Sistema.md 11.3, Inicio del turno. Primero se borra la marca de erizada: dura
# hasta el inicio de su proximo turno (11.2, S-15). Despues van los chequeos de
# 11.3, en este orden:
#   1. Regeneracion de mana del Maestro (2.1): T21.
#   2. Huida de las salvajes con vida <= 25% (11.7): T25. Si sale, el turno termina ahi.
#   3. Rival enemiga a su alcance: Encono (10.5) o cobardia (10.6): T19.
#   4. Incidente con rival aliada (10.4), solo si no quedo enconada: T18.
func _inicio_del_turno() -> void:
	var criatura: Criatura = _plantel.criatura(unidad_id)
	if criatura != null:
		criatura.erizada = false


# Punto de fin del turno, sin efectos por ahora: aca se enchufan T16 (cadena de
# combos y registro de "esperar") y T23.
func _fin_del_turno() -> void:
	pass


func _resolver(accion: Accion, aplica: bool) -> ResultadoAccion:
	match accion.tipo:
		Accion.Tipo.MOVER:
			return _mover(accion.casilla, aplica)
		Accion.Tipo.ATACAR:
			return _atacar(accion.objetivo_id, aplica)
		Accion.Tipo.ERIZARSE:
			return _erizarse(aplica)
	return _terminar(aplica)


# Sistema.md 11.3, Movimiento: a una casilla alcanzable (Tablero), de una vez;
# se gasta entero aunque sobren pasos.
func _mover(destino: Vector2i, aplica: bool) -> ResultadoAccion:
	if terminado:
		return ResultadoAccion.rechazada(ResultadoAccion.Motivo.TURNO_TERMINADO)
	if _inmovil(unidad_id):
		return ResultadoAccion.rechazada(ResultadoAccion.Motivo.ERIZADA)
	if movimiento_usado:
		return ResultadoAccion.rechazada(ResultadoAccion.Motivo.MOVIMIENTO_USADO)
	var desde: Vector2i = _posicion(unidad_id)
	if destino == desde:
		return ResultadoAccion.rechazada(ResultadoAccion.Motivo.MISMA_CASILLA)
	if not _tablero.alcanzables(desde, _movimiento(), _bando(unidad_id), _plantel).has(destino):
		return ResultadoAccion.rechazada(ResultadoAccion.Motivo.CASILLA_NO_ALCANZABLE)
	if aplica:
		_poner_posicion(unidad_id, destino)
		movimiento_usado = true
	return ResultadoAccion.aceptada()


# Sistema.md 11.3: atacar gasta la accion. La objetivo es una enemiga de pie en
# una casilla que la unidad golpea desde donde esta. La vida no baja de 0; lo
# que pasa en 0 es de T10.
func _atacar(objetivo_id: String, aplica: bool) -> ResultadoAccion:
	if terminado:
		return ResultadoAccion.rechazada(ResultadoAccion.Motivo.TURNO_TERMINADO)
	if accion_usada:
		return ResultadoAccion.rechazada(ResultadoAccion.Motivo.ACCION_USADA)
	if objetivo_id != Maestro.ID and _plantel.criatura(objetivo_id) == null:
		return ResultadoAccion.rechazada(ResultadoAccion.Motivo.OBJETIVO_INEXISTENTE)
	if _bando(objetivo_id) == _bando(unidad_id):
		return ResultadoAccion.rechazada(ResultadoAccion.Motivo.OBJETIVO_ALIADO)
	# El Maestro como objetivo esta siempre de pie: si cae, el combate termina (11.5, T10).
	var objetivo: Criatura = _plantel.criatura(objetivo_id)
	if objetivo != null and objetivo.estado == Criatura.Estado.CAIDA:
		return ResultadoAccion.rechazada(ResultadoAccion.Motivo.OBJETIVO_CAIDO)
	var hasta: Vector2i = _posicion(objetivo_id)
	if (objetivo != null and objetivo.estado == Criatura.Estado.GUARDADA) or hasta == Criatura.SIN_POSICION:
		return ResultadoAccion.rechazada(ResultadoAccion.Motivo.OBJETIVO_FUERA_DEL_TABLERO)
	var desde: Vector2i = _posicion(unidad_id)
	var bando: Criatura.Bando = _bando(unidad_id)
	if not _tablero.golpeables(desde, _alcance(), bando, _plantel).has(hasta):
		if _tablero.en_linea(desde, hasta) and Tablero.distancia(desde, hasta) <= _alcance() \
				and _tablero.linea_bloqueada(desde, hasta, bando, _plantel):
			return ResultadoAccion.rechazada(ResultadoAccion.Motivo.LINEA_BLOQUEADA)
		return ResultadoAccion.rechazada(ResultadoAccion.Motivo.FUERA_DE_ALCANCE)

	var resultado: ResultadoAccion = ResultadoAccion.aceptada()
	resultado.danio = _danio.calcular(unidad_id, objetivo_id, _plantel)
	if aplica:
		_poner_vida(objetivo_id, maxi(0, _vida(objetivo_id) - resultado.danio))
		accion_usada = true
	return resultado


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
	if criatura == null or criatura.especie.rasgo()["efecto"] != _EFECTO_ACCION_DEFENSA:
		return ResultadoAccion.rechazada(ResultadoAccion.Motivo.SIN_RASGO)
	if aplica:
		criatura.erizada = true
		accion_usada = true
		if _inmovil(unidad_id):
			movimiento_usado = true
	return ResultadoAccion.aceptada()


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
