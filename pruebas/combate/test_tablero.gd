extends GdUnitTestSuite

# Arquitectura.md B.2 (T06): tablero y geometria, con fixtures (A.6).
# Sistema.md 11.3 (Tablero, Movimiento, Distancias, Despliegue, Adyacencia y Alcance 2).
const _CARPETA: String = "res://pruebas/fixtures/combate/"
const _CARPETA_UNIDADES: String = "res://pruebas/fixtures/unidades/"
const _ESPECIES: Array[String] = ["ocarra", "rodauva", "zancajunco"]

const TRIBU: Criatura.Bando = Criatura.Bando.TRIBU
const ENEMIGA: Criatura.Bando = Criatura.Bando.ENEMIGA


func _leer(ruta: String, nombre_esquema: String) -> Dictionary:
	var lectura: Dictionary = LectorFixture.leer(ruta, nombre_esquema)
	var errores: Array[Dictionary] = lectura["errores"]
	assert_array(errores).override_failure_message(str(errores)).is_empty()
	return lectura["datos"]


func _escenario(nombre: String) -> Dictionary:
	return _leer(_CARPETA + "escenario_" + nombre + ".json", "escenario")


func _plantel(escenario: Dictionary) -> Plantel:
	var especies: Dictionary = {}
	for id_especie in _ESPECIES:
		especies[id_especie] = Especie.new(_leer(_CARPETA_UNIDADES + id_especie + ".json", "especie"))
	var tabla: TablaBalanza = TablaBalanza.new(_leer(_CARPETA_UNIDADES + "balanza_1_2.json", "balanza"))
	return Plantel.desde_escenario(escenario, especies, tabla, _leer(_CARPETA_UNIDADES + "maestro.json", "maestro"))


func _tablero(escenario: Dictionary) -> Tablero:
	return Tablero.desde_datos(escenario["tablero"], _leer(_CARPETA + "combate.json", "combate"))


# Manhattan
func test_distancia_manhattan() -> void:
	assert_int(Tablero.distancia(Vector2i(0, 0), Vector2i(3, 4))).is_equal(7)
	assert_int(Tablero.distancia(Vector2i(3, 4), Vector2i(0, 0))).is_equal(7)
	assert_int(Tablero.distancia(Vector2i(3, 7), Vector2i(3, 5))).is_equal(2)
	# Una diagonal vale 2, no 1.
	assert_int(Tablero.distancia(Vector2i(3, 3), Vector2i(4, 4))).is_equal(2)


# Adyacencia: 4 ortogonales; la diagonal no es adyacente.
func test_diagonal_no_es_adyacente() -> void:
	var tablero: Tablero = Tablero.new(8, 8, 2)
	assert_array(tablero.vecinas(Vector2i(3, 3))).contains_exactly_in_any_order([
		Vector2i(3, 2), Vector2i(2, 3), Vector2i(4, 3), Vector2i(3, 4)])
	assert_bool(tablero.adyacentes(Vector2i(3, 3), Vector2i(4, 3))).is_true()
	assert_bool(tablero.adyacentes(Vector2i(3, 3), Vector2i(4, 4))).is_false()
	assert_bool(tablero.adyacentes(Vector2i(3, 3), Vector2i(3, 3))).is_false()


# Una enemiga en el camino obliga a rodear, y el rodeo cuesta pasos.
func test_rodear_a_una_enemiga_cuesta_pasos() -> void:
	var escenario: Dictionary = _escenario("rodeo")
	var plantel: Plantel = _plantel(escenario)
	var tablero: Tablero = _tablero(escenario)
	var desde: Vector2i = plantel.criatura("rodauva_1").posicion
	var destino: Vector2i = Vector2i(3, 5)
	assert_int(Tablero.distancia(desde, destino)).is_equal(2)

	# En linea recta serian 2 pasos; rodeando a la Ocarra en [3,6] son 4.
	assert_array(tablero.alcanzables(desde, 3, TRIBU, plantel, Surcos.new(), false)).not_contains([destino])
	assert_array(tablero.alcanzables(desde, 4, TRIBU, plantel, Surcos.new(), false)).contains([destino])
	assert_array(tablero.alcanzables(desde, 4, TRIBU, plantel, Surcos.new(), false)).not_contains([Vector2i(3, 6)])


