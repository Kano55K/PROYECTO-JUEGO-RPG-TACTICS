extends GdUnitTestSuite

# Arquitectura.md B.3 (T15): afinidad por adyacencia, con fixtures (A.6).
# Sistema.md 10.3, 10.7, 10.8, 11.2.2, 11.4 y 11.5. Los numeros de danio son la
# comprobacion: el codigo los lee de las fichas, la balanza y combate.json de
# prueba (+1 en afinidad_danio_plano). Cada test acomoda a sus unidades en el
# centro; las demas quedan estacionadas en los bordes (escenario_afinidad.json).
const _CARPETA: String = "res://pruebas/fixtures/combate/"
const _CARPETA_UNIDADES: String = "res://pruebas/fixtures/unidades/"
const _ESPECIES: Array[String] = ["ocarra", "rodauva", "surcon", "tasajero", "zancajunco"]
const _FUENTES: Array[String] = ["res://nucleo/combate/afinidad.gd"]
const _AZAR_PROHIBIDO: Array[String] = ["GeneradorAzar", "randi", "randf", "RandomNumberGenerator"]

var _tablero: Tablero
var _danio: Danio


func before_test() -> void:
	var tabla_combate: Dictionary = _leer(_CARPETA + "combate.json", "combate")
	_tablero = Tablero.desde_datos({"ancho": 8, "alto": 8}, tabla_combate)
	_danio = Danio.desde_datos(tabla_combate, _leer(_CARPETA + "hambre.json", "hambre"))


func _leer(ruta: String, nombre_esquema: String) -> Dictionary:
	var lectura: Dictionary = LectorFixture.leer(ruta, nombre_esquema)
	var errores: Array[Dictionary] = lectura["errores"]
	assert_array(errores).override_failure_message(str(errores)).is_empty()
	return lectura["datos"]


# El plantel de escenario_afinidad.json con las posiciones de `ubicar`.
func _plantel(ubicar: Dictionary = {}) -> Plantel:
	var especies: Dictionary = {}
	for id_especie in _ESPECIES:
		especies[id_especie] = Especie.new(_leer(_CARPETA_UNIDADES + id_especie + ".json", "especie"))
	var tabla: TablaBalanza = TablaBalanza.new(_leer(_CARPETA_UNIDADES + "balanza_1_2.json", "balanza"))
	var plantel: Plantel = Plantel.desde_escenario(_leer(_CARPETA + "escenario_afinidad.json", "escenario"),
			especies, tabla, _leer(_CARPETA_UNIDADES + "maestro.json", "maestro"))
	_ubicar(plantel, ubicar)
	return plantel


func _ubicar(plantel: Plantel, ubicar: Dictionary) -> void:
	for id_unidad in ubicar.keys():
		if id_unidad == Maestro.ID:
			plantel.maestro.posicion = ubicar[id_unidad]
		else:
			plantel.criatura(id_unidad).posicion = ubicar[id_unidad]


func _turno(plantel: Plantel, unidad_id: String, afinidad: Afinidad = null) -> Turno:
	return Turno.empezar(EntradaCola.new(unidad_id, "", 0), plantel, _tablero, _danio, Surcos.new(),
			afinidad if afinidad != null else DatosFixture.afinidad(), DatosFixture.cadena())


# El danio del ataque desde donde esta, por la misma funcion que lo aplica.
func _pega(plantel: Plantel, atacante_id: String, objetivo_id: String, afinidad: Afinidad = null) -> int:
	var resultado: ResultadoAccion = _turno(plantel, atacante_id, afinidad).validar(Accion.atacar(objetivo_id))
	assert_bool(resultado.valida).override_failure_message(
			"%s -> %s: %s" % [atacante_id, objetivo_id, ResultadoAccion.Motivo.keys()[resultado.motivo]]).is_true()
	return resultado.danio


func _fuentes(desglose: DesgloseDanio) -> Array:
	var fuentes: Array = []
	for modificador in desglose.modificadores:
		fuentes.append(modificador.fuente)
	return fuentes


