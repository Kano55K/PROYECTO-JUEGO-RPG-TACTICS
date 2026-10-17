extends GdUnitTestSuite

# Arquitectura.md B.3 (T18): incidentes con rival aliada, con fixtures (A.6).
# Sistema.md 1.3 (Arrimo), 5.4 (obediencia), 10.2 (el golpe corta la cadena),
# 10.4 v1.6 (incidente, vecinas en 8), 11.2.2 (la oculta), 11.3 paso 4 y 11.5 (la
# caida no participa). Lecturas declaradas S-32 (P-034), S-33 (P-035) y S-34
# (P-036). Para fijar la tirada, combate.json de prueba con la base en 100 o en 0
# y balanza 5 (Arrimo 0). Cada test acomoda a sus unidades alrededor de [3,3];
# las demas quedan estacionadas (escenario_incidente.json).
const _CARPETA: String = "res://pruebas/fixtures/combate/"
const _CARPETA_UNIDADES: String = "res://pruebas/fixtures/unidades/"
const _ESPECIES: Array[String] = ["ocarra", "rodauva", "surcon", "tasajero", "zancajunco"]
const _BASE_100: String = "combate_incidente_100.json"
const _BASE_0: String = "combate_incidente_0.json"
const _BASE_20: String = "combate.json"
# Reescrito en T19 (Sistema.md 10.5 y 10.6 v1.6, 11.3 paso 3): la Ocarra salvaje
# queda a su alcance de las Ocarras y del Zancajunco de la tribu, que ahora tiran
# su chequeo de rival enemiga antes del incidente. Los turnos de este archivo usan
# un chequeo que nunca tira, para que el generador mida solo el incidente; el
# orden de los dos chequeos se prueba en test_enconada.gd.
const _SIN_RIVAL: String = "combate_sin_rival.json"

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


# El plantel de escenario_incidente.json con las posiciones de `ubicar`.
func _plantel(ubicar: Dictionary = {}) -> Plantel:
	var especies: Dictionary = {}
	for id_especie in _ESPECIES:
		especies[id_especie] = Especie.new(_leer(_CARPETA_UNIDADES + id_especie + ".json", "especie"))
	var tabla: TablaBalanza = TablaBalanza.new(_leer(_CARPETA_UNIDADES + "balanza_1_2.json", "balanza"))
	var plantel: Plantel = Plantel.desde_escenario(_leer(_CARPETA + "escenario_incidente.json", "escenario"),
			especies, tabla, _leer(_CARPETA_UNIDADES + "maestro.json", "maestro"))
	for id_unidad in ubicar.keys():
		if id_unidad == Maestro.ID:
			plantel.maestro.posicion = ubicar[id_unidad]
		else:
			plantel.criatura(id_unidad).posicion = ubicar[id_unidad]
	return plantel


# Sistema.md 5.4 con la balanza 5 (umbral 8) y el piso de Neutral 4.
func _leal(plantel: Plantel, id_unidad: String) -> void:
	plantel.criatura(id_unidad).lealtad = 8
	plantel.criatura(id_unidad).hambre = 3


func _neutral(plantel: Plantel, id_unidad: String) -> void:
	plantel.criatura(id_unidad).lealtad = 5
	plantel.criatura(id_unidad).hambre = 3


func _baja(plantel: Plantel, id_unidad: String) -> void:
	plantel.criatura(id_unidad).lealtad = 5
	plantel.criatura(id_unidad).hambre = 6


# El turno de la unidad, como lo empieza el Combate (corre el paso 4).
func _turno(plantel: Plantel, unidad_id: String, azar: GeneradorAzar, combate: String = _BASE_100,
		cadena: Cadena = null, cola: ColaIniciativa = null) -> Turno:
	return Turno.empezar(EntradaCola.new(unidad_id, "", 0), plantel, _tablero, Surcos.new(),
			cadena if cadena != null else DatosFixture.cadena(),
			cola if cola != null else ColaIniciativa.new(),
			DatosFixture.reglas({"incidente": DatosFixture.incidente(combate),
				"chequeo_rival": DatosFixture.chequeo_rival(_SIN_RIVAL)}), azar)


