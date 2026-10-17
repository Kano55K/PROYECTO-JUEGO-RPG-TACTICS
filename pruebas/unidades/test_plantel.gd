extends GdUnitTestSuite

# Arquitectura.md B.2 (T05, criterios 2, 3b, 4, 5 y 8): el Plantel creado desde
# un escenario, con fixtures (A.6). Sistema.md 3.2 y 9.2.
const _CARPETA: String = "res://pruebas/fixtures/unidades/"
const _ESPECIES: Array[String] = ["ocarra", "rodauva", "surcon", "tasajero", "zancajunco"]


func _leer(archivo: String, nombre_esquema: String) -> Dictionary:
	var lectura: Dictionary = LectorFixture.leer(_CARPETA + archivo, nombre_esquema)
	var errores: Array[Dictionary] = lectura["errores"]
	assert_array(errores).override_failure_message(str(errores)).is_empty()
	return lectura["datos"]


func _crear(archivo_escenario: String) -> Plantel:
	return _crear_desde(_leer(archivo_escenario, "escenario"))


func _crear_desde(escenario: Dictionary) -> Plantel:
	var especies: Dictionary = {}
	for id_especie in _ESPECIES:
		especies[id_especie] = Especie.new(_leer(id_especie + ".json", "especie"))
	var tabla: TablaBalanza = TablaBalanza.new(_leer("balanza_1_2.json", "balanza"))
	return Plantel.desde_escenario(escenario, especies, tabla, _leer("maestro.json", "maestro"))


# La fila de la balanza del fixture, leida del archivo (no del codigo).
func _fila_balanza(posicion: int) -> Dictionary:
	for fila in (_leer("balanza_1_2.json", "balanza")["posiciones"] as Array):
		if fila["posicion"] == posicion:
			return fila
	return {}


# Criterio 2. Las dos son salvajes: sin pergamino (Sistema.md 3.2, P-010).
func test_ocarras_de_b_independientes() -> void:
	var plantel: Plantel = _crear("escenario_b.json")
	var ocarra_1: Criatura = plantel.criatura("ocarra_s1")
	var ocarra_2: Criatura = plantel.criatura("ocarra_s2")
	assert_object(ocarra_1).is_not_same(ocarra_2)
	assert_object(ocarra_1.especie).is_same(ocarra_2.especie)

	var vida_2: int = ocarra_2.vida
	ocarra_1.vida -= 1
	assert_int(ocarra_2.vida).is_equal(vida_2)
	assert_int(ocarra_1.vida).is_equal(vida_2 - 1)

	assert_str(ocarra_1.pergamino_id).is_empty()
	assert_str(ocarra_2.pergamino_id).is_empty()


# Criterio 8 (P-010): las dos Rodauvas de la tribu de E tienen lealtad propia
# y pergaminos distintos (C-02).
func test_rodauvas_de_e_independientes() -> void:
	var plantel: Plantel = _crear("escenario_e.json")
	var leal: Criatura = plantel.criatura("rodauva_1")
	var neutral: Criatura = plantel.criatura("rodauva_2")
	assert_object(leal).is_not_same(neutral)
	assert_int(leal.lealtad).is_equal(8)
	assert_int(neutral.lealtad).is_equal(5)

	leal.lealtad -= 1
	assert_int(neutral.lealtad).is_equal(5)

	assert_str(leal.pergamino_id).is_not_empty()
	assert_str(neutral.pergamino_id).is_not_empty()
	assert_str(leal.pergamino_id).is_not_equal(neutral.pergamino_id)
	assert_str(plantel.pergamino(leal.pergamino_id).ocupante_id).is_equal("rodauva_1")
	assert_str(plantel.pergamino(neutral.pergamino_id).ocupante_id).is_equal("rodauva_2")


# Criterio 3b: null toma el valor por defecto; un valor explicito se respeta.
func test_null_toma_el_valor_por_defecto() -> void:
	var plantel: Plantel = _crear("escenario_nulos.json")
	var ficha_maestro: Dictionary = _leer("maestro.json", "maestro")
	# Sistema.md 1.2, fila de la balanza 2 del fixture.
	assert_int(plantel.maestro.vida).is_equal(20)
	assert_int(plantel.maestro.hambre).is_equal((ficha_maestro["iniciales"] as Dictionary)["hambre"] as int)
	assert_int(plantel.maestro.enfermedades).is_equal(0)
	# Reescrito por Sistema.md 2.1 y 1.2 (T21, M-04): null ya no queda null; es la
	# reserva de la fila de la balanza.
	assert_int(plantel.maestro.mana_entrada).is_equal(_fila_balanza(2)["reserva_mana"] as int)

	var rodauva: Criatura = plantel.criatura("rodauva_1")
	assert_int(rodauva.vida).is_equal(rodauva.especie.vida())
	assert_int(rodauva.enfermedades).is_equal(0)
	assert_int(plantel.criatura("ocarra_s1").vida).is_equal(5)


