extends GdUnitTestSuite

# Arquitectura.md B.4 (T31, sesion 1) y A.9, con datos/ real (A.6): las
# variantes que pide 11.9 se arman con EdicionEscenario sobre los escenarios
# del disco, validan y llegan al primer turno del jugador.
const _CARPETA_DATOS: String = "res://datos"


func _datos() -> Dictionary:
	var carga: Dictionary = Cargador.new().cargar_carpeta(_CARPETA_DATOS)
	assert_array(carga["errores"] as Array).override_failure_message(str(carga["errores"])).is_empty()
	return carga["datos"]


func _edicion(datos: Dictionary, escenario_id: String) -> EdicionEscenario:
	var esquema: Dictionary = Cargador.new().esquema_resuelto(_CARPETA_DATOS, "escenario")["esquema"]
	return EdicionEscenario.new(datos["escenarios/%s.json" % escenario_id], datos, esquema)


func _combate(edicion: EdicionEscenario, datos: Dictionary) -> Combate:
	var errores: Array[Dictionary] = edicion.validar()
	assert_array(errores).override_failure_message(str(errores)).is_empty()
	var contexto: ContextoCombate = ContextoCombate.armar(edicion.escenario(), datos)
	assert_bool(contexto.valido).override_failure_message(str(contexto.motivo)).is_true()
	return Combate.empezar(contexto)


# (6) C con la Rodauva guardada (c_tasajero.json, _nota): valida y llega al
# primer turno del jugador, con la Rodauva fuera del tablero.
func test_6_c_con_la_rodauva_guardada() -> void:
	var datos: Dictionary = _datos()
	var edicion: EdicionEscenario = _edicion(datos, "c_tasajero")
	assert_str(edicion.cambiar("tribu.rodauva_1.estado", "guardada")).is_empty()
	var combate: Combate = _combate(edicion, datos)
	assert_str(combate.error()).is_empty()
	assert_bool(combate.esperando_jugador()).is_true()
	for criatura in (combate.instantanea()["criaturas"] as Array):
		if (criatura as Dictionary)["id"] == "rodauva_1":
			assert_str(criatura["estado"]).is_equal("guardada")
			assert_that(criatura["posicion"]).is_null()


# (7) D normal con balanza 4 desde el panel (Sistema.md 11.9 y 14): valida,
# llega al primer turno del jugador y difiere de D normal solo en la balanza.
func test_7_d_normal_con_balanza_4() -> void:
	var datos: Dictionary = _datos()
	var edicion: EdicionEscenario = _edicion(datos, "d_rivales_normal")
	assert_str(edicion.cambiar("maestro.balanza", 4)).is_empty()
	var combate: Combate = _combate(edicion, datos)
	assert_str(combate.error()).is_empty()
	assert_bool(combate.esperando_jugador()).is_true()

	var normal: Dictionary = (datos["escenarios/d_rivales_normal.json"] as Dictionary).duplicate(true)
	var variante: Dictionary = edicion.escenario()
	assert_int((variante["maestro"] as Dictionary)["balanza"] as int).is_equal(4)
	(normal["maestro"] as Dictionary).erase("balanza")
	(variante["maestro"] as Dictionary).erase("balanza")
	assert_dict(variante).is_equal(normal)
