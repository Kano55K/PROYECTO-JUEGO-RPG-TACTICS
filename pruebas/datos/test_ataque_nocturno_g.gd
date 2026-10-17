extends GdUnitTestSuite

# Arquitectura.md B.4 (T30, sesion 3), criterio 16, con datos/ real (A.6): G, el
# ataque nocturno. La Ocarra golpea al Maestro antes de la ronda 1 (200 → 160);
# G se juega hasta tumbarla con las consultas del Turno, sin coordenadas
# escritas; y las tres salidas (perdonar, sellar de nuevo, comer) desde el mismo
# estado, con los textos de datos/textos/es.json. Sistema.md 9.2, 9.3, 4.4 y 5.2.
# Si un dia G cambia y no se llega a tumbar a la Ocarra, no se tocan
# coordenadas: se anota en docs/PREGUNTAS.md.
const _CARPETA_DATOS: String = "res://datos"
const _ESCENARIO: String = JugadorG.ESCENARIO
const _FICHA_OCARRA: String = "especies/ocarra.json"
const _TEXTOS: String = "textos/es.json"
const _OCARRA: String = JugadorG.OCARRA
# Mundo.md 1.5 y 4.6, copiados de es.json (con la Ocarra y el Zancajunco).
const _TEXTO_BASE: String = "Te despierta el silencio. El Molino cruje como siempre, pero algo dejó de respirar junto al fuego. Cuando abrís los ojos, la Ocarra ya está encima tuyo."
const _TEXTO_BASE_OCARRA: String = "No grazna. Eso es lo que más te asusta: la Ocarra nunca hizo nada en silencio."
const _TEXTO_ZANCAJUNCO: String = "El Zancajunco se acerca a comer con vos. Es el único."
const _VIDA_MAESTRO: int = 200
const _VIDA_TRAS_EL_GOLPE: int = 160
const _COSTO_RESELLAR: int = 2

var _datos: Dictionary = {}


func _cargar() -> Dictionary:
	if _datos.is_empty():
		var carga: Dictionary = Cargador.new().cargar_carpeta(_CARPETA_DATOS)
		assert_array(carga["errores"]).override_failure_message(str(carga["errores"])).is_empty()
		_datos = carga["datos"]
	return _datos


func _combate() -> Combate:
	var datos: Dictionary = _cargar()
	var contexto: ContextoCombate = ContextoCombate.armar(datos[_ESCENARIO], datos)
	assert_bool(contexto.valido).is_true()
	var combate: Combate = Combate.empezar(contexto)
	assert_str(combate.error()).is_empty()
	return combate


func _lectura(combate: Combate) -> LecturaCombate:
	var datos: Dictionary = _cargar()
	return LecturaCombate.new(combate, ArmadorTextos.desde_datos(datos[_TEXTOS], combate.contexto().azar_textos),
			EstadosUnidad.desde_datos(datos["tablas/hambre.json"], datos["tablas/lealtad.json"]))


func _ultimo(combate: Combate, tipo: String) -> Dictionary:
	var encontrado: Dictionary = {}
	for linea in combate.registro().lineas():
		if linea["tipo"] == tipo:
			encontrado = linea
	return encontrado


# G jugado con JugadorG (todo desde las consultas del Turno) hasta el destino.
func _jugar_hasta_el_destino() -> Combate:
	var combate: Combate = _combate()
	assert_str(JugadorG.hasta_el_destino(combate)).is_empty()
	assert_int(combate.fin()).is_equal(FinCombate.Fin.VICTORIA)
	assert_bool(combate.esperando_destino()).is_true()
	return combate


func _errores_resultado(combate: Combate) -> Array:
	var esquema: Dictionary = Cargador.new().esquema_resuelto(_CARPETA_DATOS, "resultado")["esquema"]
	return Validador.new().validar(combate.resultado().a_diccionario(), esquema, "resultado")["errores"]


# {id: motivos} de los cambios de lealtad finales.
func _motivos(combate: Combate) -> Dictionary:
	var motivos: Dictionary = {}
	for cambio in (combate.resultado().a_diccionario()["lealtad_cambios"] as Array):
		motivos[cambio["id"]] = (cambio["anotaciones"] as Array).map(func(a: Dictionary) -> String: return a["motivo"])
	return motivos


# (16) El primer evento despues de `inicio` es el golpe de la Ocarra al Maestro,
# con la base de su ficha y la vida de 200 a 160. En los sucesos, el despertar de
# Mundo.md 4.6 con la linea de la Ocarra.
func test_golpe_inicial_de_la_ocarra() -> void:
	var combate: Combate = _combate()
	var lineas: Array[Dictionary] = combate.registro().lineas()
	assert_str(lineas[0]["tipo"]).is_equal("inicio")
	var golpe: Dictionary = lineas[1]
	assert_str(golpe["tipo"]).is_equal("golpe_inicial")
	assert_int(golpe["ronda"]).is_equal(0)
	assert_str(golpe["atacante"]).is_equal(_OCARRA)
	assert_str(golpe["objetivo"]).is_equal(Maestro.ID)
	assert_int(golpe["desglose"]["base"]).is_equal(_cargar()[_FICHA_OCARRA]["danio"])
	assert_int(golpe["vida_antes"]).is_equal(combate.contexto().plantel.maestro.vida_max_real())
	assert_int(golpe["vida_antes"]).is_equal(_VIDA_MAESTRO)
	assert_int(golpe["vida_despues"]).is_equal(golpe["vida_antes"] - golpe["desglose"]["total"])
	assert_int(golpe["vida_despues"]).is_equal(_VIDA_TRAS_EL_GOLPE)
	var sucesos: Array[String] = _lectura(combate).suceso(golpe)
	assert_str(sucesos[0]).is_equal(_TEXTO_BASE)
	assert_str(sucesos[1]).is_equal(_TEXTO_BASE_OCARRA)


