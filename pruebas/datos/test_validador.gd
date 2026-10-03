extends GdUnitTestSuite

# Arquitectura.md A.2 y B.2 (T03, sesion 1): subconjunto de JSON Schema, sin
# cargador de archivos ni chequeos cruzados. Fixtures en pruebas/fixtures/validador,
# no los esquemas reales de datos/_esquemas/.
const _CARPETA_FIXTURES: String = "res://pruebas/fixtures/validador/"


func _cargar(nombre_archivo: String) -> Variant:
	var contenido: String = FileAccess.get_file_as_string(_CARPETA_FIXTURES + nombre_archivo)
	return JSON.parse_string(contenido)


func test_campo_mal_tipeado_es_rechazado() -> void:
	var esquema: Dictionary = _cargar("esquema_ficha.schema.json")
	var datos: Dictionary = _cargar("ficha_campo_mal_tipeado.json")
	var resultado: Dictionary = Validador.new().validar(datos, esquema, "ficha_campo_mal_tipeado.json")
	var errores: Array[Dictionary] = resultado["errores"]

	assert_int(errores.size()).is_equal(1)
	assert_str(errores[0]["archivo"] as String).is_equal("ficha_campo_mal_tipeado.json")
	assert_str(errores[0]["campo"] as String).is_equal("vidaa")
	assert_str(errores[0]["esperado"] as String).is_equal("un campo definido en el esquema")


func test_decimal_donde_va_entero_es_rechazado() -> void:
	var esquema: Dictionary = _cargar("esquema_ficha.schema.json")
	var datos: Dictionary = _cargar("ficha_decimal_donde_va_entero.json")
	var resultado: Dictionary = Validador.new().validar(datos, esquema, "ficha_decimal_donde_va_entero.json")
	var errores: Array[Dictionary] = resultado["errores"]

	assert_int(errores.size()).is_equal(1)
	assert_str(errores[0]["campo"] as String).is_equal("vida")
	assert_str(errores[0]["esperado"] as String).is_equal("integer")
	assert_float(errores[0]["recibido"] as float).is_equal(12.5)


func test_entero_de_godot_12_0_se_acepta_y_convierte() -> void:
	var esquema: Dictionary = _cargar("esquema_ficha.schema.json")
	var datos: Dictionary = _cargar("ficha_entero_godot.json")
	var resultado: Dictionary = Validador.new().validar(datos, esquema, "ficha_entero_godot.json")
	var errores: Array[Dictionary] = resultado["errores"]

	assert_array(errores).is_empty()
	var convertidos: Dictionary = resultado["datos"]
	assert_bool(typeof(convertidos["vida"]) == TYPE_INT).is_true()
	assert_int(convertidos["vida"] as int).is_equal(12)


func test_valor_fuera_de_rango_es_rechazado() -> void:
	var esquema: Dictionary = _cargar("esquema_ficha.schema.json")
	var datos: Dictionary = _cargar("ficha_valor_fuera_de_rango.json")
	var resultado: Dictionary = Validador.new().validar(datos, esquema, "ficha_valor_fuera_de_rango.json")
	var errores: Array[Dictionary] = resultado["errores"]

	assert_int(errores.size()).is_equal(1)
	assert_str(errores[0]["campo"] as String).is_equal("vida")
	assert_str(errores[0]["esperado"] as String).is_equal("menor o igual a 999")
	assert_float(errores[0]["recibido"] as float).is_equal(1000.0)


func test_obligatorio_faltante_es_rechazado() -> void:
	var esquema: Dictionary = _cargar("esquema_ficha.schema.json")
	var datos: Dictionary = _cargar("ficha_obligatorio_faltante.json")
	var resultado: Dictionary = Validador.new().validar(datos, esquema, "ficha_obligatorio_faltante.json")
	var errores: Array[Dictionary] = resultado["errores"]

	assert_int(errores.size()).is_equal(1)
	assert_str(errores[0]["campo"] as String).is_equal("nombre")
	assert_str(errores[0]["esperado"] as String).is_equal("presente (obligatorio)")


func test_enum_invalido_es_rechazado() -> void:
	var esquema: Dictionary = _cargar("esquema_ficha.schema.json")
	var datos: Dictionary = _cargar("ficha_enum_invalido.json")
	var resultado: Dictionary = Validador.new().validar(datos, esquema, "ficha_enum_invalido.json")
	var errores: Array[Dictionary] = resultado["errores"]

	assert_int(errores.size()).is_equal(1)
	assert_str(errores[0]["campo"] as String).is_equal("rango")
	assert_str(errores[0]["esperado"] as String).is_equal("uno de [bajo, medio, alto]")
	assert_str(errores[0]["recibido"] as String).is_equal("altisimo")


