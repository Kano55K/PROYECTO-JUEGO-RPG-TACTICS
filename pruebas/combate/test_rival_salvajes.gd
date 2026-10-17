extends GdUnitTestSuite

# Arquitectura.md B.3 (T20): las enemigas tiran Encono, cobardia e incidentes por
# la misma funcion que la tribu, con fixtures (A.6). Sistema.md 9.2 punto 3 (la
# atacante nocturna se trata como salvaje), 10.4 (incidente), 10.5 (Encono), 10.6
# (cobardia y toggle de afines), 10.7 (salvajes: obediencia <= 3 y sin Arrimo),
# 11.2.2 (la oculta), 11.3 pasos 3 y 4 y 11.5. Lectura declarada S-41 (el -10
# del Maestro vecino no vale para una enemiga). Con combate.json de prueba (los
# numeros de 10.4 a 10.6): Encono de una salvaje 25 + 10 = 35, cobardia 60 + 20 =
# 80, incidente 20. Cada test acomoda a sus unidades en las filas 6 a 9; las demas
# quedan estacionadas (escenario_rival_salvajes.json). Cubre los puntos (1) a (4),
# (13) y (14).
const _CARPETA: String = "res://pruebas/fixtures/combate/"
const _CARPETA_UNIDADES: String = "res://pruebas/fixtures/unidades/"
const _ESPECIES: Array[String] = ["ocarra", "rodauva", "surcon", "tasajero", "zancajunco"]
const _BASE: String = "combate.json"
const _BASE_100: String = "combate_rival_100.json"
const _INCIDENTE_100: String = "combate_incidente_100.json"

var _tablero: Tablero


func before_test() -> void:
	var tabla_combate: Dictionary = _leer(_CARPETA + _BASE, "combate")
	_tablero = Tablero.desde_datos({"ancho": 12, "alto": 12}, tabla_combate)


func _leer(ruta: String, nombre_esquema: String) -> Dictionary:
	var lectura: Dictionary = LectorFixture.leer(ruta, nombre_esquema)
	var errores: Array[Dictionary] = lectura["errores"]
	assert_array(errores).override_failure_message(str(errores)).is_empty()
	return lectura["datos"]


# El plantel de escenario_rival_salvajes.json con las posiciones de `ubicar`.
func _plantel(ubicar: Dictionary = {}) -> Plantel:
	var especies: Dictionary = {}
	for id_especie in _ESPECIES:
		especies[id_especie] = Especie.new(_leer(_CARPETA_UNIDADES + id_especie + ".json", "especie"))
	var tabla: TablaBalanza = TablaBalanza.new(_leer(_CARPETA_UNIDADES + "balanza_1_2.json", "balanza"))
	var plantel: Plantel = Plantel.desde_escenario(_leer(_CARPETA + "escenario_rival_salvajes.json", "escenario"),
			especies, tabla, _leer(_CARPETA_UNIDADES + "maestro.json", "maestro"))
	for id_unidad in ubicar.keys():
		if id_unidad == Maestro.ID:
			plantel.maestro.posicion = ubicar[id_unidad]
		else:
			plantel.criatura(id_unidad).posicion = ubicar[id_unidad]
	return plantel


func _pct(chequeo: ChequeoRival, plantel: Plantel, id_unidad: String) -> int:
	return chequeo.consulta(id_unidad, plantel.criatura(id_unidad).posicion, plantel)["porcentaje"]


func _pct_incidente(incidente: Incidente, plantel: Plantel, id_unidad: String) -> int:
	return incidente.consulta(id_unidad, plantel.criatura(id_unidad).posicion, plantel)["porcentaje"]


# El turno de la unidad, como lo empieza el Combate (corre los pasos 3 y 4).
func _turno(plantel: Plantel, unidad_id: String, combate: String, azar: GeneradorAzar = GeneradorAzar.new(1)) -> Turno:
	return Turno.empezar(EntradaCola.new(unidad_id, "", 0), plantel, _tablero, Surcos.new(),
			DatosFixture.cadena(), ColaIniciativa.new(),
			DatosFixture.reglas({"incidente": DatosFixture.incidente(combate),
				"chequeo_rival": DatosFixture.chequeo_rival(combate)}), azar)


