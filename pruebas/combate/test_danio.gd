extends GdUnitTestSuite

# Arquitectura.md B.2 (T09): formula de danio completa, con fixtures (A.6).
# Sistema.md 11.4 (orden del calculo), 7.1 (Saciado), 8.2 y 8.4 (enfermedades y
# combinacion) y 11.2 (Erizarse; desde la v1.3 el Surcon y el Zancajunco no
# tienen modificador pasivo, T35). Los numeros son la comprobacion: el codigo
# los lee de las fichas, la balanza, combate.json y hambre.json.
const _CARPETA: String = "res://pruebas/fixtures/combate/"
const _CARPETA_UNIDADES: String = "res://pruebas/fixtures/unidades/"
const _ESPECIES: Array[String] = ["ocarra", "rodauva", "surcon", "tasajero", "zancajunco"]

var _tablero: Tablero
var _danio: Danio
var _minimo: int


func before_test() -> void:
	var tabla_combate: Dictionary = _leer(_CARPETA + "combate.json", "combate")
	_tablero = Tablero.desde_datos({"ancho": 8, "alto": 8}, tabla_combate)
	_danio = Danio.desde_datos(tabla_combate, _leer(_CARPETA + "hambre.json", "hambre"))
	_minimo = tabla_combate["danio_minimo"]


func _leer(ruta: String, nombre_esquema: String) -> Dictionary:
	var lectura: Dictionary = LectorFixture.leer(ruta, nombre_esquema)
	var errores: Array[Dictionary] = lectura["errores"]
	assert_array(errores).override_failure_message(str(errores)).is_empty()
	return lectura["datos"]


func _plantel() -> Plantel:
	var especies: Dictionary = {}
	for id_especie in _ESPECIES:
		especies[id_especie] = Especie.new(_leer(_CARPETA_UNIDADES + id_especie + ".json", "especie"))
	var tabla: TablaBalanza = TablaBalanza.new(_leer(_CARPETA_UNIDADES + "balanza_1_2.json", "balanza"))
	return Plantel.desde_escenario(_leer(_CARPETA + "escenario_danio.json", "escenario"), especies, tabla,
			_leer(_CARPETA_UNIDADES + "maestro.json", "maestro"))


func _turno(plantel: Plantel, unidad_id: String) -> Turno:
	return Turno.empezar(EntradaCola.new(unidad_id, "", 0), plantel, _tablero, _danio)


func _aporte(fuente: ModificadorDanio.Fuente, tipo: ModificadorDanio.Tipo, valor: int) -> ModificadorDanio:
	return ModificadorDanio.new(fuente, tipo, valor)


func _combo(valor: int) -> ModificadorDanio:
	return _aporte(ModificadorDanio.Fuente.COMBO, ModificadorDanio.Tipo.PORCENTAJE, valor)


func _afinidad(valor: int) -> ModificadorDanio:
	return _aporte(ModificadorDanio.Fuente.AFINIDAD, ModificadorDanio.Tipo.PLANO, valor)


func _total(atacante_id: String, objetivo_id: String, plantel: Plantel) -> int:
	return _danio.calcular(atacante_id, objetivo_id, plantel).total


# 11.4 rearmado desde la lista de modificadores: el desglose explica el total.
func _assert_reconstruye(desglose: DesgloseDanio) -> void:
	var porcentaje: int = 0
	var planos: int = 0
	for modificador in desglose.modificadores:
		if modificador.tipo == ModificadorDanio.Tipo.PORCENTAJE:
			porcentaje += modificador.valor
		else:
			planos += modificador.valor
	assert_int(desglose.porcentaje_total).is_equal(porcentaje)
	assert_int(desglose.planos_total).is_equal(planos)
	assert_int(desglose.tras_porcentajes).is_equal(Porcentajes.aplicar(desglose.base, porcentaje))
	var sin_minimo: int = desglose.tras_porcentajes + planos
	assert_bool(desglose.minimo_aplicado).is_equal(sin_minimo < _minimo)
	assert_int(desglose.total).is_equal(maxi(_minimo, sin_minimo))


