# Arquitectura.md A.6: los tests de reglas leen fixtures propios, nunca datos/,
# y los validan con los mismos esquemas reales de datos/_esquemas/.
# No extiende GdUnitTestSuite: es un ayudante, no una suite.
class_name LectorFixture
extends RefCounted

const _CARPETA_ESQUEMAS: String = "res://datos"


# Devuelve {"errores": Array[Dictionary], "datos": Variant} con los enteros
# ya convertidos por el Validador, igual que los entrega el Cargador.
static func leer(ruta: String, nombre_esquema: String) -> Dictionary:
	var esquema: Dictionary = Cargador.new().esquema_resuelto(_CARPETA_ESQUEMAS, nombre_esquema)["esquema"]
	var valor: Variant = JSON.parse_string(FileAccess.get_file_as_string(ruta))
	return Validador.new().validar(valor, esquema, ruta.get_file())
