extends GdUnitTestSuite

# Arquitectura.md B.4 (T30, sesion 1), criterios 1, 2 y 6: el golpe inicial de la
# atacante nocturna, con fixtures (A.6). Sistema.md 9.2 punto 1 y 11.4. Lectura
# declarada S-64: sin aportes de turno (ni afinidad, ni combo, ni Encono, ni
# cobardia), en la ronda 0 y fuera de la metrica 1. Fixture
# escenario_nocturno_combate.json: la Ocarra del fixture pega 4; el Surcon salvaje
# a su lado es su afin.
const _DANIO_OCARRA: int = 4
const _FUENTES_DE_TURNO: Array[String] = ["afinidad", "combo", "encono", "cobardia"]


# (1) Primer evento detras de `inicio`, en la ronda 0, con el desglose de 11.4 sin
# aportes, aunque la afin de la atacante este al lado. Ni Encono ni cadena.
func test_golpe_inicial_es_el_primer_evento_tras_inicio() -> void:
	var escenario: Dictionary = MesaNocturno.escenario()
	var combate: Combate = MesaNocturno.combate(escenario)
	assert_str(combate.error()).is_empty()
	var lineas: Array[Dictionary] = combate.registro().lineas()
	assert_str(lineas[0]["tipo"]).is_equal("inicio")
	var golpe: Dictionary = lineas[1]
	assert_str(golpe["tipo"]).is_equal("golpe_inicial")
	assert_int(golpe["ronda"]).is_equal(0)
	assert_str(golpe["atacante"]).is_equal(MesaNocturno.ATACANTE)
	assert_str(golpe["objetivo"]).is_equal(Maestro.ID)
	var vida_inicial: int = combate.contexto().plantel.maestro.vida_max_real()
	assert_int(golpe["vida_antes"]).is_equal(vida_inicial)
	assert_int(golpe["vida_despues"]).is_equal(vida_inicial - _DANIO_OCARRA)

	# El mismo Danio que un ataque, sin aportes (11.4), calculado sobre otro Plantel.
	var otro: ContextoCombate = ContextoCombate.armar(escenario, MesaNocturno.datos())
	assert_array(otro.afinidad.afines_vecinas(MesaNocturno.ATACANTE, Vector2i(3, 4), otro.plantel)) \
			.is_not_empty()
	var esperado: DesgloseDanio = otro.danio.calcular(MesaNocturno.ATACANTE, Maestro.ID, otro.plantel, [])
	assert_dict(golpe["desglose"]).is_equal(esperado.a_diccionario())
	assert_int((golpe["desglose"] as Dictionary)["total"]).is_equal(_DANIO_OCARRA)
	for modificador: Dictionary in (golpe["desglose"] as Dictionary)["modificadores"]:
		assert_array(_FUENTES_DE_TURNO).not_contains([modificador["fuente"]])

	var foto: Dictionary = combate.instantanea()
	assert_object(foto["cadena"]).is_null()
	for unidad: Dictionary in foto["criaturas"]:
		if unidad["id"] == MesaNocturno.ATACANTE:
			assert_int(unidad["encono"]).is_equal(0)
	# Antes de la ronda 1: ni encono ni cadena_cortada.
	for linea in combate.registro().lineas():
		if linea["ronda"] == 0:
			assert_array(["encono", "cadena_cortada"]).not_contains([linea["tipo"]])


# (2) Con golpe_inicial null no hay golpe: detras de inicio va la ronda 1.
func test_sin_golpe_inicial_no_hay_golpe() -> void:
	var escenario: Dictionary = MesaNocturno.escenario()
	escenario["golpe_inicial"] = null
	var combate: Combate = MesaNocturno.combate(escenario)
	assert_str(combate.error()).is_empty()
	assert_array(MesaNocturno.lineas_de_tipo(combate, "golpe_inicial")).is_empty()
	# Despues de inicio, la ronda 1 (las enemigas despues pueden pegarle).
	assert_str(combate.registro().lineas()[1]["tipo"]).is_equal("ronda")


# (6) La metrica 1 no cuenta el golpe inicial (S-64): un combate que termina en la
# ronda 0 por el golpe no tiene primer ataque; y en un registro con golpe inicial y
# un ataque en la ronda 2, el primer ataque es el de la ronda 2.
func test_la_metrica_1_no_cuenta_el_golpe_inicial() -> void:
	var combate: Combate = MesaNocturno.combate(MesaNocturno.escenario(), {Maestro.ID: _DANIO_OCARRA})
	var rondas: Dictionary = combate.resultado().metricas["rondas"]
	assert_object(rondas["primer_ataque"]).is_null()
	assert_int(rondas["de_pelea"]).is_equal(0)

	var golpe: Dictionary = MesaNocturno.lineas_de_tipo(combate, "golpe_inicial")[0]
	var lineas: Array[Dictionary] = [{"tipo": "inicio", "ronda": 0}, golpe, {"tipo": "ronda", "ronda": 1},
			{"tipo": "fin_ronda", "ronda": 1}, {"tipo": "ronda", "ronda": 2},
			{"tipo": "ataque", "ronda": 2, "atacante": "surcon_s1", "objetivo": Maestro.ID,
				"desglose": golpe["desglose"], "eslabon": null, "vida_antes": 16, "vida_despues": 12},
			{"tipo": "fin_ronda", "ronda": 2}]
	var metricas: Dictionary = MetricasCombate.calcular(MesaNocturno.escenario(), lineas)
	assert_int((metricas["rondas"] as Dictionary)["primer_ataque"]).is_equal(2)
