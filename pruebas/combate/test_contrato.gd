extends GdUnitTestSuite

# Arquitectura.md B.2 (T12, sesion 2): resultado, grabacion y reproductor (A.7),
# con fixtures (A.6). Tests 11 a 15, 16 (aviso de huella) y 17; la huella sola
# esta en pruebas/datos/test_huella_datos.gd. Sistema.md 5.2, 9.2 y 11.5. Los
# numeros de vida y lealtad son la comprobacion: el codigo los lee de las tablas.
const _CARPETA: String = "res://pruebas/fixtures/combate/"
const _CARPETA_CONTRATO: String = "res://pruebas/fixtures/combate/contrato/"
const _CARPETA_UNIDADES: String = "res://pruebas/fixtures/unidades/"
const _CARPETA_DATOS: String = "res://datos"
const _RONDAS_C: int = 2


func _datos() -> Dictionary:
	var lectura: Dictionary = DatosFixture.cargar()
	var errores: Array[Dictionary] = lectura["errores"]
	assert_array(errores).override_failure_message(str(errores)).is_empty()
	return lectura["datos"]


func _escenario(ruta: String) -> Dictionary:
	var lectura: Dictionary = LectorFixture.leer(ruta, "escenario")
	var errores: Array[Dictionary] = lectura["errores"]
	assert_array(errores).override_failure_message(str(errores)).is_empty()
	return lectura["datos"]


func _combate(escenario: Dictionary) -> Combate:
	var contexto: ContextoCombate = ContextoCombate.armar(escenario, _datos())
	assert_bool(contexto.valido).is_true()
	var combate: Combate = Combate.empezar(contexto)
	assert_str(combate.error()).is_empty()
	return combate


func _aplicar_valida(combate: Combate, accion: Accion) -> void:
	var resultado: ResultadoAccion = combate.aplicar(accion)
	assert_bool(resultado.valida).override_failure_message(
			ResultadoAccion.Motivo.keys()[resultado.motivo] + " " + str(accion.a_diccionario())).is_true()
	assert_str(combate.error()).is_empty()


# Errores del Validador de T03 contra un esquema real de datos/_esquemas/.
func _errores_esquema(valor: Variant, nombre_esquema: String) -> Array[Dictionary]:
	var esquema: Dictionary = Cargador.new().esquema_resuelto(_CARPETA_DATOS, nombre_esquema)["esquema"]
	var resultado: Dictionary = Validador.new().validar(valor, esquema, nombre_esquema)
	return resultado["errores"]


func _assert_valida(valor: Variant, nombre_esquema: String) -> void:
	var errores: Array[Dictionary] = _errores_esquema(valor, nombre_esquema)
	assert_array(errores).override_failure_message(str(errores)).is_empty()


# Lo que se compara entre jugar en vivo y reproducir.
func _foto(combate: Combate) -> Array:
	return [combate.instantanea(), combate.registro().lineas_json()]


# contrato_victoria jugado hasta el final: el Maestro va a [2,5] y tumba a la Ocarra.
func _victoria() -> Combate:
	var combate: Combate = _combate(_escenario(_CARPETA_CONTRATO + "contrato_victoria.json"))
	_aplicar_valida(combate, Accion.mover(Vector2i(2, 5)))
	_aplicar_valida(combate, Accion.atacar("ocarra_s1"))
	return combate


# C jugado en vivo: cada unidad del jugador va a la primera casilla a la que
# llega (sin quedarse quieta) y termina. Devuelve la foto despues de cada
# accion, con la del comienzo en el lugar 0.
func _jugar_c(combate: Combate) -> Array:
	var fotos: Array = [_foto(combate)]
	while not combate.terminado() and combate.instantanea()["ronda"] <= _RONDAS_C:
		var turno: Turno = combate.turno_actual()
		if not turno.movimiento_usado:
			var desde: Vector2i = combate.contexto().plantel.maestro.posicion if turno.unidad_id == Maestro.ID \
					else combate.contexto().plantel.criatura(turno.unidad_id).posicion
			var casillas: Array[Vector2i] = turno.casillas_para_mover()
			casillas.erase(desde)
			if not casillas.is_empty():
				_aplicar_valida(combate, Accion.mover(casillas[0]))
				fotos.append(_foto(combate))
				continue
		_aplicar_valida(combate, Accion.terminar())
		fotos.append(_foto(combate))
	return fotos