func _motivo(turno: Turno, accion: Accion) -> String:
	return ResultadoAccion.Motivo.keys()[turno.validar(accion).motivo]


# Un combate de fixtures (escenario_incidente_combate) con la base en 100.
func _combate() -> Combate:
	var lectura: Dictionary = DatosFixture.cargar(_BASE_100)
	assert_array(lectura["errores"]).is_empty()
	var contexto: ContextoCombate = ContextoCombate.armar(_leer(_CARPETA + "escenario_incidente_combate.json",
			"escenario"), lectura["datos"])
	assert_bool(contexto.valido).is_true()
	var combate: Combate = Combate.empezar(contexto)
	assert_str(combate.error()).is_empty()
	return combate


func _eventos(combate: Combate, tipo: String) -> Array[Dictionary]:
	var resultado: Array[Dictionary] = []
	for linea in combate.registro().lineas():
		if linea["tipo"] == tipo:
			resultado.append(linea)
	return resultado


func _aplicar(combate: Combate, accion: Accion) -> ResultadoAccion:
	var resultado: ResultadoAccion = combate.aplicar(accion)
	assert_bool(resultado.valida).override_failure_message(
			str(accion.a_diccionario()) + " -> " + ResultadoAccion.Motivo.keys()[resultado.motivo]).is_true()
	return resultado


# (1) Sistema.md 10.4 v1.6 y 11.3 v1.6: una rival en diagonal (vecina en 8, no
# ortogonal) hace tirar; a 2 casillas, no, y el generador no avanza.
func test_rival_en_diagonal_tira_y_a_dos_no() -> void:
	var plantel: Plantel = _plantel({"ocarra_1": Vector2i(3, 3), "zancajunco_1": Vector2i(4, 4)})
	var azar: GeneradorAzar = GeneradorAzar.new(1)
	_turno(plantel, "ocarra_1", azar, _BASE_20)
	assert_int(azar.historial().size()).is_equal(1)

	plantel = _plantel({"ocarra_1": Vector2i(3, 3), "zancajunco_1": Vector2i(5, 5)})
	azar = GeneradorAzar.new(1)
	var turno: Turno = _turno(plantel, "ocarra_1", azar, _BASE_100)
	assert_int(azar.historial().size()).is_equal(0)
	assert_dict(turno.incidente).is_empty()


# (2) Sistema.md 11.5 y 11.2.2: una rival caida, guardada, fuera o de otro bando
# no hace tirar; una oculta, si.
func test_caida_guardada_fuera_y_otro_bando_no_y_oculta_si() -> void:
	for estado in [Criatura.Estado.CAIDA, Criatura.Estado.GUARDADA, Criatura.Estado.FUERA]:
		var plantel: Plantel = _plantel({"ocarra_1": Vector2i(3, 3), "zancajunco_1": Vector2i(4, 4)})
		plantel.criatura("zancajunco_1").estado = estado
		var azar: GeneradorAzar = GeneradorAzar.new(1)
		assert_dict(_turno(plantel, "ocarra_1", azar).incidente).is_empty()
		assert_int(azar.historial().size()).override_failure_message(str(estado)).is_equal(0)

	var otro_bando: Plantel = _plantel({"ocarra_1": Vector2i(3, 3), "ocarra_s1": Vector2i(4, 4)})
	var azar_bando: GeneradorAzar = GeneradorAzar.new(1)
	assert_dict(_turno(otro_bando, "ocarra_1", azar_bando).incidente).is_empty()
	assert_int(azar_bando.historial().size()).is_equal(0)

	var oculta: Plantel = _plantel({"ocarra_1": Vector2i(3, 3), "zancajunco_1": Vector2i(4, 4)})
	oculta.criatura("zancajunco_1").oculta = true
	var azar_oculta: GeneradorAzar = GeneradorAzar.new(1)
	var turno: Turno = _turno(oculta, "ocarra_1", azar_oculta)
	assert_int(azar_oculta.historial().size()).is_equal(1)
	assert_array(turno.incidente["rivales"]).is_equal(["zancajunco_1"])


