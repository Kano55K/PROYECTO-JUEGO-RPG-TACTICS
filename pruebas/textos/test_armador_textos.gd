extends GdUnitTestSuite

# Arquitectura.md B.2 (T34): armador de textos, con el fixture propio de
# pruebas/fixtures/textos/ (A.6), nunca datos/. Mundo.md 1.5 y A.2.1.
const _CARPETA: String = "res://pruebas/fixtures/textos/"
const _CARPETA_COMBATE: String = "res://pruebas/fixtures/combate/"
const _SEMILLA: int = 1234
const _PEDIDOS: int = 20


func _textos(archivo: String = "es.json") -> Dictionary:
	var lectura: Dictionary = LectorFixture.leer(_CARPETA + archivo, "textos")
	var errores: Array[Dictionary] = lectura["errores"]
	assert_array(errores).override_failure_message(str(errores)).is_empty()
	return lectura["datos"]


func _armador(semilla: int = _SEMILLA) -> ArmadorTextos:
	return ArmadorTextos.desde_datos(_textos(), GeneradorAzar.new(semilla))


func _motivos(avisos: Array[Dictionary]) -> Array[String]:
	var resultado: Array[String] = []
	for aviso in avisos:
		resultado.append(ArmadorTextos.Motivo.keys()[aviso["motivo"]])
	return resultado


func _molino(armador: ArmadorTextos, intercalar: bool) -> Array[String]:
	var resultado: Array[String] = []
	for i in range(_PEDIDOS):
		if intercalar:
			armador.armar("sellar.tooltip", {"porcentaje": 40, "criatura": HuecoCriatura.new("rodauva")})
			armador.armar("caida", {"criatura": HuecoCriatura.new("surcon")}, "surcon")
		resultado.append(armador.armar("noche.molino"))
	return resultado


# (1) Mundo.md 1.5: "¿{criatura}?" con la Rodauva da "¿La Rodauva?".
func test_pregunta_con_mayuscula() -> void:
	var armador: ArmadorTextos = _armador()
	assert_str(armador.armar("comer.elegir", {"criatura": HuecoCriatura.new("rodauva")})).is_equal("¿La Rodauva?")
	assert_array(armador.avisos()).is_empty()


# (2) Mundo.md 1.5, tabla de huecos gramaticales: seis formas por rol.
func test_formas_de_rol() -> void:
	var armador: ArmadorTextos = _armador()
	var surcon: HuecoCriatura = HuecoCriatura.new("surcon")
	var rodauva: HuecoCriatura = HuecoCriatura.new("rodauva")
	assert_str(armador.armar("prueba.formas", {"rival": surcon, "criatura": surcon})).is_equal(
			"Formas: al Surcón, del Surcón, flaco, lo, él")
	assert_str(armador.armar("prueba.formas", {"rival": rodauva, "criatura": rodauva})).is_equal(
			"Formas: a la Rodauva, de la Rodauva, flaca, la, ella")
	assert_str(armador.armar("incidente.distraida", {"criatura": HuecoCriatura.new("ocarra"), "rival": surcon})).is_equal(
			"La Ocarra no le saca el ojo al Surcón. Se le va el turno mirándolo.")
	assert_array(armador.avisos()).is_empty()


# (3) Mayuscula al empezar y despues de . ? ! ¿ ¡, tambien con tilde; lo demas igual.
func test_mayusculas() -> void:
	var armador: ArmadorTextos = _armador()
	assert_str(armador.armar("prueba.mayusculas", {"criatura": HuecoCriatura.new("surcon")})).is_equal(
			"Él cae. Él se levanta. ¡Él sigue, y la Rodauva no!")


# (4) <clave>.maestro y <clave>.<especie> reemplazan a la base; sin variante, la base.
func test_variantes_reemplazan() -> void:
	var armador: ArmadorTextos = _armador()
	var datos: Dictionary = {"criatura": HuecoCriatura.new("rodauva")}
	assert_str(armador.armar("hambre.estado.famelico", {}, "maestro")).is_equal("Famélico")
	assert_str(armador.armar("hambre.estado.famelico", {}, "rodauva")).is_equal("Famélica")
	assert_str(armador.armar("hambre.estado.famelico")).is_equal("Famélica")
	assert_str(armador.armar("sellar.fallo", datos, "surcon")).is_equal(
			"El hilo se le enreda en los terrones y se cae con ellos.")
	assert_str(armador.armar("sellar.fallo", datos, "rodauva")).is_equal(
			"El hilo la roza y se suelta. El maná ya se fue.")
	assert_array(armador.avisos()).is_empty()


