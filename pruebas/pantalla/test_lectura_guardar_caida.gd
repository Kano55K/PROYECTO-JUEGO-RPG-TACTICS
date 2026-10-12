extends GdUnitTestSuite

# Arquitectura.md B.4 (T27), criterio 13: lo que LecturaCombate arma para guardar
# a una caida: el boton con el costo de Combate.costo_guardar_caida y el motivo
# de Turno.motivo_guardar_caida, la vista previa (mana y vida de
# Turno.previsualizar_guardar_caida) y los sucesos (la accion y guardar_caida con
# el hueco {caida}). Fixtures (A.6): escenario_guardar_caida_combate.json (en la
# ronda 1 la Ocarra tumba a rodauva_1, a distancia 2 del Maestro; balanza 2:
# cuesta 2), es_rasgos.json y copias textuales de datos/textos/es.json.
# Sistema.md 11.5 y 2.3.
const _ESCENARIO: String = "res://pruebas/fixtures/combate/escenario_guardar_caida_combate.json"
const _TEXTOS: String = "res://pruebas/fixtures/pantalla/es_rasgos.json"
const _CAIDA: String = "rodauva_1"
const _TOPE_ACCIONES: int = 20
# Copias textuales de datos/textos/es.json.
const _TEXTOS_T27: Dictionary = {
	"accion.guardar_caida": "Guardar a la caída",
	"panel.mana": "Maná",
	"guardar_caida": "Tendés el pergamino hacia {caida}. El hilo {caida_la} encuentra donde cayó y {caida_la} recoge.",
	"guardar_caida.tooltip": "Guardada con lo justo para respirar. No se cura hasta que salga.",
}

var _combate: Combate


# maestro_en: otra casilla para el Maestro (SIN_POSICION: la del escenario).
func _lectura(maestro_en: Vector2i = Criatura.SIN_POSICION) -> LecturaCombate:
	var lectura: Dictionary = DatosFixture.cargar()
	assert_array(lectura["errores"]).is_empty()
	var datos: Dictionary = lectura["datos"]
	var textos: Dictionary = LectorFixture.leer(_TEXTOS, "textos")["datos"]
	textos.merge(_TEXTOS_T27, true)
	var escenario: Dictionary = LectorFixture.leer(_ESCENARIO, "escenario")["datos"]
	if maestro_en != Criatura.SIN_POSICION:
		escenario["maestro"]["posicion"] = [maestro_en.x, maestro_en.y]
	var contexto: ContextoCombate = ContextoCombate.armar(escenario, datos)
	assert_bool(contexto.valido).is_true()
	_combate = Combate.empezar(contexto)
	assert_str(_combate.error()).is_empty()
	return LecturaCombate.new(_combate, ArmadorTextos.desde_datos(textos, contexto.azar_textos),
			EstadosUnidad.desde_datos(datos["tablas/hambre.json"], datos["tablas/lealtad.json"]))


func _hasta_el_maestro() -> void:
	for _i in range(_TOPE_ACCIONES):
		if _combate.turno_actual().unidad_id == Maestro.ID:
			return
		assert_bool(_combate.aplicar(Accion.terminar()).valida).is_true()
	fail("no llego el turno del Maestro")


# (13) Los sucesos: el Maestro nombra la accion y guardar_caida dice a la caida.
func test_sucesos() -> void:
	var lectura: LecturaCombate = _lectura()
	assert_array(lectura.suceso({"tipo": "accion", "unidad": Maestro.ID, "origen": "jugador",
			"accion": {"tipo": "guardar_caida", "objetivo": _CAIDA}, "paso": null, "n": 1, "ronda": 1})) \
			.is_equal(["%s · Guardar a la caída" % lectura.nombre(Maestro.ID)])
	assert_array(lectura.suceso({"tipo": "guardado_caida", "unidad": _CAIDA, "vida": 1, "n": 1, "ronda": 1})) \
			.is_equal(["Tendés el pergamino hacia la Rodauva. El hilo la encuentra donde cayó y la recoge."])


# (13) El boton en el turno del Maestro, con el costo y el tooltip; con la
# caida a distancia 2, habilitado.
func test_boton_con_costo() -> void:
	var lectura: LecturaCombate = _lectura()
	_hasta_el_maestro()
	var boton: Dictionary = lectura.boton_guardar_caida()
	assert_str(boton["texto"]).is_equal("Guardar a la caída (2 Maná)")
	assert_bool(boton["habilitado"]).is_true()
	assert_str(boton["tooltip"]).is_equal("Guardada con lo justo para respirar. No se cura hasta que salga.")


# (13) Con el Maestro lejos, deshabilitado con el motivo de Turno.motivo_guardar_caida.
func test_boton_deshabilitado_con_el_motivo() -> void:
	var lectura: LecturaCombate = _lectura(Vector2i(7, 7))
	_hasta_el_maestro()
	assert_int(_combate.turno_actual().motivo_guardar_caida()).is_equal(ResultadoAccion.Motivo.FUERA_DE_ALCANCE)
	var boton: Dictionary = lectura.boton_guardar_caida()
	assert_str(boton["texto"]).is_equal("Guardar a la caída (2 Maná)")
	assert_bool(boton["habilitado"]).is_false()
	assert_str(boton["tooltip"]).is_equal("Guardada con lo justo para respirar. No se cura hasta que salga.\n"
			+ "[FALTA: aviso.guardar_caida.fuera_de_alcance]")


# (13) La vista previa: el mana y la vida de -> a; nada si no vale.
func test_vista_previa() -> void:
	var lectura: LecturaCombate = _lectura()
	_hasta_el_maestro()
	var previa: ResultadoAccion = _combate.turno_actual().previsualizar_guardar_caida(_CAIDA)
	assert_array(lectura.vista_previa_guardar_caida(previa)).is_equal(["Maná: 8 → 6", "Vida: 0 → 1"])
	assert_array(lectura.vista_previa_guardar_caida(
			_combate.turno_actual().previsualizar_guardar_caida("rodauva_2"))).is_empty()
