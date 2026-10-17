extends GdUnitTestSuite

# Arquitectura.md B.3 (T22), criterios 2, 3 y 10: el Martillazo, con fixtures
# (A.6). Sistema.md 1.6, 10.2, 10.3, 11.2, 11.2.2, 11.2.3, 11.4 y 11.5, y S-47.
# Numeros de los fixtures (escala vieja, D-009): Martillazo 2 + 1 x Poder (3 con
# Poder 1, 5 con Poder 3), costo 2, alcance 3; Maestro de balanza 2 con 8 de mana.
const _M: String = "martillazo"


func _valida(resultado: ResultadoAccion) -> void:
	assert_bool(resultado.valida).override_failure_message(
			"rechazada: " + ResultadoAccion.Motivo.keys()[resultado.motivo]).is_true()


func _rechazada(resultado: ResultadoAccion, motivo: ResultadoAccion.Motivo) -> void:
	assert_bool(resultado.valida).is_false()
	assert_str(ResultadoAccion.Motivo.keys()[resultado.motivo]).is_equal(ResultadoAccion.Motivo.keys()[motivo])


# Lo previsto (validar) es lo aplicado, y el danio es el del desglose.
func _martillazo(mesa: MesaHechizos, turno: Turno, objetivo_id: String) -> ResultadoAccion:
	var previsto: ResultadoAccion = turno.previsualizar_hechizo(_M, objetivo_id)
	_valida(previsto)
	var aplicado: ResultadoAccion = turno.aplicar(Accion.hechizo(_M, objetivo_id))
	_valida(aplicado)
	assert_dict(aplicado.desglose.a_diccionario()).is_equal(previsto.desglose.a_diccionario())
	assert_int(aplicado.danio).is_equal(aplicado.desglose.total)
	return aplicado


# Criterio 2: Manhattan <= 3, sin pedir linea recta; a 4, no.
func test_alcance_al_limite_y_uno_mas() -> void:
	var mesa: MesaHechizos = MesaHechizos.new({Maestro.ID: Vector2i(3, 6), "ocarra_s1": Vector2i(3, 3)})
	var turno: Turno = mesa.turno()
	_valida(turno.validar(Accion.hechizo(_M, "ocarra_s1")))
	mesa.plantel.criatura("ocarra_s1").posicion = Vector2i(2, 4)
	_valida(turno.validar(Accion.hechizo(_M, "ocarra_s1")))
	mesa.plantel.criatura("ocarra_s1").posicion = Vector2i(3, 2)
	_rechazada(turno.validar(Accion.hechizo(_M, "ocarra_s1")), ResultadoAccion.Motivo.FUERA_DE_ALCANCE)


# Criterio 2: sin bloqueo, ni por una enemiga en el medio ni por un surco (11.2.1).
func test_pasa_por_encima_de_una_enemiga_y_de_un_surco() -> void:
	var mesa: MesaHechizos = MesaHechizos.new({Maestro.ID: Vector2i(3, 6), "rodauva_s1": Vector2i(3, 5),
			"ocarra_s1": Vector2i(3, 3)})
	mesa.surcos.cavar(Vector2i(3, 4), "surcon_s1", 2)
	_valida(mesa.turno().validar(Accion.hechizo(_M, "ocarra_s1")))


