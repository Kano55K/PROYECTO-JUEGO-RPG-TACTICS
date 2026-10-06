extends GdUnitTestSuite

# Arquitectura.md B.2 (T08): turno de una unidad, con fixtures (A.6).
# Sistema.md 11.2 (Erizarse, Caza y cuenta) y 11.3 (Turno de una unidad, Alcance 2
# e inicio del turno). Los numeros de danio y vida son la comprobacion: el codigo
# los lee de las fichas, la balanza y combate.json de prueba.
const _CARPETA: String = "res://pruebas/fixtures/combate/"
const _CARPETA_UNIDADES: String = "res://pruebas/fixtures/unidades/"
const _ESPECIES: Array[String] = ["ocarra", "rodauva", "surcon", "tasajero", "zancajunco"]
const _FUENTES: Array[String] = [
	"res://nucleo/combate/turno.gd",
	"res://nucleo/combate/accion.gd",
	"res://nucleo/combate/resultado_accion.gd",
	"res://nucleo/combate/danio.gd",
]
const _AZAR_PROHIBIDO: Array[String] = ["GeneradorAzar", "randi", "randf", "RandomNumberGenerator"]

var _tablero: Tablero
var _danio: Danio


func before_test() -> void:
	var tabla_combate: Dictionary = _leer(_CARPETA + "combate.json", "combate")
	_tablero = Tablero.desde_datos({"ancho": 8, "alto": 8}, tabla_combate)
	_danio = Danio.desde_datos(tabla_combate, _leer(_CARPETA + "hambre.json", "hambre"))


func _leer(ruta: String, nombre_esquema: String) -> Dictionary:
	var lectura: Dictionary = LectorFixture.leer(ruta, nombre_esquema)
	var errores: Array[Dictionary] = lectura["errores"]
	assert_array(errores).override_failure_message(str(errores)).is_empty()
	return lectura["datos"]


func _escenario(nombre: String = "escenario_turno.json") -> Dictionary:
	return _leer(_CARPETA + nombre, "escenario")


# Sin escenario: escenario_turno.json.
func _plantel(escenario: Dictionary = {}) -> Plantel:
	if escenario.is_empty():
		escenario = _escenario()
	var especies: Dictionary = {}
	for id_especie in _ESPECIES:
		especies[id_especie] = Especie.new(_leer(_CARPETA_UNIDADES + id_especie + ".json", "especie"))
	var tabla: TablaBalanza = TablaBalanza.new(_leer(_CARPETA_UNIDADES + "balanza_1_2.json", "balanza"))
	return Plantel.desde_escenario(escenario, especies, tabla, _leer(_CARPETA_UNIDADES + "maestro.json", "maestro"))


# Turno suelto, sin cola: la entrada se arma a mano.
func _turno(plantel: Plantel, unidad_id: String) -> Turno:
	return Turno.empezar(EntradaCola.new(unidad_id, "", 0), plantel, _tablero, _danio, Surcos.new())


func _siguiente_turno(cola: ColaIniciativa, plantel: Plantel) -> Turno:
	return Turno.empezar(cola.siguiente(plantel), plantel, _tablero, _danio, Surcos.new())


# Todo lo que una accion puede cambiar en el Plantel.
func _foto(plantel: Plantel) -> String:
	var foto: Array = [plantel.maestro.vida, plantel.maestro.posicion]
	for criatura in plantel.criaturas():
		foto.append([criatura.id, criatura.vida, criatura.posicion, criatura.estado, criatura.erizada])
	return str(foto)


func _assert_valida(resultado: ResultadoAccion) -> void:
	assert_bool(resultado.valida).override_failure_message("motivo: " + ResultadoAccion.Motivo.keys()[resultado.motivo]).is_true()
	assert_int(resultado.motivo).is_equal(ResultadoAccion.Motivo.NINGUNO)


