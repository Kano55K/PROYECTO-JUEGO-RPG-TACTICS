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


# La cola de C con Caza y Cuenta, y la entrada actual (el Zancajunco).
func test_filas_cola() -> void:
	var lectura: LecturaCombate = _lectura()
	var textos: Array[String] = []
	var actuales: Array[bool] = []
	for fila in lectura.filas_cola():
		textos.append(fila["texto"])
		actuales.append(fila["actual"])
	assert_array(textos).is_equal(["Zancajunco", "Tasajero · Caza", "Ocarra", "Rodauva",
			"[FALTA: maestro.nombre]", "Tasajero · Cuenta"])
	assert_array(actuales).is_equal([true, false, false, false, false, false])


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
