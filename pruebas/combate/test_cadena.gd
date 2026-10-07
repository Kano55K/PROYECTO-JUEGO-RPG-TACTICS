extends GdUnitTestSuite

# Arquitectura.md B.3 (T16): cadenas y combos, con fixtures (A.6). Sistema.md
# 10.2, 10.7, 1.3, 11.4 y 11.6, y las lecturas declaradas S-27 y S-28 (10.5).
# Los numeros de danio y de bono son la comprobacion: el codigo los lee de
# combate.json (+20 / +40, divisor 2), arrimo.json (+10 por paso) y la balanza
# de prueba. Los turnos sueltos comparten una Cadena, como en el Combate; las
# unidades que pegan van a una casilla vecina de la objetivo y vuelven a la suya
# (escenario_cadena.json), asi no hay afinidad salvo donde el test la pone.
const _CARPETA: String = "res://pruebas/fixtures/combate/"
const _CARPETA_UNIDADES: String = "res://pruebas/fixtures/unidades/"
const _ESPECIES: Array[String] = ["ocarra", "rodauva", "surcon", "tasajero", "zancajunco"]
const _FUENTES: Array[String] = ["res://nucleo/combate/cadena.gd", "res://nucleo/combate/combo.gd"]
const _AZAR_PROHIBIDO: Array[String] = ["GeneradorAzar", "randi", "randf", "RandomNumberGenerator"]
# La casilla de la objetivo y la vecina desde la que pega cada una.
const _OBJETIVO: Vector2i = Vector2i(3, 3)
const _DESDE: Vector2i = Vector2i(3, 4)

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


# El plantel de escenario_cadena.json con las posiciones de `ubicar`.
func _plantel(ubicar: Dictionary = {}) -> Plantel:
	var especies: Dictionary = {}
	for id_especie in _ESPECIES:
		especies[id_especie] = Especie.new(_leer(_CARPETA_UNIDADES + id_especie + ".json", "especie"))
	var tabla: TablaBalanza = TablaBalanza.new(_leer(_CARPETA_UNIDADES + "balanza_1_2.json", "balanza"))
	var plantel: Plantel = Plantel.desde_escenario(_leer(_CARPETA + "escenario_cadena.json", "escenario"),
			especies, tabla, _leer(_CARPETA_UNIDADES + "maestro.json", "maestro"))
	for id_unidad in ubicar.keys():
		_poner(plantel, id_unidad, ubicar[id_unidad])
	return plantel


func _poner(plantel: Plantel, unidad_id: String, casilla: Vector2i) -> void:
	if unidad_id == Maestro.ID:
		plantel.maestro.posicion = casilla
	else:
		plantel.criatura(unidad_id).posicion = casilla


func _posicion(plantel: Plantel, unidad_id: String) -> Vector2i:
	return plantel.maestro.posicion if unidad_id == Maestro.ID else plantel.criatura(unidad_id).posicion


func _turno(plantel: Plantel, unidad_id: String, cadena: Cadena) -> Turno:
	return Turno.empezar(EntradaCola.new(unidad_id, "", 0), plantel, _tablero, _danio, Surcos.new(),
			DatosFixture.afinidad(), cadena)


# La atacante va a `desde`, valida y aplica el ataque (lo mismo en los dos) y
# vuelve a su casilla. Devuelve el resultado aplicado.
func _golpe(plantel: Plantel, cadena: Cadena, atacante_id: String, objetivo_id: String,
		desde: Vector2i = _DESDE) -> ResultadoAccion:
	var casilla: Vector2i = _posicion(plantel, atacante_id)
	_poner(plantel, atacante_id, desde)
	var turno: Turno = _turno(plantel, atacante_id, cadena)
	var validado: ResultadoAccion = turno.validar(Accion.atacar(objetivo_id))
	var aplicado: ResultadoAccion = turno.aplicar(Accion.atacar(objetivo_id))
	assert_bool(aplicado.valida).override_failure_message(
			"%s -> %s: %s" % [atacante_id, objetivo_id, ResultadoAccion.Motivo.keys()[aplicado.motivo]]).is_true()
	assert_int(aplicado.danio).is_equal(validado.danio)
	assert_that(aplicado.eslabon).is_equal(validado.eslabon)
	if _posicion(plantel, atacante_id) == desde:
		_poner(plantel, atacante_id, casilla)
	return aplicado


