extends GdUnitTestSuite

# Arquitectura.md B.3 (T22), criterios 4, 5, 6, 9 y 10: la Lanzadera, con
# fixtures (A.6). Sistema.md 1.6 (y sus casos borde), 10.2, 11.2.1, 11.2.2,
# 11.3 y 11.5, y S-46 a S-48. Numeros de los fixtures (escala vieja, D-009):
# costo 2, alcance 2, 1 casilla, choque 1 (4 con hechizos_choque_4.json).
const _L: String = "lanzadera"
const _EMPUJAR: String = "empujar"
const _ATRAER: String = "atraer"


func _valida(resultado: ResultadoAccion) -> void:
	assert_bool(resultado.valida).override_failure_message(
			"rechazada: " + ResultadoAccion.Motivo.keys()[resultado.motivo]).is_true()


func _rechazada(resultado: ResultadoAccion, motivo: ResultadoAccion.Motivo) -> void:
	assert_bool(resultado.valida).is_false()
	assert_str(ResultadoAccion.Motivo.keys()[resultado.motivo]).is_equal(ResultadoAccion.Motivo.keys()[motivo])


# Aplica la Lanzadera y comprueba que lo previsto es lo aplicado: el evento y las
# ocultas que destaparia (los destapes que produjo).
func _lanzar(turno: Turno, objetivo_id: String, sentido: String) -> ResultadoAccion:
	var previsto: ResultadoAccion = turno.previsualizar_hechizo(_L, objetivo_id, sentido)
	_valida(previsto)
	var antes: int = turno.eventos().size()
	var aplicado: ResultadoAccion = turno.aplicar(Accion.hechizo(_L, objetivo_id, sentido))
	_valida(aplicado)
	assert_dict(aplicado.evento).is_equal(previsto.evento)
	assert_dict(aplicado.mana).is_equal(previsto.mana)
	var destapadas: Array[String] = []
	var eventos: Array[Dictionary] = turno.eventos()
	for indice in range(antes, eventos.size()):
		if eventos[indice]["tipo"] == "destape":
			destapadas.append(eventos[indice]["unidad"])
	assert_array(destapadas).is_equal(previsto.destaparia)
	return aplicado


func _assert_choca(resultado: ResultadoAccion, objetivo_id: String, desde: Vector2i, danio: int,
		vida_antes: int) -> void:
	assert_dict(resultado.evento).is_equal({"tipo": "lanzadera", "objetivo": objetivo_id, "sentido":
			resultado.evento["sentido"], "desde": [desde.x, desde.y], "hasta": null, "choque": true, "danio": danio,
			"vida_antes": vida_antes, "vida_despues": maxi(0, vida_antes - danio)})


# Criterio 4: en linea a 1 y a 2, si; en diagonal o a 3, no (1.6, D-001).
func test_en_linea_a_1_y_a_2() -> void:
	var mesa: MesaHechizos = MesaHechizos.new({Maestro.ID: Vector2i(3, 4), "ocarra_s1": Vector2i(3, 3)})
	var turno: Turno = mesa.turno()
	assert_array(turno.sentidos_para_hechizo(_L, "ocarra_s1")).contains_exactly([_EMPUJAR])
	var ocarra: Criatura = mesa.plantel.criatura("ocarra_s1")
	ocarra.posicion = Vector2i(3, 2)
	assert_array(turno.sentidos_para_hechizo(_L, "ocarra_s1")).contains_exactly([_EMPUJAR, _ATRAER])
	ocarra.posicion = Vector2i(1, 4)
	assert_array(turno.sentidos_para_hechizo(_L, "ocarra_s1")).contains_exactly([_EMPUJAR, _ATRAER])
	ocarra.posicion = Vector2i(4, 3)
	_rechazada(turno.validar(Accion.hechizo(_L, "ocarra_s1", _EMPUJAR)), ResultadoAccion.Motivo.FUERA_DE_ALCANCE)
	ocarra.posicion = Vector2i(3, 1)
	_rechazada(turno.validar(Accion.hechizo(_L, "ocarra_s1", _EMPUJAR)), ResultadoAccion.Motivo.FUERA_DE_ALCANCE)


