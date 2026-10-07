# Sistema.md 10.2 y 10.7: la cadena de combos del combate. El dueno es el Combate
# (Arquitectura.md B.3, T16), como los Surcos; el Turno la recibe por parametro.
# Guarda la objetivo, el eslabon y las participantes en orden, por id (A.5 y
# F-02). Solo un ataque aplicado de la tribu la avanza; los cortes los piden el
# Combate y el Turno. Lleva un historial de los `cadena_cortada` que el Combate
# vuelca al registro: las reglas nunca escriben el registro.
class_name Cadena
extends RefCounted

# Arquitectura.md A.7: motivos del evento cadena_cortada.
const MOTIVO_ENEMIGA: String = "enemiga"
const MOTIVO_OTRO_OBJETIVO: String = "otro_objetivo"
const MOTIVO_FIN_RONDA: String = "fin_ronda"
const MOTIVO_OBJETIVO_FUERA: String = "objetivo_fuera"
const MOTIVO_FIN_COMBATE: String = "fin_combate"

var _combo: Combo
# "" sin cadena.
var _objetivo_id: String = ""
var _eslabon: int = 0
# Una por eslabon, en orden: la ultima es el ultimo atacante.
var _participantes: Array[String] = []
var _historial: Array[Dictionary] = []


func _init(combo: Combo) -> void:
	_combo = combo


func activa() -> bool:
	return not _objetivo_id.is_empty()


# Sistema.md 10.2 y 11.4 paso 1: el bono del golpe que seguiria la cadena, o null
# si no la sigue (otra objetivo, sin cadena o una enemiga, que no encadena: 10.7).
# Calcula sin aplicar.
func aporte(atacante_id: String, objetivo_id: String, plantel: Plantel) -> ModificadorDanio:
	if not _es_tribu(atacante_id, plantel) or not activa() or objetivo_id != _objetivo_id:
		return null
	var bono: int = _combo.bono(_eslabon + 1, _participantes.back(), atacante_id, plantel)
	return ModificadorDanio.new(ModificadorDanio.Fuente.COMBO, ModificadorDanio.Tipo.PORCENTAJE, bono)


# El eslabon que seria ese ataque: null para una enemiga (10.7). Calcula sin aplicar.
func eslabon_para(atacante_id: String, objetivo_id: String, plantel: Plantel) -> Variant:
	if not _es_tribu(atacante_id, plantel):
		return null
	return _eslabon + 1 if activa() and objetivo_id == _objetivo_id else 1


# Un ataque aplicado. De la tribu: a la misma objetivo sube el eslabon; a otra,
# corta la cadena vieja y empieza una nueva en el eslabon 1. Una enemiga no la toca.
func atacar(atacante_id: String, objetivo_id: String, plantel: Plantel) -> void:
	if not _es_tribu(atacante_id, plantel):
		return
	if activa() and objetivo_id != _objetivo_id:
		cortar(MOTIVO_OTRO_OBJETIVO)
	_objetivo_id = objetivo_id
	_eslabon += 1
	_participantes.append(atacante_id)


# Sistema.md 10.2: termina la cadena con un solo cadena_cortada. Sin cadena, nada.
func cortar(motivo: String) -> void:
	if not activa():
		return
	_historial.append({"tipo": "cadena_cortada", "objetivo": _objetivo_id, "eslabones": _eslabon,
			"participantes": _participantes.duplicate(), "motivo": motivo})
	_objetivo_id = ""
	_eslabon = 0
	_participantes.clear()


# Sistema.md 10.2, "el objetivo sale del tablero": si ya no puede ser objetivo de
# una accion hostil (Objetivos: fuera, caida, guardada u oculta), se corta.
func revisar_objetivo(plantel: Plantel) -> void:
	if activa() and not Objetivos.puede_ser_objetivo(_objetivo_id, Objetivos.Clase.HOSTIL, plantel):
		cortar(MOTIVO_OBJETIVO_FUERA)


# Copia de los eventos, para que el Combate vuelque los nuevos al registro.
func historial() -> Array[Dictionary]:
	return _historial.duplicate(true)


# Arquitectura.md A.7: la cadena actual, o null.
func instantanea() -> Variant:
	if not activa():
		return null
	return {"objetivo": _objetivo_id, "eslabon": _eslabon, "ultimo_atacante": _participantes.back(),
			"participantes": _participantes.duplicate()}


static func _es_tribu(unidad_id: String, plantel: Plantel) -> bool:
	return unidad_id == Maestro.ID or plantel.criatura(unidad_id).bando == Criatura.Bando.TRIBU