func _assert_modificador(modificador: ModificadorDanio, fuente: ModificadorDanio.Fuente,
		tipo: ModificadorDanio.Tipo, valor: int, detalle: String) -> void:
	assert_str(ModificadorDanio.Fuente.keys()[modificador.fuente]).is_equal(ModificadorDanio.Fuente.keys()[fuente])
	assert_str(ModificadorDanio.Tipo.keys()[modificador.tipo]).is_equal(ModificadorDanio.Tipo.keys()[tipo])
	assert_int(modificador.valor).is_equal(valor)
	assert_str(modificador.detalle).is_equal(detalle)


# (1) Ejemplo de 11.4: el Maestro (4), segundo eslabon (+50%) y adyacente a una
# afin (+1): 4 x 1,5 = 6, mas 1 = 7.
func test_ejemplo_de_11_4() -> void:
	var plantel: Plantel = _plantel()
	var aportes: Array[ModificadorDanio] = [_combo(50), _afinidad(1)]
	var desglose: DesgloseDanio = _danio.calcular(Maestro.ID, "ocarra_s1", plantel, aportes)
	assert_int(desglose.base).is_equal(4)
	assert_int(desglose.tras_porcentajes).is_equal(6)
	assert_int(desglose.total).is_equal(7)


# (2) 11.4, A vigilar: la Rodauva saciada hace 2 x 1,25 = 2,5 -> 2. Con hambre 3, 2.
# Borde del corte 0-2 de 7.1 (sale de hambre.json): la Ocarra con 2 hace 5, con 3 hace 4.
func test_saciado() -> void:
	var plantel: Plantel = _plantel()
	var rodauva: Criatura = plantel.criatura("rodauva_1")
	rodauva.hambre = 0
	var desglose: DesgloseDanio = _danio.calcular("rodauva_1", "ocarra_s1", plantel)
	assert_int(desglose.porcentaje_total).is_equal(25)
	assert_int(desglose.total).is_equal(2)
	rodauva.hambre = 3
	assert_int(_total("rodauva_1", "ocarra_s1", plantel)).is_equal(2)

	var ocarra: Criatura = plantel.criatura("ocarra_1")
	ocarra.hambre = 2
	assert_int(_total("ocarra_1", "ocarra_s1", plantel)).is_equal(5)
	ocarra.hambre = 3
	assert_int(_total("ocarra_1", "ocarra_s1", plantel)).is_equal(4)


# (3) 8.4: Saciado con 1 enfermedad = 0%. La Ocarra saciada y enferma hace 4.
func test_saciado_y_una_enfermedad() -> void:
	var plantel: Plantel = _plantel()
	var ocarra: Criatura = plantel.criatura("ocarra_1")
	ocarra.hambre = 0
	ocarra.enfermedades = 1
	var desglose: DesgloseDanio = _danio.calcular("ocarra_1", "ocarra_s1", plantel)
	assert_int(desglose.porcentaje_total).is_equal(0)
	assert_int(desglose.total).is_equal(4)


# (4) 8.2: 3 enfermedades = -75%. El Maestro (4, hambre 3) hace 1.
func test_tres_enfermedades() -> void:
	var plantel: Plantel = _plantel()
	plantel.maestro.enfermedades = 3
	var desglose: DesgloseDanio = _danio.calcular(Maestro.ID, "ocarra_s1", plantel)
	assert_int(desglose.porcentaje_total).is_equal(-75)
	assert_int(desglose.total).is_equal(1)
	assert_bool(desglose.minimo_aplicado).is_false()


# (5) 11.2, Erizarse: -50% al danio recibido. Contra una Rodauva erizada, la
# Ocarra hace 2 y el Tasajero 2 (5 x 0,5 = 2,5 -> 2). Reescrito por Sistema.md
# 11.2 v1.3 (Tasajero con Danio 5; antes 6, que daba 3) y 11.2.3 ("erizada
# recibe 2 + 2").
func test_contra_erizada() -> void:
	var plantel: Plantel = _plantel()
	plantel.criatura("rodauva_s1").erizada = true
	assert_int(_total("ocarra_1", "rodauva_s1", plantel)).is_equal(2)
	plantel.criatura("rodauva_1").erizada = true
	assert_int(_total("tasajero_s1", "rodauva_1", plantel)).is_equal(2)
	# Sin erizarse, el rasgo no actua.
	plantel.criatura("rodauva_s1").erizada = false
	assert_int(_total("ocarra_1", "rodauva_s1", plantel)).is_equal(4)


