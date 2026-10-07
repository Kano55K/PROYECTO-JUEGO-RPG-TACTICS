extends GdUnitTestSuite

# Arquitectura.md B.2.1 (T37): el surco, con fixtures (A.6). Un test por fila de
# Sistema.md 11.2.1, mas 11.3 (Movimiento, Casilla libre, Alcance 2), 1.6
# (Lanzadera: destino en un surco) y A.7 (eventos surco y surco_cerrado).
const _CARPETA: String = "res://pruebas/fixtures/combate/"
const _CARPETA_UNIDADES: String = "res://pruebas/fixtures/unidades/"
const _CARPETA_DATOS: String = "res://datos"
const _ESPECIES: Array[String] = ["ocarra", "rodauva", "surcon", "tasajero", "zancajunco"]
const _SURCON: String = "surcon_1"
const _SURCON_SALVAJE: String = "surcon_s1"

var _tablero: Tablero
var _danio: Danio


func before_test() -> void:
	var tabla_combate: Dictionary = _leer(_CARPETA + "combate.json", "combate")
	_tablero = Tablero.desde_datos({"ancho": 8, "alto": 8}, tabla_combate)
	_danio = Danio.desde_datos(tabla_combate, _leer(_CARPETA + "hambre.json", "hambre"))


func _leer(ruta: String, nombre_esquema: String) -> Dictionary:
	var lectura: Dictionary = LectorFixture.leer(ruta, nombre_esquema)
	var errores: Array[Dictionary] = lectura["errores"]
	assert_array(errores).override_failure_message(str(errores)).is_empty()
	return lectura["datos"]


# escenario_surco.json: Surcon [3,4], Rodauva [1,2] y Ocarra [6,6] de la tribu;
# Surcon salvaje [5,1] y Rodauva salvaje [6,4].
func _plantel() -> Plantel:
	var especies: Dictionary = {}
	for id_especie in _ESPECIES:
		especies[id_especie] = Especie.new(_leer(_CARPETA_UNIDADES + id_especie + ".json", "especie"))
	var tabla: TablaBalanza = TablaBalanza.new(_leer(_CARPETA_UNIDADES + "balanza_1_2.json", "balanza"))
	return Plantel.desde_escenario(_leer(_CARPETA + "escenario_surco.json", "escenario"), especies, tabla,
			_leer(_CARPETA_UNIDADES + "maestro.json", "maestro"))


# Turno suelto, sin cola, con los surcos del combate.
func _turno(plantel: Plantel, unidad_id: String, surcos: Surcos) -> Turno:
	return Turno.empezar(EntradaCola.new(unidad_id, "", 0), plantel, _tablero, _danio, surcos,
			DatosFixture.afinidad(), DatosFixture.cadena())


# Todo lo que una accion puede cambiar: Plantel, surcos y turno.
func _foto(plantel: Plantel, surcos: Surcos, turno: Turno) -> String:
	return str([plantel.instantanea(), surcos.instantanea(), surcos.historial(), turno.pasos_restantes,
			turno.ataques_restantes, turno.movimiento_usado, turno.accion_usada, turno.terminado, turno.se_movio])


func _assert_valida(resultado: ResultadoAccion) -> void:
	assert_bool(resultado.valida).override_failure_message("motivo: " + ResultadoAccion.Motivo.keys()[resultado.motivo]).is_true()


func _assert_rechazada(resultado: ResultadoAccion, motivo: ResultadoAccion.Motivo) -> void:
	assert_bool(resultado.valida).is_false()
	assert_str(ResultadoAccion.Motivo.keys()[resultado.motivo]).is_equal(ResultadoAccion.Motivo.keys()[motivo])


# Valida sin aplicar y comprueba que no cambio nada.
func _validar(plantel: Plantel, surcos: Surcos, turno: Turno, accion: Accion) -> ResultadoAccion:
	var antes: String = _foto(plantel, surcos, turno)
	var resultado: ResultadoAccion = turno.validar(accion)
	assert_str(_foto(plantel, surcos, turno)).is_equal(antes)
	return resultado