# Se atraviesa a una aliada y a una caida propia, pero no se termina encima.
func test_atraviesa_aliada_y_caida_propia() -> void:
	var escenario: Dictionary = _escenario("atravesar")
	var plantel: Plantel = _plantel(escenario)
	plantel.criatura("rodauva_1").estado = Criatura.Estado.CAIDA
	var tablero: Tablero = _tablero(escenario)
	var zancajunco: Criatura = plantel.criatura("zancajunco_1")

	var alcanzables: Array[Vector2i] = tablero.alcanzables(zancajunco.posicion, zancajunco.especie.movimiento(), TRIBU, plantel, Surcos.new(), false)
	# Del otro lado del Maestro [3,6] y de la caida [3,5].
	assert_array(alcanzables).contains([Vector2i(3, 4), Vector2i(3, 3)])
	assert_array(alcanzables).not_contains([Vector2i(3, 6), Vector2i(3, 5)])
	# Quedarse quieto: 0 pasos.
	assert_array(alcanzables).contains([zancajunco.posicion])


# Una enemiga en un pasillo hace de muro; una aliada en el mismo lugar no.
func test_enemiga_en_pasillo_hace_de_muro() -> void:
	var escenario: Dictionary = _escenario("pasillo_enemiga")
	var plantel: Plantel = _plantel(escenario)
	var tablero: Tablero = _tablero(escenario)
	for casilla in tablero.alcanzables(Vector2i(1, 4), 4, TRIBU, plantel, Surcos.new(), false):
		assert_int(casilla.y).override_failure_message(str(casilla)).is_greater(2)

	var escenario_aliada: Dictionary = _escenario("pasillo_aliada")
	var plantel_aliada: Plantel = _plantel(escenario_aliada)
	var alcanzables: Array[Vector2i] = _tablero(escenario_aliada).alcanzables(Vector2i(1, 4), 4, TRIBU, plantel_aliada, Surcos.new(), false)
	assert_array(alcanzables).contains([Vector2i(1, 1), Vector2i(1, 0)])


# Alcance 2: la Ocarra pega a distancia 2 en linea por encima de una aliada.
func test_ocarra_pega_por_encima_de_una_aliada() -> void:
	var escenario: Dictionary = _escenario("alcance")
	var plantel: Plantel = _plantel(escenario)
	var tablero: Tablero = _tablero(escenario)
	var ocarra: Criatura = plantel.criatura("ocarra_1")
	assert_int(ocarra.especie.alcance()).is_equal(2)

	var golpeables: Array[Vector2i] = tablero.golpeables(ocarra.posicion, ocarra.especie.alcance(), TRIBU, plantel)
	assert_bool(tablero.en_linea(ocarra.posicion, Vector2i(3, 5))).is_true()
	assert_array(tablero.casillas_entre(ocarra.posicion, Vector2i(3, 5))).contains_exactly([Vector2i(3, 6)])
	assert_bool(tablero.linea_bloqueada(ocarra.posicion, Vector2i(3, 5), TRIBU, plantel)).is_false()
	assert_array(golpeables).contains([Vector2i(3, 5), Vector2i(5, 7)])


# Alcance 2: nunca por encima de una enemiga.
func test_ocarra_no_pega_por_encima_de_una_enemiga() -> void:
	var escenario: Dictionary = _escenario("alcance")
	var plantel: Plantel = _plantel(escenario)
	var tablero: Tablero = _tablero(escenario)
	var ocarra: Criatura = plantel.criatura("ocarra_1")

	var golpeables: Array[Vector2i] = tablero.golpeables(ocarra.posicion, ocarra.especie.alcance(), TRIBU, plantel)
	assert_bool(tablero.linea_bloqueada(ocarra.posicion, Vector2i(1, 7), TRIBU, plantel)).is_true()
	assert_array(golpeables).not_contains([Vector2i(1, 7)])
	# La enemiga que bloquea si es golpeable: esta adyacente.
	assert_array(golpeables).contains([Vector2i(2, 7)])


