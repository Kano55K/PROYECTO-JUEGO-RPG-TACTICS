extends GdUnitTestSuite

# Arquitectura.md B.2.1 (T40, test 1): las dos consultas nuevas del nucleo para
# la pantalla, con fixtures (A.6). zona_amenaza (Sistema.md 11.2.3 y 15, zona de
# Caza) y destaparia (11.2.2, aviso al mover junto a una oculta, S-24). Ninguna
# de las dos modifica el estado.
const _CARPETA: String = "res://pruebas/fixtures/combate/"
const _CARPETA_UNIDADES: String = "res://pruebas/fixtures/unidades/"
const _ESPECIES: Array[String] = ["ocarra", "rodauva", "surcon", "tasajero", "zancajunco"]


func _leer(ruta: String, nombre_esquema: String) -> Dictionary:
	var lectura: Dictionary = LectorFixture.leer(ruta, nombre_esquema)
	var errores: Array[Dictionary] = lectura["errores"]
	assert_array(errores).override_failure_message(str(errores)).is_empty()
	return lectura["datos"]


func _combate(nombre: String) -> Combate:
	var lectura: Dictionary = DatosFixture.cargar()
	assert_array(lectura["errores"]).is_empty()
	var combate: Combate = Combate.empezar(ContextoCombate.armar(_leer(_CARPETA + nombre + ".json", "escenario"),
			lectura["datos"]))
	assert_str(combate.error()).is_empty()
	return combate


func _plantel(nombre: String) -> Plantel:
	var especies: Dictionary = {}
	for id_especie in _ESPECIES:
		especies[id_especie] = Especie.new(_leer(_CARPETA_UNIDADES + id_especie + ".json", "especie"))
	var tabla: TablaBalanza = TablaBalanza.new(_leer(_CARPETA_UNIDADES + "balanza_1_2.json", "balanza"))
	return Plantel.desde_escenario(_leer(_CARPETA + nombre + ".json", "escenario"), especies, tabla,
			_leer(_CARPETA_UNIDADES + "maestro.json", "maestro"))


# (1a) escenario_caza: el Tasajero salvaje [3,3] (Movimiento 4, Alcance 1) pega
# a sus dos presas sin moverse y queda rodeado por el Maestro [2,3], la Rodauva
# [3,4] y la Ocarra [4,3]: solo sale por [3,2]. La zona son las casillas que
# golpea desde cada casilla a la que llega, sin la suya. Las enemigas le tapan
# el paso: [2,4] y [4,4] estan a 2 de el y no entran.
func test_zona_amenaza() -> void:
	var combate: Combate = _combate("escenario_caza")
	assert_bool(combate.esperando_jugador()).is_true()
	var foto: String = JSON.stringify(combate.instantanea())
	var zona: Array[Vector2i] = combate.zona_amenaza("tasajero_s1")

	# Desde su casilla: las cuatro adyacentes, con las tres presas.
	assert_array(zona).contains([Vector2i(3, 2), Vector2i(2, 3), Vector2i(3, 4), Vector2i(4, 3)])
	# [1,3] y [5,3] estan a 4 pasos por [3,2]: golpea sus vecinas.
	assert_array(zona).contains([Vector2i(1, 4), Vector2i(0, 3), Vector2i(5, 4), Vector2i(6, 3)])
	assert_array(zona).not_contains([Vector2i(3, 3)])
	assert_array(zona).not_contains([Vector2i(2, 4), Vector2i(4, 4), Vector2i(0, 4), Vector2i(7, 7)])
	# Orden de lectura y sin repetidas.
	for i in range(1, zona.size()):
		var a: Vector2i = zona[i - 1]
		var b: Vector2i = zona[i]
		assert_bool(a.y < b.y or (a.y == b.y and a.x < b.x)).override_failure_message("%s, %s" % [a, b]).is_true()
	# No modifica nada.
	assert_str(JSON.stringify(combate.instantanea())).is_equal(foto)
	# Una unidad que no esta de pie no amenaza.
	combate.contexto().plantel.criatura("tasajero_s1").estado = Criatura.Estado.CAIDA
	assert_array(combate.zona_amenaza("tasajero_s1")).is_empty()


