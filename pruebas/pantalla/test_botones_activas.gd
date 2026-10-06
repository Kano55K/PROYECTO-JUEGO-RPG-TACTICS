extends GdUnitTestSuite

# Arquitectura.md B.2.1 (T40, test 2): los botones de las activas salen del
# efecto del rasgo de la ficha, nunca del id de la especie o del rasgo, y si se
# pueden usar lo dicen las consultas del Turno. Fixtures (A.6): una especie
# inventada con el efecto ocultarse y otros ids.
const _ESCENA: String = "res://pantalla/combate/vista_combate.tscn"
const _CARPETA: String = "res://pruebas/fixtures/pantalla/"
const _CARPETA_COMBATE: String = "res://pruebas/fixtures/combate/"


func _datos() -> Dictionary:
	var lectura: Dictionary = DatosFixture.cargar()
	assert_array(lectura["errores"]).is_empty()
	var datos: Dictionary = lectura["datos"]
	var especie: Dictionary = LectorFixture.leer(_CARPETA + "especie_prueba.json", "especie")
	assert_array(especie["errores"]).override_failure_message(str(especie["errores"])).is_empty()
	datos["especies/especie_prueba.json"] = especie["datos"]
	datos["textos/es.json"] = LectorFixture.leer(_CARPETA + "es_rasgos.json", "textos")["datos"]
	return datos


func _escenario(ruta: String) -> Dictionary:
	var lectura: Dictionary = LectorFixture.leer(ruta, "escenario")
	assert_array(lectura["errores"]).override_failure_message(str(lectura["errores"])).is_empty()
	return lectura["datos"]


func _lectura(combate: Combate, datos: Dictionary) -> LecturaCombate:
	var armador: ArmadorTextos = ArmadorTextos.desde_datos(datos["textos/es.json"], combate.contexto().azar_textos)
	var estados: EstadosUnidad = EstadosUnidad.desde_datos(datos["tablas/hambre.json"], datos["tablas/lealtad.json"])
	return LecturaCombate.new(combate, armador, estados)


func _tipos(botones: Array[Dictionary]) -> Array[String]:
	var tipos: Array[String] = []
	for boton in botones:
		tipos.append(boton["tipo"])
	return tipos


func test_botones_salen_del_efecto() -> void:
	var datos: Dictionary = _datos()
	var combate: Combate = Combate.empezar(ContextoCombate.armar(_escenario(_CARPETA + "escenario_especie_prueba.json"), datos))
	assert_str(combate.error()).is_empty()
	assert_str(combate.turno_actual().unidad_id).is_equal("prueba_1")
	var botones: Array[Dictionary] = _lectura(combate, datos).botones_activas()
	assert_array(_tipos(botones)).is_equal([LecturaCombate.ACTIVA_HACERSE_JUNCO])
	assert_bool(botones[0]["habilitado"]).is_true()
	# El nombre sale del id de su rasgo: sin texto, [FALTA].
	assert_str(botones[0]["texto"]).is_equal("[FALTA: rasgo.rasgo_prueba.nombre]")

	# El Zancajunco de C: Hacerse junco, sin Erizarse ni Cavar.
	combate = Combate.empezar(ContextoCombate.armar(_escenario(_CARPETA_COMBATE + "escenario_c.json"), datos))
	assert_str(combate.turno_actual().unidad_id).is_equal("zancajunco_1")
	botones = _lectura(combate, datos).botones_activas()
	assert_array(_tipos(botones)).is_equal([LecturaCombate.ACTIVA_HACERSE_JUNCO])
	assert_str(botones[0]["texto"]).is_equal("Hacerse junco")
	# Despues de moverse ya no puede ocultarse: el boton sigue y queda deshabilitado.
	assert_bool(combate.aplicar(Accion.mover(combate.turno_actual().casillas_para_mover()[0])).valida).is_true()
	assert_bool(_lectura(combate, datos).botones_activas()[0]["habilitado"]).is_false()

	# El Surcon de la tribu: Cavar, con accion.cavar.
	combate = Combate.empezar(ContextoCombate.armar(_escenario(_CARPETA_COMBATE + "escenario_surco_tribu.json"), datos))
	assert_bool(combate.aplicar(Accion.terminar()).valida).is_true()
	botones = _lectura(combate, datos).botones_activas()
	assert_array(_tipos(botones)).is_equal([LecturaCombate.ACTIVA_CAVAR])
	assert_str(botones[0]["texto"]).is_equal("Arar")
	assert_bool(botones[0]["habilitado"]).is_true()
	# El Maestro no tiene activas.
	combate = Combate.empezar(ContextoCombate.armar(_escenario(_CARPETA_COMBATE + "escenario_surco_tribu.json"), datos))
	assert_array(_lectura(combate, datos).botones_activas()).is_empty()


# En la vista: el boton de la especie inventada se ve, y pulsarlo la oculta.
func test_vista_pulsa_la_activa_del_efecto() -> void:
	var datos: Dictionary = _datos()
	var runner: GdUnitSceneRunner = scene_runner(auto_free(load(_ESCENA).instantiate()))
	var vista: VistaCombate = runner.scene()
	vista.empezar(_escenario(_CARPETA + "escenario_especie_prueba.json"), datos)
	await runner.simulate_frames(1)
	var boton: Button = runner.find_child("Activa_" + LecturaCombate.ACTIVA_HACERSE_JUNCO)
	assert_object(boton).is_not_null()
	assert_bool(boton.visible).is_true()
	assert_bool(boton.disabled).is_false()
	assert_object(runner.find_child("Activa_" + LecturaCombate.ACTIVA_ERIZARSE)).is_null()
	assert_bool(vista.pulsar_activa(LecturaCombate.ACTIVA_HACERSE_JUNCO)).is_true()
	assert_bool(vista.combate().contexto().plantel.criatura("prueba_1").oculta).is_true()