# (1) Sistema.md 10.3 y 10.8 (Rodauva-Rodauva, manada): la Rodauva (2) junto a
# otra pega 3; con dos afines al lado, 3 (maximo +1 por ataque); sola, 2.
func test_rodauva_junto_a_rodauva() -> void:
	var una: Plantel = _plantel({"rodauva_2": Vector2i(3, 3), "ocarra_s1": Vector2i(3, 2), "rodauva_3": Vector2i(2, 3)})
	assert_int(_pega(una, "rodauva_2", "ocarra_s1")).is_equal(3)

	var dos: Plantel = _plantel({"rodauva_2": Vector2i(3, 3), "ocarra_s1": Vector2i(3, 2), "rodauva_3": Vector2i(2, 3),
			"rodauva_1": Vector2i(4, 3)})
	var vista: ResultadoAccion = _turno(dos, "rodauva_2").validar(Accion.atacar("ocarra_s1"))
	assert_int(vista.danio).is_equal(3)
	assert_int(_fuentes(vista.desglose).count(ModificadorDanio.Fuente.AFINIDAD)).is_equal(1)

	var sola: Plantel = _plantel({"rodauva_2": Vector2i(3, 3), "ocarra_s1": Vector2i(3, 2)})
	assert_int(_pega(sola, "rodauva_2", "ocarra_s1")).is_equal(2)


# (2) Sistema.md 10.3: el Maestro (4) junto a una leal pega 5, y la leal su
# danio + 1. Junto a una neutral (lealtad 5, umbral 7), ninguno suma.
func test_maestro_y_leal() -> void:
	var leal: Plantel = _plantel({Maestro.ID: Vector2i(3, 3), "ocarra_s1": Vector2i(3, 2),
			"rodauva_1": Vector2i(2, 3), "rodauva_s1": Vector2i(2, 2)})
	assert_int(_pega(leal, Maestro.ID, "ocarra_s1")).is_equal(4 + 1)
	assert_int(_pega(leal, "rodauva_1", "rodauva_s1")).is_equal(2 + 1)

	var neutral: Plantel = _plantel({Maestro.ID: Vector2i(3, 3), "ocarra_s1": Vector2i(3, 2),
			"rodauva_2": Vector2i(2, 3), "rodauva_s1": Vector2i(2, 2)})
	assert_int(_pega(neutral, Maestro.ID, "ocarra_s1")).is_equal(4)
	assert_int(_pega(neutral, "rodauva_2", "rodauva_s1")).is_equal(2)


# (3) Sistema.md 10.3 y 7.2: la obediencia se pregunta en el acto. La leal con
# lealtad 7 y hambre 5 (umbral 7): el Maestro suma. El hambre de combate al
# cerrar la ronda 5 la sube a 6 (Hambriento, -2): obediencia 5, neutral, y el
# Maestro deja de sumar sin que nada se haya guardado.
func test_en_el_acto_por_hambre_de_combate() -> void:
	var plantel: Plantel = _plantel({Maestro.ID: Vector2i(3, 3), "ocarra_s1": Vector2i(3, 2),
			"rodauva_1": Vector2i(2, 3)})
	var rodauva: Criatura = plantel.criatura("rodauva_1")
	rodauva.lealtad = 7
	rodauva.hambre = 5
	var turno: Turno = _turno(plantel, Maestro.ID)
	assert_int(turno.validar(Accion.atacar("ocarra_s1")).danio).is_equal(4 + 1)

	var hambre_combate: HambreCombate = HambreCombate.desde_datos(_leer(_CARPETA + "hambre.json", "hambre"))
	assert_object(hambre_combate.cerrar_ronda(5, plantel)).is_not_null()
	assert_int(rodauva.hambre).is_equal(6)
	assert_int(plantel.maestro.hambre).is_equal(4)
	# El mismo turno, sin rearmar nada.
	assert_int(turno.validar(Accion.atacar("ocarra_s1")).danio).is_equal(4)


# (4) Sistema.md 10.7: la afinidad solo existe dentro del mismo bando. La Rodauva
# de la tribu junto a una Rodauva salvaje pega 2; dos Rodauvas salvajes juntas
# pegan 3 cada una.
func test_mismo_bando() -> void:
	var mezcla: Plantel = _plantel({"rodauva_2": Vector2i(3, 3), "ocarra_s1": Vector2i(3, 2),
			"rodauva_s1": Vector2i(2, 3)})
	assert_int(_pega(mezcla, "rodauva_2", "ocarra_s1")).is_equal(2)

	var salvajes: Plantel = _plantel({"rodauva_s1": Vector2i(3, 3), "rodauva_s2": Vector2i(2, 3),
			"rodauva_2": Vector2i(3, 4), "ocarra_1": Vector2i(2, 4)})
	assert_int(_pega(salvajes, "rodauva_s1", "rodauva_2")).is_equal(2 + 1)
	assert_int(_pega(salvajes, "rodauva_s2", "ocarra_1")).is_equal(2 + 1)


