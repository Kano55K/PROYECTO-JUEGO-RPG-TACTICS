extends GdUnitTestSuite

# Arquitectura.md B.3 (T18): la vista muestra el riesgo de incidente con lo que
# le da el nucleo (Combate.incidente_en) y el suceso del evento `incidente`.
# Fixtures (A.6): escenario_incidente_combate.json con el combate.json de prueba
# (base 20) y la balanza 5 (Arrimo 0): 20 %. Textos de es_rasgos.json con las
# claves del incidente agregadas por el test.
const _ESCENA: String = "res://pantalla/combate/vista_combate.tscn"
const _ESCENARIO: String = "res://pruebas/fixtures/combate/escenario_incidente_combate.json"
const _TEXTOS: String = "res://pruebas/fixtures/pantalla/es_rasgos.json"
const _TEXTOS_INCIDENTE: Dictionary = {
	"incidente.tooltip": "{porcentaje}% de incidente.",
	"incidente.distraida": "{criatura} mira {a_rival}.",
	"incidente.ataque": "{criatura} le pega {a_rival}.",
	"incidente.ataque.ocarra.zancajunco": "Picotazo al Zancajunco.",
}


func _datos() -> Dictionary:
	var lectura: Dictionary = DatosFixture.cargar()
	assert_array(lectura["errores"]).is_empty()
	var datos: Dictionary = lectura["datos"]
	var textos: Dictionary = LectorFixture.leer(_TEXTOS, "textos")["datos"]
	textos.merge(_TEXTOS_INCIDENTE, true)
	datos["textos/es.json"] = textos
	return datos


func _vista() -> GdUnitSceneRunner:
	var escenario: Dictionary = LectorFixture.leer(_ESCENARIO, "escenario")["datos"]
	var runner: GdUnitSceneRunner = scene_runner(auto_free(load(_ESCENA).instantiate()))
	(runner.scene() as VistaCombate).pausa_ia = 0.0
	(runner.scene() as VistaCombate).empezar(escenario, _datos())
	return runner


# (18) Sistema.md 10.4 ("la probabilidad se muestra en la casilla antes de
# mover") y 15 v1.6: el Zancajunco [3,2] juega primero. Con el mouse sobre [5,4]
# (alcanzable), la Ocarra de la tribu [5,5] queda vecina: se marca y el aviso
# dice el 20 %. Sobre la casilla propia, sin rivales vecinas, nada.
func test_aviso_y_marca_de_incidente() -> void:
	var runner: GdUnitSceneRunner = _vista()
	await runner.simulate_frames(1)
	var vista: VistaCombate = runner.scene()
	var turno: Turno = vista.combate().turno_actual()
	assert_str(turno.unidad_id).is_equal("zancajunco_1")
	assert_array(turno.casillas_para_mover()).contains([Vector2i(5, 4)])

	vista.sobre_casilla(Vector2i(5, 4))
	assert_array(vista.casillas_rivales()).is_equal([Vector2i(5, 5)])
	assert_str(vista.aviso_mostrado()).is_equal("20% de incidente.")
	assert_bool(runner.find_child("Aviso").visible).is_true()
	var rivales: TileMapLayer = runner.find_child("Rivales")
	assert_vector(rivales.get_cell_atlas_coords(Vector2i(5, 5))).is_equal(Vector2i(8, 0))

	vista.sobre_casilla(Vector2i(3, 2))
	assert_array(vista.casillas_rivales()).is_empty()
	assert_str(vista.aviso_mostrado()).is_empty()
	assert_bool(runner.find_child("Aviso").visible).is_false()


# (19) A.7 y Mundo.md 9.2: el evento `incidente` da su linea de sucesos. Si se
# distrajo, con la primera de sus rivales; si golpeo, con la objetivo. La
# variante del par de especies reemplaza a la base.
func test_suceso_del_incidente() -> void:
	var datos: Dictionary = _datos()
	var contexto: ContextoCombate = ContextoCombate.armar(LectorFixture.leer(_ESCENARIO, "escenario")["datos"], datos)
	var combate: Combate = Combate.empezar(contexto)
	assert_str(combate.error()).is_empty()
	var lectura: LecturaCombate = LecturaCombate.new(combate,
			ArmadorTextos.desde_datos(datos["textos/es.json"], contexto.azar_textos),
			EstadosUnidad.desde_datos(datos["tablas/hambre.json"], datos["tablas/lealtad.json"]))
	assert_array(lectura.suceso({"tipo": "incidente", "unidad": "ocarra_2", "rivales": ["ocarra_1"],
			"porcentaje": 20, "resultado": "distraida", "objetivo": null})) \
			.is_equal(["La Ocarra mira a la Ocarra."])
	assert_array(lectura.suceso({"tipo": "incidente", "unidad": "ocarra_1", "rivales": ["ocarra_2"],
			"porcentaje": 20, "resultado": "golpe", "objetivo": "ocarra_2"})) \
			.is_equal(["La Ocarra le pega a la Ocarra."])
	assert_array(lectura.suceso({"tipo": "incidente", "unidad": "ocarra_1", "rivales": ["ocarra_2", "zancajunco_1"],
			"porcentaje": 20, "resultado": "golpe", "objetivo": "zancajunco_1"})) \
			.is_equal(["Picotazo al Zancajunco."])