func _reproducir(grabacion: Grabacion, hasta_n: int = -1) -> Reproductor:
	var reproduccion: Reproductor = Reproductor.reproducir(grabacion, _datos(), hasta_n)
	assert_str(reproduccion.error).is_empty()
	assert_int(reproduccion.accion_con_error).is_equal(0)
	return reproduccion


func _estado(resultado: Dictionary, unidad_id: String) -> Dictionary:
	for unidad in (resultado["unidades"] as Array):
		if unidad["id"] == unidad_id:
			return unidad
	return {}


# (11) Los resultados de victoria (con una caida levantada y una guardada) y de
# derrota (con muertas) validan contra el esquema; con la atacante nocturna
# caida, atacante_pendiente es su id.
func test_resultados_validan_contra_el_esquema() -> void:
	# Victoria: la Rodauva cae y se levanta con 1 y +1; la Surcon guardada no cambia.
	var escenario: Dictionary = _escenario(_CARPETA_CONTRATO + "contrato_victoria.json")
	(escenario["tribu"] as Array).append({"id": "surcon_1", "especie": "surcon", "estado": "guardada",
			"lealtad": 5, "hambre": 3, "enfermedades": 0, "vida": null, "posicion": null})
	var combate: Combate = _combate(escenario)
	_aplicar_valida(combate, Accion.mover(Vector2i(2, 5)))
	_aplicar_valida(combate, Accion.atacar("ocarra_s1"))
	var victoria: Dictionary = combate.resultado().a_diccionario()
	_assert_valida(victoria, "resultado")
	assert_str(victoria["desenlace"]).is_equal("victoria")
	assert_str(victoria["contexto_id"]).is_equal("contrato_victoria")
	assert_int(victoria["rondas"]).is_equal(1)
	assert_bool(victoria["maestro_caido"]).is_false()
	assert_array(victoria["levantadas"]).is_equal(["rodauva_1"])
	assert_array(victoria["muertas"]).is_empty()
	assert_dict(_estado(victoria, "rodauva_1")).contains_key_value("estado", "suelta").contains_key_value("vida", 1)
	assert_dict(_estado(victoria, "surcon_1")).contains_key_value("estado", "guardada").contains_key_value("lealtad", 5)
	assert_dict(_estado(victoria, "ocarra_s1")).contains_key_value("estado", "fuera") \
			.contains_key_value("lealtad", null).contains_key_value("posicion", null)
	assert_array(victoria["lealtad_cambios"]).is_equal([{"id": "rodauva_1", "antes": 5, "cambio": 1,
			"despues": 6, "anotaciones": [{"cambio": 1, "motivo": "victoria"}]}])
	assert_dict(victoria["pergaminos"]).is_equal({"en_blanco": 0, "ardidos": []})
	# Campos de tareas futuras: null o lista vacia. Reescrito en T29 (Sistema.md 6):
	# en una victoria, sin rescatista y permadeath falso.
	assert_object(victoria["atacante_pendiente"]).is_null()
	assert_object(victoria["rescatista"]).is_null()
	assert_bool(victoria["permadeath"]).is_false()
	# Reescrito en T23 (A.7, D-011): metricas ya no es null; valida con el resto.
	assert_int((victoria["metricas"]["rondas"] as Dictionary)["totales"]).is_equal(1)
	# Reescrito por Sistema.md 2.1 (T21): el mana del Maestro es un entero; sin
	# gastos, el de entrada (la reserva de su balanza en el fixture).
	assert_int((victoria["maestro"] as Dictionary)["mana"]).is_equal(
			combate.contexto().plantel.maestro.fila_balanza()["reserva_mana"])
	var con_mana_nulo: Dictionary = victoria.duplicate(true)
	(con_mana_nulo["maestro"] as Dictionary)["mana"] = null
	assert_array(_errores_esquema(con_mana_nulo, "resultado")).is_not_empty()
	assert_array(victoria["capturas"]).is_empty()

	# Derrota: la Rodauva arranca en 0 (caida) y la Ocarra tumba al Maestro: muere
	# y su pergamino arde.
	var con_caida: Dictionary = _escenario(_CARPETA_CONTRATO + "contrato_derrota.json")
	((con_caida["tribu"] as Array)[0] as Dictionary)["vida"] = 0
	var derrota: Dictionary = _combate(con_caida).resultado().a_diccionario()
	_assert_valida(derrota, "resultado")
	assert_str(derrota["desenlace"]).is_equal("derrota_por_caida")
	assert_bool(derrota["maestro_caido"]).is_true()
	assert_array(derrota["muertas"]).is_equal(["rodauva_1"])
	assert_dict(_estado(derrota, "rodauva_1")).contains_key_value("estado", "muerta")
	assert_array((derrota["pergaminos"] as Dictionary)["ardidos"]).is_equal(["pergamino_1"])
	assert_object(derrota["atacante_pendiente"]).is_null()
	# T29 (Sistema.md 6): la unica de la tribu esta caida: permadeath.
	assert_object(derrota["rescatista"]).is_null()
	assert_bool(derrota["permadeath"]).is_true()

	# Escenario G con la atacante en 0: queda caida, victoria sin rondas y su
	# destino queda pendiente (T30).
	var nocturno: Dictionary = _escenario(_CARPETA_UNIDADES + "escenario_g.json")
	((nocturno["enemigas"] as Array)[0] as Dictionary)["vida"] = 0
	var pendiente: Dictionary = _combate(nocturno).resultado().a_diccionario()
	_assert_valida(pendiente, "resultado")
	assert_str(pendiente["desenlace"]).is_equal("victoria")
	assert_int(pendiente["rondas"]).is_equal(0)
	assert_str(pendiente["atacante_pendiente"]).is_equal("ocarra_1")
	assert_dict(_estado(pendiente, "ocarra_1")).contains_key_value("estado", "caida")