# (5) Sistema.md 11.5: una caida no da afinidad. Una guardada no esta en el
# tablero (sin posicion): tampoco. Control: la misma de pie, si.
func test_caida_y_guardada_no_dan() -> void:
	var ubicar: Dictionary = {"rodauva_2": Vector2i(3, 3), "ocarra_s1": Vector2i(3, 2), "rodauva_3": Vector2i(2, 3)}
	assert_int(_pega(_plantel(ubicar), "rodauva_2", "ocarra_s1")).is_equal(3)

	var caida: Plantel = _plantel(ubicar)
	caida.criatura("rodauva_3").estado = Criatura.Estado.CAIDA
	caida.criatura("rodauva_3").vida = 0
	assert_int(_pega(caida, "rodauva_2", "ocarra_s1")).is_equal(2)

	var guardada: Plantel = _plantel(ubicar)
	guardada.criatura("rodauva_3").estado = Criatura.Estado.GUARDADA
	guardada.criatura("rodauva_3").posicion = Criatura.SIN_POSICION
	assert_int(_pega(guardada, "rodauva_2", "ocarra_s1")).is_equal(2)


# (6) Sistema.md 11.2.2, Relaciones: una oculta sigue dando y recibiendo
# afinidad. Con un fixture de relaciones con Rodauva-Zancajunco "bien" (en 10.8
# no lo son): la Rodauva junto al Zancajunco oculto pega 3, y el Zancajunco
# oculto (4, bono +3) junto a la Rodauva pega 8. Con las relaciones de siempre,
# 2 y 7.
func test_oculta_da_y_recibe() -> void:
	var afinidad_junco: Afinidad = DatosFixture.afinidad(_leer(_CARPETA + "relaciones_junco_afin.json", "relaciones"))
	var plantel: Plantel = _plantel({"rodauva_2": Vector2i(3, 3), "ocarra_s1": Vector2i(3, 2),
			"zancajunco_1": Vector2i(2, 3), "rodauva_s1": Vector2i(2, 2)})
	Junco.ocultar(plantel.criatura("zancajunco_1"))
	assert_bool(plantel.criatura("zancajunco_1").oculta).is_true()

	assert_int(_pega(plantel, "rodauva_2", "ocarra_s1", afinidad_junco)).is_equal(2 + 1)
	assert_int(_pega(plantel, "zancajunco_1", "rodauva_s1", afinidad_junco)).is_equal(4 + 3 + 1)

	assert_int(_pega(plantel, "rodauva_2", "ocarra_s1")).is_equal(2)
	assert_int(_pega(plantel, "zancajunco_1", "rodauva_s1")).is_equal(4 + 3)


# (7) Sistema.md 10.3: "se mira la posicion del atacante al golpear". La
# previsualizacion desde una casilla junto a una afin suma aunque hoy no este
# al lado; desde una sin afin no suma aunque hoy si lo este. La Rodauva que
# previsualiza desde la casilla vecina a la suya, sin otra Rodauva cerca, pega
# 2: no se cuenta a si misma.
func test_se_mira_desde_la_casilla_del_ataque() -> void:
	var lejos: Plantel = _plantel({"rodauva_2": Vector2i(1, 3), "ocarra_s1": Vector2i(3, 2), "rodauva_3": Vector2i(4, 3)})
	var vista: ResultadoAccion = _turno(lejos, "rodauva_2").previsualizar_ataque(Vector2i(3, 3), "ocarra_s1")
	assert_bool(vista.valida).is_true()
	assert_int(vista.danio).is_equal(3)

	var al_lado: Plantel = _plantel({"rodauva_2": Vector2i(3, 3), "ocarra_s1": Vector2i(3, 2), "rodauva_3": Vector2i(4, 3)})
	var turno: Turno = _turno(al_lado, "rodauva_2")
	assert_int(turno.validar(Accion.atacar("ocarra_s1")).danio).is_equal(3)
	vista = turno.previsualizar_ataque(Vector2i(2, 2), "ocarra_s1")
	assert_bool(vista.valida).is_true()
	assert_int(vista.danio).is_equal(2)

	var sola: Plantel = _plantel({"rodauva_2": Vector2i(3, 4), "ocarra_s1": Vector2i(3, 2)})
	vista = _turno(sola, "rodauva_2").previsualizar_ataque(Vector2i(3, 3), "ocarra_s1")
	assert_bool(vista.valida).is_true()
	assert_int(vista.danio).is_equal(2)
	assert_array(_fuentes(vista.desglose)).not_contains([ModificadorDanio.Fuente.AFINIDAD])


