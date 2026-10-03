# Arquitectura.md A.2: valida un dato ya parseado (Dictionary/Array/...) contra
# el subconjunto de JSON Schema admitido. No lee archivos ni hace chequeos
# cruzados (cargador, sesion 2 de T03): solo recibe datos y esquema por parametro.
class_name Validador
extends RefCounted

const _PALABRAS_CLAVE_ESQUEMA: Array[String] = [
	"type", "properties", "required", "additionalProperties", "items",
	"enum", "minimum", "maximum", "minItems", "maxItems", "pattern",
	"$ref", "$defs", "title", "description",
]

const _PREFIJO_REF: String = "#/$defs/"


# Devuelve {"errores": Array[Dictionary], "datos": Variant}. Cada error:
# {"archivo", "campo", "esperado", "recibido"}. "datos" trae los enteros de
# Godot (12.0) ya convertidos a int (A.2, fila "Enteros").
func validar(datos: Variant, esquema: Dictionary, archivo: String) -> Dictionary:
	var errores: Array[Dictionary] = []
	var defs: Dictionary = esquema.get("$defs", {})
	var datos_convertidos: Variant = _validar_nodo(datos, esquema, "", archivo, defs, errores)
	return {"errores": errores, "datos": datos_convertidos}


func _validar_nodo(valor: Variant, esquema: Dictionary, campo: String, archivo: String, defs: Dictionary, errores: Array[Dictionary]) -> Variant:
	_chequear_palabras_clave(esquema, campo, archivo, errores)

	var sub_esquema: Dictionary = esquema
	if esquema.has("$ref"):
		sub_esquema = _resolver_ref(esquema["$ref"] as String, defs, campo, archivo, errores)
		if sub_esquema.is_empty():
			return valor
		_chequear_palabras_clave(sub_esquema, campo, archivo, errores)

	if sub_esquema.has("enum"):
		var opciones: Array = sub_esquema["enum"]
		if not _valor_en_enum(valor, opciones):
			errores.append(_error(archivo, campo, _formatear_enum(opciones), valor))
			return valor

	if sub_esquema.has("type"):
		var tipos: Array = _como_lista(sub_esquema["type"])
		var chequeo: Dictionary = _validar_tipo(valor, tipos)
		if not chequeo["valido"]:
			errores.append(_error(archivo, campo, _formatear_tipos(tipos), valor))
			return valor
		valor = chequeo["valor"]

	if valor is float or valor is int:
		if sub_esquema.has("minimum") and float(valor) < float(sub_esquema["minimum"]):
			errores.append(_error(archivo, campo, "mayor o igual a %s" % [_formatear_numero(sub_esquema["minimum"])], valor))
		if sub_esquema.has("maximum") and float(valor) > float(sub_esquema["maximum"]):
			errores.append(_error(archivo, campo, "menor o igual a %s" % [_formatear_numero(sub_esquema["maximum"])], valor))

	if valor is String and sub_esquema.has("pattern"):
		var expresion: RegEx = RegEx.new()
		expresion.compile(sub_esquema["pattern"] as String)
		if expresion.search(valor as String) == null:
			errores.append(_error(archivo, campo, "que matchee %s" % [sub_esquema["pattern"]], valor))

	if valor is Array:
		valor = _validar_array(valor as Array, sub_esquema, campo, archivo, defs, errores)

	if valor is Dictionary:
		valor = _validar_objeto(valor as Dictionary, sub_esquema, campo, archivo, defs, errores)

	return valor


func _validar_array(lista: Array, sub_esquema: Dictionary, campo: String, archivo: String, defs: Dictionary, errores: Array[Dictionary]) -> Array:
	if sub_esquema.has("minItems") and lista.size() < int(sub_esquema["minItems"]):
		errores.append(_error(archivo, campo, "al menos %d elementos" % [int(sub_esquema["minItems"])], lista.size()))
	if sub_esquema.has("maxItems") and lista.size() > int(sub_esquema["maxItems"]):
		errores.append(_error(archivo, campo, "como mucho %d elementos" % [int(sub_esquema["maxItems"])], lista.size()))

	if not sub_esquema.has("items"):
		return lista

	var items_esquema: Dictionary = sub_esquema["items"]
	var nueva_lista: Array = []
	for i in range(lista.size()):
		var campo_item: String = "%s[%d]" % [campo, i]
		nueva_lista.append(_validar_nodo(lista[i], items_esquema, campo_item, archivo, defs, errores))
	return nueva_lista