# (3) Sistema.md 10.8: una aliada sin relacion (Rodauva) o "bien" (Surcon) no
# hace tirar.
func test_aliada_que_no_es_rival_no_tira() -> void:
	var plantel: Plantel = _plantel({"ocarra_1": Vector2i(3, 3), "rodauva_1": Vector2i(4, 3),
			"surcon_1": Vector2i(2, 2)})
	var azar: GeneradorAzar = GeneradorAzar.new(1)
	assert_dict(_turno(plantel, "ocarra_1", azar).incidente).is_empty()
	assert_int(azar.historial().size()).is_equal(0)


# Comun a (4) y (5): el Zancajunco con la Ocarra rival al lado y una enemiga a su
# alcance se distrae: pierde la accion y conserva el movimiento.
func _comprobar_distraida(obediencia: Callable) -> void:
	var plantel: Plantel = _plantel({"zancajunco_1": Vector2i(3, 3), "ocarra_1": Vector2i(3, 2),
			"ocarra_s1": Vector2i(4, 3), "rodauva_1": Vector2i(2, 4)})
	obediencia.call(plantel, "zancajunco_1")
	var cola: ColaIniciativa = ColaIniciativa.new()
	cola.empezar_ronda(plantel)
	var turno: Turno = _turno(plantel, "zancajunco_1", GeneradorAzar.new(1), _BASE_100, null, cola)
	assert_dict(turno.incidente).is_equal({"rivales": ["ocarra_1"], "porcentaje": 100,
			"resultado": Turno.RESULTADO_DISTRAIDA, "objetivo": null})
	assert_dict(turno.golpe_incidente).is_empty()
	# Nadie recibio un golpe.
	assert_int(plantel.criatura("ocarra_1").vida).is_equal(12)
	assert_str(_motivo(turno, Accion.atacar("ocarra_s1"))).is_equal("ACCION_USADA")
	assert_str(_motivo(turno, Accion.erizarse())).is_equal("ACCION_USADA")
	assert_str(_motivo(turno, Accion.hacerse_junco())).is_equal("ACCION_USADA")
	assert_str(_motivo(turno, Accion.secundar("rodauva_1"))).is_equal("ACCION_USADA")
	assert_bool(turno.movimiento_usado).is_false()
	assert_bool(turno.validar(Accion.mover(Vector2i(2, 3))).valida).is_true()
	assert_bool(turno.aplicar(Accion.mover(Vector2i(2, 3))).valida).is_true()
	assert_bool(turno.aplicar(Accion.terminar()).valida).is_true()


# (4) Sistema.md 10.4 y 5.4: base 100 y obediencia leal → se distrae.
func test_leal_se_distrae() -> void:
	_comprobar_distraida(_leal)


# (5) Sistema.md 10.4 y 5.4: base 100 y obediencia neutral → igual que el 4.
func test_neutral_se_distrae() -> void:
	_comprobar_distraida(_neutral)


# (6) Sistema.md 10.4 y 11.4: base 100 y obediencia baja con la rival
# ortogonal: la golpea por el camino del ataque (mismo desglose que Danio con la
# afinidad de su casilla) y conserva el movimiento.
func test_baja_golpea_a_la_rival() -> void:
	var plantel: Plantel = _plantel({"ocarra_1": Vector2i(3, 3), "zancajunco_1": Vector2i(3, 2)})
	_baja(plantel, "ocarra_1")
	var esperado: DesgloseDanio = _danio.calcular("ocarra_1", "zancajunco_1", plantel, [])
	var turno: Turno = _turno(plantel, "ocarra_1", GeneradorAzar.new(1))
	assert_dict(turno.incidente).is_equal({"rivales": ["zancajunco_1"], "porcentaje": 100,
			"resultado": Turno.RESULTADO_GOLPE, "objetivo": "zancajunco_1"})
	# La Ocarra (4) hambrienta, sin otros modificadores: 4.
	assert_int(esperado.total).is_equal(4)
	assert_int(plantel.criatura("zancajunco_1").vida).is_equal(12 - esperado.total)
	assert_dict((turno.golpe_incidente["desglose"] as DesgloseDanio).a_diccionario()).is_equal(esperado.a_diccionario())
	assert_int(turno.golpe_incidente["vida_antes"]).is_equal(12)
	assert_int(turno.golpe_incidente["vida_despues"]).is_equal(8)
	assert_str(_motivo(turno, Accion.atacar("ocarra_s1"))).is_equal("ACCION_USADA")
	assert_bool(turno.movimiento_usado).is_false()
	assert_bool(turno.aplicar(Accion.mover(Vector2i(3, 4))).valida).is_true()

	# Con una afin vecina (Surcon-Ocarra bien), el golpe suma la afinidad (11.4).
	var con_afin: Plantel = _plantel({"ocarra_1": Vector2i(3, 3), "zancajunco_1": Vector2i(3, 2),
			"surcon_1": Vector2i(2, 4)})
	_baja(con_afin, "ocarra_1")
	_turno(con_afin, "ocarra_1", GeneradorAzar.new(1))
	assert_int(con_afin.criatura("zancajunco_1").vida).is_equal(12 - 5)