# Criterio 4: una enemiga en el medio bloquea la linea; una aliada no (11.3).
func test_enemiga_en_el_medio_bloquea_y_aliada_no() -> void:
	var mesa: MesaHechizos = MesaHechizos.new({Maestro.ID: Vector2i(3, 4), "rodauva_s1": Vector2i(3, 3),
			"ocarra_s1": Vector2i(3, 2)})
	var turno: Turno = mesa.turno()
	_rechazada(turno.validar(Accion.hechizo(_L, "ocarra_s1", _EMPUJAR)), ResultadoAccion.Motivo.LINEA_BLOQUEADA)
	mesa.plantel.criatura("rodauva_s1").posicion = Vector2i(0, 1)
	mesa.plantel.criatura("rodauva_1").posicion = Vector2i(3, 3)
	_valida(turno.validar(Accion.hechizo(_L, "ocarra_s1", _EMPUJAR)))


# Criterio 4 y S-48: atraer a una adyacente se rechaza; empujarla vale.
func test_atraer_a_una_adyacente_no() -> void:
	var mesa: MesaHechizos = MesaHechizos.new({Maestro.ID: Vector2i(3, 4), "ocarra_s1": Vector2i(3, 3)})
	var turno: Turno = mesa.turno()
	var foto: String = mesa.foto(turno)
	_rechazada(turno.aplicar(Accion.hechizo(_L, "ocarra_s1", _ATRAER)), ResultadoAccion.Motivo.ATRAER_ADYACENTE)
	assert_str(mesa.foto(turno)).is_equal(foto)
	_valida(turno.validar(Accion.hechizo(_L, "ocarra_s1", _EMPUJAR)))


# Criterio 4 y S-47: el Maestro mismo, una caida y una oculta (aunque sea
# aliada) no son objetivo; las aliadas de pie si. Sin sentido o con otro, no.
func test_objetivos_validos_y_rechazados() -> void:
	var mesa: MesaHechizos = MesaHechizos.new({Maestro.ID: Vector2i(3, 4), "rodauva_1": Vector2i(2, 4),
			"ocarra_1": Vector2i(3, 5), "zancajunco_1": Vector2i(4, 4)})
	var turno: Turno = mesa.turno()
	_rechazada(turno.validar(Accion.hechizo(_L, Maestro.ID, _EMPUJAR)), ResultadoAccion.Motivo.OBJETIVO_PROPIO)
	_valida(turno.validar(Accion.hechizo(_L, "rodauva_1", _EMPUJAR)))
	_rechazada(turno.validar(Accion.hechizo(_L, "rodauva_1", "")), ResultadoAccion.Motivo.SENTIDO_INVALIDO)
	_rechazada(turno.validar(Accion.hechizo(_L, "rodauva_1", "girar")), ResultadoAccion.Motivo.SENTIDO_INVALIDO)
	mesa.plantel.criatura("zancajunco_1").oculta = true
	_rechazada(turno.validar(Accion.hechizo(_L, "zancajunco_1", _EMPUJAR)), ResultadoAccion.Motivo.OBJETIVO_OCULTO)
	var caida: Criatura = mesa.plantel.criatura("ocarra_1")
	caida.estado = Criatura.Estado.CAIDA
	caida.vida = 0
	_rechazada(turno.validar(Accion.hechizo(_L, "ocarra_1", _EMPUJAR)), ResultadoAccion.Motivo.OBJETIVO_CAIDO)
	assert_array(turno.objetivos_para_hechizo(_L)).contains_exactly(["rodauva_1"])


# Criterio 5: contra el borde no se mueve y recibe el choque.
func test_choque_contra_el_borde() -> void:
	var mesa: MesaHechizos = MesaHechizos.new({Maestro.ID: Vector2i(3, 1), "ocarra_s1": Vector2i(3, 0)})
	var turno: Turno = mesa.turno()
	var resultado: ResultadoAccion = _lanzar(turno, "ocarra_s1", _EMPUJAR)
	_assert_choca(resultado, "ocarra_s1", Vector2i(3, 0), 1, 12)
	assert_int(mesa.plantel.criatura("ocarra_s1").vida).is_equal(11)
	assert_that(mesa.plantel.criatura("ocarra_s1").posicion).is_equal(Vector2i(3, 0))
	assert_int(mesa.plantel.maestro.mana).is_equal(6)