# (8) Sistema.md 10.3: se mira a la atacante, nunca a la objetivo. La Ocarra (4)
# que golpea a distancia 2 suma con el Surcon (10.8, "bien") a su lado, y no por
# la Rodauva salvaje afin de la objetivo.
func test_ocarra_a_distancia_2() -> void:
	var con_surcon: Plantel = _plantel({"ocarra_1": Vector2i(1, 4), "surcon_1": Vector2i(1, 5),
			"rodauva_s1": Vector2i(3, 4), "rodauva_s2": Vector2i(4, 4)})
	assert_int(_pega(con_surcon, "ocarra_1", "rodauva_s1")).is_equal(4 + 1)

	var sin_surcon: Plantel = _plantel({"ocarra_1": Vector2i(1, 4), "rodauva_s1": Vector2i(3, 4),
			"rodauva_s2": Vector2i(4, 4)})
	assert_int(_pega(sin_surcon, "ocarra_1", "rodauva_s1")).is_equal(4)


# (9) Sistema.md 11.4, ejemplo: el Maestro (4), con un aporte de prueba de combo
# +50% y adyacente a una leal: 4 x 1,5 = 6, + 1 = 7. El desglose lleva la fuente
# afinidad.
func test_ejemplo_11_4() -> void:
	var plantel: Plantel = _plantel({Maestro.ID: Vector2i(3, 3), "ocarra_s1": Vector2i(3, 2),
			"rodauva_1": Vector2i(2, 3)})
	var afinidad: ModificadorDanio = DatosFixture.afinidad().aporte(Maestro.ID, Vector2i(3, 3), plantel)
	assert_object(afinidad).is_not_null()
	var combo: ModificadorDanio = ModificadorDanio.new(ModificadorDanio.Fuente.COMBO, ModificadorDanio.Tipo.PORCENTAJE, 50)
	var aportes: Array[ModificadorDanio] = [combo, afinidad]
	var desglose: DesgloseDanio = _danio.calcular(Maestro.ID, "ocarra_s1", plantel, aportes)
	assert_int(desglose.total).is_equal(7)
	assert_array(_fuentes(desglose)).contains([ModificadorDanio.Fuente.AFINIDAD])
	assert_int(afinidad.tipo).is_equal(ModificadorDanio.Tipo.PLANO)
	assert_int(afinidad.valor).is_equal(1)


# (10) Sistema.md 11.8 (paso 5, "puede tumbar", S-8) y 10.7: la Rodauva salvaje
# (2) sola no tumba a la Ocarra de la tribu con 3 de vida; con su afin al lado
# (3) si, y la remata. El danio aplicado es el previsto.
func test_ia_remata_con_la_afinidad() -> void:
	var sola: Plantel = _plantel({"rodauva_s1": Vector2i(3, 2), "ocarra_1": Vector2i(3, 3)})
	sola.criatura("ocarra_1").vida = 3
	var decision_sola: DecisionIA = _decidir(sola, "rodauva_s1")["decision"]
	assert_int(decision_sola.paso).is_not_equal(DecisionIA.Paso.REMATE)

	var plantel: Plantel = _plantel({"rodauva_s1": Vector2i(3, 2), "rodauva_s2": Vector2i(4, 2), "ocarra_1": Vector2i(3, 3)})
	plantel.criatura("ocarra_1").vida = 3
	var jugada: Dictionary = _decidir(plantel, "rodauva_s1")
	var decision: DecisionIA = jugada["decision"]
	assert_int(decision.paso).override_failure_message(decision.describir()).is_equal(DecisionIA.Paso.REMATE)
	assert_str(decision.objetivo_id).is_equal("ocarra_1")
	assert_int(decision.danio_previsto).is_equal(2 + 1)
	var turno: Turno = jugada["turno"]
	var aplicado: int = -1
	for accion in decision.acciones:
		var resultado: ResultadoAccion = turno.aplicar(accion)
		assert_bool(resultado.valida).is_true()
		if accion.tipo == Accion.Tipo.ATACAR:
			aplicado = resultado.danio
	assert_int(aplicado).is_equal(decision.danio_previsto)
	assert_int(plantel.criatura("ocarra_1").vida).is_equal(0)
	assert_int(plantel.criatura("ocarra_1").estado).is_equal(Criatura.Estado.CAIDA)