# Alcance 2: ni en diagonal. Con alcance 1, solo las vecinas.
func test_ocarra_no_pega_en_diagonal() -> void:
	var escenario: Dictionary = _escenario("alcance")
	var plantel: Plantel = _plantel(escenario)
	var tablero: Tablero = _tablero(escenario)
	var desde: Vector2i = plantel.criatura("ocarra_1").posicion

	var golpeables: Array[Vector2i] = tablero.golpeables(desde, 2, TRIBU, plantel)
	assert_array(golpeables).not_contains([Vector2i(2, 6), Vector2i(4, 6), Vector2i(2, 5), Vector2i(4, 5)])
	assert_bool(tablero.en_linea(desde, Vector2i(4, 6))).is_false()
	assert_array(golpeables).contains_exactly_in_any_order([
		Vector2i(3, 6), Vector2i(2, 7), Vector2i(4, 7), Vector2i(3, 5), Vector2i(5, 7)])

	assert_array(tablero.golpeables(desde, 1, TRIBU, plantel)).contains_exactly_in_any_order(tablero.vecinas(desde))


# "Aliada" y "enemiga" son relativas al bando de quien golpea.
func test_aliada_y_enemiga_relativas_al_bando() -> void:
	var escenario: Dictionary = _escenario("alcance")
	var plantel: Plantel = _plantel(escenario)
	var tablero: Tablero = _tablero(escenario)
	var salvaje: Criatura = plantel.criatura("ocarra_s1")
	var destino: Vector2i = Vector2i(5, 5)

	# Para la salvaje, la Rodauva salvaje en [5,4] es aliada.
	assert_bool(tablero.linea_bloqueada(salvaje.posicion, destino, ENEMIGA, plantel)).is_false()
	assert_array(tablero.golpeables(salvaje.posicion, salvaje.especie.alcance(), ENEMIGA, plantel)).contains([destino])
	# Para la tribu, esa misma linea esta bloqueada.
	assert_bool(tablero.linea_bloqueada(salvaje.posicion, destino, TRIBU, plantel)).is_true()
	assert_array(tablero.golpeables(salvaje.posicion, salvaje.especie.alcance(), TRIBU, plantel)).not_contains([destino])


# Despliegue: las 2 filas del borde de cada bando en un 8 x 8. El numero de
# filas sale del dato (fixture combate.json), no del codigo.
func test_despliegue_en_8x8() -> void:
	var tablero: Tablero = _tablero(_escenario("rodeo"))
	var tribu: Array[Vector2i] = tablero.despliegue(TRIBU)
	var enemigas: Array[Vector2i] = tablero.despliegue(ENEMIGA)
	assert_int(tribu.size()).is_equal(16)
	assert_int(enemigas.size()).is_equal(16)
	for casilla in tribu:
		assert_bool(casilla.y == 6 or casilla.y == 7).override_failure_message(str(casilla)).is_true()
		assert_array(enemigas).not_contains([casilla])
	for casilla in enemigas:
		assert_bool(casilla.y == 0 or casilla.y == 1).override_failure_message(str(casilla)).is_true()

	var tres_filas: Tablero = Tablero.new(8, 8, 3)
	assert_int(tres_filas.despliegue(TRIBU).size()).is_equal(24)
	assert_array(tres_filas.despliegue(TRIBU)).contains([Vector2i(0, 5)])
	assert_array(tres_filas.despliegue(ENEMIGA)).contains([Vector2i(7, 2)])


# Nada se sale del tablero.
func test_nada_se_sale_del_tablero() -> void:
	var escenario: Dictionary = _escenario("esquina")
	var plantel: Plantel = _plantel(escenario)
	var tablero: Tablero = _tablero(escenario)
	assert_bool(tablero.dentro(Vector2i(-1, 0))).is_false()
	assert_bool(tablero.dentro(Vector2i(8, 7))).is_false()
	assert_array(tablero.vecinas(Vector2i(0, 7))).contains_exactly_in_any_order([Vector2i(0, 6), Vector2i(1, 7)])

	var casillas: Array[Vector2i] = []
	casillas.append_array(tablero.alcanzables(plantel.maestro.posicion, 7, TRIBU, plantel, Surcos.new(), false))
	casillas.append_array(tablero.golpeables(Vector2i(7, 0), 2, ENEMIGA, plantel))
	casillas.append_array(tablero.golpeables(Vector2i(7, 7), 2, TRIBU, plantel))
	casillas.append_array(tablero.casillas_entre(Vector2i(7, 0), Vector2i(7, 7)))
	casillas.append_array(tablero.despliegue(TRIBU))
	casillas.append_array(tablero.despliegue(ENEMIGA))
	for esquina in [Vector2i(0, 0), Vector2i(7, 0), Vector2i(0, 7), Vector2i(7, 7)]:
		casillas.append_array(tablero.vecinas(esquina))
	assert_array(casillas).is_not_empty()
	for casilla in casillas:
		assert_bool(tablero.dentro(casilla)).override_failure_message(str(casilla)).is_true()