# (7) Sistema.md 10.4, Precisiones: con dos rivales a su alcance golpea a la de
# menos vida actual; si empatan, a la primera en el orden de la tribu.
func test_baja_elige_la_de_menos_vida_y_desempata_por_orden() -> void:
	var ubicar: Dictionary = {"ocarra_1": Vector2i(3, 3), "zancajunco_1": Vector2i(3, 2), "ocarra_2": Vector2i(4, 3)}
	var empate: Plantel = _plantel(ubicar)
	_baja(empate, "ocarra_1")
	assert_str(_turno(empate, "ocarra_1", GeneradorAzar.new(1)).incidente["objetivo"]).is_equal("ocarra_2")

	var menos_vida: Plantel = _plantel(ubicar)
	_baja(menos_vida, "ocarra_1")
	menos_vida.criatura("zancajunco_1").vida = 7
	var turno: Turno = _turno(menos_vida, "ocarra_1", GeneradorAzar.new(1))
	assert_str(turno.incidente["objetivo"]).is_equal("zancajunco_1")
	assert_array(turno.incidente["rivales"]).is_equal(["ocarra_2", "zancajunco_1"])
	assert_int(menos_vida.criatura("ocarra_2").vida).is_equal(12)


# (8) Sistema.md 10.4 v1.6, la rival en diagonal: con la unica rival en diagonal
# no la alcanza (el ataque es ortogonal; la Alabarda pega en linea): se distrae.
func test_baja_sin_rival_al_alcance_se_distrae() -> void:
	var plantel: Plantel = _plantel({"ocarra_1": Vector2i(3, 3), "zancajunco_1": Vector2i(4, 4)})
	_baja(plantel, "ocarra_1")
	var turno: Turno = _turno(plantel, "ocarra_1", GeneradorAzar.new(1))
	assert_str(turno.incidente["resultado"]).is_equal(Turno.RESULTADO_DISTRAIDA)
	assert_that(turno.incidente["objetivo"]).is_null()
	assert_int(plantel.criatura("zancajunco_1").vida).is_equal(12)
	assert_str(_motivo(turno, Accion.atacar("ocarra_s1"))).is_equal("ACCION_USADA")


# (9) Sistema.md 10.4 y 1.3: con 0 % no se tira: sin evento y el generador no
# avanza (el siguiente numero es el mismo que el de un gemelo).
func test_base_0_no_tira() -> void:
	var plantel: Plantel = _plantel({"ocarra_1": Vector2i(3, 3), "zancajunco_1": Vector2i(3, 2)})
	var azar: GeneradorAzar = GeneradorAzar.new(7)
	var gemelo: GeneradorAzar = GeneradorAzar.new(7)
	var turno: Turno = _turno(plantel, "ocarra_1", azar, _BASE_0)
	assert_dict(turno.incidente).is_empty()
	assert_int(azar.historial().size()).is_equal(0)
	assert_int(azar.entero(1, 100)).is_equal(gemelo.entero(1, 100))