# (1a') zona_amenaza usa los surcos del combate (Sistema.md 11.2.1: el surco es
# intransitable). escenario_caza_surco: el de arriba mas el Surcon de la tribu
# [3,1], ultimo de la ronda 1. Antes de cavar, el Tasajero sale por [3,2] y la
# zona llega a [1,4], [0,3], [5,4] y [6,3]; con el surco en [3,2] queda
# encerrado y la zona es solo lo que golpea desde su casilla. Con una lista de
# surcos vacia seguiria saliendo por [3,2].
func test_zona_amenaza_con_surco() -> void:
	var combate: Combate = _combate("escenario_caza_surco")
	for _i in range(4):
		if combate.turno_actual().unidad_id == "surcon_1":
			break
		assert_bool(combate.aplicar(Accion.terminar()).valida).is_true()
	assert_str(combate.turno_actual().unidad_id).is_equal("surcon_1")
	assert_int(combate.instantanea()["ronda"]).is_equal(1)
	assert_array(combate.zona_amenaza("tasajero_s1")).contains(
			[Vector2i(1, 4), Vector2i(0, 3), Vector2i(5, 4), Vector2i(6, 3)])

	assert_bool(combate.aplicar(Accion.cavar(Vector2i(3, 2))).valida).is_true()
	var foto: String = JSON.stringify(combate.instantanea())
	assert_array(combate.zona_amenaza("tasajero_s1")).is_equal(
			[Vector2i(3, 2), Vector2i(2, 3), Vector2i(4, 3), Vector2i(3, 4)])
	assert_str(JSON.stringify(combate.instantanea())).is_equal(foto)


# (1b) destaparia, con el Plantel (Junco) y con el Combate: da las ocultas del
# otro bando adyacentes a la casilla donde terminaria; una oculta aliada, una
# casilla lejos o una unidad caida, nada. No destapa a nadie.
func test_destaparia() -> void:
	# escenario_junco_salvaje: Zancajunco salvaje [3,2]; Rodauva [3,5] de la tribu.
	var plantel: Plantel = _plantel("escenario_junco_salvaje")
	plantel.criatura("zancajunco_s1").oculta = true
	assert_array(Junco.destaparia("rodauva_1", Vector2i(3, 3), plantel)).is_equal(["zancajunco_s1"])
	assert_array(Junco.destaparia("rodauva_1", Vector2i(2, 2), plantel)).is_equal(["zancajunco_s1"])
	assert_array(Junco.destaparia("rodauva_1", Vector2i(3, 4), plantel)).is_empty()
	assert_bool(plantel.criatura("zancajunco_s1").oculta).is_true()
	plantel.criatura("rodauva_1").estado = Criatura.Estado.CAIDA
	assert_array(Junco.destaparia("rodauva_1", Vector2i(3, 3), plantel)).is_empty()

	# escenario_junco: Zancajunco de la tribu [3,4] oculto; la Rodauva [3,5] es
	# aliada y la Rodauva salvaje [3,1], enemiga.
	plantel = _plantel("escenario_junco")
	plantel.criatura("zancajunco_1").oculta = true
	assert_array(Junco.destaparia("rodauva_1", Vector2i(2, 4), plantel)).is_empty()
	assert_array(Junco.destaparia("rodauva_s1", Vector2i(2, 4), plantel)).is_equal(["zancajunco_1"])
	assert_array(Junco.destaparia(Maestro.ID, Vector2i(2, 4), plantel)).is_empty()

	# Por el Combate: el Tasajero de la tribu [6,2] juega primero.
	var combate: Combate = _combate("escenario_junco_salvaje")
	combate.contexto().plantel.criatura("zancajunco_s1").oculta = true
	var foto: String = JSON.stringify(combate.instantanea())
	assert_array(combate.destaparia("tasajero_1", Vector2i(4, 2))).is_equal(["zancajunco_s1"])
	assert_array(combate.destaparia("tasajero_1", Vector2i(5, 2))).is_empty()
	assert_str(JSON.stringify(combate.instantanea())).is_equal(foto)