# (6) T35 (criterio 6). Reemplaza al test de Lomo de tierra (-1 a cada golpe),
# retirado por Sistema.md 11.2 y 11.2.1 v1.3: el surco reemplaza a Lomo de
# tierra y no reduce el danio. Contra el Surcon, el Maestro hace 4 y la Rodauva
# 2, sin ningun modificador de rasgo.
func test_surcon_no_reduce_el_danio() -> void:
	var plantel: Plantel = _plantel()
	var desglose: DesgloseDanio = _danio.calcular(Maestro.ID, "surcon_s1", plantel)
	assert_int(desglose.total).is_equal(4)
	assert_array(desglose.modificadores).is_empty()
	desglose = _danio.calcular("rodauva_1", "surcon_s1", plantel)
	assert_int(desglose.total).is_equal(2)
	assert_int(desglose.planos_total).is_equal(0)
	assert_array(desglose.modificadores).is_empty()


# (7) Reemplaza al test de Hacerse junco pasivo (+2 en el primer ataque del
# combate), retirado por Sistema.md 11.2.2 v1.3: ahora es una activa (+3 despues
# de ocultarse, T38). Sin ocultarse, el Zancajunco pega 4 en su primer ataque y
# en el segundo, y aplicar un ataque no deja ninguna marca en la criatura.
func test_zancajunco_sin_bono_pasivo() -> void:
	var plantel: Plantel = _plantel()
	assert_int(_total("zancajunco_1", "tasajero_s1", plantel)).is_equal(4)

	var turno: Turno = _turno(plantel, "zancajunco_1")
	assert_int(turno.validar(Accion.atacar("tasajero_s1")).danio).is_equal(4)
	assert_int(turno.aplicar(Accion.atacar("tasajero_s1")).danio).is_equal(4)
	assert_int(plantel.criatura("tasajero_s1").vida).is_equal(30 - 4)
	turno.aplicar(Accion.terminar())

	turno = _turno(plantel, "zancajunco_1")
	var antes: Dictionary = plantel.instantanea()
	assert_int(turno.validar(Accion.atacar("tasajero_s1")).danio).is_equal(4)
	assert_dict(plantel.instantanea()).is_equal(antes)
	assert_int(turno.aplicar(Accion.atacar("tasajero_s1")).danio).is_equal(4)
	assert_int(plantel.criatura("tasajero_s1").vida).is_equal(30 - 4 - 4)


# (8) Porcentajes por debajo de -100%: la Rodauva con 3 enfermedades (-75%)
# contra una Rodauva erizada (-50%): 2 x (-25%) = -0,5 -> -1 (piso, no 0); minimo 1.
func test_porcentajes_bajo_menos_cien() -> void:
	var plantel: Plantel = _plantel()
	plantel.criatura("rodauva_1").enfermedades = 3
	plantel.criatura("rodauva_s1").erizada = true
	var desglose: DesgloseDanio = _danio.calcular("rodauva_1", "rodauva_s1", plantel)
	assert_int(desglose.porcentaje_total).is_equal(-125)
	assert_int(desglose.tras_porcentajes).is_equal(-1)
	assert_int(desglose.total).is_equal(1)
	assert_bool(desglose.minimo_aplicado).is_true()
	_assert_reconstruye(desglose)