# Un turno entero del Surcon que cava en `casilla` y termina.
func _cavar_turno(plantel: Plantel, surcos: Surcos, unidad_id: String, casilla: Vector2i) -> void:
	var turno: Turno = _turno(plantel, unidad_id, surcos)
	_assert_valida(turno.aplicar(Accion.cavar(casilla)))
	_assert_valida(turno.aplicar(Accion.terminar()))


# (1) Donde (11.2.1): una casilla libre (sin unidad ni surco), ortogonalmente
# adyacente. Puede estar junto a enemigas.
func test_donde_cavar() -> void:
	var plantel: Plantel = _plantel()
	var surcos: Surcos = Surcos.new()
	surcos.cavar(Vector2i(3, 5), _SURCON_SALVAJE, 2)
	plantel.criatura("rodauva_1").posicion = Vector2i(2, 4)
	var ocarra: Criatura = plantel.criatura("ocarra_1")
	ocarra.posicion = Vector2i(4, 4)
	ocarra.vida = 0
	ocarra.estado = Criatura.Estado.CAIDA
	var turno: Turno = _turno(plantel, _SURCON, surcos)
	# Diagonal y a distancia 2: no son adyacentes.
	_assert_rechazada(_validar(plantel, surcos, turno, Accion.cavar(Vector2i(4, 3))), ResultadoAccion.Motivo.CASILLA_NO_ADYACENTE)
	_assert_rechazada(_validar(plantel, surcos, turno, Accion.cavar(Vector2i(3, 2))), ResultadoAccion.Motivo.CASILLA_NO_ADYACENTE)
	# Ocupada por una de pie, por una caida, o con un surco (aunque sea de otro Surcon).
	_assert_rechazada(_validar(plantel, surcos, turno, Accion.cavar(Vector2i(2, 4))), ResultadoAccion.Motivo.CASILLA_NO_LIBRE)
	_assert_rechazada(_validar(plantel, surcos, turno, Accion.cavar(Vector2i(4, 4))), ResultadoAccion.Motivo.CASILLA_NO_LIBRE)
	_assert_rechazada(_validar(plantel, surcos, turno, Accion.cavar(Vector2i(3, 5))), ResultadoAccion.Motivo.CASILLA_NO_LIBRE)
	# Junto a una enemiga de pie: vale.
	plantel.criatura("rodauva_s1").posicion = Vector2i(3, 2)
	_assert_valida(_validar(plantel, surcos, turno, Accion.cavar(Vector2i(3, 3))))
	_assert_valida(turno.aplicar(Accion.cavar(Vector2i(3, 3))))
	assert_bool(surcos.hay_en(Vector2i(3, 3))).is_true()
	assert_array(surcos.de(_SURCON)).is_equal([Vector2i(3, 3)])

	# Fuera del tablero: adyacente, pero no libre.
	var en_borde: Plantel = _plantel()
	en_borde.criatura(_SURCON).posicion = Vector2i(0, 0)
	var turno_borde: Turno = _turno(en_borde, _SURCON, Surcos.new())
	_assert_rechazada(turno_borde.validar(Accion.cavar(Vector2i(-1, 0))), ResultadoAccion.Motivo.CASILLA_NO_LIBRE)
	_assert_rechazada(turno_borde.validar(Accion.cavar(Vector2i(0, -1))), ResultadoAccion.Motivo.CASILLA_NO_LIBRE)