func _decidir(plantel: Plantel, unidad_id: String) -> Dictionary:
	var turno: Turno = _turno(plantel, unidad_id)
	var cola: ColaIniciativa = ColaIniciativa.new()
	cola.empezar_ronda(plantel)
	return {"turno": turno, "decision": IASalvaje.decidir(turno, plantel, cola)}


# Arquitectura.md, principio 2: la afinidad no usa azar.
func test_sin_azar() -> void:
	for ruta in _FUENTES:
		var codigo: String = FileAccess.get_file_as_string(ruta)
		for prohibido in _AZAR_PROHIBIDO:
			assert_str(codigo).not_contains(prohibido)


# --- T41: vecinas en 8 (Sistema.md 10.3 v1.6, 11.3 v1.6 y D-001) ---

# (T41.1) Sistema.md 10.3 v1.6: una afin en diagonal de `desde` da +1. La
# Rodauva (2) con otra Rodauva en diagonal pega 3; sin ella, 2.
func test_afin_en_diagonal() -> void:
	var diagonal: Plantel = _plantel({"rodauva_2": Vector2i(3, 3), "ocarra_s1": Vector2i(3, 2),
			"rodauva_3": Vector2i(2, 4)})
	assert_int(_pega(diagonal, "rodauva_2", "ocarra_s1")).is_equal(2 + 1)

	var sola: Plantel = _plantel({"rodauva_2": Vector2i(3, 3), "ocarra_s1": Vector2i(3, 2)})
	assert_int(_pega(sola, "rodauva_2", "ocarra_s1")).is_equal(2)


# (T41.2) Sistema.md 10.3 v1.6: una afin ortogonal y otra en diagonal dan +1, no +2.
func test_ortogonal_y_diagonal_dan_uno() -> void:
	var plantel: Plantel = _plantel({"rodauva_2": Vector2i(3, 3), "ocarra_s1": Vector2i(3, 2),
			"rodauva_3": Vector2i(2, 3), "rodauva_1": Vector2i(4, 4)})
	var vista: ResultadoAccion = _turno(plantel, "rodauva_2").validar(Accion.atacar("ocarra_s1"))
	assert_int(vista.danio).is_equal(2 + 1)
	assert_int(_fuentes(vista.desglose).count(ModificadorDanio.Fuente.AFINIDAD)).is_equal(1)
	assert_array(DatosFixture.afinidad().afines_vecinas("rodauva_2", Vector2i(3, 3), plantel)) \
			.is_equal(["rodauva_1", "rodauva_3"])


# (T41.3) Sistema.md 10.3 v1.6: a distancia 2 ([x+2, y] y [x+2, y+1]) no da.
func test_a_distancia_2_no_da() -> void:
	for casilla in [Vector2i(5, 3), Vector2i(5, 4)]:
		var plantel: Plantel = _plantel({"rodauva_2": Vector2i(3, 3), "ocarra_s1": Vector2i(3, 2),
				"rodauva_3": casilla})
		assert_int(_pega(plantel, "rodauva_2", "ocarra_s1")).override_failure_message(str(casilla)).is_equal(2)


# (T41.4) Sistema.md 10.3 v1.6: la Ocarra (4) que pega a distancia 2 suma con el
# Surcon en diagonal de ella; con el Surcon en diagonal de la objetivo (lejos de
# ella), no.
func test_ocarra_a_distancia_2_afin_en_diagonal() -> void:
	var de_ella: Plantel = _plantel({"ocarra_1": Vector2i(1, 4), "surcon_1": Vector2i(2, 5),
			"rodauva_s1": Vector2i(3, 4)})
	assert_int(_pega(de_ella, "ocarra_1", "rodauva_s1")).is_equal(4 + 1)

	var de_la_objetivo: Plantel = _plantel({"ocarra_1": Vector2i(1, 4), "surcon_1": Vector2i(4, 5),
			"rodauva_s1": Vector2i(3, 4)})
	assert_int(_pega(de_la_objetivo, "ocarra_1", "rodauva_s1")).is_equal(4)


