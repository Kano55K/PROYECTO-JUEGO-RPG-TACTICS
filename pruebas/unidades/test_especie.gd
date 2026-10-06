extends GdUnitTestSuite

# Arquitectura.md B.2.1 (T35): la ficha responde los valores del modo actual
# (Caza y cuenta) y la criatura arranca en el modo inicial. Reescribe el test de
# T05 (criterio 7, "dos turnos 8 y 3"): Sistema.md 11.2.3 v1.3, un turno por
# ronda en dos modos.
const _FIXTURE_TASAJERO: String = "res://pruebas/fixtures/unidades/tasajero.json"
const _FIXTURE_RODAUVA: String = "res://pruebas/fixtures/unidades/rodauva.json"


func _especie(ruta: String) -> Especie:
	var lectura: Dictionary = LectorFixture.leer(ruta, "especie")
	var errores: Array[Dictionary] = lectura["errores"]
	assert_array(errores).override_failure_message(str(errores)).is_empty()
	return Especie.new(lectura["datos"])


# Sistema.md 11.2.3: Caza (Vel 8, 2 ataques, sin partir, +25%, plano 0) y
# Cuenta (Vel 3, 1 ataque, partido, 0%, -1). Empieza en Caza.
func test_tasajero_responde_por_modo() -> void:
	var tasajero: Especie = _especie(_FIXTURE_TASAJERO)
	assert_str(tasajero.modo_inicial()).is_equal("caza")

	assert_int(tasajero.velocidad("caza")).is_equal(8)
	assert_int(tasajero.ataques_por_turno("caza")).is_equal(2)
	assert_bool(tasajero.movimiento_partido("caza")).is_false()
	assert_int(tasajero.recibido_pct("caza")).is_equal(25)
	assert_int(tasajero.danio_plano("caza")).is_equal(0)

	assert_int(tasajero.velocidad("cuenta")).is_equal(3)
	assert_int(tasajero.ataques_por_turno("cuenta")).is_equal(1)
	assert_bool(tasajero.movimiento_partido("cuenta")).is_true()
	assert_int(tasajero.recibido_pct("cuenta")).is_equal(0)
	assert_int(tasajero.danio_plano("cuenta")).is_equal(-1)


# Sin modos: la Velocidad de la ficha y los valores neutros.
func test_sin_modos_responde_la_ficha_y_valores_neutros() -> void:
	var rodauva: Especie = _especie(_FIXTURE_RODAUVA)
	assert_str(rodauva.modo_inicial()).is_empty()
	assert_int(rodauva.velocidad("")).is_equal(6)
	assert_int(rodauva.ataques_por_turno("")).is_equal(1)
	assert_bool(rodauva.movimiento_partido("")).is_false()
	assert_int(rodauva.recibido_pct("")).is_equal(0)
	assert_int(rodauva.danio_plano("")).is_equal(0)


# La criatura arranca en el modo inicial de su especie; sin modos, "".
func test_criatura_arranca_en_el_modo_inicial() -> void:
	var tasajero: Criatura = Criatura.new("tasajero_s1", _especie(_FIXTURE_TASAJERO), Criatura.Bando.ENEMIGA)
	assert_str(tasajero.modo).is_equal("caza")
	var rodauva: Criatura = Criatura.new("rodauva_1", _especie(_FIXTURE_RODAUVA), Criatura.Bando.TRIBU)
	assert_str(rodauva.modo).is_empty()
