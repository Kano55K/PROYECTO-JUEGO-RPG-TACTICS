extends GdUnitTestSuite

# T33, sesion 3, criterio (10): FichaPlaytest arma la ficha de playtest (D-015):
# la variante sin la semilla, el indice de la semilla de playtest (desde 1) o
# null, y el jugador (vacio = null). Valida contra el esquema playtest. Las
# semillas son las del fixture de alarmas (MesaPlaytest).


func _errores(ficha: Dictionary) -> Array:
	var esquema: Dictionary = Cargador.new().esquema_resuelto("res://datos", "playtest")["esquema"]
	return Validador.new().validar(ficha, esquema, "playtest")["errores"]


func test_la_ficha_valida_y_no_lleva_la_semilla_en_la_variante() -> void:
	var semillas: Array = MesaPlaytest.semillas()
	var cambios: Dictionary = {"semilla": semillas[0], "maestro.balanza": 4, "tribu.rodauva_1.estado": "guardada"}
	var ficha: Dictionary = FichaPlaytest.armar("c_tasajero", cambios, semillas[0], semillas, "Ana")
	assert_array(_errores(ficha)).override_failure_message(str(_errores(ficha))).is_empty()
	assert_dict(ficha).is_equal({"escenario": "c_tasajero",
			"variante": {"maestro.balanza": 4, "tribu.rodauva_1.estado": "guardada"},
			"semilla": semillas[0], "indice_semilla": 1, "jugador": "Ana"})
	# Los cambios que recibe no se tocan.
	assert_bool(cambios.has("semilla")).is_true()


func test_indice_de_la_semilla() -> void:
	var semillas: Array = MesaPlaytest.semillas()
	assert_int(FichaPlaytest.indice(semillas[0], semillas) as int).is_equal(1)
	assert_int(FichaPlaytest.indice(semillas[9], semillas) as int).is_equal(10)
	assert_that(FichaPlaytest.indice(999, semillas)).is_null()
	assert_that(FichaPlaytest.indice(semillas[0], [])).is_null()
	var fuera: Dictionary = FichaPlaytest.armar("a_dia_1", {}, 999, semillas, "Ana")
	assert_that(fuera["indice_semilla"]).is_null()
	assert_dict(fuera["variante"] as Dictionary).is_empty()
	assert_array(_errores(fuera)).is_empty()


func test_jugador_vacio_es_null() -> void:
	for jugador in [null, "", "   "]:
		var ficha: Dictionary = FichaPlaytest.armar("a_dia_1", {}, 1, [], jugador)
		assert_that(ficha["jugador"]).override_failure_message(str(jugador)).is_null()
		assert_array(_errores(ficha)).is_empty()
	assert_str(FichaPlaytest.armar("a_dia_1", {}, 1, [], "  Ana ")["jugador"] as String).is_equal("Ana")


# (12) Un resultado sin ficha: escenario y semilla del resultado, variante y
# jugador desconocidos (null).
func test_desconocida() -> void:
	var semillas: Array = MesaPlaytest.semillas()
	var resultado: Dictionary = MesaPlaytest.partida("c_tasajero", "Ana", semillas[1])["resultado"]
	assert_dict(FichaPlaytest.desconocida(resultado, semillas)).is_equal({"escenario": "c_tasajero",
			"variante": null, "semilla": semillas[1], "indice_semilla": 2, "jugador": null})
