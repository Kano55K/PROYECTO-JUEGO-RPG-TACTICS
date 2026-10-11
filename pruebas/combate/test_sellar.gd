extends GdUnitTestSuite

# Arquitectura.md B.4 (T24), criterios 3 a 7: la accion sellar en un turno suelto,
# con fixtures (A.6, MesaSellar sobre escenario_sellar.json: Maestro en [5,6],
# balanza 2, mana 8, un pergamino en blanco). Sistema.md 4.1 a 4.3, 2.3, 11.2.1,
# 11.2.2 (S-21) y 10.2 (P-029); lecturas S-49, S-50 y S-51.
# Semillas del generador del turno (primer entero de 1 a 100): 1 -> 98 (falla aun
# con 80 %), 3 -> 45 (sale con 65 % o mas).
const _MAESTRO_EN: Vector2i = Vector2i(5, 6)
const _A_DOS: Vector2i = Vector2i(5, 4)
const _A_TRES: Vector2i = Vector2i(5, 3)
const _SEMILLA_FALLA: int = 1
const _SEMILLA_SALE: int = 3
const _ENEMIGAS: Array[String] = ["ocarra_s1", "rodauva_s1", "surcon_s1", "zancajunco_s1", "r2_s1",
		"no_sellable_s1", "atacante_1"]


# Deja de pie solo a `queda` (las demas enemigas, fuera del tablero), asi
# motivo_sellar solo puede hablar de ella.
func _solo(mesa: MesaSellar, queda: String) -> void:
	for id_enemiga in _ENEMIGAS:
		if id_enemiga != queda:
			var criatura: Criatura = mesa.plantel.criatura(id_enemiga)
			criatura.estado = Criatura.Estado.FUERA
			criatura.posicion = Criatura.SIN_POSICION


func _motivo(turno: Turno, objetivo_id: String) -> ResultadoAccion.Motivo:
	return turno.validar(Accion.sellar(objetivo_id)).motivo


# Comprueba el motivo de validar, que no cambie nada y, si compara_consulta, que
# motivo_sellar diga lo mismo.
func _caso(mesa: MesaSellar, turno: Turno, objetivo_id: String, esperado: ResultadoAccion.Motivo,
		compara_consulta: bool = true) -> void:
	var antes: String = mesa.foto(turno)
	var nombre: String = ResultadoAccion.Motivo.keys()[esperado]
	assert_int(_motivo(turno, objetivo_id)).override_failure_message(nombre).is_equal(esperado)
	assert_str(mesa.foto(turno)).override_failure_message(nombre).is_equal(antes)
	if compara_consulta:
		assert_int(turno.motivo_sellar()).override_failure_message("motivo_sellar " + nombre).is_equal(esperado)


