extends GdUnitTestSuite

# Arquitectura.md B.2 (T12, sesion 1): contexto, bucle y registro del combate
# (A.7), con fixtures (A.6) salvo el test 9, que usa los 11 escenarios de datos/.
# Sistema.md 5.2, 9.2 y 11.5. Los numeros de vida y danio son la comprobacion:
# el codigo los lee de las fichas, la balanza y las tablas de prueba.
const _CARPETA: String = "res://pruebas/fixtures/combate/"
const _CARPETA_CONTRATO: String = "res://pruebas/fixtures/combate/contrato/"
const _CARPETA_UNIDADES: String = "res://pruebas/fixtures/unidades/"
const _CARPETA_DATOS: String = "res://datos"
const _TIRADAS: int = 10


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


func _contexto(escenario: Dictionary) -> ContextoCombate:
	var contexto: ContextoCombate = ContextoCombate.armar(escenario, _datos())
	assert_bool(contexto.valido).is_true()
	return contexto


func _combate(escenario: Dictionary) -> Combate:
	var combate: Combate = Combate.empezar(_contexto(escenario))
	assert_str(combate.error()).is_empty()
	return combate


func _tipos(combate: Combate) -> Array[String]:
	var tipos: Array[String] = []
	for linea in combate.registro().lineas():
		tipos.append(linea["tipo"])
	return tipos


func _de_tipo(combate: Combate, tipo: String) -> Array[Dictionary]:
	var resultado: Array[Dictionary] = []
	for linea in combate.registro().lineas():
		if linea["tipo"] == tipo:
			resultado.append(linea)
	return resultado


func _aplicar_valida(combate: Combate, accion: Accion) -> ResultadoAccion:
	var resultado: ResultadoAccion = combate.aplicar(accion)
	assert_bool(resultado.valida).override_failure_message(
			ResultadoAccion.Motivo.keys()[resultado.motivo] + " " + str(accion.a_diccionario())).is_true()
	assert_str(combate.error()).is_empty()
	return resultado


func _assert_motivo(resultado: ResultadoAccion, motivo: ResultadoAccion.Motivo) -> void:
	assert_bool(resultado.valida).is_false()
	assert_str(ResultadoAccion.Motivo.keys()[resultado.motivo]).is_equal(ResultadoAccion.Motivo.keys()[motivo])


func _assert_fin(combate: Combate, fin: FinCombate.Fin) -> void:
	assert_str(FinCombate.Fin.keys()[combate.fin()]).is_equal(FinCombate.Fin.keys()[fin])


# Lo que no cambia con una accion rechazada.
func _foto(combate: Combate) -> Array:
	return [combate.instantanea(), combate.registro().lineas(), combate.acciones_jugador()]


func _sin_float(valor: Variant) -> bool:
	match typeof(valor):
		TYPE_FLOAT:
			return false
		TYPE_ARRAY:
			for elemento in (valor as Array):
				if not _sin_float(elemento):
					return false
		TYPE_DICTIONARY:
			for clave in (valor as Dictionary).keys():
				if not _sin_float((valor as Dictionary)[clave]):
					return false
	return true


func _tiradas(generador: GeneradorAzar) -> Array[int]:
	var resultado: Array[int] = []
	for i in range(_TIRADAS):
		resultado.append(generador.entero(0, 999999))
	return resultado


