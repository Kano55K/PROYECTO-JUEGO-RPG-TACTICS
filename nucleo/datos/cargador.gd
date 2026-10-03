# Arquitectura.md A.2: lee los JSON de una carpeta de datos (parametro, nunca
# fija), elige el esquema de cada archivo por convencion de carpeta, resuelve
# los $ref entre archivos de esquema y corre los chequeos cruzados que un
# esquema no puede expresar. Usa el Validador de la sesion 1 sin tocarlo.
class_name Cargador
extends RefCounted

const _PATRON_CLAVE_TEXTO: String = "^[a-z0-9_]+(\\.[a-z0-9_]+)*$"


# Devuelve {"errores": Array[Dictionary], "avisos": Array[Dictionary], "datos": Variant}.
# "datos" es null si hay al menos un error. claves_texto_esperadas es la lista
# de claves que usa el codigo, para el chequeo de A.2.1 contra textos/es.json.
func cargar_carpeta(ruta_carpeta: String, claves_texto_esperadas: Array[String] = []) -> Dictionary:
	var errores: Array[Dictionary] = []
	var avisos: Array[Dictionary] = []
	var datos_por_archivo: Dictionary = {}
	var cache_esquemas: Dictionary = {}

	for ruta_relativa in _listar_archivos_json(ruta_carpeta):
		var ruta_absoluta: String = ruta_carpeta.path_join(ruta_relativa)
		var lectura: Dictionary = _leer_json(ruta_absoluta)
		if not lectura["ok"]:
			errores.append(_error(ruta_relativa, "linea %d" % [lectura["linea"] as int], "JSON valido", lectura["mensaje"]))
			continue

		var nombre_esquema: String = _esquema_para_ruta(ruta_relativa)
		if nombre_esquema.is_empty():
			errores.append(_error(ruta_relativa, "archivo", "un archivo reconocido por la convencion de carpetas (Arquitectura.md A.2)", ruta_relativa))
			continue

		var esquema: Dictionary = _obtener_esquema_resuelto(ruta_carpeta, nombre_esquema, cache_esquemas, errores)
		if esquema.is_empty():
			continue

		var resultado: Dictionary = Validador.new().validar(lectura["valor"], esquema, ruta_relativa)
		var errores_archivo: Array[Dictionary] = resultado["errores"]
		if not errores_archivo.is_empty():
			errores.append_array(errores_archivo)
			continue

		datos_por_archivo[ruta_relativa] = resultado["datos"]

	if not errores.is_empty():
		return {"errores": errores, "avisos": avisos, "datos": null}

	_chequear_cruzados(datos_por_archivo, errores)
	_chequear_textos(datos_por_archivo, claves_texto_esperadas, errores, avisos)

	if not errores.is_empty():
		return {"errores": errores, "avisos": avisos, "datos": null}

	return {"errores": errores, "avisos": avisos, "datos": datos_por_archivo}


# --- Lectura de archivos ---------------------------------------------------

func _listar_archivos_json(carpeta: String, relativo: String = "") -> Array[String]:
	var resultado: Array[String] = []
	var ruta_actual: String = carpeta if relativo.is_empty() else carpeta.path_join(relativo)
	var dir: DirAccess = DirAccess.open(ruta_actual)
	if dir == null:
		return resultado

	dir.list_dir_begin()
	var nombre: String = dir.get_next()
	while nombre != "":
		if not nombre.begins_with("."):
			var relativo_hijo: String = nombre if relativo.is_empty() else relativo.path_join(nombre)
			if dir.current_is_dir():
				if nombre != "_esquemas":
					resultado.append_array(_listar_archivos_json(carpeta, relativo_hijo))
			elif nombre.ends_with(".json"):
				resultado.append(relativo_hijo)
		nombre = dir.get_next()
	dir.list_dir_end()

	resultado.sort()
	return resultado


func _leer_json(ruta_absoluta: String) -> Dictionary:
	if not FileAccess.file_exists(ruta_absoluta):
		return {"ok": false, "linea": 0, "mensaje": "archivo no encontrado"}
	var contenido: String = FileAccess.get_file_as_string(ruta_absoluta)
	var json: JSON = JSON.new()
	var error: Error = json.parse(contenido)
	if error != OK:
		return {"ok": false, "linea": json.get_error_line(), "mensaje": json.get_error_message()}
	return {"ok": true, "valor": json.data}


# --- Convencion de esquema por carpeta (Arquitectura.md A.2, tabla de archivos) ---