func _assert_rechazada(resultado: ResultadoAccion, motivo: ResultadoAccion.Motivo) -> void:
	assert_bool(resultado.valida).is_false()
	assert_str(ResultadoAccion.Motivo.keys()[resultado.motivo]).is_equal(ResultadoAccion.Motivo.keys()[motivo])


# (1) Movimiento y accion en cualquier orden (Sistema.md 11.3).
func test_mover_y_atacar_en_cualquier_orden() -> void:
	var plantel: Plantel = _plantel()
	var turno: Turno = _turno(plantel, Maestro.ID)
	_assert_valida(turno.aplicar(Accion.mover(Vector2i(4, 5))))
	assert_that(plantel.maestro.posicion).is_equal(Vector2i(4, 5))
	var ataque: ResultadoAccion = turno.aplicar(Accion.atacar("ocarra_s1"))
	_assert_valida(ataque)
	assert_int(ataque.danio).is_equal(4)
	assert_int(plantel.criatura("ocarra_s1").vida).is_equal(12 - 4)

	plantel = _plantel()
	turno = _turno(plantel, Maestro.ID)
	_assert_valida(turno.aplicar(Accion.atacar("ocarra_s1")))
	assert_int(plantel.criatura("ocarra_s1").vida).is_equal(12 - 4)
	# Pasa por encima de la Rodauva aliada [2,6].
	_assert_valida(turno.aplicar(Accion.mover(Vector2i(2, 7))))
	assert_that(plantel.maestro.posicion).is_equal(Vector2i(2, 7))


# (2) El movimiento no se parte: 1 paso de 4 lo gasta entero.
func test_movimiento_no_se_parte() -> void:
	var plantel: Plantel = _plantel()
	var turno: Turno = _turno(plantel, "rodauva_1")
	_assert_valida(turno.aplicar(Accion.mover(Vector2i(1, 6))))
	_assert_rechazada(turno.aplicar(Accion.mover(Vector2i(0, 6))), ResultadoAccion.Motivo.MOVIMIENTO_USADO)
	assert_that(plantel.criatura("rodauva_1").posicion).is_equal(Vector2i(1, 6))
	assert_array(turno.casillas_para_mover()).is_empty()


# (3) Una sola accion por turno.
func test_no_hay_segunda_accion() -> void:
	var plantel: Plantel = _plantel()
	var turno: Turno = _turno(plantel, Maestro.ID)
	_assert_valida(turno.aplicar(Accion.atacar("ocarra_s1")))
	_assert_rechazada(turno.aplicar(Accion.atacar("ocarra_s1")), ResultadoAccion.Motivo.ACCION_USADA)
	assert_int(plantel.criatura("ocarra_s1").vida).is_equal(12 - 4)
	assert_bool(turno.puede_erizarse()).is_false()
	assert_array(turno.objetivos_para_atacar()).is_empty()


# (4) Cada accion invalida se rechaza con su motivo y no cambia nada.
func test_rechazos_con_motivo_sin_cambios() -> void:
	var plantel: Plantel = _plantel()
	plantel.criatura("rodauva_s1").estado = Criatura.Estado.CAIDA
	var antes: String = _foto(plantel)
	var maestro: Turno = _turno(plantel, Maestro.ID)
	var ocarra: Turno = _turno(plantel, "ocarra_1")
	var casos: Array = [
		[maestro, Accion.mover(Vector2i(7, 0)), ResultadoAccion.Motivo.CASILLA_NO_ALCANZABLE],
		[maestro, Accion.atacar("rodauva_1"), ResultadoAccion.Motivo.OBJETIVO_ALIADO],
		[ocarra, Accion.atacar("rodauva_s1"), ResultadoAccion.Motivo.OBJETIVO_CAIDO],
		[maestro, Accion.atacar("rodauva_s2"), ResultadoAccion.Motivo.FUERA_DE_ALCANCE],
		[maestro, Accion.atacar("no_existe"), ResultadoAccion.Motivo.OBJETIVO_INEXISTENTE],
	]
	for caso in casos:
		_assert_rechazada((caso[0] as Turno).aplicar(caso[1]), caso[2])
		assert_str(_foto(plantel)).is_equal(antes)

	# Alcance 2 de la Ocarra [3,7]: no pega por encima de una enemiga en pie
	# [4,7] a [5,7], ni en diagonal.
	plantel = _plantel()
	antes = _foto(plantel)
	ocarra = _turno(plantel, "ocarra_1")
	_assert_rechazada(ocarra.aplicar(Accion.atacar("rodauva_s2")), ResultadoAccion.Motivo.LINEA_BLOQUEADA)
	maestro = _turno(plantel, Maestro.ID)
	_assert_valida(maestro.aplicar(Accion.mover(Vector2i(4, 6))))
	antes = _foto(plantel)
	_assert_rechazada(maestro.aplicar(Accion.atacar("ocarra_s1")), ResultadoAccion.Motivo.FUERA_DE_ALCANCE)
	assert_str(_foto(plantel)).is_equal(antes)

	# Despues de los rechazos el turno conserva movimiento y accion.
	assert_bool(ocarra.movimiento_usado).is_false()
	assert_bool(ocarra.accion_usada).is_false()
	_assert_valida(ocarra.aplicar(Accion.atacar("rodauva_s1")))


