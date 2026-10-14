extends GdUnitTestSuite

# T33, sesion 1, criterio (1), con datos/ real: datos/ carga sin errores con
# playtest/alarmas.json y cada alarma lleva los numeros de Sistema.md 11.9
# ("Como se mide" y "Umbrales de alarma"). Los numeros estan aca porque este
# test es la comprobacion; la tabla de cotejo va en el resumen de la sesion.
const _CARPETA_DATOS: String = "res://datos"
const _ARCHIVO: String = "playtest/alarmas.json"

# id -> [escenarios, calculo, parametros], Sistema.md 11.9.
const _ESPERADAS: Dictionary = {
	"a_mismo_tramo": [["a_dia_1"], "primer_sellado_mismo_tramo", {"umbral_pct": 80}],
	"b_huir_no_se_lee": [["b_muro"], "desenlace_proporcion",
			{"desenlaces": ["huida", "victoria"], "comparacion": "menor_que", "umbral_pct": 30}],
	"c_rondas_largas": [["c_tasajero"], "rondas_pelea_mayor_que", {"rondas": 5, "umbral_pct": 20}],
	"c_rondas_promedio": [["c_tasajero"], "rondas_pelea_promedio_fuera", {"desde_decimas": 20, "hasta_decimas": 35}],
	"c_rodauva_muere": [["c_tasajero"], "muere_si_empezo_suelta", {"especie": "rodauva", "umbral_pct": 50}],
	"d_rivales_invisibles": [["d_rivales_normal"], "combates_con_incidente", {"bando": "tribu", "umbral_pct": 20}],
	"d_castigo_derrota": [["d_rivales_hambriento"], "desenlace_proporcion",
			{"desenlaces": ["derrota_por_caida"], "comparacion": "mayor_que", "umbral_pct": 50}],
	"d_castigo_golpes": [["d_rivales_hambriento"], "golpes_incidente_promedio", {"bando": "tribu", "umbral_decimas": 30}],
	"h_build_trampa": [["h_soplo"], "desenlace_proporcion",
			{"desenlaces": ["victoria"], "comparacion": "menor_que", "umbral_pct": 20}],
}


func _alarmas() -> Dictionary:
	var resultado: Dictionary = Cargador.new().cargar_carpeta(_CARPETA_DATOS)
	var errores: Array[Dictionary] = resultado["errores"]
	assert_array(errores).override_failure_message(str(errores)).is_empty()
	return (resultado["datos"] as Dictionary)[_ARCHIVO]


func test_como_se_mide() -> void:
	var alarmas: Dictionary = _alarmas()
	assert_int(alarmas["partidas_por_grupo"] as int).is_equal(10)
	assert_int(alarmas["jugadores_minimos"] as int).is_equal(3)
	var semillas: Array = alarmas["semillas"]
	assert_int(semillas.size()).is_equal(10)
	# Distintas de las semillas de los escenarios.
	var datos: Dictionary = Cargador.new().cargar_carpeta(_CARPETA_DATOS)["datos"]
	for ruta in datos.keys():
		if (ruta as String).begins_with("escenarios/"):
			assert_bool(semillas.has((datos[ruta] as Dictionary)["semilla"])).override_failure_message(ruta).is_false()


func test_umbrales_de_la_sesion_1() -> void:
	var por_id: Dictionary = {}
	for alarma in (_alarmas()["alarmas"] as Array):
		por_id[alarma["id"]] = alarma
	for id in _ESPERADAS.keys():
		assert_bool(por_id.has(id)).override_failure_message(id).is_true()
		var esperada: Array = _ESPERADAS[id]
		var alarma: Dictionary = por_id[id]
		assert_array(alarma["escenarios"] as Array).override_failure_message(id).is_equal(esperada[0])
		assert_str(alarma["calculo"] as String).override_failure_message(id).is_equal(esperada[1])
		var parametros: Dictionary = (alarma["parametros"] as Dictionary).duplicate()
		parametros.erase("_nota")
		assert_dict(parametros).override_failure_message(id).is_equal(esperada[2])