# (10) Sistema.md 1.3, tabla derivada: base 20 con la balanza 2 (Arrimo 3) da 5 %,
# con la 5 da 20 % y con la 1 (Arrimo 4) da 0 %, con piso 0 y sin tirada.
func test_arrimo_y_piso_0() -> void:
	var incidente: Incidente = DatosFixture.incidente(_BASE_20)
	var plantel: Plantel = _plantel({"ocarra_1": Vector2i(3, 3), "zancajunco_1": Vector2i(3, 2)})
	var casilla: Vector2i = Vector2i(3, 3)
	plantel.maestro.balanza = 2
	assert_int(incidente.consulta("ocarra_1", casilla, plantel)["porcentaje"]).is_equal(5)
	plantel.maestro.balanza = 5
	assert_int(incidente.consulta("ocarra_1", casilla, plantel)["porcentaje"]).is_equal(20)
	plantel.maestro.balanza = 1
	assert_int(incidente.consulta("ocarra_1", casilla, plantel)["porcentaje"]).is_equal(0)
	var azar: GeneradorAzar = GeneradorAzar.new(1)
	assert_dict(incidente.tirar("ocarra_1", plantel, azar)).is_empty()
	assert_int(azar.historial().size()).is_equal(0)
	# Con base 0 y la balanza 2 el ajuste da -15: el piso es 0.
	plantel.maestro.balanza = 2
	assert_int(DatosFixture.incidente(_BASE_0).consulta("ocarra_1", casilla, plantel)["porcentaje"]).is_equal(0)


# (11) S-31 (P-033): el turno que vuelve despues de Secundar no tira de nuevo.
# Base 20 con la balanza 5: una semilla cuya primera tirada no sale.
func test_turno_que_vuelve_no_tira() -> void:
	var semilla: int = 1
	while GeneradorAzar.new(semilla).entero(1, 100) <= 20:
		semilla += 1
	var plantel: Plantel = _plantel({"zancajunco_1": Vector2i(3, 3), "ocarra_1": Vector2i(3, 2)})
	var cola: ColaIniciativa = ColaIniciativa.new()
	cola.empezar_ronda(plantel)
	var azar: GeneradorAzar = GeneradorAzar.new(semilla)
	var entrada: EntradaCola = cola.siguiente(plantel)
	assert_str(entrada.unidad_id).is_equal("zancajunco_1")
	var turno: Turno = Turno.empezar(entrada, plantel, _tablero, Surcos.new(), DatosFixture.cadena(), cola,
			DatosFixture.reglas({"incidente": DatosFixture.incidente(_BASE_20),
				"chequeo_rival": DatosFixture.chequeo_rival(_SIN_RIVAL)}), azar)
	assert_int(azar.historial().size()).is_equal(1)
	assert_dict(turno.incidente).is_empty()
	assert_bool(turno.aplicar(Accion.secundar("ocarra_1")).valida).is_true()
	# Juega la Ocarra (tira su propio incidente) y vuelve el Zancajunco.
	var ocarra: Turno = Turno.empezar(cola.siguiente(plantel), plantel, _tablero, Surcos.new(),
			DatosFixture.cadena(), cola, DatosFixture.reglas({"incidente": DatosFixture.incidente(_BASE_20),
				"chequeo_rival": DatosFixture.chequeo_rival(_SIN_RIVAL)}), azar)
	assert_str(ocarra.unidad_id).is_equal("ocarra_1")
	ocarra.aplicar(Accion.terminar())
	var tiradas: int = azar.historial().size()
	var vuelta: EntradaCola = cola.siguiente(plantel)
	assert_str(vuelta.unidad_id).is_equal("zancajunco_1")
	assert_bool(vuelta.vuelve).is_true()
	var de_vuelta: Turno = Turno.empezar(vuelta, plantel, _tablero, Surcos.new(), DatosFixture.cadena(), cola,
			DatosFixture.reglas({"incidente": DatosFixture.incidente(_BASE_100),
				"chequeo_rival": DatosFixture.chequeo_rival(_SIN_RIVAL)}), azar)
	assert_int(azar.historial().size()).is_equal(tiradas)
	assert_dict(de_vuelta.incidente).is_empty()
	assert_bool(de_vuelta.validar(Accion.atacar("ocarra_s1")).motivo == ResultadoAccion.Motivo.ACCION_USADA).is_false()


