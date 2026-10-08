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
		assert_dict(_sin_estado(pasos[i])).is_equal({"tipo": SecuenciaIA.ATAQUE, "unidad": "tasajero_s1",
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
			assert_dict(_sin_estado(pasos[i])).is_equal({"tipo": SecuenciaIA.MOVIMIENTO, "unidad": evento["unidad"],
					"desde": Vector2i(evento["desde"][0], evento["desde"][1]),
					"hasta": Vector2i(evento["hasta"][0], evento["hasta"][1])})
		else:
			assert_str(pasos[i]["tipo"]).is_equal(SecuenciaIA.ATAQUE)
			assert_str(pasos[i]["unidad"]).is_equal(evento["atacante"])
	# Desde el final del registro, nada.
	assert_array(SecuenciaIA.pasos(combate.registro().lineas(), combate.registro().lineas().size())).is_empty()


# T20: el `estado` de cada paso se mira aparte (test_estado_del_chequeo).
func _sin_estado(paso: Dictionary) -> Dictionary:
	var copia: Dictionary = paso.duplicate()
	copia.erase("estado")
	return copia


# T20 (Sistema.md 10.5): escenario_rival_salvajes_combate con la semilla 1:
# ocarra_s1 se encona contra ocarra_1 en su turno (chequeo_rival `enconada`),
# asi que todos sus pasos llevan ese estado; ocarra_s2, sin chequeo, "". Un
# `turno` nuevo de la misma unidad lo vuelve a "".
func test_estado_del_chequeo() -> void:
	var combate: Combate = _combate("escenario_rival_salvajes_combate")
	var desde: int = combate.registro().lineas().size()
	assert_bool(combate.aplicar(Accion.terminar()).valida).is_true()
	var lineas: Array[Dictionary] = combate.registro().lineas()
	var pasos: Array[Dictionary] = SecuenciaIA.pasos(lineas, desde)
	var de_s1: int = 0
	for paso in pasos:
		if paso["unidad"] == "ocarra_s1":
			de_s1 += 1
			assert_str(paso["estado"]).is_equal("enconada")
		else:
			assert_str(paso["estado"]).is_empty()
	assert_int(de_s1).is_greater(0)

	var con_otro_turno: Array[Dictionary] = lineas.duplicate()
	con_otro_turno.append({"tipo": "turno", "unidad": "ocarra_s1"})
	con_otro_turno.append({"tipo": "accion", "origen": "ia"})
	con_otro_turno.append({"tipo": "movimiento", "unidad": "ocarra_s1", "desde": [3, 5], "hasta": [3, 4]})
	var ultimo: Dictionary = SecuenciaIA.pasos(con_otro_turno, desde).back()
	assert_str(ultimo["unidad"]).is_equal("ocarra_s1")
	assert_str(ultimo["estado"]).is_empty()
