extends GdUnitTestSuite

# Arquitectura.md B.2 (T13): LecturaCombate traduce el combate en lo que se
# dibuja, sin reglas propias y con todo texto pedido al ArmadorTextos. Fixtures
# (A.6): prueba C y una copia de textos de es.json sin las claves nuevas.
const _ESCENARIO_C: String = "res://pruebas/fixtures/combate/escenario_c.json"
const _TEXTOS: String = "res://pruebas/fixtures/pantalla/es.json"

var _combate: Combate


func _lectura(hambre_maestro: int = -1) -> LecturaCombate:
	var datos_fixture: Dictionary = DatosFixture.cargar()
	assert_array(datos_fixture["errores"]).is_empty()
	var datos: Dictionary = datos_fixture["datos"]
	var escenario: Dictionary = LectorFixture.leer(_ESCENARIO_C, "escenario")["datos"]
	if hambre_maestro >= 0:
		(escenario["maestro"] as Dictionary)["hambre"] = hambre_maestro
	var textos: Dictionary = LectorFixture.leer(_TEXTOS, "textos")
	assert_array(textos["errores"]).is_empty()
	var contexto: ContextoCombate = ContextoCombate.armar(escenario, datos)
	_combate = Combate.empezar(contexto)
	assert_str(_combate.error()).is_empty()
	var armador: ArmadorTextos = ArmadorTextos.desde_datos(textos["datos"], contexto.azar_textos)
	var estados: EstadosUnidad = EstadosUnidad.desde_datos(datos["tablas/hambre.json"], datos["tablas/lealtad.json"])
	return LecturaCombate.new(_combate, armador, estados)


# Nombres por T34; la clave que falta se ve como [FALTA: clave].
func test_nombres() -> void:
	var lectura: LecturaCombate = _lectura()
	assert_str(lectura.nombre("rodauva_1")).is_equal("Rodauva")
	assert_str(lectura.nombre("tasajero_s1")).is_equal("Tasajero")
	assert_str(lectura.nombre(Maestro.ID)).is_equal("[FALTA: maestro.nombre]")
	assert_str(lectura.texto_ronda()).is_equal("[FALTA: combate.ronda]")


# La cola de C con la marca de Caza y la entrada actual (el Zancajunco). Sin la
# fila de la Cuenta: reescrito por Sistema.md 11.2.3 v1.3 (un turno por ronda).
func test_filas_cola() -> void:
	var lectura: LecturaCombate = _lectura()
	var textos: Array[String] = []
	var actuales: Array[bool] = []
	for fila in lectura.filas_cola():
		textos.append(fila["texto"])
		actuales.append(fila["actual"])
	assert_array(textos).is_equal(["Zancajunco", "Tasajero · Caza", "Ocarra", "Rodauva",
			"[FALTA: maestro.nombre]"])
	assert_array(actuales).is_equal([true, false, false, false, false])


# Panel del turno: lealtad con su estado (balanza 2, umbral de la fixture) y
# hambre con su estado; el Maestro usa la variante .maestro.
func test_panel_turno() -> void:
	var lectura: LecturaCombate = _lectura(1)
	var panel: Array[String] = lectura.panel_turno()
	assert_str(panel[0]).is_equal("Zancajunco")
	assert_array(panel).contains(["[FALTA: panel.lealtad]: 8 (Leal)", "[FALTA: panel.hambre]: 3 (Normal)"])
	while _combate.turno_actual().unidad_id != Maestro.ID:
		_combate.aplicar(Accion.terminar())
		assert_str(_combate.error()).is_empty()
	panel = lectura.panel_turno()
	assert_str(panel[0]).is_equal("[FALTA: maestro.nombre]")
	assert_array(panel).contains(["[FALTA: panel.hambre]: 1 (Saciado)"])
	for linea in panel:
		assert_str(linea).not_contains("panel.lealtad")


