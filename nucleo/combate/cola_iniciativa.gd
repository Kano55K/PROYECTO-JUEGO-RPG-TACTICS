# Sistema.md 10.1 y 11.3: la cola de iniciativa. Se arma al empezar cada ronda
# desde el Plantel y se recorre turno por turno; no ejecuta turnos (T08).
# Es una lista ordenada editable: Secundar (T17) mueve entradas dentro de ella.
class_name ColaIniciativa
extends RefCounted

var ronda: int = 0
var _entradas: Array[EntradaCola] = []
# Indice de la proxima entrada a revisar.
var _cursor: int = 0


# Sistema.md 11.3, Criatura invocada: la cola se arma aca y no cambia en la
# ronda, asi que la que entra a mitad de ronda espera a la siguiente.
func empezar_ronda(plantel: Plantel) -> void:
	ronda += 1
	_cursor = 0
	_entradas = _armar(plantel)


# Devuelve la proxima entrada cuya unidad todavia puede actuar, ya marcada como
# actuada, o null si se termino la ronda. Las que no pueden actuar se saltean.
func siguiente(plantel: Plantel) -> EntradaCola:
	while _cursor < _entradas.size():
		var entrada: EntradaCola = _entradas[_cursor]
		_cursor += 1
		if _puede_actuar(entrada.unidad_id, plantel):
			entrada.actuo = true
			return entrada
	return null


# Cuantas entradas de la ronda ya se recorrieron (jugadas o salteadas).
func lugar() -> int:
	return _cursor


func ronda_terminada() -> bool:
	return _cursor >= _entradas.size()


# Punto de fin de ronda, sin efectos por ahora: aca se enchufa el corte de
# cadenas (T16). El hambre de combate (T14) la aplica Combate._cerrar_ronda,
# despues de este punto, porque toca el Plantel y va al registro.
func terminar_ronda() -> void:
	pass


# Copia del arreglo, en el orden de la ronda. Las entradas son las mismas.
func entradas() -> Array[EntradaCola]:
	return _entradas.duplicate()


# Sistema.md 10.1: la unidad tiene una entrada que todavia no se recorrio y
# puede actuar (no cayo, no fue guardada, no salio del tablero). Lo que ya actuo
# o se salteo queda antes del cursor.
func pendiente(unidad_id: String, plantel: Plantel) -> bool:
	for indice in range(_cursor, _entradas.size()):
		if _entradas[indice].unidad_id == unidad_id:
			return _puede_actuar(unidad_id, plantel)
	return false


# T46 (D-017, D-005): la ronda que empezaria ahora con este Plantel, con la
# misma cuenta que empezar_ronda, sin tocar la cola (calcular sin aplicar). La
# usa la previsualizacion de la huida del Maestro (Sistema.md 11.7 v1.8).
func ronda_siguiente(plantel: Plantel) -> Array[EntradaCola]:
	return _armar(plantel)


# Indice de la entrada de la unidad en la ronda, o -1.
func lugar_de(unidad_id: String) -> int:
	for indice in range(_entradas.size()):
		if _entradas[indice].unidad_id == unidad_id:
			return indice
	return -1


# Sistema.md 10.1, Secundar: la cola que quedaria, sin tocar nada (calcular sin
# aplicar). [] si la unidad no es la del turno en curso o la aliada no tiene
# una entrada pendiente detras.
func orden_si_secunda(unidad_id: String, aliado_id: String) -> Array[EntradaCola]:
	return _reordenar(unidad_id, aliado_id)


# Sistema.md 10.1: mueve la entrada de la unidad justo detras de la de la
# aliada, sin reordenar el resto, y la deja como pendiente y marcada como turno
# que vuelve (S-31). La entrada sacada estaba antes del cursor, asi que el
# cursor retrocede uno. La entrada siempre avanza: la ronda termina (S-30).
# Devuelve el lugar nuevo, o -1 si no se puede.
func secundar(unidad_id: String, aliado_id: String) -> int:
	var orden: Array[EntradaCola] = _reordenar(unidad_id, aliado_id)
	if orden.is_empty():
		return -1
	var entrada: EntradaCola = _entradas[_cursor - 1]
	_entradas = orden
	_cursor -= 1
	entrada.actuo = false
	entrada.vuelve = true
	return _entradas.find(entrada)


