extends GdUnitTestSuite

# Arquitectura.md B.4 (T26), criterio 14: lo que LecturaCombate arma para guardar
# e invocar: los sucesos (claves guardar e invocar con la criatura como hueco), el
# boton Guardar solo cuando Turno.motivo_guardar lo deja y los botones de invocar
# con el costo de Combate.costo_invocar y el motivo de Turno.motivo_invocar.
# Fixtures (A.6): escenario_guardar_invocar_combate.json (balanza 2: invocar a la
# Rodauva cuesta 2), es_rasgos.json y copias textuales de datos/textos/es.json.
# Sistema.md 3.1 y 2.3.
const _ESCENARIO: String = "res://pruebas/fixtures/combate/escenario_guardar_invocar_combate.json"
const _TEXTOS: String = "res://pruebas/fixtures/pantalla/es_rasgos.json"
# Copias textuales de datos/textos/es.json.
const _TEXTOS_T26: Dictionary = {
	"accion.guardar": "Guardar",
	"accion.invocar": "Invocar",
	"panel.mana": "Maná",
	"guardar": "{criatura} toca el pergamino y el hilo {criatura_la} recoge.",
	"guardar.tooltip": "A salvo hasta que la saques. Mientras tanto, no gana ni pierde nada.",
	"invocar": "Desenrollás el pergamino. {criatura} sale parpadeando: para {criatura_ella}, no pasó el tiempo.",
	"invocar.tooltip": "Llega en la ronda que viene.",
}

var _combate: Combate


func _lectura() -> LecturaCombate:
	var lectura: Dictionary = DatosFixture.cargar()
	assert_array(lectura["errores"]).is_empty()
	var datos: Dictionary = lectura["datos"]
	var textos: Dictionary = LectorFixture.leer(_TEXTOS, "textos")["datos"]
	textos.merge(_TEXTOS_T26, true)
	var contexto: ContextoCombate = ContextoCombate.armar(LectorFixture.leer(_ESCENARIO, "escenario")["datos"], datos)
	assert_bool(contexto.valido).is_true()
	_combate = Combate.empezar(contexto)
	assert_str(_combate.error()).is_empty()
	return LecturaCombate.new(_combate, ArmadorTextos.desde_datos(textos, contexto.azar_textos),
			EstadosUnidad.desde_datos(datos["tablas/hambre.json"], datos["tablas/lealtad.json"]))


# (14) Los sucesos: la accion guardar y el evento invocacion, con la criatura.
func test_sucesos() -> void:
	var lectura: LecturaCombate = _lectura()
	assert_array(lectura.suceso({"tipo": "accion", "unidad": "rodauva_1", "origen": "jugador",
			"accion": {"tipo": "guardar"}, "paso": null, "n": 1, "ronda": 1})) \
			.is_equal(["La Rodauva toca el pergamino y el hilo la recoge."])
	assert_array(lectura.suceso({"tipo": "invocacion", "unidad": "rodauva_g", "casilla": [5, 2], "n": 1, "ronda": 1})) \
			.is_equal(["Desenrollás el pergamino. La Rodauva sale parpadeando: para ella, no pasó el tiempo."])
	# La accion invocar no tiene linea propia: la dice la invocacion.
	assert_array(lectura.suceso({"tipo": "accion", "unidad": Maestro.ID, "origen": "jugador",
			"accion": {"tipo": "invocar", "criatura": "rodauva_g", "casilla": [5, 2]}, "paso": null, "n": 1,
			"ronda": 1})).is_empty()


# (14) Guardar: con la Rodauva junto al Maestro, el boton; lejos, nada; en el
# turno del Maestro, nada.
func test_boton_guardar_solo_cuando_vale() -> void:
	var lectura: LecturaCombate = _lectura()
	assert_str(_combate.turno_actual().unidad_id).is_equal("rodauva_1")
	assert_dict(lectura.boton_guardar()).is_equal({"texto": "Guardar",
			"tooltip": "A salvo hasta que la saques. Mientras tanto, no gana ni pierde nada."})
	assert_array(lectura.botones_invocar()).is_empty()
	assert_bool(_combate.aplicar(Accion.mover(Vector2i(4, 2))).valida).is_true()
	assert_dict(lectura.boton_guardar()).is_empty()
	assert_bool(_combate.aplicar(Accion.terminar()).valida).is_true()
	assert_str(_combate.turno_actual().unidad_id).is_equal(Maestro.ID)
	assert_dict(lectura.boton_guardar()).is_empty()


# (14) Invocar: un boton por guardada, con nombre y costo; deshabilitado con su
# motivo despues de moverse.
func test_botones_invocar_con_costo_y_motivo() -> void:
	var lectura: LecturaCombate = _lectura()
	assert_bool(_combate.aplicar(Accion.terminar()).valida).is_true()
	assert_array(lectura.botones_invocar()).is_equal([{"criatura": "rodauva_g", "habilitado": true,
			"tooltip": "Llega en la ronda que viene.", "texto": "Invocar Rodauva (2 Maná)"}])
	assert_bool(_combate.aplicar(Accion.mover(Vector2i(6, 1))).valida).is_true()
	assert_array(lectura.botones_invocar()).is_equal([{"criatura": "rodauva_g", "habilitado": false,
			"tooltip": "Llega en la ronda que viene.\n[FALTA: aviso.invocar.ya_se_movio]",
			"texto": "Invocar Rodauva (2 Maná)"}])