# Una ficha por unidad en el tablero, en su casilla, con el Maestro marcado.
func test_fichas() -> void:
	var lectura: LecturaCombate = _lectura()
	var por_id: Dictionary = {}
	for ficha in lectura.fichas():
		por_id[ficha["id"]] = ficha
	assert_array(por_id.keys()).contains_exactly_in_any_order([Maestro.ID, "rodauva_1", "ocarra_1", "zancajunco_1", "tasajero_s1"])
	assert_bool(por_id[Maestro.ID]["maestro"]).is_true()
	assert_bool(por_id["tasajero_s1"]["tribu"]).is_false()
	assert_bool(por_id["rodauva_1"]["tribu"]).is_true()
	assert_vector(por_id["rodauva_1"]["casilla"]).is_equal(_casilla("rodauva_1"))


func _casilla(id_unidad: String) -> Vector2i:
	for criatura in _combate.instantanea()["criaturas"]:
		if criatura["id"] == id_unidad:
			return Vector2i(criatura["posicion"][0], criatura["posicion"][1])
	return Criatura.SIN_POSICION


# T13, sesion 2: lo nuevo del registro como lineas. El movimiento se arma con
# claves que ya existen; la caida usa `caida` con su complemento de especie.
func test_sucesos() -> void:
	var lectura: LecturaCombate = _lectura()
	var desde: int = _combate.registro().lineas().size()
	var destino: Vector2i = _combate.turno_actual().casillas_para_mover()[0]
	assert_bool(_combate.aplicar(Accion.mover(destino)).valida).is_true()
	assert_array(lectura.sucesos(desde)).is_equal(["Zancajunco · Mover"])
	assert_array(lectura.suceso({"tipo": "estado", "unidad": "rodauva_1", "de": "suelta", "a": "caida"})) \
			.is_equal(["La Rodauva cae y no se levanta. Todavía respira.",
					"Queda hecha bola, quieta. Las frutas se le cayeron de las púas."])
	assert_array(lectura.suceso({"tipo": "ataque", "atacante": "zancajunco_1", "objetivo": "tasajero_s1",
			"desglose": {"total": 6}, "vida_antes": 14, "vida_despues": 8})) \
			.is_equal(["Zancajunco · Atacar · Tasajero −6 (14 → 8)"])
	assert_array(lectura.suceso({"tipo": "fin", "desenlace": "victoria"})) \
			.is_equal(["El claro queda en silencio. Se terminó."])
	assert_array(lectura.suceso({"tipo": "tirada"})).is_empty()


# El desglose de 11.4 tal como viene del nucleo: base, cada modificador con su
# fuente, total y si actuo el minimo. Ninguna cuenta en la pantalla.
func test_desglose() -> void:
	var lectura: LecturaCombate = _lectura()
	var desglose: Dictionary = {"base": 4, "modificadores": [
			{"fuente": "hambre", "tipo": "porcentaje", "valor": 25, "detalle": "saciado"},
			{"fuente": "combo", "tipo": "porcentaje", "valor": 50, "detalle": ""},
			{"fuente": "rasgo_atacante", "tipo": "plano", "valor": 2, "detalle": "hacerse_junco"},
			{"fuente": "rasgo_objetivo", "tipo": "plano", "valor": -1, "detalle": "hacerse_junco"}],
			"porcentaje_total": 75, "tras_porcentajes": 7, "planos_total": 1, "minimo_aplicado": false, "total": 8}
	assert_array(lectura.desglose(desglose, "zancajunco_1")).is_equal([
			"[FALTA: desglose.base]: 4", "Saciada: +25%", "[FALTA: desglose.fuente.combo]: +50%",
			"Hacerse junco: +2", "Hacerse junco: -1", "[FALTA: desglose.total]: 8"])
	desglose["minimo_aplicado"] = true
	desglose["total"] = 1
	assert_str(lectura.desglose(desglose, "zancajunco_1").back()) \
			.is_equal("[FALTA: desglose.total]: 1 ([FALTA: desglose.minimo])")


