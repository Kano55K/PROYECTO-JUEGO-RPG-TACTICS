extends GdUnitTestSuite

# Arquitectura.md B.3 (T19): el chequeo de rival enemiga, con fixtures (A.6).
# Sistema.md 1.3 (Arrimo), 5.4 (obediencia), 10.5 (Encono), 10.6 (cobardia y el
# toggle de afines, P-008), 11.2.2 (la oculta), 11.3 paso 3 v1.6 y 11.5 (la
# caida no participa). Lectura declarada S-37 (una tirada con varias rivales).
# Los porcentajes salen de ChequeoRival.consulta con combate.json de prueba; para
# fijar una tirada, combate_rival_100.json con tramo neutral y balanza 5 (Arrimo 0).
# Cada test acomoda a sus unidades alrededor de [3,3]; las demas quedan
# estacionadas (escenario_rival.json). Cubre los puntos (1) a (5), (12) y (13).
const _CARPETA: String = "res://pruebas/fixtures/combate/"
const _CARPETA_UNIDADES: String = "res://pruebas/fixtures/unidades/"
const _ESPECIES: Array[String] = ["ocarra", "rodauva", "surcon", "tasajero", "zancajunco"]
const _BASE: String = "combate.json"
const _BASE_100: String = "combate_rival_100.json"
# Encono 25 % e incidente 100 %: con la semilla 1, la tirada del Encono no sale
# (54) y la del incidente si (4).
const _ENCONO_25_INCIDENTE_100: String = "combate_incidente_100.json"

var _tablero: Tablero


func before_test() -> void:
	var tabla_combate: Dictionary = _leer(_CARPETA + _BASE, "combate")
	_tablero = Tablero.desde_datos({"ancho": 12, "alto": 12}, tabla_combate)


func _leer(ruta: String, nombre_esquema: String) -> Dictionary:
	var lectura: Dictionary = LectorFixture.leer(ruta, nombre_esquema)
	var errores: Array[Dictionary] = lectura["errores"]
	assert_array(errores).override_failure_message(str(errores)).is_empty()
	return lectura["datos"]


# El plantel de escenario_rival.json con las posiciones de `ubicar`. especie_ocarra_1:
# otra ficha para ocarra_1 (el test de la rama por rol), o {}.
func _plantel(ubicar: Dictionary = {}, especie_ocarra_1: Dictionary = {}) -> Plantel:
	var especies: Dictionary = {}
	for id_especie in _ESPECIES:
		especies[id_especie] = Especie.new(_leer(_CARPETA_UNIDADES + id_especie + ".json", "especie"))
	var escenario: Dictionary = _leer(_CARPETA + "escenario_rival.json", "escenario")
	if not especie_ocarra_1.is_empty():
		especies[especie_ocarra_1["id"]] = Especie.new(especie_ocarra_1)
		(escenario["tribu"] as Array)[0]["especie"] = especie_ocarra_1["id"]
	var tabla: TablaBalanza = TablaBalanza.new(_leer(_CARPETA_UNIDADES + "balanza_1_2.json", "balanza"))
	var plantel: Plantel = Plantel.desde_escenario(escenario, especies, tabla,
			_leer(_CARPETA_UNIDADES + "maestro.json", "maestro"))
	for id_unidad in ubicar.keys():
		if id_unidad == Maestro.ID:
			plantel.maestro.posicion = ubicar[id_unidad]
		else:
			plantel.criatura(id_unidad).posicion = ubicar[id_unidad]
	return plantel


# Sistema.md 5.4: con la balanza 5 (umbral 8) o la 2 (umbral 7) y el piso de Neutral 4.
func _leal(plantel: Plantel, id_unidad: String) -> void:
	plantel.criatura(id_unidad).lealtad = 8
	plantel.criatura(id_unidad).hambre = 3


func _baja(plantel: Plantel, id_unidad: String) -> void:
	plantel.criatura(id_unidad).lealtad = 5
	plantel.criatura(id_unidad).hambre = 6


func _pct(chequeo: ChequeoRival, plantel: Plantel, id_unidad: String) -> int:
	return chequeo.consulta(id_unidad, plantel.criatura(id_unidad).posicion, plantel)["porcentaje"]


