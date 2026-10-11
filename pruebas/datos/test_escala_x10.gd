extends GdUnitTestSuite

# Arquitectura.md B.3 (T44), criterio 2, y D-009: la escala x10 de vida y daño
# (Sistema.md 11.1, 1.2, 11.2 y 11.9 v1.7) con datos/ real. Comprueba lo que sale
# del plantel armado, no los JSON: la balanza del Maestro, el escenario F y la
# vida de cambio del Tasajero (11.2.3).
const _CARPETA_DATOS: String = "res://datos"


func _datos() -> Dictionary:
	var resultado: Dictionary = Cargador.new().cargar_carpeta(_CARPETA_DATOS)
	var errores: Array[Dictionary] = resultado["errores"]
	assert_array(errores).override_failure_message(str(errores)).is_empty()
	return resultado["datos"]


func _plantel(datos: Dictionary, escenario_id: String) -> Plantel:
	return Plantel.desde_datos(datos, datos["escenarios/%s.json" % escenario_id])


# Sistema.md 1.2 y 11.2 v1.7: balanza 2, 200 de vida y 40 de daño.
func test_a_maestro_200_y_40() -> void:
	var plantel: Plantel = _plantel(_datos(), "a_dia_1")
	assert_int(plantel.maestro.vida).is_equal(200)
	assert_int(plantel.maestro.danio_cuerpo()).is_equal(40)


# Sistema.md 11.9 v1.7: F empieza con el Maestro en 60.
func test_f_maestro_60() -> void:
	assert_int(_plantel(_datos(), "f_rescate").maestro.vida).is_equal(60)


# Sistema.md 1.2 v1.7: balanza 5 (Soplo), 140 de vida y 30 de daño.
func test_h_maestro_140_y_30() -> void:
	var plantel: Plantel = _plantel(_datos(), "h_soplo")
	assert_int(plantel.maestro.balanza).is_equal(5)
	assert_int(plantel.maestro.vida).is_equal(140)
	assert_int(plantel.maestro.danio_cuerpo()).is_equal(30)


# Sistema.md 11.2 y 11.2.3 v1.7: el Tasajero tiene 300 y pasa a Cuenta con 150 (50 %).
func test_tasajero_300_y_cambio_150() -> void:
	var tasajero: Criatura = _plantel(_datos(), "c_tasajero").criatura("tasajero_s1")
	assert_int(tasajero.vida).is_equal(300)
	assert_int(CambioModo.vida_de_cambio(tasajero) as int).is_equal(150)


# Arquitectura.md B.3 (T22), criterio 1, y D-010: los hechizos en la escala x10
# (Sistema.md 1.6 y 11.1 v1.7), desde datos/ y el Poder de cada escenario. A
# (Poder 1): Martillazo 30 y Remiendo 40; H (Poder 3): 50 y 60. Costos 2/2/4 sin
# descuento de la balanza (2.3) y choque de la Lanzadera 10.
func test_hechizos_desde_datos() -> void:
	var datos: Dictionary = _datos()
	var hechizos: Hechizos = Hechizos.desde_datos(datos["hechizos.json"], datos["maestro.json"])
	assert_object(hechizos).is_not_null()
	var poder_a: int = _plantel(datos, "a_dia_1").maestro.poder
	var poder_h: int = _plantel(datos, "h_soplo").maestro.poder
	assert_int(poder_a).is_equal(1)
	assert_int(poder_h).is_equal(3)
	assert_int(hechizos.valor("martillazo", poder_a)).is_equal(30)
	assert_int(hechizos.valor("remiendo", poder_a)).is_equal(40)
	assert_int(hechizos.valor("martillazo", poder_h)).is_equal(50)
	assert_int(hechizos.valor("remiendo", poder_h)).is_equal(60)
	assert_int(hechizos.hechizo("martillazo")["costo"]).is_equal(2)
	assert_int(hechizos.hechizo("lanzadera")["costo"]).is_equal(2)
	assert_int(hechizos.hechizo("remiendo")["costo"]).is_equal(4)
	assert_int(hechizos.hechizo("lanzadera")["danio_choque"]).is_equal(10)