# (16) G jugado con las consultas: la Ocarra cae, victoria y su destino espera.
func test_g_se_juega_hasta_tumbar_a_la_ocarra() -> void:
	var combate: Combate = _jugar_hasta_el_destino()
	assert_int(combate.contexto().plantel.criatura(_OCARRA).estado).is_equal(Criatura.Estado.CAIDA)
	assert_str(combate.resultado().atacante_pendiente).is_equal(_OCARRA)
	for opcion in DestinoAtacante.OPCIONES:
		assert_int(combate.motivo_destino(opcion)).is_equal(ResultadoAccion.Motivo.NINGUNO)
	assert_array(_lectura(combate).botones_destino().map(func(boton: Dictionary) -> String: return boton["opcion"])) \
			.is_equal(DestinoAtacante.OPCIONES)


# (16) Las tres salidas desde el mismo estado (mismo registro al llegar al destino).
func test_las_tres_salidas_desde_el_mismo_estado() -> void:
	var referencia: Array[String] = _jugar_hasta_el_destino().registro().lineas_json()

	# Perdonar: las leales reciben el perdon (Sistema.md 9.3), sumado al cierre.
	var perdonar: Combate = _jugar_hasta_el_destino()
	assert_array(perdonar.registro().lineas_json()).is_equal(referencia)
	assert_bool(perdonar.aplicar(Accion.destino_atacante(DestinoAtacante.OPCION_PERDONAR)).valida).is_true()
	assert_int(perdonar.contexto().plantel.criatura(_OCARRA).estado).is_equal(Criatura.Estado.FUERA)
	for motivos: Array in _motivos(perdonar).values():
		assert_array(motivos).contains(["perdon_a_leales"])
	assert_array(_errores_resultado(perdonar)).is_empty()

	# Comer: -2 a todas las sueltas; el Zancajunco suelto come con vos.
	var comer: Combate = _jugar_hasta_el_destino()
	assert_array(comer.registro().lineas_json()).is_equal(referencia)
	assert_bool(comer.aplicar(Accion.destino_atacante(DestinoAtacante.OPCION_COMER)).valida).is_true()
	assert_int(comer.contexto().plantel.criatura(_OCARRA).estado).is_equal(Criatura.Estado.MUERTA)
	for motivos: Array in _motivos(comer).values():
		assert_array(motivos).contains(["comer_atacante"])
	assert_array(_lectura(comer).suceso(_ultimo(comer, "destino_atacante"))).contains([_TEXTO_ZANCAJUNCO])
	assert_array(_errores_resultado(comer)).is_empty()

	# Sellar de nuevo: cuesta 2 (fila de resellar, 4.4). Si sale, guardada de la
	# tribu en el pergamino en blanco; si falla, quedan perdonar y comer.
	var sellar: Combate = _jugar_hasta_el_destino()
	assert_array(sellar.registro().lineas_json()).is_equal(referencia)
	var previa: ResultadoAccion = sellar.previsualizar_destino(DestinoAtacante.OPCION_SELLAR)
	assert_int(previa.costo).is_equal(_COSTO_RESELLAR)
	assert_bool(sellar.aplicar(Accion.destino_atacante(DestinoAtacante.OPCION_SELLAR)).valida).is_true()
	var ocarra: Criatura = sellar.contexto().plantel.criatura(_OCARRA)
	if _ultimo(sellar, "destino_atacante")["resultado"] == DestinoAtacante.RESULTADO_SELLADA:
		assert_int(ocarra.estado).is_equal(Criatura.Estado.GUARDADA)
		assert_int(ocarra.bando).is_equal(Criatura.Bando.TRIBU)
		assert_str(sellar.contexto().plantel.pergamino(ocarra.pergamino_id).ocupante_id).is_equal(_OCARRA)
		assert_bool(sellar.esperando_destino()).is_false()
	else:
		assert_bool(sellar.esperando_destino()).is_true()
		assert_int(sellar.motivo_destino(DestinoAtacante.OPCION_SELLAR)).is_equal(ResultadoAccion.Motivo.SELLAR_YA_FALLO)
		assert_bool(sellar.aplicar(Accion.destino_atacante(DestinoAtacante.OPCION_PERDONAR)).valida).is_true()
	assert_array(_errores_resultado(sellar)).is_empty()