# (1) El contexto lee semilla, tablero, plantel, golpe inicial y toggles; dos
# contextos del mismo escenario dan los mismos generadores; Danio sin tabla de
# hambre falla.
func test_contexto_lee_el_escenario() -> void:
	var escenario: Dictionary = _escenario(_CARPETA + "escenario_c.json")
	var contexto: ContextoCombate = _contexto(escenario)
	assert_str(contexto.escenario_id).is_equal("c_tasajero")
	assert_str(contexto.tipo).is_equal("test")
	assert_int(contexto.semilla).is_equal(33001)
	assert_bool(contexto.tablero.dentro(Vector2i(7, 7))).is_true()
	assert_bool(contexto.tablero.dentro(Vector2i(8, 0))).is_false()
	assert_int(contexto.plantel.criaturas().size()).is_equal(4)
	assert_that(contexto.plantel.maestro.posicion).is_equal(Vector2i(3, 6))
	assert_str(contexto.golpe_inicial).is_empty()
	assert_dict(contexto.toggles).is_equal({"afines_contra_cobardia": false})
	assert_object(contexto.danio).is_not_null()
	assert_object(contexto.cierre).is_not_null()

	# Golpe inicial: el id de la atacante, leido y sin resolver (T30).
	var con_golpe: Dictionary = _escenario(_CARPETA_UNIDADES + "escenario_g.json")
	var contexto_g: ContextoCombate = _contexto(con_golpe)
	assert_str(contexto_g.golpe_inicial).is_equal(con_golpe["golpe_inicial"])
	assert_str(contexto_g.tipo).is_equal("nocturno")

	var otro: ContextoCombate = _contexto(escenario)
	var combate_a: Array[int] = _tiradas(contexto.azar_combate)
	var textos_a: Array[int] = _tiradas(contexto.azar_textos)
	assert_array(_tiradas(otro.azar_combate)).is_equal(combate_a)
	assert_array(_tiradas(otro.azar_textos)).is_equal(textos_a)
	assert_array(textos_a).is_not_equal(combate_a)

	var tabla_combate: Dictionary = _datos()["tablas/combate.json"]
	assert_object(Danio.desde_datos(tabla_combate, {})).is_null()


# (2) Prueba A: al empezar, la Ocarra juega sola y el combate se detiene en el
# turno de la Rodauva.
func test_prueba_a_se_detiene_en_la_rodauva() -> void:
	var combate: Combate = _combate(_escenario(_CARPETA_UNIDADES + "escenario_a.json"))
	var turnos: Array[Dictionary] = _de_tipo(combate, "turno")
	assert_int(turnos.size()).is_equal(2)
	assert_str(turnos[0]["unidad"]).is_equal("ocarra_s1")
	assert_str(turnos[1]["unidad"]).is_equal("rodauva_1")
	for accion in _de_tipo(combate, "accion"):
		assert_str(accion["unidad"]).is_equal("ocarra_s1")
		assert_str(accion["origen"]).is_equal("ia")
		assert_str(accion["paso"]).is_not_empty()
	assert_bool(combate.esperando_jugador()).is_true()
	assert_str(combate.turno_actual().unidad_id).is_equal("rodauva_1")
	assert_bool(combate.terminado()).is_false()
	assert_array(combate.acciones_jugador()).is_empty()


# (3) Una accion invalida del jugador, o una con el combate terminado, no
# cambia la instantanea, el registro ni lo que se graba.
func test_accion_invalida_no_cambia_nada() -> void:
	var combate: Combate = _combate(_escenario(_CARPETA_UNIDADES + "escenario_a.json"))
	var antes: Array = _foto(combate)
	_assert_motivo(combate.aplicar(Accion.mover(Vector2i(0, 0))), ResultadoAccion.Motivo.CASILLA_NO_ALCANZABLE)
	_assert_motivo(combate.aplicar(Accion.atacar("ocarra_s1")), ResultadoAccion.Motivo.FUERA_DE_ALCANCE)
	_assert_motivo(combate.aplicar(Accion.atacar("maestro")), ResultadoAccion.Motivo.OBJETIVO_ALIADO)
	assert_str(str(_foto(combate))).is_equal(str(antes))

	# Con el combate terminado (el Maestro empieza en 0), toda accion se rechaza.
	var escenario: Dictionary = _escenario(_CARPETA_CONTRATO + "contrato_victoria.json")
	(escenario["maestro"] as Dictionary)["vida"] = 0
	var terminado: Combate = _combate(escenario)
	var antes_fin: Array = _foto(terminado)
	_assert_motivo(terminado.aplicar(Accion.terminar()), ResultadoAccion.Motivo.COMBATE_TERMINADO)
	assert_str(str(_foto(terminado))).is_equal(str(antes_fin))


