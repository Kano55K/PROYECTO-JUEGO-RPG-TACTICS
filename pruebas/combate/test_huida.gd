extends GdUnitTestSuite

# Arquitectura.md B.4 (T25), criterios 1 a 6: la regla Huida y el paso 2 del
# inicio del turno con turnos sueltos. Fixtures (A.6): escenario_huida.json con
# las especies inventadas de T25 (MesaHuida): especie_huida_100 (100 %, vida 30:
# el 25 % es 7,5) y especie_huida_1 (1 %); la Rodauva (50 %, vida 8), la Ocarra
# (0 %) y el Tasajero (25 %, vida 30, Caza hasta el 50 %) de la fixture.
# GeneradorAzar.new(1) tira primero 98 (se queda); GeneradorAzar.new(6), 7.
# Sistema.md 11.7, 11.3 paso 2, 9.2 punto 5 y S-52.
const _CARPETA: String = "res://pruebas/fixtures/combate/"
const _HUYE: String = "huye_s1"
const _QUEDA: String = "queda_s1"
const _OCARRA: String = "ocarra_s1"
const _RODAUVA_S: String = "rodauva_s1"
const _TASAJERO: String = "tasajero_s1"
const _ATACANTE: String = "atacante_1"
const _RODAUVA_TRIBU: String = "rodauva_1"


# (1) Umbral con una vida maxima que no da un % entero (30: 25 % = 7,5),
# comparando en enteros: 7 tira, 8 no. La Rodauva (8): 2 tira, 3 no.
func test_umbral_de_vida() -> void:
	var mesa: MesaHuida = MesaHuida.new({_HUYE: 7, _RODAUVA_S: 2})
	var huida: Huida = mesa.reglas.huida
	assert_int(huida.porcentaje(_HUYE, mesa.plantel, false)).is_equal(100)
	assert_int(huida.porcentaje(_RODAUVA_S, mesa.plantel, false)).is_equal(50)
	mesa.plantel.criatura(_HUYE).vida = 8
	mesa.plantel.criatura(_RODAUVA_S).vida = 3
	assert_int(huida.porcentaje(_HUYE, mesa.plantel, false)).is_equal(0)
	assert_int(huida.porcentaje(_RODAUVA_S, mesa.plantel, false)).is_equal(0)


# (1) Una especie con 0 % (la Ocarra, "valiente de mas") no huye aunque este
# por debajo del umbral.
func test_especie_con_cero() -> void:
	var mesa: MesaHuida = MesaHuida.new({_OCARRA: 3})
	assert_int(mesa.reglas.huida.porcentaje(_OCARRA, mesa.plantel, false)).is_equal(0)
	assert_int(mesa.reglas.huida.porcentaje(_OCARRA, mesa.plantel, true)).is_equal(25)


# (1) S-52: la enconada no huye. En el paso 2 cuenta como enconada la que tiene
# el Encono en el maximo (3 en la fixture); con uno menos, tira.
func test_enconada_con_encono_al_maximo_da_cero() -> void:
	var mesa: MesaHuida = MesaHuida.new({_HUYE: 7})
	var huida: Huida = mesa.reglas.huida
	mesa.plantel.criatura(_HUYE).encono = 3
	assert_int(huida.porcentaje(_HUYE, mesa.plantel, false)).is_equal(0)
	assert_int(huida.porcentaje(_HUYE, mesa.plantel, true)).is_equal(0)
	mesa.plantel.criatura(_HUYE).encono = 2
	assert_int(huida.porcentaje(_HUYE, mesa.plantel, false)).is_equal(100)


# (1) La acobardada suma 25 (parametro, S-52) y se recorta a 100. Al empezar el
# turno nunca cuenta como acobardada: porcentaje_al_empezar = sin el +25.
func test_acobardada_suma_y_recorta() -> void:
	var mesa: MesaHuida = MesaHuida.new({_RODAUVA_S: 2, _HUYE: 7})
	var huida: Huida = mesa.reglas.huida
	assert_int(huida.porcentaje(_RODAUVA_S, mesa.plantel, true)).is_equal(75)
	assert_int(huida.porcentaje(_HUYE, mesa.plantel, true)).is_equal(100)
	assert_int(huida.porcentaje_al_empezar(_RODAUVA_S, mesa.plantel)).is_equal(50)
	assert_int(huida.porcentaje_al_empezar(_HUYE, mesa.plantel)).is_equal(100)


# (1) Sin un dato de tablas/combate.json la regla no se arma (sin valores por defecto).
func test_sin_un_dato_no_se_arma() -> void:
	var tabla: Dictionary = LectorFixture.leer(_CARPETA + "combate.json", "combate")["datos"]
	assert_object(Huida.desde_datos(tabla)).is_not_null()
	for camino in [["huida_salvaje", "umbral_vida_pct"], ["huida_salvaje", "acobardada_pts"], ["encono", "max_puntos"]]:
		var copia: Dictionary = tabla.duplicate(true)
		(copia[camino[0]] as Dictionary).erase(camino[1])
		assert_object(Huida.desde_datos(copia)).override_failure_message(str(camino)).is_null()