# El valor del aporte de combo del desglose, o null si no tiene.
func _combo(resultado: ResultadoAccion) -> Variant:
	for modificador in resultado.desglose.modificadores:
		if modificador.fuente == ModificadorDanio.Fuente.COMBO:
			assert_int(modificador.tipo).is_equal(ModificadorDanio.Tipo.PORCENTAJE)
			return modificador.valor
	return null


func _fuentes(resultado: ResultadoAccion) -> Array:
	var fuentes: Array = []
	for modificador in resultado.desglose.modificadores:
		fuentes.append(modificador.fuente)
	return fuentes


# (1) Sistema.md 11.6, Prueba A, y 10.2: la Rodauva neutral (lealtad 5, umbral 7)
# pega a la Ocarra y despues el Maestro, sin ninguna afin al lado: sin relacion
# +20 y 3 pasos de Arrimo +30 = +50, y 4 x 1,5 = 6.
func test_prueba_a() -> void:
	var plantel: Plantel = _plantel({"ocarra_s1": _OBJETIVO})
	var cadena: Cadena = DatosFixture.cadena()
	var rodauva: ResultadoAccion = _golpe(plantel, cadena, "rodauva_2", "ocarra_s1")
	assert_that(_combo(rodauva)).is_null()
	assert_that(rodauva.eslabon).is_equal(1)

	var maestro: ResultadoAccion = _golpe(plantel, cadena, Maestro.ID, "ocarra_s1")
	assert_that(_combo(maestro)).is_equal(50)
	assert_that(maestro.eslabon).is_equal(2)
	assert_array(_fuentes(maestro)).not_contains([ModificadorDanio.Fuente.AFINIDAD])
	assert_int(maestro.danio).is_equal(6)
	assert_int(plantel.criatura("ocarra_s1").vida).is_equal(12 - 2 - 6)


# (2) Sistema.md 10.2 y 11.4: la Rodauva leal (lealtad 8) y despues el Maestro son
# afines: +40 + 30 = +70, y 4 x 1,7 = 6. Con la leal adyacente a la casilla desde
# la que pega el Maestro, suma la afinidad (10.3): 6 + 1 = 7.
func test_afines_y_ejemplo_11_4() -> void:
	var plantel: Plantel = _plantel({"ocarra_s1": _OBJETIVO})
	var cadena: Cadena = DatosFixture.cadena()
	_golpe(plantel, cadena, "rodauva_1", "ocarra_s1")

	_poner(plantel, Maestro.ID, _DESDE)
	var turno: Turno = _turno(plantel, Maestro.ID, cadena)
	var sola: ResultadoAccion = turno.validar(Accion.atacar("ocarra_s1"))
	assert_that(_combo(sola)).is_equal(70)
	assert_int(sola.danio).is_equal(6)

	_poner(plantel, "rodauva_1", Vector2i(3, 5))
	var con_afin: ResultadoAccion = turno.validar(Accion.atacar("ocarra_s1"))
	assert_that(_combo(con_afin)).is_equal(70)
	assert_array(_fuentes(con_afin)).contains([ModificadorDanio.Fuente.AFINIDAD])
	assert_int(con_afin.danio).is_equal(7)
	assert_int(turno.aplicar(Accion.atacar("ocarra_s1")).danio).is_equal(7)


