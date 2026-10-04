# Sistema.md 10.1 y 11.3: la cola de iniciativa. Se arma al empezar cada ronda
# desde el Plantel y se recorre turno por turno; no ejecuta turnos (T08).
# Es una lista ordenada editable: Secundar (T17) movera entradas dentro de ella.
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


# Punto de fin de ronda, sin efectos por ahora: aca se enchufan el hambre de
# combate (T14) y el corte de cadenas (T16).
func terminar_ronda() -> void:
	pass


# Copia del arreglo, en el orden de la ronda. Las entradas son las mismas.
func entradas() -> Array[EntradaCola]:
	return _entradas.duplicate()


# Sistema.md 11.3, Orden y Empates: mayor Velocidad primero; empates: bando del
# jugador antes que el enemigo, el Maestro antes que sus criaturas, y despues el
# orden del Plantel (tribu en su orden; enemigas en el orden de la lista
# `enemigas`, P-011). Una entrada por cada turno de la ficha (Tasajero: dos).
func _armar(plantel: Plantel) -> Array[EntradaCola]:
	var candidatas: Array[Dictionary] = []
	if _puede_actuar(Maestro.ID, plantel):
		candidatas.append(_candidata(EntradaCola.new(Maestro.ID, "", plantel.maestro.velocidad), Criatura.Bando.TRIBU, true, 0, 0))
	var criaturas: Array[Criatura] = plantel.criaturas()
	for indice in range(criaturas.size()):
		var criatura: Criatura = criaturas[indice]
		if not _puede_actuar(criatura.id, plantel):
			continue
		var turnos: Array[Dictionary] = criatura.especie.turnos()
		for indice_turno in range(turnos.size()):
			var turno: Dictionary = turnos[indice_turno]
			var entrada: EntradaCola = EntradaCola.new(criatura.id, turno.get("marca", ""), turno["velocidad"])
			candidatas.append(_candidata(entrada, criatura.bando, false, indice, indice_turno))
	candidatas.sort_custom(_va_antes)

	var resultado: Array[EntradaCola] = []
	for candidata in candidatas:
		resultado.append(candidata["entrada"])
	return resultado


func _candidata(entrada: EntradaCola, bando: Criatura.Bando, es_maestro: bool, indice: int, indice_turno: int) -> Dictionary:
	return {"entrada": entrada, "bando": bando, "maestro": es_maestro, "indice": indice, "turno": indice_turno}


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
	if a["indice"] != b["indice"]:
		return a["indice"] < b["indice"]
	return a["turno"] < b["turno"]


# En la cola entran y actuan solo las unidades de pie en el tablero: no las
# guardadas, las caidas ni las que no tienen posicion (P-012). El Maestro no se
# saltea: si cae, el combate termina (Sistema.md 11.5, P-013).
func _puede_actuar(unidad_id: String, plantel: Plantel) -> bool:
	if unidad_id == Maestro.ID:
		return plantel.maestro.posicion != Criatura.SIN_POSICION
	var criatura: Criatura = plantel.criatura(unidad_id)
	return criatura != null and criatura.estado == Criatura.Estado.SUELTA and criatura.posicion != Criatura.SIN_POSICION