# (12) P-019: cada motivo es una clave de lealtad.json eventos y el +1 de
# victoria sale de ahi, no de combate.json.
func test_p019_motivos_y_victoria_en_lealtad() -> void:
	var resultado: Dictionary = Cargador.new().esquema_resuelto(_CARPETA_DATOS, "resultado")["esquema"]
	var cambio: Dictionary = (resultado["properties"]["lealtad_cambios"] as Dictionary)["items"]
	var anotacion: Dictionary = (cambio["properties"]["anotaciones"] as Dictionary)["items"]
	var motivos: Array = (anotacion["properties"]["motivo"] as Dictionary)["enum"].duplicate()
	var lealtad: Dictionary = Cargador.new().esquema_resuelto(_CARPETA_DATOS, "lealtad")["esquema"]
	var eventos: Dictionary = lealtad["properties"]["eventos"]
	var claves: Array = (eventos["properties"] as Dictionary).keys()
	claves.erase("_nota")
	var requeridas: Array = (eventos["required"] as Array).duplicate()
	motivos.sort()
	claves.sort()
	requeridas.sort()
	assert_array(motivos).is_equal(claves)
	assert_array(requeridas).is_equal(claves)

	var datos: Dictionary = _datos()
	assert_bool((datos["tablas/combate.json"] as Dictionary).has("lealtad_por_victoria")).is_false()
	# Con otro numero en eventos.victoria, el Cierre lo usa.
	var tabla_lealtad: Dictionary = (datos["tablas/lealtad.json"] as Dictionary).duplicate(true)
	(tabla_lealtad["eventos"] as Dictionary)["victoria"] = 3
	var escenario: Dictionary = _escenario(_CARPETA_CONTRATO + "contrato_victoria.json")
	var contexto: ContextoCombate = ContextoCombate.armar(escenario, datos)
	contexto.cierre = Cierre.desde_datos(datos["tablas/combate.json"], tabla_lealtad, contexto.relaciones)
	var combate: Combate = Combate.empezar(contexto)
	_aplicar_valida(combate, Accion.mover(Vector2i(2, 5)))
	_aplicar_valida(combate, Accion.atacar("ocarra_s1"))
	var cambios: Array = combate.resultado().a_diccionario()["lealtad_cambios"]
	assert_array(cambios).is_equal([{"id": "rodauva_1", "antes": 5, "cambio": 3,
			"despues": 8, "anotaciones": [{"cambio": 3, "motivo": "victoria"}]}])