# El combate de escenario_rival_salvajes_combate.json con las posiciones de `ubicar`.
func _combate(combate: String, ubicar: Dictionary = {}) -> Combate:
	var lectura: Dictionary = DatosFixture.cargar(combate)
	assert_array(lectura["errores"]).is_empty()
	var escenario: Dictionary = _leer(_CARPETA + "escenario_rival_salvajes_combate.json", "escenario")
	for datos_unidad in (escenario["tribu"] as Array) + (escenario["enemigas"] as Array):
		if ubicar.has(datos_unidad["id"]):
			datos_unidad["posicion"] = ubicar[datos_unidad["id"]]
	var contexto: ContextoCombate = ContextoCombate.armar(escenario, lectura["datos"])
	assert_bool(contexto.valido).is_true()
	var combate_armado: Combate = Combate.empezar(contexto)
	assert_str(combate_armado.error()).is_empty()
	return combate_armado


func _aplicar(combate: Combate, accion: Accion) -> void:
	var resultado: ResultadoAccion = combate.aplicar(accion)
	assert_bool(resultado.valida).override_failure_message(str(ResultadoAccion.Motivo.keys()[resultado.motivo])).is_true()
	assert_str(combate.error()).is_empty()


func _lineas_de(combate: Combate, tipo: String) -> Array[Dictionary]:
	var lineas: Array[Dictionary] = []
	for linea in combate.registro().lineas():
		if linea["tipo"] == tipo:
			lineas.append(linea)
	return lineas


func _reproduce_igual(combate: Combate, combate_json: String) -> void:
	var grabacion: Grabacion = Grabacion.desde_combate(combate)
	var reproduccion: Reproductor = Reproductor.reproducir(Grabacion.desde_diccionario(grabacion.a_diccionario()),
			DatosFixture.cargar(combate_json)["datos"])
	assert_str(reproduccion.error).is_empty()
	assert_array(reproduccion.combate.registro().lineas_json()).is_equal(combate.registro().lineas_json())


# (1) Sistema.md 10.5 y 10.7: una salvaje tira Encono como obediencia <= 3 (+10) y
# sin Arrimo: 35 con el contador en 0, 60 con 1, 85 con 2; con 3, enconada sin
# tirar. La balanza del Maestro (1, 2 o 5) no cambia nada.
func test_encono_de_una_salvaje() -> void:
	var chequeo: ChequeoRival = DatosFixture.chequeo_rival(_BASE)
	var plantel: Plantel = _plantel({"ocarra_s1": Vector2i(5, 6), "ocarra_1": Vector2i(5, 9)})
	var consulta: Dictionary = chequeo.consulta("ocarra_s1", Vector2i(5, 6), plantel)
	assert_str(consulta["tipo"]).is_equal(ChequeoRival.TIPO_ENCONO)
	assert_array(consulta["rivales"]).is_equal(["ocarra_1"])
	assert_int(consulta["porcentaje"]).is_equal(35)
	for balanza in [1, 2, 5]:
		plantel.maestro.balanza = balanza
		assert_int(_pct(chequeo, plantel, "ocarra_s1")).override_failure_message("balanza %d" % balanza).is_equal(35)
	plantel.criatura("ocarra_s1").encono = 1
	assert_int(_pct(chequeo, plantel, "ocarra_s1")).is_equal(60)
	plantel.criatura("ocarra_s1").encono = 2
	assert_int(_pct(chequeo, plantel, "ocarra_s1")).is_equal(85)

	plantel.criatura("ocarra_s1").encono = 3
	var azar: GeneradorAzar = GeneradorAzar.new(1)
	var seguro: Dictionary = chequeo.tirar("ocarra_s1", plantel, azar)
	assert_int(azar.historial().size()).is_equal(0)
	assert_dict(seguro).is_equal({"tipo": "encono", "rivales": ["ocarra_1"], "porcentaje": 100, "tiro": false,
			"resultado": "enconada"})


