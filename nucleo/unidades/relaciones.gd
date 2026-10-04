# Sistema.md 10.8 (W-01): relaciones entre especies, par a par, leidas de
# relaciones.json. Pares sin orden; el que no figura no tiene relacion.
# Recibe el contenido ya validado por el Cargador; no lee archivos.
class_name Relaciones
extends RefCounted

enum Relacion { NINGUNA, BIEN, MAL }

const _RELACIONES: Dictionary = {
	"bien": Relacion.BIEN,
	"mal": Relacion.MAL,
}

# "a|b" con los ids ordenados -> Relacion.
var _pares: Dictionary = {}


func _init(datos_relaciones: Dictionary) -> void:
	for par in (datos_relaciones["pares"] as Array):
		_pares[_clave(par["a"], par["b"])] = _RELACIONES[par["relacion"]]


func relacion(especie_a: String, especie_b: String) -> Relacion:
	return _pares.get(_clave(especie_a, especie_b), Relacion.NINGUNA)


static func _clave(especie_a: String, especie_b: String) -> String:
	if especie_a < especie_b:
		return especie_a + "|" + especie_b
	return especie_b + "|" + especie_a
