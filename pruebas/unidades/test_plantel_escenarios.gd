extends GdUnitTestSuite

# Arquitectura.md B.2 (T05, criterio 3) y A.6: test de datos reales. Con datos/
# se crea el plantel de los 11 escenarios. No compara contra numeros de
# Sistema.md: la vida maxima se lee de la balanza cargada.
const _CARPETA_DATOS: String = "res://datos"


func _datos() -> Dictionary:
	var resultado: Dictionary = Cargador.new().cargar_carpeta(_CARPETA_DATOS)
	var errores: Array[Dictionary] = resultado["errores"]
	assert_array(errores).override_failure_message(str(errores)).is_empty()
	return resultado["datos"]


func test_once_escenarios_crean_plantel() -> void:
	var datos: Dictionary = _datos()
	var cantidad: int = 0
	for ruta in datos.keys():
		if not (ruta as String).begins_with("escenarios/"):
			continue
		cantidad += 1
		var escenario: Dictionary = datos[ruta]
		var plantel: Plantel = Plantel.desde_datos(datos, escenario)
		assert_object(plantel).override_failure_message(ruta).is_not_null()
		assert_object(plantel.maestro).override_failure_message(ruta).is_not_null()

		var tribu: Array = escenario["tribu"]
		var enemigas: Array = escenario["enemigas"]
		var atacantes: int = 0
		for enemiga in enemigas:
			if (enemiga as Dictionary)["comportamiento"] == "atacante_nocturna":
				atacantes += 1
		assert_int(plantel.criaturas().size()).override_failure_message(ruta).is_equal(tribu.size() + enemigas.size())
		var esperados: int = tribu.size() + atacantes + (escenario["pergaminos_en_blanco"] as int)
		assert_int(plantel.pergaminos().size()).override_failure_message(ruta).is_equal(esperados)
		for criatura in plantel.criaturas():
			assert_object(criatura.especie).override_failure_message(criatura.id).is_not_null()
	assert_int(cantidad).is_equal(11)


# Sistema.md 11.9, F: el Maestro empieza en 6, con la vida maxima de su balanza.
func test_f_maestro_en_6() -> void:
	var datos: Dictionary = _datos()
	var plantel: Plantel = Plantel.desde_datos(datos, datos["escenarios/f_rescate.json"])
	assert_int(plantel.maestro.vida).is_equal(6)
	var tabla: TablaBalanza = TablaBalanza.new(datos["tablas/balanza.json"])
	var fila: Dictionary = tabla.fila(plantel.maestro.balanza)
	assert_int(plantel.maestro.vida_max_real()).is_equal(fila["vida_max_real"] as int)