# (3) Sistema.md 10.2: cada eslabon vale la mitad que el anterior, con piso y sin
# tope. Seis golpes seguidos, cada uno afin con el anterior (Rodauva-Rodauva,
# Rodauva-Surcon, Surcon-Ocarra, 10.8; la Ocarra leal y el Maestro): +70 / +35 /
# +17 / +8 (la tabla de 10.2) y el quinto bono, 70 / 16 = +4.
func test_eslabones_sin_tope() -> void:
	var plantel: Plantel = _plantel({"tasajero_s1": _OBJETIVO})
	var cadena: Cadena = DatosFixture.cadena()
	var atacantes: Array[String] = ["rodauva_2", "rodauva_3", "rodauva_1", "surcon_1", "ocarra_1", Maestro.ID]
	var bonos: Array = []
	var eslabones: Array = []
	for atacante in atacantes:
		var golpe: ResultadoAccion = _golpe(plantel, cadena, atacante, "tasajero_s1")
		bonos.append(_combo(golpe))
		eslabones.append(golpe.eslabon)
	assert_array(bonos).is_equal([null, 70, 35, 17, 8, 4])
	assert_array(eslabones).is_equal([1, 2, 3, 4, 5, 6])
	assert_dict(cadena.instantanea()).is_equal({"objetivo": "tasajero_s1", "eslabon": 6,
			"ultimo_atacante": Maestro.ID, "participantes": atacantes})


# (4) Sistema.md 1.3, tabla derivada: el Arrimo suma +10 por paso al bono del par.
# Balanza 5 (0 pasos): +20 sin relacion y +40 entre afines; balanza 1 (4 pasos):
# +60 y +80. Rodauva-Zancajunco no tienen relacion; Rodauva-Rodauva son afines.
func test_arrimo_por_balanza() -> void:
	var plantel: Plantel = _plantel()
	var combo: Combo = DatosFixture.combo()
	assert_int(combo.bono_par("rodauva_2", "zancajunco_1", plantel)).is_equal(50)
	assert_int(combo.bono_par("rodauva_2", "rodauva_3", plantel)).is_equal(70)
	plantel.maestro.balanza = 5
	assert_int(combo.bono_par("rodauva_2", "zancajunco_1", plantel)).is_equal(20)
	assert_int(combo.bono_par("rodauva_2", "rodauva_3", plantel)).is_equal(40)
	plantel.maestro.balanza = 1
	assert_int(combo.bono_par("rodauva_2", "zancajunco_1", plantel)).is_equal(60)
	assert_int(combo.bono_par("rodauva_2", "rodauva_3", plantel)).is_equal(80)

	# El mismo bono llega al ataque por la cadena (balanza 1, afines: +80).
	_poner(plantel, "ocarra_s1", _OBJETIVO)
	var cadena: Cadena = DatosFixture.cadena()
	_golpe(plantel, cadena, "rodauva_2", "ocarra_s1")
	assert_that(_combo(_golpe(plantel, cadena, "rodauva_3", "ocarra_s1"))).is_equal(80)


# (5) S-27 (lectura declarada): cada eslabon usa la base de su par, dividida por
# 2 tantas veces como eslabones pasaron desde el segundo. Rodauva -> Surcon
# (afines, eslabon 2): +70; Surcon -> Zancajunco (sin relacion, eslabon 3): 50 / 2 = +25.
func test_s27_pares_mixtos() -> void:
	var plantel: Plantel = _plantel({"tasajero_s1": _OBJETIVO})
	var cadena: Cadena = DatosFixture.cadena()
	assert_that(_combo(_golpe(plantel, cadena, "rodauva_1", "tasajero_s1"))).is_null()
	assert_that(_combo(_golpe(plantel, cadena, "surcon_1", "tasajero_s1"))).is_equal(70)
	assert_that(_combo(_golpe(plantel, cadena, "zancajunco_1", "tasajero_s1"))).is_equal(25)


# (6c) Sistema.md 10.2: una de la tribu que ataca a otra objetivo corta la cadena
# (otro_objetivo) y empieza una nueva en el eslabon 1, sin bono.
func test_otro_objetivo_empieza_en_1() -> void:
	var plantel: Plantel = _plantel({"ocarra_s1": _OBJETIVO, "rodauva_s1": Vector2i(5, 5)})
	var cadena: Cadena = DatosFixture.cadena()
	_golpe(plantel, cadena, "rodauva_2", "ocarra_s1")
	_golpe(plantel, cadena, "rodauva_3", "ocarra_s1")
	var otro: ResultadoAccion = _golpe(plantel, cadena, Maestro.ID, "rodauva_s1", Vector2i(5, 4))
	assert_that(otro.eslabon).is_equal(1)
	assert_that(_combo(otro)).is_null()
	assert_array(cadena.historial()).is_equal([{"tipo": "cadena_cortada", "objetivo": "ocarra_s1", "eslabones": 2,
			"participantes": ["rodauva_2", "rodauva_3"], "motivo": Cadena.MOTIVO_OTRO_OBJETIVO}])
	assert_dict(cadena.instantanea()).is_equal({"objetivo": "rodauva_s1", "eslabon": 1,
			"ultimo_atacante": Maestro.ID, "participantes": [Maestro.ID]})