# T07: la Velocidad del Maestro sale de maestro.json, sin depender de la balanza
# (Sistema.md 11.2).
func test_velocidad_del_maestro_de_maestro_json() -> void:
	var plantel: Plantel = _crear("escenario_a.json")
	var ficha_maestro: Dictionary = _leer("maestro.json", "maestro")
	assert_int(plantel.maestro.velocidad).is_equal(ficha_maestro["velocidad"] as int)
	assert_int(plantel.maestro.velocidad).is_equal(5)


# Criterio 4: en G ocupan pergamino la tribu y la atacante; queda 1 en blanco.
# Ids en orden: tribu, atacantes, en blanco.
func test_pergaminos_de_g() -> void:
	var plantel: Plantel = _crear("escenario_g.json")
	var esperados: Dictionary = {
		"rodauva_1": "pergamino_1",
		"zancajunco_1": "pergamino_2",
		"ocarra_1": "pergamino_3",
	}
	for id_criatura in esperados.keys():
		var criatura: Criatura = plantel.criatura(id_criatura)
		assert_str(criatura.pergamino_id).is_equal(esperados[id_criatura] as String)
		var pergamino: Pergamino = plantel.pergamino(criatura.pergamino_id)
		assert_int(pergamino.estado).is_equal(Pergamino.Estado.OCUPADO)
		assert_str(pergamino.ocupante_id).is_equal(id_criatura as String)

	var en_blanco: Pergamino = plantel.pergamino("pergamino_4")
	assert_int(en_blanco.estado).is_equal(Pergamino.Estado.EN_BLANCO)
	assert_str(en_blanco.ocupante_id).is_empty()
	assert_int(plantel.pergaminos().size()).is_equal(4)

	var atacante: Criatura = plantel.criatura("ocarra_1")
	assert_int(atacante.bando).is_equal(Criatura.Bando.ENEMIGA)
	assert_int(atacante.comportamiento).is_equal(Criatura.Comportamiento.ATACANTE_NOCTURNA)


# Criterio 4: en A la Ocarra salvaje no tiene pergamino.
func test_salvaje_de_a_sin_pergamino() -> void:
	var plantel: Plantel = _crear("escenario_a.json")
	var salvaje: Criatura = plantel.criatura("ocarra_s1")
	assert_int(salvaje.comportamiento).is_equal(Criatura.Comportamiento.SALVAJE)
	assert_str(salvaje.pergamino_id).is_empty()
	for pergamino in plantel.pergaminos():
		assert_str(pergamino.ocupante_id).is_not_equal("ocarra_s1")
	# La Rodauva ocupa uno y quedan los 2 en blanco del escenario.
	assert_int(plantel.pergaminos().size()).is_equal(3)


# Criterio 5: dos creaciones del mismo escenario dan los mismos ids de pergamino.
func test_misma_creacion_mismos_ids() -> void:
	var primero: Plantel = _crear("escenario_g.json")
	var segundo: Plantel = _crear("escenario_g.json")
	assert_array(_ids_pergaminos(segundo)).is_equal(_ids_pergaminos(primero))
	assert_array(_pares(segundo)).is_equal(_pares(primero))


func _ids_pergaminos(plantel: Plantel) -> Array[String]:
	var ids: Array[String] = []
	for pergamino in plantel.pergaminos():
		ids.append(pergamino.id)
	return ids


func _pares(plantel: Plantel) -> Array[String]:
	var pares: Array[String] = []
	for criatura in plantel.criaturas():
		pares.append("%s:%s" % [criatura.id, criatura.pergamino_id])
	return pares


# T21 (1), Sistema.md 1.2 y 2.1 (M-04): mana_entrada null es la reserva de la
# fila de su balanza (dos balanzas del fixture); un valor explicito se respeta.
# El mana actual arranca en mana_entrada.
func test_t21_mana_entrada_se_resuelve() -> void:
	for balanza in [2, 4]:
		var escenario: Dictionary = _leer("escenario_nulos.json", "escenario")
		(escenario["maestro"] as Dictionary)["balanza"] = balanza
		var maestro: Maestro = _crear_desde(escenario).maestro
		assert_int(maestro.mana_entrada).is_equal(_fila_balanza(balanza)["reserva_mana"] as int)
		assert_int(maestro.mana).is_equal(maestro.mana_entrada)
	assert_int(_fila_balanza(2)["reserva_mana"] as int).is_not_equal(_fila_balanza(4)["reserva_mana"] as int)

	var explicito: Dictionary = _leer("escenario_nulos.json", "escenario")
	(explicito["maestro"] as Dictionary)["mana_entrada"] = 4
	var con_entrada: Maestro = _crear_desde(explicito).maestro
	assert_int(con_entrada.mana_entrada).is_equal(4)
	assert_int(con_entrada.mana).is_equal(4)