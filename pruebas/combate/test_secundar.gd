extends GdUnitTestSuite

# Arquitectura.md B.3 (T17): Secundar, con fixtures (A.6). Sistema.md 10.1
# (Iniciativa y Secundar), 10.2 (Secundar no corta la cadena) y 11.3 (Turno de
# una unidad e Inicio del turno), con las lecturas declaradas S-29 a S-31
# (P-031 a P-033). Los turnos sueltos comparten la cola, como en el Combate.
const _CARPETA: String = "res://pruebas/fixtures/combate/"
const _CARPETA_UNIDADES: String = "res://pruebas/fixtures/unidades/"
const _CARPETA_DATOS: String = "res://datos/"
const _ESPECIES: Array[String] = ["ocarra", "rodauva", "surcon", "tasajero", "zancajunco"]
const _FUENTES: Array[String] = [
	"res://nucleo/combate/cola_iniciativa.gd",
	"res://nucleo/combate/entrada_cola.gd",
	"res://nucleo/combate/turno.gd",
]
# T18 (Sistema.md 10.4 y 11.3, paso 4): el Turno recibe el generador de combate
# para la tirada del incidente y solo lo pasa a Incidente.tirar. No crea
# generadores, no tira por su cuenta ni usa azar suelto.
const _AZAR_PROHIBIDO: Array[String] = ["GeneradorAzar.new", "GeneradorAzar.derivado", ".entero(", ".decimal(",
		"randi", "randf", "RandomNumberGenerator"]

var _tablero: Tablero


func before_test() -> void:
	var tabla_combate: Dictionary = _leer(_CARPETA + "combate.json", "combate")
	_tablero = Tablero.desde_datos({"ancho": 8, "alto": 8}, tabla_combate)


func _leer(ruta: String, nombre_esquema: String) -> Dictionary:
	var lectura: Dictionary = LectorFixture.leer(ruta, nombre_esquema)
	var errores: Array[Dictionary] = lectura["errores"]
	assert_array(errores).override_failure_message(str(errores)).is_empty()
	return lectura["datos"]


func _escenario(nombre: String = "escenario_c.json") -> Dictionary:
	return _leer(_CARPETA + nombre, "escenario")


func _plantel(escenario: Dictionary = {}) -> Plantel:
	if escenario.is_empty():
		escenario = _escenario()
	var especies: Dictionary = {}
	for id_especie in _ESPECIES:
		especies[id_especie] = Especie.new(_leer(_CARPETA_UNIDADES + id_especie + ".json", "especie"))
	var tabla: TablaBalanza = TablaBalanza.new(_leer(_CARPETA_UNIDADES + "balanza_1_2.json", "balanza"))
	return Plantel.desde_escenario(escenario, especies, tabla, _leer(_CARPETA_UNIDADES + "maestro.json", "maestro"))


func _cola(plantel: Plantel) -> ColaIniciativa:
	var cola: ColaIniciativa = ColaIniciativa.new()
	cola.empezar_ronda(plantel)
	return cola


# El turno de la proxima entrada, como lo empieza el Combate.
func _siguiente(cola: ColaIniciativa, plantel: Plantel) -> Turno:
	var entrada: EntradaCola = cola.siguiente(plantel)
	if entrada == null:
		return null
	return Turno.empezar(entrada, plantel, _tablero, Surcos.new(), DatosFixture.cadena(), cola,
			DatosFixture.reglas(), GeneradorAzar.new(1))


# "id" o "id:marca", en el orden de la cola.
func _orden(entradas: Array[EntradaCola]) -> Array[String]:
	var resultado: Array[String] = []
	for entrada in entradas:
		resultado.append(entrada.unidad_id if entrada.marca.is_empty() else entrada.unidad_id + ":" + entrada.marca)
	return resultado


