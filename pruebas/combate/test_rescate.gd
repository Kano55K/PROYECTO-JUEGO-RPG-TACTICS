extends GdUnitTestSuite

# Arquitectura.md B.4 (T29), criterios 1 a 6: la eleccion de la rescatista
# (Rescate) y el cierre con rescate, con fixtures (A.6). Sistema.md 6 (candidatas,
# desempates, +2, permadeath), 5.1 (Leal desde el umbral), 5.2 (suma y recorte
# unicos), 5.4 ("el rescate usa la lealtad real"), 1.2 (umbral 7 con la balanza 2
# y 8 con la 4) y 11.5. Lectura declarada S-62: la lealtad del momento en que cae
# el Maestro. escenario_rescate.json: todas en los bordes, lejos del Maestro
# [5,5]; cada test acomoda las suyas. Los numeros son la comprobacion.
const _CARPETA: String = "res://pruebas/fixtures/combate/"
const _CARPETA_UNIDADES: String = "res://pruebas/fixtures/unidades/"
const _ESPECIES: Array[String] = ["ocarra", "rodauva", "surcon", "zancajunco"]
const _UMBRAL_BALANZA_2: int = 7
const _UMBRAL_BALANZA_4: int = 8
const _HAMBRE_FAMELICA: int = 9
const _RESCATE: int = 2

var _cierre: Cierre
var _obediencia: Obediencia


func before_test() -> void:
	var relaciones: Relaciones = Relaciones.new(_leer(_CARPETA_UNIDADES + "relaciones.json", "relaciones"))
	var lealtad: Dictionary = _leer(_CARPETA_UNIDADES + "lealtad.json", "lealtad")
	var combate: Dictionary = _leer(_CARPETA + "combate.json", "combate")
	_cierre = Cierre.desde_datos(combate, lealtad, relaciones)
	_obediencia = Obediencia.desde_datos(_leer(_CARPETA + "hambre.json", "hambre"), lealtad, combate)


func _leer(ruta: String, nombre_esquema: String) -> Dictionary:
	var lectura: Dictionary = LectorFixture.leer(ruta, nombre_esquema)
	var errores: Array[Dictionary] = lectura["errores"]
	assert_array(errores).override_failure_message(str(errores)).is_empty()
	return lectura["datos"]


func _plantel() -> Plantel:
	var especies: Dictionary = {}
	for id_especie in _ESPECIES:
		especies[id_especie] = Especie.new(_leer(_CARPETA_UNIDADES + id_especie + ".json", "especie"))
	var tabla: TablaBalanza = TablaBalanza.new(_leer(_CARPETA_UNIDADES + "balanza_1_2.json", "balanza"))
	return Plantel.desde_escenario(_leer(_CARPETA + "escenario_rescate.json", "escenario"), especies, tabla,
			_leer(_CARPETA_UNIDADES + "maestro.json", "maestro"))


# Pone lealtad y casilla a una suelta del fixture.
func _acomodar(plantel: Plantel, criatura_id: String, lealtad: int, casilla: Vector2i) -> Criatura:
	var criatura: Criatura = plantel.criatura(criatura_id)
	criatura.lealtad = lealtad
	criatura.posicion = casilla
	return criatura


# Lleva a 0 a cada unidad y la resuelve como despues de un golpe aplicado.
func _tumbar(plantel: Plantel, ids: Array[String]) -> void:
	for unidad_id in ids:
		if unidad_id == Maestro.ID:
			plantel.maestro.vida = 0
		else:
			plantel.criatura(unidad_id).vida = 0
		VidaCero.resolver(unidad_id, plantel, Surcos.new())


func _cerrar_derrota(plantel: Plantel) -> ResultadoCierre:
	_tumbar(plantel, [Maestro.ID])
	var cierre: ResultadoCierre = _cierre.cerrar(plantel, FinCombate.Fin.DERROTA_POR_CAIDA)
	assert_bool(cierre.valido).is_true()
	return cierre


func _cambio(cierre: ResultadoCierre, criatura_id: String) -> CambioLealtad:
	for cambio in cierre.lealtad:
		if cambio.criatura_id == criatura_id:
			return cambio
	return null


func _motivos(cambio: CambioLealtad) -> Array[String]:
	var motivos: Array[String] = []
	for anotacion in cambio.anotaciones:
		motivos.append(anotacion.motivo)
	return motivos


func _con_rescate(cierre: ResultadoCierre) -> Array[String]:
	var ids: Array[String] = []
	for cambio in cierre.lealtad:
		if _motivos(cambio).has("rescate"):
			ids.append(cambio.criatura_id)
	return ids


