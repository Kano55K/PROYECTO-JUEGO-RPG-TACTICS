extends GdUnitTestSuite

# Arquitectura.md B.2 (T13, sesion 2, test 7): el interprete de clic, sin nodos
# y con fixtures (A.6). Traduce una casilla en la Accion que corresponde usando
# solo las consultas del Turno (T08). escenario_turno.json: el Maestro [3,6]
# tiene a la Ocarra salvaje [3,5] adyacente y a la Rodauva aliada [2,6].
const _CARPETA: String = "res://pruebas/fixtures/combate/"
const _CARPETA_UNIDADES: String = "res://pruebas/fixtures/unidades/"
const _ESPECIES: Array[String] = ["ocarra", "rodauva", "surcon", "tasajero", "zancajunco"]

const _OCARRA_SALVAJE: Vector2i = Vector2i(3, 5)
const _RODAUVA_ALIADA: Vector2i = Vector2i(2, 6)
const _LIBRE_ALCANZABLE: Vector2i = Vector2i(2, 5)
const _LIBRE_LEJOS: Vector2i = Vector2i(7, 0)
const _LIBRE_VECINA: Vector2i = Vector2i(1, 5)

var _plantel: Plantel
var _turno: Turno


func before_test() -> void:
	var tabla_combate: Dictionary = _leer(_CARPETA + "combate.json", "combate")
	var tablero: Tablero = Tablero.desde_datos({"ancho": 8, "alto": 8}, tabla_combate)
	var danio: Danio = Danio.desde_datos(tabla_combate, _leer(_CARPETA + "hambre.json", "hambre"))
	var especies: Dictionary = {}
	for id_especie in _ESPECIES:
		especies[id_especie] = Especie.new(_leer(_CARPETA_UNIDADES + id_especie + ".json", "especie"))
	var tabla: TablaBalanza = TablaBalanza.new(_leer(_CARPETA_UNIDADES + "balanza_1_2.json", "balanza"))
	_plantel = Plantel.desde_escenario(_leer(_CARPETA + "escenario_turno.json", "escenario"), especies, tabla,
			_leer(_CARPETA_UNIDADES + "maestro.json", "maestro"))
	_turno = Turno.empezar(EntradaCola.new(Maestro.ID, "", 0), _plantel, tablero, danio, Surcos.new(),
			DatosFixture.afinidad(), DatosFixture.cadena())


func _leer(ruta: String, nombre_esquema: String) -> Dictionary:
	var lectura: Dictionary = LectorFixture.leer(ruta, nombre_esquema)
	var errores: Array[Dictionary] = lectura["errores"]
	assert_array(errores).override_failure_message(str(errores)).is_empty()
	return lectura["datos"]


func _clic(casilla: Vector2i) -> Accion:
	return InterpreteClic.accion(_turno, _plantel.instantanea(), casilla)


func test_casilla_alcanzable_da_mover() -> void:
	assert_bool(_turno.casillas_para_mover().has(_LIBRE_ALCANZABLE)).is_true()
	var accion: Accion = _clic(_LIBRE_ALCANZABLE)
	assert_object(accion).is_not_null()
	assert_int(accion.tipo).is_equal(Accion.Tipo.MOVER)
	assert_vector(accion.casilla).is_equal(_LIBRE_ALCANZABLE)


func test_objetivo_atacable_da_atacar() -> void:
	assert_array(_turno.objetivos_para_atacar()).contains(["ocarra_s1"])
	var accion: Accion = _clic(_OCARRA_SALVAJE)
	assert_object(accion).is_not_null()
	assert_int(accion.tipo).is_equal(Accion.Tipo.ATACAR)
	assert_str(accion.objetivo_id).is_equal("ocarra_s1")
	assert_str(InterpreteClic.objetivo_en(_turno, _plantel.instantanea(), _OCARRA_SALVAJE)).is_equal("ocarra_s1")


func test_aliada_no_alcanzable_y_fuera_del_tablero_dan_nada() -> void:
	assert_bool(_turno.casillas_para_mover().has(_LIBRE_LEJOS)).is_false()
	assert_object(_clic(_RODAUVA_ALIADA)).is_null()
	assert_object(_clic(_LIBRE_LEJOS)).is_null()
	assert_object(_clic(Vector2i(-1, 0))).is_null()
	assert_object(_clic(Vector2i(8, 8))).is_null()
	assert_str(InterpreteClic.objetivo_en(_turno, _plantel.instantanea(), _RODAUVA_ALIADA)).is_empty()


func test_con_el_movimiento_gastado_una_casilla_vacia_da_nada() -> void:
	assert_bool(_turno.aplicar(Accion.mover(_LIBRE_ALCANZABLE)).valida).is_true()
	assert_object(_clic(_LIBRE_VECINA)).is_null()
	# La accion sigue disponible: la Ocarra salvaje sigue siendo atacable.
	assert_int(_clic(_OCARRA_SALVAJE).tipo).is_equal(Accion.Tipo.ATACAR)


# T40 (test 3): en el modo "elegir casilla" de Cavar, una casilla donde `cavar`
# vale da la accion y cualquier otra no da nada. Sin el modo, lo de siempre.
# escenario_surco_tribu.json: el Surcon de la tribu [3,6] con sus cuatro vecinas libres.
func test_modo_cavar() -> void:
	var tabla_combate: Dictionary = _leer(_CARPETA + "combate.json", "combate")
	var tablero: Tablero = Tablero.desde_datos({"ancho": 8, "alto": 8}, tabla_combate)
	var danio: Danio = Danio.desde_datos(tabla_combate, _leer(_CARPETA + "hambre.json", "hambre"))
	var especies: Dictionary = {}
	for id_especie in _ESPECIES:
		especies[id_especie] = Especie.new(_leer(_CARPETA_UNIDADES + id_especie + ".json", "especie"))
	var tabla: TablaBalanza = TablaBalanza.new(_leer(_CARPETA_UNIDADES + "balanza_1_2.json", "balanza"))
	var plantel: Plantel = Plantel.desde_escenario(_leer(_CARPETA + "escenario_surco_tribu.json", "escenario"),
			especies, tabla, _leer(_CARPETA_UNIDADES + "maestro.json", "maestro"))
	var turno: Turno = Turno.empezar(EntradaCola.new("surcon_1", "", 0), plantel, tablero, danio, Surcos.new(),
			DatosFixture.afinidad(), DatosFixture.cadena())
	var foto: Dictionary = plantel.instantanea()

	var accion: Accion = InterpreteClic.accion(turno, foto, Vector2i(3, 5), true)
	assert_object(accion).is_not_null()
	assert_int(accion.tipo).is_equal(Accion.Tipo.CAVAR)
	assert_vector(accion.casilla).is_equal(Vector2i(3, 5))
	# Diagonal, a dos casillas o fuera del tablero: nada.
	assert_object(InterpreteClic.accion(turno, foto, Vector2i(2, 5), true)).is_null()
	assert_object(InterpreteClic.accion(turno, foto, Vector2i(3, 4), true)).is_null()
	assert_object(InterpreteClic.accion(turno, foto, Vector2i(3, 8), true)).is_null()
	# Sin el modo, la misma casilla es un movimiento.
	assert_int(InterpreteClic.accion(turno, foto, Vector2i(3, 5)).tipo).is_equal(Accion.Tipo.MOVER)