# (13) La grabacion valida contra su esquema y trae el escenario entero, la
# huella y las acciones con su unidad.
func test_grabacion_valida_y_completa() -> void:
	var escenario: Dictionary = _escenario(_CARPETA_CONTRATO + "contrato_victoria.json")
	var original: Dictionary = escenario.duplicate(true)
	var combate: Combate = _combate(escenario)
	_aplicar_valida(combate, Accion.mover(Vector2i(2, 5)))
	_aplicar_valida(combate, Accion.atacar("ocarra_s1"))
	var grabacion: Dictionary = Grabacion.desde_combate(combate).a_diccionario()
	_assert_valida(grabacion, "grabacion")
	assert_int(grabacion["version"]).is_equal(Grabacion.FORMATO)
	assert_dict(grabacion["escenario"]).is_equal(original)
	assert_str(grabacion["huella"]).is_equal(combate.contexto().huella)
	assert_int((grabacion["huella"] as String).length()).is_equal(64)
	assert_array(grabacion["acciones"]).is_equal([
		{"unidad": Maestro.ID, "accion": {"tipo": "mover", "casilla": [2, 5]}},
		{"unidad": Maestro.ID, "accion": {"tipo": "atacar", "objetivo": "ocarra_s1"}},
	])
	# Cambiar el escenario despues de armar no cambia lo grabado.
	escenario["semilla"] = 1
	assert_dict(Grabacion.desde_combate(combate).a_diccionario()["escenario"]).is_equal(original)

	var con_campo_de_mas: Dictionary = grabacion.duplicate(true)
	((con_campo_de_mas["acciones"] as Array)[0] as Dictionary)["paso"] = "remate"
	assert_array(_errores_esquema(con_campo_de_mas, "grabacion")).is_not_empty()


# (14) Reproducir da un registro identico al del combate en vivo, tambien
# despues de pasar la grabacion por texto.
func test_reproducir_da_el_mismo_registro() -> void:
	var en_vivo: Combate = _victoria()
	var grabacion: Grabacion = Grabacion.desde_combate(en_vivo)
	var reproduccion: Reproductor = _reproducir(grabacion)
	assert_bool(reproduccion.aviso_huella).is_false()
	assert_array(reproduccion.combate.registro().lineas_json()).is_equal(en_vivo.registro().lineas_json())
	assert_bool(reproduccion.combate.terminado()).is_true()

	# Ida y vuelta por JSON: los enteros vuelven como decimales y el esquema los convierte.
	var texto: String = JSON.stringify(grabacion.a_diccionario())
	var leida: Dictionary = Validador.new().validar(JSON.parse_string(texto),
			Cargador.new().esquema_resuelto(_CARPETA_DATOS, "grabacion")["esquema"], "grabacion")
	assert_array(leida["errores"] as Array).is_empty()
	var desde_texto: Reproductor = _reproducir(Grabacion.desde_diccionario(leida["datos"]))
	assert_array(desde_texto.combate.registro().lineas_json()).is_equal(en_vivo.registro().lineas_json())

	var c_en_vivo: Combate = _combate(_escenario(_CARPETA + "escenario_c.json"))
	_jugar_c(c_en_vivo)
	var c_reproducido: Reproductor = _reproducir(Grabacion.desde_combate(c_en_vivo))
	assert_array(c_reproducido.combate.registro().lineas_json()).is_equal(c_en_vivo.registro().lineas_json())


