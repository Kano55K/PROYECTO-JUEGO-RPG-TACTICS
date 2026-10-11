extends GdUnitTestSuite

# Arquitectura.md B.4 (T24), criterio 10: los sucesos del evento `sellado` (fallo,
# fallo con la objetivo erizada y logrado) y el boton con varios costos. Que este
# erizada lo mira la pantalla en la instantanea del nucleo (S-51). Fixtures
# (A.6): escenario_sellar.json con las especies inventadas de T24 (MesaSellar),
# es_rasgos.json y copias textuales de datos/textos/es.json. Mundo.md 5.
const _ESCENARIO: String = "res://pruebas/fixtures/combate/escenario_sellar.json"
const _TEXTOS: String = "res://pruebas/fixtures/pantalla/es_rasgos.json"
# Copias textuales de datos/textos/es.json v1.3.
const _TEXTOS_SELLAR: Dictionary = {
	"accion.sellar": "Sellar",
	"panel.mana": "Maná",
	"sellar.exito": "El hilo {criatura_la} encuentra y se tensa. {criatura} se achica hasta caber en el pergamino, y la hoja deja de estar en blanco.",
	"sellar.fallo": "El hilo {criatura_la} roza y se suelta. El maná ya se fue.",
	"sellar.fallo.erizada": "El hilo resbala entre las púas.",
	"sellar.fallo.surcon": "El hilo se le enreda en los terrones y se cae con ellos.",
}

var _combate: Combate


func _lectura() -> LecturaCombate:
	var lectura: Dictionary = DatosFixture.cargar()
	assert_array(lectura["errores"]).is_empty()
	var datos: Dictionary = lectura["datos"]
	datos.merge(MesaSellar.fichas_t24())
	var textos: Dictionary = LectorFixture.leer(_TEXTOS, "textos")["datos"]
	textos.merge(_TEXTOS_SELLAR, true)
	var contexto: ContextoCombate = ContextoCombate.armar(LectorFixture.leer(_ESCENARIO, "escenario")["datos"], datos)
	assert_bool(contexto.valido).is_true()
	_combate = Combate.empezar(contexto)
	assert_str(_combate.error()).is_empty()
	return LecturaCombate.new(_combate, ArmadorTextos.desde_datos(textos, contexto.azar_textos),
			EstadosUnidad.desde_datos(datos["tablas/hambre.json"], datos["tablas/lealtad.json"]))


func _sellado(objetivo: String, resultado: String) -> Dictionary:
	return {"tipo": "sellado", "objetivo": objetivo, "porcentaje": 5, "tiro": 50, "resultado": resultado,
			"pergamino": null, "n": 1, "ronda": 1}


# (10) Fallo: la linea general (la Ocarra no tiene variante) o la de la especie
# (el Surcon); con la objetivo erizada en la instantanea, la de las puas.
func test_sucesos_de_fallo() -> void:
	var lectura: LecturaCombate = _lectura()
	assert_array(lectura.suceso(_sellado("ocarra_s1", "fallido"))) \
			.is_equal(["El hilo la roza y se suelta. El maná ya se fue."])
	assert_array(lectura.suceso(_sellado("surcon_s1", "fallido"))) \
			.is_equal(["El hilo se le enreda en los terrones y se cae con ellos."])
	assert_array(lectura.suceso(_sellado("rodauva_s1", "fallido"))) \
			.is_equal(["El hilo la roza y se suelta. El maná ya se fue."])
	_combate.contexto().plantel.criatura("rodauva_s1").erizada = true
	assert_array(lectura.suceso(_sellado("rodauva_s1", "fallido"))).is_equal(["El hilo resbala entre las púas."])


# (10) Logrado: sellar.exito, con la objetivo como hueco (y aunque este erizada).
func test_suceso_logrado() -> void:
	var lectura: LecturaCombate = _lectura()
	_combate.contexto().plantel.criatura("rodauva_s1").erizada = true
	assert_array(lectura.suceso(_sellado("rodauva_s1", "logrado"))).is_equal([
			"El hilo la encuentra y se tensa. La Rodauva se achica hasta caber en el pergamino, y la hoja deja de estar en blanco."])
	assert_array(lectura.suceso({"tipo": "accion", "unidad": Maestro.ID, "origen": "jugador",
			"accion": {"tipo": "sellar", "objetivo": "ocarra_s1"}, "paso": null, "n": 1, "ronda": 1})) \
			.is_equal(["Maestro · Sellar"])


# (10) El boton lleva los costos distintos de las salvajes que se podrian sellar
# (rango 1: 3; rango 2: 5; la no sellable no cuenta), solo en el turno del Maestro.
func test_boton_con_varios_costos() -> void:
	var lectura: LecturaCombate = _lectura()
	for _i in range(10):
		if _combate.turno_actual().unidad_id == Maestro.ID:
			break
		assert_bool(_combate.aplicar(Accion.terminar()).valida).is_true()
	assert_str(_combate.turno_actual().unidad_id).is_equal(Maestro.ID)
	var boton: Dictionary = lectura.boton_sellar()
	assert_str(boton["texto"]).is_equal("Sellar (3/5 Maná)")
	assert_bool(_combate.aplicar(Accion.terminar()).valida).is_true()
	if _combate.turno_actual() != null and _combate.turno_actual().unidad_id != Maestro.ID:
		assert_dict(lectura.boton_sellar()).is_empty()
