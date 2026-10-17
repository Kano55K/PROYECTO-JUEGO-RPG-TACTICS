extends GdUnitTestSuite

# Arquitectura.md B.3 (T44), criterios 5 y 6, con fixtures (A.6, D-009):
# - Sistema.md 10.6 v1.7 (P-040): con el toggle de afines, la cobardia es
#   max(sin_afines - afines, min(sin_afines, minimo_pct)). El piso no la sube.
# - Arquitectura.md A.7 (T44) y Mundo.md 9.2 v1.3: el chequeo resistido trae
#   sostenida_por (maestro / afin / null) y, con afin, cual (P-041).
# Las bases que no estan en los fixtures (3 % y 12 %) salen de una copia en
# memoria de combate.json: pruebas/fixtures/ no cambia. Con la balanza 2 (3 pasos
# de Arrimo, -15) y la Rodauva leal (-20), sin_afines = base - 35.
const _CARPETA: String = "res://pruebas/fixtures/combate/"
const _CARPETA_UNIDADES: String = "res://pruebas/fixtures/unidades/"
const _ESPECIES: Array[String] = ["ocarra", "rodauva", "surcon", "tasajero", "zancajunco"]
const _BASE: String = "combate.json"
const _BASE_100: String = "combate_rival_100.json"
# Con la semilla 1, la primera tirada da 98: con 97 % o menos, resiste.
const _SEMILLA_RESISTE: int = 1


func _leer(ruta: String, nombre_esquema: String) -> Dictionary:
	var lectura: Dictionary = LectorFixture.leer(ruta, nombre_esquema)
	var errores: Array[Dictionary] = lectura["errores"]
	assert_array(errores).override_failure_message(str(errores)).is_empty()
	return lectura["datos"]


# El plantel de escenario_rival.json (balanza 2) con las posiciones de `ubicar`.
# La Rodauva que tira es leal; el Maestro queda estacionado salvo que se ubique.
func _plantel(ubicar: Dictionary) -> Plantel:
	var especies: Dictionary = {}
	for id_especie in _ESPECIES:
		especies[id_especie] = Especie.new(_leer(_CARPETA_UNIDADES + id_especie + ".json", "especie"))
	var tabla: TablaBalanza = TablaBalanza.new(_leer(_CARPETA_UNIDADES + "balanza_1_2.json", "balanza"))
	var plantel: Plantel = Plantel.desde_escenario(_leer(_CARPETA + "escenario_rival.json", "escenario"), especies,
			tabla, _leer(_CARPETA_UNIDADES + "maestro.json", "maestro"))
	plantel.maestro.balanza = 2
	for id_unidad in ubicar.keys():
		if id_unidad == Maestro.ID:
			plantel.maestro.posicion = ubicar[id_unidad]
		else:
			plantel.criatura(id_unidad).posicion = ubicar[id_unidad]
	plantel.criatura("rodauva_1").lealtad = 8
	plantel.criatura("rodauva_1").hambre = 3
	return plantel


# El ChequeoRival de los fixtures, con otra base de cobardia si base_pct >= 0.
func _chequeo(toggle: bool, base_pct: int = -1, combate: String = _BASE) -> ChequeoRival:
	var datos: Dictionary = DatosFixture.cargar(combate)["datos"]
	var tabla_combate: Dictionary = (datos["tablas/combate.json"] as Dictionary).duplicate(true)
	if base_pct >= 0:
		tabla_combate["cobardia"]["base_pct"] = base_pct
	var obediencia: Obediencia = Obediencia.desde_datos(datos["tablas/hambre.json"], datos["tablas/lealtad.json"],
			tabla_combate)
	var relaciones: Relaciones = Relaciones.new(datos["relaciones.json"])
	return ChequeoRival.desde_datos(tabla_combate, Arrimo.desde_datos(datos["tablas/arrimo.json"]), relaciones,
			obediencia, Afinidad.desde_datos(tabla_combate, relaciones, obediencia), toggle)


func _pct(chequeo: ChequeoRival, plantel: Plantel) -> int:
	return chequeo.consulta("rodauva_1", plantel.criatura("rodauva_1").posicion, plantel)["porcentaje"]