# (5) El Maestro pega el danio de su balanza; una criatura, el de su ficha.
func test_danio_de_balanza_y_de_ficha() -> void:
	var plantel: Plantel = _plantel()
	_turno(plantel, Maestro.ID).aplicar(Accion.atacar("ocarra_s1"))
	assert_int(plantel.criatura("ocarra_s1").vida).is_equal(12 - 4)

	var escenario: Dictionary = _escenario()
	escenario["maestro"]["balanza"] = 5
	plantel = _plantel(escenario)
	assert_int(_turno(plantel, Maestro.ID).aplicar(Accion.atacar("ocarra_s1")).danio).is_equal(3)
	assert_int(plantel.criatura("ocarra_s1").vida).is_equal(12 - 3)

	plantel = _plantel()
	_turno(plantel, "ocarra_1").aplicar(Accion.atacar("ocarra_s1"))
	assert_int(plantel.criatura("ocarra_s1").vida).is_equal(12 - 4)

	plantel = _plantel()
	var rodauva: Turno = _turno(plantel, "rodauva_1")
	rodauva.aplicar(Accion.mover(Vector2i(2, 5)))
	assert_int(rodauva.aplicar(Accion.atacar("ocarra_s1")).danio).is_equal(2)
	assert_int(plantel.criatura("ocarra_s1").vida).is_equal(12 - 2)


# (6) La vida no baja de 0. La salvaje en 0 sale del tablero (T10, Sistema.md 11.5).
func test_vida_no_baja_de_cero() -> void:
	var escenario: Dictionary = _escenario()
	(escenario["enemigas"] as Array)[1]["vida"] = 1
	var plantel: Plantel = _plantel(escenario)
	var ataque: ResultadoAccion = _turno(plantel, "ocarra_1").aplicar(Accion.atacar("rodauva_s1"))
	assert_int(ataque.danio).is_equal(4)
	assert_int(plantel.criatura("rodauva_s1").vida).is_equal(0)
	assert_int(plantel.criatura("rodauva_s1").estado).is_equal(Criatura.Estado.FUERA)


# (7a) Erizarse gasta la accion, y sin haberse movido pierde el movimiento (P-014).
func test_erizarse_antes_de_mover() -> void:
	var plantel: Plantel = _plantel()
	var turno: Turno = _turno(plantel, "rodauva_1")
	assert_bool(turno.puede_erizarse()).is_true()
	_assert_valida(turno.aplicar(Accion.erizarse()))
	assert_bool(plantel.criatura("rodauva_1").erizada).is_true()
	assert_bool(turno.accion_usada).is_true()
	_assert_rechazada(turno.aplicar(Accion.mover(Vector2i(1, 6))), ResultadoAccion.Motivo.ERIZADA)
	_assert_rechazada(turno.aplicar(Accion.atacar("ocarra_s1")), ResultadoAccion.Motivo.ACCION_USADA)
	assert_array(turno.casillas_para_mover()).is_empty()
	assert_that(plantel.criatura("rodauva_1").posicion).is_equal(Vector2i(2, 6))


