extends GdUnitTestSuite

# Arquitectura.md B.3 (T17, criterio 9): el boton Secundar y el modo "elegir
# aliada", con fixtures (A.6) y el runner de escenas de GdUnit4. La cola que se
# ve con el mouse sobre una aliada es la del nucleo (Turno.cola_si_secunda).
# Sistema.md 10.1. En escenario_c juega primero el Zancajunco [4,6]; la Rodauva
# [2,6], el Maestro [3,6] y la Ocarra [3,7] son sus aliadas; el Tasajero [3,1], la enemiga.
const _ESCENA: String = "res://pantalla/combate/vista_combate.tscn"
const _CARPETA_COMBATE: String = "res://pruebas/fixtures/combate/"
const _TEXTOS: String = "res://pruebas/fixtures/pantalla/es_rasgos.json"
const _MARCA_ALIADA: Vector2i = Vector2i(5, 0)


func _vista(nombre: String = "escenario_c") -> GdUnitSceneRunner:
	var lectura: Dictionary = DatosFixture.cargar()
	assert_array(lectura["errores"]).is_empty()
	var datos: Dictionary = lectura["datos"]
	datos["textos/es.json"] = LectorFixture.leer(_TEXTOS, "textos")["datos"]
	var escenario: Dictionary = LectorFixture.leer(_CARPETA_COMBATE + nombre + ".json", "escenario")["datos"]
	var runner: GdUnitSceneRunner = scene_runner(auto_free(load(_ESCENA).instantiate()))
	(runner.scene() as VistaCombate).pausa_ia = 0.0
	(runner.scene() as VistaCombate).empezar(escenario, datos)
	return runner


# Los ids de las filas de la cola que se ven, en orden.
func _cola_mostrada(vista: VistaCombate) -> Array:
	var ids: Array = []
	for fila in vista.filas_cola():
		ids.append(fila.get_meta("unidad_id"))
	return ids


func _actual_mostrada(vista: VistaCombate) -> String:
	for fila in vista.filas_cola():
		if fila.get_meta("actual"):
			return fila.get_meta("unidad_id")
	return ""


# (9) El boton aparece con aliadas validas y entra en el modo; las aliadas se
# marcan; con el mouse sobre la Ocarra la cola muestra el orden resultante y
# fuera de una aliada vuelve la de ahora; un clic en una enemiga no hace nada y
# el clic en la Ocarra aplica: el Tasajero juega y le toca a la Ocarra.
func test_boton_hover_y_clic() -> void:
	var runner: GdUnitSceneRunner = _vista()
	await runner.simulate_frames(1)
	var vista: VistaCombate = runner.scene()
	assert_str(vista.combate().turno_actual().unidad_id).is_equal("zancajunco_1")
	var boton: Button = runner.find_child("Secundar")
	assert_object(boton).is_not_null()
	assert_str(boton.text).is_equal("Secundar")
	var ahora: Array = ["zancajunco_1", "tasajero_s1", "ocarra_1", "rodauva_1", Maestro.ID]
	assert_array(_cola_mostrada(vista)).is_equal(ahora)

	assert_bool(vista.pulsar_secundar()).is_true()
	assert_bool(vista.eligiendo_aliada()).is_true()
	var marcas: TileMapLayer = runner.find_child("Marcas")
	var marcadas: Array[Vector2i] = marcas.get_used_cells()
	marcadas.sort()
	assert_array(marcadas).is_equal([Vector2i(2, 6), Vector2i(3, 6), Vector2i(3, 7)])
	assert_vector(marcas.get_cell_atlas_coords(Vector2i(3, 7))).is_equal(_MARCA_ALIADA)

	vista.sobre_casilla(Vector2i(3, 7))
	assert_array(_cola_mostrada(vista)).is_equal(["tasajero_s1", "ocarra_1", "zancajunco_1", "rodauva_1", Maestro.ID])
	assert_str(_actual_mostrada(vista)).is_equal("zancajunco_1")
	vista.sobre_casilla(Vector2i(0, 0))
	assert_array(_cola_mostrada(vista)).is_equal(ahora)
	vista.sobre_casilla(Vector2i(3, 6))
	assert_array(_cola_mostrada(vista)).is_equal(["tasajero_s1", "ocarra_1", "rodauva_1", Maestro.ID, "zancajunco_1"])
	# El hover no cambia la cola del combate.
	var cola: Array = []
	for entrada in vista.combate().cola():
		cola.append(entrada.unidad_id)
	assert_array(cola).is_equal(ahora)

	assert_bool(vista.clic_casilla(Vector2i(3, 1))).is_false()
	assert_bool(vista.clic_casilla(Vector2i(3, 7))).is_true()
	assert_bool(vista.eligiendo_aliada()).is_false()
	assert_str(vista.combate().turno_actual().unidad_id).is_equal("ocarra_1")
	assert_array(_cola_mostrada(vista)).is_equal(["tasajero_s1", "ocarra_1", "zancajunco_1", "rodauva_1", Maestro.ID])
	assert_str((runner.find_child("Sucesos") as Label).text).contains("Zancajunco · Secundar · Ocarra")


# (9) Despues de moverse ya no hay aliadas validas (S-29): el boton no aparece y
# pulsarlo no hace nada. Volver a pulsarlo sale del modo, y Cavar y Secundar no
# quedan puestos a la vez.
func test_sin_aliadas_no_hay_boton() -> void:
	var runner: GdUnitSceneRunner = _vista()
	await runner.simulate_frames(1)
	var vista: VistaCombate = runner.scene()
	assert_bool(vista.pulsar_secundar()).is_true()
	assert_bool(vista.pulsar_secundar()).is_true()
	assert_bool(vista.eligiendo_aliada()).is_false()

	assert_bool(vista.clic_casilla(Vector2i(4, 5))).is_true()
	assert_str(vista.combate().turno_actual().unidad_id).is_equal("zancajunco_1")
	assert_object(runner.find_child("Secundar")).is_null()
	assert_bool(vista.pulsar_secundar()).is_false()
	assert_bool(vista.eligiendo_aliada()).is_false()