# Criterio 5: contra una unidad de pie o caida; solo la movida recibe el choque (1.6).
func test_choque_contra_una_unidad_de_pie_o_caida() -> void:
	var mesa: MesaHechizos = MesaHechizos.new({Maestro.ID: Vector2i(3, 5), "ocarra_s1": Vector2i(3, 4),
			"rodauva_s1": Vector2i(3, 3)})
	_assert_choca(_lanzar(mesa.turno(), "ocarra_s1", _EMPUJAR), "ocarra_s1", Vector2i(3, 4), 1, 12)
	assert_int(mesa.plantel.criatura("rodauva_s1").vida).is_equal(8)

	mesa = MesaHechizos.new({Maestro.ID: Vector2i(3, 5), "ocarra_s1": Vector2i(3, 4), "rodauva_1": Vector2i(3, 3)})
	var caida: Criatura = mesa.plantel.criatura("rodauva_1")
	caida.estado = Criatura.Estado.CAIDA
	caida.vida = 0
	_assert_choca(_lanzar(mesa.turno(), "ocarra_s1", _EMPUJAR), "ocarra_s1", Vector2i(3, 4), 1, 12)


# Criterio 5 y 11.2.1: un surco cuenta como ocupada para la que no es Surcon.
func test_choque_contra_un_surco() -> void:
	var mesa: MesaHechizos = MesaHechizos.new({Maestro.ID: Vector2i(3, 5), "ocarra_s1": Vector2i(3, 4)})
	mesa.surcos.cavar(Vector2i(3, 3), "surcon_s1", 2)
	_assert_choca(_lanzar(mesa.turno(), "ocarra_s1", _EMPUJAR), "ocarra_s1", Vector2i(3, 4), 1, 12)
	assert_that(mesa.plantel.criatura("ocarra_s1").posicion).is_equal(Vector2i(3, 4))


# Criterio 5: atraer a distancia 2 con una aliada en el medio choca contra ella.
func test_atraer_a_2_con_una_aliada_en_el_medio_choca() -> void:
	var mesa: MesaHechizos = MesaHechizos.new({Maestro.ID: Vector2i(3, 5), "rodauva_1": Vector2i(3, 4),
			"ocarra_s1": Vector2i(3, 3)})
	_assert_choca(_lanzar(mesa.turno(), "ocarra_s1", _ATRAER), "ocarra_s1", Vector2i(3, 3), 1, 12)
	assert_int(mesa.plantel.criatura("rodauva_1").vida).is_equal(8)


# Criterio 5 y S-46: el choque es fijo, sin modificadores: la erizada lo recibe
# entero (4, no 2) y sigue erizada; el Tasajero en Caza tambien (4, no 5).
func test_choque_entero_a_una_erizada_y_al_tasajero() -> void:
	var mesa: MesaHechizos = MesaHechizos.new({Maestro.ID: Vector2i(3, 1), "rodauva_s1": Vector2i(3, 0)})
	mesa.reglas = DatosFixture.reglas({"hechizos": DatosFixture.hechizos("hechizos_choque_4.json")})
	mesa.plantel.criatura("rodauva_s1").erizada = true
	_assert_choca(_lanzar(mesa.turno(), "rodauva_s1", _EMPUJAR), "rodauva_s1", Vector2i(3, 0), 4, 8)
	assert_int(mesa.plantel.criatura("rodauva_s1").vida).is_equal(4)
	assert_bool(mesa.plantel.criatura("rodauva_s1").erizada).is_true()

	mesa = MesaHechizos.new({Maestro.ID: Vector2i(3, 1), "tasajero_s1": Vector2i(3, 0)})
	mesa.reglas = DatosFixture.reglas({"hechizos": DatosFixture.hechizos("hechizos_choque_4.json")})
	_assert_choca(_lanzar(mesa.turno(), "tasajero_s1", _EMPUJAR), "tasajero_s1", Vector2i(3, 0), 4, 30)
	assert_int(mesa.plantel.criatura("tasajero_s1").vida).is_equal(26)


# Criterio 5 y 11.2.1: a un Surcon el surco no lo frena (cualquier bando); los
# surcos quedan donde estaban.
func test_un_surcon_sobre_un_surco_se_mueve() -> void:
	var mesa: MesaHechizos = MesaHechizos.new({Maestro.ID: Vector2i(3, 5), "surcon_1": Vector2i(3, 4)})
	mesa.surcos.cavar(Vector2i(3, 3), "surcon_s1", 2)
	var surcos_antes: Array = mesa.surcos.instantanea()
	var resultado: ResultadoAccion = _lanzar(mesa.turno(), "surcon_1", _EMPUJAR)
	assert_bool(resultado.evento["choque"]).is_false()
	assert_array(resultado.evento["hasta"]).is_equal([3, 3])
	assert_int(resultado.evento["danio"]).is_equal(0)
	assert_that(mesa.plantel.criatura("surcon_1").posicion).is_equal(Vector2i(3, 3))
	assert_array(mesa.surcos.instantanea()).is_equal(surcos_antes)