# (5) caida.* es complemento: base y variante del sujeto en dos lineas.
func test_complementos() -> void:
	assert_array(ArmadorTextos.PREFIJOS_COMPLEMENTO).is_equal(["caida.", "nocturno.base.", "nocturno.raso."])
	var armador: ArmadorTextos = _armador()
	var lineas: Array[String] = armador.armar_lineas("caida", {"criatura": HuecoCriatura.new("rodauva")}, "rodauva")
	assert_array(lineas).is_equal([
		"La Rodauva cae y no se levanta. Todavía respira.",
		"Queda hecha bola, quieta. Las frutas se le cayeron de las púas.",
	])
	assert_str(armador.armar("caida", {"criatura": HuecoCriatura.new("rodauva")}, "rodauva")).is_equal(
			lineas[0] + "\n" + lineas[1])
	assert_array(armador.armar_lineas("caida", {"criatura": HuecoCriatura.new("tasajero")}, "tasajero")).is_equal([
		"El Tasajero cae y no se levanta. Todavía respira.",
	])
	assert_array(armador.avisos()).is_empty()


# (6) Lo que falta no rompe: [FALTA: clave] y [FALTA: hueco], cada uno con su aviso.
func test_faltantes() -> void:
	var armador: ArmadorTextos = _armador()
	assert_str(armador.armar("no.existe")).is_equal("[FALTA: no.existe]")
	assert_array(_motivos(armador.avisos())).is_equal(["CLAVE_FALTANTE"])
	assert_str(armador.avisos()[0]["clave"]).is_equal("no.existe")
	assert_str(armador.armar("incidente.distraida", {"criatura": HuecoCriatura.new("ocarra")})).is_equal(
			"La Ocarra no le saca el ojo [FALTA: a_rival]. Se le va el turno mirándol[FALTA: rival_o].")
	assert_array(_motivos(armador.avisos())).is_equal(["CLAVE_FALTANTE", "HUECO_SIN_DATO", "HUECO_SIN_DATO"])
	assert_str(armador.avisos()[1]["hueco"]).is_equal("a_rival")
	assert_str(armador.avisos()[2]["clave"]).is_equal("incidente.distraida")
	# Una forma de rol sobre un literal no es una criatura.
	assert_str(armador.armar("comer.elegir", {"criatura": "Rodauva"})).is_equal("¿Rodauva?")
	assert_str(armador.armar("sellar.fallo", {"criatura": "Rodauva"})).is_equal(
			"El hilo [FALTA: criatura_la] roza y se suelta. El maná ya se fue.")
	assert_str(_motivos(armador.avisos()).back()).is_equal("HUECO_NO_ES_CRIATURA")


# (7) Lista de variantes: misma semilla, misma secuencia; otra semilla, otra.
func test_variantes_al_azar_con_semilla() -> void:
	var opciones: Array = _textos()["noche.molino"]
	var primera: Array[String] = _molino(_armador(_SEMILLA), false)
	var segunda: Array[String] = _molino(_armador(_SEMILLA), false)
	var otra: Array[String] = _molino(_armador(_SEMILLA + 1), false)
	assert_array(segunda).is_equal(primera)
	assert_array(otra).is_not_equal(primera)
	for texto in primera + otra:
		assert_bool(opciones.has(texto)).is_true()


# (8) Un texto suelto no consume tirada.
func test_texto_suelto_no_tira() -> void:
	var generador_a: GeneradorAzar = GeneradorAzar.new(_SEMILLA)
	var generador_b: GeneradorAzar = GeneradorAzar.new(_SEMILLA)
	var solo: Array[String] = _molino(ArmadorTextos.desde_datos(_textos(), generador_a), false)
	var intercalado: Array[String] = _molino(ArmadorTextos.desde_datos(_textos(), generador_b), true)
	assert_array(intercalado).is_equal(solo)
	assert_int(generador_a.historial().size()).is_equal(_PEDIDOS)
	assert_int(generador_b.historial().size()).is_equal(_PEDIDOS)