# (6d) Sistema.md 10.2 y 11.5: la objetivo que sale del tablero (la salvaje en 0
# huye) corta la cadena con objetivo_fuera, en el golpe que la saca, que si
# cuenta como eslabon.
func test_objetivo_que_sale_del_tablero() -> void:
	var plantel: Plantel = _plantel({"ocarra_s1": _OBJETIVO})
	plantel.criatura("ocarra_s1").vida = 5
	var cadena: Cadena = DatosFixture.cadena()
	_golpe(plantel, cadena, "rodauva_2", "ocarra_s1")
	var ultimo: ResultadoAccion = _golpe(plantel, cadena, Maestro.ID, "ocarra_s1")
	assert_that(ultimo.eslabon).is_equal(2)
	assert_int(plantel.criatura("ocarra_s1").estado).is_equal(Criatura.Estado.FUERA)
	assert_bool(cadena.activa()).is_false()
	assert_that(cadena.instantanea()).is_null()
	assert_array(cadena.historial()).is_equal([{"tipo": "cadena_cortada", "objetivo": "ocarra_s1", "eslabones": 2,
			"participantes": ["rodauva_2", Maestro.ID], "motivo": Cadena.MOTIVO_OBJETIVO_FUERA}])


# (7) Sistema.md 10.2, "no la corta": entre dos golpes, otras de la tribu se
# erizan, se hacen junco, cavan, se mueven y esperan. El segundo golpe es el
# eslabon 2, con el par del primer atacante y el segundo (Rodauva neutral y
# Ocarra leal, sin relacion: +50).
func test_no_cortan_las_acciones_que_no_son_ataque() -> void:
	var plantel: Plantel = _plantel({"ocarra_s1": _OBJETIVO})
	var cadena: Cadena = DatosFixture.cadena()
	_golpe(plantel, cadena, "rodauva_2", "ocarra_s1")
	var antes: Variant = cadena.instantanea()
	var acciones: Array = [
		["rodauva_1", [Accion.erizarse(), Accion.terminar()]],
		["zancajunco_1", [Accion.hacerse_junco(), Accion.terminar()]],
		["surcon_1", [Accion.cavar(Vector2i(3, 0)), Accion.terminar()]],
		["rodauva_3", [Accion.mover(Vector2i(6, 5)), Accion.terminar()]],
		[Maestro.ID, [Accion.terminar()]],
	]
	for jugada in acciones:
		var turno: Turno = _turno(plantel, jugada[0], cadena)
		for accion in jugada[1]:
			var resultado: ResultadoAccion = turno.aplicar(accion)
			assert_bool(resultado.valida).override_failure_message(
					"%s %s: %s" % [jugada[0], str(accion.a_diccionario()),
					ResultadoAccion.Motivo.keys()[resultado.motivo]]).is_true()
		assert_that(cadena.instantanea()).is_equal(antes)
	var segundo: ResultadoAccion = _golpe(plantel, cadena, "ocarra_1", "ocarra_s1")
	assert_that(segundo.eslabon).is_equal(2)
	assert_that(_combo(segundo)).is_equal(50)
	assert_array(cadena.historial()).is_empty()
	assert_array(cadena.instantanea()["participantes"]).is_equal(["rodauva_2", "ocarra_1"])


# (8) Sistema.md 10.7: las salvajes no encadenan. Dos Rodauvas salvajes seguidas
# sobre la misma objetivo no suman bono, su eslabon es null y no abren cadena.
# Que su turno corta la cadena de la tribu se ve con el Combate en
# test_corta_el_turno_enemigo_aunque_espere y en test_registro_instantanea_y_grabacion.
func test_salvajes_no_encadenan() -> void:
	var plantel: Plantel = _plantel({"rodauva_1": _OBJETIVO})
	var cadena: Cadena = DatosFixture.cadena()
	for atacante in ["rodauva_s1", "rodauva_s2"]:
		var golpe: ResultadoAccion = _golpe(plantel, cadena, atacante, "rodauva_1")
		assert_that(golpe.eslabon).is_null()
		assert_that(_combo(golpe)).is_null()
		assert_int(golpe.danio).is_equal(2)
	assert_bool(cadena.activa()).is_false()
	assert_array(cadena.historial()).is_empty()