# El turno de la unidad, como lo empieza el Combate (corre los pasos 3 y 4).
func _turno(plantel: Plantel, unidad_id: String, azar: GeneradorAzar, combate: String = _BASE_100) -> Turno:
	return Turno.empezar(EntradaCola.new(unidad_id, "", 0), plantel, _tablero, Surcos.new(),
			DatosFixture.cadena(), ColaIniciativa.new(),
			DatosFixture.reglas({"incidente": DatosFixture.incidente(combate),
				"chequeo_rival": DatosFixture.chequeo_rival(combate)}), azar)


func _combate(combate: String) -> Combate:
	var lectura: Dictionary = DatosFixture.cargar(combate)
	assert_array(lectura["errores"]).is_empty()
	var contexto: ContextoCombate = ContextoCombate.armar(_leer(_CARPETA + "escenario_rival_combate.json",
			"escenario"), lectura["datos"])
	assert_bool(contexto.valido).is_true()
	var combate_armado: Combate = Combate.empezar(contexto)
	assert_str(combate_armado.error()).is_empty()
	return combate_armado


func _aplicar(combate: Combate, accion: Accion) -> void:
	var resultado: ResultadoAccion = combate.aplicar(accion)
	assert_bool(resultado.valida).override_failure_message(str(ResultadoAccion.Motivo.keys()[resultado.motivo])).is_true()
	assert_str(combate.error()).is_empty()


# (1) Sistema.md 10.5: 25 % + 25 % por punto, -5 por paso de Arrimo (1.3) y +-10
# por obediencia (5.4). Con la balanza 2 (3 pasos), la leal con contador 0 da 0 %
# y no tira. Con la balanza 5 (0 pasos): neutral 25, leal 15, baja 35; cada
# punto suma 25. Con el contador en el maximo queda enconada sin tirar.
func test_porcentaje_del_encono() -> void:
	var chequeo: ChequeoRival = DatosFixture.chequeo_rival(_BASE)
	var plantel: Plantel = _plantel({"ocarra_1": Vector2i(3, 3), "ocarra_s1": Vector2i(3, 6)})
	plantel.maestro.balanza = 2
	_leal(plantel, "ocarra_1")
	assert_int(_pct(chequeo, plantel, "ocarra_1")).is_equal(0)
	var azar: GeneradorAzar = GeneradorAzar.new(1)
	assert_dict(chequeo.tirar("ocarra_1", plantel, azar)).is_empty()
	assert_int(azar.historial().size()).is_equal(0)

	plantel.maestro.balanza = 5
	assert_int(_pct(chequeo, plantel, "ocarra_1")).is_equal(15)
	plantel.criatura("ocarra_1").lealtad = 5
	assert_int(_pct(chequeo, plantel, "ocarra_1")).is_equal(25)
	_baja(plantel, "ocarra_1")
	assert_int(_pct(chequeo, plantel, "ocarra_1")).is_equal(35)
	plantel.criatura("ocarra_1").hambre = 3
	plantel.criatura("ocarra_1").encono = 1
	assert_int(_pct(chequeo, plantel, "ocarra_1")).is_equal(50)

	plantel.criatura("ocarra_1").encono = 3
	var consulta: Dictionary = chequeo.consulta("ocarra_1", Vector2i(3, 3), plantel)
	assert_bool(consulta["seguro"]).is_true()
	assert_int(consulta["porcentaje"]).is_equal(100)
	var seguro: Dictionary = chequeo.tirar("ocarra_1", plantel, azar)
	assert_int(azar.historial().size()).is_equal(0)
	assert_dict(seguro).is_equal({"tipo": "encono", "rivales": ["ocarra_s1"], "porcentaje": 100, "tiro": false,
			"resultado": "enconada"})


# (2) Sistema.md 10.6, tabla de la balanza 2: leal 25, leal con el Maestro vecino
# 15 (ortogonal o en diagonal: vecina en 8, 11.3 v1.6), neutral 45, baja 65. Con
# el Maestro a distancia 2 no resta: 25.
func test_porcentaje_de_la_cobardia() -> void:
	var chequeo: ChequeoRival = DatosFixture.chequeo_rival(_BASE)
	var plantel: Plantel = _plantel({"rodauva_1": Vector2i(3, 3), "tasajero_s1": Vector2i(3, 7)})
	plantel.maestro.balanza = 2
	_leal(plantel, "rodauva_1")
	assert_int(_pct(chequeo, plantel, "rodauva_1")).is_equal(25)
	plantel.maestro.posicion = Vector2i(2, 3)
	assert_int(_pct(chequeo, plantel, "rodauva_1")).is_equal(15)
	plantel.maestro.posicion = Vector2i(2, 2)
	assert_int(_pct(chequeo, plantel, "rodauva_1")).is_equal(15)
	plantel.maestro.posicion = Vector2i(1, 3)
	assert_int(_pct(chequeo, plantel, "rodauva_1")).is_equal(25)
	plantel.criatura("rodauva_1").lealtad = 5
	assert_int(_pct(chequeo, plantel, "rodauva_1")).is_equal(45)
	_baja(plantel, "rodauva_1")
	assert_int(_pct(chequeo, plantel, "rodauva_1")).is_equal(65)