# (4) Jugado con acciones de prueba hasta la victoria: el cierre corre una vez,
# el resultado esta disponible y toda accion siguiente se rechaza.
func test_victoria_cierra_una_vez() -> void:
	var combate: Combate = _combate(_escenario(_CARPETA_CONTRATO + "contrato_victoria.json"))
	# La Ocarra tumbo a la Rodauva: se saltea y juega el Maestro.
	var rodauva: Criatura = combate.contexto().plantel.criatura("rodauva_1")
	assert_int(rodauva.estado).is_equal(Criatura.Estado.CAIDA)
	assert_str(combate.turno_actual().unidad_id).is_equal(Maestro.ID)
	assert_object(combate.resultado()).is_null()

	_aplicar_valida(combate, Accion.mover(Vector2i(2, 5)))
	var ataque: ResultadoAccion = _aplicar_valida(combate, Accion.atacar("ocarra_s1"))
	assert_int(ataque.danio).is_equal(4)
	assert_bool(combate.terminado()).is_true()
	_assert_fin(combate, FinCombate.Fin.VICTORIA)
	assert_bool(combate.esperando_jugador()).is_false()

	var resultado: ResultadoCombate = combate.resultado()
	assert_object(resultado).is_not_null()
	assert_array(resultado.levantadas).is_equal(["rodauva_1"])
	assert_int(rodauva.estado).is_equal(Criatura.Estado.SUELTA)
	assert_int(rodauva.vida).is_equal(1)
	assert_bool(combate.contexto().plantel.cerrado).is_true()
	assert_int(_de_tipo(combate, "cierre").size()).is_equal(1)
	assert_int(_de_tipo(combate, "fin").size()).is_equal(1)
	assert_str(_de_tipo(combate, "fin")[0]["desenlace"]).is_equal("victoria")
	assert_str(_tipos(combate).back()).is_equal("cierre")
	assert_int(combate.acciones_jugador().size()).is_equal(2)

	var antes: Array = _foto(combate)
	_assert_motivo(combate.aplicar(Accion.terminar()), ResultadoAccion.Motivo.COMBATE_TERMINADO)
	_assert_motivo(combate.aplicar(Accion.atacar("ocarra_s1")), ResultadoAccion.Motivo.COMBATE_TERMINADO)
	assert_str(str(_foto(combate))).is_equal(str(antes))
	assert_object(combate.resultado()).is_same(resultado)


# (5) La IA tumba al Maestro a mitad de ronda: derrota en el acto, sin ninguna
# entrada mas.
func test_derrota_a_mitad_de_ronda() -> void:
	var combate: Combate = _combate(_escenario(_CARPETA_CONTRATO + "contrato_derrota.json"))
	assert_bool(combate.terminado()).is_true()
	_assert_fin(combate, FinCombate.Fin.DERROTA_POR_CAIDA)
	assert_bool(combate.esperando_jugador()).is_false()
	assert_bool(combate.contexto().plantel.maestro.caido).is_true()

	var turnos: Array[Dictionary] = _de_tipo(combate, "turno")
	assert_int(turnos.size()).is_equal(1)
	assert_str(turnos[0]["unidad"]).is_equal("ocarra_s1")
	assert_array(_de_tipo(combate, "fin_turno")).is_empty()
	assert_array(_de_tipo(combate, "fin_ronda")).is_empty()
	var tipos: Array[String] = _tipos(combate)
	assert_array(tipos.slice(tipos.find("ataque"))).is_equal(["ataque", "estado", "fin", "cierre"])
	var estado: Dictionary = _de_tipo(combate, "estado")[0]
	assert_dict(estado).contains_key_value("unidad", Maestro.ID)
	assert_dict(estado).contains_key_value("a", "caido")
	assert_object(combate.resultado()).is_not_null()
	assert_bool(combate.resultado().maestro_caido).is_true()