# Todo lo que una accion puede cambiar en el Plantel.
func _foto(plantel: Plantel) -> String:
	var foto: Array = [plantel.maestro.vida, plantel.maestro.posicion]
	for criatura in plantel.criaturas():
		foto.append([criatura.id, criatura.vida, criatura.posicion, criatura.estado, criatura.erizada, criatura.modo])
	return str(foto)


func _aplicar_valida(turno: Turno, accion: Accion) -> ResultadoAccion:
	var resultado: ResultadoAccion = turno.aplicar(accion)
	assert_bool(resultado.valida).override_failure_message("%s %s: %s" % [turno.unidad_id,
			str(accion.a_diccionario()), ResultadoAccion.Motivo.keys()[resultado.motivo]]).is_true()
	return resultado


# Validar y aplicar rechazan con el motivo, sin cambiar la cola, el Plantel ni el turno.
func _assert_rechazo(turno: Turno, cola: ColaIniciativa, plantel: Plantel, aliado_id: String,
		motivo: ResultadoAccion.Motivo) -> void:
	var orden: Array[String] = _orden(cola.entradas())
	var lugar: int = cola.lugar()
	var foto: String = _foto(plantel)
	for resultado in [turno.validar(Accion.secundar(aliado_id)), turno.aplicar(Accion.secundar(aliado_id))]:
		assert_bool((resultado as ResultadoAccion).valida).override_failure_message(aliado_id).is_false()
		assert_str(ResultadoAccion.Motivo.keys()[(resultado as ResultadoAccion).motivo]).override_failure_message(
				aliado_id).is_equal(ResultadoAccion.Motivo.keys()[motivo])
	assert_array(turno.cola_si_secunda(aliado_id)).is_empty()
	assert_array(_orden(cola.entradas())).is_equal(orden)
	assert_int(cola.lugar()).is_equal(lugar)
	assert_str(_foto(plantel)).is_equal(foto)
	assert_bool(turno.terminado).is_false()


# (1) Sistema.md 10.1, Prueba C: la cola es Zancajunco, Tasajero (Caza), Ocarra,
# Rodauva, Maestro. El Zancajunco Secunda a la Ocarra: el Tasajero y la Ocarra
# actuan antes que el, y el resto no se reordena.
func test_prueba_c() -> void:
	var plantel: Plantel = _plantel()
	var cola: ColaIniciativa = _cola(plantel)
	assert_array(_orden(cola.entradas())).is_equal(["zancajunco_1", "tasajero_s1:caza", "ocarra_1", "rodauva_1",
			Maestro.ID])
	var turno: Turno = _siguiente(cola, plantel)
	assert_str(turno.unidad_id).is_equal("zancajunco_1")
	_aplicar_valida(turno, Accion.secundar("ocarra_1"))
	assert_bool(turno.terminado).is_true()
	assert_array(_orden(cola.entradas())).is_equal(["tasajero_s1:caza", "ocarra_1", "zancajunco_1", "rodauva_1",
			Maestro.ID])
	assert_str(cola.siguiente(plantel).unidad_id).is_equal("tasajero_s1")
	assert_str(cola.siguiente(plantel).unidad_id).is_equal("ocarra_1")
	var vuelta: EntradaCola = cola.siguiente(plantel)
	assert_str(vuelta.unidad_id).is_equal("zancajunco_1")
	assert_bool(vuelta.vuelve).is_true()
	assert_str(cola.siguiente(plantel).unidad_id).is_equal("rodauva_1")
	assert_str(cola.siguiente(plantel).unidad_id).is_equal(Maestro.ID)
	assert_object(cola.siguiente(plantel)).is_null()


# (1) Lo mismo con el Combate: el Tasajero juega su turno antes de que vuelva el Zancajunco.
func test_prueba_c_con_el_combate() -> void:
	var combate: Combate = _combate(_escenario())
	assert_str(combate.turno_actual().unidad_id).is_equal("zancajunco_1")
	_aplicar_combate(combate, Accion.secundar("ocarra_1"))
	assert_str(combate.turno_actual().unidad_id).is_equal("ocarra_1")
	var turnos: Array = []
	for linea in combate.registro().lineas():
		if linea["tipo"] == "turno" or linea["tipo"] == "turno_vuelve":
			turnos.append(linea["unidad"])
	assert_array(turnos).is_equal(["zancajunco_1", "tasajero_s1", "ocarra_1"])
	_aplicar_combate(combate, Accion.terminar())
	assert_str(combate.turno_actual().unidad_id).is_equal("zancajunco_1")