# Criterio 5 y 11.5: un choque que tumba a una salvaje la saca del tablero.
func test_choque_que_tumba_a_una_salvaje() -> void:
	var mesa: MesaHechizos = MesaHechizos.new({Maestro.ID: Vector2i(3, 1), "ocarra_s1": Vector2i(3, 0)})
	mesa.plantel.criatura("ocarra_s1").vida = 1
	_assert_choca(_lanzar(mesa.turno(), "ocarra_s1", _EMPUJAR), "ocarra_s1", Vector2i(3, 0), 1, 1)
	assert_int(mesa.plantel.criatura("ocarra_s1").estado).is_equal(Criatura.Estado.FUERA)
	assert_that(mesa.plantel.criatura("ocarra_s1").posicion).is_equal(Criatura.SIN_POSICION)


# Criterio 5 y 11.2.1: un Surcon salvaje tumbado cierra sus surcos.
func test_choque_que_tumba_a_un_surcon_cierra_sus_surcos() -> void:
	var mesa: MesaHechizos = MesaHechizos.new({Maestro.ID: Vector2i(3, 1), "surcon_s1": Vector2i(3, 0)})
	mesa.surcos.cavar(Vector2i(5, 3), "surcon_s1", 2)
	mesa.plantel.criatura("surcon_s1").vida = 1
	_lanzar(mesa.turno(), "surcon_s1", _EMPUJAR)
	assert_int(mesa.plantel.criatura("surcon_s1").estado).is_equal(Criatura.Estado.FUERA)
	assert_array(mesa.surcos.instantanea()).is_empty()
	assert_str(mesa.surcos.historial().back()["tipo"]).is_equal("surco_cerrado")
	assert_str(mesa.surcos.historial().back()["motivo"]).is_equal("duenio_fuera")


# Criterio 5 y 11.5: a una aliada la deja caida en su casilla.
func test_choque_que_tumba_a_una_aliada() -> void:
	var mesa: MesaHechizos = MesaHechizos.new({Maestro.ID: Vector2i(3, 1), "rodauva_1": Vector2i(3, 0)})
	mesa.plantel.criatura("rodauva_1").vida = 1
	_lanzar(mesa.turno(), "rodauva_1", _EMPUJAR)
	assert_int(mesa.plantel.criatura("rodauva_1").estado).is_equal(Criatura.Estado.CAIDA)
	assert_that(mesa.plantel.criatura("rodauva_1").posicion).is_equal(Vector2i(3, 0))


# Criterio 6: una erizada se mueve y conserva la marca (1.6, casos borde).
func test_mueve_a_una_erizada() -> void:
	var mesa: MesaHechizos = MesaHechizos.new({Maestro.ID: Vector2i(3, 4), "rodauva_1": Vector2i(3, 3)})
	mesa.plantel.criatura("rodauva_1").erizada = true
	var resultado: ResultadoAccion = _lanzar(mesa.turno(), "rodauva_1", _EMPUJAR)
	assert_dict(resultado.evento).is_equal({"tipo": "lanzadera", "objetivo": "rodauva_1", "sentido": _EMPUJAR,
			"desde": [3, 3], "hasta": [3, 2], "choque": false, "danio": 0, "vida_antes": 8, "vida_despues": 8})
	assert_that(mesa.plantel.criatura("rodauva_1").posicion).is_equal(Vector2i(3, 2))
	assert_bool(mesa.plantel.criatura("rodauva_1").erizada).is_true()


# Criterio 6 y 11.2.2 (S-24): dejar a una enemiga ortogonal a un Zancajunco oculto
# lo destapa por contacto; en diagonal, no.
func test_destapa_por_contacto() -> void:
	var mesa: MesaHechizos = MesaHechizos.new({Maestro.ID: Vector2i(2, 2), "ocarra_s1": Vector2i(3, 2),
			"zancajunco_1": Vector2i(5, 2)})
	mesa.plantel.criatura("zancajunco_1").oculta = true
	var turno: Turno = mesa.turno()
	var resultado: ResultadoAccion = _lanzar(turno, "ocarra_s1", _EMPUJAR)
	assert_array(resultado.destaparia).contains_exactly(["zancajunco_1"])
	assert_bool(mesa.plantel.criatura("zancajunco_1").oculta).is_false()
	assert_array(turno.eventos()).contains([{"tipo": "destape", "unidad": "zancajunco_1", "motivo": "contacto",
			"por": "ocarra_s1"}])

	mesa = MesaHechizos.new({Maestro.ID: Vector2i(2, 2), "ocarra_s1": Vector2i(3, 2), "zancajunco_1": Vector2i(5, 3)})
	mesa.plantel.criatura("zancajunco_1").oculta = true
	resultado = _lanzar(mesa.turno(), "ocarra_s1", _EMPUJAR)
	assert_array(resultado.destaparia).is_empty()
	assert_bool(mesa.plantel.criatura("zancajunco_1").oculta).is_true()


