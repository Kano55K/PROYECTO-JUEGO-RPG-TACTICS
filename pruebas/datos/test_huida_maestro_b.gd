extends GdUnitTestSuite

# Arquitectura.md B.4 (T28), criterio 11, con datos/ real (A.6). Con el jugador
# esperando (JugadorEsperando), el Maestro declara la huida con el turno sin usar
# en la ronda 2 y el combate sigue esperando hasta el fin. El danio que recibe
# despues de declarar no supera el danio maximo de Combate.previsualizar_huida,
# y el combate termina en huida, o en derrota por caida si la previsualizacion
# decia que podia caer (Sistema.md 11.7, S-61).
# Desde T46 (Sistema.md 11.7 v1.8, S-63) se va justo antes de su proximo turno:
# B: las dos Ocarras (Velocidad 7) y la Rodauva (6) juegan antes que el Maestro
# (5), asi que al declarar no queda ninguna enemiga pendiente en la ronda, pero
# las Ocarras vuelven a jugar en la 3 antes que el. D: el Surcon salvaje
# (Velocidad 2) juega despues en la ronda 2 y la Rodauva salvaje antes en la 3.
# Si un dia una regla impide declarar, no se tocan coordenadas: se anota en
# docs/PREGUNTAS.md.
const _CARPETA_DATOS: String = "res://datos"
const _RONDA_HUIDA: int = 2
const _TOPE_ACCIONES: int = 200


func _datos() -> Dictionary:
	var carga: Dictionary = Cargador.new().cargar_carpeta(_CARPETA_DATOS)
	assert_array(carga["errores"]).override_failure_message(str(carga["errores"])).is_empty()
	return carga["datos"]


func _combate(escenario_id: String) -> Combate:
	var datos: Dictionary = _datos()
	var contexto: ContextoCombate = ContextoCombate.armar(datos["escenarios/%s.json" % escenario_id], datos)
	assert_bool(contexto.valido).is_true()
	var combate: Combate = Combate.empezar(contexto)
	assert_str(combate.error()).is_empty()
	return combate


# Juega esperando hasta el turno del Maestro de la ronda pedida; false si antes
# termino el combate.
func _esperar_hasta_el_maestro(combate: Combate, ronda: int) -> bool:
	for _i in range(_TOPE_ACCIONES):
		assert_str(combate.error()).is_empty()
		if combate.terminado():
			return false
		if combate.turno_actual().unidad_id == Maestro.ID and combate.instantanea()["ronda"] == ronda:
			return true
		assert_str(JugadorEsperando.lo_obligado(combate)).is_empty()
		if combate.terminado():
			return false
		assert_bool(combate.aplicar(Accion.terminar()).valida).is_true()
	return false


func _hasta_el_fin(combate: Combate) -> void:
	for _i in range(_TOPE_ACCIONES):
		assert_str(combate.error()).is_empty()
		if combate.terminado():
			return
		assert_str(JugadorEsperando.lo_obligado(combate)).is_empty()
		if combate.terminado():
			return
		assert_bool(combate.aplicar(Accion.terminar()).valida).is_true()
	assert_bool(combate.terminado()).is_true()


# Danio que recibio el Maestro en los eventos `ataque` desde la linea `desde`.
func _danio_al_maestro(combate: Combate, desde: int) -> int:
	var total: int = 0
	for linea: Dictionary in combate.registro().lineas().slice(desde):
		if linea["tipo"] == "ataque" and linea["objetivo"] == Maestro.ID:
			total += (linea["vida_antes"] as int) - (linea["vida_despues"] as int)
	return total


# Las enemigas con evento `turno` desde la linea `desde`, en orden.
func _enemigas_que_actuaron(combate: Combate, desde: int) -> Array:
	var enemigas: Array = (combate.contexto().escenario["enemigas"] as Array).map(func(enemiga: Dictionary) -> String:
			return enemiga["id"])
	return combate.registro().lineas().slice(desde).filter(func(linea: Dictionary) -> bool:
			return linea["tipo"] == "turno" and enemigas.has(linea["unidad"])) \
			.map(func(linea: Dictionary) -> String: return linea["unidad"])


# Declara en la ronda 2 y juega hasta el fin. Devuelve la previsualizacion.
# Reescrito en T46 (Sistema.md 11.7 v1.8, S-63): el Maestro se va justo antes de
# su turno de la ronda 3, asi que el combate termina en la ronda 3 (o antes, si
# cae), y las enemigas listadas son exactamente las que actuaron en el medio.
func _huir(combate: Combate) -> Dictionary:
	assert_bool(_esperar_hasta_el_maestro(combate, _RONDA_HUIDA)).is_true()
	assert_int(combate.turno_actual().motivo_huir()).is_equal(ResultadoAccion.Motivo.NINGUNO)
	var previa: Dictionary = combate.previsualizar_huida()
	var desde: int = combate.registro().lineas().size()
	assert_bool(combate.aplicar(Accion.huir()).valida).is_true()
	_hasta_el_fin(combate)
	assert_int(_danio_al_maestro(combate, desde)).is_less_equal(previa["danio_maximo"])
	if combate.fin() == FinCombate.Fin.HUIDA:
		assert_int(combate.instantanea()["ronda"]).is_equal(_RONDA_HUIDA + 1)
		var unidades: Array = (previa["enemigas"] as Array).map(func(enemiga: Dictionary) -> String:
				return enemiga["unidad"])
		assert_array(_enemigas_que_actuaron(combate, desde)).is_equal(unidades)
		assert_str(combate.resultado().a_diccionario()["desenlace"]).is_equal("huida")
	else:
		# Si podia caer, por caida.
		assert_bool(previa["puede_caer"]).is_true()
		assert_int(combate.fin()).is_equal(FinCombate.Fin.DERROTA_POR_CAIDA)
	return previa


# (11) Reescrito en T46 (Sistema.md 11.7 v1.8, S-63): en B las dos Ocarras
# (Velocidad 7) actuan en la ronda 3 antes que el Maestro (5): la
# previsualizacion las lista, en el orden de la cola, y deja de estar vacia.
func test_b_huye_en_la_ronda_2() -> void:
	var combate: Combate = _combate("b_muro")
	var previa: Dictionary = _huir(combate)
	var unidades: Array = (previa["enemigas"] as Array).map(func(enemiga: Dictionary) -> String: return enemiga["unidad"])
	assert_array(unidades).is_equal(["ocarra_s1", "ocarra_s2"])
	assert_int(previa["danio_maximo"]).is_greater(0)


# (11) Reescrito en T46 (Sistema.md 11.7 v1.8, S-63): en D el Surcon salvaje
# (Velocidad 2) juega despues del Maestro en la ronda 2, y la Rodauva salvaje
# (6), antes que el en la 3: la previsualizacion lista a las dos, en ese orden.
func test_d_el_surcon_figura() -> void:
	var combate: Combate = _combate("d_rivales_normal")
	var previa: Dictionary = _huir(combate)
	var unidades: Array = (previa["enemigas"] as Array).map(func(enemiga: Dictionary) -> String: return enemiga["unidad"])
	assert_array(unidades).is_equal(["surcon_s1", "rodauva_s1"])