# (2) Sistema.md 10.1: Secundar a la ultima aliada pendiente la deja ultima de
# la ronda ("no mas alla del final de la ronda" sale solo).
func test_detras_de_la_ultima() -> void:
	var plantel: Plantel = _plantel()
	var cola: ColaIniciativa = _cola(plantel)
	_aplicar_valida(_siguiente(cola, plantel), Accion.secundar(Maestro.ID))
	assert_array(_orden(cola.entradas())).is_equal(["tasajero_s1:caza", "ocarra_1", "rodauva_1", Maestro.ID,
			"zancajunco_1"])
	for unidad_id in ["tasajero_s1", "ocarra_1", "rodauva_1", Maestro.ID]:
		assert_str(cola.siguiente(plantel).unidad_id).is_equal(unidad_id)
	assert_str(cola.siguiente(plantel).unidad_id).is_equal("zancajunco_1")
	assert_object(cola.siguiente(plantel)).is_null()
	assert_bool(cola.ronda_terminada()).is_true()


# (3) Sistema.md 10.1 y S-29: rechazos con su motivo y sin cambiar nada.
func test_rechazos() -> void:
	var plantel: Plantel = _plantel()
	var cola: ColaIniciativa = _cola(plantel)
	var zancajunco: Turno = _siguiente(cola, plantel)
	_assert_rechazo(zancajunco, cola, plantel, "tasajero_s1", ResultadoAccion.Motivo.ALIADA_DE_OTRO_BANDO)
	_assert_rechazo(zancajunco, cola, plantel, "zancajunco_1", ResultadoAccion.Motivo.SECUNDAR_A_SI_MISMA)
	_assert_rechazo(zancajunco, cola, plantel, "nadie", ResultadoAccion.Motivo.OBJETIVO_INEXISTENTE)
	# Caida a mitad de ronda: tiene entrada, pero ya no puede actuar.
	plantel.criatura("rodauva_1").estado = Criatura.Estado.CAIDA
	_assert_rechazo(zancajunco, cola, plantel, "rodauva_1", ResultadoAccion.Motivo.ALIADA_SIN_ENTRADA_PENDIENTE)
	plantel.criatura("rodauva_1").estado = Criatura.Estado.SUELTA
	_aplicar_valida(zancajunco, Accion.terminar())

	# Una salvaje no Secunda (Sistema.md 10.1), ni a otra salvaje.
	var tasajero: Turno = _siguiente(cola, plantel)
	assert_str(tasajero.unidad_id).is_equal("tasajero_s1")
	assert_bool(tasajero.puede_secundar()).is_false()
	assert_array(tasajero.aliadas_para_secundar()).is_empty()
	_assert_rechazo(tasajero, cola, plantel, "tasajero_s1", ResultadoAccion.Motivo.SALVAJE_NO_SECUNDA)
	_assert_rechazo(tasajero, cola, plantel, "ocarra_1", ResultadoAccion.Motivo.SALVAJE_NO_SECUNDA)
	_aplicar_valida(tasajero, Accion.terminar())

	# Una aliada que ya actuo.
	var ocarra: Turno = _siguiente(cola, plantel)
	_assert_rechazo(ocarra, cola, plantel, "zancajunco_1", ResultadoAccion.Motivo.ALIADA_SIN_ENTRADA_PENDIENTE)

	# Despues de mover (S-29).
	_aplicar_valida(ocarra, Accion.mover(Vector2i(3, 5)))
	_assert_rechazo(ocarra, cola, plantel, "rodauva_1", ResultadoAccion.Motivo.YA_SE_MOVIO)
	assert_array(ocarra.aliadas_para_secundar()).is_empty()


