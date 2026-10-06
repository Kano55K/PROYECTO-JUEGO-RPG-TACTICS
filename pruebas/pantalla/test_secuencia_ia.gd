extends GdUnitTestSuite

# Arquitectura.md B.2.1 (T40, sesion 2): SecuenciaIA copia del registro los
# movimientos y ataques de la IA, en orden, para mostrarlos de a uno. No decide
# ni calcula nada. Fixtures (A.6).
const _CARPETA: String = "res://pruebas/fixtures/combate/"


func _combate(nombre: String) -> Combate:
	var lectura: Dictionary = DatosFixture.cargar()
	assert_array(lectura["errores"]).is_empty()
	var escenario: Dictionary = LectorFixture.leer(_CARPETA + nombre + ".json", "escenario")["datos"]
	var combate: Combate = Combate.empezar(ContextoCombate.armar(escenario, lectura["datos"]))
	assert_str(combate.error()).is_empty()
	return combate


# Los eventos `movimiento` y `ataque` del registro desde `desde`.
func _eventos(combate: Combate, desde: int) -> Array[Dictionary]:
	var lista: Array[Dictionary] = []
	var lineas: Array[Dictionary] = combate.registro().lineas()
	for indice in range(desde, lineas.size()):
		if lineas[indice]["tipo"] in ["movimiento", "ataque"]:
			lista.append(lineas[indice])
	return lista


# escenario_caza: el Tasajero salvaje juega primero y da sus dos ataques sin
# moverse. Los pasos son esos dos, con la vida que dejo cada uno.
func test_pasos_de_la_ia() -> void:
	var combate: Combate = _combate("escenario_caza")
	var pasos: Array[Dictionary] = SecuenciaIA.pasos(combate.registro().lineas(), 0)
	var ataques: Array[Dictionary] = _eventos(combate, 0)
	assert_int(ataques.size()).is_equal(2)
	assert_int(pasos.size()).is_equal(2)
	for i in range(pasos.size()):
		assert_dict(pasos[i]).is_equal({"tipo": SecuenciaIA.ATAQUE, "unidad": "tasajero_s1",
				"objetivo": ataques[i]["objetivo"], "vida_despues": ataques[i]["vida_despues"]})


# escenario_c: el movimiento del jugador no da pasos; los de la IA que juega
# despues de su `terminar`, si, con desde y hasta como casillas.
func test_solo_la_ia_y_desde() -> void:
	var combate: Combate = _combate("escenario_c")
	var lineas_antes: int = combate.registro().lineas().size()
	assert_array(SecuenciaIA.pasos(combate.registro().lineas(), lineas_antes)).is_empty()
	var turno: Turno = combate.turno_actual()
	var casillas: Array[Vector2i] = turno.casillas_para_mover()
	assert_array(casillas).is_not_empty()
	assert_bool(combate.aplicar(Accion.mover(casillas[0])).valida).is_true()
	assert_array(SecuenciaIA.pasos(combate.registro().lineas(), lineas_antes)).is_empty()

	var hasta_aca: int = combate.registro().lineas().size()
	# Termina turnos hasta que juegue alguna IA que se mueva o ataque.
	for _i in range(20):
		assert_bool(combate.aplicar(Accion.terminar()).valida).is_true()
		if not _eventos(combate, hasta_aca).is_empty() or combate.terminado():
			break
	var eventos: Array[Dictionary] = _eventos(combate, hasta_aca)
	var pasos: Array[Dictionary] = SecuenciaIA.pasos(combate.registro().lineas(), hasta_aca)
	assert_int(pasos.size()).is_equal(eventos.size())
	assert_int(pasos.size()).is_greater(0)
	for i in range(pasos.size()):
		var evento: Dictionary = eventos[i]
		if evento["tipo"] == "movimiento":
			assert_dict(pasos[i]).is_equal({"tipo": SecuenciaIA.MOVIMIENTO, "unidad": evento["unidad"],
					"desde": Vector2i(evento["desde"][0], evento["desde"][1]),
					"hasta": Vector2i(evento["hasta"][0], evento["hasta"][1])})
		else:
			assert_str(pasos[i]["tipo"]).is_equal(SecuenciaIA.ATAQUE)
			assert_str(pasos[i]["unidad"]).is_equal(evento["atacante"])
	# Desde el final del registro, nada.
	assert_array(SecuenciaIA.pasos(combate.registro().lineas(), combate.registro().lineas().size())).is_empty()