# (1) Solo las sueltas de pie en el tablero: una caida, una guardada (lealtad 9)
# y una que salio no rescatan aunque sean leales; una oculta si.
func test_candidatas_por_estado() -> void:
	var plantel: Plantel = _plantel()
	var rescate: Rescate = _cierre.rescate
	_acomodar(plantel, "rodauva_1", 9, Vector2i(0, 0))
	_tumbar(plantel, ["rodauva_1"])
	var fuera: Criatura = _acomodar(plantel, "rodauva_2", 9, Vector2i(11, 0))
	VidaCero.sacar_del_tablero(fuera, Surcos.new())
	assert_int(fuera.estado).is_equal(Criatura.Estado.FUERA)
	var oculta: Criatura = _acomodar(plantel, "surcon_1", _UMBRAL_BALANZA_2, Vector2i(0, 11))
	oculta.oculta = true

	assert_bool(rescate.es_candidata(plantel.criatura("rodauva_1"), plantel)).is_false()
	assert_bool(rescate.es_candidata(fuera, plantel)).is_false()
	assert_bool(rescate.es_candidata(plantel.criatura("zancajunco_1"), plantel)).is_false()
	assert_bool(rescate.es_candidata(plantel.criatura("ocarra_s1"), plantel)).is_false()
	assert_bool(rescate.es_candidata(oculta, plantel)).is_true()
	assert_str(rescate.elegir(plantel)).is_equal("surcon_1")


# (1) Lealtad igual al umbral rescata y uno menos no: balanza 2 (umbral 7) y 4 (8).
func test_umbral_de_la_balanza() -> void:
	var plantel: Plantel = _plantel()
	var rescate: Rescate = _cierre.rescate
	var criatura: Criatura = plantel.criatura("rodauva_1")
	for caso in [[2, _UMBRAL_BALANZA_2], [4, _UMBRAL_BALANZA_4]]:
		plantel.maestro.balanza = caso[0]
		assert_int(plantel.maestro.fila_balanza()["umbral_rescate"]).is_equal(caso[1])
		criatura.lealtad = caso[1]
		assert_bool(rescate.es_candidata(criatura, plantel)).override_failure_message(str(caso)).is_true()
		assert_str(rescate.elegir(plantel)).is_equal("rodauva_1")
		criatura.lealtad = caso[1] - 1
		assert_bool(rescate.es_candidata(criatura, plantel)).override_failure_message(str(caso)).is_false()
		assert_str(rescate.elegir(plantel)).is_empty()


# (1) Sistema.md 5.4: una leal famelica (obediencia baja) rescata igual.
func test_leal_hambrienta_rescata() -> void:
	var plantel: Plantel = _plantel()
	var criatura: Criatura = _acomodar(plantel, "rodauva_1", _UMBRAL_BALANZA_2, Vector2i(0, 0))
	criatura.hambre = _HAMBRE_FAMELICA
	assert_str(_obediencia.tramo(criatura, plantel.maestro)).is_equal(Obediencia.TRAMO_BAJA)
	assert_bool(_cierre.rescate.es_candidata(criatura, plantel)).is_true()
	var cierre: ResultadoCierre = _cerrar_derrota(plantel)
	assert_str(cierre.rescatista).is_equal("rodauva_1")
	assert_bool(cierre.permadeath).is_false()


# (2) Desempates: mayor lealtad aunque este mas lejos.
func test_gana_la_mayor_lealtad() -> void:
	var plantel: Plantel = _plantel()
	_acomodar(plantel, "rodauva_1", 8, Vector2i(5, 6))
	_acomodar(plantel, "ocarra_1", 9, Vector2i(11, 11))
	assert_str(_cierre.rescate.elegir(plantel)).is_equal("ocarra_1")
	var cierre: ResultadoCierre = _cerrar_derrota(plantel)
	assert_str(cierre.rescatista).is_equal("ocarra_1")
	assert_array(_con_rescate(cierre)).contains_exactly(["ocarra_1"])


# (2) Con empate en lealtad, la mas cercana a la casilla donde cayo el Maestro;
# con empate en las dos, la primera en el orden de la tribu.
func test_desempate_por_distancia_y_orden() -> void:
	var plantel: Plantel = _plantel()
	_acomodar(plantel, "rodauva_1", 8, Vector2i(5, 9))
	_acomodar(plantel, "surcon_1", 8, Vector2i(5, 7))
	_acomodar(plantel, "ocarra_1", 8, Vector2i(7, 5))
	_tumbar(plantel, [Maestro.ID])
	assert_str(_cierre.rescate.elegir(plantel)).is_equal("surcon_1")
	plantel.criatura("rodauva_1").posicion = Vector2i(3, 5)
	assert_str(_cierre.rescate.elegir(plantel)).is_equal("rodauva_1")