# (9) S-28 (lectura declarada): la relacion del par no mira adyacencia ni si la
# anterior sigue de pie, y la obediencia se pregunta en el momento del golpe.
func test_s28_relacion_sin_adyacencia_y_en_el_momento() -> void:
	# Lejos: la leal vuelve a [2,7] y el Maestro pega desde [3,2].
	var lejos: Plantel = _plantel({"tasajero_s1": _OBJETIVO})
	var cadena: Cadena = DatosFixture.cadena()
	_golpe(lejos, cadena, "rodauva_1", "tasajero_s1")
	assert_int(Tablero.distancia(Vector2i(3, 2), lejos.criatura("rodauva_1").posicion)).is_greater(1)
	assert_that(_combo(_golpe(lejos, cadena, Maestro.ID, "tasajero_s1", Vector2i(3, 2)))).is_equal(70)

	# La anterior cae despues de pegar: siguen siendo afines para el combo.
	var caida: Plantel = _plantel({"tasajero_s1": _OBJETIVO})
	cadena = DatosFixture.cadena()
	_golpe(caida, cadena, "rodauva_1", "tasajero_s1")
	var rodauva: Criatura = caida.criatura("rodauva_1")
	rodauva.vida = 0
	VidaCero.resolver("rodauva_1", caida, Surcos.new())
	assert_int(rodauva.estado).is_equal(Criatura.Estado.CAIDA)
	assert_that(_combo(_golpe(caida, cadena, Maestro.ID, "tasajero_s1"))).is_equal(70)

	# La leal (lealtad 7, hambre 5) pasa a neutral con el hambre de combate de
	# la ronda 5 (Sistema.md 7.2): encadena con el Maestro como sin relacion.
	var hambre: Plantel = _plantel({"tasajero_s1": _OBJETIVO})
	var leal: Criatura = hambre.criatura("rodauva_1")
	leal.lealtad = 7
	leal.hambre = 5
	cadena = DatosFixture.cadena()
	_golpe(hambre, cadena, "rodauva_1", "tasajero_s1")
	_poner(hambre, Maestro.ID, _DESDE)
	var turno: Turno = _turno(hambre, Maestro.ID, cadena)
	assert_that(_combo(turno.validar(Accion.atacar("tasajero_s1")))).is_equal(70)
	var hambre_combate: HambreCombate = HambreCombate.desde_datos(_leer(_CARPETA + "hambre.json", "hambre"))
	assert_object(hambre_combate.cerrar_ronda(5, hambre)).is_not_null()
	assert_int(leal.hambre).is_equal(6)
	assert_that(_combo(turno.validar(Accion.atacar("tasajero_s1")))).is_equal(50)


# (10) Sistema.md 10.2 y Arquitectura.md B.3: validar y previsualizar no avanzan
# la cadena, y el bono previsto es el aplicado.
func test_validar_y_previsualizar_no_avanzan() -> void:
	var plantel: Plantel = _plantel({"ocarra_s1": _OBJETIVO})
	var cadena: Cadena = DatosFixture.cadena()
	_golpe(plantel, cadena, "rodauva_2", "ocarra_s1")
	var antes: Variant = cadena.instantanea()

	_poner(plantel, Maestro.ID, Vector2i(3, 5))
	var turno: Turno = _turno(plantel, Maestro.ID, cadena)
	var previsto: ResultadoAccion = turno.previsualizar_ataque(_DESDE, "ocarra_s1")
	assert_bool(previsto.valida).is_true()
	for _i in range(3):
		turno.previsualizar_ataque(_DESDE, "ocarra_s1")
		turno.validar(Accion.atacar("ocarra_s1"))
	assert_that(cadena.instantanea()).is_equal(antes)
	assert_array(cadena.historial()).is_empty()
	assert_that(previsto.eslabon).is_equal(2)
	assert_that(_combo(previsto)).is_equal(50)

	assert_bool(turno.aplicar(Accion.mover(_DESDE)).valida).is_true()
	var validado: ResultadoAccion = turno.validar(Accion.atacar("ocarra_s1"))
	assert_that(cadena.instantanea()).is_equal(antes)
	var aplicado: ResultadoAccion = turno.aplicar(Accion.atacar("ocarra_s1"))
	assert_dict(aplicado.desglose.a_diccionario()).is_equal(previsto.desglose.a_diccionario())
	assert_dict(aplicado.desglose.a_diccionario()).is_equal(validado.desglose.a_diccionario())
	assert_that(aplicado.eslabon).is_equal(previsto.eslabon)
	assert_int(cadena.instantanea()["eslabon"]).is_equal(2)