func _esquema_para_ruta(ruta_relativa: String) -> String:
	var partes: PackedStringArray = ruta_relativa.split("/")
	if partes.size() == 1:
		return partes[0].get_basename()

	match partes[0]:
		"especies":
			return "especie"
		"escenarios":
			return "escenario"
		"tablas":
			return partes[partes.size() - 1].get_basename()
		"textos":
			return "textos"
		_:
			return ""


# --- Esquemas y resolucion de $ref entre archivos ---------------------------

func _obtener_esquema_resuelto(carpeta: String, nombre_esquema: String, cache_esquemas: Dictionary, errores: Array[Dictionary]) -> Dictionary:
	if cache_esquemas.has(nombre_esquema):
		return cache_esquemas[nombre_esquema]

	var ruta_relativa: String = "_esquemas/%s.schema.json" % [nombre_esquema]
	var lectura: Dictionary = _leer_json(carpeta.path_join(ruta_relativa))
	if not lectura["ok"]:
		errores.append(_error(ruta_relativa, "linea %d" % [lectura["linea"] as int], "JSON valido", lectura["mensaje"]))
		cache_esquemas[nombre_esquema] = {}
		return {}

	var cache_archivos: Dictionary = {}
	var resuelto: Variant = _resolver_refs_cruzados(lectura["valor"], carpeta, cache_archivos, errores)
	cache_esquemas[nombre_esquema] = resuelto
	return resuelto


func _resolver_refs_cruzados(nodo: Variant, carpeta: String, cache_archivos: Dictionary, errores: Array[Dictionary]) -> Variant:
	if nodo is Dictionary:
		var diccionario: Dictionary = nodo as Dictionary
		if diccionario.has("$ref"):
			var ref: String = diccionario["$ref"] as String
			var partes_hash: PackedStringArray = ref.split("#", true, 1)
			var archivo_ref: String = partes_hash[0]
			if not archivo_ref.is_empty():
				var puntero: String = partes_hash[1] if partes_hash.size() > 1 else ""
				var definicion: Variant = _resolver_puntero_en_archivo(carpeta, archivo_ref, puntero, cache_archivos, errores)
				if definicion == null:
					return diccionario
				return _resolver_refs_cruzados(definicion, carpeta, cache_archivos, errores)

		var nuevo: Dictionary = {}
		for clave in diccionario.keys():
			nuevo[clave] = _resolver_refs_cruzados(diccionario[clave], carpeta, cache_archivos, errores)
		return nuevo

	if nodo is Array:
		var nueva_lista: Array = []
		for elemento in nodo as Array:
			nueva_lista.append(_resolver_refs_cruzados(elemento, carpeta, cache_archivos, errores))
		return nueva_lista

	return nodo


func _resolver_puntero_en_archivo(carpeta: String, archivo_ref: String, puntero: String, cache_archivos: Dictionary, errores: Array[Dictionary]) -> Variant:
	var ruta_relativa: String = "_esquemas/%s" % [archivo_ref]
	if not cache_archivos.has(archivo_ref):
		var lectura: Dictionary = _leer_json(carpeta.path_join(ruta_relativa))
		if not lectura["ok"]:
			errores.append(_error(ruta_relativa, "linea %d" % [lectura["linea"] as int], "JSON valido", lectura["mensaje"]))
			cache_archivos[archivo_ref] = {}
		else:
			cache_archivos[archivo_ref] = lectura["valor"]

	var nodo_actual: Variant = cache_archivos[archivo_ref]
	for parte in puntero.split("/", false):
		if not (nodo_actual is Dictionary) or not (nodo_actual as Dictionary).has(parte):
			errores.append(_error(ruta_relativa, puntero, "una referencia que exista en %s" % [archivo_ref], puntero))
			return null
		nodo_actual = (nodo_actual as Dictionary)[parte]
	return nodo_actual


# --- Chequeos cruzados (Arquitectura.md A.2) --------------------------------

func _chequear_cruzados(datos_por_archivo: Dictionary, errores: Array[Dictionary]) -> void:
	var especies_validas: Dictionary = {}
	for ruta in datos_por_archivo.keys():
		if (ruta as String).begins_with("especies/"):
			especies_validas[(datos_por_archivo[ruta] as Dictionary)["id"]] = true

	_chequear_id_coincide_con_archivo(datos_por_archivo, errores)
	_chequear_especies_existen(datos_por_archivo, especies_validas, errores)
	_chequear_pares_sin_repetir(datos_por_archivo, errores)
	_chequear_balanza(datos_por_archivo, errores)
	_chequear_sellado(datos_por_archivo, errores)
	_chequear_hambre(datos_por_archivo, errores)
	_chequear_ids_escenario(datos_por_archivo, errores)
	_chequear_posiciones_en_tablero(datos_por_archivo, errores)


