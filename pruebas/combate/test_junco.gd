extends GdUnitTestSuite

# Arquitectura.md B.2.1 (T38): Hacerse junco, "oculto" y la consulta unica de
# objetivo, con fixtures (A.6). Un test por renglon del criterio de terminado:
# Sistema.md 11.2.2 (v1.4), 10.5 (rival oculta), 11.3, 11.4 y A.7 (eventos
# oculto, destape y bono_perdido).
const _CARPETA: String = "res://pruebas/fixtures/combate/"
const _CARPETA_UNIDADES: String = "res://pruebas/fixtures/unidades/"
const _CARPETA_DATOS: String = "res://datos"
const _ESPECIES: Array[String] = ["ocarra", "rodauva", "surcon", "tasajero", "zancajunco"]
const _JUNCO: String = "zancajunco_1"
const _JUNCO_SALVAJE: String = "zancajunco_s1"

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


# escenario_junco.json: Zancajunco [3,4] y Rodauva [3,5] de la tribu; Rodauva
# salvaje [3,1] y Ocarra salvaje [6,4]. escenario_junco_salvaje.json: Zancajunco
# salvaje [3,2]; Rodauva [3,5] y Tasajero [6,2] de la tribu.
func _plantel(nombre: String = "escenario_junco") -> Plantel:
	var especies: Dictionary = {}
	for id_especie in _ESPECIES:
		especies[id_especie] = Especie.new(_leer(_CARPETA_UNIDADES + id_especie + ".json", "especie"))
	var tabla: TablaBalanza = TablaBalanza.new(_leer(_CARPETA_UNIDADES + "balanza_1_2.json", "balanza"))
	return Plantel.desde_escenario(_leer(_CARPETA + nombre + ".json", "escenario"), especies, tabla,
			_leer(_CARPETA_UNIDADES + "maestro.json", "maestro"))


# Turno suelto, sin cola y sin surcos.
func _turno(plantel: Plantel, unidad_id: String) -> Turno:
	return Turno.empezar(EntradaCola.new(unidad_id, "", 0), plantel, _tablero, _danio, Surcos.new(),
			DatosFixture.afinidad(), DatosFixture.cadena(), ColaIniciativa.new(), DatosFixture.incidente(), GeneradorAzar.new(1))


# Un turno entero que se oculta y termina.
func _ocultar(plantel: Plantel, unidad_id: String) -> Turno:
	var turno: Turno = _turno(plantel, unidad_id)
	_assert_valida(turno.aplicar(Accion.hacerse_junco()))
	_assert_valida(turno.aplicar(Accion.terminar()))
	return turno


# Un turno entero que solo espera.
func _esperar(plantel: Plantel, unidad_id: String) -> void:
	_assert_valida(_turno(plantel, unidad_id).aplicar(Accion.terminar()))


# Todo lo que una accion puede cambiar: Plantel, turno y sus eventos.
func _foto(plantel: Plantel, turno: Turno) -> String:
	return str([plantel.instantanea(), turno.eventos(), turno.pasos_restantes, turno.ataques_restantes,
			turno.movimiento_usado, turno.accion_usada, turno.terminado, turno.se_movio])


# Valida sin aplicar y comprueba que no cambio nada.
func _validar(plantel: Plantel, turno: Turno, accion: Accion) -> ResultadoAccion:
	var antes: String = _foto(plantel, turno)
	var resultado: ResultadoAccion = turno.validar(accion)
	assert_str(_foto(plantel, turno)).is_equal(antes)
	return resultado


func _assert_valida(resultado: ResultadoAccion) -> void:
	assert_bool(resultado.valida).override_failure_message("motivo: " + ResultadoAccion.Motivo.keys()[resultado.motivo]).is_true()


func _assert_rechazada(resultado: ResultadoAccion, motivo: ResultadoAccion.Motivo) -> void:
	assert_bool(resultado.valida).is_false()
	assert_str(ResultadoAccion.Motivo.keys()[resultado.motivo]).is_equal(ResultadoAccion.Motivo.keys()[motivo])