# (15) Reproducir hasta N = 0, 1, una del medio y la ultima da la misma
# instantanea y el mismo registro (hasta ahi) que jugar en vivo.
func test_reproducir_hasta_n() -> void:
	var en_vivo: Combate = _combate(_escenario(_CARPETA + "escenario_c.json"))
	var fotos: Array = _jugar_c(en_vivo)
	var grabacion: Grabacion = Grabacion.desde_combate(en_vivo)
	var ultima: int = grabacion.acciones.size()
	assert_int(ultima).is_greater(3)
	assert_int(fotos.size()).is_equal(ultima + 1)
	for n in [0, 1, ultima / 2, ultima]:
		var reproduccion: Reproductor = _reproducir(grabacion, n)
		assert_str(str(_foto(reproduccion.combate))).override_failure_message("N = %d" % n).is_equal(str(fotos[n]))
	# Mas acciones de las que hay es un error.
	assert_str(Reproductor.reproducir(grabacion, _datos(), ultima + 1).error).is_not_empty()


# (16, segunda parte) Con otra huella, el reproductor avisa y llega al mismo
# final. La huella del inicio es la de los datos con que se reproduce.
func test_otra_huella_avisa_y_llega_igual() -> void:
	var en_vivo: Combate = _victoria()
	var grabacion: Grabacion = Grabacion.desde_combate(en_vivo)
	grabacion.huella = "0".repeat(64)
	var reproduccion: Reproductor = _reproducir(grabacion)
	assert_bool(reproduccion.aviso_huella).is_true()
	assert_str(str(reproduccion.combate.instantanea())).is_equal(str(en_vivo.instantanea()))
	assert_array(reproduccion.combate.registro().lineas_json()).is_equal(en_vivo.registro().lineas_json())
	assert_str(reproduccion.combate.registro().lineas()[0]["huella"]).is_equal(en_vivo.contexto().huella)


# (17) Una grabacion con una accion imposible se detiene con error en esa
# accion, con el estado de la anterior.
func test_accion_imposible_detiene_con_error() -> void:
	var grabacion: Grabacion = Grabacion.desde_combate(_victoria())
	var hasta_1: Reproductor = _reproducir(grabacion, 1)

	# La segunda es un movimiento que no llega (y ya se movio en el turno).
	grabacion.acciones[1] = {"unidad": Maestro.ID, "accion": {"tipo": "mover", "casilla": [7, 0]}}
	var imposible: Reproductor = Reproductor.reproducir(grabacion, _datos())
	assert_str(imposible.error).is_not_empty()
	assert_int(imposible.accion_con_error).is_equal(2)
	assert_str(str(imposible.combate.instantanea())).is_equal(str(hasta_1.combate.instantanea()))
	assert_bool(imposible.combate.terminado()).is_false()

	# La primera dice ser de otra unidad que la del turno.
	var otra: Grabacion = Grabacion.desde_combate(_victoria())
	otra.acciones[0] = {"unidad": "rodauva_1", "accion": {"tipo": "mover", "casilla": [2, 5]}}
	var ajena: Reproductor = Reproductor.reproducir(otra, _datos())
	assert_str(ajena.error).is_not_empty()
	assert_int(ajena.accion_con_error).is_equal(1)
	assert_str(str(ajena.combate.instantanea())).is_equal(str(_reproducir(otra, 0).combate.instantanea()))


