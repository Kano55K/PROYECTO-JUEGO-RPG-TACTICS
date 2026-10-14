extends GdUnitTestSuite

# T30-fix, con datos/ real (A.6), solo nucleo: el resellado de la atacante de G
# (Sistema.md 4.4) sale con el % que da la regla, y la consulta es la misma
# cuenta que la tirada (D-005). La prueba manual fallaba siempre porque G tiene
# semilla fija (777) y el resellado es la primera tirada del combate (82 > 80):
# ver P-047. Aca se varian las semillas; la politica de semillas no se toca.
const _CARPETA_DATOS: String = "res://datos"
const _SEMILLAS: int = 2000
# Margen del estadistico, en puntos de porcentaje (pedido por la tarea).
const _MARGEN: float = 3.0
# Semillas para jugar G entero: las primeras N y la del escenario.
const _SEMILLAS_JUGADAS: int = 10

var _datos: Dictionary = {}


func _cargar() -> Dictionary:
	if _datos.is_empty():
		var carga: Dictionary = Cargador.new().cargar_carpeta(_CARPETA_DATOS)
		assert_array(carga["errores"]).override_failure_message(str(carga["errores"])).is_empty()
		_datos = carga["datos"]
	return _datos


func _escenario(semilla: int = -1) -> Dictionary:
	var escenario: Dictionary = (_cargar()[JugadorG.ESCENARIO] as Dictionary).duplicate(true)
	if semilla >= 0:
		escenario["semilla"] = semilla
	return escenario


func _jugado(semilla: int) -> Combate:
	var contexto: ContextoCombate = ContextoCombate.armar(_escenario(semilla), _cargar())
	assert_bool(contexto.valido).is_true()
	var combate: Combate = Combate.empezar(contexto)
	assert_str(JugadorG.hasta_el_destino(combate)).is_empty()
	return combate


# Estadistico: 2000 semillas, cada una con su generador de combate derivado como
# lo arma ContextoCombate (A.8) y un Plantel nuevo de G con la Ocarra caida en 0.
# La tasa de exito queda a menos de 3 puntos del % de la regla (leido, no escrito).
func test_el_resellado_sale_con_el_porcentaje_de_la_regla() -> void:
	var datos: Dictionary = _cargar()
	var escenario: Dictionary = _escenario()
	var contexto: ContextoCombate = ContextoCombate.armar(escenario, datos)
	assert_bool(contexto.valido).is_true()
	var regla: DestinoAtacante = contexto.destino_atacante
	var porcentaje: int = regla.porcentaje(contexto.plantel.criatura(JugadorG.OCARRA).especie)
	assert_int(porcentaje).is_greater(0)
	var exitos: int = 0
	for semilla in range(1, _SEMILLAS + 1):
		var plantel: Plantel = Plantel.desde_datos(datos, escenario)
		var ocarra: Criatura = plantel.criatura(JugadorG.OCARRA)
		ocarra.vida = 0
		ocarra.estado = Criatura.Estado.CAIDA
		var azar: GeneradorAzar = GeneradorAzar.derivado(semilla, ContextoCombate.SISTEMA_COMBATE)
		var resultado: ResultadoAccion = regla.resolver(DestinoAtacante.OPCION_SELLAR, JugadorG.OCARRA, plantel,
				AcumuladorLealtad.desde_datos(datos["tablas/lealtad.json"]), false, azar, Surcos.new(), true)
		assert_bool(resultado.valida).is_true()
		if resultado.evento["resultado"] == DestinoAtacante.RESULTADO_SELLADA:
			exitos += 1
	var tasa: float = 100.0 * exitos / _SEMILLAS
	assert_float(tasa).override_failure_message("tasa %.2f %% con %d %%" % [tasa, porcentaje]) \
			.is_between(porcentaje - _MARGEN, porcentaje + _MARGEN)


# Consulta = tirada (D-005): con G jugado hasta el destino, el % de
# previsualizar_destino("sellar") es el que usa la tirada registrada: el
# ResultadoAccion aplicado lleva el mismo %, y la ultima `tirada` sale si y solo si
# el resultado es `sellada`. Con varias semillas aparecen las dos salidas.
func test_el_porcentaje_de_la_consulta_es_el_de_la_tirada() -> void:
	var semillas: Array[int] = [_escenario()["semilla"]]
	for semilla in range(1, _SEMILLAS_JUGADAS + 1):
		semillas.append(semilla)
	var vistos: Dictionary = {}
	for semilla in semillas:
		var combate: Combate = _jugado(semilla)
		var previa: ResultadoAccion = combate.previsualizar_destino(DestinoAtacante.OPCION_SELLAR)
		assert_bool(previa.valida).is_true()
		var aplicado: ResultadoAccion = combate.aplicar(Accion.destino_atacante(DestinoAtacante.OPCION_SELLAR))
		assert_bool(aplicado.valida).is_true()
		assert_int(aplicado.porcentaje).is_equal(previa.porcentaje)
		assert_int(aplicado.costo).is_equal(previa.costo)
		var tirada: Dictionary = {}
		var destino: Dictionary = {}
		for linea in combate.registro().lineas():
			if linea["tipo"] == "tirada":
				tirada = linea
			elif linea["tipo"] == "destino_atacante":
				destino = linea
		assert_dict(tirada).is_not_empty()
		assert_bool(Porcentajes.sale(tirada["resultado"], previa.porcentaje)) \
				.is_equal(destino["resultado"] == DestinoAtacante.RESULTADO_SELLADA)
		vistos[destino["resultado"]] = true
		# Sistema.md 4.4: tras un fallo, sellar ya no vale.
		if destino["resultado"] == DestinoAtacante.RESULTADO_SELLADO_FALLIDO:
			assert_int(combate.motivo_destino(DestinoAtacante.OPCION_SELLAR)) \
					.is_equal(ResultadoAccion.Motivo.SELLAR_YA_FALLO)
	assert_bool(vistos.has(DestinoAtacante.RESULTADO_SELLADA)).is_true()
	assert_bool(vistos.has(DestinoAtacante.RESULTADO_SELLADO_FALLIDO)).is_true()