# (5a) Sistema.md 10.6 v1.7: sin afines vecinas, el toggle no cambia nada. Con la
# base de 60 da 25 con y sin el toggle; con una base de 38 (sin_afines 3 %), 3
# con y sin el toggle (antes de P-040, el toggle la subia a 5).
func test_toggle_sin_afines_no_cambia_nada() -> void:
	var plantel: Plantel = _plantel({"rodauva_1": Vector2i(3, 3), "tasajero_s1": Vector2i(3, 7)})
	assert_int(_pct(_chequeo(true), plantel)).is_equal(25)
	assert_int(_pct(_chequeo(false), plantel)).is_equal(25)
	assert_int(_pct(_chequeo(true, 38), plantel)).is_equal(3)
	assert_int(_pct(_chequeo(false, 38), plantel)).is_equal(3)


# (5b) Sistema.md 10.6 v1.7: con una base que ya esta por debajo del piso (3 %),
# una afin vecina no la sube a 5 ni la baja: queda en 3.
func test_piso_no_sube_la_cobardia() -> void:
	var plantel: Plantel = _plantel({"rodauva_1": Vector2i(3, 3), "rodauva_2": Vector2i(2, 3),
			"tasajero_s1": Vector2i(3, 7)})
	assert_int(_pct(_chequeo(true, 38), plantel)).is_equal(3)


# (5c) Sistema.md 10.6 v1.7: con afines, nunca baja del piso. Con 12 % y dos
# afines (-20) da 5, no -8; con 25 % y dos afines, 5; con una sola, 15.
func test_con_afines_nunca_baja_del_piso() -> void:
	var plantel: Plantel = _plantel({"rodauva_1": Vector2i(3, 3), "rodauva_2": Vector2i(2, 3),
			"rodauva_3": Vector2i(4, 4), "tasajero_s1": Vector2i(3, 7)})
	assert_int(_pct(_chequeo(true, 47), plantel)).is_equal(5)
	assert_int(_pct(_chequeo(true), plantel)).is_equal(5)
	plantel.criatura("rodauva_3").posicion = Vector2i(0, 6)
	assert_int(_pct(_chequeo(true), plantel)).is_equal(15)


# (6) A.7 (T44): resistida con el Maestro vecino (en diagonal), sin el toggle:
# 15 %, sostenida por el Maestro y sin `afin`.
func test_sostenida_por_el_maestro() -> void:
	var plantel: Plantel = _plantel({"rodauva_1": Vector2i(3, 3), Maestro.ID: Vector2i(2, 2),
			"tasajero_s1": Vector2i(3, 7)})
	var tirado: Dictionary = _chequeo(false).tirar("rodauva_1", plantel, GeneradorAzar.new(_SEMILLA_RESISTE))
	assert_str(tirado["resultado"]).is_equal(ChequeoRival.RESULTADO_RESISTIDA)
	assert_int(tirado["porcentaje"]).is_equal(15)
	assert_dict(tirado).contains_key_value("sostenida_por", ChequeoRival.SOSTENIDA_MAESTRO)
	assert_bool(tirado.has("afin")).is_false()


# (6) A.7 (T44) y P-041: con el toggle y una afin vecina en diagonal, sin el
# Maestro: 15 %, sostenida por una afin, y `afin` dice cual.
func test_sostenida_por_una_afin() -> void:
	var plantel: Plantel = _plantel({"rodauva_1": Vector2i(3, 3), "rodauva_2": Vector2i(4, 4),
			"tasajero_s1": Vector2i(3, 7)})
	var tirado: Dictionary = _chequeo(true).tirar("rodauva_1", plantel, GeneradorAzar.new(_SEMILLA_RESISTE))
	assert_str(tirado["resultado"]).is_equal(ChequeoRival.RESULTADO_RESISTIDA)
	assert_int(tirado["porcentaje"]).is_equal(15)
	assert_dict(tirado).contains_key_value("sostenida_por", ChequeoRival.SOSTENIDA_AFIN) \
			.contains_key_value("afin", "rodauva_2")


# (6) A.7 (T44) y P-041: con dos afines, `afin` es la primera en el orden del
# Plantel (rodauva_2 antes que rodauva_3), aunque en el diccionario de posiciones
# vaya despues.
func test_afin_es_la_primera_del_plantel() -> void:
	var plantel: Plantel = _plantel({"rodauva_1": Vector2i(3, 3), "rodauva_3": Vector2i(2, 3),
			"rodauva_2": Vector2i(4, 4), "tasajero_s1": Vector2i(3, 7)})
	var tirado: Dictionary = _chequeo(true).tirar("rodauva_1", plantel, GeneradorAzar.new(_SEMILLA_RESISTE))
	assert_str(tirado["resultado"]).is_equal(ChequeoRival.RESULTADO_RESISTIDA)
	assert_dict(tirado).contains_key_value("afin", "rodauva_2")


