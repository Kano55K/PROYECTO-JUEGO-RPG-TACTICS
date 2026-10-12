extends GdUnitTestSuite

# Arquitectura.md B.4 (T25), criterio 10: el % de huida en la ficha y el
# tooltip (Combate.porcentaje_huida), los sucesos del evento `huida` y las claves
# de ClavesTextos.usadas. Fixtures (A.6): escenario_huida_pantalla.json,
# es_rasgos.json y copias textuales de datos/textos/es.json. Los textos de la
# marca y del tooltip no existen en es.json: los de aca son de prueba.
# Sistema.md 11.7.
const _ESCENARIO: String = "res://pruebas/fixtures/pantalla/escenario_huida_pantalla.json"
const _TEXTOS: String = "res://pruebas/fixtures/pantalla/es_rasgos.json"
const _SURCON: String = "surcon_s1"
const _OCARRA: String = "ocarra_s1"
# Copias textuales de datos/textos/es.json v1.3.
const _TEXTOS_HUIDA: Dictionary = {
	"huida.salvaje.surcon": "Se mete a medias en la tierra y se va abriendo un surco, sin apuro.",
	"huida.salvaje.ocarra": "Se aleja a los graznidos, ofendida, sin darte del todo la espalda.",
}
# Textos de prueba de las claves propuestas (no estan en es.json).
const _TEXTOS_PRUEBA: Dictionary = {
	"marca.huida": "Huida",
	"huida.salvaje.porcentaje": "{porcentaje}% de que se vaya",
}

var _combate: Combate


func _datos() -> Dictionary:
	var lectura: Dictionary = DatosFixture.cargar()
	assert_array(lectura["errores"]).is_empty()
	return lectura["datos"]


func _lectura(extra: Dictionary = {}) -> LecturaCombate:
	var datos: Dictionary = _datos()
	var textos: Dictionary = LectorFixture.leer(_TEXTOS, "textos")["datos"]
	textos.merge(_TEXTOS_HUIDA, true)
	textos.merge(extra, true)
	var contexto: ContextoCombate = ContextoCombate.armar(LectorFixture.leer(_ESCENARIO, "escenario")["datos"], datos)
	assert_bool(contexto.valido).is_true()
	_combate = Combate.empezar(contexto)
	assert_str(_combate.error()).is_empty()
	return LecturaCombate.new(_combate, ArmadorTextos.desde_datos(textos, contexto.azar_textos),
			EstadosUnidad.desde_datos(datos["tablas/hambre.json"], datos["tablas/lealtad.json"]))


func _marcas(lectura: LecturaCombate, unidad_id: String) -> Array:
	for ficha in lectura.fichas():
		if ficha["id"] == unidad_id:
			return ficha["marcas"]
	return []


func _huida(unidad_id: String, resultado: String) -> Dictionary:
	return {"tipo": "huida", "unidad": unidad_id, "porcentaje": 25, "tiro": 10, "resultado": resultado,
			"n": 1, "ronda": 1}


# (10) La marca de la ficha lleva el % de porcentaje_huida; sin marca con 0 %
# (la Ocarra, aunque este en 1 de 12) ni en la tribu. Sin el texto de la clave,
# [FALTA] y el numero igual.
func test_marca_en_la_ficha() -> void:
	var lectura: LecturaCombate = _lectura(_TEXTOS_PRUEBA)
	assert_int(_combate.porcentaje_huida(_SURCON)).is_equal(25)
	assert_array(_marcas(lectura, _SURCON)).contains(["Huida 25%"])
	assert_int(_combate.porcentaje_huida(_OCARRA)).is_equal(0)
	for unidad_id in [_OCARRA, "rodauva_1", Maestro.ID]:
		for marca in _marcas(lectura, unidad_id):
			assert_str(marca as String).override_failure_message(unidad_id).not_contains("Huida")
	assert_array(_marcas(_lectura(), _SURCON)).contains(["[FALTA: marca.huida] 25%"])


# (10) El tooltip de la salvaje lleva huida.salvaje.porcentaje con el mismo %; el
# de la Ocarra (0 %) no.
func test_linea_en_el_tooltip() -> void:
	var lectura: LecturaCombate = _lectura(_TEXTOS_PRUEBA)
	assert_array(lectura.tooltip_unidad(_SURCON)).contains(["25% de que se vaya"])
	assert_array(lectura.tooltip_unidad(_OCARRA)).not_contains(["0% de que se vaya"])
	for linea in lectura.tooltip_unidad(_OCARRA):
		assert_str(linea).not_contains("de que se vaya")


# (10) Huye: la linea de su especie (huida.salvaje.<especie>).
func test_suceso_huye() -> void:
	var lectura: LecturaCombate = _lectura()
	assert_array(lectura.suceso(_huida(_SURCON, Huida.RESULTADO_HUYE))).is_equal(
			["Se mete a medias en la tierra y se va abriendo un surco, sin apuro."])
	assert_array(lectura.suceso(_huida(_OCARRA, Huida.RESULTADO_HUYE))).is_equal(
			["Se aleja a los graznidos, ofendida, sin darte del todo la espalda."])


# (10) Se queda: sin linea si no existe la clave; con ella (texto de prueba), su
# linea, y la variante de la especie si la hay.
func test_suceso_se_queda() -> void:
	assert_array(_lectura().suceso(_huida(_SURCON, Huida.RESULTADO_SE_QUEDA))).is_empty()
	var con_texto: LecturaCombate = _lectura({"huida.salvaje.se_queda": "Se queda.",
			"huida.salvaje.se_queda.ocarra": "No se va."})
	assert_array(con_texto.suceso(_huida(_SURCON, Huida.RESULTADO_SE_QUEDA))).is_equal(["Se queda."])
	assert_array(con_texto.suceso(_huida(_OCARRA, Huida.RESULTADO_SE_QUEDA))).is_equal(["No se va."])
	var solo_variante: LecturaCombate = _lectura({"huida.salvaje.se_queda.ocarra": "No se va."})
	assert_array(solo_variante.suceso(_huida(_OCARRA, Huida.RESULTADO_SE_QUEDA))).is_equal(["No se va."])
	assert_array(solo_variante.suceso(_huida(_SURCON, Huida.RESULTADO_SE_QUEDA))).is_empty()


# Criterio 8 del prompt: usadas suma la marca y el tooltip (fijas, como las
# faltantes de T24) y las variantes de huida que existen; nunca la base
# huida.salvaje (no tiene texto) ni las variantes que no estan.
func test_claves_usadas() -> void:
	var datos: Dictionary = _datos()
	var textos: Dictionary = LectorFixture.leer(_TEXTOS, "textos")["datos"]
	textos.merge(_TEXTOS_HUIDA, true)
	datos["textos/es.json"] = textos
	var claves: Array[String] = ClavesTextos.usadas(datos)
	assert_array(claves).contains([ClavesTextos.MARCA_HUIDA, ClavesTextos.HUIDA_PORCENTAJE,
			"huida.salvaje.surcon", "huida.salvaje.ocarra"])
	assert_array(claves).not_contains(["huida.salvaje", "huida.salvaje.rodauva", ClavesTextos.HUIDA_SE_QUEDA])
	textos["huida.salvaje.se_queda"] = "Se queda."
	assert_array(ClavesTextos.usadas(datos)).contains([ClavesTextos.HUIDA_SE_QUEDA])
