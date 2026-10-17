# Sistema.md 11.5, 3.1 y 2.3 (T27): la regla de guardar a una caida propia, sin
# estado. Los numeros salen de tablas/combate.json (alcance y vida al guardarla)
# y CostosMana (el costo de su fila, con el descuento de la balanza). El chequeo
# y el efecto los resuelve el Turno.
class_name GuardadoCaida
extends RefCounted

# Arquitectura.md A.7 y D-007: el motivo del evento `mana` que paga guardar a una caida.
const MOTIVO_GUARDAR_CAIDA: String = "guardar_caida"

var _costos: CostosMana
var _alcance: int = 0
var _vida: int = 0


# null si falta un dato: sin valores por defecto (leccion de T09 y T37).
# costos: la de ReglasCombate (T26), o null si no se pudo armar.
static func desde_datos(tabla_combate: Dictionary, costos: CostosMana) -> GuardadoCaida:
	if costos == null or not tabla_combate.has("alcance_guardar_caida") \
			or not tabla_combate.has("vida_al_guardar_caida"):
		return null
	var regla: GuardadoCaida = GuardadoCaida.new()
	regla._costos = costos
	regla._alcance = tabla_combate["alcance_guardar_caida"]
	regla._vida = tabla_combate["vida_al_guardar_caida"]
	return regla


# Sistema.md 2.3: el costo del rango menos el descuento, con el minimo (CostosMana).
func costo(especie: Especie, maestro: Maestro) -> int:
	return _costos.guardar_caida(especie, maestro)


# Sistema.md 11.5: la distancia Manhattan maxima del Maestro a la caida (S-57).
func alcance() -> int:
	return _alcance


# Sistema.md 11.5: la vida con la que queda guardada.
func vida() -> int:
	return _vida