# (3) Un caso por motivo, en el orden de _motivo_sellar. motivo_sellar no tiene
# objetivo: no puede dar inexistente ni de la tribu, y con la unica enemiga
# fuera o caida el combate ya termino; en esos casos solo se mira validar.
func test_un_caso_por_motivo_en_orden() -> void:
	# 1 Turno terminado.
	var mesa: MesaSellar = MesaSellar.new({Maestro.ID: _MAESTRO_EN, "ocarra_s1": _A_DOS})
	var turno: Turno = mesa.turno()
	assert_bool(turno.aplicar(Accion.terminar()).valida).is_true()
	_caso(mesa, turno, "ocarra_s1", ResultadoAccion.Motivo.TURNO_TERMINADO)
	# 2 Solo el Maestro.
	mesa = MesaSellar.new({Maestro.ID: _MAESTRO_EN, "ocarra_s1": _A_DOS, "rodauva_1": Vector2i(6, 6)})
	_caso(mesa, mesa.turno("rodauva_1"), "ocarra_s1", ResultadoAccion.Motivo.SOLO_MAESTRO)
	# 3 Accion usada (un Remiendo sobre si mismo, que cura 0: S-45).
	mesa = MesaSellar.new({Maestro.ID: _MAESTRO_EN, "ocarra_s1": _A_DOS})
	turno = mesa.turno()
	assert_bool(turno.aplicar(Accion.hechizo("remiendo", Maestro.ID)).valida).is_true()
	_caso(mesa, turno, "ocarra_s1", ResultadoAccion.Motivo.ACCION_USADA)
	# 4 Sin pergamino en blanco.
	mesa = MesaSellar.new({Maestro.ID: _MAESTRO_EN, "ocarra_s1": _A_DOS})
	mesa.plantel.pergamino_en_blanco().ocupar("otra")
	_caso(mesa, mesa.turno(), "ocarra_s1", ResultadoAccion.Motivo.SIN_PERGAMINO)
	# 5 Objetivo inexistente.
	mesa = MesaSellar.new({Maestro.ID: _MAESTRO_EN, "ocarra_s1": _A_DOS})
	_caso(mesa, mesa.turno(), "nadie", ResultadoAccion.Motivo.OBJETIVO_INEXISTENTE, false)
	# 6 De la tribu.
	mesa = MesaSellar.new({Maestro.ID: _MAESTRO_EN, "ocarra_s1": _A_DOS, "rodauva_1": Vector2i(6, 6)})
	_caso(mesa, mesa.turno(), "rodauva_1", ResultadoAccion.Motivo.OBJETIVO_ALIADO, false)
	# 7 Fuera del tablero, caida y oculta (Objetivos HOSTIL, S-21).
	mesa = MesaSellar.new({Maestro.ID: _MAESTRO_EN, "ocarra_s1": _A_DOS})
	var fuera: Criatura = mesa.plantel.criatura("rodauva_s1")
	fuera.estado = Criatura.Estado.FUERA
	fuera.posicion = Criatura.SIN_POSICION
	_caso(mesa, mesa.turno(), "rodauva_s1", ResultadoAccion.Motivo.OBJETIVO_FUERA_DEL_TABLERO, false)
	mesa = MesaSellar.new({Maestro.ID: _MAESTRO_EN, "ocarra_s1": _A_DOS, "atacante_1": Vector2i(6, 5)})
	mesa.plantel.criatura("atacante_1").vida = 0
	mesa.plantel.criatura("atacante_1").estado = Criatura.Estado.CAIDA
	_caso(mesa, mesa.turno(), "atacante_1", ResultadoAccion.Motivo.OBJETIVO_CAIDO, false)
	mesa = MesaSellar.new({Maestro.ID: _MAESTRO_EN, "zancajunco_s1": _A_DOS})
	mesa.plantel.criatura("zancajunco_s1").oculta = true
	_solo(mesa, "zancajunco_s1")
	_caso(mesa, mesa.turno(), "zancajunco_s1", ResultadoAccion.Motivo.OBJETIVO_OCULTO)
	# 8 No es salvaje (la atacante nocturna: T30).
	mesa = MesaSellar.new({Maestro.ID: _MAESTRO_EN, "atacante_1": _A_DOS})
	_solo(mesa, "atacante_1")
	_caso(mesa, mesa.turno(), "atacante_1", ResultadoAccion.Motivo.OBJETIVO_NO_SALVAJE)
	# 9 Fuera de alcance (distancia 3).
	mesa = MesaSellar.new({Maestro.ID: _MAESTRO_EN, "ocarra_s1": _A_TRES})
	_solo(mesa, "ocarra_s1")
	_caso(mesa, mesa.turno(), "ocarra_s1", ResultadoAccion.Motivo.FUERA_DE_ALCANCE)
	# 10 No sellable.
	mesa = MesaSellar.new({Maestro.ID: _MAESTRO_EN, "no_sellable_s1": _A_DOS})
	_solo(mesa, "no_sellable_s1")
	_caso(mesa, mesa.turno(), "no_sellable_s1", ResultadoAccion.Motivo.NO_SELLABLE)
	# 11 Rango alto (balanza 1: rango maximo 1; la objetivo es de rango 2).
	mesa = MesaSellar.new({Maestro.ID: _MAESTRO_EN, "r2_s1": _A_DOS}, 1)
	_solo(mesa, "r2_s1")
	_caso(mesa, mesa.turno(), "r2_s1", ResultadoAccion.Motivo.RANGO_ALTO)
	# 12 Mana insuficiente (2 contra un costo de 3).
	mesa = MesaSellar.new({Maestro.ID: _MAESTRO_EN, "ocarra_s1": _A_DOS})
	_solo(mesa, "ocarra_s1")
	turno = mesa.turno()
	mesa.plantel.maestro.mana = 2
	_caso(mesa, turno, "ocarra_s1", ResultadoAccion.Motivo.MANA_INSUFICIENTE)
	# Y con todo en orden, vale.
	mesa = MesaSellar.new({Maestro.ID: _MAESTRO_EN, "ocarra_s1": _A_DOS})
	_caso(mesa, mesa.turno(), "ocarra_s1", ResultadoAccion.Motivo.NINGUNO)


# (3) motivo_sellar con varias enemigas: la que mas lejos llego en el orden
# (fuera de alcance gana a no salvaje), y NINGUNO si alguna vale.
func test_motivo_sellar_dice_la_que_mas_lejos_llego() -> void:
	var mesa: MesaSellar = MesaSellar.new({Maestro.ID: _MAESTRO_EN, "atacante_1": _A_DOS, "ocarra_s1": _A_TRES})
	assert_int(mesa.turno().motivo_sellar()).is_equal(ResultadoAccion.Motivo.FUERA_DE_ALCANCE)
	mesa = MesaSellar.new({Maestro.ID: _MAESTRO_EN, "ocarra_s1": _A_DOS})
	assert_int(mesa.turno().motivo_sellar()).is_equal(ResultadoAccion.Motivo.NINGUNO)