# (3) Despues de atacar (S-29) y a una guardada, que no esta en la cola.
func test_rechazos_despues_de_atacar_y_guardada() -> void:
	var escenario: Dictionary = _escenario()
	(escenario["tribu"] as Array)[0]["estado"] = "guardada"
	var plantel: Plantel = _plantel(escenario)
	plantel.criatura("tasajero_s1").posicion = Vector2i(4, 5)
	var cola: ColaIniciativa = _cola(plantel)
	var zancajunco: Turno = _siguiente(cola, plantel)
	_assert_rechazo(zancajunco, cola, plantel, "rodauva_1", ResultadoAccion.Motivo.ALIADA_SIN_ENTRADA_PENDIENTE)
	assert_array(zancajunco.aliadas_para_secundar()).is_equal([Maestro.ID, "ocarra_1"])
	_aplicar_valida(zancajunco, Accion.atacar("tasajero_s1"))
	_assert_rechazo(zancajunco, cola, plantel, "ocarra_1", ResultadoAccion.Motivo.ACCION_USADA)
	assert_bool(zancajunco.puede_secundar()).is_false()


# (4) S-30 (P-032): al volver se puede Secundar otra vez si queda otra aliada
# pendiente detras; la entrada siempre avanza.
func test_volver_a_secundar() -> void:
	var plantel: Plantel = _plantel()
	var cola: ColaIniciativa = _cola(plantel)
	_aplicar_valida(_siguiente(cola, plantel), Accion.secundar("ocarra_1"))
	_aplicar_valida(_siguiente(cola, plantel), Accion.terminar())
	_aplicar_valida(_siguiente(cola, plantel), Accion.terminar())
	var vuelta: Turno = _siguiente(cola, plantel)
	assert_str(vuelta.unidad_id).is_equal("zancajunco_1")
	assert_array(vuelta.aliadas_para_secundar()).is_equal([Maestro.ID, "rodauva_1"])
	_assert_rechazo(vuelta, cola, plantel, "ocarra_1", ResultadoAccion.Motivo.ALIADA_SIN_ENTRADA_PENDIENTE)
	_aplicar_valida(vuelta, Accion.secundar("rodauva_1"))
	assert_array(_orden(cola.entradas())).is_equal(["tasajero_s1:caza", "ocarra_1", "rodauva_1", "zancajunco_1",
			Maestro.ID])
	assert_str(cola.siguiente(plantel).unidad_id).is_equal("rodauva_1")
	assert_str(cola.siguiente(plantel).unidad_id).is_equal("zancajunco_1")


# (4) Sin ninguna aliada pendiente detras, no vale.
func test_volver_sin_aliada_detras() -> void:
	var plantel: Plantel = _plantel()
	var cola: ColaIniciativa = _cola(plantel)
	_aplicar_valida(_siguiente(cola, plantel), Accion.secundar(Maestro.ID))
	for i in range(4):
		_aplicar_valida(_siguiente(cola, plantel), Accion.terminar())
	var vuelta: Turno = _siguiente(cola, plantel)
	assert_str(vuelta.unidad_id).is_equal("zancajunco_1")
	assert_bool(vuelta.puede_secundar()).is_true()
	assert_array(vuelta.aliadas_para_secundar()).is_empty()
	_assert_rechazo(vuelta, cola, plantel, Maestro.ID, ResultadoAccion.Motivo.ALIADA_SIN_ENTRADA_PENDIENTE)
	_aplicar_valida(vuelta, Accion.terminar())
	assert_bool(cola.ronda_terminada()).is_true()