# (9) revisar avisa de huecos mal formados, corchetes sin convertir y llaves sin cerrar.
func test_revisar() -> void:
	var avisos: Array[Dictionary] = ArmadorTextos.revisar(_textos("es_mal_formado.json"))
	var encontrados: Array[String] = []
	for aviso in avisos:
		encontrados.append("%s|%s|%s" % [aviso["clave"], ArmadorTextos.Motivo.keys()[aviso["motivo"]], aviso["fragmento"]])
	encontrados.sort()
	assert_array(encontrados).is_equal([
		"prueba.corchetes|CORCHETE_SIN_CONVERTIR|[Criatura]",
		"prueba.espacios|HUECO_MAL_FORMADO|{ criatura }",
		"prueba.lista|HUECO_MAL_FORMADO|{Rival}",
		"prueba.mayuscula|HUECO_MAL_FORMADO|{Criatura}",
		"prueba.sin_cerrar|LLAVE_SIN_CERRAR|{criatura se levanta.",
	])
	assert_array(ArmadorTextos.revisar(_textos())).is_empty()


# (10) Un valor que no es criatura va literal.
func test_literal() -> void:
	var armador: ArmadorTextos = _armador()
	assert_str(armador.armar("sellar.tooltip", {"porcentaje": 40, "criatura": HuecoCriatura.new("rodauva")})).is_equal(
			"40% de que el hilo la sujete. Si se suelta, el maná se pierde igual.")
	assert_array(armador.avisos()).is_empty()


# (11) Armar textos con el generador de textos durante un combate no cambia su
# registro ni su instantanea (A.8: generadores separados).
func test_no_toca_el_combate() -> void:
	var sin_textos: Combate = _jugar_ronda_c(false)
	var con_textos: Combate = _jugar_ronda_c(true)
	assert_array(con_textos.registro().lineas_json()).is_equal(sin_textos.registro().lineas_json())
	assert_dict(con_textos.instantanea()).is_equal(sin_textos.instantanea())
	assert_int(con_textos.contexto().azar_textos.historial().size()).is_greater(0)
	assert_int(sin_textos.contexto().azar_textos.historial().size()).is_equal(0)


func _jugar_ronda_c(armar_textos: bool) -> Combate:
	var lectura_datos: Dictionary = DatosFixture.cargar()
	var errores_datos: Array[Dictionary] = lectura_datos["errores"]
	assert_array(errores_datos).override_failure_message(str(errores_datos)).is_empty()
	var lectura: Dictionary = LectorFixture.leer(_CARPETA_COMBATE + "escenario_c.json", "escenario")
	var errores: Array[Dictionary] = lectura["errores"]
	assert_array(errores).override_failure_message(str(errores)).is_empty()
	var contexto: ContextoCombate = ContextoCombate.armar(lectura["datos"], lectura_datos["datos"])
	assert_bool(contexto.valido).is_true()
	var combate: Combate = Combate.empezar(contexto)
	assert_str(combate.error()).is_empty()
	var armador: ArmadorTextos = ArmadorTextos.desde_datos(_textos(), contexto.azar_textos)
	while combate.instantanea()["ronda"] == 1:
		if armar_textos:
			armador.armar("noche.molino")
			armador.armar("caida", {"criatura": HuecoCriatura.new("rodauva")}, "rodauva")
		var resultado: ResultadoAccion = combate.aplicar(Accion.terminar())
		assert_bool(resultado.valida).is_true()
	return combate


# T19, sesion 2: si una clave tiene texto (para elegir entre la reaccion del par
# y la linea general, Mundo.md 5). No avisa ni toca el generador.
func test_tiene() -> void:
	var armador: ArmadorTextos = _armador()
	assert_bool(armador.tiene("noche.molino")).is_true()
	assert_bool(armador.tiene("no.existe")).is_false()
	assert_bool(armador.tiene("_nota")).is_false()
	assert_array(armador.avisos()).is_empty()
