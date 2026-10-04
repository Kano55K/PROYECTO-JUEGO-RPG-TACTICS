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


# Arquitectura.md A.8: de una semilla se derivan generadores separados por
# sistema ("combate", "textos"...). La semilla derivada son los primeros 8 bytes
# del SHA-256 de "semilla/sistema": no depende del orden en que se crean, asi
# que sumar un sistema no cambia las tiradas de los otros.
static func derivado(semilla_base: int, sistema: String) -> GeneradorAzar:
	var contexto: HashingContext = HashingContext.new()
	contexto.start(HashingContext.HASH_SHA256)
	contexto.update(("%d/%s" % [semilla_base, sistema]).to_utf8_buffer())
	var resumen: PackedByteArray = contexto.finish()
	return GeneradorAzar.new(resumen.decode_s64(0))


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
