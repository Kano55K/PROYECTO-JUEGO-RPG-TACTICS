extends GdUnitTestSuite

# Arquitectura.md B.3 (T19, sesion 2, punto 14): la vista muestra el Encono y la
# cobardia con lo que le da el nucleo (Combate.rival_en, las consultas del Turno,
# la instantanea y el registro). Sistema.md 10.5, 10.6 y 11.3 v1.6; Mundo.md 9.2
# v1.2 y 5. Fixtures (A.6): escenario_rival_combate.json (Ocarras, balanza 5,
# neutrales: Encono 25 % con el combate.json de prueba, 0 con combate_rival_0.json
# y 100 con combate_rival_100.json) y escenario_cobardia_pantalla.json (Rodauva
# neutral: cobardia 60 %, 50 junto al Maestro). Textos de es_rasgos.json mas los
# de T19, agregados por el test.
const _ESCENA: String = "res://pantalla/combate/vista_combate.tscn"
const _CARPETA_COMBATE: String = "res://pruebas/fixtures/combate/"
const _ESCENARIO_ENCONO: String = _CARPETA_COMBATE + "escenario_rival_combate.json"
const _ESCENARIO_COBARDIA: String = "res://pruebas/fixtures/pantalla/escenario_cobardia_pantalla.json"
const _ESCENARIO_TODAS: String = _CARPETA_COMBATE + "escenario_rival.json"
const _TEXTOS: String = "res://pruebas/fixtures/pantalla/es_rasgos.json"
const _BASE_0: String = "combate_rival_0.json"
const _BASE_100: String = "combate_rival_100.json"
const _MARCA_RIVAL_ENEMIGA: Vector2i = Vector2i(9, 0)
const _TEXTOS_RIVAL: Dictionary = {
	"encono.tooltip": "{porcentaje}% de encono.",
	"cobardia.tooltip": "{porcentaje}% de cobardia.",
	"incidente.tooltip": "{porcentaje}% de incidente.",
	"encono.inicio": "{criatura} se encona con {rival}.",
	"encono.sube": "Sube el encono {de_criatura}.",
	"encono.ocarra.ocarra": "Cresta contra cresta.",
	"encono.ocarra.zancajunco": "Carga contra el Zancajunco.",
	"cobardia.inicio": "{criatura} ve {a_rival} y se asusta.",
	"cobardia.rodauva": "La Rodauva se hace bola.",
	"cobardia.resiste": "{criatura} tiembla.",
	"cobardia.resiste.rodauva": "La Rodauva se queda.",
	"marca.enconada": "Enconada",
	"marca.acobardada": "Acobardada",
	"panel.encono": "Encono",
	"aviso.terminar.debe_atacar_rival": "Tiene que atacar a su rival.",
	"aviso.terminar.debe_acercarse": "Tiene que acercarse a su rival.",
}


func _datos(combate: String = "combate.json") -> Dictionary:
	var lectura: Dictionary = DatosFixture.cargar(combate)
	assert_array(lectura["errores"]).is_empty()
	var datos: Dictionary = lectura["datos"]
	var textos: Dictionary = LectorFixture.leer(_TEXTOS, "textos")["datos"]
	textos.merge(_TEXTOS_RIVAL, true)
	datos["textos/es.json"] = textos
	return datos


func _escenario(ruta: String) -> Dictionary:
	var lectura: Dictionary = LectorFixture.leer(ruta, "escenario")
	assert_array(lectura["errores"]).is_empty()
	return lectura["datos"]


func _vista(escenario: Dictionary, combate: String = "combate.json") -> GdUnitSceneRunner:
	var runner: GdUnitSceneRunner = scene_runner(auto_free(load(_ESCENA).instantiate()))
	(runner.scene() as VistaCombate).pausa_ia = 0.0
	(runner.scene() as VistaCombate).empezar(escenario, _datos(combate))
	return runner


func _marcas_de(vista: VistaCombate, unidad_id: String) -> String:
	for ficha in vista.fichas():
		if ficha.unidad_id == unidad_id:
			return (ficha.get_node("Marcas") as Label).text
	return ""


