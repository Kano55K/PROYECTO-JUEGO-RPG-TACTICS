extends GdUnitTestSuite

# Arquitectura.md B.4 (T30, sesion 2), criterio 11 y apoyos: las cuentas del
# destino de la atacante con fixtures (A.6), sin Combate. Sistema.md 2.3 y 4.4:
# resellar cuesta su fila de costos_mana.json con el descuento de la balanza
# (balanza_1_2.json: 0 en la 2, 1 en la 3, 2 en la 5) y minimo 1; tira con el
# primer tramo (<= 25 %) de su rango; vuelve con la lealtad al resellar mas el
# ajuste de la balanza (0 / -1 / -2), nunca menos de 0. 5.2: un solo recorte.
const _CARPETA_UNIDADES: String = "res://pruebas/fixtures/unidades/"
const _CARPETA_COMBATE: String = "res://pruebas/fixtures/combate/"


func _maestro(balanza: int) -> Maestro:
	var tabla: TablaBalanza = TablaBalanza.new(LectorFixture.leer(_CARPETA_UNIDADES + "balanza_1_2.json",
			"balanza")["datos"])
	return Maestro.new(tabla, balanza)


func _especie(id_especie: String) -> Especie:
	return Especie.new(LectorFixture.leer(_CARPETA_UNIDADES + id_especie + ".json", "especie")["datos"])


func _destino(costos: String = "costos_mana.json") -> DestinoAtacante:
	return DatosFixture.destino_atacante(costos)


# (11) Con su fila propia (2 / 4 / 5, distinta de invocar): balanza 2 sin
# descuento; 3, con 1; 5, con 2, y el rango 1 sube al minimo (1).
func test_costo_de_resellar_con_balanza_2_3_y_5() -> void:
	var destino: DestinoAtacante = _destino("costos_mana_resellar.json")
	var costos: CostosMana = DatosFixture.costos_mana("costos_mana_resellar.json")
	# balanza -> [rango 1 (Ocarra), rango 2 (Surcon), rango 3 (Tasajero)].
	var casos: Dictionary = {2: [2, 4, 5], 3: [1, 3, 4], 5: [1, 2, 3]}
	for balanza: int in casos.keys():
		var esperados: Array = casos[balanza]
		var maestro: Maestro = _maestro(balanza)
		var indice: int = 0
		for id_especie in ["ocarra", "surcon", "tasajero"]:
			assert_int(destino.costo(_especie(id_especie), maestro)) \
					.override_failure_message("balanza %d, %s" % [balanza, id_especie]).is_equal(esperados[indice])
			assert_int(costos.resellar(_especie(id_especie), maestro)).is_equal(esperados[indice])
			indice += 1
	# No es la fila de invocar (2 / 3 / 4).
	assert_int(costos.invocar(_especie("surcon"), _maestro(2))).is_equal(3)


# (11) 4.4: el primer tramo (vida <= 25 %) de su rango: 80 / 65 / 50.
func test_porcentaje_del_primer_tramo() -> void:
	var destino: DestinoAtacante = _destino()
	assert_int(destino.porcentaje(_especie("ocarra"))).is_equal(80)
	assert_int(destino.porcentaje(_especie("surcon"))).is_equal(65)
	assert_int(destino.porcentaje(_especie("tasajero"))).is_equal(50)


# (11) 4.4: lealtad 1 con el ajuste de la balanza (0, -1, -2), nunca menos de 0.
# La vida, la de combate.json (P-046; el fixture lleva 1, D-009).
func test_lealtad_y_vida_al_resellar() -> void:
	var destino: DestinoAtacante = _destino()
	assert_int(destino.lealtad_resellar(_maestro(2))).is_equal(1)
	assert_int(destino.lealtad_resellar(_maestro(3))).is_equal(0)
	assert_int(destino.lealtad_resellar(_maestro(5))).is_equal(0)
	assert_int(destino.vida()).is_equal(1)


# A.2.2: sin un dato no hay regla (y el contexto no se arma).
func test_sin_un_dato_no_se_arma() -> void:
	var datos: Dictionary = DatosFixture.cargar()["datos"]
	var costos: CostosMana = DatosFixture.costos_mana()
	var sellado: Sellado = DatosFixture.sellado()
	var combate: Dictionary = datos["tablas/combate.json"]
	var lealtad: Dictionary = datos["tablas/lealtad.json"]
	assert_object(DestinoAtacante.desde_datos(combate, lealtad, costos, sellado)).is_not_null()
	assert_object(DestinoAtacante.desde_datos(combate, lealtad, null, sellado)).is_null()
	assert_object(DestinoAtacante.desde_datos(combate, lealtad, costos, null)).is_null()
	var sin_vida: Dictionary = combate.duplicate(true)
	sin_vida.erase("vida_al_resellar")
	assert_object(DestinoAtacante.desde_datos(sin_vida, lealtad, costos, sellado)).is_null()
	for evento in ["perdon_a_leales", "comer_atacante"]:
		var sin_evento: Dictionary = lealtad.duplicate(true)
		(sin_evento["eventos"] as Dictionary).erase(evento)
		assert_object(DestinoAtacante.desde_datos(combate, sin_evento, costos, sellado)).is_null()
	# La fila de resellar es obligatoria en CostosMana y la lealtad al resellar, en el Sellado.
	var tabla_costos: Dictionary = LectorFixture.leer(_CARPETA_COMBATE + "costos_mana.json", "costos_mana")["datos"]
	tabla_costos.erase("resellar")
	assert_object(CostosMana.desde_datos(tabla_costos)).is_null()
	var sin_resellar: Dictionary = lealtad.duplicate(true)
	sin_resellar.erase("resellar")
	assert_object(Sellado.desde_datos(datos["tablas/sellado.json"], costos, sin_resellar, combate)).is_null()


# 5.2 (S-65): calcular da lo mismo que aplicar sin escribir nada; con extra suma
# esas anotaciones sin guardarlas.
func test_acumulador_calcula_sin_aplicar() -> void:
	var criatura: Criatura = Criatura.new("rodauva_1", _especie("rodauva"), Criatura.Bando.TRIBU)
	criatura.lealtad = 10
	var acumulador: AcumuladorLealtad = AcumuladorLealtad.new(0, 10)
	acumulador.anotar(criatura.id, 1, "victoria")
	var extra: Array[AnotacionLealtad] = [AnotacionLealtad.new(criatura.id, -2, "comer_atacante")]
	var calculados: Array[CambioLealtad] = acumulador.calcular([criatura], extra)
	assert_int(calculados[0].despues).is_equal(9)
	assert_int(calculados[0].anotaciones.size()).is_equal(2)
	assert_int(criatura.lealtad).is_equal(10)
	# Sin el extra, solo la victoria (recortada a 10); el extra no quedo anotado.
	assert_int(acumulador.calcular([criatura])[0].despues).is_equal(10)
	var aplicados: Array[CambioLealtad] = acumulador.aplicar([criatura])
	assert_int(aplicados[0].despues).is_equal(10)
	assert_int(criatura.lealtad).is_equal(10)