# La pantalla de resultado desde ResultadoCombate.a_diccionario(): desenlace,
# rondas, estado final de cada unidad y cambios de lealtad con su motivo.
func test_resultado() -> void:
	var lectura: LecturaCombate = _lectura()
	var resultado: Dictionary = {"desenlace": "victoria", "rondas": 3, "maestro_caido": false,
			"maestro": {"vida": 20}, "unidades": [
				{"id": "rodauva_1", "especie": "rodauva", "estado": "suelta", "vida": 1},
				{"id": "tasajero_s1", "especie": "tasajero", "estado": "fuera", "vida": 0}],
			"lealtad_cambios": [{"id": "rodauva_1", "antes": 8, "cambio": 1, "despues": 9,
				"anotaciones": [{"cambio": 1, "motivo": "victoria"}]}]}
	assert_array(lectura.resultado(resultado)).is_equal([
			"[FALTA: resultado.titulo]",
			"[FALTA: resultado.desenlace.victoria]",
			"[FALTA: resultado.rondas]: 3",
			"[FALTA: maestro.nombre] · [FALTA: panel.vida]: 20",
			"Rodauva · [FALTA: estado.suelta] · [FALTA: panel.vida]: 1",
			"Tasajero · [FALTA: estado.fuera] · [FALTA: panel.vida]: 0",
			"[FALTA: resultado.lealtad]",
			"Rodauva: 8 → 9",
			"  [FALTA: lealtad.motivo.victoria]: +1"])


# --- T40: rasgos visibles (Arquitectura.md B.2.1) -----------------------------

const _CARPETA_COMBATE: String = "res://pruebas/fixtures/combate/"
const _TEXTOS_RASGOS: String = "res://pruebas/fixtures/pantalla/es_rasgos.json"


# Un combate de fixtures con los textos de es_rasgos.json. cambios: tribu id ->
# {campo: valor} sobre el escenario antes de armarlo.
func _lectura_rasgos(nombre: String, cambios: Dictionary = {}) -> LecturaCombate:
	var datos_fixture: Dictionary = DatosFixture.cargar()
	assert_array(datos_fixture["errores"]).is_empty()
	var datos: Dictionary = datos_fixture["datos"]
	var escenario: Dictionary = LectorFixture.leer(_CARPETA_COMBATE + nombre + ".json", "escenario")["datos"]
	for unidad in escenario["tribu"]:
		if cambios.has(unidad["id"]):
			(unidad as Dictionary).merge(cambios[unidad["id"]], true)
	var textos: Dictionary = LectorFixture.leer(_TEXTOS_RASGOS, "textos")
	assert_array(textos["errores"]).is_empty()
	var contexto: ContextoCombate = ContextoCombate.armar(escenario, datos)
	_combate = Combate.empezar(contexto)
	assert_str(_combate.error()).is_empty()
	var armador: ArmadorTextos = ArmadorTextos.desde_datos(textos["datos"], contexto.azar_textos)
	var estados: EstadosUnidad = EstadosUnidad.desde_datos(datos["tablas/hambre.json"], datos["tablas/lealtad.json"])
	return LecturaCombate.new(_combate, armador, estados)


func _ficha_de(lectura: LecturaCombate, id_unidad: String) -> Dictionary:
	for ficha in lectura.fichas():
		if ficha["id"] == id_unidad:
			return ficha
	return {}