# (2) Costo (11.2.1, 11.3): turno completo, sin haberse movido. Despues solo vale
# terminar, y no es "esperar". Solo con el efecto surco.
func test_costo_turno_completo() -> void:
	var plantel: Plantel = _plantel()
	var surcos: Surcos = Surcos.new()
	var turno: Turno = _turno(plantel, _SURCON, surcos)
	_assert_valida(turno.aplicar(Accion.mover(Vector2i(3, 5))))
	_assert_rechazada(_validar(plantel, surcos, turno, Accion.cavar(Vector2i(3, 6))), ResultadoAccion.Motivo.YA_SE_MOVIO)

	plantel = _plantel()
	plantel.criatura("rodauva_s1").posicion = Vector2i(2, 4)
	turno = _turno(plantel, _SURCON, surcos)
	_assert_valida(turno.aplicar(Accion.cavar(Vector2i(3, 3))))
	_assert_rechazada(_validar(plantel, surcos, turno, Accion.mover(Vector2i(3, 5))), ResultadoAccion.Motivo.MOVIMIENTO_USADO)
	_assert_rechazada(_validar(plantel, surcos, turno, Accion.atacar("rodauva_s1")), ResultadoAccion.Motivo.ACCION_USADA)
	_assert_rechazada(_validar(plantel, surcos, turno, Accion.cavar(Vector2i(4, 4))), ResultadoAccion.Motivo.ACCION_USADA)
	var fin: ResultadoAccion = turno.aplicar(Accion.terminar())
	_assert_valida(fin)
	assert_bool(fin.espero).is_false()
	assert_bool(Accion.cavar(Vector2i(3, 3)).gasta_turno_completo()).is_true()

	# Sin el efecto surco: no cava.
	var turno_rodauva: Turno = _turno(plantel, "rodauva_1", surcos)
	_assert_rechazada(turno_rodauva.validar(Accion.cavar(Vector2i(1, 1))), ResultadoAccion.Motivo.SIN_RASGO)


# (3) Tope (11.2.1): 2 surcos por Surcon; el tercero cierra el mas viejo. Cada
# Surcon tiene su tope.
func test_tope() -> void:
	var plantel: Plantel = _plantel()
	var surcos: Surcos = Surcos.new()
	_cavar_turno(plantel, surcos, _SURCON, Vector2i(3, 3))
	_cavar_turno(plantel, surcos, _SURCON, Vector2i(2, 4))
	_cavar_turno(plantel, surcos, _SURCON_SALVAJE, Vector2i(5, 2))
	_cavar_turno(plantel, surcos, _SURCON_SALVAJE, Vector2i(4, 1))
	assert_int(surcos.instantanea().size()).is_equal(4)

	_cavar_turno(plantel, surcos, _SURCON, Vector2i(4, 4))
	assert_array(surcos.de(_SURCON)).is_equal([Vector2i(2, 4), Vector2i(4, 4)])
	assert_array(surcos.de(_SURCON_SALVAJE)).is_equal([Vector2i(5, 2), Vector2i(4, 1)])
	assert_bool(surcos.hay_en(Vector2i(3, 3))).is_false()
	var historial: Array[Dictionary] = surcos.historial()
	assert_int(historial.size()).is_equal(6)
	assert_dict(historial[4]).is_equal({"tipo": "surco", "unidad": _SURCON, "casilla": [4, 4]})
	assert_dict(historial[5]).is_equal({"tipo": "surco_cerrado", "casilla": [3, 3], "duenio": _SURCON, "motivo": "tope"})