# (2) Sistema.md 10.6 y 10.7: la Rodauva salvaje (trabajo) con el Tasajero de la
# tribu a su alcance: 60 + 20 = 80. S-41: con el Maestro enemigo vecino,
# ortogonal o en diagonal, sigue en 80. Con el toggle y dos Rodauvas salvajes
# vecinas (una en diagonal), 60. Sin el toggle no restan.
func test_cobardia_de_una_salvaje() -> void:
	var sin_toggle: ChequeoRival = DatosFixture.chequeo_rival(_BASE, false)
	var con_toggle: ChequeoRival = DatosFixture.chequeo_rival(_BASE, true)
	var plantel: Plantel = _plantel({"rodauva_s1": Vector2i(5, 6), "tasajero_1": Vector2i(5, 9)})
	var consulta: Dictionary = sin_toggle.consulta("rodauva_s1", Vector2i(5, 6), plantel)
	assert_str(consulta["tipo"]).is_equal(ChequeoRival.TIPO_COBARDIA)
	assert_array(consulta["rivales"]).is_equal(["tasajero_1"])
	assert_int(consulta["porcentaje"]).is_equal(80)
	plantel.maestro.posicion = Vector2i(4, 6)
	assert_int(_pct(sin_toggle, plantel, "rodauva_s1")).is_equal(80)
	plantel.maestro.posicion = Vector2i(4, 5)
	assert_int(_pct(sin_toggle, plantel, "rodauva_s1")).is_equal(80)
	plantel.maestro.posicion = Vector2i(11, 0)

	plantel.criatura("rodauva_s2").posicion = Vector2i(6, 6)
	plantel.criatura("rodauva_s3").posicion = Vector2i(4, 7)
	assert_int(_pct(con_toggle, plantel, "rodauva_s1")).is_equal(60)
	assert_int(_pct(sin_toggle, plantel, "rodauva_s1")).is_equal(80)


# (3) Sistema.md 9.2 punto 3: la atacante nocturna tira como salvaje (35). 11.2.2
# y 11.5: una rival oculta o caida no cuenta. 10.5: el Maestro no tiene especie
# y nunca es rival, aunque este al lado.
func test_atacante_oculta_caida_y_maestro() -> void:
	var chequeo: ChequeoRival = DatosFixture.chequeo_rival(_BASE)
	var plantel: Plantel = _plantel({"ocarra_a1": Vector2i(5, 6), "ocarra_1": Vector2i(5, 9),
			Maestro.ID: Vector2i(5, 7)})
	var consulta: Dictionary = chequeo.consulta("ocarra_a1", Vector2i(5, 6), plantel)
	assert_array(consulta["rivales"]).is_equal(["ocarra_1"])
	assert_int(consulta["porcentaje"]).is_equal(35)

	plantel.criatura("zancajunco_1").posicion = Vector2i(6, 8)
	plantel.criatura("zancajunco_1").oculta = true
	assert_array(chequeo.rivales_a_su_alcance("ocarra_a1", Vector2i(5, 6), plantel)).is_equal(["ocarra_1"])
	plantel.criatura("zancajunco_1").oculta = false
	assert_array(chequeo.rivales_a_su_alcance("ocarra_a1", Vector2i(5, 6), plantel)) \
			.is_equal(["ocarra_1", "zancajunco_1"])
	plantel.criatura("zancajunco_1").estado = Criatura.Estado.CAIDA
	plantel.criatura("ocarra_1").estado = Criatura.Estado.CAIDA
	assert_array(chequeo.rivales_a_su_alcance("ocarra_a1", Vector2i(5, 6), plantel)).is_empty()
	var azar: GeneradorAzar = GeneradorAzar.new(1)
	assert_dict(chequeo.tirar("ocarra_a1", plantel, azar)).is_empty()
	assert_int(azar.historial().size()).is_equal(0)


