extends GdUnitTestSuite

# Arquitectura.md B.3 (T22, sesion 2), criterio 5, con datos/ real (A.6): en B
# (Sistema.md 11.9, "segunda salida legitima"), el Maestro se mueve 1 o 2 pasos
# y una Lanzadera deja a las dos Ocarras vecinas en 8 (Tablero.es_vecina_en_8).
# El jugador espera (JugadorEsperando) hasta cada turno del Maestro y ahi busca
# la jugada con las consultas del Turno. Cada candidata se juega en un combate
# nuevo llevado al mismo turno (el combate es determinista): el test no calcula
# ninguna regla. Si un dia no hay jugada, no se tocan coordenadas: se anota en
# docs/PREGUNTAS.md para SISTEMAS.
const _CARPETA_DATOS: String = "res://datos"
const _B: String = "b_muro"
const _LANZADERA: String = "lanzadera"
const _OCARRAS: Array[String] = ["ocarra_s1", "ocarra_s2"]
const _MAX_PASOS: int = 2
# Hasta que ronda se busca: las Ocarras llegan en la 2 (nota del escenario).
const _HASTA_RONDA: int = 4
const _TOPE_ACCIONES: int = 200


func _datos() -> Dictionary:
	var carga: Dictionary = Cargador.new().cargar_carpeta(_CARPETA_DATOS)
	assert_array(carga["errores"]).override_failure_message(str(carga["errores"])).is_empty()
	return carga["datos"]


# El combate de B al empezar el turno numero `n` del Maestro (desde 1), con el
# jugador esperando en todos los turnos anteriores; null si antes termino o paso
# la ronda tope.
func _en_turno_del_maestro(datos: Dictionary, n: int) -> Combate:
	var contexto: ContextoCombate = ContextoCombate.armar(datos["escenarios/%s.json" % _B], datos)
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


func _posicion(foto: Dictionary, criatura_id: String) -> Variant:
	for criatura in foto["criaturas"]:
		if criatura["id"] == criatura_id and criatura["estado"] == "suelta":
			return criatura["posicion"]
	return null


# Las dos Ocarras de pie y vecinas en 8.
func _juntas(combate: Combate) -> bool:
	var foto: Dictionary = combate.instantanea()
	var a: Variant = _posicion(foto, _OCARRAS[0])
	var b: Variant = _posicion(foto, _OCARRAS[1])
	if a == null or b == null:
		return false
	return Tablero.es_vecina_en_8(Vector2i(a[0], a[1]), Vector2i(b[0], b[1]))


# La primera jugada {turno, casilla, ocarra, sentido} que junta a las Ocarras, o {}.
func _buscar(datos: Dictionary) -> Dictionary:
	var n: int = 1
	while true:
		var combate: Combate = _en_turno_del_maestro(datos, n)
		if combate == null:
			return {}
		var desde: Vector2i = combate.contexto().plantel.maestro.posicion
		for casilla in combate.turno_actual().casillas_para_mover():
			var pasos: int = Tablero.distancia(desde, casilla)
			if pasos < 1 or pasos > _MAX_PASOS:
				continue
			for ocarra in _OCARRAS:
				for sentido in ["empujar", "atraer"]:
					var prueba: Combate = _en_turno_del_maestro(datos, n)
					assert_bool(prueba.aplicar(Accion.mover(casilla)).valida).is_true()
					if not prueba.turno_actual().sentidos_para_hechizo(_LANZADERA, ocarra).has(sentido):
						continue
					assert_bool(prueba.aplicar(Accion.hechizo(_LANZADERA, ocarra, sentido)).valida).is_true()
					if _juntas(prueba):
						return {"turno": n, "casilla": casilla, "ocarra": ocarra, "sentido": sentido, "combate": prueba}
		n += 1
	return {}


# Criterio 5: hay una jugada de 1 o 2 pasos y una Lanzadera que junta a las dos
# Ocarras; el registro tiene esa Lanzadera, sin choque.
func test_la_lanzadera_junta_a_las_ocarras_de_b() -> void:
	var jugada: Dictionary = _buscar(_datos())
	assert_dict(jugada).override_failure_message(
			"B: ninguna Lanzadera tras 1 o 2 pasos junta a las Ocarras hasta la ronda %d" % _HASTA_RONDA).is_not_empty()
	var combate: Combate = jugada["combate"]
	assert_bool(_juntas(combate)).is_true()
	var lanzadera: Dictionary = {}
	for linea in combate.registro().lineas():
		if linea["tipo"] == "lanzadera":
			lanzadera = linea
	assert_str(lanzadera["objetivo"]).is_equal(jugada["ocarra"])
	assert_str(lanzadera["sentido"]).is_equal(jugada["sentido"])
	assert_bool(lanzadera["choque"]).is_false()
