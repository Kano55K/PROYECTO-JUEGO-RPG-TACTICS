extends GdUnitTestSuite

# Arquitectura.md B.4 (T30, sesion 1), criterios 3 a 5: la atacante nocturna que
# se va con la derrota (P-024; Sistema.md 9.2 paso 6) o con la huida del Maestro
# (lectura declarada S-66), dentro del Combate, con fixtures (A.6). Fixture
# escenario_nocturno_combate.json: la Ocarra pega 4 en el golpe inicial;
# rodauva_1 es leal (rescatista si cae el Maestro).
const _DANIO_OCARRA: int = 4
const _VELOCIDAD_MAESTRO: int = 9
const _TOPE_ACCIONES: int = 30


func _assert_se_fue(combate: Combate) -> Dictionary:
	assert_str(combate.error()).is_empty()
	assert_bool(combate.terminado()).is_true()
	var resultado: Dictionary = combate.resultado().a_diccionario()
	var errores: Array[Dictionary] = MesaNocturno.errores_esquema(resultado, "resultado")
	assert_array(errores).override_failure_message(str(errores)).is_empty()
	assert_object(resultado["atacante_pendiente"]).is_null()
	assert_dict(resultado["destino_atacante"]).is_equal({"opcion": null, "resultado": "se_fue", "primera_opcion": null})
	var atacante: Dictionary = {}
	for unidad: Dictionary in resultado["unidades"]:
		if unidad["id"] == MesaNocturno.ATACANTE:
			atacante = unidad
	assert_dict(atacante).contains_key_value("estado", "fuera").contains_key_value("posicion", null)
	# Su pergamino (el que ocupaba al empezar) ardio en este combate.
	assert_array((resultado["pergaminos"] as Dictionary)["ardidos"]).contains(["pergamino_2"])
	var cierre: Dictionary = MesaNocturno.lineas_de_tipo(combate, "cierre")[0]
	assert_array(cierre["pergaminos_ardidos"]).contains(["pergamino_2"])
	# Nadie anota lealtad por ella.
	for cambio: Dictionary in resultado["lealtad_cambios"]:
		assert_str(cambio["id"]).is_not_equal(MesaNocturno.ATACANTE)
	return resultado


# (3) El golpe inicial deja al Maestro en 0: derrota con 0 rondas y la atacante,
# de pie, se va.
func test_golpe_que_tumba_al_maestro() -> void:
	var combate: Combate = MesaNocturno.combate(MesaNocturno.escenario(), {Maestro.ID: _DANIO_OCARRA})
	var resultado: Dictionary = _assert_se_fue(combate)
	assert_str(resultado["desenlace"]).is_equal("derrota_por_caida")
	assert_int(resultado["rondas"]).is_equal(0)
	assert_bool(resultado["maestro_caido"]).is_true()
	var tipos: Array = combate.registro().lineas().map(func(linea: Dictionary) -> String: return linea["tipo"])
	assert_array(tipos).is_equal(["inicio", "golpe_inicial", "estado", "fin", "rescate", "cierre"])


# (4) Derrota con la atacante caida y con la atacante de pie: atacante_pendiente
# null, pergamino ardido, se_fue y solo el +2 del rescate en la lealtad.
func test_derrota_con_la_atacante_caida_y_de_pie() -> void:
	# Caida: arranca en 0 (no golpea) y el Maestro tambien.
	var caida: Combate = MesaNocturno.combate(MesaNocturno.escenario(),
			{Maestro.ID: 0, MesaNocturno.ATACANTE: 0})
	var con_caida: Dictionary = _assert_se_fue(caida)
	assert_array(MesaNocturno.lineas_de_tipo(caida, "golpe_inicial")).is_empty()
	# De pie: la tumba el golpe inicial.
	var de_pie: Dictionary = _assert_se_fue(MesaNocturno.combate(MesaNocturno.escenario(),
			{Maestro.ID: _DANIO_OCARRA}))
	for resultado in [con_caida, de_pie]:
		assert_str(resultado["desenlace"]).is_equal("derrota_por_caida")
		assert_array(resultado["lealtad_cambios"]).is_equal([{"id": MesaNocturno.SUELTA, "antes": 8, "cambio": 2,
				"despues": 10, "anotaciones": [{"cambio": 2, "motivo": "rescate"}]}])


# (5) S-66: el Maestro declara la huida con la atacante en el tablero; al cerrar
# la ronda se va y la atacante se va igual.
func test_huida_con_la_atacante_en_el_tablero() -> void:
	var escenario: Dictionary = MesaNocturno.escenario()
	escenario["golpe_inicial"] = null
	var combate: Combate = MesaNocturno.combate(escenario, {}, MesaNocturno.datos(_VELOCIDAD_MAESTRO))
	assert_str(combate.turno_actual().unidad_id).is_equal(Maestro.ID)
	_aplicar_valida(combate, Accion.huir())
	_aplicar_valida(combate, Accion.terminar())
	var acciones: int = 0
	while not combate.terminado() and acciones < _TOPE_ACCIONES:
		_aplicar_valida(combate, Accion.terminar())
		acciones += 1
	var resultado: Dictionary = _assert_se_fue(combate)
	assert_str(resultado["desenlace"]).is_equal("huida")


func _aplicar_valida(combate: Combate, accion: Accion) -> void:
	var resultado: ResultadoAccion = combate.aplicar(accion)
	assert_bool(resultado.valida).override_failure_message("%s: %s" % [str(accion.a_diccionario()),
			ResultadoAccion.Motivo.keys()[resultado.motivo]]).is_true()
	assert_str(combate.error()).is_empty()
