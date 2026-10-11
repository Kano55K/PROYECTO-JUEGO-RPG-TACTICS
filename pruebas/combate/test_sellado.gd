extends GdUnitTestSuite

# Arquitectura.md B.4 (T24), criterios 1 y 2: la regla Sellado con fixtures
# (A.6). Sistema.md 4.1 (tabla de sellado), 2.3 (costo de sellar 3 / 5 / 7, con el
# descuento de la balanza y minimo 1) y 4.2 (lealtad inicial del camino de
# combate: 2, 1 con balanza 3-4, 0 con 5).
const _CARPETA_UNIDADES: String = "res://pruebas/fixtures/unidades/"
# Sistema.md 4.1: una vida maxima con la que 25 %, 50 % y 75 % caen justo en una
# vida entera y la vida siguiente da un % no entero (25,7; 50,7; 75,7).
const _VIDA_MAX: int = 140


func _maestro(balanza: int) -> Maestro:
	var tabla: TablaBalanza = TablaBalanza.new(LectorFixture.leer(_CARPETA_UNIDADES + "balanza_1_2.json",
			"balanza")["datos"])
	return Maestro.new(tabla, balanza)


# (1) Cada tramo y rango, con los bordes: el limite esta incluido (35 de 140 es
# 25 % justo) y la vida siguiente pasa al otro tramo aunque su % no sea entero.
# Truncar 36/140 = 25,7 % daria 25 y el tramo de abajo; la comparacion entera no.
func test_tabla_por_tramo_y_rango_con_los_bordes() -> void:
	var sellado: Sellado = DatosFixture.sellado()
	# vida -> [rango 1, rango 2, rango 3] (Sistema.md 4.1).
	var casos: Dictionary = {
		1: [80, 65, 50],
		35: [80, 65, 50],
		36: [50, 35, 20],
		70: [50, 35, 20],
		71: [20, 10, 5],
		105: [20, 10, 5],
		106: [5, 0, 0],
		140: [5, 0, 0],
	}
	for vida: int in casos.keys():
		for rango in range(1, 4):
			assert_int(sellado.porcentaje(vida, _VIDA_MAX, rango)) \
					.override_failure_message("vida %d, rango %d" % [vida, rango]) \
					.is_equal(casos[vida][rango - 1])


# (1) Lo mismo con otra vida maxima (33: ningun borde es entero): 8 (24,2 %) y 9
# (27,3 %), 16 (48,5 %) y 17 (51,5 %), 24 (72,7 %) y 25 (75,8 %).
func test_bordes_con_vida_maxima_impar() -> void:
	var sellado: Sellado = DatosFixture.sellado()
	var casos: Dictionary = {8: 80, 9: 50, 16: 50, 17: 20, 24: 20, 25: 5}
	for vida: int in casos.keys():
		assert_int(sellado.porcentaje(vida, 33, 1)).override_failure_message("vida %d" % vida) \
				.is_equal(casos[vida])


# (2) Costo: balanza 2 (sin descuento) 3 / 5; balanza 3 (descuento 1) 2 / 4;
# balanza 5 (descuento 2) 1 / 3 / 5.
func test_costo_con_balanza_2_3_y_5() -> void:
	var sellado: Sellado = DatosFixture.sellado()
	var especies: Dictionary = MesaSellar.especies()
	var rango_1: Especie = especies["ocarra"]
	var rango_2: Especie = especies["especie_sellar_r2"]
	var rango_3: Especie = especies["tasajero"]
	assert_int(sellado.costo(rango_1, _maestro(2))).is_equal(3)
	assert_int(sellado.costo(rango_2, _maestro(2))).is_equal(5)
	assert_int(sellado.costo(rango_1, _maestro(3))).is_equal(2)
	assert_int(sellado.costo(rango_2, _maestro(3))).is_equal(4)
	assert_int(sellado.costo(rango_1, _maestro(5))).is_equal(1)
	assert_int(sellado.costo(rango_2, _maestro(5))).is_equal(3)
	assert_int(sellado.costo(rango_3, _maestro(5))).is_equal(5)


# (2) Con costos chicos (1 / 2 / 3) y balanza 5 (descuento 2), el minimo de 2.3: 1.
func test_costo_minimo() -> void:
	var sellado: Sellado = DatosFixture.sellado("costos_mana_chico.json")
	var especies: Dictionary = MesaSellar.especies()
	assert_int(sellado.costo(especies["ocarra"], _maestro(5))).is_equal(1)
	assert_int(sellado.costo(especies["especie_sellar_r2"], _maestro(5))).is_equal(1)
	assert_int(sellado.costo(especies["tasajero"], _maestro(5))).is_equal(1)


# (2) Sistema.md 4.2, fila Combate: 2, 1 (balanza 3-4) y 0 (balanza 5).
func test_lealtad_inicial_2_1_y_0() -> void:
	var sellado: Sellado = DatosFixture.sellado()
	assert_int(sellado.lealtad_inicial(_maestro(2))).is_equal(2)
	assert_int(sellado.lealtad_inicial(_maestro(3))).is_equal(1)
	assert_int(sellado.lealtad_inicial(_maestro(4))).is_equal(1)
	assert_int(sellado.lealtad_inicial(_maestro(5))).is_equal(0)


# Sistema.md 4.1: rango maximo sellable de la balanza (1 con balanza 1, 2 con 2) y
# el alcance de combate.json.
func test_rango_permitido_y_alcance() -> void:
	var sellado: Sellado = DatosFixture.sellado()
	var especies: Dictionary = MesaSellar.especies()
	assert_bool(sellado.rango_permitido(especies["especie_sellar_r2"], _maestro(2))).is_true()
	assert_bool(sellado.rango_permitido(especies["especie_sellar_r2"], _maestro(1))).is_false()
	assert_bool(sellado.rango_permitido(especies["tasajero"], _maestro(2))).is_false()
	assert_int(sellado.alcance()).is_equal(2)


# D-008: sin tablas/sellado.json el contexto no se arma, con el nombre de la regla.
func test_contexto_sin_sellado_se_rechaza() -> void:
	var datos: Dictionary = DatosFixture.cargar()["datos"]
	var escenario: Dictionary = LectorFixture.leer("res://pruebas/fixtures/combate/escenario_hechizos.json",
			"escenario")["datos"]
	assert_object(ContextoCombate.armar(escenario, datos).sellado).is_not_null()
	datos.erase("tablas/sellado.json")
	var contextos: Array[ContextoCombate] = []
	await assert_error(func() -> void: contextos.append(ContextoCombate.armar(escenario, datos))) \
			.is_push_error("ReglasCombate: falta la regla sellado")
	assert_int(contextos[0].motivo).is_equal(ContextoCombate.Motivo.REGLA_FALTANTE)
	assert_str(contextos[0].regla_faltante).is_equal("sellado")