func test_type_con_lista_acepta_entero_y_array() -> void:
	var esquema: Dictionary = _cargar("esquema_type_lista.schema.json")

	var datos_entero: Dictionary = _cargar("alcance_entero.json")
	var resultado_entero: Dictionary = Validador.new().validar(datos_entero, esquema, "alcance_entero.json")
	assert_array(resultado_entero["errores"] as Array[Dictionary]).is_empty()

	var datos_lista: Dictionary = _cargar("alcance_lista.json")
	var resultado_lista: Dictionary = Validador.new().validar(datos_lista, esquema, "alcance_lista.json")
	assert_array(resultado_lista["errores"] as Array[Dictionary]).is_empty()


func test_type_con_lista_rechaza_otro_tipo() -> void:
	var esquema: Dictionary = _cargar("esquema_type_lista.schema.json")
	var datos: Dictionary = _cargar("alcance_invalido.json")
	var resultado: Dictionary = Validador.new().validar(datos, esquema, "alcance_invalido.json")
	var errores: Array[Dictionary] = resultado["errores"]

	assert_int(errores.size()).is_equal(1)
	assert_str(errores[0]["campo"] as String).is_equal("alcance")
	assert_str(errores[0]["esperado"] as String).is_equal("integer o array")


func test_diccionario_claves_libres_acepta_valor_valido() -> void:
	var esquema: Dictionary = _cargar("esquema_diccionario.schema.json")
	var datos: Dictionary = _cargar("diccionario_valido.json")
	var resultado: Dictionary = Validador.new().validar(datos, esquema, "diccionario_valido.json")

	assert_array(resultado["errores"] as Array[Dictionary]).is_empty()


func test_diccionario_claves_libres_rechaza_valor_invalido() -> void:
	var esquema: Dictionary = _cargar("esquema_diccionario.schema.json")
	var datos: Dictionary = _cargar("diccionario_valor_invalido.json")
	var resultado: Dictionary = Validador.new().validar(datos, esquema, "diccionario_valor_invalido.json")
	var errores: Array[Dictionary] = resultado["errores"]

	assert_int(errores.size()).is_equal(1)
	assert_str(errores[0]["campo"] as String).is_equal("saludo.hola")
	assert_str(errores[0]["esperado"] as String).is_equal("string o array")


func test_minitems_rechaza_array_vacio() -> void:
	var esquema: Dictionary = _cargar("esquema_array_limites.schema.json")
	var datos: Dictionary = _cargar("turnos_vacio.json")
	var resultado: Dictionary = Validador.new().validar(datos, esquema, "turnos_vacio.json")
	var errores: Array[Dictionary] = resultado["errores"]

	assert_int(errores.size()).is_equal(1)
	assert_str(errores[0]["campo"] as String).is_equal("turnos")
	assert_str(errores[0]["esperado"] as String).is_equal("al menos 1 elementos")


func test_maxitems_rechaza_array_con_exceso() -> void:
	var esquema: Dictionary = _cargar("esquema_array_limites.schema.json")
	var datos: Dictionary = _cargar("turnos_exceso.json")
	var resultado: Dictionary = Validador.new().validar(datos, esquema, "turnos_exceso.json")
	var errores: Array[Dictionary] = resultado["errores"]

	assert_int(errores.size()).is_equal(1)
	assert_str(errores[0]["campo"] as String).is_equal("turnos")
	assert_str(errores[0]["esperado"] as String).is_equal("como mucho 3 elementos")


func test_ref_defs_resuelve_referencia_y_valida_adentro() -> void:
	var esquema: Dictionary = _cargar("esquema_ref_defs.schema.json")

	var datos_validos: Dictionary = _cargar("ref_valido.json")
	var resultado_valido: Dictionary = Validador.new().validar(datos_validos, esquema, "ref_valido.json")
	assert_array(resultado_valido["errores"] as Array[Dictionary]).is_empty()

	var datos_invalidos: Dictionary = _cargar("ref_invalido.json")
	var resultado_invalido: Dictionary = Validador.new().validar(datos_invalidos, esquema, "ref_invalido.json")
	var errores: Array[Dictionary] = resultado_invalido["errores"]
	assert_int(errores.size()).is_equal(1)
	assert_str(errores[0]["campo"] as String).is_equal("posicion.y")
	assert_str(errores[0]["esperado"] as String).is_equal("presente (obligatorio)")


func test_esquema_con_palabra_clave_desconocida_es_error() -> void:
	var esquema: Dictionary = _cargar("esquema_palabra_desconocida.schema.json")
	var datos: Dictionary = _cargar("ficha_palabra_desconocida_dato.json")
	var resultado: Dictionary = Validador.new().validar(datos, esquema, "ficha_palabra_desconocida_dato.json")
	var errores: Array[Dictionary] = resultado["errores"]

	assert_int(errores.size()).is_equal(1)
	assert_str(errores[0]["campo"] as String).is_equal("$esquema.nombre.minLength")
	assert_str(errores[0]["esperado"] as String).is_equal("una palabra clave del subconjunto admitido")
	assert_str(errores[0]["recibido"] as String).is_equal("minLength")