# (4) No son objetivo: oculta, caida, de la tribu, atacante nocturna, no
# sellable, rango alto y distancia 3. La de distancia 2, si.
func test_quienes_no_son_objetivo() -> void:
	var mesa: MesaSellar = MesaSellar.new({Maestro.ID: _MAESTRO_EN, "ocarra_s1": _A_DOS,
			"zancajunco_s1": Vector2i(4, 5), "rodauva_1": Vector2i(6, 6), "atacante_1": Vector2i(6, 5),
			"no_sellable_s1": Vector2i(4, 6), "r2_s1": Vector2i(3, 6), "rodauva_s1": Vector2i(8, 6)}, 1)
	mesa.plantel.criatura("zancajunco_s1").oculta = true
	assert_array(mesa.turno().objetivos_para_sellar()).contains_exactly(["ocarra_s1"])
	# La caida (solo la atacante cae: una salvaje en 0 sale del tablero, 11.5).
	mesa = MesaSellar.new({Maestro.ID: _MAESTRO_EN, "ocarra_s1": _A_DOS, "atacante_1": Vector2i(6, 5)})
	mesa.plantel.criatura("atacante_1").vida = 0
	mesa.plantel.criatura("atacante_1").estado = Criatura.Estado.CAIDA
	assert_array(mesa.turno().objetivos_para_sellar()).contains_exactly(["ocarra_s1"])


# (5) Falla (5 % con la vida completa, semilla 1 -> 98): el mana se pierde, el
# pergamino sigue en blanco (S-49), la accion queda usada y el movimiento entero.
func test_fallo() -> void:
	var mesa: MesaSellar = MesaSellar.new({Maestro.ID: _MAESTRO_EN, "ocarra_s1": _A_DOS})
	var turno: Turno = mesa.turno(Maestro.ID, GeneradorAzar.new(_SEMILLA_FALLA))
	var pasos: int = turno.pasos_restantes
	var resultado: ResultadoAccion = turno.aplicar(Accion.sellar("ocarra_s1"))
	assert_bool(resultado.valida).is_true()
	assert_int(resultado.porcentaje).is_equal(5)
	assert_int(resultado.costo).is_equal(3)
	assert_dict(resultado.mana).is_equal({"de": 8, "a": 5})
	assert_dict(resultado.evento).is_equal({"tipo": "sellado", "objetivo": "ocarra_s1", "porcentaje": 5, "tiro": 98,
			"resultado": "fallido", "pergamino": null})
	assert_int(mesa.plantel.maestro.mana).is_equal(5)
	assert_object(mesa.plantel.pergamino_en_blanco()).is_not_null()
	assert_str(mesa.plantel.criatura("ocarra_s1").pergamino_id).is_empty()
	assert_int(mesa.plantel.criatura("ocarra_s1").estado).is_equal(Criatura.Estado.SUELTA)
	assert_bool(turno.accion_usada).is_true()
	assert_int(turno.pasos_restantes).is_equal(pasos)
	assert_bool(turno.validar(Accion.mover(Vector2i(5, 7))).valida).is_true()
	assert_int(_motivo(turno, "ocarra_s1")).is_equal(ResultadoAccion.Motivo.ACCION_USADA)


# (5) S-51: erizada no cambia el % (Rodauva con 3 de 8: 26-50 %, rango 1 -> 50 %).
func test_erizada_da_el_mismo_porcentaje() -> void:
	var mesa: MesaSellar = MesaSellar.new({Maestro.ID: _MAESTRO_EN, "rodauva_s1": _A_DOS})
	mesa.plantel.criatura("rodauva_s1").vida = 3
	var sin_erizar: ResultadoAccion = mesa.turno().previsualizar_sellar("rodauva_s1")
	mesa.plantel.criatura("rodauva_s1").erizada = true
	var erizada: ResultadoAccion = mesa.turno().previsualizar_sellar("rodauva_s1")
	assert_int(sin_erizar.porcentaje).is_equal(50)
	assert_int(erizada.porcentaje).is_equal(sin_erizar.porcentaje)
	assert_int(erizada.costo).is_equal(sin_erizar.costo)


