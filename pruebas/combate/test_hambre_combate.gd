extends GdUnitTestSuite

# Arquitectura.md B.3 (T14), tests 4 a 8: Sistema.md 7.2 (hambre de combate al
# cerrar las rondas 5, 10...), 5.4 y 7.1 (la obediencia y Saciado se leen del
# hambre nueva en el acto) y A.7 (evento hambre_combate, instantanea y
# resultado). Fixtures (A.6): escenario_hambre_combate.json.
const _ESCENARIO: String = "res://pruebas/fixtures/combate/escenario_hambre_combate.json"
const _CARPETA_DATOS: String = "res://datos"


func _datos() -> Dictionary:
	var lectura: Dictionary = DatosFixture.cargar()
	var errores: Array[Dictionary] = lectura["errores"]
	assert_array(errores).override_failure_message(str(errores)).is_empty()
	return lectura["datos"]


func _escenario(sin_atacante: bool = false) -> Dictionary:
	var lectura: Dictionary = LectorFixture.leer(_ESCENARIO, "escenario")
	var errores: Array[Dictionary] = lectura["errores"]
	assert_array(errores).override_failure_message(str(errores)).is_empty()
	var escenario: Dictionary = lectura["datos"]
	if sin_atacante:
		var enemigas: Array = escenario["enemigas"]
		enemigas.pop_back()
	return escenario


func _combate(escenario: Dictionary) -> Combate:
	var contexto: ContextoCombate = ContextoCombate.armar(escenario, _datos())
	assert_bool(contexto.valido).is_true()
	var combate: Combate = Combate.empezar(contexto)
	assert_str(combate.error()).is_empty()
	return combate


func _aplicar_valida(combate: Combate, accion: Accion) -> void:
	var resultado: ResultadoAccion = combate.aplicar(accion)
	assert_bool(resultado.valida).override_failure_message(
			ResultadoAccion.Motivo.keys()[resultado.motivo] + " " + str(accion.a_diccionario())).is_true()
	assert_str(combate.error()).is_empty()


# Solo `terminar` hasta que empiece la ronda pedida.
func _terminar_hasta_ronda(combate: Combate, ronda: int) -> void:
	while combate.instantanea()["ronda"] < ronda:
		_aplicar_valida(combate, Accion.terminar())


func _terminar_hasta_el_maestro(combate: Combate) -> void:
	while combate.turno_actual().unidad_id != Maestro.ID:
		_aplicar_valida(combate, Accion.terminar())


# id -> hambre, el Maestro primero y despues en el orden del Plantel.
func _hambres(combate: Combate) -> Dictionary:
	var plantel: Plantel = combate.contexto().plantel
	var hambres: Dictionary = {Maestro.ID: plantel.maestro.hambre}
	for criatura in plantel.criaturas():
		hambres[criatura.id] = criatura.hambre
	return hambres


func _de_tipo(combate: Combate, tipo: String) -> Array[Dictionary]:
	var lineas: Array[Dictionary] = []
	for linea in combate.registro().lineas():
		if linea["tipo"] == tipo:
			lineas.append(linea)
	return lineas


# En la ronda actual, la Ocarra salvaje aparece junto al Maestro con 1 de vida y
# el Maestro la tumba: la ultima enemiga, victoria a mitad de ronda.
func _ganar_en_la_ronda_actual(combate: Combate) -> void:
	_terminar_hasta_el_maestro(combate)
	var salvaje: Criatura = combate.contexto().plantel.criatura("ocarra_s1")
	salvaje.posicion = Vector2i(1, 1)
	salvaje.vida = 1
	_aplicar_valida(combate, Accion.atacar("ocarra_s1"))
	assert_bool(combate.terminado()).is_true()
	assert_int(combate.fin()).is_equal(FinCombate.Fin.VICTORIA)


# (4) Jugado solo con `terminar`: nada al cerrar la 4; +1 al cerrar la 5 al
# Maestro, a la suelta y a la caida; la guardada, la salvaje y la atacante no
# cambian; otra vez al cerrar la 10; la de hambre 10 queda en 10 y no aparece.
func test_hambre_de_combate_en_rondas_5_y_10() -> void:
	var combate: Combate = _combate(_escenario())
	var inicial: Dictionary = _hambres(combate)
	assert_int(combate.contexto().plantel.criatura("surcon_1").estado).is_equal(Criatura.Estado.CAIDA)

	_terminar_hasta_ronda(combate, 5)
	assert_dict(_hambres(combate)).is_equal(inicial)
	assert_array(_de_tipo(combate, "hambre_combate")).is_empty()

	_terminar_hasta_ronda(combate, 6)
	assert_dict(_hambres(combate)).is_equal({Maestro.ID: 4, "rodauva_1": 6, "ocarra_1": 3, "surcon_1": 4,
			"rodauva_2": 10, "zancajunco_1": 3, "ocarra_s1": 0, "ocarra_a1": 9})
	var eventos: Array[Dictionary] = _de_tipo(combate, "hambre_combate")
	assert_int(eventos.size()).is_equal(1)
	assert_array(eventos[0]["cambios"]).is_equal([
		{"unidad": Maestro.ID, "de": 3, "a": 4},
		{"unidad": "rodauva_1", "de": 5, "a": 6},
		{"unidad": "ocarra_1", "de": 2, "a": 3},
		{"unidad": "surcon_1", "de": 3, "a": 4},
	])

	_terminar_hasta_ronda(combate, 11)
	assert_dict(_hambres(combate)).is_equal({Maestro.ID: 5, "rodauva_1": 7, "ocarra_1": 4, "surcon_1": 5,
			"rodauva_2": 10, "zancajunco_1": 3, "ocarra_s1": 0, "ocarra_a1": 9})
	eventos = _de_tipo(combate, "hambre_combate")
	assert_int(eventos.size()).is_equal(2)
	assert_int(eventos[1]["ronda"] as int).is_equal(10)
	# Nadie llego a pelear: el hambre no depende de los ataques.
	assert_array(_de_tipo(combate, "ataque")).is_empty()