# (4) Duracion (11.2.1): mientras su Surcon este en el tablero, de pie o caido.
# Se cierran si sale del tablero.
func test_duracion() -> void:
	var plantel: Plantel = _plantel()
	var surcos: Surcos = Surcos.new()
	_cavar_turno(plantel, surcos, _SURCON, Vector2i(2, 4))
	# Caido: los conserva, y siguen cerrando el paso.
	var surcon: Criatura = plantel.criatura(_SURCON)
	surcon.vida = 1
	plantel.criatura("rodauva_s1").posicion = Vector2i(3, 3)
	var golpe: Turno = _turno(plantel, "rodauva_s1", surcos)
	_assert_valida(golpe.aplicar(Accion.atacar(_SURCON)))
	assert_int(surcon.estado).is_equal(Criatura.Estado.CAIDA)
	assert_array(surcos.de(_SURCON)).is_equal([Vector2i(2, 4)])
	plantel.criatura("rodauva_1").posicion = Vector2i(1, 4)
	var pasos: Dictionary = _tablero.pasos_hasta(Vector2i(1, 4), 4, Criatura.Bando.TRIBU, plantel, surcos, false)
	assert_bool(pasos.has(Vector2i(2, 4))).is_false()

	# Un Surcon salvaje que sale del tablero (vida 0, fuera) los cierra.
	_cavar_turno(plantel, surcos, _SURCON_SALVAJE, Vector2i(5, 2))
	_cavar_turno(plantel, surcos, _SURCON_SALVAJE, Vector2i(4, 1))
	plantel.criatura(_SURCON_SALVAJE).vida = 1
	plantel.criatura("rodauva_1").posicion = Vector2i(6, 1)
	var remate: Turno = _turno(plantel, "rodauva_1", surcos)
	_assert_valida(remate.aplicar(Accion.atacar(_SURCON_SALVAJE)))
	assert_int(plantel.criatura(_SURCON_SALVAJE).estado).is_equal(Criatura.Estado.FUERA)
	assert_array(surcos.de(_SURCON_SALVAJE)).is_empty()
	assert_array(surcos.de(_SURCON)).is_equal([Vector2i(2, 4)])
	var historial: Array[Dictionary] = surcos.historial()
	assert_array(historial.slice(historial.size() - 2)).is_equal([
		{"tipo": "surco_cerrado", "casilla": [5, 2], "duenio": _SURCON_SALVAJE, "motivo": "duenio_fuera"},
		{"tipo": "surco_cerrado", "casilla": [4, 1], "duenio": _SURCON_SALVAJE, "motivo": "duenio_fuera"},
	])


# (5) Transito (11.2.1, 11.3 Movimiento): solo un Surcon, de cualquier bando,
# entra, atraviesa o termina en un surco. Para el resto es intransitable.
func test_transito() -> void:
	var plantel: Plantel = _plantel()
	var surcos: Surcos = Surcos.new()
	var desde: Vector2i = Vector2i(1, 2)
	assert_int(_tablero.pasos_hasta(desde, 4, Criatura.Bando.TRIBU, plantel, surcos, false)[Vector2i(3, 2)]).is_equal(2)
	surcos.cavar(Vector2i(2, 2), _SURCON, 2)
	var pasos: Dictionary = _tablero.pasos_hasta(desde, 4, Criatura.Bando.TRIBU, plantel, surcos, false)
	assert_bool(pasos.has(Vector2i(2, 2))).is_false()
	assert_int(pasos[Vector2i(3, 2)]).is_equal(4)
	var turno_rodauva: Turno = _turno(plantel, "rodauva_1", surcos)
	_assert_rechazada(turno_rodauva.validar(Accion.mover(Vector2i(2, 2))), ResultadoAccion.Motivo.CASILLA_NO_ALCANZABLE)
	assert_bool(turno_rodauva.casillas_para_mover().has(Vector2i(2, 2))).is_false()
	assert_int(turno_rodauva.pasos_para_mover()[Vector2i(3, 2)]).is_equal(4)

	# El Surcon salvaje pisa el surco del Surcon de la tribu: lo atraviesa y termina ahi.
	surcos.cavar(Vector2i(5, 2), _SURCON, 2)
	var pasos_surcon: Dictionary = _tablero.pasos_hasta(Vector2i(5, 1), 2, Criatura.Bando.ENEMIGA, plantel, surcos, true)
	assert_int(pasos_surcon[Vector2i(5, 2)]).is_equal(1)
	assert_int(pasos_surcon[Vector2i(5, 3)]).is_equal(2)
	_assert_valida(_turno(plantel, _SURCON_SALVAJE, surcos).aplicar(Accion.mover(Vector2i(5, 3))))
	assert_that(plantel.criatura(_SURCON_SALVAJE).posicion).is_equal(Vector2i(5, 3))
	var turno_surcon: Turno = _turno(plantel, _SURCON_SALVAJE, surcos)
	_assert_valida(turno_surcon.aplicar(Accion.mover(Vector2i(5, 2))))
	assert_that(plantel.criatura(_SURCON_SALVAJE).posicion).is_equal(Vector2i(5, 2))


