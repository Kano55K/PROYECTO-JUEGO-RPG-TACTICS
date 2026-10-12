# Sistema.md 11.2.2, Hacerse junco: ocultarse, destaparse, cobrar y perder el
# bono. El estado vive en la Criatura (oculta, bono_junco); esta clase no guarda
# nada. Cada funcion devuelve los eventos de Arquitectura.md A.7 que produjo, y
# el Turno los junta para que el Combate los registre: las reglas nunca
# escriben el registro. Se llama solo al aplicar, nunca al validar.
class_name Junco
extends RefCounted

# Sistema.md 11.2.2: el efecto de rasgo que se oculta. Nunca se mira el id.
const EFECTO: String = "ocultarse"
# Arquitectura.md A.7: motivos del evento destape.
const MOTIVO_MOVER: String = "mover"
const MOTIVO_ATACAR: String = "atacar"
const MOTIVO_CONTACTO: String = "contacto"


static func es_junco(unidad_id: String, plantel: Plantel) -> bool:
	var criatura: Criatura = plantel.criatura(unidad_id)
	return criatura != null and criatura.especie.rasgo()["efecto"] == EFECTO


# Queda oculta y con el bono. Con el bono ya puesto no suma otro (No acumula).
static func ocultar(criatura: Criatura) -> Array[Dictionary]:
	criatura.oculta = true
	criatura.bono_junco = true
	return [{"tipo": "oculto", "unidad": criatura.id}]


# Se destapa si estaba oculta; el bono no cambia. por_id: la unidad que la
# destapo, solo por contacto.
static func destapar(criatura: Criatura, motivo: String, por_id: String = "") -> Array[Dictionary]:
	if not criatura.oculta:
		return []
	criatura.oculta = false
	return [{"tipo": "destape", "unidad": criatura.id, "motivo": motivo,
			"por": null if por_id.is_empty() else por_id}]


# Sistema.md 11.2.2, Destape por contacto (S-24): la unica revision. Se llama
# despues de todo cambio de posicion, cuando el movimiento termina (hoy mover,
# cada tramo en Cuenta; despues la Lanzadera, T22, e invocar, T26). Destapa a
# toda oculta del otro bando adyacente a la unidad que quedo en `movida_id`,
# si esta de pie, en el orden del Plantel. Por donde paso no importa.
static func revisar_contacto(movida_id: String, plantel: Plantel) -> Array[Dictionary]:
	var eventos: Array[Dictionary] = []
	for id_oculta in destaparia(movida_id, _posicion(movida_id, plantel), plantel):
		eventos.append_array(destapar(plantel.criatura(id_oculta), MOTIVO_CONTACTO, movida_id))
	return eventos


# La misma regla sin aplicar (T40, aviso de la pantalla): los ids de las ocultas
# del otro bando que `movida_id` destaparia si terminara su movimiento en
# `casilla`, en el orden del Plantel. No modifica nada.
static func destaparia(movida_id: String, casilla: Vector2i, plantel: Plantel) -> Array[String]:
	if not Objetivos.de_pie(movida_id, plantel):
		var ninguna: Array[String] = []
		return ninguna
	return destaparia_al_entrar(movida_id, casilla, plantel)


# T26 (S-24): la misma regla para una unidad que todavia no esta de pie en el
# tablero y va a entrar en `casilla` (la guardada que se invoca), sin mirar si
# esta de pie. No modifica nada.
static func destaparia_al_entrar(movida_id: String, casilla: Vector2i, plantel: Plantel) -> Array[String]:
	var ids: Array[String] = []
	var bando: Criatura.Bando = _bando(movida_id, plantel)
	for criatura in plantel.criaturas():
		if criatura.oculta and criatura.bando != bando and Tablero.distancia(criatura.posicion, casilla) == 1:
			ids.append(criatura.id)
	return ids


# Sistema.md 11.2.2, Bono y Se destapa: la atacante ataco. Se destapa y el bono
# se cobra en ese golpe (Danio ya lo sumo). El Maestro no tiene el rasgo.
static func atacar(atacante_id: String, plantel: Plantel) -> Array[Dictionary]:
	var atacante: Criatura = plantel.criatura(atacante_id)
	if atacante == null:
		return []
	atacante.bono_junco = false
	return destapar(atacante, MOTIVO_ATACAR)


# Sistema.md 11.2.2, Pierde el bono: recibio un ataque destapada y antes de
# atacar. Una oculta no puede recibirlo (Objetivos); la Lanzadera no llama aca.
static func recibir_ataque(objetivo_id: String, atacante_id: String, plantel: Plantel) -> Array[Dictionary]:
	var objetivo: Criatura = plantel.criatura(objetivo_id)
	if objetivo == null or not objetivo.bono_junco or objetivo.oculta:
		return []
	objetivo.bono_junco = false
	return [{"tipo": "bono_perdido", "unidad": objetivo_id, "atacante": atacante_id}]


# Sistema.md 11.2.2, Fin del combate: se borran el estado oculto y el bono, sin
# evento (como los surcos).
static func limpiar(plantel: Plantel) -> void:
	for criatura in plantel.criaturas():
		criatura.oculta = false
		criatura.bono_junco = false


static func _bando(unidad_id: String, plantel: Plantel) -> Criatura.Bando:
	if unidad_id == Maestro.ID:
		return Criatura.Bando.TRIBU
	return plantel.criatura(unidad_id).bando


static func _posicion(unidad_id: String, plantel: Plantel) -> Vector2i:
	if unidad_id == Maestro.ID:
		return plantel.maestro.posicion
	return plantel.criatura(unidad_id).posicion