# (7b) Mover y despues erizarse vale (S-15).
func test_mover_y_despues_erizarse() -> void:
	var plantel: Plantel = _plantel()
	var turno: Turno = _turno(plantel, "rodauva_1")
	_assert_valida(turno.aplicar(Accion.mover(Vector2i(2, 5))))
	_assert_valida(turno.aplicar(Accion.erizarse()))
	assert_bool(plantel.criatura("rodauva_1").erizada).is_true()
	assert_that(plantel.criatura("rodauva_1").posicion).is_equal(Vector2i(2, 5))


# (7c) Sigue erizada en los turnos de las demas y deja de estarlo al empezar su
# proximo turno, en la ronda siguiente.
func test_erizada_hasta_su_proximo_turno() -> void:
	var plantel: Plantel = _plantel()
	var rodauva: Criatura = plantel.criatura("rodauva_1")
	var cola: ColaIniciativa = ColaIniciativa.new()
	cola.empezar_ronda(plantel)
	var turno: Turno = _siguiente_turno(cola, plantel)
	while turno.unidad_id != "rodauva_1":
		turno.aplicar(Accion.terminar())
		turno = _siguiente_turno(cola, plantel)
	turno.aplicar(Accion.erizarse())
	turno.aplicar(Accion.terminar())

	# Resto de la ronda 1: rodauva_s1, rodauva_s2 y el Maestro.
	turno = _siguiente_turno(cola, plantel)
	while turno != null:
		assert_bool(rodauva.erizada).override_failure_message("en el turno de " + turno.unidad_id).is_true()
		turno.aplicar(Accion.terminar())
		var entrada: EntradaCola = cola.siguiente(plantel)
		turno = null if entrada == null else Turno.empezar(entrada, plantel, _tablero, _danio, Surcos.new())
	cola.terminar_ronda()

	cola.empezar_ronda(plantel)
	turno = _siguiente_turno(cola, plantel)
	while turno.unidad_id != "rodauva_1":
		assert_bool(rodauva.erizada).override_failure_message("en el turno de " + turno.unidad_id).is_true()
		turno.aplicar(Accion.terminar())
		turno = _siguiente_turno(cola, plantel)
	assert_bool(rodauva.erizada).is_false()
	_assert_valida(turno.aplicar(Accion.mover(Vector2i(1, 6))))


# (8) Erizarse lo habilita el rasgo de la ficha: la Ocarra y el Maestro no pueden.
func test_sin_rasgo_no_se_eriza() -> void:
	var plantel: Plantel = _plantel()
	var antes: String = _foto(plantel)
	for unidad_id in ["ocarra_1", Maestro.ID]:
		var turno: Turno = _turno(plantel, unidad_id)
		assert_bool(turno.puede_erizarse()).is_false()
		_assert_rechazada(turno.aplicar(Accion.erizarse()), ResultadoAccion.Motivo.SIN_RASGO)
		assert_bool(turno.accion_usada).is_false()
	assert_str(_foto(plantel)).is_equal(antes)