# La unica cuenta de Secundar: la usan orden_si_secunda y secundar. No modifica nada.
func _reordenar(unidad_id: String, aliado_id: String) -> Array[EntradaCola]:
	var resultado: Array[EntradaCola] = []
	if _cursor == 0 or _entradas[_cursor - 1].unidad_id != unidad_id:
		return resultado
	var aliada: int = -1
	for indice in range(_cursor, _entradas.size()):
		if _entradas[indice].unidad_id == aliado_id:
			aliada = indice
	if aliada == -1:
		return resultado
	resultado = _entradas.duplicate()
	var movida: EntradaCola = resultado.pop_at(_cursor - 1)
	# Al sacar la entrada, la de la aliada quedo un lugar antes.
	resultado.insert(aliada, movida)
	return resultado


# Sistema.md 11.3, Orden y Empates: mayor Velocidad primero; empates: bando del
# jugador antes que el enemigo, el Maestro antes que sus criaturas, y despues el
# orden del Plantel (tribu en su orden; enemigas en el orden de la lista
# `enemigas`, P-011). Una entrada por unidad (11.2.3: el Tasajero tambien), con
# la Velocidad y la marca de su modo de este momento: un cambio de modo rige
# desde la ronda siguiente (11.3, Velocidad por modo).
func _armar(plantel: Plantel) -> Array[EntradaCola]:
	var candidatas: Array[Dictionary] = []
	if _puede_actuar(Maestro.ID, plantel):
		candidatas.append(_candidata(EntradaCola.new(Maestro.ID, "", plantel.maestro.velocidad), Criatura.Bando.TRIBU, true, 0))
	var criaturas: Array[Criatura] = plantel.criaturas()
	for indice in range(criaturas.size()):
		var criatura: Criatura = criaturas[indice]
		if not _puede_actuar(criatura.id, plantel):
			continue
		var entrada: EntradaCola = EntradaCola.new(criatura.id, criatura.modo, criatura.especie.velocidad(criatura.modo))
		candidatas.append(_candidata(entrada, criatura.bando, false, indice))
	candidatas.sort_custom(_va_antes)

	var resultado: Array[EntradaCola] = []
	for candidata in candidatas:
		resultado.append(candidata["entrada"])
	return resultado


func _candidata(entrada: EntradaCola, bando: Criatura.Bando, es_maestro: bool, indice: int) -> Dictionary:
	return {"entrada": entrada, "bando": bando, "maestro": es_maestro, "indice": indice}


# Orden total: no depende de que el ordenamiento sea estable.
func _va_antes(a: Dictionary, b: Dictionary) -> bool:
	var velocidad_a: int = (a["entrada"] as EntradaCola).velocidad
	var velocidad_b: int = (b["entrada"] as EntradaCola).velocidad
	if velocidad_a != velocidad_b:
		return velocidad_a > velocidad_b
	if a["bando"] != b["bando"]:
		return a["bando"] == Criatura.Bando.TRIBU
	if a["maestro"] != b["maestro"]:
		return a["maestro"]
	return a["indice"] < b["indice"]


# En la cola entran y actuan solo las unidades de pie en el tablero: no las
# guardadas, las caidas ni las que no tienen posicion (P-012). El Maestro no se
# saltea: si cae, el combate termina (Sistema.md 11.5, P-013).
func _puede_actuar(unidad_id: String, plantel: Plantel) -> bool:
	if unidad_id == Maestro.ID:
		return plantel.maestro.posicion != Criatura.SIN_POSICION
	var criatura: Criatura = plantel.criatura(unidad_id)
	return criatura != null and criatura.estado == Criatura.Estado.SUELTA and criatura.posicion != Criatura.SIN_POSICION