# --- Con el Combate (escenario_cadena_combate.json) ---

func _datos() -> Dictionary:
	var lectura: Dictionary = DatosFixture.cargar()
	var errores: Array[Dictionary] = lectura["errores"]
	assert_array(errores).override_failure_message(str(errores)).is_empty()
	return lectura["datos"]


func _escenario() -> Dictionary:
	return _leer(_CARPETA + "escenario_cadena_combate.json", "escenario")


func _combate(escenario: Dictionary) -> Combate:
	var contexto: ContextoCombate = ContextoCombate.armar(escenario, _datos())
	assert_bool(contexto.valido).is_true()
	var combate: Combate = Combate.empezar(contexto)
	assert_str(combate.error()).is_empty()
	return combate


func _aplicar_valida(combate: Combate, accion: Accion) -> void:
	var resultado: ResultadoAccion = combate.aplicar(accion)
	assert_bool(resultado.valida).override_failure_message("%s %s: %s" % [combate.turno_actual().unidad_id,
			str(accion.a_diccionario()), ResultadoAccion.Motivo.keys()[resultado.motivo]]).is_true()
	assert_str(combate.error()).is_empty()


# La unidad del turno ataca a la objetivo y termina.
func _atacar_y_terminar(combate: Combate, unidad_id: String, objetivo_id: String) -> void:
	assert_str(combate.turno_actual().unidad_id).is_equal(unidad_id)
	_aplicar_valida(combate, Accion.atacar(objetivo_id))
	if not combate.terminado():
		_aplicar_valida(combate, Accion.terminar())


func _de_tipo(combate: Combate, tipo: String) -> Array[Dictionary]:
	var resultado: Array[Dictionary] = []
	for linea in combate.registro().lineas():
		if linea["tipo"] == tipo:
			resultado.append(linea)
	return resultado


# La ronda 1 del escenario: la tribu pega toda a surcon_s1; rodauva_s1 y surcon_s1
# juegan solas.
func _jugar_ronda_1(combate: Combate) -> void:
	_atacar_y_terminar(combate, "zancajunco_1", "surcon_s1")
	_atacar_y_terminar(combate, "ocarra_1", "surcon_s1")
	_atacar_y_terminar(combate, Maestro.ID, "surcon_s1")
	_atacar_y_terminar(combate, "surcon_1", "surcon_s1")


# (6a) Sistema.md 10.2 y 10.7: el turno de una enemiga corta la cadena aunque
# solo espere. rodauva_s1, encerrada por dos caidas, solo termina; el corte va
# justo detras de su evento `turno`, antes de cualquier accion suya.
func test_corta_el_turno_enemigo_aunque_espere() -> void:
	var combate: Combate = _combate(_escenario())
	_atacar_y_terminar(combate, "zancajunco_1", "surcon_s1")
	_atacar_y_terminar(combate, "ocarra_1", "surcon_s1")
	assert_str(combate.turno_actual().unidad_id).is_equal(Maestro.ID)
	assert_that(combate.instantanea()["cadena"]).is_null()

	var lineas: Array[Dictionary] = combate.registro().lineas()
	var indice: int = -1
	for i in range(lineas.size()):
		if lineas[i]["tipo"] == "turno" and lineas[i]["unidad"] == "rodauva_s1":
			indice = i
	assert_int(indice).is_greater(0)
	assert_dict(lineas[indice + 1]).is_equal({"tipo": "cadena_cortada", "objetivo": "surcon_s1", "eslabones": 2,
			"participantes": ["zancajunco_1", "ocarra_1"], "motivo": Cadena.MOTIVO_ENEMIGA,
			"ronda": 1, "n": indice + 1})
	var acciones: Array = []
	for linea in lineas.slice(indice):
		if linea["tipo"] == "accion" and linea["unidad"] == "rodauva_s1":
			acciones.append(linea["accion"]["tipo"])
	assert_array(acciones).is_equal(["terminar"])


