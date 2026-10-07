# Sistema.md 7.2: el hambre de combate. Al cerrar cada N rondas suma al Maestro
# y a toda criatura de la tribu en el tablero, de pie o caida, hasta el tope de
# la escala (7.1). No alcanza a guardadas, muertas, unidades fuera, salvajes ni
# a la atacante nocturna. Todo numero sale de tablas/hambre.json. La llama el
# Combate en su fin de ronda (es el que escribe el registro, A.7).
class_name HambreCombate
extends RefCounted

var _cada_rondas: int
var _suma: int
var _maximo: int


func _init(cada_rondas: int, suma: int, maximo: int) -> void:
	_cada_rondas = cada_rondas
	_suma = suma
	_maximo = maximo


# tabla_hambre: tablas/hambre.json.
static func desde_datos(tabla_hambre: Dictionary) -> HambreCombate:
	var combate: Dictionary = tabla_hambre["combate"]
	return HambreCombate.new(combate["cada_rondas"], combate["suma"], tabla_hambre["maximo"])


# ronda: la que se cierra. null si no la dispara; si la dispara, aplica la suma
# y devuelve los cambios {unidad, de, a} de las que cambiaron (A.7: la que ya
# esta en el tope no aparece), el Maestro primero y despues en el orden del Plantel.
func cerrar_ronda(ronda: int, plantel: Plantel) -> Variant:
	if ronda % _cada_rondas != 0:
		return null
	var cambios: Array = []
	var maestro: Maestro = plantel.maestro
	if not maestro.caido and maestro.posicion != Criatura.SIN_POSICION:
		var nuevo: int = _sumada(maestro.hambre)
		if nuevo != maestro.hambre:
			cambios.append({"unidad": Maestro.ID, "de": maestro.hambre, "a": nuevo})
			maestro.hambre = nuevo
	for criatura in plantel.criaturas():
		if not _alcanza(criatura):
			continue
		var nuevo: int = _sumada(criatura.hambre)
		if nuevo != criatura.hambre:
			cambios.append({"unidad": criatura.id, "de": criatura.hambre, "a": nuevo})
			criatura.hambre = nuevo
	return cambios


func _sumada(hambre: int) -> int:
	return mini(hambre + _suma, _maximo)


# De la tribu y en el tablero, de pie o caida (7.2). Las salvajes y la atacante
# son del bando enemigo.
func _alcanza(criatura: Criatura) -> bool:
	return criatura.bando == Criatura.Bando.TRIBU \
			and criatura.estado in [Criatura.Estado.SUELTA, Criatura.Estado.CAIDA] \
			and criatura.posicion != Criatura.SIN_POSICION
