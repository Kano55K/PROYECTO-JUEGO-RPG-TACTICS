extends GdUnitTestSuite

# Arquitectura.md B.2 (T10, sesion 1): vida en 0 y fin del combate, con fixtures
# (A.6). Sistema.md 11.5. Las vidas del escenario son a un golpe: los numeros
# son la comprobacion, el codigo los lee de las fichas y la balanza de prueba.
const _CARPETA: String = "res://pruebas/fixtures/combate/"
const _CARPETA_UNIDADES: String = "res://pruebas/fixtures/unidades/"
const _ESPECIES: Array[String] = ["ocarra", "rodauva"]

var _tablero: Tablero
var _danio: Danio


func before_test() -> void:
	var tabla_combate: Dictionary = _leer(_CARPETA + "combate.json", "combate")
	_tablero = Tablero.desde_datos({"ancho": 8, "alto": 8}, tabla_combate)
	_danio = Danio.desde_datos(tabla_combate)


func _leer(ruta: String, nombre_esquema: String) -> Dictionary:
	var lectura: Dictionary = LectorFixture.leer(ruta, nombre_esquema)
	var errores: Array[Dictionary] = lectura["errores"]
	assert_array(errores).override_failure_message(str(errores)).is_empty()
	return lectura["datos"]


func _escenario() -> Dictionary:
	return _leer(_CARPETA + "escenario_vida_cero.json", "escenario")


# Sin escenario: escenario_vida_cero.json.
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
	return Turno.empezar(EntradaCola.new(unidad_id, "", 0), plantel, _tablero, _danio)


func _siguiente_turno(cola: ColaIniciativa, plantel: Plantel) -> Turno:
	return Turno.empezar(cola.siguiente(plantel), plantel, _tablero, _danio)


# Todo lo que una accion puede cambiar en el Plantel.
func _foto(plantel: Plantel) -> String:
	var foto: Array = [plantel.maestro.vida, plantel.maestro.posicion, plantel.maestro.caido]
	for criatura in plantel.criaturas():
		foto.append([criatura.id, criatura.vida, criatura.posicion, criatura.estado, criatura.erizada])
	return str(foto)


func _assert_valida(resultado: ResultadoAccion) -> void:
	assert_bool(resultado.valida).override_failure_message("motivo: " + ResultadoAccion.Motivo.keys()[resultado.motivo]).is_true()


func _assert_rechazada(resultado: ResultadoAccion, motivo: ResultadoAccion.Motivo) -> void:
	assert_bool(resultado.valida).is_false()
	assert_str(ResultadoAccion.Motivo.keys()[resultado.motivo]).is_equal(ResultadoAccion.Motivo.keys()[motivo])


func _assert_fin(resultado: ResultadoAccion, fin: FinCombate.Fin) -> void:
	assert_str(FinCombate.Fin.keys()[resultado.fin]).is_equal(FinCombate.Fin.keys()[fin])


# (1) La Rodauva de la tribu llega a 0 y queda caida, en su casilla (que sigue
# ocupada), sin poder ser atacada, y la cola la saltea. Validar no la tumba.
func test_tribu_en_cero_queda_caida() -> void:
	var plantel: Plantel = _plantel()
	var rodauva: Criatura = plantel.criatura("rodauva_1")
	var cola: ColaIniciativa = ColaIniciativa.new()
	cola.empezar_ronda(plantel)
	var turno: Turno = _siguiente_turno(cola, plantel)
	assert_str(turno.unidad_id).is_equal("ocarra_s1")

	var validado: ResultadoAccion = turno.validar(Accion.atacar("rodauva_1"))
	_assert_valida(validado)
	assert_int(validado.danio).is_equal(4)
	_assert_fin(validado, FinCombate.Fin.EN_CURSO)
	assert_int(rodauva.vida).is_equal(4)
	assert_int(rodauva.estado).is_equal(Criatura.Estado.SUELTA)

	var ataque: ResultadoAccion = turno.aplicar(Accion.atacar("rodauva_1"))
	_assert_valida(ataque)
	_assert_fin(ataque, FinCombate.Fin.EN_CURSO)
	assert_int(rodauva.vida).is_equal(0)
	assert_int(rodauva.estado).is_equal(Criatura.Estado.CAIDA)
	assert_that(rodauva.posicion).is_equal(Vector2i(2, 6))
	_assert_rechazada(_turno(plantel, "ocarra_s1").validar(Accion.atacar("rodauva_1")), ResultadoAccion.Motivo.OBJETIVO_CAIDO)
	assert_array(_turno(plantel, Maestro.ID).casillas_para_mover()).not_contains([Vector2i(2, 6)])
	turno.aplicar(Accion.terminar())

	turno = _siguiente_turno(cola, plantel)
	assert_str(turno.unidad_id).is_equal("ocarra_n1")
	turno.aplicar(Accion.terminar())
	assert_str(_siguiente_turno(cola, plantel).unidad_id).is_equal(Maestro.ID)


