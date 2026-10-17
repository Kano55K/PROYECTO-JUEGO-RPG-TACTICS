extends GdUnitTestSuite

# Arquitectura.md B.4 (T24), criterio 11, con datos/ real (A.6): en A, el jugador
# espera (JugadorEsperando) hasta cada turno del Maestro y ahi busca, con las
# consultas del Turno, una casilla desde la que la Ocarra sea objetivo de sellar
# (cada candidata se juega en un combate nuevo llevado al mismo turno: el combate
# es determinista). Ahi, el % que se muestra antes de confirmar
# (previsualizar_sellar y Combate.porcentaje_sellado) es el `porcentaje` del
# evento `sellado` y la celda de datos/tablas/sellado.json para su vida
# (Sistema.md 4.1). Si un dia no hay jugada, no se tocan coordenadas: se anota en
# docs/PREGUNTAS.md.
const _CARPETA_DATOS: String = "res://datos"
const _A: String = "a_dia_1"
const _OCARRA: String = "ocarra_s1"
const _HASTA_RONDA: int = 6
const _TOPE_ACCIONES: int = 200


func _datos() -> Dictionary:
	var carga: Dictionary = Cargador.new().cargar_carpeta(_CARPETA_DATOS)
	assert_array(carga["errores"]).override_failure_message(str(carga["errores"])).is_empty()
	return carga["datos"]


# El combate de A al empezar el turno numero `n` del Maestro (desde 1), con el
# jugador esperando en todos los turnos anteriores; null si antes termino o paso
# la ronda tope.
func _en_turno_del_maestro(datos: Dictionary, n: int) -> Combate:
	var contexto: ContextoCombate = ContextoCombate.armar(datos["escenarios/%s.json" % _A], datos)
	assert_bool(contexto.valido).is_true()
	var combate: Combate = Combate.empezar(contexto)
	var vistos: int = 0
	for _i in range(_TOPE_ACCIONES):
		assert_str(combate.error()).is_empty()
		if combate.terminado() or (combate.instantanea()["ronda"] as int) > _HASTA_RONDA:
			return null
		if combate.turno_actual().unidad_id == Maestro.ID:
			vistos += 1
			if vistos == n:
				return combate
		var falla: String = JugadorEsperando.lo_obligado(combate)
		assert_str(falla).is_empty()
		if combate.terminado():
			return null
		assert_bool(combate.aplicar(Accion.terminar()).valida).is_true()
	return null


# Sistema.md 4.1, leida de datos/tablas/sellado.json: la comprobacion del test.
func _celda(datos: Dictionary, vida: int, vida_max: int, rango: int) -> int:
	for tramo in (datos["tablas/sellado.json"]["tramos"] as Array):
		if vida * 100 <= (tramo["hasta_vida_pct"] as int) * vida_max:
			return (tramo["pct_por_rango"] as Array)[rango - 1]
	return -1


func test_a_el_porcentaje_mostrado_es_el_del_evento_y_el_de_la_tabla() -> void:
	var datos: Dictionary = _datos()
	var ficha: Dictionary = datos["especies/ocarra.json"]
	for n in range(1, _HASTA_RONDA + 1):
		var base: Combate = _en_turno_del_maestro(datos, n)
		if base == null:
			break
		var candidatas: Array[Vector2i] = [Criatura.SIN_POSICION]
		candidatas.append_array(base.turno_actual().casillas_para_mover())
		for casilla in candidatas:
			var combate: Combate = _en_turno_del_maestro(datos, n)
			if casilla != Criatura.SIN_POSICION:
				assert_bool(combate.aplicar(Accion.mover(casilla)).valida).is_true()
			var turno: Turno = combate.turno_actual()
			if not turno.objetivos_para_sellar().has(_OCARRA):
				continue
			var previa: ResultadoAccion = turno.previsualizar_sellar(_OCARRA)
			assert_bool(previa.valida).is_true()
			var vida: int = combate.contexto().plantel.criatura(_OCARRA).vida
			var mostrado: int = previa.porcentaje
			assert_int(combate.porcentaje_sellado(_OCARRA)).is_equal(mostrado)
			assert_int(mostrado).is_equal(_celda(datos, vida, ficha["vida"], ficha["rango"]))
			assert_bool(combate.aplicar(Accion.sellar(_OCARRA)).valida).is_true()
			var evento: Dictionary = {}
			for linea in combate.registro().lineas():
				if linea["tipo"] == "sellado":
					evento = linea
			assert_str(evento["objetivo"]).is_equal(_OCARRA)
			assert_int(evento["porcentaje"]).is_equal(mostrado)
			return
	fail("en A no hubo un turno del Maestro con la Ocarra a distancia de sellar hasta la ronda %d" % _HASTA_RONDA)