# (4) Cada evento nuevo de A.7 da su linea de sucesos; el destape, segun su
# motivo, y el cambio de modo, segun el modo al que pasa.
func test_t40_sucesos_de_los_rasgos() -> void:
	var lectura: LecturaCombate = _lectura_rasgos("escenario_c")
	assert_array(lectura.suceso({"tipo": "surco", "casilla": [2, 1], "duenio": "surcon_s1"})) \
			.is_equal(["El Surcón hunde la reja y abre un surco."])
	assert_array(lectura.suceso({"tipo": "surco_cerrado", "casilla": [2, 1], "duenio": "surcon_s1", "motivo": "tope"})) \
			.is_equal(["Un surco se desmorona. La tierra vuelve a asentarse."])
	assert_array(lectura.suceso({"tipo": "oculto", "unidad": "zancajunco_1"})) \
			.is_equal(["El Zancajunco se queda quieto. Ya no se lo distingue de los juncos."])
	assert_array(lectura.suceso({"tipo": "destape", "unidad": "zancajunco_1", "motivo": "mover", "por": null})) \
			.is_equal(["El Zancajunco deja de ser junco y avanza. La embestida sigue en pie."])
	assert_array(lectura.suceso({"tipo": "destape", "unidad": "zancajunco_1", "motivo": "atacar", "por": null})) \
			.is_equal(["El junco era el Zancajunco. El golpe sale de la quietud."])
	assert_array(lectura.suceso({"tipo": "destape", "unidad": "zancajunco_1", "motivo": "contacto",
			"por": "tasajero_s1"})) \
			.is_equal(["Alguien se le plantó al lado. El Zancajunco deja de fingir que es junco."])
	assert_array(lectura.suceso({"tipo": "bono_perdido", "unidad": "zancajunco_1", "atacante": "tasajero_s1"})) \
			.is_equal(["Le pegaron antes de embestir. El Zancajunco pierde el impulso."])
	assert_array(lectura.suceso({"tipo": "cambio_modo", "unidad": "tasajero_s1", "de": "caza", "a": "cuenta"})) \
			.is_equal(["El Tasajero deja de cazar. Ahora cuenta lo que le queda."])
	# La accion de cavar o de ocultarse no da linea propia: la da su evento.
	assert_array(lectura.suceso({"tipo": "accion", "unidad": "zancajunco_1", "origen": "jugador",
			"accion": {"tipo": "hacerse_junco"}, "paso": null})).is_empty()


# (5) El tooltip de una enemiga muestra su rasgo y su estado: el Tasajero de C
# en Caza con el umbral de vida_de_cambio (30 x 50% = 15); el Zancajunco
# salvaje oculto con el bono; los Surcones con sus surcos contra el tope (2).
# T19 (Sistema.md 10.5 v1.6): el Tasajero es de Encono y suma su contador (0 de
# 3); el fixture de textos no tiene panel.encono.
func test_t40_tooltip_de_una_enemiga() -> void:
	var lectura: LecturaCombate = _lectura_rasgos("escenario_c")
	assert_array(lectura.tooltip_unidad("tasajero_s1")).is_equal(["Tasajero", "Vida: 30/30", "Caza y cuenta",
			"Empieza cazando: dos zarpazos por turno, a una presa o a dos, y recibe más daño. Herido, pasa a contar: pica una vez, más flojo, y se aparta. No vuelve a cazar.",
			"Caza", "[FALTA: panel.encono]: 0/3", "Con 15 de vida o menos, pasa a Cuenta."])
	assert_str(lectura.tooltip_unidad(Maestro.ID)[0]).is_equal("Maestro")

	lectura = _lectura_rasgos("escenario_junco_salvaje")
	var zancajunco: Criatura = _combate.contexto().plantel.criatura("zancajunco_s1")
	zancajunco.oculta = true
	zancajunco.bono_junco = true
	var tooltip: Array[String] = lectura.tooltip_unidad("zancajunco_s1")
	assert_array(tooltip).contains(["Zancajunco", "Hacerse junco", "Hecho junco", "Embestida"])
	assert_bool(_ficha_de(lectura, "zancajunco_s1")["oculta"]).is_true()
	# T24 (Sistema.md 4.1): la ficha de una salvaje sellable suma su % de sellado (rango 2
	# con la vida completa: 0 %).
	assert_array(_ficha_de(lectura, "zancajunco_s1")["marcas"]).is_equal(["Hecho junco", "Embestida", "0%"])

	# escenario_surco_tribu: el Maestro juega primero; despues el Surcon de la tribu cava.
	lectura = _lectura_rasgos("escenario_surco_tribu")
	assert_bool(_combate.aplicar(Accion.terminar()).valida).is_true()
	assert_str(_combate.turno_actual().unidad_id).is_equal("surcon_1")
	assert_bool(_combate.aplicar(Accion.cavar(Vector2i(3, 5))).valida).is_true()
	assert_str(lectura.tooltip_unidad("surcon_1").back()).is_equal("Arar: 1/2")
	assert_str(lectura.tooltip_unidad("surcon_s1").back()).is_equal("Arar: 0/2")


