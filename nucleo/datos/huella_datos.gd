# Arquitectura.md A.7, Huella de los datos: SHA-256 de la serializacion canonica
# (claves ordenadas) de los datos cargados, sin textos/ ni escenarios/, sin _nota
# ni $schema. Una correccion de texto o de nota no invalida grabaciones; un numero
# si. escenarios/ queda afuera porque la grabacion lleva su escenario entero. La
# usan la grabacion (T12) y el guardado de 0b.
class_name HuellaDatos
extends RefCounted

const _PREFIJOS_IGNORADOS: Array[String] = ["textos/", "escenarios/"]
const _CLAVES_IGNORADAS: Array[String] = ["_nota", "$schema"]


# datos: con la forma de Cargador.cargar_carpeta()["datos"] (ruta -> contenido),
# con los enteros ya convertidos por el Validador. Devuelve 64 caracteres hex.
static func calcular(datos: Dictionary) -> String:
	var limpio: Dictionary = {}
	for ruta in datos.keys():
		if _ignorada(ruta as String):
			continue
		limpio[ruta] = _sin_notas(datos[ruta])
	# Claves ordenadas en todos los niveles.
	var canonico: String = JSON.stringify(limpio, "", true)
	var contexto: HashingContext = HashingContext.new()
	contexto.start(HashingContext.HASH_SHA256)
	contexto.update(canonico.to_utf8_buffer())
	return contexto.finish().hex_encode()


static func _ignorada(ruta: String) -> bool:
	for prefijo in _PREFIJOS_IGNORADOS:
		if ruta.begins_with(prefijo):
			return true
	return false


static func _sin_notas(valor: Variant) -> Variant:
	if valor is Dictionary:
		var copia: Dictionary = {}
		for clave in (valor as Dictionary).keys():
			if not _CLAVES_IGNORADAS.has(clave):
				copia[clave] = _sin_notas((valor as Dictionary)[clave])
		return copia
	if valor is Array:
		var lista: Array = []
		for elemento in (valor as Array):
			lista.append(_sin_notas(elemento))
		return lista
	return valor