func _assert_estado_junco(plantel: Plantel, unidad_id: String, oculta: bool, bono: bool) -> void:
	assert_bool(plantel.criatura(unidad_id).oculta).override_failure_message("oculta de " + unidad_id).is_equal(oculta)
	assert_bool(plantel.criatura(unidad_id).bono_junco).override_failure_message("bono de " + unidad_id).is_equal(bono)


func _modificador(desglose: DesgloseDanio, fuente: ModificadorDanio.Fuente) -> ModificadorDanio:
	for modificador in desglose.modificadores:
		if modificador.fuente == fuente:
			return modificador
	return null


# (1) Activar (11.2.2): gasta la accion, solo sin haberse movido y sin ninguna
# enemiga de pie adyacente; no dos turnos seguidos; cierra el movimiento (S-26).
func test_activar() -> void:
	# Despues de moverse, no.
	var plantel: Plantel = _plantel()
	var turno: Turno = _turno(plantel, _JUNCO)
	_assert_valida(turno.aplicar(Accion.mover(Vector2i(2, 4))))
	_assert_rechazada(_validar(plantel, turno, Accion.hacerse_junco()), ResultadoAccion.Motivo.YA_SE_MOVIO)

	# Con una enemiga de pie adyacente, no; si esta caida, si.
	plantel = _plantel()
	plantel.criatura("rodauva_s1").posicion = Vector2i(4, 4)
	_assert_rechazada(_validar(plantel, _turno(plantel, _JUNCO), Accion.hacerse_junco()),
			ResultadoAccion.Motivo.ENEMIGA_ADYACENTE)
	plantel.criatura("rodauva_s1").estado = Criatura.Estado.CAIDA
	_assert_valida(_validar(plantel, _turno(plantel, _JUNCO), Accion.hacerse_junco()))

	# Con una aliada adyacente (la Rodauva [3,5]), si: queda oculta y con el bono.
	plantel = _plantel()
	turno = _turno(plantel, _JUNCO)
	_assert_valida(_validar(plantel, turno, Accion.hacerse_junco()))
	_assert_valida(turno.aplicar(Accion.hacerse_junco()))
	_assert_estado_junco(plantel, _JUNCO, true, true)
	assert_bool(turno.accion_usada).is_true()
	# Cierra el movimiento que quede y gasta la accion; terminar no es esperar.
	_assert_rechazada(turno.validar(Accion.mover(Vector2i(2, 4))), ResultadoAccion.Motivo.MOVIMIENTO_USADO)
	assert_array(turno.casillas_para_mover()).is_empty()
	_assert_rechazada(turno.validar(Accion.atacar("rodauva_s1")), ResultadoAccion.Motivo.ACCION_USADA)
	_assert_rechazada(turno.validar(Accion.hacerse_junco()), ResultadoAccion.Motivo.ACCION_USADA)
	var fin: ResultadoAccion = turno.aplicar(Accion.terminar())
	_assert_valida(fin)
	assert_bool(fin.espero).is_false()

	# No dos turnos seguidos; al siguiente, si.
	turno = _turno(plantel, _JUNCO)
	_assert_rechazada(_validar(plantel, turno, Accion.hacerse_junco()), ResultadoAccion.Motivo.JUNCO_TURNO_ANTERIOR)
	_assert_valida(turno.aplicar(Accion.terminar()))
	_assert_valida(_turno(plantel, _JUNCO).validar(Accion.hacerse_junco()))

	# Sin el efecto ocultarse, no.
	_assert_rechazada(_turno(plantel, "rodauva_1").validar(Accion.hacerse_junco()), ResultadoAccion.Motivo.SIN_RASGO)