# (14) Sistema.md 10.5 y 15 v1.6 (el riesgo se ve antes de mover): la Ocarra de la
# tribu [3,5] tiene a la Ocarra salvaje [3,1] a su alcance (4 <= 3 + 2). En su
# casilla se marca la rival con la marca propia (no la de la rival aliada) y el
# aviso dice el 25 %. En [0,5] la rival queda a 7: ni marca ni linea.
func test_aviso_y_marca_de_encono() -> void:
	var runner: GdUnitSceneRunner = _vista(_escenario(_ESCENARIO_ENCONO))
	await runner.simulate_frames(1)
	var vista: VistaCombate = runner.scene()
	var turno: Turno = vista.combate().turno_actual()
	assert_str(turno.unidad_id).is_equal("ocarra_1")

	vista.sobre_casilla(Vector2i(3, 5))
	assert_array(vista.casillas_rivales_enemigas()).is_equal([Vector2i(3, 1)])
	var capa: TileMapLayer = runner.find_child("RivalesEnemigas")
	assert_vector(capa.get_cell_atlas_coords(Vector2i(3, 1))).is_equal(_MARCA_RIVAL_ENEMIGA)
	assert_str(vista.aviso_mostrado()).contains("25% de encono.")
	assert_bool(runner.find_child("Aviso").visible).is_true()

	assert_array(turno.casillas_para_mover()).contains([Vector2i(0, 5)])
	vista.sobre_casilla(Vector2i(0, 5))
	assert_array(vista.casillas_rivales_enemigas()).is_empty()
	assert_str(vista.aviso_mostrado()).not_contains("de encono")


# (14) Con 0 % no hay riesgo: ni marca ni linea, aunque la rival este a su alcance.
func test_sin_aviso_con_0() -> void:
	var runner: GdUnitSceneRunner = _vista(_escenario(_ESCENARIO_ENCONO), _BASE_0)
	await runner.simulate_frames(1)
	var vista: VistaCombate = runner.scene()
	assert_str(vista.combate().turno_actual().unidad_id).is_equal("ocarra_1")
	vista.sobre_casilla(Vector2i(3, 5))
	assert_array(vista.casillas_rivales_enemigas()).is_empty()
	assert_str(vista.aviso_mostrado()).not_contains("de encono")


# (14) Sistema.md 10.6: la Rodauva neutral con la balanza 5 da 60 %; parada
# vecina en 8 del Maestro, 50 % (-10). Se marca el Tasajero.
func test_cobardia_baja_junto_al_maestro() -> void:
	var runner: GdUnitSceneRunner = _vista(_escenario(_ESCENARIO_COBARDIA))
	await runner.simulate_frames(1)
	var vista: VistaCombate = runner.scene()
	var turno: Turno = vista.combate().turno_actual()
	assert_str(turno.unidad_id).is_equal("rodauva_1")
	var tasajero: Vector2i = vista.combate().contexto().plantel.criatura("tasajero_s1").posicion

	vista.sobre_casilla(Vector2i(2, 6))
	assert_array(vista.casillas_rivales_enemigas()).is_equal([tasajero])
	assert_str(vista.aviso_mostrado()).is_equal("60% de cobardia.")

	assert_array(turno.casillas_para_mover()).contains([Vector2i(1, 6)])
	vista.sobre_casilla(Vector2i(1, 6))
	assert_array(vista.casillas_rivales_enemigas()).is_equal([tasajero])
	assert_str(vista.aviso_mostrado()).is_equal("50% de cobardia.")