# Las consultas no cambian el Plantel.
func test_consultas_no_cambian_el_plantel() -> void:
	for nombre in ["atravesar", "alcance"]:
		var escenario: Dictionary = _escenario(nombre)
		var plantel: Plantel = _plantel(escenario)
		var tablero: Tablero = _tablero(escenario)
		var antes: Array[String] = _foto(plantel)

		for criatura in plantel.criaturas():
			tablero.alcanzables(criatura.posicion, criatura.especie.movimiento(), criatura.bando, plantel, Surcos.new(), false)
			tablero.golpeables(criatura.posicion, criatura.especie.alcance(), criatura.bando, plantel)
			for otra in plantel.criaturas():
				tablero.linea_bloqueada(criatura.posicion, otra.posicion, criatura.bando, plantel)
		var maestro: Maestro = plantel.maestro
		tablero.alcanzables(maestro.posicion, maestro.movimiento, TRIBU, plantel, Surcos.new(), false)
		tablero.golpeables(maestro.posicion, maestro.alcance, TRIBU, plantel)
		tablero.despliegue(TRIBU)
		tablero.despliegue(ENEMIGA)

		assert_array(_foto(plantel)).override_failure_message(nombre).is_equal(antes)


# El Movimiento y el Alcance del Maestro salen de maestro.json.
func test_movimiento_y_alcance_del_maestro() -> void:
	var plantel: Plantel = _plantel(_escenario("rodeo"))
	var ficha: Dictionary = _leer(_CARPETA_UNIDADES + "maestro.json", "maestro")
	assert_int(plantel.maestro.movimiento).is_equal(ficha["movimiento"] as int)
	assert_int(plantel.maestro.alcance).is_equal(ficha["alcance"] as int)


func _foto(plantel: Plantel) -> Array[String]:
	var maestro: Maestro = plantel.maestro
	var foto: Array[String] = ["maestro:%s:%d" % [maestro.posicion, maestro.vida]]
	for criatura in plantel.criaturas():
		foto.append("%s:%s:%d:%d:%d" % [criatura.id, criatura.posicion, criatura.estado, criatura.vida, criatura.bando])
	return foto


# T11: pasos_hasta da las mismas casillas que alcanzables, con los pasos del
# camino mas corto (el rodeo cuesta 4).
func test_pasos_hasta_con_rodeo() -> void:
	var escenario: Dictionary = _escenario("rodeo")
	var plantel: Plantel = _plantel(escenario)
	var tablero: Tablero = _tablero(escenario)
	var desde: Vector2i = plantel.criatura("rodauva_1").posicion
	var pasos: Dictionary = tablero.pasos_hasta(desde, 4, TRIBU, plantel, Surcos.new(), false)
	assert_array(pasos.keys()).contains_exactly_in_any_order(tablero.alcanzables(desde, 4, TRIBU, plantel, Surcos.new(), false))
	assert_int(pasos[desde]).is_equal(0)
	assert_int(pasos[Vector2i(2, 7)]).is_equal(1)
	assert_int(pasos[Vector2i(3, 5)]).is_equal(4)
	assert_bool(pasos.has(Vector2i(3, 6))).is_false()


# T41, Sistema.md 11.3 v1.6 (D-001): el vinculo mira las 8 vecinas (Chebyshev 1).
# Las 4 ortogonales y las 4 diagonales si; la misma casilla y a distancia 2, no.
# Las vecinas del cuerpo (vecinas, adyacentes) no cambian: test_diagonal_no_es_adyacente.
func test_vecina_en_8() -> void:
	var centro: Vector2i = Vector2i(3, 3)
	for dx in [-1, 0, 1]:
		for dy in [-1, 0, 1]:
			var otra: Vector2i = centro + Vector2i(dx, dy)
			assert_bool(Tablero.es_vecina_en_8(centro, otra)).override_failure_message(str(otra)) \
					.is_equal(otra != centro)
	assert_bool(Tablero.es_vecina_en_8(centro, Vector2i(5, 3))).is_false()
	assert_bool(Tablero.es_vecina_en_8(centro, Vector2i(5, 4))).is_false()
	assert_bool(Tablero.es_vecina_en_8(centro, Vector2i(5, 5))).is_false()