# (4) Sistema.md 10.4 y 10.7: incidente entre salvajes, 20 % con cualquier balanza
# (sin Arrimo). Con 100 %: la rival ortogonal a su alcance recibe el golpe; con
# dos, la de menos vida, y con empate, la primera de la lista de enemigas (P-011).
func test_incidente_entre_salvajes() -> void:
	var incidente: Incidente = DatosFixture.incidente(_BASE)
	var plantel: Plantel = _plantel({"ocarra_s1": Vector2i(5, 6), "ocarra_s2": Vector2i(5, 7)})
	for balanza in [1, 2, 5]:
		plantel.maestro.balanza = balanza
		assert_int(_pct_incidente(incidente, plantel, "ocarra_s1")).override_failure_message("balanza %d" % balanza) \
				.is_equal(20)

	var golpe: Turno = _turno(plantel, "ocarra_s1", _INCIDENTE_100)
	assert_dict(golpe.chequeo_rival).is_empty()
	assert_dict(golpe.incidente).is_equal({"rivales": ["ocarra_s2"], "porcentaje": 100, "resultado": Turno.RESULTADO_GOLPE,
			"objetivo": "ocarra_s2"})
	assert_int(plantel.criatura("ocarra_s2").vida).is_equal(8)
	assert_bool(golpe.accion_usada).is_true()

	var empate: Plantel = _plantel({"ocarra_s1": Vector2i(5, 6), "ocarra_s3": Vector2i(5, 7), "ocarra_s2": Vector2i(4, 6)})
	assert_str(_turno(empate, "ocarra_s1", _INCIDENTE_100).incidente["objetivo"]).is_equal("ocarra_s2")
	var menos_vida: Plantel = _plantel({"ocarra_s1": Vector2i(5, 6), "ocarra_s3": Vector2i(5, 7),
			"ocarra_s2": Vector2i(4, 6)})
	menos_vida.criatura("ocarra_s3").vida = 5
	assert_str(_turno(menos_vida, "ocarra_s1", _INCIDENTE_100).incidente["objetivo"]).is_equal("ocarra_s3")


# (4) Sistema.md 10.4 v1.6: la rival en diagonal no esta a su alcance (la Alabarda
# pega en linea): se distrae. 10.4 y 11.3 paso 4: la enconada no tira incidente.
func test_incidente_diagonal_y_enconada() -> void:
	var plantel: Plantel = _plantel({"ocarra_s1": Vector2i(5, 6), "ocarra_s2": Vector2i(6, 7)})
	var distraida: Turno = _turno(plantel, "ocarra_s1", _INCIDENTE_100)
	assert_str(distraida.incidente["resultado"]).is_equal(Turno.RESULTADO_DISTRAIDA)
	assert_that(distraida.incidente["objetivo"]).is_null()
	assert_bool(distraida.accion_usada).is_true()
	assert_int(distraida.ataques_restantes).is_equal(0)
	assert_int(plantel.criatura("ocarra_s2").vida).is_equal(12)

	var enconada: Plantel = _plantel({"ocarra_s1": Vector2i(5, 6), "ocarra_s2": Vector2i(5, 7),
			"ocarra_1": Vector2i(7, 8)})
	var azar: GeneradorAzar = GeneradorAzar.new(1)
	var turno: Turno = _turno(enconada, "ocarra_s1", _BASE_100, azar)
	assert_bool(turno.enconada).is_true()
	assert_dict(turno.incidente).is_empty()
	assert_int(azar.historial().size()).is_equal(1)