func _validar_objeto(objeto: Dictionary, sub_esquema: Dictionary, campo: String, archivo: String, defs: Dictionary, errores: Array[Dictionary]) -> Dictionary:
	var propiedades: Dictionary = sub_esquema.get("properties", {})
	var requeridos: Array = sub_esquema.get("required", [])
	var adicional: Variant = sub_esquema.get("additionalProperties", true)
	var nuevo_objeto: Dictionary = {}

	for clave_requerida in requeridos:
		if not objeto.has(clave_requerida):
			errores.append(_error(archivo, _unir_campo(campo, clave_requerida as String), "presente (obligatorio)", null))

	for clave in objeto.keys():
		var campo_hijo: String = _unir_campo(campo, clave as String)
		if propiedades.has(clave):
			nuevo_objeto[clave] = _validar_nodo(objeto[clave], propiedades[clave], campo_hijo, archivo, defs, errores)
		elif adicional is Dictionary:
			nuevo_objeto[clave] = _validar_nodo(objeto[clave], adicional as Dictionary, campo_hijo, archivo, defs, errores)
		elif adicional == false:
			errores.append(_error(archivo, campo_hijo, "un campo definido en el esquema", clave))
			nuevo_objeto[clave] = objeto[clave]
		else:
			nuevo_objeto[clave] = objeto[clave]

	return nuevo_objeto


func _chequear_palabras_clave(esquema: Dictionary, campo: String, archivo: String, errores: Array[Dictionary]) -> void:
	for clave in esquema.keys():
		if clave is String and not _PALABRAS_CLAVE_ESQUEMA.has(clave):
			var base: String = "$esquema" if campo.is_empty() else "$esquema.%s" % [campo]
			errores.append(_error(archivo, "%s.%s" % [base, clave], "una palabra clave del subconjunto admitido", clave))


func _resolver_ref(ref: String, defs: Dictionary, campo: String, archivo: String, errores: Array[Dictionary]) -> Dictionary:
	if not ref.begins_with(_PREFIJO_REF):
		errores.append(_error(archivo, campo, "una referencia que empiece con %s" % [_PREFIJO_REF], ref))
		return {}
	var nombre: String = ref.substr(_PREFIJO_REF.length())
	if not defs.has(nombre):
		errores.append(_error(archivo, campo, "una definicion existente en $defs", ref))
		return {}
	return defs[nombre]


func _validar_tipo(valor: Variant, tipos: Array) -> Dictionary:
	for tipo in tipos:
		var chequeo: Dictionary = _chequear_un_tipo(valor, tipo as String)
		if chequeo["valido"]:
			return chequeo
	return {"valido": false, "valor": valor}


func _chequear_un_tipo(valor: Variant, tipo: String) -> Dictionary:
	match tipo:
		"object":
			return {"valido": valor is Dictionary, "valor": valor}
		"array":
			return {"valido": valor is Array, "valor": valor}
		"string":
			return {"valido": valor is String, "valor": valor}
		"boolean":
			return {"valido": valor is bool, "valor": valor}
		"null":
			return {"valido": valor == null, "valor": valor}
		"number":
			return {"valido": valor is float or valor is int, "valor": valor}
		"integer":
			if valor is int:
				return {"valido": true, "valor": valor}
			if valor is float and _es_entero_godot(valor as float):
				return {"valido": true, "valor": int(valor)}
			return {"valido": false, "valor": valor}
		_:
			return {"valido": false, "valor": valor}


func _es_entero_godot(valor: float) -> bool:
	return valor == floor(valor)


func _valor_en_enum(valor: Variant, opciones: Array) -> bool:
	for opcion in opciones:
		if _son_iguales(valor, opcion):
			return true
	return false


func _son_iguales(a: Variant, b: Variant) -> bool:
	if (a is float or a is int) and (b is float or b is int):
		return float(a) == float(b)
	return a == b


func _unir_campo(campo: String, clave: String) -> String:
	if campo.is_empty():
		return clave
	return "%s.%s" % [campo, clave]


func _formatear_numero(valor: Variant) -> String:
	if (valor is float or valor is int) and _es_entero_godot(float(valor)):
		return str(int(valor))
	return str(valor)


func _formatear_enum(opciones: Array) -> String:
	var partes: PackedStringArray = PackedStringArray()
	for opcion in opciones:
		partes.append(str(opcion))
	return "uno de [%s]" % [", ".join(partes)]


func _formatear_tipos(tipos: Array) -> String:
	var partes: PackedStringArray = PackedStringArray()
	for tipo in tipos:
		partes.append(str(tipo))
	return " o ".join(partes)


func _como_lista(valor: Variant) -> Array:
	if valor is Array:
		return valor
	return [valor]


func _error(archivo: String, campo: String, esperado: String, recibido: Variant) -> Dictionary:
	return {"archivo": archivo, "campo": campo, "esperado": esperado, "recibido": recibido}