# Criterio 2 y S-47: solo a enemigas que la consulta unica acepta como hostiles.
func test_objetivos_rechazados_con_su_motivo() -> void:
	var mesa: MesaHechizos = MesaHechizos.new({Maestro.ID: Vector2i(3, 6), "rodauva_1": Vector2i(3, 5),
			"ocarra_s1": Vector2i(3, 4), "zancajunco_s1": Vector2i(2, 5), "rodauva_s1": Vector2i(4, 5)})
	var turno: Turno = mesa.turno()
	_rechazada(turno.aplicar(Accion.hechizo(_M, "rodauva_1")), ResultadoAccion.Motivo.OBJETIVO_ALIADO)
	_rechazada(turno.aplicar(Accion.hechizo(_M, Maestro.ID)), ResultadoAccion.Motivo.OBJETIVO_PROPIO)
	_rechazada(turno.aplicar(Accion.hechizo(_M, "nadie")), ResultadoAccion.Motivo.OBJETIVO_INEXISTENTE)
	mesa.plantel.criatura("zancajunco_s1").oculta = true
	_rechazada(turno.aplicar(Accion.hechizo(_M, "zancajunco_s1")), ResultadoAccion.Motivo.OBJETIVO_OCULTO)
	var caida: Criatura = mesa.plantel.criatura("rodauva_s1")
	caida.estado = Criatura.Estado.CAIDA
	caida.vida = 0
	_rechazada(turno.aplicar(Accion.hechizo(_M, "rodauva_s1")), ResultadoAccion.Motivo.OBJETIVO_CAIDO)
	var fuera: Criatura = mesa.plantel.criatura("ocarra_s1")
	fuera.estado = Criatura.Estado.FUERA
	fuera.posicion = Criatura.SIN_POSICION
	_rechazada(turno.aplicar(Accion.hechizo(_M, "ocarra_s1")), ResultadoAccion.Motivo.OBJETIVO_FUERA_DEL_TABLERO)
	_rechazada(turno.aplicar(Accion.hechizo("bola_de_fuego", "ocarra_s1")), ResultadoAccion.Motivo.HECHIZO_INEXISTENTE)
	# Los rechazos no gastaron la accion ni el mana.
	assert_bool(turno.accion_usada).is_false()
	assert_int(mesa.plantel.maestro.mana).is_equal(8)


# Sistema.md 1.6: solo el Maestro lanza hechizos; un sentido sobra en el Martillazo.
func test_solo_el_maestro_y_sin_sentido() -> void:
	var mesa: MesaHechizos = MesaHechizos.new({Maestro.ID: Vector2i(3, 6), "rodauva_1": Vector2i(2, 4),
			"ocarra_s1": Vector2i(3, 4)})
	_rechazada(mesa.turno("rodauva_1").validar(Accion.hechizo(_M, "ocarra_s1")), ResultadoAccion.Motivo.SOLO_MAESTRO)
	_rechazada(mesa.turno().validar(Accion.hechizo(_M, "ocarra_s1", "empujar")), ResultadoAccion.Motivo.SENTIDO_INVALIDO)


# Criterio 2 y Sistema.md 1.6: gasta la accion y conserva el movimiento, antes o despues.
func test_se_mueve_antes_o_despues() -> void:
	var mesa: MesaHechizos = MesaHechizos.new({Maestro.ID: Vector2i(3, 6), "ocarra_s1": Vector2i(3, 2)})
	var turno: Turno = mesa.turno()
	_rechazada(turno.validar(Accion.hechizo(_M, "ocarra_s1")), ResultadoAccion.Motivo.FUERA_DE_ALCANCE)
	_valida(turno.aplicar(Accion.mover(Vector2i(3, 5))))
	_valida(turno.aplicar(Accion.hechizo(_M, "ocarra_s1")))

	mesa = MesaHechizos.new({Maestro.ID: Vector2i(3, 6), "ocarra_s1": Vector2i(3, 3)})
	turno = mesa.turno()
	_valida(turno.aplicar(Accion.hechizo(_M, "ocarra_s1")))
	_valida(turno.aplicar(Accion.mover(Vector2i(4, 6))))


# Criterio 2 y 8: con menos mana que el costo, rechazo con su motivo y sin cambios.
func test_sin_mana_suficiente_no_cambia_nada() -> void:
	var mesa: MesaHechizos = MesaHechizos.new({Maestro.ID: Vector2i(3, 6), "ocarra_s1": Vector2i(3, 3)})
	var turno: Turno = mesa.turno()
	mesa.plantel.maestro.mana = 1
	var foto: String = mesa.foto(turno)
	_rechazada(turno.aplicar(Accion.hechizo(_M, "ocarra_s1")), ResultadoAccion.Motivo.MANA_INSUFICIENTE)
	assert_str(mesa.foto(turno)).is_equal(foto)
	mesa.plantel.maestro.mana = 2
	_valida(turno.aplicar(Accion.hechizo(_M, "ocarra_s1")))
	assert_int(mesa.plantel.maestro.mana).is_equal(0)