# (6) A.7 (T44): con el Maestro y una afin (toggle), gana el Maestro: 5 %.
func test_maestro_y_afin_gana_el_maestro() -> void:
	var plantel: Plantel = _plantel({"rodauva_1": Vector2i(3, 3), Maestro.ID: Vector2i(3, 2),
			"rodauva_2": Vector2i(2, 3), "tasajero_s1": Vector2i(3, 7)})
	var tirado: Dictionary = _chequeo(true).tirar("rodauva_1", plantel, GeneradorAzar.new(_SEMILLA_RESISTE))
	assert_str(tirado["resultado"]).is_equal(ChequeoRival.RESULTADO_RESISTIDA)
	assert_int(tirado["porcentaje"]).is_equal(5)
	assert_dict(tirado).contains_key_value("sostenida_por", ChequeoRival.SOSTENIDA_MAESTRO)
	assert_bool(tirado.has("afin")).is_false()


# (6) A.7 (T44): sin Maestro vecino ni afines (con el toggle), la clave va en null.
# Una afin vecina sin el toggle no sostiene.
func test_sin_nadie_es_null() -> void:
	var sola: Plantel = _plantel({"rodauva_1": Vector2i(3, 3), "tasajero_s1": Vector2i(3, 7)})
	var tirado: Dictionary = _chequeo(true).tirar("rodauva_1", sola, GeneradorAzar.new(_SEMILLA_RESISTE))
	assert_str(tirado["resultado"]).is_equal(ChequeoRival.RESULTADO_RESISTIDA)
	assert_bool(tirado.has("sostenida_por")).is_true()
	assert_object(tirado["sostenida_por"]).is_null()
	assert_bool(tirado.has("afin")).is_false()

	var con_afin: Plantel = _plantel({"rodauva_1": Vector2i(3, 3), "rodauva_2": Vector2i(2, 3),
			"tasajero_s1": Vector2i(3, 7)})
	tirado = _chequeo(false).tirar("rodauva_1", con_afin, GeneradorAzar.new(_SEMILLA_RESISTE))
	assert_str(tirado["resultado"]).is_equal(ChequeoRival.RESULTADO_RESISTIDA)
	assert_object(tirado["sostenida_por"]).is_null()


# (6) A.7 (T44): en acobardada, enconada y no_enconada la clave no va, aunque el
# Maestro sea vecino (salvo en la acobardada, que lo necesita lejos para dar 100 %).
# Acobardada y enconada con combate_rival_100.json (balanza 5, tramo neutral);
# no_enconada con la Ocarra neutral al 25 % y la semilla 1 (98).
func test_otros_resultados_sin_la_clave() -> void:
	var acobardada: Plantel = _plantel({"rodauva_1": Vector2i(3, 3),
			"tasajero_s1": Vector2i(3, 7)})
	acobardada.maestro.balanza = 5
	acobardada.criatura("rodauva_1").lealtad = 5
	var tirado: Dictionary = _chequeo(false, -1, _BASE_100).tirar("rodauva_1", acobardada, GeneradorAzar.new(1))
	assert_str(tirado["resultado"]).is_equal(ChequeoRival.RESULTADO_ACOBARDADA)
	assert_bool(tirado.has("sostenida_por")).is_false()
	assert_bool(tirado.has("afin")).is_false()

	var encono: Plantel = _plantel({"ocarra_1": Vector2i(3, 3), Maestro.ID: Vector2i(3, 2),
			"ocarra_s1": Vector2i(3, 6)})
	encono.maestro.balanza = 5
	tirado = _chequeo(false, -1, _BASE_100).tirar("ocarra_1", encono, GeneradorAzar.new(1))
	assert_str(tirado["resultado"]).is_equal(ChequeoRival.RESULTADO_ENCONADA)
	assert_bool(tirado.has("sostenida_por")).is_false()
	tirado = _chequeo(false).tirar("ocarra_1", encono, GeneradorAzar.new(1))
	assert_str(tirado["resultado"]).is_equal(ChequeoRival.RESULTADO_NO_ENCONADA)
	assert_bool(tirado.has("sostenida_por")).is_false()