# (14) S-35: la Ocarra enconada (100 %) que alcanza no termina sin atacar. El
# boton esta deshabilitado y el motivo se lee en el panel y en el tooltip del
# boton; la ficha lleva la marca. Despues de golpear a su rival desde [3,3], el
# boton se habilita, la ficha muestra el contador (10.5) y los sucesos la
# reaccion del par y el encono que sube.
func test_enconada_no_termina_hasta_atacar() -> void:
	var runner: GdUnitSceneRunner = _vista(_escenario(_ESCENARIO_ENCONO), _BASE_100)
	await runner.simulate_frames(1)
	var vista: VistaCombate = runner.scene()
	var turno: Turno = vista.combate().turno_actual()
	assert_str(turno.unidad_id).is_equal("ocarra_1")
	assert_bool(turno.enconada).is_true()
	var boton: Button = runner.find_child("BotonTerminar")
	assert_bool(boton.disabled).is_true()
	assert_str(boton.tooltip_text).is_equal("Tiene que atacar a su rival.")
	assert_str((runner.find_child("PanelTurno") as Label).text).contains("Tiene que atacar a su rival.")
	assert_str(_marcas_de(vista, "ocarra_1")).contains("Enconada")
	assert_str(_marcas_de(vista, "ocarra_1")).not_contains("Encono:")
	assert_str((runner.find_child("Sucesos") as Label).text).contains("Cresta contra cresta.")
	assert_bool(vista.pulsar_terminar()).is_false()

	assert_bool(vista.clic_casilla(Vector2i(3, 3))).is_true()
	assert_bool(boton.disabled).is_true()
	assert_bool(vista.clic_casilla(Vector2i(3, 1))).is_true()
	assert_bool(boton.disabled).is_false()
	assert_str(boton.tooltip_text).is_empty()
	assert_str((runner.find_child("PanelTurno") as Label).text).not_contains("Tiene que atacar")
	assert_str(_marcas_de(vista, "ocarra_1")).contains("Encono: 1/3")
	assert_str((runner.find_child("Sucesos") as Label).text).contains("Sube el encono de la Ocarra.")
	assert_bool(vista.pulsar_terminar()).is_true()


# (14) S-35, la enconada que no alcanza: con la rival en [3,0] (a 5) y el Surcon
# salvaje en [3,4] tapando la columna, ninguna casilla a 3 pasos la golpea. El
# motivo es acercarse; despues de acercarse, el boton se habilita.
func test_enconada_que_no_alcanza_debe_acercarse() -> void:
	var escenario: Dictionary = _escenario(_ESCENARIO_ENCONO)
	(escenario["enemigas"] as Array)[0]["posicion"] = [3, 0]
	(escenario["enemigas"] as Array).append({"id": "surcon_s1", "especie": "surcon", "comportamiento": "salvaje",
			"vida": null, "posicion": [3, 4]})
	var runner: GdUnitSceneRunner = _vista(escenario, _BASE_100)
	await runner.simulate_frames(1)
	var vista: VistaCombate = runner.scene()
	var turno: Turno = vista.combate().turno_actual()
	assert_str(turno.unidad_id).is_equal("ocarra_1")
	assert_int(turno.obligacion).is_equal(Turno.Obligacion.ACERCARSE)
	var boton: Button = runner.find_child("BotonTerminar")
	assert_bool(boton.disabled).is_true()
	assert_str(boton.tooltip_text).is_equal("Tiene que acercarse a su rival.")
	assert_str((runner.find_child("PanelTurno") as Label).text).contains("Tiene que acercarse a su rival.")

	assert_bool(vista.clic_casilla(turno.casillas_para_mover()[0])).is_true()
	assert_bool(boton.disabled).is_false()
	assert_str((runner.find_child("PanelTurno") as Label).text).not_contains("Tiene que acercarse")