# (5) S-31 (P-033), Sistema.md 11.2 y 11.3: el borrado de Erizarse es del inicio
# del turno y corre una sola vez por ronda. La Rodauva erizada de la ronda
# anterior pierde la marca al empezar; si algo la vuelve a poner entre medio
# (el test, a mano), al volver no se borra otra vez.
func test_s31_erizarse_una_vez() -> void:
	var plantel: Plantel = _plantel()
	plantel.criatura("rodauva_1").erizada = true
	var cola: ColaIniciativa = _cola(plantel)
	for i in range(3):
		_aplicar_valida(_siguiente(cola, plantel), Accion.terminar())
	var rodauva: Turno = _siguiente(cola, plantel)
	assert_str(rodauva.unidad_id).is_equal("rodauva_1")
	assert_bool(plantel.criatura("rodauva_1").erizada).is_false()
	_aplicar_valida(rodauva, Accion.secundar(Maestro.ID))
	plantel.criatura("rodauva_1").erizada = true
	_aplicar_valida(_siguiente(cola, plantel), Accion.terminar())
	var vuelta: Turno = _siguiente(cola, plantel)
	assert_str(vuelta.unidad_id).is_equal("rodauva_1")
	assert_bool(plantel.criatura("rodauva_1").erizada).is_true()


# (5) S-31, Sistema.md 11.2.3: el cambio a Cuenta se evalua una sola vez por
# ronda. El Tasajero de la tribu (escenario_caza_tribu, como en T36) Secunda al
# Maestro en Caza; entre medio queda en su vida de cambio: al volver sigue en
# Caza. Una entrada nueva con la misma vida si cambia.
func test_s31_cambio_de_modo_una_vez() -> void:
	var plantel: Plantel = _plantel(_escenario("escenario_caza_tribu.json"))
	var cola: ColaIniciativa = _cola(plantel)
	assert_array(_orden(cola.entradas())).is_equal(["tasajero_1:caza", "ocarra_s1", "rodauva_s1", Maestro.ID])
	var tasajero: Turno = _siguiente(cola, plantel)
	assert_dict(tasajero.cambio_modo).is_empty()
	_aplicar_valida(tasajero, Accion.secundar(Maestro.ID))
	var criatura: Criatura = plantel.criatura("tasajero_1")
	criatura.vida = CambioModo.vida_de_cambio(criatura)
	for i in range(3):
		_aplicar_valida(_siguiente(cola, plantel), Accion.terminar())
	var vuelta: Turno = _siguiente(cola, plantel)
	assert_str(vuelta.unidad_id).is_equal("tasajero_1")
	assert_str(vuelta.marca).is_equal("caza")
	assert_dict(vuelta.cambio_modo).is_empty()
	assert_str(criatura.modo).is_equal("caza")
	assert_int(vuelta.ataques_restantes).is_equal(criatura.especie.ataques_por_turno("caza"))

	var nueva: Turno = Turno.empezar(EntradaCola.new("tasajero_1", "caza", 0), plantel, _tablero, Surcos.new(),
			DatosFixture.cadena(), ColaIniciativa.new(), DatosFixture.reglas(), GeneradorAzar.new(1))
	assert_dict(nueva.cambio_modo).is_equal({"de": "caza", "a": "cuenta"})


# --- Con el Combate ---

func _datos() -> Dictionary:
	var lectura: Dictionary = DatosFixture.cargar()
	var errores: Array[Dictionary] = lectura["errores"]
	assert_array(errores).override_failure_message(str(errores)).is_empty()
	return lectura["datos"]


func _combate(escenario: Dictionary) -> Combate:
	var contexto: ContextoCombate = ContextoCombate.armar(escenario, _datos())
	assert_bool(contexto.valido).is_true()
	var combate: Combate = Combate.empezar(contexto)
	assert_str(combate.error()).is_empty()
	return combate


func _aplicar_combate(combate: Combate, accion: Accion) -> ResultadoAccion:
	var resultado: ResultadoAccion = combate.aplicar(accion)
	assert_bool(resultado.valida).override_failure_message("%s %s: %s" % [combate.turno_actual().unidad_id,
			str(accion.a_diccionario()), ResultadoAccion.Motivo.keys()[resultado.motivo]]).is_true()
	assert_str(combate.error()).is_empty()
	return resultado