# (6b) Sistema.md 10.2: la cadena nunca pasa a la ronda siguiente. Con la objetivo
# como Ocarra salvaje (Velocidad 7, juega antes que el Maestro), el Maestro y el
# Surcon cierran la ronda encadenados: el corte va justo detras del fin_ronda
# (en la ronda 1 no hay hambre de combate).
func test_corta_al_cerrar_la_ronda() -> void:
	var escenario: Dictionary = _escenario()
	var objetivo: Dictionary = (escenario["enemigas"] as Array)[0]
	objetivo["id"] = "ocarra_s1"
	objetivo["especie"] = "ocarra"
	var combate: Combate = _combate(escenario)
	_aplicar_valida(combate, Accion.terminar())
	_aplicar_valida(combate, Accion.terminar())
	_atacar_y_terminar(combate, Maestro.ID, "ocarra_s1")
	_atacar_y_terminar(combate, "surcon_1", "ocarra_s1")
	assert_int(combate.instantanea()["ronda"] as int).is_equal(2)
	assert_that(combate.instantanea()["cadena"]).is_null()

	var lineas: Array[Dictionary] = combate.registro().lineas()
	var indice: int = -1
	for i in range(lineas.size()):
		if lineas[i]["tipo"] == "fin_ronda":
			indice = i
	assert_dict(lineas[indice + 1]).is_equal({"tipo": "cadena_cortada", "objetivo": "ocarra_s1", "eslabones": 2,
			"participantes": [Maestro.ID, "surcon_1"], "motivo": Cadena.MOTIVO_FIN_RONDA,
			"ronda": 1, "n": indice + 1})
	assert_int(_de_tipo(combate, "cadena_cortada").size()).is_equal(1)