# (14) A.7 y Mundo.md 5: las lineas de chequeo_rival y encono. La reaccion del par
# (o de la especie, en la cobardia) reemplaza a la general; resistir usa la
# variante de la especie; no enconarse no tiene linea.
func test_sucesos_del_chequeo_y_del_encono() -> void:
	var datos: Dictionary = _datos()
	var contexto: ContextoCombate = ContextoCombate.armar(_escenario(_ESCENARIO_TODAS), datos)
	assert_bool(contexto.valido).is_true()
	var combate: Combate = Combate.empezar(contexto)
	assert_str(combate.error()).is_empty()
	var lectura: LecturaCombate = LecturaCombate.new(combate,
			ArmadorTextos.desde_datos(datos["textos/es.json"], contexto.azar_textos),
			EstadosUnidad.desde_datos(datos["tablas/hambre.json"], datos["tablas/lealtad.json"]))

	assert_array(lectura.suceso(_chequeo("ocarra_1", "encono", ["zancajunco_s1", "ocarra_s1"], "enconada"))) \
			.is_equal(["Carga contra el Zancajunco."])
	assert_array(lectura.suceso(_chequeo("ocarra_1", "encono", ["tasajero_s1"], "enconada"))) \
			.is_equal(["La Ocarra se encona con el Tasajero."])
	assert_array(lectura.suceso(_chequeo("ocarra_1", "encono", ["tasajero_s1"], "no_enconada"))).is_empty()
	assert_array(lectura.suceso(_chequeo("rodauva_1", "cobardia", ["tasajero_s1"], "acobardada"))) \
			.is_equal(["La Rodauva se hace bola."])
	assert_array(lectura.suceso(_chequeo("surcon_1", "cobardia", ["tasajero_s1"], "acobardada"))) \
			.is_equal(["El Surcón ve al Tasajero y se asusta."])
	assert_array(lectura.suceso(_chequeo("rodauva_1", "cobardia", ["tasajero_s1"], "resistida"))) \
			.is_equal(["La Rodauva se queda."])
	assert_array(lectura.suceso(_chequeo("surcon_1", "cobardia", ["tasajero_s1"], "resistida"))) \
			.is_equal(["El Surcón tiembla."])
	assert_array(lectura.suceso({"tipo": "encono", "unidad": "ocarra_1", "de": 0, "a": 1, "rival": "ocarra_s1"})) \
			.is_equal(["Sube el encono de la Ocarra."])


func _chequeo(unidad: String, tipo: String, rivales: Array, resultado: String) -> Dictionary:
	return {"tipo": "chequeo_rival", "unidad": unidad, "tipo_chequeo": tipo, "rivales": rivales, "porcentaje": 25,
			"tiro": true, "resultado": resultado}


# (14) Sistema.md 10.5: el contador de las criaturas de Encono (de los dos bandos)
# en el tooltip, tambien en 0; la de cobardia no lo tiene. Con la Rodauva
# acobardada en su turno (60 %, sale), su ficha y su tooltip llevan la marca.
func test_contador_y_marca_en_el_tooltip() -> void:
	var runner: GdUnitSceneRunner = _vista(_escenario(_ESCENARIO_COBARDIA))
	await runner.simulate_frames(1)
	var vista: VistaCombate = runner.scene()
	var turno: Turno = vista.combate().turno_actual()
	assert_str(turno.unidad_id).is_equal("rodauva_1")
	assert_bool(turno.acobardada).is_true()
	var lectura: LecturaCombate = _lectura(vista.combate())
	assert_array(lectura.tooltip_unidad("rodauva_1")).contains(["Acobardada"])
	assert_array(lectura.tooltip_unidad("rodauva_1")).not_contains(["Encono: 0/3"])
	assert_array(lectura.tooltip_unidad("tasajero_s1")).contains(["Encono: 0/3"])
	assert_str(_marcas_de(vista, "rodauva_1")).contains("Acobardada")
	# El boton no se bloquea: la acobardada puede terminar donde esta.
	assert_bool((runner.find_child("BotonTerminar") as Button).disabled).is_false()

	var runner_encono: GdUnitSceneRunner = _vista(_escenario(_ESCENARIO_ENCONO))
	await runner_encono.simulate_frames(1)
	var lectura_encono: LecturaCombate = _lectura((runner_encono.scene() as VistaCombate).combate())
	assert_array(lectura_encono.tooltip_unidad("ocarra_1")).contains(["Encono: 0/3"])
	assert_array(lectura_encono.tooltip_unidad("ocarra_s1")).contains(["Encono: 0/3"])


func _lectura(combate: Combate) -> LecturaCombate:
	var datos: Dictionary = _datos()
	return LecturaCombate.new(combate, ArmadorTextos.desde_datos(datos["textos/es.json"], GeneradorAzar.new(1)),
			EstadosUnidad.desde_datos(datos["tablas/hambre.json"], datos["tablas/lealtad.json"]))