# T23 (D-011): true si en el valor hay algun float, a cualquier profundidad.
func _tiene_float(valor: Variant) -> bool:
	if valor is float:
		return true
	if valor is Dictionary:
		for clave in (valor as Dictionary).keys():
			if _tiene_float(valor[clave]):
				return true
	if valor is Array:
		for elemento in (valor as Array):
			if _tiene_float(elemento):
				return true
	return false


# (8) T23: las metricas de una victoria y de una derrota (con muertas) validan
# contra el esquema y no tienen ningun float (D-011). La derrota cuenta la
# caida del Maestro (P-043) y la muerte con su causa.
func test_t23_metricas_de_victoria_y_derrota() -> void:
	var victoria: Dictionary = _victoria().resultado().a_diccionario()
	_assert_valida(victoria, "resultado")
	var metricas: Dictionary = victoria["metricas"]
	assert_bool(_tiene_float(metricas)).is_false()
	assert_dict(metricas["rondas"]).is_equal({"totales": 1, "primer_ataque": 1, "de_pelea": 1})
	# La Ocarra salvaje la tumba en la ronda 1 (se levanta en el cierre); la Ocarra
	# salvaje en 0 sale del tablero sin caer (Sistema.md 11.5).
	assert_array(metricas["caidas"]).is_equal([{"unidad": "rodauva_1", "ronda": 1}])
	assert_array(metricas["muertes"]).is_empty()

	var con_caida: Dictionary = _escenario(_CARPETA_CONTRATO + "contrato_derrota.json")
	((con_caida["tribu"] as Array)[0] as Dictionary)["vida"] = 0
	var derrota: Dictionary = _combate(con_caida).resultado().a_diccionario()
	_assert_valida(derrota, "resultado")
	assert_bool(_tiene_float(derrota["metricas"])).is_false()
	assert_array(derrota["metricas"]["muertes"]).is_equal([{"unidad": "rodauva_1", "causa": "derrota_por_caida"}])
	var caidas: Array = (derrota["metricas"]["caidas"] as Array).map(func(caida: Dictionary) -> String: return caida["unidad"])
	assert_array(caidas).contains([Maestro.ID])
	# Un float en una metrica no valida.
	var con_float: Dictionary = victoria.duplicate(true)
	(con_float["metricas"]["secundar"] as Dictionary)["usos"] = 0.5
	assert_array(_errores_esquema(con_float, "resultado")).is_not_empty()


# (9) T23: las metricas sobre el registro en vivo y sobre el de su reproduccion
# son exactamente las mismas (tambien las del resultado).
func test_t23_metricas_en_vivo_y_reproducidas() -> void:
	var en_vivo: Combate = _victoria()
	var reproduccion: Reproductor = _reproducir(Grabacion.desde_combate(en_vivo))
	var escenario: Dictionary = en_vivo.contexto().escenario
	assert_str(JSON.stringify(MetricasCombate.calcular(escenario, reproduccion.combate.registro().lineas()), "", true)) \
			.is_equal(JSON.stringify(MetricasCombate.calcular(escenario, en_vivo.registro().lineas()), "", true))
	assert_dict(reproduccion.combate.resultado().a_diccionario()["metricas"]) \
			.is_equal(en_vivo.resultado().a_diccionario()["metricas"])

	# C jugado dos rondas (sin terminar): mismas metricas del registro parcial.
	var c_en_vivo: Combate = _combate(_escenario(_CARPETA + "escenario_c.json"))
	_jugar_c(c_en_vivo)
	var c_reproducido: Reproductor = _reproducir(Grabacion.desde_combate(c_en_vivo))
	var escenario_c: Dictionary = c_en_vivo.contexto().escenario
	assert_dict(MetricasCombate.calcular(escenario_c, c_reproducido.combate.registro().lineas())) \
			.is_equal(MetricasCombate.calcular(escenario_c, c_en_vivo.registro().lineas()))
