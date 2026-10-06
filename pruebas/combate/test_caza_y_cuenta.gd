extends GdUnitTestSuite

# Arquitectura.md B.2.1 (T36): turno generalizado y Caza y cuenta, con fixtures
# (A.6). Sistema.md 11.2.3 (Caza y cuenta, S-23), 11.3 (Turno, Velocidad por
# modo), 11.4 (pasos 1 y 3) y 11.8 (paso 2). Los numeros son la comprobacion: el
# codigo los lee de las fichas, la balanza y las tablas de prueba.
const _CARPETA: String = "res://pruebas/fixtures/combate/"
const _CARPETA_UNIDADES: String = "res://pruebas/fixtures/unidades/"
const _ESPECIES: Array[String] = ["ocarra", "rodauva", "surcon", "tasajero", "zancajunco"]
const _TASAJERO: String = "tasajero_s1"

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


# escenario_caza.json: el Tasajero salvaje [3,3] en una esquina concava.
func _plantel() -> Plantel:
	var especies: Dictionary = {}
	for id_especie in _ESPECIES:
		especies[id_especie] = Especie.new(_leer(_CARPETA_UNIDADES + id_especie + ".json", "especie"))
	var tabla: TablaBalanza = TablaBalanza.new(_leer(_CARPETA_UNIDADES + "balanza_1_2.json", "balanza"))
	return Plantel.desde_escenario(_leer(_CARPETA + "escenario_caza.json", "escenario"), especies, tabla,
			_leer(_CARPETA_UNIDADES + "maestro.json", "maestro"))


# Turno suelto, sin cola: la entrada se arma a mano.
func _turno(plantel: Plantel, unidad_id: String) -> Turno:
	return Turno.empezar(EntradaCola.new(unidad_id, "", 0), plantel, _tablero, _danio, Surcos.new())


func _siguiente_turno(cola: ColaIniciativa, plantel: Plantel) -> Turno:
	var entrada: EntradaCola = cola.siguiente(plantel)
	return null if entrada == null else Turno.empezar(entrada, plantel, _tablero, _danio, Surcos.new())


# Todo lo que una accion puede cambiar en el Plantel y en el turno.
func _foto(plantel: Plantel, turno: Turno) -> String:
	return str([plantel.instantanea(), turno.pasos_restantes, turno.ataques_restantes,
			turno.movimiento_usado, turno.accion_usada, turno.terminado])


func _assert_valida(resultado: ResultadoAccion) -> void:
	assert_bool(resultado.valida).override_failure_message("motivo: " + ResultadoAccion.Motivo.keys()[resultado.motivo]).is_true()


func _assert_rechazada(resultado: ResultadoAccion, motivo: ResultadoAccion.Motivo) -> void:
	assert_bool(resultado.valida).is_false()
	assert_str(ResultadoAccion.Motivo.keys()[resultado.motivo]).is_equal(ResultadoAccion.Motivo.keys()[motivo])


func _assert_modificador(modificador: ModificadorDanio, tipo: ModificadorDanio.Tipo, valor: int, detalle: String) -> void:
	assert_str(ModificadorDanio.Fuente.keys()[modificador.fuente]).is_equal("MODO")
	assert_int(modificador.tipo).is_equal(tipo)
	assert_int(modificador.valor).is_equal(valor)
	assert_str(modificador.detalle).is_equal(detalle)


