# Sistema.md 11.5: el combate se gana cuando no queda ninguna enemiga en pie y se
# pierde cuando cae el Maestro. 11.7 (T28): termina en huida cuando el Maestro se
# fue con la huida declarada (justo antes de su proximo turno, 11.7 v1.8, T46).
# No se guarda: sale del Plantel, asi todos los turnos lo
# ven igual. El cierre (Cierre) recibe el mismo Fin.
class_name FinCombate
extends RefCounted

enum Fin { EN_CURSO, VICTORIA, DERROTA_POR_CAIDA, HUIDA }


# En este orden: caida, victoria, huida (11.7 y S-60). La caida del Maestro
# termina el combate en el acto, quede quien quede; si antes del cierre cae o
# huye la ultima enemiga, es victoria aunque haya declarado la huida.
static func evaluar(plantel: Plantel) -> Fin:
	if plantel.maestro.caido:
		return Fin.DERROTA_POR_CAIDA
	var victoria: bool = true
	for criatura in plantel.criaturas():
		if criatura.bando == Criatura.Bando.ENEMIGA and _en_pie(criatura):
			victoria = false
			break
	if victoria:
		return Fin.VICTORIA
	if plantel.maestro.se_fue:
		return Fin.HUIDA
	return Fin.EN_CURSO


# En pie en el tablero: no cuentan las caidas ni las que salieron.
static func _en_pie(criatura: Criatura) -> bool:
	return criatura.estado == Criatura.Estado.SUELTA and criatura.posicion != Criatura.SIN_POSICION
