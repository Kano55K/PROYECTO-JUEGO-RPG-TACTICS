# Arquitectura.md A.7, Formato del registro: una linea por evento, en orden, con
# `n` consecutivo. Solo enteros, textos, booleanos, null, listas y diccionarios:
# un float (u otro tipo) es un error y la linea no entra. Lo escribe Combate,
# nunca las reglas. Dos combates iguales dan las mismas lineas, byte por byte.
class_name RegistroCombate
extends RefCounted

# "" mientras no hubo error; si no, que linea se rechazo y por que.
var error: String = ""
var _lineas: Array[Dictionary] = []


# Agrega el evento con su `n`. Devuelve false (y deja `error`) si tiene un tipo
# que no va en el registro; con un error previo no agrega nada mas.
func agregar(evento: Dictionary) -> bool:
	if not error.is_empty():
		return false
	var linea: Dictionary = evento.duplicate(true)
	linea["n"] = _lineas.size()
	var problema: String = _tipo_invalido(linea, "")
	if not problema.is_empty():
		error = "linea %d (%s): %s" % [linea["n"], linea.get("tipo", "?"), problema]
		return false
	_lineas.append(linea)
	return true


# Copia de las lineas, en orden.
func lineas() -> Array[Dictionary]:
	return _lineas.duplicate(true)


# Cada linea serializada con las claves ordenadas: lo que va al archivo .jsonl.
func lineas_json() -> Array[String]:
	var resultado: Array[String] = []
	for linea in _lineas:
		resultado.append(JSON.stringify(linea, "", true))
	return resultado


# "" si el valor y todo lo que contiene es de un tipo permitido; si no, la ruta.
static func _tipo_invalido(valor: Variant, ruta: String) -> String:
	match typeof(valor):
		TYPE_NIL, TYPE_BOOL, TYPE_INT, TYPE_STRING:
			return ""
		TYPE_ARRAY:
			var lista: Array = valor
			for indice in range(lista.size()):
				var problema: String = _tipo_invalido(lista[indice], "%s[%d]" % [ruta, indice])
				if not problema.is_empty():
					return problema
			return ""
		TYPE_DICTIONARY:
			var diccionario: Dictionary = valor
			for clave in diccionario.keys():
				if typeof(clave) != TYPE_STRING:
					return "%s: clave que no es texto" % ruta
				var problema: String = _tipo_invalido(diccionario[clave], "%s.%s" % [ruta, clave])
				if not problema.is_empty():
					return problema
			return ""
	return "%s es %s" % [ruta, type_string(typeof(valor))]
