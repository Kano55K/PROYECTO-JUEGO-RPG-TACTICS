# CLAUDE.md, principio 2 / Arquitectura.md A.5: el azar vive solo acá, como objeto que se crea,
# nunca randi()/randf() ni un RandomNumberGenerator sueltos, nunca global.
class_name GeneradorAzar
extends RefCounted

var _rng: RandomNumberGenerator
var _semilla: int
var _historial: Array[Dictionary] = []


func _init(semilla: int) -> void:
	_semilla = semilla
	_rng = RandomNumberGenerator.new()
	_rng.seed = semilla


func semilla() -> int:
	return _semilla


func entero(minimo: int, maximo: int) -> int:
	var resultado: int = _rng.randi_range(minimo, maximo)
	_registrar("entero", {"minimo": minimo, "maximo": maximo}, resultado)
	return resultado


func decimal() -> float:
	var resultado: float = _rng.randf()
	_registrar("decimal", {}, resultado)
	return resultado


func historial() -> Array[Dictionary]:
	return _historial.duplicate(true)


func _registrar(metodo: String, parametros: Dictionary, resultado: Variant) -> void:
	_historial.append({
		"indice": _historial.size(),
		"metodo": metodo,
		"parametros": parametros,
		"resultado": resultado,
	})
