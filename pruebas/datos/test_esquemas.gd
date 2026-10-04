extends GdUnitTestSuite

# Arquitectura.md A.2 y B.2 (T04, sesion 1): los esquemas reales de entrada en
# datos/_esquemas/. Se resuelven con el Cargador y se validan con el Validador;
# los escenarios de prueba viven en pruebas/fixtures/esquemas/.
const _CARPETA_DATOS: String = "res://datos"
const _CARPETA_FIXTURES: String = "res://pruebas/fixtures/esquemas/"

# Los 13 archivos de entrada de la tabla de A.2 (resultado y grabacion son de T12).
const _ESQUEMAS_DE_ENTRADA: Array[String] = [
	"especie", "maestro", "hechizos", "relaciones", "balanza", "arrimo",
	"sellado", "costos_mana", "hambre", "lealtad", "combate", "escenario", "textos",
]


func _esquema(nombre: String) -> Dictionary:
	var resultado: Dictionary = Cargador.new().esquema_resuelto(_CARPETA_DATOS, nombre)
	return resultado["esquema"]


func _validar_escenario(nombre_fixture: String) -> Array[Dictionary]:
	var contenido: String = FileAccess.get_file_as_string(_CARPETA_FIXTURES + nombre_fixture)
	var datos: Variant = JSON.parse_string(contenido)
	var resultado: Dictionary = Validador.new().validar(datos, _esquema("escenario"), nombre_fixture)
	return resultado["errores"]


# Recorre todos los nodos de esquema (no los nombres de propiedades) y anota
# en "problemas" lo que incumple el subconjunto y las reglas de A.2.
func _revisar_nodo(nodo: Dictionary, ruta: String, problemas: Array[String]) -> void:
	for clave in nodo.keys():
		if not Validador._PALABRAS_CLAVE_ESQUEMA.has(clave):
			problemas.append("%s: palabra fuera del subconjunto '%s'" % [ruta, clave])

	if nodo.has("properties"):
		var propiedades: Dictionary = nodo["properties"]
		if not nodo.has("additionalProperties"):
			problemas.append("%s: objeto sin additionalProperties" % [ruta])
		if not propiedades.has("_nota"):
			problemas.append("%s: objeto sin _nota" % [ruta])
		for clave in propiedades.keys():
			_revisar_nodo(propiedades[clave], "%s.%s" % [ruta, clave], problemas)

	if nodo.get("items") is Dictionary:
		_revisar_nodo(nodo["items"], ruta + "[]", problemas)
	if nodo.get("additionalProperties") is Dictionary:
		_revisar_nodo(nodo["additionalProperties"], ruta + ".*", problemas)
	if nodo.has("$defs"):
		var defs: Dictionary = nodo["$defs"]
		for clave in defs.keys():
			_revisar_nodo(defs[clave], "%s.$defs.%s" % [ruta, clave], problemas)


func test_esquemas_de_entrada_resuelven() -> void:
	for nombre in _ESQUEMAS_DE_ENTRADA:
		var resultado: Dictionary = Cargador.new().esquema_resuelto(_CARPETA_DATOS, nombre)
		var errores: Array[Dictionary] = resultado["errores"]
		assert_array(errores).override_failure_message("%s: %s" % [nombre, errores]).is_empty()
		assert_bool((resultado["esquema"] as Dictionary).is_empty()).override_failure_message(nombre).is_false()


func test_esquemas_usan_solo_el_subconjunto_y_son_estrictos() -> void:
	var problemas: Array[String] = []
	for nombre in _ESQUEMAS_DE_ENTRADA:
		var esquema: Dictionary = _esquema(nombre)
		_revisar_nodo(esquema, nombre, problemas)
		# A.2, fila "Notas": la raiz de cada archivo admite $schema.
		if not (esquema.get("properties", {}) as Dictionary).has("$schema"):
			problemas.append("%s: la raiz no declara $schema" % [nombre])
	assert_array(problemas).override_failure_message(" | ".join(problemas)).is_empty()


func test_ejemplo_a2_valida() -> void:
	var errores: Array[Dictionary] = _validar_escenario("escenario_ejemplo_a2.json")
	assert_array(errores).override_failure_message(str(errores)).is_empty()


# Criterio de terminado de T04: _nota dentro de cada unidad y "guardada" como estado.
func test_nota_en_unidades_y_guardada_valida() -> void:
	var errores: Array[Dictionary] = _validar_escenario("escenario_nota_guardada.json")
	assert_array(errores).override_failure_message(str(errores)).is_empty()


func test_campo_mal_tipeado_en_unidad_falla() -> void:
	var errores: Array[Dictionary] = _validar_escenario("escenario_campo_mal_tipeado.json")
	assert_int(errores.size()).is_equal(1)
	assert_str(errores[0]["campo"] as String).is_equal("tribu[0].danoi")
	assert_str(errores[0]["esperado"] as String).is_equal("un campo definido en el esquema")


# T04, sesion 4: la atacante nocturna de G lleva hambre (0-10, como la tribu).
func test_hambre_en_enemiga_valida() -> void:
	var errores: Array[Dictionary] = _validar_escenario("escenario_enemiga_hambre.json")
	assert_array(errores).override_failure_message(str(errores)).is_empty()


func test_hambre_en_enemiga_fuera_de_rango_falla() -> void:
	var errores: Array[Dictionary] = _validar_escenario("escenario_enemiga_hambre_fuera_de_rango.json")
	assert_int(errores.size()).override_failure_message(str(errores)).is_equal(1)
	assert_str(errores[0]["campo"] as String).is_equal("enemigas[0].hambre")
