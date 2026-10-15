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


# T33, sesion 2: E a H, "todos" y "C y E", Sistema.md 11.9.
const _TODOS: Array = ["a_dia_1", "b_muro", "c_tasajero", "d_rivales_normal", "d_rivales_hambriento", "e_cobardia",
		"e_cobardia_afines", "f_rescate", "g_ataque_nocturno", "h_soplo"]
const _ESPERADAS_2: Dictionary = {
	"e_acobardadas": [["e_cobardia", "e_cobardia_afines"], "tasa_acobardadas_fuera",
			{"bando": "tribu", "desde_pct": 10, "hasta_pct": 60}],
	"e_toggle_afines": [["e_cobardia_afines"], "toggle_afines",
			{"comparado_con": "e_cobardia", "bando": "tribu", "supera_pct": 60, "desde_pct": 10, "hasta_pct": 60}],
	"f_rescate_azaroso": [["f_rescate"], "maestro_cae_sin_rescatista", {"umbral_pct": 60}],
	"f_guardar_no_se_lee": [["f_rescate"], "sin_caidas_guardadas", {"umbral_pct": 80}],
	"g_comer_siempre": [["g_ataque_nocturno"], "destino_atacante_proporcion", {"opciones": ["comer"], "umbral_pct": 70}],
	"h_mas_facil_que_c": [["h_soplo"], "victorias_diferencia", {"comparado_con": "c_tasajero", "umbral_puntos": 20}],
	"todos_maestro_se_esconde": [_TODOS, "distancia_maestro_mayor_que", {"umbral_decimas": 30, "umbral_pct": 50}],
	"todos_activa_erizarse": [_TODOS, "activa_poco_usada", {"efecto": "erizarse", "umbral_pct": 20}],
	"todos_activa_surco": [_TODOS, "activa_poco_usada", {"efecto": "surco", "umbral_pct": 20}],
	"todos_activa_ocultarse": [_TODOS, "activa_poco_usada", {"efecto": "ocultarse", "umbral_pct": 20}],
	"ce_encierro": [["c_tasajero", "e_cobardia", "e_cobardia_afines"], "encierro_de_efecto",
			{"efecto": "caza_y_cuenta", "umbral_pct": 20}],
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
	_cotejar(_ESPERADAS)


func test_umbrales_de_la_sesion_2() -> void:
	_cotejar(_ESPERADAS_2)
	# Las 16 filas de 11.9 son 20 alarmas: C y D hambriento llevan dos calculos
	# cada una, y las activas, una alarma por efecto. Ninguna de mas.
	assert_int((_alarmas()["alarmas"] as Array).size()).is_equal(_ESPERADAS.size() + _ESPERADAS_2.size())


func _cotejar(esperadas_por_id: Dictionary) -> void:
	var por_id: Dictionary = {}
	for alarma in (_alarmas()["alarmas"] as Array):
		por_id[alarma["id"]] = alarma
	for id in esperadas_por_id.keys():
		assert_bool(por_id.has(id)).override_failure_message(id).is_true()
		var esperada: Array = esperadas_por_id[id]
		var alarma: Dictionary = por_id[id]
		assert_array(alarma["escenarios"] as Array).override_failure_message(id).is_equal(esperada[0])
		assert_str(alarma["calculo"] as String).override_failure_message(id).is_equal(esperada[1])
		var parametros: Dictionary = (alarma["parametros"] as Dictionary).duplicate()
		parametros.erase("_nota")
		assert_dict(parametros).override_failure_message(id).is_equal(esperada[2])
