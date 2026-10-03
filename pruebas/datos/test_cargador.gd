extends GdUnitTestSuite

# Arquitectura.md A.2 y B.2 (T03, sesion 2): cargador de carpeta de datos,
# eleccion de esquema por convencion, resolucion de $ref entre archivos y los
# ocho chequeos cruzados, mas los de textos/es.json (A.2.1). Fixtures propias
# en pruebas/fixtures/cargador/, nunca datos/ real.
const _CARPETA_FIXTURES: String = "res://pruebas/fixtures/cargador/"


func _buscar_error(errores: Array[Dictionary], archivo: String) -> Dictionary:
	for error in errores:
		if (error["archivo"] as String) == archivo:
			return error
	return {}


func test_id_debe_coincidir_con_archivo() -> void:
	var resultado: Dictionary = Cargador.new().cargar_carpeta(_CARPETA_FIXTURES + "id_coincide")
	var errores: Array[Dictionary] = resultado["errores"]

	assert_int(errores.size()).is_equal(2)
	assert_bool(resultado["datos"] == null).is_true()

	var error_especie: Dictionary = _buscar_error(errores, "especies/malo.json")
	assert_str(error_especie["campo"] as String).is_equal("id")
	assert_str(error_especie["esperado"] as String).is_equal("malo")
	assert_str(error_especie["recibido"] as String).is_equal("otra_cosa")

	var error_escenario: Dictionary = _buscar_error(errores, "escenarios/feo.json")
	assert_str(error_escenario["campo"] as String).is_equal("id")
	assert_str(error_escenario["esperado"] as String).is_equal("feo")
	assert_str(error_escenario["recibido"] as String).is_equal("otro_id")


func test_especie_referenciada_debe_existir() -> void:
	var resultado: Dictionary = Cargador.new().cargar_carpeta(_CARPETA_FIXTURES + "especies_existentes")
	var errores: Array[Dictionary] = resultado["errores"]

	var error_relaciones: Dictionary = _buscar_error(errores, "relaciones.json")
	assert_str(error_relaciones["esperado"] as String).is_equal("una especie existente en especies/")
	assert_str(error_relaciones["recibido"] as String).is_equal("duende")

	var error_escenario: Dictionary = _buscar_error(errores, "escenarios/a_dia_1.json")
	assert_str(error_escenario["esperado"] as String).is_equal("una especie existente en especies/")
	assert_str(error_escenario["recibido"] as String).is_equal("trol")


func test_pares_sin_repetir() -> void:
	var resultado: Dictionary = Cargador.new().cargar_carpeta(_CARPETA_FIXTURES + "pares_repetidos")
	var errores: Array[Dictionary] = resultado["errores"]

	assert_int(errores.size()).is_equal(1)
	assert_str(errores[0]["archivo"] as String).is_equal("relaciones.json")
	assert_str(errores[0]["esperado"] as String).is_equal("un par sin repetir")


func test_balanza_posiciones_1_a_5() -> void:
	var resultado: Dictionary = Cargador.new().cargar_carpeta(_CARPETA_FIXTURES + "balanza_posiciones")
	var errores: Array[Dictionary] = resultado["errores"]

	assert_int(errores.size()).is_equal(1)
	assert_str(errores[0]["archivo"] as String).is_equal("tablas/balanza.json")
	assert_str(errores[0]["esperado"] as String).is_equal("las posiciones 1 a 5, cada una una sola vez")


func test_sellado_tramos_crecientes() -> void:
	var resultado: Dictionary = Cargador.new().cargar_carpeta(_CARPETA_FIXTURES + "sellado_tramos")
	var errores: Array[Dictionary] = resultado["errores"]

	assert_int(errores.size()).is_equal(1)
	assert_str(errores[0]["archivo"] as String).is_equal("tablas/sellado.json")
	assert_str(errores[0]["campo"] as String).is_equal("tramos[1].hasta_vida_pct")
	assert_str(errores[0]["esperado"] as String).is_equal("mayor que 50")


func test_hambre_cubre_0_10_sin_huecos() -> void:
	var resultado: Dictionary = Cargador.new().cargar_carpeta(_CARPETA_FIXTURES + "hambre_cobertura")
	var errores: Array[Dictionary] = resultado["errores"]

	assert_int(errores.size()).is_equal(1)
	assert_str(errores[0]["archivo"] as String).is_equal("tablas/hambre.json")
	assert_str(errores[0]["esperado"] as String).is_equal("5")


func test_escenario_ids_sin_repetir() -> void:
	var resultado: Dictionary = Cargador.new().cargar_carpeta(_CARPETA_FIXTURES + "escenario_ids_repetidos")
	var errores: Array[Dictionary] = resultado["errores"]

	assert_int(errores.size()).is_equal(1)
	assert_str(errores[0]["archivo"] as String).is_equal("escenarios/a_dia_1.json")
	assert_str(errores[0]["esperado"] as String).is_equal("un id sin repetir en el escenario")
	assert_str(errores[0]["recibido"] as String).is_equal("rodauva_1")