# (13) T20: Combate.rival_en de una enemiga da el chequeo de su turno siguiente si
# nadie se mueve, y no cambia la instantanea. Con la semilla 1: ocarra_1 no se
# encona (54 > 25) y espera; ocarra_s1 tira 35 % y sale 4.
func test_rival_en_de_una_enemiga() -> void:
	var combate: Combate = _combate(_BASE)
	assert_str(combate.turno_actual().unidad_id).is_equal("ocarra_1")
	var antes: String = str(combate.instantanea())
	var previsto: Dictionary = combate.rival_en("ocarra_s1", Vector2i(3, 3))
	assert_str(str(combate.instantanea())).is_equal(antes)
	assert_str(previsto["tipo"]).is_equal(ChequeoRival.TIPO_ENCONO)
	assert_array(previsto["rivales"]).is_equal(["ocarra_1"])
	assert_int(previsto["porcentaje"]).is_equal(35)
	_aplicar(combate, Accion.terminar())
	var chequeos: Array[Dictionary] = _lineas_de(combate, "chequeo_rival")
	var de_la_salvaje: Dictionary = chequeos.filter(func(l: Dictionary) -> bool: return l["unidad"] == "ocarra_s1")[0]
	assert_array(de_la_salvaje["rivales"]).is_equal(previsto["rivales"])
	assert_int(de_la_salvaje["porcentaje"]).is_equal(previsto["porcentaje"])
	assert_str(de_la_salvaje["tipo_chequeo"]).is_equal(previsto["tipo"])


# (14) Arquitectura.md A.7 (T20): el chequeo_rival de la salvaje con su tirada,
# la `accion` de la IA con paso "encono", el `ataque` a su rival con el bono del
# Encono y el `encono` detras. La grabacion se reproduce con el mismo registro.
func test_registro_del_encono_de_una_salvaje() -> void:
	var combate: Combate = _combate(_BASE)
	_aplicar(combate, Accion.terminar())
	var lineas: Array[Dictionary] = combate.registro().lineas()
	var turno: int = -1
	for indice in lineas.size():
		if lineas[indice]["tipo"] == "turno" and lineas[indice]["unidad"] == "ocarra_s1":
			turno = indice
	assert_int(turno).is_greater_equal(0)
	assert_str(lineas[turno + 1]["tipo"]).is_equal("tirada")
	assert_int(lineas[turno + 1]["resultado"] as int).is_equal(4)
	assert_dict(lineas[turno + 2]).is_equal({"tipo": "chequeo_rival", "unidad": "ocarra_s1", "tipo_chequeo": "encono",
			"rivales": ["ocarra_1"], "porcentaje": 35, "tiro": true, "resultado": "enconada", "ronda": 1,
			"n": lineas[turno + 2]["n"]})
	var pasos: Array = []
	for linea in lineas.slice(turno):
		if linea["tipo"] == "accion" and linea["unidad"] == "ocarra_s1":
			pasos.append(linea["paso"])
	assert_array(pasos).is_not_empty()
	for paso in pasos:
		assert_str(paso).is_equal("encono")
	var ataque: int = -1
	for indice in range(turno, lineas.size()):
		if lineas[indice]["tipo"] == "ataque" and lineas[indice]["atacante"] == "ocarra_s1":
			ataque = indice
			break
	assert_int(ataque).is_greater(turno)
	assert_str(lineas[ataque]["objetivo"]).is_equal("ocarra_1")
	var fuentes: Array = []
	for modificador in (lineas[ataque]["desglose"] as Dictionary)["modificadores"]:
		fuentes.append(modificador["fuente"])
	assert_array(fuentes).contains(["encono"])
	assert_dict(lineas[ataque + 1]).contains_key_value("tipo", "encono").contains_key_value("unidad", "ocarra_s1") \
			.contains_key_value("de", 0).contains_key_value("a", 1).contains_key_value("rival", "ocarra_1")
	_reproduce_igual(combate, _BASE)