# Criterio 3: la base del hechizo segun Poder (2 + 1 x Poder) reemplaza al Danio base.
func test_base_segun_poder() -> void:
	var mesa: MesaHechizos = MesaHechizos.new({Maestro.ID: Vector2i(3, 6), "ocarra_s1": Vector2i(3, 3)})
	var golpe: ResultadoAccion = _martillazo(mesa, mesa.turno(), "ocarra_s1")
	assert_int(golpe.desglose.base).is_equal(3)
	assert_int(golpe.danio).is_equal(3)
	assert_int(mesa.plantel.criatura("ocarra_s1").vida).is_equal(9)
	assert_int(mesa.plantel.maestro.mana).is_equal(6)

	mesa = MesaHechizos.new({Maestro.ID: Vector2i(3, 6), "ocarra_s1": Vector2i(3, 3)})
	mesa.plantel.maestro.poder = 3
	golpe = _martillazo(mesa, mesa.turno(), "ocarra_s1")
	assert_int(golpe.desglose.base).is_equal(5)
	assert_int(mesa.plantel.criatura("ocarra_s1").vida).is_equal(7)


# Criterio 3: -50 % contra una erizada (11.2): 5 x 0,5 = 2 (Poder 3).
func test_erizada_recibe_la_mitad() -> void:
	var mesa: MesaHechizos = MesaHechizos.new({Maestro.ID: Vector2i(3, 6), "rodauva_s1": Vector2i(3, 4)})
	mesa.plantel.maestro.poder = 3
	mesa.plantel.criatura("rodauva_s1").erizada = true
	var golpe: ResultadoAccion = _martillazo(mesa, mesa.turno(), "rodauva_s1")
	assert_int(golpe.danio).is_equal(2)
	assert_int(mesa.plantel.criatura("rodauva_s1").vida).is_equal(6)


# Criterio 3: +25 % contra el Tasajero en Caza (11.2.3): 5 x 1,25 = 6 (Poder 3).
func test_tasajero_en_caza_recibe_mas() -> void:
	var mesa: MesaHechizos = MesaHechizos.new({Maestro.ID: Vector2i(3, 6), "tasajero_s1": Vector2i(3, 4)})
	mesa.plantel.maestro.poder = 3
	var golpe: ResultadoAccion = _martillazo(mesa, mesa.turno(), "tasajero_s1")
	assert_int(golpe.danio).is_equal(6)
	assert_int(mesa.plantel.criatura("tasajero_s1").vida).is_equal(24)


# Criterio 3: la afinidad desde la casilla del Maestro, con una leal vecina en 8 (10.3): 3 + 1.
func test_suma_la_afinidad_de_una_leal_vecina() -> void:
	var mesa: MesaHechizos = MesaHechizos.new({Maestro.ID: Vector2i(3, 6), "rodauva_1": Vector2i(2, 5),
			"ocarra_s1": Vector2i(3, 3)})
	var golpe: ResultadoAccion = _martillazo(mesa, mesa.turno(), "ocarra_s1")
	assert_int(golpe.danio).is_equal(4)
	assert_bool(golpe.desglose.modificadores.any(func(m: ModificadorDanio) -> bool:
			return m.fuente == ModificadorDanio.Fuente.AFINIDAD)).is_true()


# Criterio 3 y 10.2: es un eslabon. Despues de la leal, el combo entre afines con
# balanza 2 es +70 % (40 + 3 pasos de Arrimo x 10): 3 x 1,7 = 5.
func test_recibe_el_combo_como_eslabon_2() -> void:
	var mesa: MesaHechizos = MesaHechizos.new({Maestro.ID: Vector2i(3, 6), "rodauva_1": Vector2i(3, 2),
			"ocarra_s1": Vector2i(3, 3)})
	mesa.cadena.atacar("rodauva_1", "ocarra_s1", mesa.plantel)
	mesa.plantel.criatura("ocarra_s1").vida = 10
	var golpe: ResultadoAccion = _martillazo(mesa, mesa.turno(), "ocarra_s1")
	assert_int(golpe.eslabon as int).is_equal(2)
	assert_int(golpe.desglose.porcentaje_total).is_equal(70)
	assert_int(golpe.danio).is_equal(5)
	assert_int(mesa.plantel.criatura("ocarra_s1").vida).is_equal(5)
	assert_int(mesa.cadena.instantanea()["eslabon"]).is_equal(2)