# (6) Linea (11.2.1, 11.3 Alcance 2): el surco es un pozo, no un muro.
func test_linea_por_encima_del_surco() -> void:
	var plantel: Plantel = _plantel()
	var surcos: Surcos = Surcos.new()
	surcos.cavar(Vector2i(6, 5), _SURCON, 2)
	assert_bool(_tablero.linea_bloqueada(Vector2i(6, 6), Vector2i(6, 4), Criatura.Bando.TRIBU, plantel)).is_false()
	var turno: Turno = _turno(plantel, "ocarra_1", surcos)
	var golpe: ResultadoAccion = turno.aplicar(Accion.atacar("rodauva_s1"))
	_assert_valida(golpe)
	assert_int(golpe.danio).is_equal(4)


# (7) Casilla libre (11.3, S-25) y destino de la Lanzadera (1.6).
func test_casilla_libre_y_desplazamiento() -> void:
	var plantel: Plantel = _plantel()
	var surcos: Surcos = Surcos.new()
	surcos.cavar(Vector2i(2, 2), _SURCON, 2)
	var ocarra: Criatura = plantel.criatura("ocarra_1")
	ocarra.vida = 0
	ocarra.estado = Criatura.Estado.CAIDA
	# Libre: dentro, sin unidad (de pie o caida) y sin surco.
	assert_bool(_tablero.es_casilla_libre(Vector2i(4, 4), plantel, surcos)).is_true()
	assert_bool(_tablero.es_casilla_libre(Vector2i(1, 2), plantel, surcos)).is_false()
	assert_bool(_tablero.es_casilla_libre(Vector2i(0, 7), plantel, surcos)).is_false()
	assert_bool(_tablero.es_casilla_libre(Vector2i(6, 6), plantel, surcos)).is_false()
	assert_bool(_tablero.es_casilla_libre(Vector2i(2, 2), plantel, surcos)).is_false()
	assert_bool(_tablero.es_casilla_libre(Vector2i(8, 0), plantel, surcos)).is_false()
	assert_bool(_tablero.es_casilla_libre(Vector2i(0, -1), plantel, surcos)).is_false()
	# Un surco no es libre ni para un Surcon (S-25): no cava encima.
	var turno: Turno = _turno(plantel, _SURCON, surcos)
	plantel.criatura(_SURCON).posicion = Vector2i(2, 3)
	_assert_rechazada(turno.validar(Accion.cavar(Vector2i(2, 2))), ResultadoAccion.Motivo.CASILLA_NO_LIBRE)

	# Lanzadera: un surco cuenta como ocupada, salvo para un Surcon.
	assert_bool(_tablero.bloquea_desplazamiento(Vector2i(4, 4), "rodauva_1", plantel, surcos)).is_false()
	assert_bool(_tablero.bloquea_desplazamiento(Vector2i(4, 4), Maestro.ID, plantel, surcos)).is_false()
	assert_bool(_tablero.bloquea_desplazamiento(Vector2i(6, 4), "rodauva_1", plantel, surcos)).is_true()
	assert_bool(_tablero.bloquea_desplazamiento(Vector2i(6, 6), "rodauva_1", plantel, surcos)).is_true()
	assert_bool(_tablero.bloquea_desplazamiento(Vector2i(-1, 2), "rodauva_1", plantel, surcos)).is_true()
	assert_bool(_tablero.bloquea_desplazamiento(Vector2i(2, 2), "rodauva_1", plantel, surcos)).is_true()
	assert_bool(_tablero.bloquea_desplazamiento(Vector2i(2, 2), Maestro.ID, plantel, surcos)).is_true()
	assert_bool(_tablero.bloquea_desplazamiento(Vector2i(2, 2), _SURCON, plantel, surcos)).is_false()
	assert_bool(_tablero.bloquea_desplazamiento(Vector2i(2, 2), _SURCON_SALVAJE, plantel, surcos)).is_false()