# (3) Sistema.md 10.6, toggle de afines (P-008): con la balanza 2, la Rodauva leal
# junto a dos Rodauvas da 5; con solo el Maestro al lado, 15 (el Maestro no cuenta
# como afin del toggle). Una afin en diagonal cuenta; una caida no. Con las dos
# Rodauvas y el Maestro, el minimo 5. Sin el toggle, las afines no restan.
func test_toggle_de_afines() -> void:
	var con_toggle: ChequeoRival = DatosFixture.chequeo_rival(_BASE, true)
	var sin_toggle: ChequeoRival = DatosFixture.chequeo_rival(_BASE, false)
	var plantel: Plantel = _plantel({"rodauva_1": Vector2i(3, 3), "rodauva_2": Vector2i(2, 3),
			"rodauva_3": Vector2i(4, 3), "tasajero_s1": Vector2i(3, 7)})
	plantel.maestro.balanza = 2
	for id_rodauva in ["rodauva_1", "rodauva_2", "rodauva_3"]:
		_leal(plantel, id_rodauva)
	assert_int(_pct(con_toggle, plantel, "rodauva_1")).is_equal(5)
	assert_int(_pct(sin_toggle, plantel, "rodauva_1")).is_equal(25)
	plantel.maestro.posicion = Vector2i(3, 2)
	assert_int(_pct(con_toggle, plantel, "rodauva_1")).is_equal(5)

	var solo_maestro: Plantel = _plantel({"rodauva_1": Vector2i(3, 3), Maestro.ID: Vector2i(3, 2),
			"tasajero_s1": Vector2i(3, 7)})
	solo_maestro.maestro.balanza = 2
	_leal(solo_maestro, "rodauva_1")
	assert_int(_pct(con_toggle, solo_maestro, "rodauva_1")).is_equal(15)

	var diagonal: Plantel = _plantel({"rodauva_1": Vector2i(3, 3), "rodauva_2": Vector2i(2, 2),
			"rodauva_3": Vector2i(4, 4), "tasajero_s1": Vector2i(3, 7)})
	diagonal.maestro.balanza = 2
	_leal(diagonal, "rodauva_1")
	diagonal.criatura("rodauva_3").estado = Criatura.Estado.CAIDA
	assert_int(_pct(con_toggle, diagonal, "rodauva_1")).is_equal(15)


# (4) Sistema.md 10.5 ("a su alcance": Manhattan <= Movimiento + Alcance), 11.2.2
# y 11.5: en el borde si, uno mas no; oculta no, destapada si; caida no. Del mismo
# bando o sin par "mal", no hay chequeo. Con dos rivales, una sola tirada (S-37).
func test_a_su_alcance() -> void:
	var chequeo: ChequeoRival = DatosFixture.chequeo_rival(_BASE)
	var plantel: Plantel = _plantel({"ocarra_1": Vector2i(3, 3), "ocarra_s1": Vector2i(3, 8)})
	assert_array(chequeo.rivales_a_su_alcance("ocarra_1", Vector2i(3, 3), plantel)).is_equal(["ocarra_s1"])
	plantel.criatura("ocarra_s1").posicion = Vector2i(3, 9)
	assert_array(chequeo.rivales_a_su_alcance("ocarra_1", Vector2i(3, 3), plantel)).is_empty()

	plantel.criatura("zancajunco_s1").posicion = Vector2i(3, 5)
	plantel.criatura("zancajunco_s1").oculta = true
	assert_array(chequeo.rivales_a_su_alcance("ocarra_1", Vector2i(3, 3), plantel)).is_empty()
	plantel.criatura("zancajunco_s1").oculta = false
	assert_array(chequeo.rivales_a_su_alcance("ocarra_1", Vector2i(3, 3), plantel)).is_equal(["zancajunco_s1"])
	plantel.criatura("zancajunco_s1").estado = Criatura.Estado.CAIDA
	assert_array(chequeo.rivales_a_su_alcance("ocarra_1", Vector2i(3, 3), plantel)).is_empty()

	var sin_rival: Plantel = _plantel({"ocarra_1": Vector2i(3, 3), "ocarra_2": Vector2i(3, 5),
			"surcon_s1": Vector2i(4, 4)})
	var azar: GeneradorAzar = GeneradorAzar.new(1)
	assert_dict(chequeo.tirar("ocarra_1", sin_rival, azar)).is_empty()
	assert_int(azar.historial().size()).is_equal(0)

	var dos: Plantel = _plantel({"ocarra_1": Vector2i(3, 3), "ocarra_s1": Vector2i(3, 6),
			"zancajunco_s1": Vector2i(4, 5)})
	var datos: Dictionary = chequeo.tirar("ocarra_1", dos, azar)
	assert_int(azar.historial().size()).is_equal(1)
	assert_array(datos["rivales"]).is_equal(["ocarra_s1", "zancajunco_s1"])
	assert_int(datos["porcentaje"]).is_equal(25)