func _chequear_id_coincide_con_archivo(datos_por_archivo: Dictionary, errores: Array[Dictionary]) -> void:
	for ruta in datos_por_archivo.keys():
		var ruta_str: String = ruta as String
		if ruta_str.begins_with("especies/") or ruta_str.begins_with("escenarios/"):
			var datos: Dictionary = datos_por_archivo[ruta]
			var nombre_esperado: String = ruta_str.get_file().get_basename()
			var id_real: String = datos["id"] as String
			if id_real != nombre_esperado:
				errores.append(_error(ruta_str, "id", nombre_esperado, id_real))


func _chequear_especies_existen(datos_por_archivo: Dictionary, especies_validas: Dictionary, errores: Array[Dictionary]) -> void:
	if datos_por_archivo.has("relaciones.json"):
		var pares: Array = (datos_por_archivo["relaciones.json"] as Dictionary).get("pares", []) as Array
		for i in range(pares.size()):
			var par: Dictionary = pares[i]
			for clave in ["a", "b"]:
				var especie: String = par[clave] as String
				if not especies_validas.has(especie):
					errores.append(_error("relaciones.json", "pares[%d].%s" % [i, clave], "una especie existente en especies/", especie))

	for ruta in datos_por_archivo.keys():
		var ruta_str: String = ruta as String
		if not ruta_str.begins_with("escenarios/"):
			continue
		var datos: Dictionary = datos_por_archivo[ruta]
		for lista_nombre in ["tribu", "enemigas"]:
			for criatura in (datos.get(lista_nombre, []) as Array):
				var criatura_dic: Dictionary = criatura as Dictionary
				var especie: String = criatura_dic["especie"] as String
				if not especies_validas.has(especie):
					errores.append(_error(ruta_str, "%s.%s.especie" % [lista_nombre, criatura_dic["id"]], "una especie existente en especies/", especie))


func _chequear_pares_sin_repetir(datos_por_archivo: Dictionary, errores: Array[Dictionary]) -> void:
	if not datos_por_archivo.has("relaciones.json"):
		return
	var pares: Array = (datos_por_archivo["relaciones.json"] as Dictionary).get("pares", []) as Array
	var vistos: Dictionary = {}
	for i in range(pares.size()):
		var par: Dictionary = pares[i]
		var a: String = par["a"] as String
		var b: String = par["b"] as String
		var clave: String = "%s|%s" % [a, b] if a <= b else "%s|%s" % [b, a]
		if vistos.has(clave):
			errores.append(_error("relaciones.json", "pares[%d]" % [i], "un par sin repetir", "%s-%s" % [a, b]))
		else:
			vistos[clave] = true


func _chequear_balanza(datos_por_archivo: Dictionary, errores: Array[Dictionary]) -> void:
	var ruta: String = "tablas/balanza.json"
	if not datos_por_archivo.has(ruta):
		return
	var posiciones: Array = (datos_por_archivo[ruta] as Dictionary).get("posiciones", []) as Array
	var valores: Array = []
	for fila in posiciones:
		valores.append((fila as Dictionary)["posicion"])
	valores.sort()
	if valores != [1, 2, 3, 4, 5]:
		errores.append(_error(ruta, "posiciones", "las posiciones 1 a 5, cada una una sola vez", valores))


func _chequear_sellado(datos_por_archivo: Dictionary, errores: Array[Dictionary]) -> void:
	var ruta: String = "tablas/sellado.json"
	if not datos_por_archivo.has(ruta):
		return
	var tramos: Array = (datos_por_archivo[ruta] as Dictionary).get("tramos", []) as Array
	for i in range(1, tramos.size()):
		var anterior: int = (tramos[i - 1] as Dictionary)["hasta_vida_pct"] as int
		var actual: int = (tramos[i] as Dictionary)["hasta_vida_pct"] as int
		if actual <= anterior:
			errores.append(_error(ruta, "tramos[%d].hasta_vida_pct" % [i], "mayor que %d" % [anterior], actual))