# (2) Oculto (11.2.2, S-21): no es objetivo de un ataque, no aparece en
# objetivos_para_atacar y la IA no la elige.
func test_no_es_objetivo_hostil() -> void:
	var plantel: Plantel = _plantel()
	# Sin ocultarse, el Zancajunco es la mas cercana de las dos salvajes.
	assert_str(IASalvaje.decidir(_turno(plantel, "ocarra_s1"), plantel, _cola(plantel)).objetivo_id).is_equal(_JUNCO)
	assert_str(IASalvaje.decidir(_turno(plantel, "rodauva_s1"), plantel, _cola(plantel)).objetivo_id).is_equal(_JUNCO)

	_ocultar(plantel, _JUNCO)
	plantel.criatura("rodauva_s1").posicion = Vector2i(3, 3)
	var turno: Turno = _turno(plantel, "rodauva_s1")
	_assert_rechazada(_validar(plantel, turno, Accion.atacar(_JUNCO)), ResultadoAccion.Motivo.OBJETIVO_OCULTO)
	assert_array(turno.objetivos_para_atacar()).not_contains([_JUNCO])
	assert_bool(turno.previsualizar_ataque(Vector2i(3, 3), _JUNCO).valida).is_false()
	plantel.criatura("rodauva_s1").posicion = Vector2i(3, 1)

	# La Ocarra va por la Rodauva de la tribu; la Rodauva salvaje no llega a
	# nadie y se acerca a la Rodauva de la tribu, no al Zancajunco.
	var decision: DecisionIA = IASalvaje.decidir(_turno(plantel, "ocarra_s1"), plantel, _cola(plantel))
	assert_int(decision.paso).is_equal(DecisionIA.Paso.CERCANA)
	assert_str(decision.objetivo_id).is_equal("rodauva_1")
	decision = IASalvaje.decidir(_turno(plantel, "rodauva_s1"), plantel, _cola(plantel))
	assert_int(decision.paso).is_equal(DecisionIA.Paso.ACERCARSE)
	assert_str(decision.objetivo_id).is_equal("rodauva_1")


func _cola(plantel: Plantel) -> ColaIniciativa:
	var cola: ColaIniciativa = ColaIniciativa.new()
	cola.empezar_ronda(plantel)
	return cola


# (3) Sigue visible y ocupa su casilla (11.2.2, 11.3): una enemiga no la
# atraviesa ni termina en ella.
func test_ocupa_su_casilla() -> void:
	var plantel: Plantel = _plantel()
	_ocultar(plantel, _JUNCO)
	plantel.criatura("rodauva_1").posicion = Vector2i(5, 6)
	plantel.criatura("rodauva_s1").posicion = Vector2i(3, 2)
	var pasos: Dictionary = _tablero.pasos_hasta(Vector2i(3, 2), 4, Criatura.Bando.ENEMIGA, plantel, Surcos.new(), false)
	assert_bool(pasos.has(Vector2i(3, 4))).is_false()
	# Detras del Zancajunco: 3 pasos sin el, 5 rodeandolo.
	assert_bool(pasos.has(Vector2i(3, 5))).is_false()
	var turno: Turno = _turno(plantel, "rodauva_s1")
	_assert_rechazada(turno.validar(Accion.mover(Vector2i(3, 4))), ResultadoAccion.Motivo.CASILLA_NO_ALCANZABLE)
	_assert_rechazada(turno.validar(Accion.mover(Vector2i(3, 5))), ResultadoAccion.Motivo.CASILLA_NO_ALCANZABLE)


# (4) Bono (11.2.2, 11.4 paso 3): su proximo ataque suma +3. El Zancajunco (4)
# pega 7, y 4 en el siguiente. Ocultarse otra vez con el bono no lo suma dos veces.
func test_bono() -> void:
	var plantel: Plantel = _plantel()
	_ocultar(plantel, _JUNCO)
	var turno: Turno = _turno(plantel, _JUNCO)
	_assert_valida(turno.aplicar(Accion.mover(Vector2i(5, 4))))
	var golpe: ResultadoAccion = turno.aplicar(Accion.atacar("ocarra_s1"))
	_assert_valida(golpe)
	assert_int(golpe.danio).is_equal(7)
	var bono: ModificadorDanio = _modificador(golpe.desglose, ModificadorDanio.Fuente.RASGO_ATACANTE)
	assert_object(bono).is_not_null()
	assert_int(bono.tipo).is_equal(ModificadorDanio.Tipo.PLANO)
	assert_int(bono.valor).is_equal(3)
	assert_str(bono.detalle).is_equal("hacerse_junco")
	assert_int(plantel.criatura("ocarra_s1").vida).is_equal(5)
	_assert_valida(turno.aplicar(Accion.terminar()))
	golpe = _turno(plantel, _JUNCO).aplicar(Accion.atacar("ocarra_s1"))
	assert_int(golpe.danio).is_equal(4)
	assert_object(_modificador(golpe.desglose, ModificadorDanio.Fuente.RASGO_ATACANTE)).is_null()

	# Oculto, se mueve (conserva el bono), se oculta otra vez con el bono y pega 7, no 10.
	plantel = _plantel()
	_ocultar(plantel, _JUNCO)
	turno = _turno(plantel, _JUNCO)
	_assert_valida(turno.aplicar(Accion.mover(Vector2i(3, 3))))
	_assert_valida(turno.aplicar(Accion.terminar()))
	_ocultar(plantel, _JUNCO)
	_assert_estado_junco(plantel, _JUNCO, true, true)
	turno = _turno(plantel, _JUNCO)
	_assert_valida(turno.aplicar(Accion.mover(Vector2i(3, 2))))
	golpe = turno.aplicar(Accion.atacar("rodauva_s1"))
	assert_int(golpe.danio).is_equal(7)
	assert_int(plantel.criatura("rodauva_s1").vida).is_equal(1)