# (6) Unidades en 0 al armar: tribu caida antes de la ronda 1; Maestro en 0,
# derrota sin rondas ni turnos; todas las enemigas en 0, victoria sin rondas.
func test_unidades_en_0_al_armar() -> void:
	var tribu_en_0: Dictionary = _escenario(_CARPETA_CONTRATO + "contrato_victoria.json")
	((tribu_en_0["tribu"] as Array)[0] as Dictionary)["vida"] = 0
	var combate: Combate = _combate(tribu_en_0)
	assert_int(combate.contexto().plantel.criatura("rodauva_1").estado).is_equal(Criatura.Estado.CAIDA)
	var tipos: Array[String] = _tipos(combate)
	assert_array(tipos.slice(0, 3)).is_equal(["inicio", "estado", "ronda"])
	var estado: Dictionary = _de_tipo(combate, "estado")[0]
	assert_dict(estado).contains_key_value("unidad", "rodauva_1")
	assert_dict(estado).contains_key_value("de", "suelta")
	assert_dict(estado).contains_key_value("a", "caida")
	assert_int(estado["ronda"] as int).is_equal(0)
	assert_bool(combate.esperando_jugador()).is_true()

	var maestro_en_0: Dictionary = _escenario(_CARPETA_CONTRATO + "contrato_victoria.json")
	(maestro_en_0["maestro"] as Dictionary)["vida"] = 0
	var derrota: Combate = _combate(maestro_en_0)
	_assert_fin(derrota, FinCombate.Fin.DERROTA_POR_CAIDA)
	assert_array(_tipos(derrota)).is_equal(["inicio", "estado", "fin", "cierre"])
	assert_int(derrota.instantanea()["ronda"] as int).is_equal(0)
	assert_object(derrota.turno_actual()).is_null()

	var enemigas_en_0: Dictionary = _escenario(_CARPETA_CONTRATO + "contrato_victoria.json")
	((enemigas_en_0["enemigas"] as Array)[0] as Dictionary)["vida"] = 0
	var victoria: Combate = _combate(enemigas_en_0)
	_assert_fin(victoria, FinCombate.Fin.VICTORIA)
	assert_array(_tipos(victoria)).is_equal(["inicio", "estado", "fin", "cierre"])
	assert_int(victoria.instantanea()["ronda"] as int).is_equal(0)
	assert_int(victoria.contexto().plantel.criatura("ocarra_s1").estado).is_equal(Criatura.Estado.FUERA)


# Ronda 1 de C con la tribu esperando, mas una tirada hecha a mano antes de la
# accion de la Ocarra de la tribu (despues de la tirada de su incidente, T18).
func _jugar_ronda_c() -> Combate:
	var combate: Combate = _combate(_escenario(_CARPETA + "escenario_c.json"))
	while combate.instantanea()["ronda"] == 1:
		if combate.turno_actual().unidad_id == "ocarra_1":
			combate.contexto().azar_combate.entero(1, 100)
		_aplicar_valida(combate, Accion.terminar())
	return combate


# (7) Registro de una ronda de C: orden de los eventos, Tasajero con caza, fin_turno
# con la posicion, sin float. La tirada queda justo antes de la accion que siguio.
# Reescrito por Sistema.md 11.2.3 v1.3: un solo turno del Tasajero por ronda (en
# Caza), y 11.9: desde [3,1] alcanza al Maestro en la ronda 1 (antes pegaba en la Cuenta).
# Reescrito en T39 por Sistema.md 11.8 paso 6b: desde [3,5], con una sola presa
# (el Maestro), le da los dos ataques de Caza: dos pares accion/ataque.
# Reescrito en T18 por Sistema.md 10.4 v1.6 y 11.3 paso 4: la Ocarra y el
# Zancajunco de la tribu son rivales vecinas en C, asi que cada una tira su
# incidente al empezar el turno (5 % con la balanza 2). Con la semilla de C
# ninguna sale: queda la `tirada` sin evento `incidente`. La hecha a mano es la 2.
func test_registro_de_una_ronda_de_c() -> void:
	var combate: Combate = _jugar_ronda_c()
	assert_str(combate.turno_actual().unidad_id).is_equal("zancajunco_1")
	assert_array(_tipos(combate)).is_equal([
		"inicio", "ronda",
		"turno", "tirada", "accion", "fin_turno",
		"turno", "accion", "movimiento", "accion", "ataque", "accion", "ataque", "accion", "fin_turno",
		"turno", "tirada", "tirada", "accion", "fin_turno",
		"turno", "accion", "fin_turno",
		"turno", "accion", "fin_turno",
		"fin_ronda", "ronda", "turno",
	])
	var turnos: Array[Dictionary] = _de_tipo(combate, "turno")
	var unidades: Array[String] = []
	var marcas: Array = []
	for turno in turnos:
		unidades.append(turno["unidad"])
		marcas.append(turno["marca"])
	assert_array(unidades).is_equal(["zancajunco_1", "tasajero_s1", "ocarra_1", "rodauva_1", Maestro.ID, "zancajunco_1"])
	assert_array(marcas).is_equal([null, "caza", null, null, null, null])

	var lineas: Array[Dictionary] = combate.registro().lineas()
	for i in range(lineas.size()):
		assert_int(lineas[i]["n"] as int).is_equal(i)
		assert_bool(_sin_float(lineas[i])).override_failure_message(str(lineas[i])).is_true()
	var fines: Array[Dictionary] = _de_tipo(combate, "fin_turno")
	assert_dict(fines[0]).contains_key_value("unidad", "zancajunco_1")
	assert_array(fines[0]["posicion"]).is_equal([4, 6])
	var tasajero: Criatura = combate.contexto().plantel.criatura("tasajero_s1")
	assert_array(fines[1]["posicion"]).is_equal([tasajero.posicion.x, tasajero.posicion.y])
	var movimiento: Dictionary = _de_tipo(combate, "movimiento")[0]
	assert_array(movimiento["desde"]).is_equal([3, 1])

	var tiradas: Array[Dictionary] = _de_tipo(combate, "tirada")
	assert_int(tiradas.size()).is_equal(3)
	assert_array(_de_tipo(combate, "incidente")).is_empty()
	for incidente in tiradas.slice(0, 2):
		assert_dict(incidente["parametros"]).is_equal({"minimo": 1, "maximo": 100})
		assert_int(incidente["resultado"] as int).is_greater(5)
	var tirada: Dictionary = tiradas[2]
	assert_int(tirada["indice"] as int).is_equal(2)
	assert_str(tirada["metodo"]).is_equal("entero")
	assert_dict(tirada["parametros"]).is_equal({"minimo": 1, "maximo": 100})
	var siguiente: Dictionary = lineas[(tirada["n"] as int) + 1]
	assert_dict(siguiente).contains_key_value("tipo", "accion")
	assert_dict(siguiente).contains_key_value("unidad", "ocarra_1")

	var ataque: Dictionary = _de_tipo(combate, "ataque")[0]
	assert_int(ataque["vida_antes"] as int - (ataque["vida_despues"] as int)).is_equal((ataque["desglose"] as Dictionary)["total"] as int)
	# Los dos golpes de Caza van al Maestro, uno detras del otro (11.8 paso 6b).
	var ataques: Array[Dictionary] = _de_tipo(combate, "ataque")
	assert_int(ataques.size()).is_equal(2)
	for golpe in ataques:
		assert_dict(golpe).contains_key_value("atacante", "tasajero_s1").contains_key_value("objetivo", Maestro.ID)
	assert_int(ataques[1]["vida_antes"] as int).is_equal(ataques[0]["vida_despues"] as int)
	assert_array(fines[1]["posicion"]).is_equal([3, 5])


