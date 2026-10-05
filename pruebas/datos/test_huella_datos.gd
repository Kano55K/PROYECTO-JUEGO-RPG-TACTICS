extends GdUnitTestSuite

# Arquitectura.md A.7 (Huella de los datos) y B.2 (T12, test 16, primera parte):
# SHA-256 de los datos cargados sin textos/ ni escenarios/, sin _nota ni $schema,
# con las claves ordenadas. Con los datos de prueba (DatosFixture), nunca con datos/.


func _datos() -> Dictionary:
	var lectura: Dictionary = DatosFixture.cargar()
	var errores: Array[Dictionary] = lectura["errores"]
	assert_array(errores).override_failure_message(str(errores)).is_empty()
	return lectura["datos"]


# (16) Cambiar un numero cambia la huella; cambiar solo una _nota, el $schema,
# un texto o un numero de un escenario no; el orden de las claves no importa.
func test_huella_cambia_con_numeros_y_no_con_notas_ni_textos() -> void:
	var datos: Dictionary = _datos()
	var huella: String = HuellaDatos.calcular(datos)
	assert_int(huella.length()).is_equal(64)
	assert_bool(huella.is_valid_hex_number()).is_true()
	assert_str(HuellaDatos.calcular(_datos())).is_equal(huella)

	var otro_numero: Dictionary = datos.duplicate(true)
	(otro_numero["tablas/combate.json"] as Dictionary)["danio_minimo"] = 2
	assert_str(HuellaDatos.calcular(otro_numero)).is_not_equal(huella)

	var otra_nota: Dictionary = datos.duplicate(true)
	(otra_nota["tablas/combate.json"] as Dictionary)["_nota"] = "otra nota"
	((otra_nota["tablas/lealtad.json"] as Dictionary)["eventos"] as Dictionary)["_nota"] = "otra nota"
	(otra_nota["tablas/hambre.json"] as Dictionary).erase("_nota")
	(otra_nota["maestro.json"] as Dictionary)["$schema"] = "../otra/ruta.schema.json"
	assert_str(HuellaDatos.calcular(otra_nota)).is_equal(huella)

	var con_textos: Dictionary = datos.duplicate(true)
	con_textos["textos/es.json"] = {"caida.rodauva": "Un texto."}
	assert_str(HuellaDatos.calcular(con_textos)).is_equal(huella)
	con_textos["textos/es.json"] = {"caida.rodauva": "Otro texto."}
	assert_str(HuellaDatos.calcular(con_textos)).is_equal(huella)

	# A.7 (correccion del 04/10/2026): la grabacion lleva su escenario entero.
	var lectura_escenario: Dictionary = LectorFixture.leer("res://pruebas/fixtures/combate/escenario_c.json", "escenario")
	var errores_escenario: Array[Dictionary] = lectura_escenario["errores"]
	assert_array(errores_escenario).override_failure_message(str(errores_escenario)).is_empty()
	var con_escenario: Dictionary = datos.duplicate(true)
	con_escenario["escenarios/c_tasajero.json"] = lectura_escenario["datos"]
	assert_str(HuellaDatos.calcular(con_escenario)).is_equal(huella)
	(con_escenario["escenarios/c_tasajero.json"] as Dictionary)["semilla"] = 33002
	assert_str(HuellaDatos.calcular(con_escenario)).is_equal(huella)

	# Las mismas claves agregadas en orden inverso.
	var invertido: Dictionary = {}
	var rutas: Array = datos.keys()
	rutas.reverse()
	for ruta in rutas:
		var original: Dictionary = datos[ruta]
		var copia: Dictionary = {}
		var claves: Array = original.keys()
		claves.reverse()
		for clave in claves:
			copia[clave] = original[clave]
		invertido[ruta] = copia
	assert_str(HuellaDatos.calcular(invertido)).is_equal(huella)
