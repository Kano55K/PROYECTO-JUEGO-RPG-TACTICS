extends GdUnitTestSuite

# Arquitectura.md B.3 (T19, punto 10): la acobardada, con fixtures (A.6).
# Sistema.md 10.1 (no Secunda), 10.6 (Acobardada) y 11.4 paso 1. Lectura
# declarada S-36: no termina el movimiento mas cerca de ninguna rival del chequeo
# que donde empezo el turno, y puede atacar a otra o a la rival. Para fijar la
# cobardia, combate_rival_100.json con tramo neutral y balanza 5. La Rodauva
# empieza en [3,3]; las demas quedan estacionadas (escenario_rival.json).
const _CARPETA: String = "res://pruebas/fixtures/combate/"
const _CARPETA_UNIDADES: String = "res://pruebas/fixtures/unidades/"
const _ESPECIES: Array[String] = ["ocarra", "rodauva", "surcon", "tasajero", "zancajunco"]
const _BASE_100: String = "combate_rival_100.json"

var _tablero: Tablero


func before_test() -> void:
	var tabla_combate: Dictionary = _leer(_CARPETA + "combate.json", "combate")
	_tablero = Tablero.desde_datos({"ancho": 12, "alto": 12}, tabla_combate)


func _leer(ruta: String, nombre_esquema: String) -> Dictionary:
	var lectura: Dictionary = LectorFixture.leer(ruta, nombre_esquema)
	var errores: Array[Dictionary] = lectura["errores"]
	assert_array(errores).override_failure_message(str(errores)).is_empty()
	return lectura["datos"]


func _plantel(ubicar: Dictionary) -> Plantel:
	var especies: Dictionary = {}
	for id_especie in _ESPECIES:
		especies[id_especie] = Especie.new(_leer(_CARPETA_UNIDADES + id_especie + ".json", "especie"))
	var tabla: TablaBalanza = TablaBalanza.new(_leer(_CARPETA_UNIDADES + "balanza_1_2.json", "balanza"))
	var plantel: Plantel = Plantel.desde_escenario(_leer(_CARPETA + "escenario_rival.json", "escenario"), especies,
			tabla, _leer(_CARPETA_UNIDADES + "maestro.json", "maestro"))
	for id_unidad in ubicar.keys():
		plantel.criatura(id_unidad).posicion = ubicar[id_unidad]
	return plantel


# La Rodauva acobardada: el Tasajero (su rival) a su alcance y la cobardia en 100.
func _turno(plantel: Plantel) -> Turno:
	var turno: Turno = Turno.empezar(EntradaCola.new("rodauva_1", "", 0), plantel, _tablero, Surcos.new(),
			DatosFixture.cadena(), ColaIniciativa.new(),
			DatosFixture.reglas({"incidente": DatosFixture.incidente(_BASE_100),
				"chequeo_rival": DatosFixture.chequeo_rival(_BASE_100)}), GeneradorAzar.new(1))
	assert_bool(turno.acobardada).is_true()
	assert_dict(turno.chequeo_rival).contains_key_value("tipo", "cobardia").contains_key_value("resultado", "acobardada")
	return turno


func _cobardia(desglose: DesgloseDanio) -> ModificadorDanio:
	for modificador in desglose.modificadores:
		if modificador.fuente == ModificadorDanio.Fuente.COBARDIA:
			return modificador
	return null


# Sistema.md 10.6: -50 % como porcentaje del paso 1 (11.4) en todos sus ataques:
# la Rodauva (2) pega 1 a otra objetivo. No Secunda (10.1).
func test_pega_la_mitad_y_no_secunda() -> void:
	var plantel: Plantel = _plantel({"rodauva_1": Vector2i(3, 3), "tasajero_s1": Vector2i(3, 6),
			"surcon_s1": Vector2i(2, 3)})
	var turno: Turno = _turno(plantel)
	assert_str(ResultadoAccion.Motivo.keys()[turno.validar(Accion.secundar("rodauva_2")).motivo]).is_equal("ACOBARDADA")
	assert_bool(turno.puede_secundar()).is_false()
	var golpe: ResultadoAccion = turno.aplicar(Accion.atacar("surcon_s1"))
	assert_bool(golpe.valida).is_true()
	assert_int(golpe.danio).is_equal(1)
	var cobardia: ModificadorDanio = _cobardia(golpe.desglose)
	assert_int(cobardia.valor).is_equal(-50)
	assert_int(cobardia.tipo).is_equal(ModificadorDanio.Tipo.PORCENTAJE)


# S-36: no termina mas cerca de su rival que donde empezo; puede alejarse, moverse
# a la misma distancia o quedarse (terminar sin moverse).
func test_no_se_acerca_a_la_rival() -> void:
	var plantel: Plantel = _plantel({"rodauva_1": Vector2i(3, 3), "tasajero_s1": Vector2i(3, 6)})
	var turno: Turno = _turno(plantel)
	assert_str(ResultadoAccion.Motivo.keys()[turno.validar(Accion.mover(Vector2i(3, 4))).motivo]) \
			.is_equal("MAS_CERCA_DE_RIVAL")
	var casillas: Array[Vector2i] = turno.casillas_para_mover()
	assert_bool(casillas.has(Vector2i(3, 4))).is_false()
	assert_bool(casillas.has(Vector2i(3, 5))).is_false()
	assert_bool(casillas.has(Vector2i(3, 1))).is_true()
	# [2,4] queda a 3 del Tasajero, como [3,3]: no esta mas cerca.
	assert_bool(casillas.has(Vector2i(2, 4))).is_true()
	assert_bool(turno.puede_terminar()).is_true()
	assert_bool(turno.aplicar(Accion.mover(Vector2i(3, 1))).valida).is_true()
	assert_bool(turno.aplicar(Accion.terminar()).valida).is_true()


# S-36: puede atacar a su rival, con el -50 %: al Tasajero en Caza (+25 % recibido),
# 2 x (1 - 0,50 + 0,25) = 1,5 -> 1.
func test_puede_atacar_a_su_rival() -> void:
	var plantel: Plantel = _plantel({"rodauva_1": Vector2i(3, 3), "tasajero_s1": Vector2i(3, 4)})
	var turno: Turno = _turno(plantel)
	var golpe: ResultadoAccion = turno.aplicar(Accion.atacar("tasajero_s1"))
	assert_bool(golpe.valida).is_true()
	assert_int(golpe.danio).is_equal(1)
	assert_object(_cobardia(golpe.desglose)).is_not_null()
