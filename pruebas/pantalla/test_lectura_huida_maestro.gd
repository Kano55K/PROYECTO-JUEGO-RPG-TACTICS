extends GdUnitTestSuite

# Arquitectura.md B.4 (T28), criterio 10: lo que LecturaCombate arma para la
# huida del Maestro: el boton (motivo de Turno.motivo_huir), la vista previa
# (Combate.previsualizar_huida), la marca y la linea del panel con la huida
# declarada, los sucesos (declarar; irse con o sin caidas, hueco {caida}) y el
# desenlace del resultado. Fixtures (A.6): escenario_huida_maestro_combate.json
# (con la Velocidad del Maestro subida en memoria a 9: juega primero; Tasajero
# 5 + 5, Surcon 3, la Ocarra no lo alcanza; rodauva_2 caida), es_rasgos.json,
# copias textuales de datos/textos/es.json y textos de prueba para las claves
# propuestas (no estan en es.json). Sistema.md 11.7.
const _ESCENARIO: String = "res://pruebas/fixtures/combate/escenario_huida_maestro_combate.json"
const _TEXTOS: String = "res://pruebas/fixtures/pantalla/es_rasgos.json"
const _VELOCIDAD_MAESTRO: int = 9
const _CAIDA: String = "rodauva_2"
# Copias textuales de datos/textos/es.json.
const _TEXTOS_ES: Dictionary = {
	"accion.huir": "Huir",
	"huida.maestro.declarar": "Retrocedés. Hasta que salgas del claro, todavía te pueden alcanzar.",
	"huida.maestro.sin_caidas": "Se van sin mirar atrás. El día queda a medias.",
	"huida.maestro.con_caidas": "Al cruzar el claro, mirás atrás una vez. {caida} sigue donde cayó.",
}
# Textos de prueba de las claves propuestas.
const _TEXTOS_PRUEBA: Dictionary = {
	"marca.huida_declarada": "Se va",
	"panel.huida_declarada": "Se va al cerrar la ronda",
	"huida.previa.alcanza": "te alcanza",
	"huida.previa.no_alcanza": "no te alcanza",
	"huida.previa.sin_enemigas": "Nadie actúa antes del cierre",
	"huida.previa.danio_maximo": "Daño máximo",
	"huida.previa.puede_caer": "Podés caer",
	"huida.previa.caidas": "Mueren",
}

var _combate: Combate


# sin_caida: el escenario sin rodauva_2.
func _lectura(sin_caida: bool = false) -> LecturaCombate:
	var lectura: Dictionary = DatosFixture.cargar()
	assert_array(lectura["errores"]).is_empty()
	var datos: Dictionary = lectura["datos"]
	datos["maestro.json"]["velocidad"] = _VELOCIDAD_MAESTRO
	var textos: Dictionary = LectorFixture.leer(_TEXTOS, "textos")["datos"]
	textos.merge(_TEXTOS_ES, true)
	textos.merge(_TEXTOS_PRUEBA, true)
	var escenario: Dictionary = LectorFixture.leer(_ESCENARIO, "escenario")["datos"]
	if sin_caida:
		escenario["tribu"] = (escenario["tribu"] as Array).filter(func(criatura: Dictionary) -> bool:
				return criatura["id"] != _CAIDA)
	var contexto: ContextoCombate = ContextoCombate.armar(escenario, datos)
	assert_bool(contexto.valido).is_true()
	_combate = Combate.empezar(contexto)
	assert_str(_combate.error()).is_empty()
	assert_str(_combate.turno_actual().unidad_id).is_equal(Maestro.ID)
	return LecturaCombate.new(_combate, ArmadorTextos.desde_datos(textos, contexto.azar_textos),
			EstadosUnidad.desde_datos(datos["tablas/hambre.json"], datos["tablas/lealtad.json"]))


func _aplicar_valida(accion: Accion) -> void:
	var resultado: ResultadoAccion = _combate.aplicar(accion)
	assert_bool(resultado.valida).override_failure_message(str(accion.a_diccionario())).is_true()


# Declara, termina y juega esperando hasta el fin (en huida).
func _huir_hasta_el_fin() -> void:
	_aplicar_valida(Accion.huir())
	for _i in range(10):
		if _combate.terminado():
			break
		_aplicar_valida(Accion.terminar())
	assert_int(_combate.fin()).is_equal(FinCombate.Fin.HUIDA)