# (5) Moverse (11.2.2): lo destapa, pero conserva el bono.
func test_mover_destapa_y_conserva() -> void:
	var plantel: Plantel = _plantel()
	var oculto: Turno = _ocultar(plantel, _JUNCO)
	assert_array(oculto.eventos()).is_equal([{"tipo": "oculto", "unidad": _JUNCO}])
	var turno: Turno = _turno(plantel, _JUNCO)
	_assert_valida(_validar(plantel, turno, Accion.mover(Vector2i(2, 4))))
	_assert_valida(turno.aplicar(Accion.mover(Vector2i(2, 4))))
	_assert_estado_junco(plantel, _JUNCO, false, true)
	assert_array(turno.eventos()).is_equal([{"tipo": "destape", "unidad": _JUNCO, "motivo": "mover", "por": null}])


# (6) Ataca (11.2.2): lo destapa y el bono se cobra en ese golpe. Validar y
# previsualizar no lo gastan.
func test_atacar_destapa_y_cobra() -> void:
	var plantel: Plantel = _plantel()
	_ocultar(plantel, _JUNCO)
	# La Ocarra queda adyacente sin moverse (no hay revision de contacto).
	plantel.criatura("ocarra_s1").posicion = Vector2i(4, 4)
	var turno: Turno = _turno(plantel, _JUNCO)
	assert_int(_validar(plantel, turno, Accion.atacar("ocarra_s1")).danio).is_equal(7)
	var antes: String = _foto(plantel, turno)
	assert_int(turno.previsualizar_ataque(Vector2i(3, 4), "ocarra_s1").danio).is_equal(7)
	assert_int(turno.previsualizar_ataque(Vector2i(4, 3), "ocarra_s1").danio).is_equal(7)
	assert_str(_foto(plantel, turno)).is_equal(antes)
	_assert_estado_junco(plantel, _JUNCO, true, true)

	var golpe: ResultadoAccion = turno.aplicar(Accion.atacar("ocarra_s1"))
	assert_int(golpe.danio).is_equal(7)
	_assert_estado_junco(plantel, _JUNCO, false, false)
	assert_array(turno.eventos()).is_equal([{"tipo": "destape", "unidad": _JUNCO, "motivo": "atacar", "por": null}])


# (7) Destape por contacto (11.2.2, S-24): una enemiga de pie que termina su
# movimiento al lado lo destapa; una que pasa al lado por el camino, no.
func test_contacto() -> void:
	var plantel: Plantel = _plantel()
	_ocultar(plantel, _JUNCO)
	# La Rodauva salvaje va de [3,2] a [4,5]: el camino pasa por [4,4], al lado.
	plantel.criatura("rodauva_s1").posicion = Vector2i(3, 2)
	var turno: Turno = _turno(plantel, "rodauva_s1")
	_assert_valida(turno.aplicar(Accion.mover(Vector2i(4, 5))))
	_assert_estado_junco(plantel, _JUNCO, true, true)
	assert_array(turno.eventos()).is_empty()

	# La Ocarra termina en [4,4]: lo destapa, y conserva el bono.
	turno = _turno(plantel, "ocarra_s1")
	_assert_valida(_validar(plantel, turno, Accion.mover(Vector2i(4, 4))))
	_assert_valida(turno.aplicar(Accion.mover(Vector2i(4, 4))))
	_assert_estado_junco(plantel, _JUNCO, false, true)
	assert_array(turno.eventos()).is_equal([{"tipo": "destape", "unidad": _JUNCO, "motivo": "contacto", "por": "ocarra_s1"}])


