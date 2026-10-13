extends GdUnitTestSuite

# Arquitectura.md B.4 (T29), criterio 9: lo que LecturaCombate arma para el
# rescate: la linea fija y la marca de quien rescataria ahora (desde
# Combate.rescatista_ahora, solo en el turno del jugador) y la pantalla de
# resultado completa, todo desde ResultadoCombate.a_diccionario(). Fixtures
# (A.6): escenario_rescate_combate.json (turno inicial de zancajunco_1, leal 7 =
# umbral de la balanza 2; rodauva_1 Neutral 5; la Ocarra remata al Maestro con
# vida 4), es_rasgos.json, copias textuales de datos/textos/es.json y textos de
# prueba de las claves propuestas (no estan en es.json). Sistema.md 6 y 5.2.
const _ESCENARIO: String = "res://pruebas/fixtures/combate/escenario_rescate_combate.json"
const _TEXTOS: String = "res://pruebas/fixtures/pantalla/es_rasgos.json"
const _LEAL: String = "zancajunco_1"
const _NEUTRAL: String = "rodauva_1"
const _SALVAJE: String = "ocarra_s1"
const _TOPE_TURNOS: int = 10
# Copias textuales de datos/textos/es.json.
const _TEXTOS_ES: Dictionary = {
	"permadeath": "Nadie te llevó a casa.",
	"rescate.zancajunco": "Te arrastra de la capa entre las patas largas, mirando hacia atrás a cada paso.",
	"lealtad.motivo.rescate": "Te llevó a casa",
	"panel.lealtad": "Lealtad",
	"resultado.desenlace.derrota_por_caida": "Caíste",
}
# Textos de prueba de las claves propuestas.
const _TEXTOS_PRUEBA: Dictionary = {
	"panel.rescatista": "Te rescataría",
	"panel.sin_rescatista": "Nadie te rescataría",
	"marca.rescatista": "Te rescata",
	"resultado.rescatista": "Te rescató",
	"resultado.muertas": "Murieron",
	"resultado.causa.derrota_por_caida": "caíste",
	"resultado.levantadas": "Se levantaron",
	"resultado.caidas_guardadas": "Guardadas al caer",
	"resultado.capturas": "Capturas",
	"resultado.atacante_pendiente": "Atacante caída",
}

var _combate: Combate


# lealtad_leal: la lealtad de zancajunco_1 en el escenario (en memoria).
func _lectura(lealtad_leal: int = 7) -> LecturaCombate:
	var lectura: Dictionary = DatosFixture.cargar()
	assert_array(lectura["errores"]).is_empty()
	var datos: Dictionary = lectura["datos"]
	var textos: Dictionary = LectorFixture.leer(_TEXTOS, "textos")["datos"]
	textos.merge(_TEXTOS_ES, true)
	textos.merge(_TEXTOS_PRUEBA, true)
	var escenario: Dictionary = LectorFixture.leer(_ESCENARIO, "escenario")["datos"]
	for criatura: Dictionary in escenario["tribu"]:
		if criatura["id"] == _LEAL:
			criatura["lealtad"] = lealtad_leal
	var contexto: ContextoCombate = ContextoCombate.armar(escenario, datos)
	assert_bool(contexto.valido).is_true()
	_combate = Combate.empezar(contexto)
	assert_str(_combate.error()).is_empty()
	assert_bool(_combate.esperando_jugador()).is_true()
	assert_str(_combate.turno_actual().unidad_id).is_equal(_LEAL)
	return LecturaCombate.new(_combate, ArmadorTextos.desde_datos(textos, contexto.azar_textos),
			EstadosUnidad.desde_datos(datos["tablas/hambre.json"], datos["tablas/lealtad.json"]))


func _criatura(id_unidad: String) -> Criatura:
	return _combate.contexto().plantel.criatura(id_unidad)


# Las marcas de la ficha de la unidad ([] si no esta en el tablero).
func _marcas(lectura: LecturaCombate, id_unidad: String) -> Array:
	for ficha in lectura.fichas():
		if ficha["id"] == id_unidad:
			return ficha["marcas"]
	return []


# Esperar hasta el fin: la Ocarra remata al Maestro.
func _hasta_el_fin() -> void:
	for _i in range(_TOPE_TURNOS):
		if _combate.terminado():
			break
		assert_bool(_combate.aplicar(Accion.terminar()).valida).is_true()
	assert_int(_combate.fin()).is_equal(FinCombate.Fin.DERROTA_POR_CAIDA)


# (9) Al empezar: la linea nombra a la leal y solo su ficha lleva la marca.
func test_linea_y_marca_al_empezar() -> void:
	var lectura: LecturaCombate = _lectura()
	assert_str(lectura.linea_rescatista()).is_equal("Te rescataría: Zancajunco")
	assert_array(lectura.panel_turno()).contains(["Te rescataría: Zancajunco"])
	assert_array(_marcas(lectura, _LEAL)).contains(["Te rescata"])
	assert_array(_marcas(lectura, _NEUTRAL)).not_contains(["Te rescata"])
	assert_array(_marcas(lectura, Maestro.ID)).not_contains(["Te rescata"])


