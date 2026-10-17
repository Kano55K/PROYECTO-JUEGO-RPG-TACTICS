extends GdUnitTestSuite

# Arquitectura.md B.4 (T26), criterio 1: la regla CostosMana con fixtures (A.6).
# Sistema.md 2.3: invocar 2 / 3 / 4 por rango, con el descuento de la balanza
# (balanza_1_2.json: 0 en la 2, 1 en la 3, 2 en la 5) y costo minimo 1. Sellar
# sigue igual: lo comprueba test_sellado.gd sin cambios.
const _CARPETA_UNIDADES: String = "res://pruebas/fixtures/unidades/"


func _maestro(balanza: int) -> Maestro:
	var tabla: TablaBalanza = TablaBalanza.new(LectorFixture.leer(_CARPETA_UNIDADES + "balanza_1_2.json",
			"balanza")["datos"])
	return Maestro.new(tabla, balanza)


func _especies() -> Dictionary:
	var resultado: Dictionary = {}
	for id_especie in ["rodauva", "surcon", "tasajero"]:
		resultado[id_especie] = Especie.new(LectorFixture.leer(_CARPETA_UNIDADES + id_especie + ".json",
				"especie")["datos"])
	return resultado


# (1) Balanza 2 (sin descuento): 2 / 3 / 4. Balanza 3 (descuento 1): 1 / 2 / 3.
# Balanza 5 (descuento 2): el rango 1 da 0 y sube al minimo (1); 1 / 2.
func test_invocar_por_rango_con_balanza_2_3_y_5() -> void:
	var costos: CostosMana = DatosFixture.costos_mana()
	var especies: Dictionary = _especies()
	# balanza -> [rango 1 (Rodauva), rango 2 (Surcon), rango 3 (Tasajero)].
	var casos: Dictionary = {2: [2, 3, 4], 3: [1, 2, 3], 5: [1, 1, 2]}
	for balanza: int in casos.keys():
		var esperados: Array = casos[balanza]
		var maestro: Maestro = _maestro(balanza)
		assert_int(costos.invocar(especies["rodauva"], maestro)).override_failure_message("balanza %d" % balanza) \
				.is_equal(esperados[0])
		assert_int(costos.invocar(especies["surcon"], maestro)).override_failure_message("balanza %d" % balanza) \
				.is_equal(esperados[1])
		assert_int(costos.invocar(especies["tasajero"], maestro)).override_failure_message("balanza %d" % balanza) \
				.is_equal(esperados[2])


# Sellar pasa por la misma cuenta: el Sellado delega en CostosMana.
func test_sellar_es_la_misma_cuenta() -> void:
	var costos: CostosMana = DatosFixture.costos_mana()
	var sellado: Sellado = DatosFixture.sellado()
	var especies: Dictionary = _especies()
	for balanza in [2, 3, 5]:
		for id_especie: String in especies.keys():
			assert_int(sellado.costo(especies[id_especie], _maestro(balanza))) \
					.is_equal(costos.sellar(especies[id_especie], _maestro(balanza)))


# A.2.2: sin un dato no hay regla (y el contexto no se arma: D-008).
func test_sin_un_dato_no_se_arma() -> void:
	var tabla: Dictionary = LectorFixture.leer("res://pruebas/fixtures/combate/costos_mana.json",
			"costos_mana")["datos"]
	assert_object(CostosMana.desde_datos(tabla)).is_not_null()
	for clave in ["sellar", "invocar", "guardar_caida", "resellar", "costo_minimo"]:
		var sin: Dictionary = tabla.duplicate(true)
		sin.erase(clave)
		assert_object(CostosMana.desde_datos(sin)).override_failure_message(clave).is_null()


# Arquitectura.md B.4 (T27), criterio 4: guardar a una caida con su fila propia
# (Sistema.md 2.3: 2 / 3 / 4, con descuento y minimo 1). Con la copia de 2.3 da
# lo mismo que invocar; con costos_mana_guardar_caida.json (fila inventada
# [1, 4, 6], distinta de invocar) se ve que no lee la de invocar. GuardadoCaida
# delega en la misma cuenta.
func test_guardar_caida_por_rango_con_balanza_2_3_y_5() -> void:
	var especies: Dictionary = _especies()
	var orden: Array[String] = ["rodauva", "surcon", "tasajero"]
	# archivo -> balanza -> [rango 1, rango 2, rango 3].
	var casos: Dictionary = {
		"costos_mana.json": {2: [2, 3, 4], 3: [1, 2, 3], 5: [1, 1, 2]},
		"costos_mana_guardar_caida.json": {2: [1, 4, 6], 3: [1, 3, 5], 5: [1, 2, 4]},
	}
	for archivo: String in casos.keys():
		var costos: CostosMana = DatosFixture.costos_mana(archivo)
		var regla: GuardadoCaida = DatosFixture.guardado_caida(archivo)
		for balanza: int in casos[archivo].keys():
			var maestro: Maestro = _maestro(balanza)
			for indice in range(orden.size()):
				var especie: Especie = especies[orden[indice]]
				var esperado: int = casos[archivo][balanza][indice]
				var mensaje: String = "%s, balanza %d, %s" % [archivo, balanza, orden[indice]]
				assert_int(costos.guardar_caida(especie, maestro)).override_failure_message(mensaje).is_equal(esperado)
				assert_int(regla.costo(especie, maestro)).override_failure_message(mensaje).is_equal(esperado)
	# La fila propia no es la de invocar: con el archivo inventado, el rango 2 difiere.
	var inventado: CostosMana = DatosFixture.costos_mana("costos_mana_guardar_caida.json")
	assert_int(inventado.guardar_caida(especies["surcon"], _maestro(2))) \
			.is_not_equal(inventado.invocar(especies["surcon"], _maestro(2)))