# (6) Sale (Surcon con 3 de 24: <= 25 %, rango 2 -> 65 %; semilla 3 -> 45): queda
# fuera, ocupa el pergamino en blanco, sus surcos se cierran y la cadena que la
# tenia de objetivo se corta por objetivo_fuera (P-029). Era la ultima: victoria.
func test_exito() -> void:
	var mesa: MesaSellar = MesaSellar.new({Maestro.ID: _MAESTRO_EN, "surcon_s1": _A_DOS,
			"rodauva_1": Vector2i(5, 5)})
	_solo(mesa, "surcon_s1")
	var surcon: Criatura = mesa.plantel.criatura("surcon_s1")
	surcon.vida = 5
	mesa.surcos.cavar(Vector2i(4, 4), "surcon_s1", 2)
	mesa.surcos.cavar(Vector2i(6, 4), "surcon_s1", 2)
	# La Rodauva de la tribu le pega (2): empieza la cadena sobre el Surcon.
	assert_bool(mesa.turno("rodauva_1").aplicar(Accion.atacar("surcon_s1")).valida).is_true()
	assert_int(surcon.vida).is_equal(3)
	assert_object(mesa.cadena.instantanea()).is_not_null()
	var blanco: Pergamino = mesa.plantel.pergamino_en_blanco()
	var turno: Turno = mesa.turno(Maestro.ID, GeneradorAzar.new(_SEMILLA_SALE))
	var resultado: ResultadoAccion = turno.aplicar(Accion.sellar("surcon_s1"))
	assert_dict(resultado.evento).is_equal({"tipo": "sellado", "objetivo": "surcon_s1", "porcentaje": 65, "tiro": 45,
			"resultado": "logrado", "pergamino": blanco.id})
	assert_int(surcon.estado).is_equal(Criatura.Estado.FUERA)
	assert_that(surcon.posicion).is_equal(Criatura.SIN_POSICION)
	assert_int(blanco.estado).is_equal(Pergamino.Estado.OCUPADO)
	assert_str(blanco.ocupante_id).is_equal("surcon_s1")
	assert_str(surcon.pergamino_id).is_equal(blanco.id)
	assert_array(mesa.surcos.de("surcon_s1")).is_empty()
	var cerrados: int = 0
	for evento in mesa.surcos.historial():
		if evento["tipo"] == "surco_cerrado":
			cerrados += 1
			assert_str(evento["motivo"]).is_equal(Surcos.MOTIVO_DUENIO_FUERA)
	assert_int(cerrados).is_equal(2)
	var historial: Array[Dictionary] = mesa.cadena.historial()
	assert_str(historial[historial.size() - 1]["motivo"]).is_equal(Cadena.MOTIVO_OBJETIVO_FUERA)
	assert_int(resultado.fin).is_equal(FinCombate.Fin.VICTORIA)


# (6) Con otra enemiga de pie, sellar no termina el combate.
func test_exito_sin_ser_la_ultima_sigue_el_combate() -> void:
	var mesa: MesaSellar = MesaSellar.new({Maestro.ID: _MAESTRO_EN, "rodauva_s1": _A_DOS})
	mesa.plantel.criatura("rodauva_s1").vida = 1
	var resultado: ResultadoAccion = mesa.turno(Maestro.ID, GeneradorAzar.new(_SEMILLA_SALE)) \
			.aplicar(Accion.sellar("rodauva_s1"))
	assert_str(resultado.evento["resultado"]).is_equal(Sellado.RESULTADO_LOGRADO)
	assert_int(resultado.fin).is_equal(FinCombate.Fin.EN_CURSO)


# (7) S-50: con 0 % (rango 2 con la vida completa) no hay tirada, falla y el mana
# se gasta igual.
func test_cero_por_ciento_sin_tirada() -> void:
	var mesa: MesaSellar = MesaSellar.new({Maestro.ID: _MAESTRO_EN, "r2_s1": _A_DOS})
	var azar: GeneradorAzar = GeneradorAzar.new(_SEMILLA_SALE)
	var turno: Turno = mesa.turno(Maestro.ID, azar)
	var tiradas: int = azar.historial().size()
	var resultado: ResultadoAccion = turno.aplicar(Accion.sellar("r2_s1"))
	assert_int(resultado.porcentaje).is_equal(0)
	assert_int(azar.historial().size()).is_equal(tiradas)
	assert_dict(resultado.evento).is_equal({"tipo": "sellado", "objetivo": "r2_s1", "porcentaje": 0, "tiro": null,
			"resultado": "fallido", "pergamino": null})
	assert_int(mesa.plantel.maestro.mana).is_equal(3)
	assert_bool(turno.accion_usada).is_true()


# Accion.sellar ida y vuelta (registro y grabacion, A.7).
func test_accion_sellar_como_diccionario() -> void:
	var accion: Accion = Accion.sellar("ocarra_s1")
	assert_dict(accion.a_diccionario()).is_equal({"tipo": "sellar", "objetivo": "ocarra_s1"})
	var vuelta: Accion = Accion.desde_diccionario(accion.a_diccionario())
	assert_int(vuelta.tipo).is_equal(Accion.Tipo.SELLAR)
	assert_str(vuelta.objetivo_id).is_equal("ocarra_s1")
	assert_object(Accion.desde_diccionario({"tipo": "sellar"})).is_null()
	assert_bool(accion.gasta_turno_completo()).is_false()