# (5) Sistema.md 10.5 y 10.6, K-06: la rama sale del rol de la ficha, no del id.
# Una especie inventada (especie_prueba, rival del Tasajero) de rol combate tira
# Encono; la misma ficha con rol trabajo tira cobardia.
func test_rama_por_rol() -> void:
	var relaciones: Dictionary = _leer(_CARPETA + "relaciones_rival_prueba.json", "relaciones")
	var chequeo: ChequeoRival = DatosFixture.chequeo_rival(_BASE, false, relaciones)
	var ficha: Dictionary = _leer(_CARPETA + "especie_rival_prueba.json", "especie")
	var combate: Plantel = _plantel({"ocarra_1": Vector2i(3, 3), "tasajero_s1": Vector2i(3, 6)}, ficha)
	var consulta: Dictionary = chequeo.consulta("ocarra_1", Vector2i(3, 3), combate)
	assert_str(consulta["tipo"]).is_equal("encono")
	assert_int(consulta["porcentaje"]).is_equal(25)

	var trabajo: Dictionary = ficha.duplicate(true)
	trabajo["rol"] = "trabajo"
	var otra: Plantel = _plantel({"ocarra_1": Vector2i(3, 3), "tasajero_s1": Vector2i(3, 6)}, trabajo)
	consulta = chequeo.consulta("ocarra_1", Vector2i(3, 3), otra)
	assert_str(consulta["tipo"]).is_equal("cobardia")
	assert_int(consulta["porcentaje"]).is_equal(60)
	var turno: Turno = Turno.empezar(EntradaCola.new("ocarra_1", "", 0), otra, _tablero, Surcos.new(),
			DatosFixture.cadena(), ColaIniciativa.new(),
			DatosFixture.reglas({"incidente": DatosFixture.incidente(_BASE_100),
				"chequeo_rival": DatosFixture.chequeo_rival(_BASE_100, false, relaciones)}), GeneradorAzar.new(1))
	assert_bool(turno.acobardada).is_true()
	assert_bool(turno.enconada).is_false()


# (12) T19: Combate.rival_en da el chequeo que tendria la unidad al empezar su
# turno en esa casilla con el tablero de ahora: si nadie se movio, el mismo que
# tiro. Calcula sin aplicar: la instantanea no cambia.
func test_rival_en() -> void:
	var combate: Combate = _combate(_BASE_100)
	assert_str(combate.turno_actual().unidad_id).is_equal("ocarra_1")
	var antes: String = str(combate.instantanea())
	var tirado: Dictionary = combate.turno_actual().chequeo_rival
	var aqui: Dictionary = combate.rival_en("ocarra_1", Vector2i(3, 5))
	assert_str(aqui["tipo"]).is_equal(tirado["tipo"])
	assert_array(aqui["rivales"]).is_equal(tirado["rivales"])
	assert_int(aqui["porcentaje"]).is_equal(tirado["porcentaje"])
	# ocarra_2 en [4,6] no la tiene a su alcance (6); parada en [3,4], si (3).
	assert_array(combate.rival_en("ocarra_2", Vector2i(4, 6))["rivales"]).is_empty()
	var ahi: Dictionary = combate.rival_en("ocarra_2", Vector2i(3, 4))
	assert_array(ahi["rivales"]).is_equal(["ocarra_s1"])
	assert_int(ahi["porcentaje"]).is_equal(100)
	assert_str(str(combate.instantanea())).is_equal(antes)