# (12) S-33 (P-035) y Sistema.md 10.2: el golpe del incidente corta la cadena en
# curso con otro_objetivo y no empieza otra; el siguiente golpe de la tribu a la
# enemiga es el eslabon 1.
func test_golpe_corta_la_cadena_sin_empezar_otra() -> void:
	var combate: Combate = _combate()
	assert_str(combate.turno_actual().unidad_id).is_equal("zancajunco_1")
	assert_that(_aplicar(combate, Accion.atacar("surcon_s1")).eslabon).is_equal(1)
	assert_dict(combate.instantanea()["cadena"]).contains_keys(["objetivo"])
	_aplicar(combate, Accion.terminar())
	# ocarra_1 (baja) golpea a ocarra_2 al empezar su turno.
	assert_str(combate.turno_actual().unidad_id).is_equal("ocarra_1")
	assert_that(combate.instantanea()["cadena"]).is_null()
	var cortes: Array[Dictionary] = _eventos(combate, "cadena_cortada")
	assert_int(cortes.size()).is_equal(1)
	assert_str(cortes[0]["motivo"]).is_equal(Cadena.MOTIVO_OTRO_OBJETIVO)
	assert_array(cortes[0]["participantes"]).is_equal(["zancajunco_1"])
	var ataques: Array[Dictionary] = _eventos(combate, "ataque")
	assert_str(ataques.back()["objetivo"]).is_equal("ocarra_2")
	assert_that(ataques.back()["eslabon"]).is_null()
	_aplicar(combate, Accion.terminar())
	# ocarra_2 (leal) se distrae; despues rodauva_1 le pega a surcon_s1: eslabon 1.
	assert_str(combate.turno_actual().unidad_id).is_equal("ocarra_2")
	assert_str(combate.turno_actual().incidente["resultado"]).is_equal(Turno.RESULTADO_DISTRAIDA)
	_aplicar(combate, Accion.terminar())
	assert_str(combate.turno_actual().unidad_id).is_equal("rodauva_1")
	assert_that(_aplicar(combate, Accion.atacar("surcon_s1")).eslabon).is_equal(1)


# (13) Sistema.md 10.4: Combate.incidente_en da las rivales y el % que despues
# tira el turno, y no cambia la instantanea.
func test_incidente_en_coincide_con_la_tirada() -> void:
	var combate: Combate = _combate()
	var antes: Dictionary = combate.instantanea()
	var consulta: Dictionary = combate.incidente_en("ocarra_1", Vector2i(5, 5))
	assert_dict(consulta).is_equal({"rivales": ["ocarra_2"], "porcentaje": 100})
	assert_dict(combate.instantanea()).is_equal(antes)
	# Sin rivales vecinas desde otra casilla: 0.
	assert_dict(combate.incidente_en("ocarra_1", Vector2i(1, 1))).is_equal({"rivales": [], "porcentaje": 0})
	_aplicar(combate, Accion.terminar())
	var evento: Dictionary = _eventos(combate, "incidente")[0]
	assert_str(evento["unidad"]).is_equal("ocarra_1")
	assert_array(evento["rivales"]).is_equal(consulta["rivales"])
	assert_int(evento["porcentaje"]).is_equal(consulta["porcentaje"])


# (14) Arquitectura.md A.7: turno → tirada → incidente → ataque, sin floats, y la
# grabacion se reproduce con el mismo registro byte por byte.
func test_registro_y_grabacion() -> void:
	var combate: Combate = _combate()
	_aplicar(combate, Accion.terminar())
	_aplicar(combate, Accion.terminar())
	_aplicar(combate, Accion.terminar())
	var lineas: Array[Dictionary] = combate.registro().lineas()
	var tipos: Array[String] = []
	for linea in lineas:
		tipos.append(linea["tipo"])
	var turno_ocarra: int = -1
	for indice in lineas.size():
		if lineas[indice]["tipo"] == "turno" and lineas[indice]["unidad"] == "ocarra_1":
			turno_ocarra = indice
	assert_int(turno_ocarra).is_greater_equal(0)
	assert_array(tipos.slice(turno_ocarra, turno_ocarra + 4)).is_equal(["turno", "tirada", "incidente", "ataque"])
	assert_dict(lineas[turno_ocarra + 2]).contains_key_value("resultado", "golpe")
	assert_dict(lineas[turno_ocarra + 2]).contains_key_value("objetivo", "ocarra_2")
	assert_dict(lineas[turno_ocarra + 3]).contains_key_value("atacante", "ocarra_1")
	# La distraida: objetivo null.
	var incidentes: Array[Dictionary] = _eventos(combate, "incidente")
	assert_int(incidentes.size()).is_equal(2)
	assert_str(incidentes[1]["unidad"]).is_equal("ocarra_2")
	assert_str(incidentes[1]["resultado"]).is_equal("distraida")
	assert_that(incidentes[1]["objetivo"]).is_null()
	assert_str(combate.error()).is_empty()

	var grabacion: Grabacion = Grabacion.desde_combate(combate)
	var reproduccion: Reproductor = Reproductor.reproducir(Grabacion.desde_diccionario(grabacion.a_diccionario()),
			DatosFixture.cargar(_BASE_100)["datos"])
	assert_str(reproduccion.error).is_empty()
	assert_array(reproduccion.combate.registro().lineas_json()).is_equal(combate.registro().lineas_json())


