extends GdUnitTestSuite

# Arquitectura.md B.4 (T26), criterio 13, con datos/ real (A.6): en A, con el
# jugador esperando (JugadorEsperando), la Rodauva (Velocidad 6) se guarda en su
# turno de la ronda 1 y el Maestro (Velocidad 5) la invoca en su turno
# siguiente, que es de la misma ronda (S-56). La casilla sale de
# Turno.casillas_para_invocar y el costo de Combate.costo_invocar; la
# comprobacion lo cuenta de datos/tablas/costos_mana.json y tablas/balanza.json
# (Sistema.md 2.3). La invocada no vuelve a jugar en la ronda 1 y si en la 2
# (11.3). Si un dia una regla impide guardarla, no se tocan coordenadas: se anota
# en docs/PREGUNTAS.md.
const _CARPETA_DATOS: String = "res://datos"
const _A: String = "a_dia_1"
const _RODAUVA: String = "rodauva_1"
const _TOPE_ACCIONES: int = 100


func _datos() -> Dictionary:
	var carga: Dictionary = Cargador.new().cargar_carpeta(_CARPETA_DATOS)
	assert_array(carga["errores"]).override_failure_message(str(carga["errores"])).is_empty()
	return carga["datos"]


# Juega esperando hasta el turno de la unidad; false si antes termino el combate.
func _esperar_hasta(combate: Combate, unidad_id: String) -> bool:
	for _i in range(_TOPE_ACCIONES):
		assert_str(combate.error()).is_empty()
		if combate.terminado():
			return false
		if combate.turno_actual().unidad_id == unidad_id:
			return true
		assert_str(JugadorEsperando.lo_obligado(combate)).is_empty()
		if combate.terminado():
			return false
		assert_bool(combate.aplicar(Accion.terminar()).valida).is_true()
	return false


# Sistema.md 2.3, leido de los datos: la comprobacion del test.
func _costo_esperado(datos: Dictionary, rango: int, balanza: int) -> int:
	var costos: Dictionary = datos["tablas/costos_mana.json"]
	var descuento: int = 0
	for fila in (datos["tablas/balanza.json"]["posiciones"] as Array):
		if fila["posicion"] == balanza:
			descuento = fila["descuento"]
	return maxi(costos["costo_minimo"] as int, ((costos["invocar"] as Array)[rango - 1] as int) - descuento)


func test_a_la_rodauva_se_guarda_y_el_maestro_la_invoca() -> void:
	var datos: Dictionary = _datos()
	var escenario: Dictionary = datos["escenarios/%s.json" % _A]
	var contexto: ContextoCombate = ContextoCombate.armar(escenario, datos)
	assert_bool(contexto.valido).is_true()
	var combate: Combate = Combate.empezar(contexto)

	assert_bool(_esperar_hasta(combate, _RODAUVA)).is_true()
	assert_int(combate.instantanea()["ronda"]).is_equal(1)
	var turno: Turno = combate.turno_actual()
	assert_str(ResultadoAccion.Motivo.keys()[turno.motivo_guardar()]).is_equal("NINGUNO")
	assert_bool(combate.aplicar(Accion.guardar()).valida).is_true()
	assert_str(combate.error()).is_empty()

	assert_str(combate.turno_actual().unidad_id).is_equal(Maestro.ID)
	assert_int(combate.instantanea()["ronda"]).is_equal(1)
	var maestro: Turno = combate.turno_actual()
	assert_array(maestro.guardadas_para_invocar()).is_equal([_RODAUVA])
	var casillas: Array[Vector2i] = maestro.casillas_para_invocar()
	assert_array(casillas).is_not_empty()
	var costo: Variant = combate.costo_invocar(_RODAUVA)
	var rango: int = datos["especies/rodauva.json"]["rango"]
	assert_int(costo).is_equal(_costo_esperado(datos, rango, escenario["maestro"]["balanza"]))
	var mana_antes: int = combate.instantanea()["maestro"]["mana"]
	var resultado: ResultadoAccion = combate.aplicar(Accion.invocar(_RODAUVA, casillas[0]))
	assert_bool(resultado.valida).is_true()
	assert_int(resultado.costo).is_equal(costo)
	assert_int(mana_antes - (combate.instantanea()["maestro"]["mana"] as int)).is_equal(costo)
	var rodauva: Criatura = contexto.plantel.criatura(_RODAUVA)
	assert_int(rodauva.estado).is_equal(Criatura.Estado.SUELTA)
	assert_that(rodauva.posicion).is_equal(casillas[0])
	assert_bool(combate.aplicar(Accion.terminar()).valida).is_true()

	# 11.3: no vuelve a jugar en la ronda 1; su proximo turno es de la ronda 2.
	assert_bool(_esperar_hasta(combate, _RODAUVA)).is_true()
	assert_int(combate.instantanea()["ronda"]).is_equal(2)
	var turnos: Array = combate.registro().lineas().filter(func(linea: Dictionary) -> bool:
			return linea["tipo"] == "turno" and linea["unidad"] == _RODAUVA)
	assert_array(turnos.map(func(linea: Dictionary) -> int: return linea["ronda"])).is_equal([1, 2])