# (1) Caza: dos ataques separados de 5, a una presa o a dos (Sistema.md 11.2.3).
# La Rodauva (8) recibe 5 + 5 y cae en el segundo; erizada recibe 2 + 2. Si la
# primera presa cae, el segundo ataque va a otra presa adyacente (S-23).
func test_caza_dos_ataques() -> void:
	var plantel: Plantel = _plantel()
	var rodauva: Criatura = plantel.criatura("rodauva_1")
	var turno: Turno = _turno(plantel, _TASAJERO)
	assert_int(turno.ataques_restantes).is_equal(2)
	assert_int(turno.aplicar(Accion.atacar("rodauva_1")).danio).is_equal(5)
	assert_int(rodauva.vida).is_equal(8 - 5)
	assert_int(rodauva.estado).is_equal(Criatura.Estado.SUELTA)
	assert_int(turno.aplicar(Accion.atacar("rodauva_1")).danio).is_equal(5)
	assert_int(rodauva.vida).is_equal(0)
	assert_int(rodauva.estado).is_equal(Criatura.Estado.CAIDA)

	plantel = _plantel()
	turno = _turno(plantel, _TASAJERO)
	_assert_valida(turno.aplicar(Accion.atacar("rodauva_1")))
	_assert_valida(turno.aplicar(Accion.atacar("ocarra_1")))
	assert_int(plantel.criatura("rodauva_1").vida).is_equal(8 - 5)
	assert_int(plantel.criatura("ocarra_1").vida).is_equal(12 - 5)

	plantel = _plantel()
	plantel.criatura("rodauva_1").erizada = true
	turno = _turno(plantel, _TASAJERO)
	assert_int(turno.aplicar(Accion.atacar("rodauva_1")).danio).is_equal(2)
	assert_int(turno.aplicar(Accion.atacar("rodauva_1")).danio).is_equal(2)
	assert_int(plantel.criatura("rodauva_1").vida).is_equal(8 - 2 - 2)

	plantel = _plantel()
	plantel.criatura("rodauva_1").vida = 5
	turno = _turno(plantel, _TASAJERO)
	_assert_valida(turno.aplicar(Accion.atacar("rodauva_1")))
	_assert_rechazada(turno.aplicar(Accion.atacar("rodauva_1")), ResultadoAccion.Motivo.OBJETIVO_CAIDO)
	_assert_valida(turno.aplicar(Accion.atacar("ocarra_1")))
	assert_int(plantel.criatura("ocarra_1").vida).is_equal(12 - 5)


# (2) No hay tercer ataque.
func test_caza_no_hay_tercer_ataque() -> void:
	var plantel: Plantel = _plantel()
	var turno: Turno = _turno(plantel, _TASAJERO)
	_assert_valida(turno.aplicar(Accion.atacar("ocarra_1")))
	_assert_valida(turno.aplicar(Accion.atacar("ocarra_1")))
	assert_int(turno.ataques_restantes).is_equal(0)
	_assert_rechazada(turno.aplicar(Accion.atacar("ocarra_1")), ResultadoAccion.Motivo.ACCION_USADA)
	assert_int(plantel.criatura("ocarra_1").vida).is_equal(12 - 5 - 5)
	assert_array(turno.objetivos_para_atacar()).is_empty()


# (3) Caza sin partir: se mueve antes o despues de los dos ataques, nunca entre
# ellos (Sistema.md 11.2.3, S-23).
func test_caza_orden_mover_y_atacar() -> void:
	# mover -> atacar -> atacar
	var plantel: Plantel = _plantel()
	var turno: Turno = _turno(plantel, _TASAJERO)
	_assert_valida(turno.aplicar(Accion.mover(Vector2i(4, 2))))
	_assert_valida(turno.aplicar(Accion.atacar("ocarra_1")))
	_assert_valida(turno.aplicar(Accion.atacar("ocarra_1")))
	assert_int(plantel.criatura("ocarra_1").vida).is_equal(12 - 5 - 5)

	# atacar -> mover se rechaza hasta el segundo ataque
	plantel = _plantel()
	turno = _turno(plantel, _TASAJERO)
	_assert_valida(turno.aplicar(Accion.atacar("ocarra_1")))
	var antes: String = _foto(plantel, turno)
	_assert_rechazada(turno.aplicar(Accion.mover(Vector2i(3, 2))), ResultadoAccion.Motivo.MOVER_ENTRE_ATAQUES)
	assert_str(_foto(plantel, turno)).is_equal(antes)
	assert_array(turno.casillas_para_mover()).is_empty()

	# atacar -> atacar -> mover
	_assert_valida(turno.aplicar(Accion.atacar("rodauva_1")))
	_assert_valida(turno.aplicar(Accion.mover(Vector2i(3, 2))))
	assert_that(plantel.criatura(_TASAJERO).posicion).is_equal(Vector2i(3, 2))
	_assert_rechazada(turno.aplicar(Accion.mover(Vector2i(3, 1))), ResultadoAccion.Motivo.MOVIMIENTO_USADO)


