# Sistema.md 11.5: el combate se gana cuando no queda ninguna enemiga en pie y se
# pierde cuando cae el Maestro. No se guarda: sale del Plantel, asi todos los
# turnos lo ven igual. El cierre (T10, sesion 2) recibe el mismo Fin.
class_name FinCombate
extends RefCounted

enum Fin { EN_CURSO, VICTORIA, DERROTA_POR_CAIDA }


# La caida del Maestro termina el combate en el acto, quede quien quede.
static func evaluar(plantel: Plantel) -> Fin:
	if plantel.maestro.caido:
		return Fin.DERROTA_POR_CAIDA
	for criatura in plantel.criaturas():
		if criatura.bando == Criatura.Bando.ENEMIGA and _en_pie(criatura):
			return Fin.EN_CURSO
	return Fin.VICTORIA


# En pie en el tablero: no cuentan las caidas ni las que salieron.
static func _en_pie(criatura: Criatura) -> bool:
	return criatura.estado == Criatura.Estado.SUELTA and criatura.posicion != Criatura.SIN_POSICION