# (10) El boton en el turno del Maestro con el turno sin usar, sin tooltip.
# Despues de moverse, deshabilitado con el motivo; con la huida declarada o en
# el turno de una criatura, no hay boton.
func test_boton() -> void:
	var lectura: LecturaCombate = _lectura()
	assert_dict(lectura.boton_huir()).is_equal({"texto": "Huir", "habilitado": true, "tooltip": ""})
	_aplicar_valida(Accion.mover(Vector2i(2, 7)))
	assert_dict(lectura.boton_huir()).is_equal({"texto": "Huir", "habilitado": false,
			"tooltip": "[FALTA: aviso.huir.ya_se_movio]"})
	_aplicar_valida(Accion.terminar())
	assert_str(_combate.turno_actual().unidad_id).is_not_equal(Maestro.ID)
	assert_dict(lectura.boton_huir()).is_empty()


func test_sin_boton_con_la_huida_declarada() -> void:
	var lectura: LecturaCombate = _lectura()
	_aplicar_valida(Accion.huir())
	assert_dict(lectura.boton_huir()).is_empty()


# (10) La vista previa con los numeros de Combate.previsualizar_huida: cada enemiga
# en el orden de la cola, el danio maximo, la vida y las caidas que moririan.
func test_vista_previa() -> void:
	var lectura: LecturaCombate = _lectura()
	var previa: Dictionary = _combate.previsualizar_huida()
	assert_array(lectura.vista_previa_huida(previa)).is_equal([
		"%s · Te alcanza −10" % lectura.nombre("tasajero_s1"),
		"%s · No te alcanza" % lectura.nombre("ocarra_s1"),
		"%s · Te alcanza −3" % lectura.nombre("surcon_s1"),
		"Daño máximo: 13",
		"Vida: 20",
		"Mueren: %s" % lectura.nombre(_CAIDA),
	])


# (10) Sin enemigas pendientes, la linea de nadie; si puede caer, el aviso.
func test_vista_previa_sin_enemigas_y_puede_caer() -> void:
	var lectura: LecturaCombate = _lectura()
	assert_array(lectura.vista_previa_huida({"enemigas": [], "danio_maximo": 0, "vida": 0, "puede_caer": true,
			"caidas": []})).is_equal(["Nadie actúa antes del cierre", "Daño máximo: 0", "Vida: 0", "Podés caer"])


# (10) Con la huida declarada: la marca en la ficha del Maestro y la linea del
# panel del turno.
func test_marca_y_panel() -> void:
	var lectura: LecturaCombate = _lectura()
	_aplicar_valida(Accion.huir())
	var marcas: Array[String] = lectura.fichas()[0]["marcas"]
	assert_array(marcas).contains(["Se va"])
	assert_array(lectura.panel_turno()).contains(["Se va al cerrar la ronda"])


# (10) Los sucesos: declarar; al irse, una linea por caida que muere (hueco
# {caida}) antes de las del cierre; sin caidas, la de irse sin mirar atras.
func test_sucesos() -> void:
	var lectura: LecturaCombate = _lectura()
	assert_array(lectura.suceso({"tipo": "accion", "unidad": Maestro.ID, "origen": "jugador",
			"accion": {"tipo": "huir"}, "paso": null, "n": 1, "ronda": 1})) \
			.is_equal(["Retrocedés. Hasta que salgas del claro, todavía te pueden alcanzar."])
	_huir_hasta_el_fin()
	var sucesos: Array[String] = lectura.sucesos(0)
	assert_array(sucesos).contains(["Retrocedés. Hasta que salgas del claro, todavía te pueden alcanzar."])
	var con_caidas: Array[String] = sucesos.filter(func(linea: String) -> bool:
			return linea.begins_with("Al cruzar el claro"))
	assert_array(con_caidas).has_size(1)
	assert_str(con_caidas[0]).ends_with("Rodauva sigue donde cayó.")
	assert_array(sucesos).not_contains(["Se van sin mirar atrás. El día queda a medias."])


func test_suceso_sin_caidas() -> void:
	var lectura: LecturaCombate = _lectura(true)
	_huir_hasta_el_fin()
	assert_array(lectura.sucesos(0)).contains(["Se van sin mirar atrás. El día queda a medias."])


# (10) El resultado dice el desenlace huida (clave propuesta: falta en es.json).
func test_resultado() -> void:
	var lectura: LecturaCombate = _lectura()
	_huir_hasta_el_fin()
	assert_array(lectura.resultado(_combate.resultado().a_diccionario())) \
			.contains(["[FALTA: resultado.desenlace.huida]"])