func _de_tipo(combate: Combate, tipo: String) -> Array[Dictionary]:
	var resultado: Array[Dictionary] = []
	for linea in combate.registro().lineas():
		if linea["tipo"] == tipo:
			resultado.append(linea)
	return resultado


# (6) Sistema.md 10.2: Secundar no es un ataque y no corta. En
# escenario_cadena_combate (cola zancajunco_1, ocarra_1, rodauva_s1, Maestro...;
# rodauva_s1 encerrada solo espera), el Zancajunco Secunda a la Ocarra: la Ocarra
# pega a surcon_s1 y el Zancajunco pega despues, sin enemigas en el medio:
# eslabon 2.
func test_cadena_sin_enemigas_en_el_medio() -> void:
	var combate: Combate = _combate(_escenario("escenario_cadena_combate.json"))
	_aplicar_combate(combate, Accion.secundar("ocarra_1"))
	assert_str(combate.turno_actual().unidad_id).is_equal("ocarra_1")
	assert_that(_aplicar_combate(combate, Accion.atacar("surcon_s1")).eslabon).is_equal(1)
	_aplicar_combate(combate, Accion.terminar())
	assert_str(combate.turno_actual().unidad_id).is_equal("zancajunco_1")
	assert_that(_aplicar_combate(combate, Accion.atacar("surcon_s1")).eslabon).is_equal(2)
	assert_array(_de_tipo(combate, "cadena_cortada")).is_empty()


# (6) Con una enemiga que actua en el medio, se corta. El Zancajunco Secunda al
# Maestro: la Ocarra pega, rodauva_s1 juega (corta, `enemiga`), el Maestro
# empieza otra cadena y el Zancajunco, justo detras, la sigue: eslabon 2.
func test_cadena_con_enemiga_en_el_medio() -> void:
	var combate: Combate = _combate(_escenario("escenario_cadena_combate.json"))
	_aplicar_combate(combate, Accion.secundar(Maestro.ID))
	assert_that(_aplicar_combate(combate, Accion.atacar("surcon_s1")).eslabon).is_equal(1)
	_aplicar_combate(combate, Accion.terminar())
	assert_str(combate.turno_actual().unidad_id).is_equal(Maestro.ID)
	var cortes: Array[Dictionary] = _de_tipo(combate, "cadena_cortada")
	assert_int(cortes.size()).is_equal(1)
	assert_str(cortes[0]["motivo"]).is_equal(Cadena.MOTIVO_ENEMIGA)
	assert_array(cortes[0]["participantes"]).is_equal(["ocarra_1"])
	assert_that(_aplicar_combate(combate, Accion.atacar("surcon_s1")).eslabon).is_equal(1)
	_aplicar_combate(combate, Accion.terminar())
	assert_str(combate.turno_actual().unidad_id).is_equal("zancajunco_1")
	assert_that(_aplicar_combate(combate, Accion.atacar("surcon_s1")).eslabon).is_equal(2)


# (7) Calcular sin aplicar: cola_si_secunda da la misma cola que aplicar y no
# cambia la instantanea ni la cola del Combate.
func test_cola_si_secunda() -> void:
	var combate: Combate = _combate(_escenario())
	var turno: Turno = combate.turno_actual()
	var antes: Dictionary = combate.instantanea()
	var cola_antes: Array[String] = _orden(combate.cola())
	var prevista: Array[String] = _orden(turno.cola_si_secunda("ocarra_1"))
	assert_array(prevista).is_equal(["tasajero_s1:caza", "ocarra_1", "zancajunco_1", "rodauva_1", Maestro.ID])
	assert_array(_orden(turno.cola_si_secunda(Maestro.ID))).is_equal(["tasajero_s1:caza", "ocarra_1",
			"rodauva_1", Maestro.ID, "zancajunco_1"])
	assert_array(turno.cola_si_secunda("tasajero_s1")).is_empty()
	assert_dict(combate.instantanea()).is_equal(antes)
	assert_array(_orden(combate.cola())).is_equal(cola_antes)
	assert_bool(combate.cola()[0].actuo).is_true()
	assert_bool(combate.cola()[0].vuelve).is_false()

	_aplicar_combate(combate, Accion.secundar("ocarra_1"))
	assert_array(_orden(combate.cola())).is_equal(prevista)