# (8) Concordancia (A.2.1): con las variantes de es_rasgos.json, el Surcon con
# hambre 0 se ve "Saciado" y caido "Caido"; la Rodauva, "Saciada" y "Caida".
func test_t40_etiquetas_con_concordancia() -> void:
	var lectura: LecturaCombate = _lectura_rasgos("escenario_surco_tribu", {"surcon_1": {"hambre": 0}})
	assert_bool(_combate.aplicar(Accion.terminar()).valida).is_true()
	assert_array(lectura.panel_turno()).contains(["Hambre: 0 (Saciado)"])
	_combate.contexto().plantel.criatura("surcon_1").estado = Criatura.Estado.CAIDA
	assert_array(_ficha_de(lectura, "surcon_1")["marcas"]).contains(["Caído"])
	var resultado: Dictionary = {"desenlace": "victoria", "rondas": 1, "maestro_caido": false,
			"maestro": {"vida": 20}, "unidades": [{"id": "surcon_1", "especie": "surcon", "estado": "caida", "vida": 0}],
			"lealtad_cambios": []}
	assert_str(lectura.resultado(resultado)[4]).contains("Caído")

	lectura = _lectura_rasgos("escenario_c", {"rodauva_1": {"hambre": 0}})
	while _combate.turno_actual().unidad_id != "rodauva_1":
		assert_bool(_combate.aplicar(Accion.terminar()).valida).is_true()
	assert_array(lectura.panel_turno()).contains(["Hambre: 0 (Saciada)"])
	_combate.contexto().plantel.criatura("rodauva_1").estado = Criatura.Estado.CAIDA
	assert_array(_ficha_de(lectura, "rodauva_1")["marcas"]).contains(["Caída"])


# (9) El desglose de un golpe al Tasajero en Caza (escenario_caza: la Ocarra
# [4,3] le pega desde su casilla) nombra la fuente modo con iniciativa.caza:
# +25% recibido (Sistema.md 11.2.3, 11.4 paso 1). Sin [FALTA: desglose.fuente.modo].
func test_t40_desglose_nombra_el_modo() -> void:
	var lectura: LecturaCombate = _lectura_rasgos("escenario_caza")
	var turno: Turno = _combate.turno_actual()
	assert_str(turno.unidad_id).is_equal("ocarra_1")
	var vista_previa: ResultadoAccion = turno.previsualizar_ataque(Vector2i(4, 3), "tasajero_s1")
	assert_bool(vista_previa.valida).is_true()
	var lineas: Array[String] = lectura.desglose(vista_previa.desglose.a_diccionario(), "ocarra_1")
	assert_array(lineas).contains(["Caza: +25%"])
	for linea in lineas:
		assert_str(linea).not_contains("desglose.fuente.modo")