# (8) Pierde el bono (11.2.2): si recibe un ataque despues de destapado y antes
# de atacar. Validar ese ataque no lo quita.
func test_pierde_el_bono() -> void:
	var plantel: Plantel = _plantel()
	_ocultar(plantel, _JUNCO)
	var turno: Turno = _turno(plantel, _JUNCO)
	_assert_valida(turno.aplicar(Accion.mover(Vector2i(3, 3))))
	_assert_valida(turno.aplicar(Accion.terminar()))
	_assert_estado_junco(plantel, _JUNCO, false, true)

	turno = _turno(plantel, "rodauva_s1")
	_assert_valida(turno.aplicar(Accion.mover(Vector2i(3, 2))))
	_assert_valida(_validar(plantel, turno, Accion.atacar(_JUNCO)))
	_assert_estado_junco(plantel, _JUNCO, false, true)
	var golpe: ResultadoAccion = turno.aplicar(Accion.atacar(_JUNCO))
	assert_int(golpe.danio).is_equal(2)
	assert_int(plantel.criatura(_JUNCO).vida).is_equal(10)
	_assert_estado_junco(plantel, _JUNCO, false, false)
	assert_array(turno.eventos()).is_equal([{"tipo": "bono_perdido", "unidad": _JUNCO, "atacante": "rodauva_s1"}])


# (9) Acciones aliadas (S-22): el Remiendo de una aliada vale sobre una oculta.
# Solo la consulta: el hechizo es de T22.
func test_aliada_vale_sobre_oculta() -> void:
	var plantel: Plantel = _plantel()
	_ocultar(plantel, _JUNCO)
	assert_bool(Objetivos.puede_ser_objetivo(_JUNCO, Objetivos.Clase.ALIADA, plantel)).is_true()
	assert_bool(Objetivos.puede_ser_objetivo(_JUNCO, Objetivos.Clase.HOSTIL, plantel)).is_false()
	assert_int(Objetivos.motivo(_JUNCO, Objetivos.Clase.HOSTIL, plantel)).is_equal(ResultadoAccion.Motivo.OBJETIVO_OCULTO)
	# Las demas exclusiones son las mismas para las dos clases.
	plantel.criatura("rodauva_1").estado = Criatura.Estado.CAIDA
	assert_int(Objetivos.motivo("rodauva_1", Objetivos.Clase.ALIADA, plantel)).is_equal(ResultadoAccion.Motivo.OBJETIVO_CAIDO)
	assert_int(Objetivos.motivo("nadie", Objetivos.Clase.ALIADA, plantel)).is_equal(ResultadoAccion.Motivo.OBJETIVO_INEXISTENTE)


# (10) Relaciones (11.2.2, 10.5): oculta no cuenta como rival a su alcance.
func test_rival_oculta() -> void:
	var plantel: Plantel = _plantel()
	# La Ocarra [6,4] (Movimiento 3 + Alcance 2) tiene al Zancajunco a 3.
	assert_bool(Objetivos.cuenta_como_rival_a_su_alcance("ocarra_s1", _JUNCO, plantel)).is_true()
	_ocultar(plantel, _JUNCO)
	assert_bool(Objetivos.cuenta_como_rival_a_su_alcance("ocarra_s1", _JUNCO, plantel)).is_false()
	# Destapado, a la misma distancia, cuenta otra vez.
	plantel.criatura(_JUNCO).oculta = false
	assert_bool(Objetivos.cuenta_como_rival_a_su_alcance("ocarra_s1", _JUNCO, plantel)).is_true()
	# Fuera del alcance (distancia 8 > 5), no.
	plantel.criatura("ocarra_s1").posicion = Vector2i(7, 0)
	assert_bool(Objetivos.cuenta_como_rival_a_su_alcance("ocarra_s1", _JUNCO, plantel)).is_false()


