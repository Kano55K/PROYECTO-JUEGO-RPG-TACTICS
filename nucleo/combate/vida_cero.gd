# Sistema.md 11.5: lo que pasa cuando una unidad llega a 0, en el acto. Se llama
# solo al aplicar (nunca al validar), desde todo lo que baja la vida: hoy el
# ataque de Turno. Lo que pasa al terminar el combate es del cierre (sesion 2).
class_name VidaCero
extends RefCounted


# Con vida mayor que 0 no hace nada.
#   Maestro -> caido: el combate termina (FinCombate).
#   Tribu -> caida: queda en su casilla y la ocupa.
#   Atacante nocturna -> caida, hasta que se decida su destino (9.3, T30).
#   Salvaje -> huye del tablero (sacar_del_tablero): fuera, sin posicion, y sus surcos se cierran.
# surcos: los del combate.
static func resolver(unidad_id: String, plantel: Plantel, surcos: Surcos) -> void:
	if unidad_id == Maestro.ID:
		if plantel.maestro.vida == 0:
			plantel.maestro.caido = true
		return
	var criatura: Criatura = plantel.criatura(unidad_id)
	if criatura == null or criatura.vida > 0:
		return
	if criatura.comportamiento == Criatura.Comportamiento.SALVAJE:
		sacar_del_tablero(criatura, surcos)
	else:
		criatura.estado = Criatura.Estado.CAIDA


# La salvaje deja el tablero: fuera, sin posicion, y sus surcos se cierran
# (11.2.1). La usan la vida en 0 y el sellado (4.1, T24); despues, la huida (T25).
static func sacar_del_tablero(criatura: Criatura, surcos: Surcos) -> void:
	criatura.estado = Criatura.Estado.FUERA
	criatura.posicion = Criatura.SIN_POSICION
	surcos.cerrar_de(criatura.id)