func _chequear_hambre(datos_por_archivo: Dictionary, errores: Array[Dictionary]) -> void:
	var ruta: String = "tablas/hambre.json"
	if not datos_por_archivo.has(ruta):
		return
	var estados: Array = ((datos_por_archivo[ruta] as Dictionary).get("estados", []) as Array).duplicate()
	estados.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return (a["desde"] as int) < (b["desde"] as int))

	var esperado_desde: int = 0
	for estado in estados:
		var estado_dic: Dictionary = estado as Dictionary
		var desde: int = estado_dic["desde"] as int
		if desde != esperado_desde:
			errores.append(_error(ruta, "estados.%s.desde" % [estado_dic["id"]], "%d" % [esperado_desde], desde))
			return
		esperado_desde = (estado_dic["hasta"] as int) + 1

	if esperado_desde != 11:
		errores.append(_error(ruta, "estados", "cobertura completa hasta 10", esperado_desde - 1))


func _chequear_ids_escenario(datos_por_archivo: Dictionary, errores: Array[Dictionary]) -> void:
	for ruta in datos_por_archivo.keys():
		var ruta_str: String = ruta as String
		if not ruta_str.begins_with("escenarios/"):
			continue
		var datos: Dictionary = datos_por_archivo[ruta]
		var vistos: Dictionary = {}
		for lista_nombre in ["tribu", "enemigas"]:
			for criatura in (datos.get(lista_nombre, []) as Array):
				var id_criatura: String = (criatura as Dictionary)["id"] as String
				if vistos.has(id_criatura):
					errores.append(_error(ruta_str, "%s.id" % [lista_nombre], "un id sin repetir en el escenario", id_criatura))
				else:
					vistos[id_criatura] = true


func _chequear_posiciones_en_tablero(datos_por_archivo: Dictionary, errores: Array[Dictionary]) -> void:
	for ruta in datos_por_archivo.keys():
		var ruta_str: String = ruta as String
		if not ruta_str.begins_with("escenarios/"):
			continue
		var datos: Dictionary = datos_por_archivo[ruta]
		var tablero: Dictionary = datos["tablero"] as Dictionary
		var ancho: int = tablero["ancho"] as int
		var alto: int = tablero["alto"] as int

		if datos.has("maestro"):
			_chequear_posicion(ruta_str, "maestro.posicion", (datos["maestro"] as Dictionary).get("posicion"), ancho, alto, errores)
		for lista_nombre in ["tribu", "enemigas"]:
			for criatura in (datos.get(lista_nombre, []) as Array):
				var criatura_dic: Dictionary = criatura as Dictionary
				_chequear_posicion(ruta_str, "%s.%s.posicion" % [lista_nombre, criatura_dic["id"]], criatura_dic.get("posicion"), ancho, alto, errores)


func _chequear_posicion(ruta: String, campo: String, posicion: Variant, ancho: int, alto: int, errores: Array[Dictionary]) -> void:
	if posicion == null:
		return
	var casilla: Array = posicion as Array
	var x: int = casilla[0] as int
	var y: int = casilla[1] as int
	if x < 0 or x >= ancho or y < 0 or y >= alto:
		errores.append(_error(ruta, campo, "dentro del tablero (0..%d, 0..%d)" % [ancho - 1, alto - 1], casilla))


# --- Textos (Arquitectura.md A.2.1) -----------------------------------------

func _chequear_textos(datos_por_archivo: Dictionary, claves_texto_esperadas: Array[String], errores: Array[Dictionary], avisos: Array[Dictionary]) -> void:
	var expresion: RegEx = RegEx.new()
	expresion.compile(_PATRON_CLAVE_TEXTO)

	for ruta in datos_por_archivo.keys():
		var ruta_str: String = ruta as String
		if not ruta_str.begins_with("textos/"):
			continue
		var datos: Dictionary = datos_por_archivo[ruta]
		var claves_archivo: Array[String] = []

		for clave in datos.keys():
			var clave_str: String = clave as String
			if clave_str == "$schema" or clave_str == "_nota":
				continue
			claves_archivo.append(clave_str)
			if expresion.search(clave_str) == null:
				errores.append(_error(ruta_str, clave_str, "una clave con el formato %s" % [_PATRON_CLAVE_TEXTO], clave_str))

		for esperada in claves_texto_esperadas:
			if not datos.has(esperada):
				avisos.append(_error(ruta_str, esperada, "presente en el archivo", null))

		for clave_str in claves_archivo:
			if not claves_texto_esperadas.has(clave_str):
				avisos.append(_error(ruta_str, clave_str, "una clave usada por el codigo", clave_str))


func _error(archivo: String, campo: String, esperado: String, recibido: Variant) -> Dictionary:
	return {"archivo": archivo, "campo": campo, "esperado": esperado, "recibido": recibido}