# (8) El mismo contexto con las mismas acciones, dos veces, da registros
# identicos linea por linea.
func test_registro_determinista() -> void:
	var primero: Array[String] = _jugar_ronda_c().registro().lineas_json()
	var segundo: Array[String] = _jugar_ronda_c().registro().lineas_json()
	assert_int(segundo.size()).is_equal(primero.size())
	for i in range(primero.size()):
		assert_str(segundo[i]).is_equal(primero[i])


# (9) Con datos/ real: los 11 escenarios arman su combate y llegan al primer
# turno del jugador sin errores. Una unidad del tablero con posicion null se
# rechaza; una guardada con null, no (P-023).
func test_once_escenarios_reales_llegan_al_jugador() -> void:
	var carga: Dictionary = Cargador.new().cargar_carpeta(_CARPETA_DATOS)
	var errores: Array[Dictionary] = carga["errores"]
	assert_array(errores).override_failure_message(str(errores)).is_empty()
	var datos: Dictionary = carga["datos"]
	var cantidad: int = 0
	for ruta in datos.keys():
		if not (ruta as String).begins_with("escenarios/"):
			continue
		cantidad += 1
		var contexto: ContextoCombate = ContextoCombate.armar(datos[ruta], datos)
		assert_bool(contexto.valido).override_failure_message(ruta).is_true()
		var combate: Combate = Combate.empezar(contexto)
		assert_str(combate.error()).override_failure_message(ruta).is_empty()
		assert_bool(combate.esperando_jugador()).override_failure_message(ruta).is_true()
	assert_int(cantidad).is_equal(11)

	var sin_posicion: Dictionary = (datos["escenarios/a_dia_1.json"] as Dictionary).duplicate(true)
	(sin_posicion["maestro"] as Dictionary)["posicion"] = null
	var rechazado: ContextoCombate = ContextoCombate.armar(sin_posicion, datos)
	assert_bool(rechazado.valido).is_false()
	assert_str(ContextoCombate.Motivo.keys()[rechazado.motivo]).is_equal("DESPLIEGUE_NO_IMPLEMENTADO")

	var enemiga_sin_posicion: Dictionary = (datos["escenarios/a_dia_1.json"] as Dictionary).duplicate(true)
	((enemiga_sin_posicion["enemigas"] as Array)[0] as Dictionary)["posicion"] = null
	assert_bool(ContextoCombate.armar(enemiga_sin_posicion, datos).valido).is_false()

	var guardada: Dictionary = (datos["escenarios/c_tasajero.json"] as Dictionary).duplicate(true)
	var rodauva: Dictionary = (guardada["tribu"] as Array)[0]
	rodauva["estado"] = "guardada"
	rodauva["posicion"] = null
	var con_guardada: ContextoCombate = ContextoCombate.armar(guardada, datos)
	assert_bool(con_guardada.valido).is_true()
	assert_bool(Combate.empezar(con_guardada).esperando_jugador()).is_true()