# (4) Cuenta: movimiento partido con 4 pasos en total, antes y despues de atacar;
# un ataque de 5 - 1 = 4 (Sistema.md 11.2.3, 11.4 paso 3).
func test_cuenta_movimiento_partido() -> void:
	var plantel: Plantel = _plantel()
	plantel.criatura(_TASAJERO).modo = "cuenta"
	var turno: Turno = _turno(plantel, _TASAJERO)
	assert_int(turno.ataques_restantes).is_equal(1)
	assert_int(turno.pasos_restantes).is_equal(4)

	_assert_valida(turno.aplicar(Accion.mover(Vector2i(4, 2))))
	assert_int(turno.pasos_restantes).is_equal(2)
	var ataque: ResultadoAccion = turno.aplicar(Accion.atacar("ocarra_1"))
	_assert_valida(ataque)
	assert_int(ataque.danio).is_equal(4)
	assert_int(plantel.criatura("ocarra_1").vida).is_equal(12 - 4)
	assert_int(ataque.desglose.modificadores.size()).is_equal(1)
	_assert_modificador(ataque.desglose.modificadores[0], ModificadorDanio.Tipo.PLANO, -1, "cuenta")

	# Tres pasos no le alcanzan; dos si.
	_assert_rechazada(turno.aplicar(Accion.mover(Vector2i(7, 2))), ResultadoAccion.Motivo.CASILLA_NO_ALCANZABLE)
	_assert_valida(turno.aplicar(Accion.mover(Vector2i(4, 0))))
	assert_int(turno.pasos_restantes).is_equal(0)
	_assert_rechazada(turno.aplicar(Accion.mover(Vector2i(3, 0))), ResultadoAccion.Motivo.MOVIMIENTO_USADO)
	assert_that(plantel.criatura(_TASAJERO).posicion).is_equal(Vector2i(4, 0))


# (5) El danio que recibe el Tasajero: +25% en Caza, sumado a los porcentajes del
# atacante (Sistema.md 11.2.3, 11.4 paso 1).
func test_danio_recibido_por_modo() -> void:
	var plantel: Plantel = _plantel()
	var ataque: ResultadoAccion = _turno(plantel, "ocarra_1").aplicar(Accion.atacar(_TASAJERO))
	assert_int(ataque.danio).is_equal(5)
	assert_int(plantel.criatura(_TASAJERO).vida).is_equal(30 - 5)
	assert_int(ataque.desglose.modificadores.size()).is_equal(1)
	_assert_modificador(ataque.desglose.modificadores[0], ModificadorDanio.Tipo.PORCENTAJE, 25, "caza")

	plantel = _plantel()
	plantel.criatura(_TASAJERO).modo = "cuenta"
	ataque = _turno(plantel, "ocarra_1").aplicar(Accion.atacar(_TASAJERO))
	assert_int(ataque.danio).is_equal(4)
	assert_array(ataque.desglose.modificadores).is_empty()

	# El Maestro con un combo +50%: 4 x 1,75 = 7.
	plantel = _plantel()
	var combo: Array[ModificadorDanio] = [ModificadorDanio.new(ModificadorDanio.Fuente.COMBO,
			ModificadorDanio.Tipo.PORCENTAJE, 50)]
	var desglose: DesgloseDanio = _danio.calcular(Maestro.ID, _TASAJERO, plantel, combo)
	assert_int(desglose.porcentaje_total).is_equal(75)
	assert_int(desglose.total).is_equal(7)