# (13) Arquitectura.md A.7: detras del `turno`, la `tirada` del chequeo, el
# `chequeo_rival` y despues lo del incidente (su `tirada` y su evento). Con la
# semilla 1 el Encono (25 %) no sale y el incidente (100 %) si: distraida.
func test_registro_del_chequeo_y_del_incidente() -> void:
	var combate: Combate = _combate(_ENCONO_25_INCIDENTE_100)
	var lineas: Array[Dictionary] = combate.registro().lineas()
	var turno: int = -1
	for indice in lineas.size():
		if lineas[indice]["tipo"] == "turno" and lineas[indice]["unidad"] == "ocarra_1":
			turno = indice
	var tipos: Array[String] = []
	for linea in lineas.slice(turno, turno + 5):
		tipos.append(linea["tipo"])
	assert_array(tipos).is_equal(["turno", "tirada", "chequeo_rival", "tirada", "incidente"])
	assert_int(lineas[turno + 1]["resultado"] as int).is_equal(54)
	assert_dict(lineas[turno + 2]).is_equal({"tipo": "chequeo_rival", "unidad": "ocarra_1", "tipo_chequeo": "encono",
			"rivales": ["ocarra_s1"], "porcentaje": 25, "tiro": true, "resultado": "no_enconada", "ronda": 1,
			"n": lineas[turno + 2]["n"]})
	assert_str(lineas[turno + 4]["resultado"]).is_equal("distraida")


# (13) Arquitectura.md A.7: la enconada segura (100 %) no tira incidente; su golpe
# a la rival va como `ataque` con el `encono` detras; la `instantanea` lleva el
# contador; la grabacion se reproduce igual, linea por linea.
func test_registro_instantanea_y_grabacion() -> void:
	var combate: Combate = _combate(_BASE_100)
	var turno: Turno = combate.turno_actual()
	assert_bool(turno.enconada).is_true()
	assert_dict(turno.incidente).is_empty()
	_aplicar(combate, Accion.mover(Vector2i(3, 3)))
	_aplicar(combate, Accion.atacar("ocarra_s1"))
	var lineas: Array[Dictionary] = combate.registro().lineas()
	var ataque: int = -1
	for indice in lineas.size():
		if lineas[indice]["tipo"] == "ataque":
			ataque = indice
	assert_int(ataque).is_greater_equal(0)
	assert_int((lineas[ataque]["desglose"] as Dictionary)["total"] as int).is_equal(5)
	var encono: Dictionary = lineas[ataque + 1]
	assert_dict(encono).contains_key_value("tipo", "encono").contains_key_value("unidad", "ocarra_1") \
			.contains_key_value("de", 0).contains_key_value("a", 1).contains_key_value("rival", "ocarra_s1")
	var tirado: Array[Dictionary] = []
	for linea in lineas:
		if linea["tipo"] in ["chequeo_rival", "incidente"]:
			tirado.append(linea)
	assert_int(tirado.size()).is_equal(1)
	assert_str(tirado[0]["resultado"]).is_equal("enconada")
	for criatura in combate.instantanea()["criaturas"]:
		if criatura["id"] == "ocarra_1":
			assert_int(criatura["encono"] as int).is_equal(1)
	_aplicar(combate, Accion.terminar())

	var grabacion: Grabacion = Grabacion.desde_combate(combate)
	var reproduccion: Reproductor = Reproductor.reproducir(Grabacion.desde_diccionario(grabacion.a_diccionario()),
			DatosFixture.cargar(_BASE_100)["datos"])
	assert_str(reproduccion.error).is_empty()
	assert_array(reproduccion.combate.registro().lineas_json()).is_equal(combate.registro().lineas_json())
	assert_str(str(reproduccion.combate.instantanea())).is_equal(str(combate.instantanea()))


# T19, sesion 2 (punto 14): el tope del contador para la pantalla ("Encono n/3"),
# el mismo que usa la regla (Sistema.md 10.5: "contador de 0 a 3").
func test_maximo_encono() -> void:
	assert_int(DatosFixture.chequeo_rival(_BASE).maximo_encono()).is_equal(3)
