extends GdUnitTestSuite

# Arquitectura.md B.4 (T27), criterios 1 y 12, con datos/ real (A.6). En A, con
# el jugador esperando (JugadorEsperando), la Ocarra tumba a la Rodauva; en el
# turno siguiente del Maestro, este la guarda. Si la caida no esta a su alcance,
# el Maestro se acerca primero (a la casilla de Turno.casillas_para_mover mas
# cercana a ella). La objetivo sale de Turno.objetivos_para_guardar_caida y el
# costo de Combate.costo_guardar_caida; la comprobacion los cuenta de
# datos/tablas/costos_mana.json (fila guardar_caida), tablas/balanza.json y
# tablas/combate.json (Sistema.md 2.3 y 11.5). Si un dia una regla impide
# guardarla, no se tocan coordenadas: se anota en docs/PREGUNTAS.md.
const _CARPETA_DATOS: String = "res://datos"
const _A: String = "a_dia_1"
const _RODAUVA: String = "rodauva_1"
const _TOPE_ACCIONES: int = 200


func _datos() -> Dictionary:
	var carga: Dictionary = Cargador.new().cargar_carpeta(_CARPETA_DATOS)
	assert_array(carga["errores"]).override_failure_message(str(carga["errores"])).is_empty()
	return carga["datos"]


# Sistema.md 2.3, leido de los datos: la comprobacion del test.
func _costo_esperado(datos: Dictionary, rango: int, balanza: int) -> int:
	var costos: Dictionary = datos["tablas/costos_mana.json"]
	var descuento: int = 0
	for fila in (datos["tablas/balanza.json"]["posiciones"] as Array):
		if fila["posicion"] == balanza:
			descuento = fila["descuento"]
	return maxi(costos["costo_minimo"] as int, ((costos["guardar_caida"] as Array)[rango - 1] as int) - descuento)


# Juega esperando hasta el turno del Maestro con la Rodauva caida; false si antes
# termino el combate.
func _esperar_la_caida(combate: Combate, contexto: ContextoCombate) -> bool:
	for _i in range(_TOPE_ACCIONES):
		assert_str(combate.error()).is_empty()
		if combate.terminado():
			return false
		if combate.turno_actual().unidad_id == Maestro.ID \
				and contexto.plantel.criatura(_RODAUVA).estado == Criatura.Estado.CAIDA:
			return true
		assert_str(JugadorEsperando.lo_obligado(combate)).is_empty()
		if combate.terminado():
			return false
		assert_bool(combate.aplicar(Accion.terminar()).valida).is_true()
	return false


# (1) El dato nuevo carga en datos/ con el valor de Sistema.md 11.5 (11.1 v1.7):
# lo comprueba la tabla de cotejo del resumen; aca, que existe y que la regla lo lee.
func test_el_dato_carga_en_datos() -> void:
	var datos: Dictionary = _datos()
	var tabla_combate: Dictionary = datos["tablas/combate.json"]
	assert_bool(tabla_combate.has("vida_al_guardar_caida")).is_true()
	var contexto: ContextoCombate = ContextoCombate.armar(datos["escenarios/%s.json" % _A], datos)
	assert_bool(contexto.valido).is_true()
	assert_int(contexto.guardado_caida.vida()).is_equal(tabla_combate["vida_al_guardar_caida"])
	assert_int(contexto.guardado_caida.alcance()).is_equal(tabla_combate["alcance_guardar_caida"])


# (12) A: la Ocarra tumba a la Rodauva y el Maestro la guarda con el costo de los datos.
func test_a_el_maestro_guarda_a_la_rodauva_caida() -> void:
	var datos: Dictionary = _datos()
	var escenario: Dictionary = datos["escenarios/%s.json" % _A]
	var contexto: ContextoCombate = ContextoCombate.armar(escenario, datos)
	assert_bool(contexto.valido).is_true()
	var combate: Combate = Combate.empezar(contexto)
	assert_bool(_esperar_la_caida(combate, contexto)).override_failure_message("la Rodauva no cayo").is_true()

	var turno: Turno = combate.turno_actual()
	var rodauva: Criatura = contexto.plantel.criatura(_RODAUVA)
	if not turno.objetivos_para_guardar_caida().has(_RODAUVA):
		var cercana: Vector2i = Criatura.SIN_POSICION
		for casilla in turno.casillas_para_mover():
			if cercana == Criatura.SIN_POSICION \
					or Tablero.distancia(casilla, rodauva.posicion) < Tablero.distancia(cercana, rodauva.posicion):
				cercana = casilla
		assert_bool(combate.aplicar(Accion.mover(cercana)).valida).is_true()
	assert_array(turno.objetivos_para_guardar_caida()).is_equal([_RODAUVA])

	var costo: Variant = combate.costo_guardar_caida(_RODAUVA)
	var rango: int = datos["especies/rodauva.json"]["rango"]
	assert_int(costo).is_equal(_costo_esperado(datos, rango, escenario["maestro"]["balanza"]))
	var pergamino_id: String = rodauva.pergamino_id
	var mana_antes: int = combate.instantanea()["maestro"]["mana"]
	var resultado: ResultadoAccion = combate.aplicar(Accion.guardar_caida(_RODAUVA))
	assert_bool(resultado.valida).is_true()
	assert_str(combate.error()).is_empty()
	assert_int(resultado.costo).is_equal(costo)
	assert_int(mana_antes - (combate.instantanea()["maestro"]["mana"] as int)).is_equal(costo)
	assert_int(rodauva.estado).is_equal(Criatura.Estado.GUARDADA)
	assert_that(rodauva.posicion).is_equal(Criatura.SIN_POSICION)
	assert_int(rodauva.vida).is_equal(datos["tablas/combate.json"]["vida_al_guardar_caida"])
	assert_str(rodauva.pergamino_id).is_equal(pergamino_id)
	var ultimo: Dictionary = combate.registro().lineas().back()
	assert_dict(ultimo).contains_key_value("tipo", "guardado_caida")
	assert_bool(combate.aplicar(Accion.terminar()).valida).is_true()