# (2) Una Ocarra salvaje en 0 sale del tablero: estado fuera, sin posicion, y su
# casilla queda libre. Queda la atacante, asi que el combate sigue.
func test_salvaje_en_cero_sale_del_tablero() -> void:
	var plantel: Plantel = _plantel()
	var salvaje: Criatura = plantel.criatura("ocarra_s1")
	var turno: Turno = _turno(plantel, "rodauva_1")
	var ataque: ResultadoAccion = turno.aplicar(Accion.atacar("ocarra_s1"))
	_assert_valida(ataque)
	assert_int(ataque.danio).is_equal(2)
	_assert_fin(ataque, FinCombate.Fin.EN_CURSO)
	assert_int(salvaje.vida).is_equal(0)
	assert_int(salvaje.estado).is_equal(Criatura.Estado.FUERA)
	assert_that(salvaje.posicion).is_equal(Criatura.SIN_POSICION)
	_assert_rechazada(_turno(plantel, Maestro.ID).validar(Accion.atacar("ocarra_s1")), ResultadoAccion.Motivo.OBJETIVO_FUERA_DEL_TABLERO)

	assert_array(turno.casillas_para_mover()).contains([Vector2i(2, 5)])
	_assert_valida(turno.aplicar(Accion.mover(Vector2i(2, 5))))

	var cola: ColaIniciativa = ColaIniciativa.new()
	cola.empezar_ronda(plantel)
	assert_str(_siguiente_turno(cola, plantel).unidad_id).is_equal("ocarra_n1")


# (3) La atacante nocturna en 0 queda caida en su casilla; su pergamino sigue
# ocupado (su destino es de T30).
func test_atacante_en_cero_queda_caida() -> void:
	var plantel: Plantel = _plantel()
	var atacante: Criatura = plantel.criatura("ocarra_n1")
	var ataque: ResultadoAccion = _turno(plantel, Maestro.ID).aplicar(Accion.atacar("ocarra_n1"))
	_assert_valida(ataque)
	assert_int(ataque.danio).is_equal(4)
	_assert_fin(ataque, FinCombate.Fin.EN_CURSO)
	assert_int(atacante.vida).is_equal(0)
	assert_int(atacante.estado).is_equal(Criatura.Estado.CAIDA)
	assert_that(atacante.posicion).is_equal(Vector2i(3, 5))
	var pergamino: Pergamino = plantel.pergamino(atacante.pergamino_id)
	assert_int(pergamino.estado).is_equal(Pergamino.Estado.OCUPADO)
	assert_str(pergamino.ocupante_id).is_equal("ocarra_n1")


# (4) Con dos enemigas, tumbar a una no termina el combate; tumbar a la ultima en
# pie da la victoria, y despues toda accion se rechaza sin cambiar nada.
func test_ultima_enemiga_da_victoria() -> void:
	var plantel: Plantel = _plantel()
	_assert_fin(_turno(plantel, Maestro.ID).aplicar(Accion.atacar("ocarra_n1")), FinCombate.Fin.EN_CURSO)

	var turno: Turno = _turno(plantel, "rodauva_1")
	var ataque: ResultadoAccion = turno.aplicar(Accion.atacar("ocarra_s1"))
	_assert_valida(ataque)
	_assert_fin(ataque, FinCombate.Fin.VICTORIA)

	var antes: String = _foto(plantel)
	var mover: ResultadoAccion = turno.aplicar(Accion.mover(Vector2i(2, 5)))
	_assert_rechazada(mover, ResultadoAccion.Motivo.COMBATE_TERMINADO)
	_assert_fin(mover, FinCombate.Fin.VICTORIA)
	var otro: Turno = _turno(plantel, Maestro.ID)
	for resultado in [otro.validar(Accion.terminar()), otro.aplicar(Accion.terminar()), otro.aplicar(Accion.mover(Vector2i(4, 6)))]:
		_assert_rechazada(resultado, ResultadoAccion.Motivo.COMBATE_TERMINADO)
		_assert_fin(resultado, FinCombate.Fin.VICTORIA)
	assert_bool(otro.terminado).is_false()
	assert_str(_foto(plantel)).is_equal(antes)


# (5) Cae el Maestro: derrota en el acto, aunque queden turnos en la cola.
func test_maestro_en_cero_da_derrota() -> void:
	var escenario: Dictionary = _escenario()
	(escenario["maestro"] as Dictionary)["vida"] = 4
	var plantel: Plantel = _plantel(escenario)
	var cola: ColaIniciativa = ColaIniciativa.new()
	cola.empezar_ronda(plantel)
	_siguiente_turno(cola, plantel).aplicar(Accion.terminar())

	var turno: Turno = _siguiente_turno(cola, plantel)
	assert_str(turno.unidad_id).is_equal("ocarra_n1")
	var ataque: ResultadoAccion = turno.aplicar(Accion.atacar(Maestro.ID))
	_assert_valida(ataque)
	_assert_fin(ataque, FinCombate.Fin.DERROTA_POR_CAIDA)
	assert_int(plantel.maestro.vida).is_equal(0)
	assert_bool(plantel.maestro.caido).is_true()
	_assert_rechazada(turno.aplicar(Accion.terminar()), ResultadoAccion.Motivo.COMBATE_TERMINADO)

	assert_bool(cola.ronda_terminada()).is_false()
	turno = _siguiente_turno(cola, plantel)
	assert_str(turno.unidad_id).is_equal("rodauva_1")
	var antes: String = _foto(plantel)
	for accion in [Accion.mover(Vector2i(1, 6)), Accion.atacar("ocarra_s1"), Accion.terminar()]:
		var resultado: ResultadoAccion = turno.aplicar(accion)
		_assert_rechazada(resultado, ResultadoAccion.Motivo.COMBATE_TERMINADO)
		_assert_fin(resultado, FinCombate.Fin.DERROTA_POR_CAIDA)
	assert_str(_foto(plantel)).is_equal(antes)