# (9) Prueba C: el Tasajero tiene un solo turno por ronda, en Caza; mueve y
# ataca dos veces, y en la ronda siguiente vuelve con movimiento y ataques
# renovados. Reescrito por Sistema.md 11.2.3 v1.3 (antes: Caza y Cuenta, dos
# turnos por ronda) y 11.2 (Danio 5). Reescrito otra vez en T36 por 11.2.3
# ("2 ataques separados de 5"): el segundo ataque vale y el tercero no.
func test_tasajero_un_turno_por_ronda() -> void:
	var plantel: Plantel = _plantel(_escenario("escenario_c.json"))
	var zancajunco: Criatura = plantel.criatura("zancajunco_1")
	var cola: ColaIniciativa = ColaIniciativa.new()
	cola.empezar_ronda(plantel)

	var turno: Turno = _siguiente_turno(cola, plantel)
	assert_str(turno.unidad_id).is_equal("zancajunco_1")
	_assert_valida(turno.aplicar(Accion.mover(Vector2i(4, 2))))
	turno.aplicar(Accion.terminar())

	turno = _siguiente_turno(cola, plantel)
	assert_str(turno.marca).is_equal("caza")
	_assert_valida(turno.aplicar(Accion.mover(Vector2i(3, 2))))
	_assert_valida(turno.aplicar(Accion.atacar("zancajunco_1")))
	assert_int(zancajunco.vida).is_equal(12 - 5)
	_assert_valida(turno.aplicar(Accion.atacar("zancajunco_1")))
	assert_int(zancajunco.vida).is_equal(12 - 5 - 5)
	_assert_rechazada(turno.validar(Accion.atacar("zancajunco_1")), ResultadoAccion.Motivo.ACCION_USADA)
	turno.aplicar(Accion.terminar())
	zancajunco.vida = 12

	for unidad_id in ["ocarra_1", "rodauva_1", Maestro.ID]:
		turno = _siguiente_turno(cola, plantel)
		assert_str(turno.unidad_id).is_equal(unidad_id)
		turno.aplicar(Accion.terminar())
	assert_bool(cola.ronda_terminada()).is_true()

	cola.terminar_ronda()
	cola.empezar_ronda(plantel)
	_siguiente_turno(cola, plantel).aplicar(Accion.terminar())
	turno = _siguiente_turno(cola, plantel)
	assert_str(turno.unidad_id).is_equal("tasajero_s1")
	assert_str(turno.marca).is_equal("caza")
	assert_bool(turno.movimiento_usado).is_false()
	assert_bool(turno.accion_usada).is_false()
	assert_int(turno.ataques_restantes).is_equal(2)
	_assert_valida(turno.aplicar(Accion.mover(Vector2i(4, 3))))
	_assert_valida(turno.aplicar(Accion.atacar("zancajunco_1")))
	assert_int(zancajunco.vida).is_equal(12 - 5)


# (10) Esperar: terminar sin usar la accion cierra el turno (P-015) y la cola
# sigue con la entrada que corresponde.
func test_esperar_cierra_el_turno() -> void:
	var plantel: Plantel = _plantel()
	var cola: ColaIniciativa = ColaIniciativa.new()
	cola.empezar_ronda(plantel)
	var turno: Turno = _siguiente_turno(cola, plantel)
	assert_str(turno.unidad_id).is_equal("ocarra_1")
	var antes: String = _foto(plantel)
	var espera: ResultadoAccion = turno.aplicar(Accion.terminar())
	_assert_valida(espera)
	assert_bool(espera.espero).is_true()
	assert_bool(turno.terminado).is_true()
	assert_str(_foto(plantel)).is_equal(antes)
	_assert_rechazada(turno.aplicar(Accion.atacar("ocarra_s1")), ResultadoAccion.Motivo.TURNO_TERMINADO)
	_assert_rechazada(turno.aplicar(Accion.mover(Vector2i(2, 7))), ResultadoAccion.Motivo.TURNO_TERMINADO)
	_assert_rechazada(turno.aplicar(Accion.terminar()), ResultadoAccion.Motivo.TURNO_TERMINADO)
	assert_bool(turno.puede_terminar()).is_false()

	turno = _siguiente_turno(cola, plantel)
	assert_str(turno.unidad_id).is_equal("ocarra_s1")
	_assert_valida(turno.aplicar(Accion.atacar(Maestro.ID)))
	assert_int(plantel.maestro.vida).is_equal(20 - 4)
	assert_bool(turno.aplicar(Accion.terminar()).espero).is_false()
	assert_str(_siguiente_turno(cola, plantel).unidad_id).is_equal("rodauva_1")


