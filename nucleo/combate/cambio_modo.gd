# Sistema.md 11.2.3, Cambio a Cuenta: el unico lugar de la regla. Lo usan el
# inicio del turno (11.8 paso 2) y la consulta de la pantalla. Se compara en
# enteros (B.2.1, T36): vida x 100 <= vida_max x umbral.
class_name CambioModo
extends RefCounted

const _CIEN: int = 100


# Si corresponde, pasa la criatura a su modo final y devuelve {de, a}; si no, {}.
static func aplicar(criatura: Criatura) -> Dictionary:
	if CambioModo.vida_de_cambio(criatura) == null \
			or criatura.vida * _CIEN > criatura.vida_max_real() * criatura.especie.umbral_cambio_pct():
		return {}
	var cambio: Dictionary = {"de": criatura.modo, "a": criatura.especie.modo_final()}
	criatura.modo = cambio["a"]
	return cambio


# La vida a la que cambia de modo, o null si no tiene modos o ya esta en el
# final (no hay vuelta). Vida y umbral no son negativos: la division entera es el piso.
static func vida_de_cambio(criatura: Criatura) -> Variant:
	var modo_final: String = criatura.especie.modo_final()
	if modo_final.is_empty() or criatura.modo == modo_final:
		return null
	return criatura.vida_max_real() * criatura.especie.umbral_cambio_pct() / _CIEN