# (14) Arquitectura.md A.7 (T20): el incidente de una salvaje, detras de su
# `turno` y su `tirada`, con el golpe a su rival aliada como `ataque` sin eslabon.
# ocarra_1 queda lejos (sin chequeo). La grabacion se reproduce igual.
func test_registro_del_incidente_de_una_salvaje() -> void:
	var combate: Combate = _combate(_INCIDENTE_100, {"ocarra_1": [7, 7], "ocarra_s2": [3, 2]})
	_aplicar(combate, Accion.terminar())
	var lineas: Array[Dictionary] = combate.registro().lineas()
	var turno: int = -1
	for indice in lineas.size():
		if lineas[indice]["tipo"] == "turno" and lineas[indice]["unidad"] == "ocarra_s1":
			turno = indice
	var tipos: Array[String] = []
	for linea in lineas.slice(turno, turno + 4):
		tipos.append(linea["tipo"])
	assert_array(tipos).is_equal(["turno", "tirada", "incidente", "ataque"])
	assert_dict(lineas[turno + 2]).is_equal({"tipo": "incidente", "unidad": "ocarra_s1", "rivales": ["ocarra_s2"],
			"porcentaje": 100, "resultado": "golpe", "objetivo": "ocarra_s2", "ronda": 1, "n": lineas[turno + 2]["n"]})
	assert_dict(lineas[turno + 3]).contains_key_value("atacante", "ocarra_s1").contains_key_value("objetivo", "ocarra_s2") \
			.contains_key_value("eslabon", null)
	_reproduce_igual(combate, _INCIDENTE_100)


# T20, sesion 2 (revision 1a; Sistema.md 10.5, Tasajero enconado en Caza, y 11.4
# paso 3; D-005): la previsualizacion del segundo golpe de Caza a la misma rival
# lleva el punto de Encono que deja el primero, igual que el ataque real. Base 5:
# el primero suma min(0 + 1, 3) = 1 (6) y el segundo min(0 + 2, 3) = 2 (7). La
# rival tiene 13 de vida: solo cae si el segundo lleva el punto extra. Con el
# contador en el maximo, los dos suman 3 (8).
func test_segundo_golpe_de_caza_preve_el_punto_del_primero() -> void:
	var plantel: Plantel = _plantel({"tasajero_s1": Vector2i(5, 8), "ocarra_1": Vector2i(5, 9)})
	plantel.criatura("ocarra_1").vida = 13
	var turno: Turno = _turno(plantel, "tasajero_s1", _BASE_100)
	assert_bool(turno.enconada).is_true()
	var desde: Vector2i = Vector2i(5, 8)
	var primero: ResultadoAccion = turno.previsualizar_ataque(desde, "ocarra_1")
	var segundo: ResultadoAccion = turno.previsualizar_ataque(desde, "ocarra_1", true)
	assert_int(primero.danio).is_equal(6)
	assert_int(segundo.danio).is_equal(7)
	var aplicado: ResultadoAccion = turno.aplicar(Accion.atacar("ocarra_1"))
	assert_int(aplicado.danio).is_equal(primero.danio)
	# Despues del primero, la previsualizacion normal y la de tras_primer_ataque coinciden.
	assert_int(turno.previsualizar_ataque(desde, "ocarra_1").danio).is_equal(segundo.danio)
	assert_int(turno.previsualizar_ataque(desde, "ocarra_1", true).danio).is_equal(segundo.danio)
	aplicado = turno.aplicar(Accion.atacar("ocarra_1"))
	assert_int(aplicado.danio).is_equal(segundo.danio)
	assert_int(plantel.criatura("ocarra_1").vida).is_equal(0)

	var en_el_maximo: Plantel = _plantel({"tasajero_s1": Vector2i(5, 8), "ocarra_1": Vector2i(5, 9)})
	en_el_maximo.criatura("tasajero_s1").encono = 3
	turno = _turno(en_el_maximo, "tasajero_s1", _BASE_100)
	assert_bool(turno.enconada).is_true()
	assert_int(turno.previsualizar_ataque(desde, "ocarra_1").danio).is_equal(8)
	assert_int(turno.previsualizar_ataque(desde, "ocarra_1", true).danio).is_equal(8)
	turno.aplicar(Accion.atacar("ocarra_1"))
	assert_int(turno.aplicar(Accion.atacar("ocarra_1")).danio).is_equal(8)