# (11) Registro, instantanea y reproduccion (A.7): oculto, destape por contacto
# de la IA y bono_perdido, con Combate.aplicar. Al terminar el combate se borran
# el estado oculto y el bono (11.2.2, Fin del combate).
func test_registro_instantanea_y_grabacion() -> void:
	var lectura: Dictionary = DatosFixture.cargar()
	assert_array(lectura["errores"]).is_empty()
	var escenario: Dictionary = _leer(_CARPETA + "escenario_junco_tribu.json", "escenario")
	var combate: Combate = Combate.empezar(ContextoCombate.armar(escenario, lectura["datos"]))
	assert_str(combate.error()).is_empty()

	assert_str(combate.turno_actual().unidad_id).is_equal(_JUNCO)
	_assert_valida(combate.aplicar(Accion.hacerse_junco()))
	var foto: Dictionary = _foto_criatura(combate, _JUNCO)
	assert_bool(foto["oculta"]).is_true()
	assert_bool(foto["bono_junco"]).is_true()
	_assert_valida(combate.aplicar(Accion.terminar()))
	# La Ocarra se acerco y lo destapo.
	assert_str(combate.turno_actual().unidad_id).is_equal(Maestro.ID)
	foto = _foto_criatura(combate, _JUNCO)
	assert_bool(foto["oculta"]).is_false()
	assert_bool(foto["bono_junco"]).is_true()
	_assert_valida(combate.aplicar(Accion.terminar()))
	# Ronda 2: espera con el bono; la Ocarra le pega y lo pierde.
	assert_str(combate.turno_actual().unidad_id).is_equal(_JUNCO)
	_assert_valida(combate.aplicar(Accion.terminar()))
	assert_str(combate.turno_actual().unidad_id).is_equal(Maestro.ID)
	foto = _foto_criatura(combate, _JUNCO)
	assert_bool(foto["bono_junco"]).is_false()
	assert_int(foto["vida"]).is_equal(8)
	_assert_valida(combate.aplicar(Accion.terminar()))
	assert_str(combate.error()).is_empty()

	var lineas: Array[Dictionary] = combate.registro().lineas()
	var tipos: Array[String] = []
	for indice in range(lineas.size()):
		var linea: Dictionary = lineas[indice]
		if linea["tipo"] in ["oculto", "destape", "bono_perdido"]:
			tipos.append(linea["tipo"])
		if linea["tipo"] == "oculto":
			assert_str(lineas[indice - 1]["tipo"]).is_equal("accion")
			assert_str(lineas[indice - 1]["accion"]["tipo"]).is_equal("hacerse_junco")
			assert_str(linea["unidad"]).is_equal(_JUNCO)
		if linea["tipo"] == "destape":
			assert_str(lineas[indice - 1]["tipo"]).is_equal("movimiento")
			assert_that(lineas[indice - 1]["hasta"]).is_equal([3, 4])
			assert_str(linea["motivo"]).is_equal("contacto")
			assert_str(linea["por"]).is_equal("ocarra_s1")
		if linea["tipo"] == "bono_perdido":
			assert_str(lineas[indice - 1]["tipo"]).is_equal("ataque")
			assert_str(linea["unidad"]).is_equal(_JUNCO)
			assert_str(linea["atacante"]).is_equal("ocarra_s1")
	assert_array(tipos).is_equal(["oculto", "destape", "bono_perdido"])

	var grabacion: Grabacion = Grabacion.desde_combate(combate)
	var diccionario: Dictionary = grabacion.a_diccionario()
	var esquema: Dictionary = Cargador.new().esquema_resuelto(_CARPETA_DATOS, "grabacion")["esquema"]
	var validacion: Dictionary = Validador.new().validar(JSON.parse_string(JSON.stringify(diccionario)), esquema, "grabacion")
	assert_array(validacion["errores"] as Array).override_failure_message(str(validacion["errores"])).is_empty()
	assert_dict(diccionario["acciones"][0]).is_equal({"unidad": _JUNCO, "accion": {"tipo": "hacerse_junco"}})
	var reproduccion: Reproductor = Reproductor.reproducir(Grabacion.desde_diccionario(validacion["datos"]), lectura["datos"])
	assert_str(reproduccion.error).is_empty()
	assert_array(reproduccion.combate.registro().lineas_json()).is_equal(combate.registro().lineas_json())
	assert_str(str(reproduccion.combate.instantanea())).is_equal(str(combate.instantanea()))

	# Accion.hacerse_junco va y vuelve por diccionario; con otro campo, no.
	assert_int(Accion.desde_diccionario(Accion.hacerse_junco().a_diccionario()).tipo).is_equal(Accion.Tipo.HACERSE_JUNCO)
	assert_object(Accion.desde_diccionario({"tipo": "hacerse_junco", "casilla": [1, 1]})).is_null()

	# Fin del combate: el cierre borra el estado oculto y el bono.
	var plantel: Plantel = _plantel()
	_ocultar(plantel, _JUNCO)
	for id_salvaje in ["rodauva_s1", "ocarra_s1"]:
		plantel.criatura(id_salvaje).estado = Criatura.Estado.FUERA
		plantel.criatura(id_salvaje).posicion = Criatura.SIN_POSICION
	var datos: Dictionary = lectura["datos"]
	var cierre: Cierre = Cierre.desde_datos(datos["tablas/combate.json"], datos["tablas/lealtad.json"],
			Relaciones.new(datos["relaciones.json"]))
	assert_bool(cierre.cerrar(plantel, FinCombate.Fin.VICTORIA).valido).is_true()
	_assert_estado_junco(plantel, _JUNCO, false, false)