# (11) Validar no cambia nada y da lo mismo que aplicar.
func test_validar_es_aplicar_sin_cambios() -> void:
	var casos: Array = [
		[Maestro.ID, Accion.mover(Vector2i(4, 5))],
		[Maestro.ID, Accion.mover(Vector2i(7, 0))],
		[Maestro.ID, Accion.atacar("ocarra_s1")],
		[Maestro.ID, Accion.atacar("rodauva_1")],
		["ocarra_1", Accion.atacar("rodauva_s2")],
		["rodauva_1", Accion.erizarse()],
		["ocarra_1", Accion.erizarse()],
		[Maestro.ID, Accion.terminar()],
	]
	for caso in casos:
		var plantel: Plantel = _plantel()
		var turno: Turno = _turno(plantel, caso[0])
		var antes: String = _foto(plantel)
		var validado: ResultadoAccion = turno.validar(caso[1])
		assert_str(_foto(plantel)).is_equal(antes)
		assert_bool(turno.movimiento_usado or turno.accion_usada or turno.terminado).is_false()

		var aplicado: ResultadoAccion = turno.aplicar(caso[1])
		assert_bool(aplicado.valida).is_equal(validado.valida)
		assert_int(aplicado.motivo).is_equal(validado.motivo)
		assert_int(aplicado.danio).is_equal(validado.danio)
		assert_bool(aplicado.espero).is_equal(validado.espero)

	# Las consultas para la pantalla tampoco cambian nada.
	var plantel: Plantel = _plantel()
	var turno: Turno = _turno(plantel, "ocarra_1")
	var antes: String = _foto(plantel)
	assert_array(turno.objetivos_para_atacar()).contains_exactly(["ocarra_s1", "rodauva_s1"])
	assert_array(turno.casillas_para_mover()).is_not_empty()
	assert_bool(turno.puede_terminar()).is_true()
	assert_str(_foto(plantel)).is_equal(antes)
	assert_bool(turno.movimiento_usado or turno.accion_usada or turno.terminado).is_false()


# (12) El turno no usa azar.
func test_turno_sin_azar() -> void:
	for ruta in _FUENTES:
		var fuente: String = FileAccess.get_file_as_string(ruta)
		assert_str(fuente).is_not_empty()
		for prohibido in _AZAR_PROHIBIDO:
			assert_bool(fuente.contains(prohibido)).override_failure_message(ruta + " usa " + prohibido).is_false()


# T11: previsualizar un ataque da el mismo danio que aplicarlo, desde la casilla
# actual o desde otra a la que llega, sin cambiar nada; una casilla a la que no
# llega se rechaza con el motivo del movimiento.
func test_previsualizar_ataque() -> void:
	var plantel: Plantel = _plantel()
	var turno: Turno = _turno(plantel, "ocarra_1")
	var antes: String = _foto(plantel)
	var desde_otra: ResultadoAccion = turno.previsualizar_ataque(Vector2i(2, 7), "rodauva_s1")
	_assert_valida(desde_otra)
	assert_int(desde_otra.danio).is_equal(4)
	_assert_rechazada(turno.previsualizar_ataque(Vector2i(0, 0), "rodauva_s1"), ResultadoAccion.Motivo.CASILLA_NO_ALCANZABLE)
	_assert_rechazada(turno.previsualizar_ataque(Vector2i(3, 7), "rodauva_1"), ResultadoAccion.Motivo.OBJETIVO_ALIADO)
	var previsto: ResultadoAccion = turno.previsualizar_ataque(Vector2i(3, 7), "ocarra_s1")
	assert_str(_foto(plantel)).is_equal(antes)
	assert_bool(turno.movimiento_usado or turno.accion_usada).is_false()
	assert_int(turno.pasos_para_mover()[Vector2i(3, 7)]).is_equal(0)

	var aplicado: ResultadoAccion = turno.aplicar(Accion.atacar("ocarra_s1"))
	_assert_valida(aplicado)
	assert_int(aplicado.danio).is_equal(previsto.danio)