# (15) Sistema.md 10.4, Precisiones: con tres rivales vecinas, una sola tirada.
func test_tres_rivales_una_tirada() -> void:
	var plantel: Plantel = _plantel({"ocarra_1": Vector2i(3, 3), "ocarra_2": Vector2i(4, 3),
			"ocarra_3": Vector2i(2, 2), "zancajunco_1": Vector2i(3, 4)})
	var azar: GeneradorAzar = GeneradorAzar.new(1)
	var turno: Turno = _turno(plantel, "ocarra_1", azar)
	assert_int(azar.historial().size()).is_equal(1)
	assert_array(turno.incidente["rivales"]).is_equal(["ocarra_2", "ocarra_3", "zancajunco_1"])


# (16) S-32 (P-034) y Sistema.md 11.2.2: la Zancajunco oculta provoca la tirada,
# pero el golpe no puede ir a ella: si es la unica rival, la baja se distrae.
func test_oculta_provoca_pero_no_se_golpea() -> void:
	var plantel: Plantel = _plantel({"ocarra_1": Vector2i(3, 3), "zancajunco_1": Vector2i(3, 2)})
	_baja(plantel, "ocarra_1")
	plantel.criatura("zancajunco_1").oculta = true
	var turno: Turno = _turno(plantel, "ocarra_1", GeneradorAzar.new(1))
	assert_str(turno.incidente["resultado"]).is_equal(Turno.RESULTADO_DISTRAIDA)
	assert_int(plantel.criatura("zancajunco_1").vida).is_equal(12)
	assert_bool(plantel.criatura("zancajunco_1").oculta).is_true()


# (17) Sistema.md 11.2.2, Pierde el bono: el golpe de un incidente a una
# Zancajunco destapada con bono se lo quita.
func test_golpe_quita_el_bono() -> void:
	var plantel: Plantel = _plantel({"ocarra_1": Vector2i(3, 3), "zancajunco_1": Vector2i(3, 2)})
	_baja(plantel, "ocarra_1")
	plantel.criatura("zancajunco_1").bono_junco = true
	var turno: Turno = _turno(plantel, "ocarra_1", GeneradorAzar.new(1))
	assert_str(turno.incidente["resultado"]).is_equal(Turno.RESULTADO_GOLPE)
	assert_bool(plantel.criatura("zancajunco_1").bono_junco).is_false()
	var tipos: Array = []
	for evento in turno.eventos():
		tipos.append(evento["tipo"])
	assert_array(tipos).contains(["bono_perdido"])


# Reescrito en T20 (Sistema.md 10.4 y 10.7 v1.6): las salvajes ya tiran (lo
# prueba test_rival_salvajes.gd). Aca queda: una salvaje sin rival aliada
# vecina (Ocarra-Rodauva no es "mal") no tira, y el Maestro no tiene rivales.
func test_salvajes_y_maestro_no_tiran() -> void:
	var plantel: Plantel = _plantel({"ocarra_s1": Vector2i(3, 3), Maestro.ID: Vector2i(5, 5)})
	plantel.criatura("rodauva_s1").posicion = Vector2i(3, 4)
	var azar: GeneradorAzar = GeneradorAzar.new(1)
	assert_dict(_turno(plantel, "ocarra_s1", azar).incidente).is_empty()
	assert_dict(_turno(plantel, Maestro.ID, azar).incidente).is_empty()
	assert_int(azar.historial().size()).is_equal(0)
