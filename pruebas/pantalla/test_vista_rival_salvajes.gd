extends GdUnitTestSuite

# Arquitectura.md B.3 (T20, sesion 2, punto 17): la pantalla muestra el chequeo
# de rival y los incidentes de las enemigas con lo que le da el nucleo, con las
# mismas claves y variantes que la tribu (T18, T19). Sistema.md 10.4 a 10.7 v1.6;
# Mundo.md 9.2 v1.2 y 5. Fixtures (A.6): escenario_rival_salvajes.json (todas las
# especies en los dos bandos, para los sucesos) y escenario_rival_salvajes_combate.json
# (ocarra_s1 [3,3] tira 35 % contra ocarra_1 [3,7] y, con la semilla 1, se encona
# y la ataca; ocarra_s2 [7,0] queda lejos de todas). Textos de es_rasgos.json mas
# los de T18 y T19, agregados por el test.
const _ESCENA: String = "res://pantalla/combate/vista_combate.tscn"
const _CARPETA_COMBATE: String = "res://pruebas/fixtures/combate/"
const _ESCENARIO_TODAS: String = _CARPETA_COMBATE + "escenario_rival_salvajes.json"
const _ESCENARIO_COMBATE: String = _CARPETA_COMBATE + "escenario_rival_salvajes_combate.json"
const _TEXTOS: String = "res://pruebas/fixtures/pantalla/es_rasgos.json"
const _TEXTOS_RIVAL: Dictionary = {
	"encono.tooltip": "{porcentaje}% de encono.",
	"cobardia.tooltip": "{porcentaje}% de cobardia.",
	"encono.inicio": "{criatura} se encona con {rival}.",
	"encono.sube": "Sube el encono {de_criatura}.",
	"encono.ocarra.ocarra": "Cresta contra cresta.",
	"encono.ocarra.zancajunco": "Carga contra el Zancajunco.",
	"cobardia.inicio": "{criatura} ve {a_rival} y se asusta.",
	"cobardia.rodauva": "La Rodauva se hace bola.",
	"cobardia.resiste": "{criatura} tiembla.",
	"cobardia.resiste.rodauva": "La Rodauva se queda.",
	"incidente.distraida": "{criatura} mira {a_rival}.",
	"incidente.ataque": "{criatura} le pega {a_rival}.",
	"incidente.ataque.ocarra.zancajunco": "Picotazo al Zancajunco.",
	"marca.enconada": "Enconada",
	"marca.acobardada": "Acobardada",
	"panel.encono": "Encono",
}
# Presentacion: la secuencia de la IA no avanza sola durante el test.
const _PAUSA_LARGA: float = 100.0


func _datos() -> Dictionary:
	var lectura: Dictionary = DatosFixture.cargar()
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


func _combate(ruta: String) -> Combate:
	var contexto: ContextoCombate = ContextoCombate.armar(_escenario(ruta), _datos())
	assert_bool(contexto.valido).is_true()
	var combate: Combate = Combate.empezar(contexto)
	assert_str(combate.error()).is_empty()
	return combate


func _lectura(combate: Combate) -> LecturaCombate:
	var datos: Dictionary = _datos()
	return LecturaCombate.new(combate, ArmadorTextos.desde_datos(datos["textos/es.json"], GeneradorAzar.new(1)),
			EstadosUnidad.desde_datos(datos["tablas/hambre.json"], datos["tablas/lealtad.json"]))


func _chequeo(unidad: String, tipo: String, rivales: Array, resultado: String) -> Dictionary:
	return {"tipo": "chequeo_rival", "unidad": unidad, "tipo_chequeo": tipo, "rivales": rivales, "porcentaje": 35,
			"tiro": true, "resultado": resultado}


# (17) Sistema.md 10.5 y 10.6, Mundo.md 5: el chequeo de una salvaje sale con la
# reaccion del par (Encono) o de la especie (cobardia) y, si no hay, con la linea
# general; no enconarse no tiene linea. Las mismas claves que la tribu (T19).
func test_sucesos_del_chequeo_de_una_enemiga() -> void:
	var lectura: LecturaCombate = _lectura(_combate(_ESCENARIO_TODAS))
	assert_array(lectura.suceso(_chequeo("ocarra_s1", "encono", ["zancajunco_1", "ocarra_1"], "enconada"))) \
			.is_equal(["Carga contra el Zancajunco."])
	assert_array(lectura.suceso(_chequeo("ocarra_s1", "encono", ["ocarra_1"], "enconada"))) \
			.is_equal(["Cresta contra cresta."])
	assert_array(lectura.suceso(_chequeo("ocarra_s1", "encono", ["tasajero_1"], "enconada"))) \
			.is_equal(["La Ocarra se encona con el Tasajero."])
	assert_array(lectura.suceso(_chequeo("ocarra_s1", "encono", ["tasajero_1"], "no_enconada"))).is_empty()
	assert_array(lectura.suceso(_chequeo("rodauva_s1", "cobardia", ["tasajero_1"], "acobardada"))) \
			.is_equal(["La Rodauva se hace bola."])
	assert_array(lectura.suceso(_chequeo("surcon_s1", "cobardia", ["tasajero_1"], "acobardada"))) \
			.is_equal(["El Surcón ve al Tasajero y se asusta."])
	assert_array(lectura.suceso(_chequeo("rodauva_s1", "cobardia", ["tasajero_1"], "resistida"))) \
			.is_equal(["La Rodauva se queda."])
	assert_array(lectura.suceso(_chequeo("surcon_s1", "cobardia", ["tasajero_1"], "resistida"))) \
			.is_equal(["El Surcón tiembla."])