# (6) Cambio a Cuenta al inicio de su turno, con vida <= 50% en enteros: con 15
# de 30 cambia y juega ese turno en Cuenta; con 16 no. Sin vuelta (Sistema.md
# 11.2.3, 11.8 paso 2).
func test_cambio_a_cuenta() -> void:
	var plantel: Plantel = _plantel()
	var tasajero: Criatura = plantel.criatura(_TASAJERO)
	tasajero.vida = 16
	assert_that(CambioModo.vida_de_cambio(tasajero)).is_equal(15)
	var turno: Turno = _turno(plantel, _TASAJERO)
	assert_str(tasajero.modo).is_equal("caza")
	assert_dict(turno.cambio_modo).is_empty()
	assert_int(turno.ataques_restantes).is_equal(2)

	tasajero.vida = 15
	turno = _turno(plantel, _TASAJERO)
	assert_str(tasajero.modo).is_equal("cuenta")
	assert_dict(turno.cambio_modo).is_equal({"de": "caza", "a": "cuenta"})
	assert_int(turno.ataques_restantes).is_equal(1)
	# Movimiento partido en ese mismo turno.
	_assert_valida(turno.aplicar(Accion.mover(Vector2i(3, 2))))
	_assert_valida(turno.aplicar(Accion.mover(Vector2i(3, 1))))
	assert_that(CambioModo.vida_de_cambio(tasajero)).is_null()

	tasajero.vida = 30
	turno = _turno(plantel, _TASAJERO)
	assert_str(tasajero.modo).is_equal("cuenta")
	assert_dict(turno.cambio_modo).is_empty()

	# Sin modos no hay cambio.
	assert_that(CambioModo.vida_de_cambio(plantel.criatura("ocarra_1"))).is_null()
	plantel.criatura("ocarra_1").vida = 1
	assert_dict(_turno(plantel, "ocarra_1").cambio_modo).is_empty()
	assert_str(plantel.criatura("ocarra_1").modo).is_equal("")


# (7) La Velocidad de Cuenta rige desde la ronda siguiente: la ronda en curso no
# se rearma (Sistema.md 11.2.3, 11.3 Velocidad por modo).
func test_ronda_siguiente_con_velocidad_de_cuenta() -> void:
	var plantel: Plantel = _plantel()
	plantel.criatura(_TASAJERO).vida = 15
	var cola: ColaIniciativa = ColaIniciativa.new()
	cola.empezar_ronda(plantel)
	var turno: Turno = _siguiente_turno(cola, plantel)
	assert_str(turno.unidad_id).is_equal(_TASAJERO)
	assert_str(turno.marca).is_equal("caza")
	assert_str(plantel.criatura(_TASAJERO).modo).is_equal("cuenta")
	var orden: Array[String] = []
	for entrada in cola.entradas():
		orden.append(entrada.unidad_id)
	assert_array(orden).is_equal([_TASAJERO, "ocarra_1", "rodauva_1", Maestro.ID])

	while turno != null:
		turno.aplicar(Accion.terminar())
		turno = _siguiente_turno(cola, plantel)
	cola.terminar_ronda()
	cola.empezar_ronda(plantel)
	var ultima: EntradaCola = cola.entradas()[cola.entradas().size() - 1]
	assert_str(ultima.unidad_id).is_equal(_TASAJERO)
	assert_str(ultima.marca).is_equal("cuenta")
	assert_int(ultima.velocidad).is_equal(3)


