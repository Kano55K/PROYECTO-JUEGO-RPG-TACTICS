# Sistema.md 5.2, Precisiones: todos los cambios de lealtad de un combate (o de
# una noche) se suman y el total se recorta a la escala una sola vez, asi el
# orden no cambia nada. General: no sabe de combates (lo reusan la noche y el
# rescate). Quien anota decide quien recibe (solo las sueltas, 3.1).
class_name AcumuladorLealtad
extends RefCounted

var _minimo: int
var _maximo: int
var _anotaciones: Array[AnotacionLealtad] = []
var _aplicado: bool = false


func _init(minimo: int, maximo: int) -> void:
	_minimo = minimo
	_maximo = maximo


# tabla_lealtad: contenido de tablas/lealtad.json.
static func desde_datos(tabla_lealtad: Dictionary) -> AcumuladorLealtad:
	return AcumuladorLealtad.new(tabla_lealtad["minimo"], tabla_lealtad["maximo"])


# Despues de aplicar no anota: cada acumulador es un solo combate o una sola noche.
func anotar(criatura_id: String, cambio: int, motivo: String) -> void:
	if _aplicado:
		return
	_anotaciones.append(AnotacionLealtad.new(criatura_id, cambio, motivo))


# Escribe la lealtad de cada criatura anotada y devuelve sus cambios en el orden
# de criaturas. Las que no tienen anotaciones no aparecen. Se aplica una sola
# vez: la segunda devuelve vacio y no cambia nada.
func aplicar(criaturas: Array[Criatura]) -> Array[CambioLealtad]:
	var cambios: Array[CambioLealtad] = []
	if _aplicado:
		return cambios
	_aplicado = true
	for criatura in criaturas:
		var cambio: CambioLealtad = CambioLealtad.new(criatura.id, criatura.lealtad)
		for anotacion in _anotaciones:
			if anotacion.criatura_id == criatura.id:
				cambio.anotaciones.append(anotacion)
				cambio.cambio += anotacion.cambio
		if cambio.anotaciones.is_empty():
			continue
		cambio.despues = clampi(cambio.antes + cambio.cambio, _minimo, _maximo)
		criatura.lealtad = cambio.despues
		cambios.append(cambio)
	return cambios