func test_escenario_posiciones_dentro_del_tablero() -> void:
	var resultado: Dictionary = Cargador.new().cargar_carpeta(_CARPETA_FIXTURES + "escenario_posiciones_tablero")
	var errores: Array[Dictionary] = resultado["errores"]

	assert_int(errores.size()).is_equal(1)
	assert_str(errores[0]["archivo"] as String).is_equal("escenarios/a_dia_1.json")
	assert_str(errores[0]["campo"] as String).is_equal("tribu.rodauva_1.posicion")
	assert_array(errores[0]["recibido"] as Array).is_equal([9, 9])


func test_textos_formato_de_clave() -> void:
	var resultado: Dictionary = Cargador.new().cargar_carpeta(_CARPETA_FIXTURES + "textos_formato_clave")
	var errores: Array[Dictionary] = resultado["errores"]

	assert_int(errores.size()).is_equal(1)
	assert_str(errores[0]["archivo"] as String).is_equal("textos/es.json")
	assert_str(errores[0]["campo"] as String).is_equal("Clave-Mala")


func test_textos_claves_faltantes_y_sobrantes() -> void:
	var claves_esperadas: Array[String] = ["saludo.hola", "falta.clave"]
	var resultado: Dictionary = Cargador.new().cargar_carpeta(_CARPETA_FIXTURES + "textos_faltantes_sobrantes", claves_esperadas)
	var avisos: Array[Dictionary] = resultado["avisos"]

	assert_array(resultado["errores"] as Array[Dictionary]).is_empty()
	assert_bool(resultado["datos"] != null).is_true()
	assert_int(avisos.size()).is_equal(2)

	var aviso_faltante: Dictionary = {}
	var aviso_sobrante: Dictionary = {}
	for aviso in avisos:
		if (aviso["campo"] as String) == "falta.clave":
			aviso_faltante = aviso
		elif (aviso["campo"] as String) == "extra.clave":
			aviso_sobrante = aviso

	assert_str(aviso_faltante["esperado"] as String).is_equal("presente en el archivo")
	assert_str(aviso_sobrante["esperado"] as String).is_equal("una clave usada por el codigo")


func test_json_con_error_de_sintaxis() -> void:
	var resultado: Dictionary = Cargador.new().cargar_carpeta(_CARPETA_FIXTURES + "json_roto")
	var errores: Array[Dictionary] = resultado["errores"]

	assert_int(errores.size()).is_equal(1)
	assert_str(errores[0]["archivo"] as String).is_equal("relaciones.json")
	assert_bool((errores[0]["campo"] as String).begins_with("linea ")).is_true()
	assert_str(errores[0]["esperado"] as String).is_equal("JSON valido")
	assert_bool(resultado["datos"] == null).is_true()


func test_un_error_ningun_dato() -> void:
	var resultado: Dictionary = Cargador.new().cargar_carpeta(_CARPETA_FIXTURES + "un_error_ningun_dato")

	assert_array(resultado["errores"] as Array[Dictionary]).is_not_empty()
	assert_bool(resultado["datos"] == null).is_true()


func test_cargador_usa_solo_la_carpeta_recibida() -> void:
	# "ocarra" existe en datos/especies/ocarra.json real, pero no en esta fixture:
	# si el cargador mirara datos/ por su cuenta, esto pasaria sin error.
	var resultado: Dictionary = Cargador.new().cargar_carpeta(_CARPETA_FIXTURES + "usa_solo_la_carpeta_recibida")
	var errores: Array[Dictionary] = resultado["errores"]

	assert_int(errores.size()).is_equal(1)
	assert_str(errores[0]["esperado"] as String).is_equal("una especie existente en especies/")
	assert_str(errores[0]["recibido"] as String).is_equal("ocarra")


func test_resuelve_ref_entre_archivos_de_esquema() -> void:
	var resultado_valido: Dictionary = Cargador.new().cargar_carpeta(_CARPETA_FIXTURES + "ref_entre_archivos/valido")
	assert_array(resultado_valido["errores"] as Array[Dictionary]).is_empty()

	var resultado_invalido: Dictionary = Cargador.new().cargar_carpeta(_CARPETA_FIXTURES + "ref_entre_archivos/invalido")
	var errores: Array[Dictionary] = resultado_invalido["errores"]
	assert_int(errores.size()).is_equal(1)
	assert_str(errores[0]["campo"] as String).is_equal("id")
	assert_str(errores[0]["esperado"] as String).is_equal("que matchee ^[a-z0-9_]+$")
	assert_str(errores[0]["recibido"] as String).is_equal("MALO")


func test_carpeta_valida_no_tiene_errores_ni_avisos() -> void:
	var claves_esperadas: Array[String] = ["saludo.hola", "despedida.chau"]
	var resultado: Dictionary = Cargador.new().cargar_carpeta(_CARPETA_FIXTURES + "carpeta_valida", claves_esperadas)

	assert_array(resultado["errores"] as Array[Dictionary]).is_empty()
	assert_array(resultado["avisos"] as Array[Dictionary]).is_empty()

	var datos: Dictionary = resultado["datos"]
	var balanza: Dictionary = datos["tablas/balanza.json"]
	var posiciones: Array = balanza["posiciones"]
	var primera: Dictionary = posiciones[0]
	assert_bool(typeof(primera["posicion"]) == TYPE_INT).is_true()
	assert_int(primera["posicion"] as int).is_equal(1)

	var escenario: Dictionary = datos["escenarios/a_dia_1.json"]
	var tablero: Dictionary = escenario["tablero"]
	assert_int(tablero["ancho"] as int).is_equal(8)