# (5) En el acto (7.2): la Rodauva con lealtad 7 y hambre 5 es leal durante la
# ronda 5 y neutral en la 6; la Ocarra con hambre 2 pega 5 (Saciada) en la 5 y
# 4 en la 6. Nada se guarda: se pregunta otra vez.
func test_recalculo_en_el_acto() -> void:
	var combate: Combate = _combate(_escenario())
	var contexto: ContextoCombate = combate.contexto()
	var plantel: Plantel = contexto.plantel
	var rodauva: Criatura = plantel.criatura("rodauva_1")

	_terminar_hasta_ronda(combate, 5)
	assert_str(contexto.obediencia.tramo(rodauva, plantel.maestro)).is_equal(Obediencia.TRAMO_LEAL)
	assert_int(contexto.danio.calcular("ocarra_1", "ocarra_s1", plantel).total).is_equal(5)

	_terminar_hasta_ronda(combate, 6)
	assert_that(contexto.obediencia.valor(rodauva)).is_equal(5)
	assert_str(contexto.obediencia.tramo(rodauva, plantel.maestro)).is_equal(Obediencia.TRAMO_NEUTRAL)
	assert_int(contexto.danio.calcular("ocarra_1", "ocarra_s1", plantel).total).is_equal(4)


# (6) Un combate que termina durante la ronda 5 no la cierra: no suma hambre.
func test_combate_que_termina_en_la_ronda_5_no_suma() -> void:
	var combate: Combate = _combate(_escenario(true))
	var inicial: Dictionary = _hambres(combate)
	_terminar_hasta_ronda(combate, 5)
	_ganar_en_la_ronda_actual(combate)
	assert_int(combate.instantanea()["ronda"] as int).is_equal(5)
	assert_array(_de_tipo(combate, "hambre_combate")).is_empty()
	var final: Dictionary = _hambres(combate)
	for id_unidad in inicial.keys():
		assert_int(final[id_unidad] as int).override_failure_message(id_unidad).is_equal(inicial[id_unidad])


# (7) Registro (A.7): hambre_combate justo despues del fin_ronda de la 5, con
# su numero; la instantanea trae el hambre nueva; la grabacion se reproduce con
# el mismo registro.
func test_registro_del_hambre_de_combate() -> void:
	var combate: Combate = _combate(_escenario())
	_terminar_hasta_ronda(combate, 6)
	var lineas: Array[Dictionary] = combate.registro().lineas()
	var indice: int = -1
	for i in range(lineas.size()):
		if lineas[i]["tipo"] == "hambre_combate":
			indice = i
	assert_int(indice).is_greater(0)
	assert_str(lineas[indice - 1]["tipo"]).is_equal("fin_ronda")
	assert_int(lineas[indice - 1]["ronda"] as int).is_equal(5)
	assert_int(lineas[indice]["ronda"] as int).is_equal(5)
	assert_str(lineas[indice + 1]["tipo"]).is_equal("ronda")

	var foto: Dictionary = combate.instantanea()
	assert_int(foto["maestro"]["hambre"] as int).is_equal(4)
	var hambres: Dictionary = {}
	for criatura in foto["criaturas"]:
		hambres[criatura["id"]] = criatura["hambre"]
	assert_dict(hambres).is_equal({"rodauva_1": 6, "ocarra_1": 3, "surcon_1": 4, "rodauva_2": 10,
			"zancajunco_1": 3, "ocarra_s1": null, "ocarra_a1": null})

	var reproduccion: Reproductor = Reproductor.reproducir(Grabacion.desde_combate(combate), _datos())
	assert_str(reproduccion.error).is_empty()
	assert_bool(reproduccion.aviso_huella).is_false()
	assert_array(reproduccion.combate.registro().lineas_json()).is_equal(combate.registro().lineas_json())
	assert_str(str(reproduccion.combate.instantanea())).is_equal(str(foto))


# (8) El resultado trae el hambre final de la tribu y null en las enemigas, y
# valida contra el esquema. Gana en la ronda 6: ya sumo el +1 de la 5.
func test_resultado_trae_el_hambre() -> void:
	var combate: Combate = _combate(_escenario(true))
	_terminar_hasta_ronda(combate, 6)
	_ganar_en_la_ronda_actual(combate)
	var resultado: Dictionary = combate.resultado().a_diccionario()
	assert_int(resultado["maestro"]["hambre"] as int).is_equal(4)
	var hambres: Dictionary = {}
	for unidad in resultado["unidades"]:
		hambres[unidad["id"]] = unidad["hambre"]
	assert_dict(hambres).is_equal({"rodauva_1": 6, "ocarra_1": 3, "surcon_1": 4, "rodauva_2": 10,
			"zancajunco_1": 3, "ocarra_s1": null})
	var esquema: Dictionary = Cargador.new().esquema_resuelto(_CARPETA_DATOS, "resultado")["esquema"]
	var errores: Array = Validador.new().validar(resultado, esquema, "resultado")["errores"]
	assert_array(errores).override_failure_message(str(errores)).is_empty()