# (11) Arquitectura.md A.7: `eslabon` en cada `ataque` (null en los de la
# enemiga); un solo cadena_cortada por cadena, con su motivo y sus participantes
# en orden; la instantanea trae la cadena; la grabacion se reproduce igual. Al
# ganar con el golpe que saca a la objetivo, el unico corte es objetivo_fuera
# (P-029) y no queda ninguna cadena abierta. fin_combate corta una cadena abierta
# una sola vez.
func test_registro_instantanea_y_grabacion() -> void:
	var combate: Combate = _combate(_escenario())
	assert_that(combate.instantanea()["cadena"]).is_null()
	_atacar_y_terminar(combate, "zancajunco_1", "surcon_s1")
	assert_str(combate.turno_actual().unidad_id).is_equal("ocarra_1")
	_aplicar_valida(combate, Accion.atacar("surcon_s1"))
	assert_dict(combate.instantanea()["cadena"]).is_equal({"objetivo": "surcon_s1", "eslabon": 2,
			"ultimo_atacante": "ocarra_1", "participantes": ["zancajunco_1", "ocarra_1"]})
	_aplicar_valida(combate, Accion.terminar())
	_atacar_y_terminar(combate, Maestro.ID, "surcon_s1")
	_atacar_y_terminar(combate, "surcon_1", "surcon_s1")
	assert_str(combate.error()).is_empty()

	var de_la_tribu: Array = []
	var de_enemigas: Array = []
	for ataque in _de_tipo(combate, "ataque"):
		if ataque["atacante"] == "surcon_s1":
			de_enemigas.append(ataque["eslabon"])
		else:
			de_la_tribu.append([ataque["atacante"], ataque["eslabon"], ataque["vida_antes"] - ataque["vida_despues"]])
	# Zancajunco 4 + 1; Ocarra (rivales, sin relacion: +50) 6; Maestro 4 + 1;
	# Surcon (neutral con el Maestro, sin relacion: +50) 3 x 1,5 = 4. Sistema.md
	# 10.3 v1.6 (T41): el Zancajunco leal [4,5] y el Maestro [5,4] estan en
	# diagonal y se dan afinidad (con vecinas en 4 pegaban 4 cada uno).
	assert_array(de_la_tribu).is_equal([["zancajunco_1", 1, 4 + 1], ["ocarra_1", 2, 6], [Maestro.ID, 1, 4 + 1],
			["surcon_1", 2, 4]])
	assert_array(de_enemigas).is_not_empty()
	for eslabon in de_enemigas:
		assert_that(eslabon).is_null()
	var cortes: Array = []
	for corte in _de_tipo(combate, "cadena_cortada"):
		cortes.append([corte["objetivo"], corte["eslabones"], corte["participantes"], corte["motivo"]])
	assert_array(cortes).is_equal([
		["surcon_s1", 2, ["zancajunco_1", "ocarra_1"], Cadena.MOTIVO_ENEMIGA],
		["surcon_s1", 2, [Maestro.ID, "surcon_1"], Cadena.MOTIVO_ENEMIGA],
	])

	var grabacion: Grabacion = Grabacion.desde_combate(combate)
	var reproduccion: Reproductor = Reproductor.reproducir(Grabacion.desde_diccionario(grabacion.a_diccionario()),
			_datos())
	assert_str(reproduccion.error).is_empty()
	assert_array(reproduccion.combate.registro().lineas_json()).is_equal(combate.registro().lineas_json())

	# Victoria con el golpe que saca a la objetivo de la cadena (sin rodauva_s1,
	# surcon_s1 con 10 de vida: 5 + 6 desde T41, Sistema.md 10.3 v1.6).
	var escenario: Dictionary = _escenario()
	(escenario["enemigas"] as Array).pop_back()
	(escenario["enemigas"] as Array)[0]["vida"] = 10
	var victoria: Combate = _combate(escenario)
	_atacar_y_terminar(victoria, "zancajunco_1", "surcon_s1")
	_atacar_y_terminar(victoria, "ocarra_1", "surcon_s1")
	assert_int(victoria.fin()).is_equal(FinCombate.Fin.VICTORIA)
	assert_that(victoria.instantanea()["cadena"]).is_null()
	var cortes_victoria: Array[Dictionary] = _de_tipo(victoria, "cadena_cortada")
	assert_int(cortes_victoria.size()).is_equal(1)
	assert_str(cortes_victoria[0]["motivo"]).is_equal(Cadena.MOTIVO_OBJETIVO_FUERA)
	assert_array(cortes_victoria[0]["participantes"]).is_equal(["zancajunco_1", "ocarra_1"])
	var tipos: Array = []
	for linea in victoria.registro().lineas():
		tipos.append(linea["tipo"])
	assert_array(tipos.slice(tipos.rfind("ataque"))).is_equal(["ataque", "estado", "cadena_cortada", "fin", "cierre"])

	# fin_combate: el corte de una cadena que sigue abierta al terminar, una sola vez.
	var plantel: Plantel = _plantel()
	var cadena: Cadena = DatosFixture.cadena()
	cadena.atacar("rodauva_2", "ocarra_s1", plantel)
	cadena.cortar(Cadena.MOTIVO_FIN_COMBATE)
	cadena.cortar(Cadena.MOTIVO_FIN_COMBATE)
	assert_array(cadena.historial()).is_equal([{"tipo": "cadena_cortada", "objetivo": "ocarra_s1", "eslabones": 1,
			"participantes": ["rodauva_2"], "motivo": Cadena.MOTIVO_FIN_COMBATE}])
	assert_that(cadena.instantanea()).is_null()


# Arquitectura.md, principio 2: la cadena y el combo no usan azar.
func test_sin_azar() -> void:
	for ruta in _FUENTES:
		var codigo: String = FileAccess.get_file_as_string(ruta)
		for prohibido in _AZAR_PROHIBIDO:
			assert_str(codigo).not_contains(prohibido)