# Adelanta el (18) de la sesion 2: Accion ida y vuelta por diccionario.
func test_accion_ida_y_vuelta() -> void:
	var acciones: Array[Accion] = [Accion.mover(Vector2i(2, 5)), Accion.atacar("ocarra_s1"), Accion.erizarse(), Accion.terminar()]
	for accion in acciones:
		var diccionario: Dictionary = accion.a_diccionario()
		var vuelta: Accion = Accion.desde_diccionario(diccionario)
		assert_object(vuelta).is_not_null()
		assert_int(vuelta.tipo).is_equal(accion.tipo)
		assert_that(vuelta.casilla).is_equal(accion.casilla)
		assert_str(vuelta.objetivo_id).is_equal(accion.objetivo_id)
		assert_dict(vuelta.a_diccionario()).is_equal(diccionario)
	assert_dict(Accion.mover(Vector2i(2, 5)).a_diccionario()).is_equal({"tipo": "mover", "casilla": [2, 5]})
	# Leida de JSON sin validar, la casilla llega como decimal entero.
	assert_that(Accion.desde_diccionario({"tipo": "mover", "casilla": [2.0, 5.0]}).casilla).is_equal(Vector2i(2, 5))
	assert_object(Accion.desde_diccionario({"tipo": "volar"})).is_null()
	assert_object(Accion.desde_diccionario({"tipo": "MOVER", "casilla": [1, 1]})).is_null()
	assert_object(Accion.desde_diccionario({"tipo": "mover", "casilla": [1.5, 1]})).is_null()
	assert_object(Accion.desde_diccionario({"tipo": "atacar"})).is_null()
	assert_object(Accion.desde_diccionario({"tipo": "terminar", "casilla": [1, 1]})).is_null()


# El registro rechaza un float y deja el error.
func test_registro_rechaza_float() -> void:
	var registro: RegistroCombate = RegistroCombate.new()
	assert_bool(registro.agregar({"tipo": "inicio", "lista": [1, "a", true, null, {"x": 2}]})).is_true()
	assert_bool(registro.agregar({"tipo": "tirada", "resultado": 0.5})).is_false()
	assert_str(registro.error).contains("resultado")
	assert_int(registro.lineas().size()).is_equal(1)
	assert_str(registro.lineas_json()[0]).is_equal('{"lista":[1,"a",true,null,{"x":2}],"n":0,"tipo":"inicio"}')


# T13: la cola que muestra la pantalla sale del combate, no se rearma afuera.
# Prueba C (Sistema.md 11.3): el primer turno del jugador es el del Zancajunco.
# Sin la entrada de la Cuenta: reescrito por Sistema.md 11.2.3 v1.3 (un turno por ronda).
func test_cola_y_entrada_actual_para_la_pantalla() -> void:
	var combate: Combate = _combate(_escenario(_CARPETA + "escenario_c.json"))
	var unidades: Array[String] = []
	var marcas: Array[String] = []
	for entrada in combate.cola():
		unidades.append(entrada.unidad_id)
		marcas.append(entrada.marca)
	assert_array(unidades).is_equal(["zancajunco_1", "tasajero_s1", "ocarra_1", "rodauva_1", Maestro.ID])
	assert_array(marcas).is_equal(["", "caza", "", "", ""])
	assert_int(combate.entrada_actual()).is_equal(0)
	_aplicar_valida(combate, Accion.terminar())
	# Despues de terminar, juega el Tasajero (Caza) y el combate se detiene en la
	# Ocarra: la entrada actual sigue al turno en curso.
	assert_str(combate.cola()[combate.entrada_actual()].unidad_id).is_equal(combate.turno_actual().unidad_id)