# T14 (11): el panel de la unidad del turno y el tooltip de una criatura de la
# tribu muestran la obediencia (numero y tramo) que da el nucleo; el Maestro y
# las enemigas no tienen. Las claves nuevas no estan en es.json: [FALTA].
func test_t14_panel_y_tooltip_con_obediencia() -> void:
	var lectura: LecturaCombate = _lectura_rasgos("escenario_hambre_combate")
	while _combate.turno_actual().unidad_id != "rodauva_1":
		assert_bool(_combate.aplicar(Accion.terminar()).valida).is_true()
	# Lealtad 7 con hambre 5 (Normal), balanza 2 (umbral 7): 7, leal.
	var linea: String = "[FALTA: panel.obediencia]: 7 ([FALTA: obediencia.tramo.leal])"
	assert_array(lectura.panel_turno()).contains([linea])
	assert_str(lectura.tooltip_unidad("rodauva_1")[2]).is_equal(linea)
	for id_unidad in [Maestro.ID, "ocarra_s1"]:
		for texto in lectura.tooltip_unidad(id_unidad):
			assert_str(texto).not_contains("obediencia")
	while _combate.turno_actual().unidad_id != Maestro.ID:
		assert_bool(_combate.aplicar(Accion.terminar()).valida).is_true()
	for texto in lectura.panel_turno():
		assert_str(texto).not_contains("obediencia")

	# Despues de cerrar la ronda 5 (Sistema.md 7.2): hambre 6, Hambrienta, 5 y neutral.
	while _combate.instantanea()["ronda"] < 6:
		assert_bool(_combate.aplicar(Accion.terminar()).valida).is_true()
	assert_str(lectura.tooltip_unidad("rodauva_1")[2]) \
			.is_equal("[FALTA: panel.obediencia]: 5 ([FALTA: obediencia.tramo.neutral])")


# T14 (11): el hambre de combate da la linea de combate.hambre y una linea por
# cada unidad cuyo estado de hambre cambio (con su sujeto, A.2.1). El Maestro y
# el Surcon caido suben 3 -> 4 sin cambiar de estado: no tienen linea.
func test_t14_suceso_de_hambre_de_combate() -> void:
	var lectura: LecturaCombate = _lectura_rasgos("escenario_hambre_combate")
	while _combate.instantanea()["ronda"] < 6:
		assert_bool(_combate.aplicar(Accion.terminar()).valida).is_true()
	var evento: Dictionary = {}
	for linea in _combate.registro().lineas():
		if linea["tipo"] == "hambre_combate":
			evento = linea
	assert_array(lectura.suceso(evento)).is_equal([
		"La pelea se alarga. A los tuyos les empieza a pesar el estómago vacío.",
		"Rodauva · Hambrienta",
		"Ocarra · Normal",
	])


# T15 (11), Sistema.md 10.3: un ataque con afinidad jugado por el Combate. El
# desglose del evento `ataque` es el de la previsualizacion (el del mouse), con
# la fuente afinidad, y la pantalla lo muestra como "Afinidad: +1". La Ocarra
# [5,4] le pega a la Ocarra salvaje [7,4] con el Surcon [5,5] a su lado.
func test_t15_desglose_del_registro_y_del_mouse_con_afinidad() -> void:
	var lectura: LecturaCombate = _lectura_rasgos("escenario_afinidad",
			{"ocarra_1": {"posicion": [5, 4]}, "surcon_1": {"posicion": [5, 5]}})
	while _combate.turno_actual().unidad_id != "ocarra_1":
		assert_bool(_combate.aplicar(Accion.terminar()).valida).is_true()
	var vista_previa: ResultadoAccion = _combate.turno_actual().previsualizar_ataque(Vector2i(5, 4), "ocarra_s1")
	assert_bool(vista_previa.valida).is_true()
	assert_int(vista_previa.danio).is_equal(4 + 1)
	assert_bool(_combate.aplicar(Accion.atacar("ocarra_s1")).valida).is_true()
	var evento: Dictionary = {}
	for linea in _combate.registro().lineas():
		if linea["tipo"] == "ataque":
			evento = linea
	assert_str(evento["atacante"]).is_equal("ocarra_1")
	assert_dict(evento["desglose"]).is_equal(vista_previa.desglose.a_diccionario())
	var lineas: Array[String] = lectura.desglose(evento["desglose"], "ocarra_1")
	assert_array(lineas).is_equal(lectura.desglose(vista_previa.desglose.a_diccionario(), "ocarra_1"))
	assert_array(lineas).contains(["Afinidad: +1", "Total: 5"])