# Criterio 3 y 10.2: a otra objetivo corta la cadena con otro_objetivo y empieza otra.
func test_a_otra_objetivo_corta_la_cadena() -> void:
	var mesa: MesaHechizos = MesaHechizos.new({Maestro.ID: Vector2i(3, 6), "rodauva_1": Vector2i(1, 2),
			"ocarra_s1": Vector2i(1, 3), "rodauva_s1": Vector2i(3, 4)})
	mesa.cadena.atacar("rodauva_1", "ocarra_s1", mesa.plantel)
	var golpe: ResultadoAccion = _martillazo(mesa, mesa.turno(), "rodauva_s1")
	assert_int(golpe.eslabon as int).is_equal(1)
	var cortes: Array[Dictionary] = mesa.cadena.historial()
	assert_int(cortes.size()).is_equal(1)
	assert_str(cortes[0]["motivo"]).is_equal(Cadena.MOTIVO_OTRO_OBJETIVO)


# Criterio 3 y 11.2.2: le quita el bono a un Zancajunco destapado.
func test_le_quita_el_bono_a_un_zancajunco_destapado() -> void:
	var mesa: MesaHechizos = MesaHechizos.new({Maestro.ID: Vector2i(3, 6), "zancajunco_s1": Vector2i(3, 4)})
	mesa.plantel.criatura("zancajunco_s1").bono_junco = true
	var turno: Turno = mesa.turno()
	_martillazo(mesa, turno, "zancajunco_s1")
	assert_bool(mesa.plantel.criatura("zancajunco_s1").bono_junco).is_false()
	assert_array(turno.eventos()).contains([{"tipo": "bono_perdido", "unidad": "zancajunco_s1", "atacante": Maestro.ID}])


# Criterio 3 y 11.5: puede tumbar; la salvaje en 0 huye del tablero.
func test_puede_tumbar() -> void:
	var mesa: MesaHechizos = MesaHechizos.new({Maestro.ID: Vector2i(3, 6), "ocarra_s1": Vector2i(3, 3)})
	mesa.plantel.criatura("ocarra_s1").vida = 3
	_martillazo(mesa, mesa.turno(), "ocarra_s1")
	var ocarra: Criatura = mesa.plantel.criatura("ocarra_s1")
	assert_int(ocarra.vida).is_equal(0)
	assert_int(ocarra.estado).is_equal(Criatura.Estado.FUERA)
	assert_that(ocarra.posicion).is_equal(Criatura.SIN_POSICION)


# Criterio 9: despues del Martillazo, atacar u otro hechizo dan ACCION_USADA; mover vale.
func test_despues_atacar_u_otro_hechizo_no() -> void:
	var mesa: MesaHechizos = MesaHechizos.new({Maestro.ID: Vector2i(3, 6), "ocarra_s1": Vector2i(3, 5),
			"rodauva_1": Vector2i(2, 6)})
	var turno: Turno = mesa.turno()
	_valida(turno.aplicar(Accion.hechizo(_M, "ocarra_s1")))
	_rechazada(turno.validar(Accion.atacar("ocarra_s1")), ResultadoAccion.Motivo.ACCION_USADA)
	_rechazada(turno.validar(Accion.hechizo(_M, "ocarra_s1")), ResultadoAccion.Motivo.ACCION_USADA)
	_rechazada(turno.validar(Accion.hechizo("lanzadera", "ocarra_s1", "empujar")), ResultadoAccion.Motivo.ACCION_USADA)
	_rechazada(turno.validar(Accion.hechizo("remiendo", "rodauva_1")), ResultadoAccion.Motivo.ACCION_USADA)
	_valida(turno.validar(Accion.mover(Vector2i(4, 6))))


# Criterio 10: previsualizar no cambia la instantanea, el mana ni el generador.
func test_previsualizar_no_cambia_nada() -> void:
	var mesa: MesaHechizos = MesaHechizos.new({Maestro.ID: Vector2i(3, 6), "ocarra_s1": Vector2i(3, 3)})
	mesa.plantel.criatura("ocarra_s1").vida = 3
	var turno: Turno = mesa.turno()
	var foto: String = mesa.foto(turno)
	var previsto: ResultadoAccion = turno.previsualizar_hechizo(_M, "ocarra_s1")
	assert_int(previsto.mana["a"]).is_equal(6)
	assert_str(mesa.foto(turno)).is_equal(foto)
	assert_array(turno.objetivos_para_hechizo(_M)).contains_exactly(["ocarra_s1"])
	assert_str(mesa.foto(turno)).is_equal(foto)
