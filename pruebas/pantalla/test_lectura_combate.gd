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