# Criterio 6 y 1.6 (no es un ataque): no cambia la cadena, el Encono ni el bono de
# Hacerse junco, ni al mover ni al chocar.
func test_no_toca_cadena_encono_ni_bono() -> void:
	var mesa: MesaHechizos = MesaHechizos.new({Maestro.ID: Vector2i(3, 4), "ocarra_1": Vector2i(1, 2),
			"ocarra_s1": Vector2i(3, 3), "zancajunco_s1": Vector2i(3, 6)})
	mesa.cadena.atacar("ocarra_1", "ocarra_s1", mesa.plantel)
	mesa.plantel.criatura("ocarra_1").encono = 2
	mesa.plantel.criatura("zancajunco_s1").bono_junco = true
	var cadena_antes: Variant = mesa.cadena.instantanea()
	var turno: Turno = mesa.turno()
	_lanzar(turno, "ocarra_s1", _EMPUJAR)
	assert_that(mesa.cadena.instantanea()).is_equal(cadena_antes)
	assert_array(mesa.cadena.historial()).is_empty()

	mesa.plantel.criatura("ocarra_s1").posicion = Vector2i(0, 1)
	mesa.plantel.criatura("zancajunco_s1").posicion = Vector2i(5, 7)
	mesa.plantel.maestro.posicion = Vector2i(5, 6)
	turno = mesa.turno()
	_lanzar(turno, "zancajunco_s1", _EMPUJAR)
	assert_bool(mesa.plantel.criatura("zancajunco_s1").bono_junco).is_true()
	assert_int(mesa.plantel.criatura("zancajunco_s1").vida).is_equal(11)
	assert_int(mesa.plantel.criatura("ocarra_1").encono).is_equal(2)
	assert_that(mesa.cadena.instantanea()).is_equal(cadena_antes)


# Criterio 9: despues de la Lanzadera, atacar u otro hechizo dan ACCION_USADA; mover vale.
func test_despues_atacar_u_otro_hechizo_no() -> void:
	var mesa: MesaHechizos = MesaHechizos.new({Maestro.ID: Vector2i(3, 4), "ocarra_s1": Vector2i(3, 3)})
	var turno: Turno = mesa.turno()
	_valida(turno.aplicar(Accion.hechizo(_L, "ocarra_s1", _EMPUJAR)))
	mesa.plantel.criatura("ocarra_s1").posicion = Vector2i(3, 3)
	_rechazada(turno.validar(Accion.atacar("ocarra_s1")), ResultadoAccion.Motivo.ACCION_USADA)
	_rechazada(turno.validar(Accion.hechizo("martillazo", "ocarra_s1")), ResultadoAccion.Motivo.ACCION_USADA)
	_valida(turno.validar(Accion.mover(Vector2i(4, 4))))


# Criterio 10: previsualizar no cambia la instantanea, el mana ni los surcos.
func test_previsualizar_no_cambia_nada() -> void:
	var mesa: MesaHechizos = MesaHechizos.new({Maestro.ID: Vector2i(2, 2), "ocarra_s1": Vector2i(3, 2),
			"zancajunco_1": Vector2i(5, 2), "rodauva_s1": Vector2i(0, 2)})
	mesa.plantel.criatura("zancajunco_1").oculta = true
	var turno: Turno = mesa.turno()
	var foto: String = mesa.foto(turno)
	assert_array(turno.previsualizar_hechizo(_L, "ocarra_s1", _EMPUJAR).destaparia).contains_exactly(["zancajunco_1"])
	assert_bool(turno.previsualizar_hechizo(_L, "rodauva_s1", _EMPUJAR).evento["choque"]).is_true()
	turno.objetivos_para_hechizo(_L)
	assert_str(mesa.foto(turno)).is_equal(foto)
	assert_array(turno.eventos()).is_empty()