# (9) Registro: el evento cambio_modo va detras del turno con la marca de la
# cola, y cada golpe de la Caza deja su evento ataque con el desglose (A.7). El
# Tasajero es de la tribu para jugarlo con Combate.aplicar: la regla sale del
# efecto de la ficha, no del bando.
func test_registro_caza_y_cuenta() -> void:
	var lectura: Dictionary = DatosFixture.cargar()
	assert_array(lectura["errores"]).is_empty()
	var escenario: Dictionary = _leer(_CARPETA + "escenario_caza_tribu.json", "escenario")

	var combate: Combate = Combate.empezar(ContextoCombate.armar(escenario, lectura["datos"]))
	assert_str(combate.error()).is_empty()
	assert_str(combate.turno_actual().unidad_id).is_equal("tasajero_1")
	assert_that(combate.vida_de_cambio("tasajero_1")).is_equal(15)
	assert_that(combate.vida_de_cambio(Maestro.ID)).is_null()
	assert_that(combate.vida_de_cambio("ocarra_s1")).is_null()
	_assert_valida(combate.aplicar(Accion.atacar("rodauva_s1")))
	_assert_valida(combate.aplicar(Accion.atacar("ocarra_s1")))
	var ataques: Array[Dictionary] = []
	for linea in combate.registro().lineas():
		if linea["tipo"] == "ataque":
			ataques.append(linea)
	assert_int(ataques.size()).is_equal(2)
	assert_array([ataques[0]["objetivo"], ataques[1]["objetivo"]]).is_equal(["rodauva_s1", "ocarra_s1"])
	for ataque in ataques:
		assert_str(ataque["atacante"]).is_equal("tasajero_1")
		assert_int((ataque["desglose"] as Dictionary)["total"] as int).is_equal(5)
		assert_int(ataque["vida_antes"] as int - (ataque["vida_despues"] as int)).is_equal(5)
	assert_dict(combate.registro().lineas()[2]).contains_key_value("marca", "caza")
	for linea in combate.registro().lineas():
		assert_str(linea["tipo"]).is_not_equal("cambio_modo")

	escenario["tribu"][0]["vida"] = 15
	combate = Combate.empezar(ContextoCombate.armar(escenario, lectura["datos"]))
	assert_str(combate.error()).is_empty()
	var lineas: Array[Dictionary] = combate.registro().lineas()
	var tipos: Array = []
	for linea in lineas:
		tipos.append(linea["tipo"])
	assert_array(tipos).is_equal(["inicio", "ronda", "turno", "cambio_modo"])
	assert_dict(lineas[2]).contains_key_value("unidad", "tasajero_1")
	assert_dict(lineas[2]).contains_key_value("marca", "caza")
	assert_dict(lineas[3]).contains_key_value("unidad", "tasajero_1")
	assert_dict(lineas[3]).contains_key_value("de", "caza")
	assert_dict(lineas[3]).contains_key_value("a", "cuenta")
	assert_that(combate.vida_de_cambio("tasajero_1")).is_null()
	assert_that(combate.instantanea()["criaturas"][0]["modo"]).is_equal("cuenta")
	# Ese turno ya juega con un ataque: el segundo se rechaza.
	_assert_valida(combate.aplicar(Accion.atacar("rodauva_s1")))
	_assert_rechazada(combate.aplicar(Accion.atacar("ocarra_s1")), ResultadoAccion.Motivo.ACCION_USADA)


# (10) Validar no cambia el estado y da lo mismo que aplicar, tambien en los
# casos de Caza y de Cuenta.
func test_validar_es_aplicar_en_modos() -> void:
	# [modo, acciones previas aplicadas, accion a comparar]
	var casos: Array = [
		["caza", [Accion.atacar("ocarra_1")], Accion.atacar("rodauva_1")],
		["caza", [Accion.atacar("ocarra_1")], Accion.mover(Vector2i(3, 2))],
		["caza", [Accion.atacar("ocarra_1"), Accion.atacar("ocarra_1")], Accion.atacar("ocarra_1")],
		["caza", [Accion.atacar("ocarra_1"), Accion.atacar("ocarra_1")], Accion.mover(Vector2i(3, 2))],
		["cuenta", [Accion.mover(Vector2i(4, 2))], Accion.mover(Vector2i(4, 0))],
		["cuenta", [Accion.mover(Vector2i(4, 2))], Accion.mover(Vector2i(7, 2))],
		["cuenta", [Accion.mover(Vector2i(4, 2)), Accion.atacar("ocarra_1")], Accion.mover(Vector2i(5, 2))],
		["cuenta", [Accion.mover(Vector2i(4, 2)), Accion.atacar("ocarra_1")], Accion.atacar("ocarra_1")],
	]
	for caso in casos:
		var plantel: Plantel = _plantel()
		plantel.criatura(_TASAJERO).modo = caso[0]
		var turno: Turno = _turno(plantel, _TASAJERO)
		for previa in caso[1]:
			_assert_valida(turno.aplicar(previa))
		var antes: String = _foto(plantel, turno)
		var validado: ResultadoAccion = turno.validar(caso[2])
		assert_str(_foto(plantel, turno)).is_equal(antes)

		var aplicado: ResultadoAccion = turno.aplicar(caso[2])
		assert_bool(aplicado.valida).is_equal(validado.valida)
		assert_int(aplicado.motivo).is_equal(validado.motivo)
		assert_int(aplicado.danio).is_equal(validado.danio)