# (2) Solo las salvajes: la atacante nocturna (aunque su ficha diga 100), la
# tribu y el Maestro dan 0 con poca vida, y su turno no toca el generador.
func test_solo_salvajes() -> void:
	var mesa: MesaHuida = MesaHuida.new({_ATACANTE: 1, _RODAUVA_TRIBU: 1, Maestro.ID: 1})
	for unidad_id in [_ATACANTE, _RODAUVA_TRIBU, Maestro.ID]:
		assert_int(mesa.reglas.huida.porcentaje_al_empezar(unidad_id, mesa.plantel)) \
				.override_failure_message(unidad_id).is_equal(0)
		var azar: GeneradorAzar = GeneradorAzar.new(1)
		var turno: Turno = mesa.turno(unidad_id, azar)
		assert_dict(turno.huida).override_failure_message(unidad_id).is_empty()
		assert_bool(turno.terminado).override_failure_message(unidad_id).is_false()
		assert_array(azar.historial()).override_failure_message(unidad_id).is_empty()


# (2) Una salvaje que ya salio del tablero no tira (no esta de pie).
func test_fuera_da_cero() -> void:
	var mesa: MesaHuida = MesaHuida.new({_HUYE: 0})
	VidaCero.sacar_del_tablero(mesa.plantel.criatura(_HUYE), mesa.surcos)
	assert_int(mesa.reglas.huida.porcentaje_al_empezar(_HUYE, mesa.plantel)).is_equal(0)


# (3) Huye: una tirada; queda fuera, sin posicion, con sus surcos cerrados, y el
# turno termina ahi. Ninguna accion vale despues.
func test_huye() -> void:
	var mesa: MesaHuida = MesaHuida.new({_HUYE: 7})
	mesa.surcos.cavar(Vector2i(1, 0), _HUYE, 2)
	var azar: GeneradorAzar = GeneradorAzar.new(1)
	var turno: Turno = mesa.turno(_HUYE, azar)
	assert_int(azar.historial().size()).is_equal(1)
	var tiro: int = azar.historial()[0]["resultado"]
	assert_dict(turno.huida).is_equal({"porcentaje": 100, "tiro": tiro, "resultado": Huida.RESULTADO_HUYE})
	var criatura: Criatura = mesa.plantel.criatura(_HUYE)
	assert_int(criatura.estado).is_equal(Criatura.Estado.FUERA)
	assert_that(criatura.posicion).is_equal(Criatura.SIN_POSICION)
	assert_array(mesa.surcos.de(_HUYE)).is_empty()
	assert_bool(turno.terminado).is_true()
	assert_bool(turno.validar(Accion.terminar()).valida).is_false()
	# Sin cambio de modo ni chequeo de rival: el turno termino en el paso 2.
	assert_dict(turno.cambio_modo).is_empty()
	assert_dict(turno.chequeo_rival).is_empty()


# (3) Pierde sus entradas restantes de la ronda: la cola la saltea.
func test_huye_pierde_sus_entradas_de_la_ronda() -> void:
	var mesa: MesaHuida = MesaHuida.new({_HUYE: 7})
	var cola: ColaIniciativa = ColaIniciativa.new()
	cola.empezar_ronda(mesa.plantel)
	var entrada: EntradaCola = cola.siguiente(mesa.plantel)
	assert_str(entrada.unidad_id).is_equal(_HUYE)
	Turno.empezar(entrada, mesa.plantel, mesa.tablero, mesa.surcos, mesa.cadena, cola, mesa.reglas, GeneradorAzar.new(1))
	var siguiente: EntradaCola = cola.siguiente(mesa.plantel)
	while siguiente != null:
		assert_str(siguiente.unidad_id).is_not_equal(_HUYE)
		siguiente = cola.siguiente(mesa.plantel)


# (4) Se queda: tira (98 > 1) y el turno sigue normal, con sus pasos y su
# ataque, y la IA decide una jugada que el turno acepta.
func test_se_queda_y_el_turno_sigue() -> void:
	var mesa: MesaHuida = MesaHuida.new({_QUEDA: 7})
	var azar: GeneradorAzar = GeneradorAzar.new(1)
	var turno: Turno = mesa.turno(_QUEDA, azar)
	assert_dict(turno.huida).is_equal({"porcentaje": 1, "tiro": 98, "resultado": Huida.RESULTADO_SE_QUEDA})
	assert_bool(turno.terminado).is_false()
	assert_int(mesa.plantel.criatura(_QUEDA).estado).is_equal(Criatura.Estado.SUELTA)
	assert_int(turno.pasos_restantes).is_equal(2)
	assert_int(turno.ataques_restantes).is_equal(1)
	var decision: DecisionIA = IASalvaje.decidir(turno, mesa.plantel, ColaIniciativa.new())
	assert_object(decision).is_not_null()
	for accion in decision.acciones:
		assert_bool(turno.aplicar(accion).valida).override_failure_message(decision.describir()).is_true()
	assert_bool(turno.terminado).is_true()