# T39: las consultas casillas_para_cavar y surcos_propios del Turno (para la IA
# del paso 7 de 11.8 y la pantalla de T40). Las casillas son las que `cavar`
# acepta (11.2.1, Donde), en orden de lectura; validar no cambia nada.
func test_casillas_para_cavar_y_surcos_propios() -> void:
	var plantel: Plantel = _plantel()
	var surcos: Surcos = Surcos.new()
	var turno: Turno = _turno(plantel, _SURCON, surcos)
	var antes: String = _foto(plantel, surcos, turno)
	assert_array(turno.casillas_para_cavar()).is_equal([Vector2i(3, 3), Vector2i(2, 4), Vector2i(4, 4), Vector2i(3, 5)])
	assert_str(_foto(plantel, surcos, turno)).is_equal(antes)
	assert_array(turno.surcos_propios()).is_empty()

	# Sin la ocupada [4,4] ni la que tiene surco [2,4] (de otro Surcon).
	plantel.criatura("rodauva_1").posicion = Vector2i(4, 4)
	surcos.cavar(Vector2i(2, 4), _SURCON_SALVAJE, 2)
	turno = _turno(plantel, _SURCON, surcos)
	assert_array(turno.casillas_para_cavar()).is_equal([Vector2i(3, 3), Vector2i(3, 5)])
	assert_array(turno.surcos_propios()).is_empty()
	_assert_valida(turno.aplicar(Accion.cavar(Vector2i(3, 5))))
	assert_array(turno.surcos_propios()).is_equal([Vector2i(3, 5)])
	# Despues de cavar (turno completo) no queda ninguna.
	assert_array(turno.casillas_para_cavar()).is_empty()

	# En la esquina: solo las vecinas dentro del tablero.
	plantel = _plantel()
	plantel.criatura(_SURCON).posicion = Vector2i(0, 0)
	turno = _turno(plantel, _SURCON, Surcos.new())
	assert_array(turno.casillas_para_cavar()).is_equal([Vector2i(1, 0), Vector2i(0, 1)])

	# Despues de moverse, ninguna; sin el efecto surco, ninguna.
	plantel = _plantel()
	turno = _turno(plantel, _SURCON, Surcos.new())
	_assert_valida(turno.aplicar(Accion.mover(Vector2i(3, 3))))
	assert_array(turno.casillas_para_cavar()).is_empty()
	assert_array(_turno(plantel, "rodauva_1", Surcos.new()).casillas_para_cavar()).is_empty()


