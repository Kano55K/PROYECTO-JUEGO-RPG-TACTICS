# Sistema.md 2.3 (T26): los costos de mana por rango que llevan el descuento de la
# balanza (sellar, invocar, guardar a una caida, T27, y resellar, T30), sin estado. Los
# numeros salen de tablas/costos_mana.json (costo por rango y costo minimo) y el
# descuento, de tablas/balanza.json (la fila del Maestro). Los hechizos no pasan
# por aca: no llevan descuento (2.3).
class_name CostosMana
extends RefCounted

# Arquitectura.md A.7 y D-007: el motivo del evento `mana` que paga una invocacion.
const MOTIVO_INVOCAR: String = "invocar"

var _sellar: Array = []
var _invocar: Array = []
var _guardar_caida: Array = []
var _resellar: Array = []
var _costo_minimo: int = 0


# null si falta un dato: sin valores por defecto (leccion de T09 y T37).
static func desde_datos(tabla_costos: Dictionary) -> CostosMana:
	if not tabla_costos.has("sellar") or not tabla_costos.has("invocar") or not tabla_costos.has("guardar_caida") \
			or not tabla_costos.has("resellar") or not tabla_costos.has("costo_minimo"):
		return null
	var regla: CostosMana = CostosMana.new()
	regla._sellar = (tabla_costos["sellar"] as Array).duplicate()
	regla._invocar = (tabla_costos["invocar"] as Array).duplicate()
	regla._guardar_caida = (tabla_costos["guardar_caida"] as Array).duplicate()
	regla._resellar = (tabla_costos["resellar"] as Array).duplicate()
	regla._costo_minimo = tabla_costos["costo_minimo"]
	return regla


# Sistema.md 2.3 y 4.1: sellar a una criatura de esa especie.
func sellar(especie: Especie, maestro: Maestro) -> int:
	return _con_descuento(_sellar, especie, maestro)


# Sistema.md 2.3 y 3.1: invocar a una criatura de esa especie.
func invocar(especie: Especie, maestro: Maestro) -> int:
	return _con_descuento(_invocar, especie, maestro)


# Sistema.md 2.3 y 11.5 (T27): guardar a una caida propia de esa especie, con la
# fila propia del archivo (no la de invocar).
func guardar_caida(especie: Especie, maestro: Maestro) -> int:
	return _con_descuento(_guardar_caida, especie, maestro)


# Sistema.md 2.3 y 4.4 (T30): resellar a la atacante nocturna caida de esa
# especie, con la fila propia del archivo.
func resellar(especie: Especie, maestro: Maestro) -> int:
	return _con_descuento(_resellar, especie, maestro)


# Sistema.md 2.3: el costo del rango menos el descuento de la balanza, con el minimo.
func _con_descuento(costos: Array, especie: Especie, maestro: Maestro) -> int:
	return maxi(_costo_minimo, (costos[especie.rango() - 1] as int) - (maestro.fila_balanza()["descuento"] as int))