# (9) Cambia con la lealtad: la leal baja a 6 (menos que el umbral) y nadie
# rescata; la Rodauva sube a 7 y pasa a ser ella.
func test_cambia_con_la_lealtad() -> void:
	var lectura: LecturaCombate = _lectura()
	_criatura(_LEAL).lealtad = 6
	assert_str(lectura.linea_rescatista()).is_equal("Nadie te rescataría")
	assert_array(lectura.panel_turno()).contains(["Nadie te rescataría"])
	assert_array(_marcas(lectura, _LEAL)).not_contains(["Te rescata"])
	_criatura(_NEUTRAL).lealtad = 7
	assert_str(lectura.linea_rescatista()).is_equal("Te rescataría: Rodauva")
	assert_array(_marcas(lectura, _NEUTRAL)).contains(["Te rescata"])
	assert_array(_marcas(lectura, _LEAL)).not_contains(["Te rescata"])


# (9) Cambia si cae la candidata: con la Rodauva tambien en 7, el empate lo gana
# ella (mas cerca del Maestro: 4 contra 5); cae la Rodauva y pasa al Zancajunco;
# si ademas cae el Zancajunco, nadie.
func test_cambia_si_cae_la_candidata() -> void:
	var lectura: LecturaCombate = _lectura()
	_criatura(_NEUTRAL).lealtad = 7
	assert_str(lectura.linea_rescatista()).is_equal("Te rescataría: Rodauva")
	_criatura(_NEUTRAL).estado = Criatura.Estado.CAIDA
	assert_str(lectura.linea_rescatista()).is_equal("Te rescataría: Zancajunco")
	assert_array(_marcas(lectura, _NEUTRAL)).not_contains(["Te rescata"])
	assert_array(_marcas(lectura, _LEAL)).contains(["Te rescata"])
	_criatura(_LEAL).estado = Criatura.Estado.CAIDA
	assert_str(lectura.linea_rescatista()).is_equal("Nadie te rescataría")
	assert_array(_marcas(lectura, _LEAL)).not_contains(["Te rescata"])


# Fuera del turno del jugador (combate terminado): sin linea ni marca.
func test_sin_turno_del_jugador_no_se_muestra() -> void:
	var lectura: LecturaCombate = _lectura()
	_hasta_el_fin()
	assert_str(lectura.linea_rescatista()).is_empty()
	assert_array(_marcas(lectura, _LEAL)).not_contains(["Te rescata"])


# (9) Resultado con rescate: quien rescato, su linea de Mundo.md 9 y el +2 con
# su motivo en los cambios de lealtad.
func test_resultado_con_rescate() -> void:
	var lectura: LecturaCombate = _lectura()
	_hasta_el_fin()
	var lineas: Array[String] = lectura.resultado(_combate.resultado().a_diccionario())
	assert_array(lineas).contains(["Caíste", "Te rescató: Zancajunco", _TEXTOS_ES["rescate.zancajunco"],
			"  Te llevó a casa: +2"])
	assert_array(lineas).not_contains(["Nadie te llevó a casa."])


# (9) Resultado con permadeath: la leal en 6, nadie rescata.
func test_resultado_con_permadeath() -> void:
	var lectura: LecturaCombate = _lectura(6)
	_hasta_el_fin()
	var datos: Dictionary = _combate.resultado().a_diccionario()
	assert_bool(datos["permadeath"]).is_true()
	var lineas: Array[String] = lectura.resultado(datos)
	assert_array(lineas).contains(["Nadie te llevó a casa."])
	for linea in lineas:
		assert_str(linea).not_contains("Te rescató")


# (9) Resultado completo: sobre el diccionario real se completan los bloques que
# este combate no tiene (con ids de sus unidades) y cada uno sale: muertas con su
# causa (metrica 11), levantadas, caidas guardadas (metrica 10), capturas y la
# atacante pendiente. Sin listas, ningun bloque.
func test_resultado_completo() -> void:
	var lectura: LecturaCombate = _lectura()
	_hasta_el_fin()
	var datos: Dictionary = _combate.resultado().a_diccionario()
	var sin_bloques: Array[String] = lectura.resultado(datos)
	for titulo in ["Murieron", "Se levantaron", "Guardadas al caer", "Capturas", "Atacante caída"]:
		assert_array(sin_bloques).not_contains([titulo])
	datos["muertas"] = [_NEUTRAL]
	datos["metricas"]["muertes"] = [{"unidad": _NEUTRAL, "causa": "derrota_por_caida"}]
	datos["levantadas"] = [_LEAL]
	datos["metricas"]["caidas_guardadas"] = [{"unidad": _NEUTRAL, "ronda": 1}]
	datos["capturas"] = [{"unidad": _SALVAJE, "especie": "ocarra", "pergamino": "pergamino_1", "lealtad": 3}]
	datos["atacante_pendiente"] = _SALVAJE
	var lineas: Array[String] = lectura.resultado(datos)
	assert_array(lineas).contains(["Murieron", "Rodauva · Caíste", "Se levantaron", "Zancajunco",
			"Guardadas al caer", "Rodauva", "Capturas", "Ocarra · Lealtad: 3", "Atacante caída: Ocarra"])