# (9) El desglose: cada modificador con su fuente, tipo y valor, y el total
# se rearma desde la lista. Zancajunco saciada (+25) con 1 enfermedad (-25) contra
# una Rodauva erizada (-50), con combo +50 y afinidad +1: 0% -> 4, +1 = 5.
# Reescrito por Sistema.md 11.2.2 v1.3: sale el +2 pasivo de Hacerse junco
# (antes 6 modificadores y total 7).
func test_desglose() -> void:
	var plantel: Plantel = _plantel()
	var zancajunco: Criatura = plantel.criatura("zancajunco_1")
	zancajunco.hambre = 0
	zancajunco.enfermedades = 1
	plantel.criatura("rodauva_s1").erizada = true
	var aportes: Array[ModificadorDanio] = [_combo(50), _afinidad(1)]
	var desglose: DesgloseDanio = _danio.calcular("zancajunco_1", "rodauva_s1", plantel, aportes)

	assert_int(desglose.base).is_equal(4)
	var modificadores: Array[ModificadorDanio] = desglose.modificadores
	assert_int(modificadores.size()).is_equal(5)
	var pct: ModificadorDanio.Tipo = ModificadorDanio.Tipo.PORCENTAJE
	var plano: ModificadorDanio.Tipo = ModificadorDanio.Tipo.PLANO
	_assert_modificador(modificadores[0], ModificadorDanio.Fuente.HAMBRE, pct, 25, "saciado")
	_assert_modificador(modificadores[1], ModificadorDanio.Fuente.ENFERMEDAD, pct, -25, "")
	_assert_modificador(modificadores[2], ModificadorDanio.Fuente.RASGO_OBJETIVO, pct, -50, "erizarse")
	_assert_modificador(modificadores[3], ModificadorDanio.Fuente.COMBO, pct, 50, "")
	_assert_modificador(modificadores[4], ModificadorDanio.Fuente.AFINIDAD, plano, 1, "")
	assert_int(desglose.porcentaje_total).is_equal(0)
	assert_int(desglose.tras_porcentajes).is_equal(4)
	assert_int(desglose.planos_total).is_equal(1)
	assert_int(desglose.total).is_equal(5)
	assert_bool(desglose.minimo_aplicado).is_false()
	_assert_reconstruye(desglose)


# (10) La funcion de porcentajes sola, sin minimo (K-05: la recoleccion puede dar 0).
func test_funcion_de_porcentajes() -> void:
	assert_int(Porcentajes.aplicar(1, -50)).is_equal(0)
	assert_int(Porcentajes.aplicar(5, -25)).is_equal(3)
	assert_int(Porcentajes.aplicar(4, 50)).is_equal(6)
	assert_int(Porcentajes.aplicar(2, 25)).is_equal(2)
	# Redondeo hacia abajo con negativos: -0,5 -> -1 (la division entera daria 0).
	assert_int(Porcentajes.aplicar(2, -125)).is_equal(-1)
	assert_int(Porcentajes.aplicar(4, -125)).is_equal(-1)
	assert_int(Porcentajes.aplicar(3, -150)).is_equal(-2)


# (11) S-17 (P-016): las enemigas no reciben Saciado ni enfermedades. Una Ocarra
# enemiga hace 4 aunque la tribu este saciada (y aunque ella tenga hambre 0 y 1 enfermedad).
func test_enemiga_sin_saciado_ni_enfermedades() -> void:
	var plantel: Plantel = _plantel()
	plantel.maestro.hambre = 0
	for criatura in plantel.criaturas():
		if criatura.bando == Criatura.Bando.TRIBU:
			criatura.hambre = 0
	var ocarra_s1: Criatura = plantel.criatura("ocarra_s1")
	ocarra_s1.hambre = 0
	ocarra_s1.enfermedades = 1
	var desglose: DesgloseDanio = _danio.calcular("ocarra_s1", Maestro.ID, plantel)
	assert_int(desglose.total).is_equal(4)
	assert_array(desglose.modificadores).is_empty()
	# La tribu saciada si lo recibe.
	assert_int(_total("ocarra_1", "ocarra_s1", plantel)).is_equal(5)


# calcular no modifica el Plantel: sirve para validar (calcular sin aplicar).
# Compara la instantanea entera: ya_ataco salio con el +2 pasivo (Sistema.md 11.2.2 v1.3).
func test_calcular_no_modifica() -> void:
	var plantel: Plantel = _plantel()
	var antes: Dictionary = plantel.instantanea()
	_danio.calcular("zancajunco_1", "tasajero_s1", plantel)
	assert_dict(plantel.instantanea()).is_equal(antes)
	assert_int(plantel.criatura("tasajero_s1").vida).is_equal(30)