# (8) Arquitectura.md A.7: evento `secundar` (unidad, detras_de, lugar nuevo en
# la cola, desde 0) y `turno_vuelve` cuando le toca de nuevo, sin otro `turno`
# ni `fin_turno` en el medio; la grabacion valida con el tipo nuevo y se
# reproduce igual.
func test_registro_y_grabacion() -> void:
	var combate: Combate = _combate(_escenario())
	_aplicar_combate(combate, Accion.secundar("ocarra_1"))
	var eventos: Array[Dictionary] = _de_tipo(combate, "secundar")
	assert_int(eventos.size()).is_equal(1)
	var evento: Dictionary = eventos[0].duplicate()
	evento.erase("n")
	assert_dict(evento).is_equal({"tipo": "secundar", "unidad": "zancajunco_1", "detras_de": "ocarra_1",
			"lugar": 2, "ronda": 1})
	_aplicar_combate(combate, Accion.terminar())
	assert_str(combate.turno_actual().unidad_id).is_equal("zancajunco_1")

	var tipos: Array = []
	for linea in combate.registro().lineas():
		if linea.get("unidad") == "zancajunco_1" and linea["tipo"] != "accion":
			tipos.append(linea["tipo"])
	assert_array(tipos).is_equal(["turno", "secundar", "turno_vuelve"])
	assert_int(_de_tipo(combate, "turno_vuelve").size()).is_equal(1)
	_aplicar_combate(combate, Accion.terminar())

	var grabacion: Dictionary = Grabacion.desde_combate(combate).a_diccionario()
	var esquema: Dictionary = Cargador.new().esquema_resuelto(_CARPETA_DATOS, "grabacion")["esquema"]
	var errores: Array[Dictionary] = Validador.new().validar(grabacion, esquema, "grabacion")["errores"]
	assert_array(errores).override_failure_message(str(errores)).is_empty()
	assert_dict((grabacion["acciones"] as Array)[0]).is_equal({"unidad": "zancajunco_1",
			"accion": {"tipo": "secundar", "aliado": "ocarra_1"}})
	var reproduccion: Reproductor = Reproductor.reproducir(Grabacion.desde_diccionario(grabacion), _datos())
	assert_str(reproduccion.error).is_empty()
	assert_array(reproduccion.combate.registro().lineas_json()).is_equal(combate.registro().lineas_json())


# (8) La accion, ida y vuelta por diccionario.
func test_accion_ida_y_vuelta() -> void:
	var accion: Accion = Accion.desde_diccionario(Accion.secundar("ocarra_1").a_diccionario())
	assert_int(accion.tipo).is_equal(Accion.Tipo.SECUNDAR)
	assert_str(accion.aliado_id).is_equal("ocarra_1")
	assert_dict(Accion.secundar("ocarra_1").a_diccionario()).is_equal({"tipo": "secundar", "aliado": "ocarra_1"})
	assert_object(Accion.desde_diccionario({"tipo": "secundar"})).is_null()
	assert_object(Accion.desde_diccionario({"tipo": "secundar", "aliado": 3})).is_null()
	assert_object(Accion.desde_diccionario({"tipo": "secundar", "aliado": "ocarra_1", "objetivo": "x"})).is_null()


# Arquitectura.md, principio 2: Secundar no usa azar.
func test_sin_azar() -> void:
	for ruta in _FUENTES:
		var codigo: String = FileAccess.get_file_as_string(ruta)
		for prohibido in _AZAR_PROHIBIDO:
			assert_str(codigo).not_contains(prohibido)