# (T41.5) Sistema.md 10.3 y 10.7 v1.6: dos Rodauvas salvajes en diagonal pegan 3
# cada una. Una Rodauva de la tribu con una salvaje en diagonal, 2.
func test_salvajes_en_diagonal_y_bandos() -> void:
	var salvajes: Plantel = _plantel({"rodauva_s1": Vector2i(3, 3), "rodauva_s2": Vector2i(2, 2),
			"rodauva_2": Vector2i(3, 4), "ocarra_1": Vector2i(1, 2)})
	assert_int(_pega(salvajes, "rodauva_s1", "rodauva_2")).is_equal(2 + 1)
	assert_int(_pega(salvajes, "rodauva_s2", "ocarra_1")).is_equal(2 + 1)

	var mezcla: Plantel = _plantel({"rodauva_2": Vector2i(3, 3), "ocarra_s1": Vector2i(3, 2),
			"rodauva_s1": Vector2i(2, 4)})
	assert_int(_pega(mezcla, "rodauva_2", "ocarra_s1")).is_equal(2)


# (T41.9) Sistema.md 11.8 (paso 5) y 10.3 v1.6: la Rodauva salvaje (2) remata a
# la Ocarra con 3 de vida gracias a su afin en diagonal, y el danio aplicado es
# el previsto.
func test_ia_remata_con_afin_en_diagonal() -> void:
	var plantel: Plantel = _plantel({"rodauva_s1": Vector2i(3, 2), "rodauva_s2": Vector2i(4, 1), "ocarra_1": Vector2i(3, 3)})
	plantel.criatura("ocarra_1").vida = 3
	var jugada: Dictionary = _decidir(plantel, "rodauva_s1")
	var decision: DecisionIA = jugada["decision"]
	assert_int(decision.paso).override_failure_message(decision.describir()).is_equal(DecisionIA.Paso.REMATE)
	assert_str(decision.objetivo_id).is_equal("ocarra_1")
	assert_int(decision.danio_previsto).is_equal(2 + 1)
	var turno: Turno = jugada["turno"]
	var aplicado: int = -1
	for accion in decision.acciones:
		var resultado: ResultadoAccion = turno.aplicar(accion)
		assert_bool(resultado.valida).is_true()
		if accion.tipo == Accion.Tipo.ATACAR:
			aplicado = resultado.danio
	assert_int(aplicado).is_equal(decision.danio_previsto)
	assert_int(plantel.criatura("ocarra_1").estado).is_equal(Criatura.Estado.CAIDA)


# (T41.10) Sistema.md 10.3 v1.6: Combate.afines_desde, en una esquina y en el
# centro, con el Maestro y la leal (rodauva_1) en diagonal. Calcula sin aplicar.
func test_afines_desde() -> void:
	var lectura: Dictionary = DatosFixture.cargar()
	assert_array(lectura["errores"]).is_empty()
	var contexto: ContextoCombate = ContextoCombate.armar(_leer(_CARPETA + "escenario_afinidad.json", "escenario"),
			lectura["datos"])
	assert_bool(contexto.valido).is_true()
	var combate: Combate = Combate.empezar(contexto)
	assert_str(combate.error()).is_empty()
	var plantel: Plantel = contexto.plantel

	# Esquina [0,0], con el Maestro y la leal en [1,1].
	_ubicar(plantel, {Maestro.ID: Vector2i(1, 1)})
	var antes: Dictionary = combate.instantanea()
	assert_array(combate.afines_desde("rodauva_1", Vector2i(0, 0))).is_equal([Maestro.ID])
	# Calcula sin aplicar: la foto es la misma.
	assert_dict(combate.instantanea()).is_equal(antes)
	_ubicar(plantel, {Maestro.ID: Vector2i(5, 5), "rodauva_1": Vector2i(1, 1)})
	assert_array(combate.afines_desde(Maestro.ID, Vector2i(0, 0))).is_equal(["rodauva_1"])

	# Centro [3,3]: la leal en [2,2] da; la neutral en [4,4], no.
	_ubicar(plantel, {Maestro.ID: Vector2i(3, 3), "rodauva_1": Vector2i(2, 2), "rodauva_2": Vector2i(4, 4)})
	assert_array(combate.afines_desde(Maestro.ID, Vector2i(3, 3))).is_equal(["rodauva_1"])
	# rodauva_2 desde [3,3]: las dos Rodauvas en diagonal, en el orden del Plantel.
	_ubicar(plantel, {Maestro.ID: Vector2i(0, 7), "rodauva_3": Vector2i(4, 2)})
	assert_array(combate.afines_desde("rodauva_2", Vector2i(3, 3))).is_equal(["rodauva_1", "rodauva_3"])
