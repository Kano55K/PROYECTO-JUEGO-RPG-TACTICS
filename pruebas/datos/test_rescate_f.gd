extends GdUnitTestSuite

# Arquitectura.md B.4 (T29), criterio 10, con datos/ real (A.6). En F, con el
# jugador esperando (JugadorEsperando), el Zancajunco salvaje tumba al Maestro en
# la ronda 3. La rescatista del resultado es la que daba
# Combate.rescatista_ahora() en el ultimo turno del jugador antes de la caida
# (la Rodauva leal; la Ocarra es Neutral y no rescata). Sistema.md 6 y 11.9.
# Si un dia la ronda o la atacante cambian, no se tocan coordenadas: se anota en
# docs/PREGUNTAS.md.
const _CARPETA_DATOS: String = "res://datos"
const _ESCENARIO: String = "escenarios/f_rescate.json"
const _ZANCAJUNCO: String = "zancajunco_s1"
const _RODAUVA: String = "rodauva_1"
const _RONDA_CAIDA: int = 3
const _TOPE_ACCIONES: int = 200


func _combate() -> Combate:
	var carga: Dictionary = Cargador.new().cargar_carpeta(_CARPETA_DATOS)
	assert_array(carga["errores"]).override_failure_message(str(carga["errores"])).is_empty()
	var datos: Dictionary = carga["datos"]
	var contexto: ContextoCombate = ContextoCombate.armar(datos[_ESCENARIO], datos)
	assert_bool(contexto.valido).is_true()
	var combate: Combate = Combate.empezar(contexto)
	assert_str(combate.error()).is_empty()
	return combate


# El ultimo evento `ataque` al Maestro del registro, o {}.
func _ultimo_ataque_al_maestro(combate: Combate) -> Dictionary:
	var ultimo: Dictionary = {}
	for linea: Dictionary in combate.registro().lineas():
		if linea["tipo"] == "ataque" and linea["objetivo"] == Maestro.ID:
			ultimo = linea
	return ultimo


# (10) Esperando hasta el fin, guardando rescatista_ahora() en cada turno del
# jugador: derrota por caida en la ronda 3, por el Zancajunco, y la rescatista
# del resultado (y de la metrica 12) es la ultima que se vio.
func test_f_rescata_la_que_se_veia() -> void:
	var combate: Combate = _combate()
	var vista_antes: Variant = null
	for _i in range(_TOPE_ACCIONES):
		assert_str(combate.error()).is_empty()
		if combate.terminado():
			break
		assert_bool(combate.esperando_jugador()).is_true()
		vista_antes = combate.rescatista_ahora()
		assert_str(JugadorEsperando.lo_obligado(combate)).is_empty()
		if combate.terminado():
			break
		assert_bool(combate.aplicar(Accion.terminar()).valida).is_true()
	assert_bool(combate.terminado()).is_true()
	assert_int(combate.fin()).is_equal(FinCombate.Fin.DERROTA_POR_CAIDA)
	var ataque: Dictionary = _ultimo_ataque_al_maestro(combate)
	assert_str(ataque.get("atacante", "")).is_equal(_ZANCAJUNCO)
	assert_int(ataque["vida_despues"]).is_equal(0)
	var datos: Dictionary = combate.resultado().a_diccionario()
	assert_int(datos["rondas"]).is_equal(_RONDA_CAIDA)
	assert_str(vista_antes).is_equal(_RODAUVA)
	assert_str(datos["rescatista"]).is_equal(vista_antes)
	assert_bool(datos["permadeath"]).is_false()
	assert_dict(datos["metricas"]["rescate"]).is_equal({"rescatista": vista_antes})