# (3) S-62: rescata con la lealtad del momento de la caida. rodauva_2 esta justo
# en el umbral y es afin de rodauva_1, que muere (-4): igual rescata y queda en
# 7 + 2 - 4 = 5.
func test_s62_en_el_umbral_rescata_aunque_pierda() -> void:
	var plantel: Plantel = _plantel()
	_acomodar(plantel, "rodauva_2", _UMBRAL_BALANZA_2, Vector2i(11, 0))
	_tumbar(plantel, ["rodauva_1"])
	var cierre: ResultadoCierre = _cerrar_derrota(plantel)
	assert_str(cierre.rescatista).is_equal("rodauva_2")
	assert_array(cierre.muertas).contains_exactly(["rodauva_1"])
	var cambio: CambioLealtad = _cambio(cierre, "rodauva_2")
	assert_array(_motivos(cambio)).contains_exactly_in_any_order(["rescate", "muerte_en_el_grupo_afines"])
	assert_int(cambio.antes).is_equal(7)
	assert_int(cambio.despues).is_equal(5)
	assert_int(plantel.criatura("rodauva_2").lealtad).is_equal(5)


# (3) Ejemplo de 5.2: una rescatista con 9 que pierde 2 por una caida que muere
# queda en 9 (9 + 2 - 2), con una anotacion de cada motivo y un solo recorte.
func test_ejemplo_de_5_2() -> void:
	var plantel: Plantel = _plantel()
	_acomodar(plantel, "ocarra_1", 9, Vector2i(11, 11))
	_tumbar(plantel, ["rodauva_1"])
	var cierre: ResultadoCierre = _cerrar_derrota(plantel)
	assert_str(cierre.rescatista).is_equal("ocarra_1")
	var cambio: CambioLealtad = _cambio(cierre, "ocarra_1")
	assert_array(_motivos(cambio)).contains_exactly_in_any_order(["rescate", "muerte_en_el_grupo"])
	for anotacion in cambio.anotaciones:
		assert_int(anotacion.cambio).is_equal(_RESCATE if anotacion.motivo == "rescate" else -2)
	assert_int(cambio.cambio).is_equal(0)
	assert_int(cambio.despues).is_equal(9)


# (4) Sin candidatas: permadeath, ningun +2 y las caidas mueren igual.
func test_sin_candidatas_permadeath() -> void:
	var plantel: Plantel = _plantel()
	var pergamino: String = plantel.criatura("rodauva_1").pergamino_id
	_tumbar(plantel, ["rodauva_1"])
	var cierre: ResultadoCierre = _cerrar_derrota(plantel)
	assert_str(cierre.rescatista).is_empty()
	assert_bool(cierre.permadeath).is_true()
	assert_array(_con_rescate(cierre)).is_empty()
	assert_array(cierre.muertas).contains_exactly(["rodauva_1"])
	assert_int(plantel.criatura("rodauva_1").estado).is_equal(Criatura.Estado.MUERTA)
	assert_int(plantel.pergamino(pergamino).estado).is_equal(Pergamino.Estado.ARDIDO)


# (5) El Maestro cae con la huida declarada (T28): derrota por caida, y rescata una
# de las que se iban con el.
func test_cae_con_la_huida_declarada() -> void:
	var plantel: Plantel = _plantel()
	_acomodar(plantel, "surcon_1", 8, Vector2i(0, 11))
	plantel.maestro.huida_declarada = true
	_tumbar(plantel, [Maestro.ID])
	assert_int(FinCombate.evaluar(plantel)).is_equal(FinCombate.Fin.DERROTA_POR_CAIDA)
	var cierre: ResultadoCierre = _cierre.cerrar(plantel, FinCombate.Fin.DERROTA_POR_CAIDA)
	assert_str(cierre.rescatista).is_equal("surcon_1")
	assert_array(_con_rescate(cierre)).contains_exactly(["surcon_1"])


# (6) En victoria y en huida no hay rescate: sin rescatista, sin permadeath y sin +2.
func test_victoria_y_huida_sin_rescate() -> void:
	var victoria: Plantel = _plantel()
	_acomodar(victoria, "ocarra_1", 9, Vector2i(11, 11))
	_tumbar(victoria, ["ocarra_s1"])
	var cierre: ResultadoCierre = _cierre.cerrar(victoria, FinCombate.Fin.VICTORIA)
	assert_bool(cierre.valido).is_true()
	assert_str(cierre.rescatista).is_empty()
	assert_bool(cierre.permadeath).is_false()
	assert_array(_con_rescate(cierre)).is_empty()

	var huida: Plantel = _plantel()
	_acomodar(huida, "ocarra_1", 9, Vector2i(11, 11))
	huida.maestro.huida_declarada = true
	huida.maestro.se_fue = true
	cierre = _cierre.cerrar(huida, FinCombate.Fin.HUIDA)
	assert_bool(cierre.valido).is_true()
	assert_str(cierre.rescatista).is_empty()
	assert_bool(cierre.permadeath).is_false()
	assert_array(_con_rescate(cierre)).is_empty()