# (8) Registro, instantanea y grabacion (A.7): el Surcon de la tribu cava tres
# veces con Combate.aplicar; la grabacion valida y se reproduce igual.
# Reescrito en T39 por Sistema.md 11.8 paso 7: el Surcon salvaje [7,0] ya no
# solo se acerca; sin nadie a su alcance cava hacia la enemiga mas cercana (el
# Surcon de la tribu): [6,0] en la ronda 1 y [7,1] en la 2 (orden de lectura);
# en la 3, con el tope lleno, se acerca. Las cuentas de la tribu se filtran por dueno.
func test_registro_instantanea_y_grabacion() -> void:
	var lectura: Dictionary = DatosFixture.cargar()
	assert_array(lectura["errores"]).is_empty()
	var escenario: Dictionary = _leer(_CARPETA + "escenario_surco_tribu.json", "escenario")
	var combate: Combate = Combate.empezar(ContextoCombate.armar(escenario, lectura["datos"]))
	assert_str(combate.error()).is_empty()
	assert_array(combate.instantanea()["surcos"]).is_empty()
	for casilla in [Vector2i(3, 5), Vector2i(2, 6), Vector2i(4, 6)]:
		assert_str(combate.turno_actual().unidad_id).is_equal(Maestro.ID)
		_assert_valida(combate.aplicar(Accion.terminar()))
		assert_str(combate.turno_actual().unidad_id).is_equal(_SURCON)
		_assert_valida(combate.aplicar(Accion.cavar(casilla)))
		_assert_valida(combate.aplicar(Accion.terminar()))
		assert_str(combate.error()).is_empty()

	var lineas: Array[Dictionary] = combate.registro().lineas()
	var surcos_cavados: Array = []
	var cavados_salvaje: Array = []
	var cerrados: Array = []
	for indice in range(lineas.size()):
		var linea: Dictionary = lineas[indice]
		if linea["tipo"] == "accion" and linea["accion"]["tipo"] == "cavar":
			assert_dict(lineas[indice + 1]).contains_key_value("tipo", "surco")
			assert_dict(lineas[indice + 1]).contains_key_value("unidad", linea["unidad"])
			assert_that(lineas[indice + 1]["casilla"]).is_equal(linea["accion"]["casilla"])
		if linea["tipo"] == "surco" and linea["unidad"] == _SURCON:
			surcos_cavados.append(linea["casilla"])
		if linea["tipo"] == "surco" and linea["unidad"] == _SURCON_SALVAJE:
			cavados_salvaje.append(linea["casilla"])
		if linea["tipo"] == "surco_cerrado":
			assert_str(lineas[indice - 1]["tipo"]).is_equal("surco")
			cerrados.append(linea)
	assert_array(surcos_cavados).is_equal([[3, 5], [2, 6], [4, 6]])
	assert_array(cavados_salvaje).is_equal([[6, 0], [7, 1]])
	assert_int(cerrados.size()).is_equal(1)
	assert_that(cerrados[0]["casilla"]).is_equal([3, 5])
	assert_str(cerrados[0]["duenio"]).is_equal(_SURCON)
	assert_str(cerrados[0]["motivo"]).is_equal("tope")
	var de_la_tribu: Array = []
	for surco in combate.instantanea()["surcos"]:
		if surco["duenio"] == _SURCON:
			de_la_tribu.append(surco)
	assert_array(de_la_tribu).is_equal([
		{"casilla": [2, 6], "duenio": _SURCON, "orden": 3},
		{"casilla": [4, 6], "duenio": _SURCON, "orden": 5},
	])

	var grabacion: Grabacion = Grabacion.desde_combate(combate)
	var diccionario: Dictionary = grabacion.a_diccionario()
	var esquema: Dictionary = Cargador.new().esquema_resuelto(_CARPETA_DATOS, "grabacion")["esquema"]
	var validacion: Dictionary = Validador.new().validar(JSON.parse_string(JSON.stringify(diccionario)), esquema, "grabacion")
	assert_array(validacion["errores"] as Array).override_failure_message(str(validacion["errores"])).is_empty()
	assert_dict(diccionario["acciones"][1]).is_equal({"unidad": _SURCON, "accion": {"tipo": "cavar", "casilla": [3, 5]}})
	var reproduccion: Reproductor = Reproductor.reproducir(Grabacion.desde_diccionario(validacion["datos"]), lectura["datos"])
	assert_str(reproduccion.error).is_empty()
	assert_array(reproduccion.combate.registro().lineas_json()).is_equal(combate.registro().lineas_json())
	assert_str(str(reproduccion.combate.instantanea())).is_equal(str(combate.instantanea()))

	# Accion.cavar va y vuelve por diccionario; sin casilla o con otro campo, no.
	var accion: Accion = Accion.desde_diccionario(Accion.cavar(Vector2i(2, 6)).a_diccionario())
	assert_int(accion.tipo).is_equal(Accion.Tipo.CAVAR)
	assert_that(accion.casilla).is_equal(Vector2i(2, 6))
	assert_object(Accion.desde_diccionario({"tipo": "cavar"})).is_null()
	assert_object(Accion.desde_diccionario({"tipo": "cavar", "casilla": [1, 1], "objetivo": "x"})).is_null()