# (4) Se queda y sigue el resto del inicio: con la rival a su alcance y el
# chequeo al 100 %, tira el chequeo de rival despues de la huida.
func test_se_queda_y_sigue_el_chequeo_de_rival() -> void:
	var mesa: MesaHuida = MesaHuida.new({_TASAJERO: 7})
	mesa.reglas = DatosFixture.reglas({"chequeo_rival": DatosFixture.chequeo_rival("combate_rival_100.json")})
	# El Tasajero es rival de la Rodauva (relaciones de la fixture): a 2 casillas.
	mesa.plantel.criatura(_TASAJERO).posicion = Vector2i(0, 9)
	var azar: GeneradorAzar = GeneradorAzar.new(1)
	var turno: Turno = mesa.turno(_TASAJERO, azar)
	assert_str(turno.huida["resultado"]).is_equal(Huida.RESULTADO_SE_QUEDA)
	assert_dict(turno.chequeo_rival).is_not_empty()
	assert_int(azar.historial()[0]["resultado"]).is_equal(turno.huida["tiro"])
	assert_int(azar.historial().size()).is_greater(1)


# (5) Con 0 % no hay tirada: el generador no se toca (la Ocarra herida y la de
# 100 % con la vida entera).
func test_con_cero_no_tira() -> void:
	var mesa: MesaHuida = MesaHuida.new({_OCARRA: 1})
	for unidad_id in [_OCARRA, _HUYE]:
		var azar: GeneradorAzar = GeneradorAzar.new(1)
		var turno: Turno = mesa.turno(unidad_id, azar)
		assert_dict(turno.huida).override_failure_message(unidad_id).is_empty()
		assert_array(azar.historial()).override_failure_message(unidad_id).is_empty()


# (6) El Tasajero (25 %) en Caza con 7 de 30: tira una vez y, si se queda, pasa
# a Cuenta despues (11.6 Prueba C: "primero tira huida; si se queda, pasa a
# Cuenta"). La tirada es la primera del generador.
func test_tasajero_tira_antes_del_cambio_de_modo() -> void:
	var mesa: MesaHuida = MesaHuida.new({_TASAJERO: 7})
	var azar: GeneradorAzar = GeneradorAzar.new(1)
	var turno: Turno = mesa.turno(_TASAJERO, azar)
	assert_dict(turno.huida).is_equal({"porcentaje": 25, "tiro": 98, "resultado": Huida.RESULTADO_SE_QUEDA})
	assert_int(azar.historial()[0]["resultado"]).is_equal(98)
	assert_dict(turno.cambio_modo).is_equal({"de": "caza", "a": "cuenta"})


# (6) Si huye, no llega al cambio de modo: sale del tablero en Caza.
func test_tasajero_que_huye_no_cambia_de_modo() -> void:
	var mesa: MesaHuida = MesaHuida.new({_TASAJERO: 7})
	var turno: Turno = mesa.turno(_TASAJERO, GeneradorAzar.new(6))
	assert_dict(turno.huida).is_equal({"porcentaje": 25, "tiro": 7, "resultado": Huida.RESULTADO_HUYE})
	assert_dict(turno.cambio_modo).is_empty()
	assert_str(mesa.plantel.criatura(_TASAJERO).modo).is_equal("caza")
	assert_int(mesa.plantel.criatura(_TASAJERO).estado).is_equal(Criatura.Estado.FUERA)


# (6) Con 8 de 30 (por encima del 25 %, debajo del 50 %) no tira y cambia de modo igual.
func test_tasajero_sobre_el_umbral_solo_cambia_de_modo() -> void:
	var mesa: MesaHuida = MesaHuida.new({_TASAJERO: 8})
	var azar: GeneradorAzar = GeneradorAzar.new(1)
	var turno: Turno = mesa.turno(_TASAJERO, azar)
	assert_dict(turno.huida).is_empty()
	assert_array(azar.historial()).is_empty()
	assert_dict(turno.cambio_modo).is_equal({"de": "caza", "a": "cuenta"})


# (6) La entrada que vuelve no repite el inicio del turno (S-31): no tira huida.
func test_al_volver_no_tira() -> void:
	var mesa: MesaHuida = MesaHuida.new({_HUYE: 7})
	var entrada: EntradaCola = EntradaCola.new(_HUYE, "", 0)
	entrada.vuelve = true
	var azar: GeneradorAzar = GeneradorAzar.new(1)
	var turno: Turno = Turno.empezar(entrada, mesa.plantel, mesa.tablero, mesa.surcos, mesa.cadena,
			ColaIniciativa.new(), mesa.reglas, azar)
	assert_dict(turno.huida).is_empty()
	assert_array(azar.historial()).is_empty()
	assert_int(mesa.plantel.criatura(_HUYE).estado).is_equal(Criatura.Estado.SUELTA)