# T16 (12), Sistema.md 10.2: con el mouse sobre la objetivo de la cadena, el
# desglose muestra el bono del eslabon siguiente, y es el del evento `ataque`.
# El panel de la unidad del turno muestra la cadena en curso (objetivo y eslabon).
# escenario_cadena_combate: el Zancajunco pega a surcon_s1 y despues la Ocarra,
# su rival (sin relacion, +50).
func test_t16_desglose_y_panel_de_la_cadena() -> void:
	var lectura: LecturaCombate = _lectura_rasgos("escenario_cadena_combate")
	assert_str(_combate.turno_actual().unidad_id).is_equal("zancajunco_1")
	for linea in lectura.panel_turno():
		assert_str(linea).not_contains("panel.cadena")
	assert_bool(_combate.aplicar(Accion.atacar("surcon_s1")).valida).is_true()
	assert_bool(_combate.aplicar(Accion.terminar()).valida).is_true()

	assert_str(_combate.turno_actual().unidad_id).is_equal("ocarra_1")
	assert_array(lectura.panel_turno()).contains(["[FALTA: panel.cadena]: Surcón (1)"])
	var vista_previa: ResultadoAccion = _combate.turno_actual().previsualizar_ataque(Vector2i(4, 6), "surcon_s1")
	assert_bool(vista_previa.valida).is_true()
	assert_array(lectura.desglose(vista_previa.desglose.a_diccionario(), "ocarra_1")) \
			.contains(["Cadena: +50%", "Total: 6"])
	assert_bool(_combate.aplicar(Accion.atacar("surcon_s1")).valida).is_true()
	var evento: Dictionary = {}
	for linea in _combate.registro().lineas():
		if linea["tipo"] == "ataque":
			evento = linea
	assert_dict(evento["desglose"]).is_equal(vista_previa.desglose.a_diccionario())
	assert_array(lectura.panel_turno()).contains(["[FALTA: panel.cadena]: Surcón (2)"])


# T21 (12), Sistema.md 2.1: el panel del turno del Maestro y su tooltip muestran
# el mana actual/tope, y cambian despues de la regeneracion; los de una criatura
# no lo muestran. panel.mana no esta en el texto: se ve [FALTA]. El fixture baja
# el mana a mano (en T21 nada lo gasta).
func test_t21_mana_en_panel_y_tooltip() -> void:
	var datos_fixture: Dictionary = DatosFixture.cargar()
	assert_array(datos_fixture["errores"]).is_empty()
	var datos: Dictionary = datos_fixture["datos"]
	var escenario: Dictionary = LectorFixture.leer("res://pruebas/fixtures/combate/escenario_mana_combate.json",
			"escenario")["datos"]
	var textos: Dictionary = LectorFixture.leer(_TEXTOS, "textos")
	var contexto: ContextoCombate = ContextoCombate.armar(escenario, datos)
	contexto.plantel.maestro.mana = 2
	_combate = Combate.empezar(contexto)
	assert_str(_combate.error()).is_empty()
	var lectura: LecturaCombate = LecturaCombate.new(_combate, ArmadorTextos.desde_datos(textos["datos"],
			contexto.azar_textos), EstadosUnidad.desde_datos(datos["tablas/hambre.json"], datos["tablas/lealtad.json"]))
	var tope: int = contexto.plantel.maestro.mana_entrada

	# Turno de la Rodauva: el Maestro todavia no regenero.
	assert_str(_combate.turno_actual().unidad_id).is_equal("rodauva_1")
	for linea in lectura.panel_turno() + lectura.tooltip_unidad("rodauva_1"):
		assert_str(linea).not_contains("panel.mana")
	assert_array(lectura.tooltip_unidad(Maestro.ID)).contains(["[FALTA: panel.mana]: 2/%d" % tope])

	_combate.aplicar(Accion.terminar())
	assert_str(_combate.turno_actual().unidad_id).is_equal(Maestro.ID)
	assert_array(lectura.panel_turno()).contains(["[FALTA: panel.mana]: 3/%d" % tope])
	assert_array(lectura.tooltip_unidad(Maestro.ID)).contains(["[FALTA: panel.mana]: 3/%d" % tope])