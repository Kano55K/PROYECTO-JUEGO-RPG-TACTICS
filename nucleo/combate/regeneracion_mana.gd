# Sistema.md 2.1 y 2.2: la regeneracion de mana del Maestro en combate. Al
# inicio de cada uno de sus turnos (11.3, paso 1) suma su atributo Regeneracion,
# sin pasar del mana con el que entro al combate (Maestro.mana_entrada, M-04).
# El estado de hambre se pregunta en el momento (7.2): regenera siempre, solo en
# rondas pares o nunca, segun tablas/hambre.json `regen_combate`. Sin estado:
# la aplica el Turno y el registro lo escribe el Combate (D-007).
class_name RegeneracionMana
extends RefCounted

# Arquitectura.md A.7 y D-007: el motivo del evento `mana`.
const MOTIVO_REGENERACION: String = "regeneracion"

# Arquitectura.md A.2.2: los valores del enum `regen_combate` de hambre.json.
const _SIEMPRE: String = "siempre"
const _RONDAS_PARES: String = "rondas_pares"

var _estados_hambre: Array


func _init(estados_hambre: Array) -> void:
	_estados_hambre = estados_hambre


# tabla_hambre: tablas/hambre.json.
static func desde_datos(tabla_hambre: Dictionary) -> RegeneracionMana:
	return RegeneracionMana.new(tabla_hambre["estados"])


# ronda: la del turno que empieza ("turnos pares" = rondas pares, 2.1). Suma y
# devuelve {de, a} si el mana cambio; si no, {} (A.7: el evento va solo si cambia).
# S-44 (lectura declarada): Famelico solo corta la regeneracion; no le quita el
# mana que ya tiene.
func aplicar(maestro: Maestro, ronda: int) -> Dictionary:
	# Lugar del quebranto (M-09, 0b): sin regeneracion por turno. Sin codigo en 0a.
	if not _regenera(maestro.hambre, ronda):
		return {}
	var nuevo: int = mini(maestro.mana + maestro.regeneracion, maestro.mana_entrada)
	if nuevo <= maestro.mana:
		return {}
	var cambio: Dictionary = {"de": maestro.mana, "a": nuevo}
	maestro.mana = nuevo
	return cambio


# Sistema.md 2.2: segun el estado de hambre actual (7.1, EstadosUnidad.fila_hambre).
func _regenera(hambre: int, ronda: int) -> bool:
	match EstadosUnidad.fila_hambre(_estados_hambre, hambre).get("regen_combate", ""):
		_SIEMPRE:
			return true
		_RONDAS_PARES:
			return ronda % 2 == 0
	return false