func _foto_criatura(combate: Combate, unidad_id: String) -> Dictionary:
	for criatura in combate.instantanea()["criaturas"]:
		if criatura["id"] == unidad_id:
			return criatura
	return {}


# (12) Destapar y pegar (11.2.2 v1.4): la Rodauva se mueve junto al Zancajunco
# salvaje oculto con el bono y lo ataca en el mismo turno; el bono se pierde.
func test_destapar_y_pegar() -> void:
	var plantel: Plantel = _plantel("escenario_junco_salvaje")
	_ocultar(plantel, _JUNCO_SALVAJE)
	var turno: Turno = _turno(plantel, "rodauva_1")
	_assert_rechazada(turno.validar(Accion.atacar(_JUNCO_SALVAJE)), ResultadoAccion.Motivo.OBJETIVO_OCULTO)
	_assert_valida(turno.aplicar(Accion.mover(Vector2i(3, 3))))
	_assert_estado_junco(plantel, _JUNCO_SALVAJE, false, true)
	var golpe: ResultadoAccion = turno.aplicar(Accion.atacar(_JUNCO_SALVAJE))
	_assert_valida(golpe)
	assert_int(golpe.danio).is_equal(2)
	_assert_estado_junco(plantel, _JUNCO_SALVAJE, false, false)
	assert_array(turno.eventos()).is_equal([
		{"tipo": "destape", "unidad": _JUNCO_SALVAJE, "motivo": "contacto", "por": "rodauva_1"},
		{"tipo": "bono_perdido", "unidad": _JUNCO_SALVAJE, "atacante": "rodauva_1"},
	])


# (13) Cuenta (11.2.2 v1.4): cada tramo del movimiento partido es un movimiento
# que termina. El Tasajero lo destapa al terminar su primer tramo, antes de atacar.
func test_cuenta_destapa_en_el_primer_tramo() -> void:
	var plantel: Plantel = _plantel("escenario_junco_salvaje")
	_ocultar(plantel, _JUNCO_SALVAJE)
	plantel.criatura("tasajero_1").modo = "cuenta"
	var turno: Turno = _turno(plantel, "tasajero_1")
	_assert_valida(turno.aplicar(Accion.mover(Vector2i(4, 2))))
	assert_int(turno.pasos_restantes).is_equal(2)
	assert_bool(turno.accion_usada).is_false()
	_assert_estado_junco(plantel, _JUNCO_SALVAJE, false, true)
	assert_array(turno.eventos()).is_equal([
		{"tipo": "destape", "unidad": _JUNCO_SALVAJE, "motivo": "contacto", "por": "tasajero_1"},
	])
	var golpe: ResultadoAccion = turno.aplicar(Accion.atacar(_JUNCO_SALVAJE))
	_assert_valida(golpe)
	assert_int(golpe.danio).is_equal(4)
	_assert_estado_junco(plantel, _JUNCO_SALVAJE, false, false)
	_assert_valida(turno.aplicar(Accion.mover(Vector2i(6, 2))))