# (17) Sistema.md 10.5 y 10.4: el contador de una salvaje y su incidente con una
# rival aliada (distraida, golpe, y la variante del par), con las claves de la tribu.
func test_sucesos_del_encono_y_del_incidente_de_una_enemiga() -> void:
	var lectura: LecturaCombate = _lectura(_combate(_ESCENARIO_TODAS))
	assert_array(lectura.suceso({"tipo": "encono", "unidad": "ocarra_s1", "de": 0, "a": 1, "rival": "ocarra_1"})) \
			.is_equal(["Sube el encono de la Ocarra."])
	assert_array(lectura.suceso({"tipo": "incidente", "unidad": "ocarra_s1", "rivales": ["ocarra_s2"],
			"porcentaje": 20, "resultado": "distraida", "objetivo": null})) \
			.is_equal(["La Ocarra mira a la Ocarra."])
	assert_array(lectura.suceso({"tipo": "incidente", "unidad": "ocarra_s1", "rivales": ["ocarra_s2"],
			"porcentaje": 20, "resultado": "golpe", "objetivo": "ocarra_s2"})) \
			.is_equal(["La Ocarra le pega a la Ocarra."])
	assert_array(lectura.suceso({"tipo": "incidente", "unidad": "ocarra_s1", "rivales": ["ocarra_s2", "zancajunco_s1"],
			"porcentaje": 20, "resultado": "golpe", "objetivo": "zancajunco_s1"})) \
			.is_equal(["Picotazo al Zancajunco."])


# (17) El suceso del registro real: ocarra_s1 se encona contra ocarra_1 en la
# ronda 1 y su chequeo sale con la reaccion del par.
func test_suceso_del_registro_de_una_enemiga() -> void:
	var combate: Combate = _combate(_ESCENARIO_COMBATE)
	assert_bool(combate.aplicar(Accion.terminar()).valida).is_true()
	var chequeo: Dictionary = {}
	for linea in combate.registro().lineas():
		if linea["tipo"] == "chequeo_rival" and linea["unidad"] == "ocarra_s1":
			chequeo = linea
	assert_str(chequeo.get("resultado", "")).is_equal("enconada")
	assert_array(_lectura(combate).suceso(chequeo)).is_equal(["Cresta contra cresta."])


# (17) Sistema.md 10.5 y 15 v1.6 (el riesgo se ve): el tooltip de una enemiga
# suma el % del chequeo que tiraria si empezara su turno ahora (Combate.rival_en
# en su casilla), con la clave de la tribu. ocarra_s1 tiene a ocarra_1 a su
# alcance: 35 %. ocarra_s2 no tiene a nadie: 0 %, sin linea. La tribu no la suma.
func test_tooltip_de_una_enemiga() -> void:
	var combate: Combate = _combate(_ESCENARIO_COMBATE)
	var lectura: LecturaCombate = _lectura(combate)
	assert_int(combate.rival_en("ocarra_s1", Vector2i(3, 3))["porcentaje"] as int).is_equal(35)
	assert_array(lectura.tooltip_unidad("ocarra_s1")).contains(["35% de encono."])
	assert_int(combate.rival_en("ocarra_s2", Vector2i(7, 0))["porcentaje"] as int).is_equal(0)
	for linea in lectura.tooltip_unidad("ocarra_s2"):
		assert_str(linea).not_contains("% de")
	for linea in lectura.tooltip_unidad("ocarra_1"):
		assert_str(linea).not_contains("% de")


# (17) La marca de un estado del chequeo, con la especie como sujeto.
func test_marca_estado() -> void:
	var lectura: LecturaCombate = _lectura(_combate(_ESCENARIO_TODAS))
	assert_str(lectura.marca_estado("ocarra_s1", "enconada")).is_equal("Enconada")
	assert_str(lectura.marca_estado("rodauva_s1", "acobardada")).is_equal("Acobardada")
	assert_str(lectura.marca_estado("ocarra_s1", "no_enconada")).is_empty()


# (17) Respuesta del usuario (T20, sesion 2): mientras la secuencia de la IA
# muestra los pasos de ocarra_s1, enconada en su turno, su ficha lleva la marca.
# Al saltar la secuencia, la vista se redibuja desde el nucleo y la marca se va.
func test_marca_de_la_enemiga_durante_la_secuencia() -> void:
	var runner: GdUnitSceneRunner = scene_runner(auto_free(load(_ESCENA).instantiate()))
	var vista: VistaCombate = runner.scene()
	vista.pausa_ia = _PAUSA_LARGA
	vista.empezar(_escenario(_ESCENARIO_COMBATE), _datos())
	await runner.simulate_frames(1)
	assert_str(vista.combate().turno_actual().unidad_id).is_equal("ocarra_1")
	assert_bool(vista.pulsar_terminar()).is_true()
	await runner.simulate_frames(1)
	assert_bool(vista.en_secuencia()).is_true()
	assert_str(_ficha(vista, "ocarra_s1").texto_marcas()).contains("Enconada")
	assert_str(_ficha(vista, "ocarra_s2").texto_marcas()).not_contains("Enconada")
	assert_bool(vista.saltar()).is_true()
	await runner.simulate_frames(1)
	assert_str(_ficha(vista, "ocarra_s1").texto_marcas()).not_contains("Enconada")


func _ficha(vista: VistaCombate, unidad_id: String) -> FichaUnidad:
	for ficha in vista.fichas():
		if ficha.unidad_id == unidad_id:
			return ficha
	return null
