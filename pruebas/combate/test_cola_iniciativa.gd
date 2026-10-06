extends GdUnitTestSuite

# Arquitectura.md B.2 (T07): cola de iniciativa, con fixtures (A.6).
# Sistema.md 10.1, 11.2 y 11.3 (filas Orden, Empates y Criatura invocada).
const _CARPETA: String = "res://pruebas/fixtures/combate/"
const _CARPETA_UNIDADES: String = "res://pruebas/fixtures/unidades/"
const _ESPECIES: Array[String] = ["ocarra", "rodauva", "surcon", "tasajero", "zancajunco"]
const _FUENTES: Array[String] = [
	"res://nucleo/combate/cola_iniciativa.gd",
	"res://nucleo/combate/entrada_cola.gd",
]
const _AZAR_PROHIBIDO: Array[String] = ["GeneradorAzar", "randi", "randf", "RandomNumberGenerator"]


func _leer(ruta: String, nombre_esquema: String) -> Dictionary:
	var lectura: Dictionary = LectorFixture.leer(ruta, nombre_esquema)
	var errores: Array[Dictionary] = lectura["errores"]
	assert_array(errores).override_failure_message(str(errores)).is_empty()
	return lectura["datos"]


func _escenario(ruta: String) -> Dictionary:
	return _leer(ruta, "escenario")


# reemplazos: id de especie -> ruta de una ficha de prueba que reemplaza a la normal.
func _plantel(escenario: Dictionary, reemplazos: Dictionary = {}) -> Plantel:
	var especies: Dictionary = {}
	for id_especie in _ESPECIES:
		var ruta: String = reemplazos.get(id_especie, _CARPETA_UNIDADES + id_especie + ".json")
		especies[id_especie] = Especie.new(_leer(ruta, "especie"))
	var tabla: TablaBalanza = TablaBalanza.new(_leer(_CARPETA_UNIDADES + "balanza_1_2.json", "balanza"))
	return Plantel.desde_escenario(escenario, especies, tabla, _leer(_CARPETA_UNIDADES + "maestro.json", "maestro"))


func _cola(plantel: Plantel) -> ColaIniciativa:
	var cola: ColaIniciativa = ColaIniciativa.new()
	cola.empezar_ronda(plantel)
	return cola


# "id" o "id:marca", en el orden de la cola.
func _orden(cola: ColaIniciativa) -> Array[String]:
	var resultado: Array[String] = []
	for entrada in cola.entradas():
		resultado.append(entrada.unidad_id if entrada.marca.is_empty() else entrada.unidad_id + ":" + entrada.marca)
	return resultado


# Recorre lo que queda de la ronda, como lo haria el combate.
func _recorrer(cola: ColaIniciativa, plantel: Plantel) -> Array[String]:
	var resultado: Array[String] = []
	var entrada: EntradaCola = cola.siguiente(plantel)
	while entrada != null:
		resultado.append(entrada.unidad_id if entrada.marca.is_empty() else entrada.unidad_id + ":" + entrada.marca)
		entrada = cola.siguiente(plantel)
	return resultado


# (1) Sistema.md 11.6, Prueba A: Ocarra (7), Rodauva (6), Maestro (5).
func test_prueba_a() -> void:
	var plantel: Plantel = _plantel(_escenario(_CARPETA_UNIDADES + "escenario_a.json"))
	assert_array(_orden(_cola(plantel))).contains_exactly(["ocarra_s1", "rodauva_1", Maestro.ID])


# (2) Prueba C. Zancajunco y Tasajero (Caza) empatan en 8: va primero el bando
# del jugador (Sistema.md 11.3, Empates). La tribu del escenario esta en otro orden.
# T35 (criterio 3), reescrito por Sistema.md 11.2.3 v1.3: un solo turno por
# ronda, cinco entradas (antes seis, con la Cuenta al final).
func test_prueba_c() -> void:
	var plantel: Plantel = _plantel(_escenario(_CARPETA + "escenario_c.json"))
	assert_array(_orden(_cola(plantel))).contains_exactly([
		"zancajunco_1", "tasajero_s1:caza", "ocarra_1", "rodauva_1", Maestro.ID])


# (3) Maestro empatado con una criatura (las dos con Velocidad 5): va antes el Maestro.
func test_maestro_empatado_va_antes_que_su_criatura() -> void:
	var plantel: Plantel = _plantel(_escenario(_CARPETA_UNIDADES + "escenario_a.json"),
		{"rodauva": _CARPETA + "rodauva_velocidad_5.json"})
	assert_int(plantel.criatura("rodauva_1").especie.velocidad("")).is_equal(plantel.maestro.velocidad)
	assert_array(_orden(_cola(plantel))).contains_exactly(["ocarra_s1", Maestro.ID, "rodauva_1"])


# (4) Las dos Rodauvas de E (Vel 6) siguen el orden de la tribu, no el id.
# Sin la entrada de la Cuenta del Tasajero (Sistema.md 11.2.3 v1.3).
func test_rodauvas_de_e_siguen_el_orden_de_la_tribu() -> void:
	var escenario: Dictionary = _escenario(_CARPETA_UNIDADES + "escenario_e.json")
	assert_array(_orden(_cola(_plantel(escenario)))).contains_exactly([
		"tasajero_s1:caza", "rodauva_1", "rodauva_2", Maestro.ID, "surcon_1"])

	(escenario["tribu"] as Array).reverse()
	assert_array(_orden(_cola(_plantel(escenario)))).contains_exactly([
		"tasajero_s1:caza", "rodauva_2", "rodauva_1", Maestro.ID, "surcon_1"])


# (5) Las dos Ocarras de B (Vel 7) siguen el orden de la lista enemigas (S-14, P-011).
func test_ocarras_de_b_siguen_el_orden_de_enemigas() -> void:
	var escenario: Dictionary = _escenario(_CARPETA_UNIDADES + "escenario_b.json")
	assert_array(_orden(_cola(_plantel(escenario)))).contains_exactly([
		"ocarra_s1", "ocarra_s2", "rodauva_1", Maestro.ID])

	(escenario["enemigas"] as Array).reverse()
	assert_array(_orden(_cola(_plantel(escenario)))).contains_exactly([
		"ocarra_s2", "ocarra_s1", "rodauva_1", Maestro.ID])


# (6a) Una guardada no entra en la cola. Sin la Cuenta (Sistema.md 11.2.3 v1.3).
func test_guardada_no_entra() -> void:
	var escenario: Dictionary = _escenario(_CARPETA + "escenario_c.json")
	(escenario["tribu"] as Array)[0]["estado"] = "guardada"
	var plantel: Plantel = _plantel(escenario)
	assert_array(_orden(_cola(plantel))).contains_exactly([
		"zancajunco_1", "tasajero_s1:caza", "ocarra_1", Maestro.ID])


# (6b) Una unidad que cae antes de su turno se saltea. El estado lo cambia el
# test a mano: el danio que la tumba es de T08.
func test_caida_antes_de_su_turno_se_saltea() -> void:
	var plantel: Plantel = _plantel(_escenario(_CARPETA_UNIDADES + "escenario_a.json"))
	var cola: ColaIniciativa = _cola(plantel)
	assert_str(cola.siguiente(plantel).unidad_id).is_equal("ocarra_s1")

	plantel.criatura("rodauva_1").estado = Criatura.Estado.CAIDA
	assert_array(_recorrer(cola, plantel)).contains_exactly([Maestro.ID])
	assert_bool(cola.entradas()[1].actuo).is_false()
	assert_bool(cola.ronda_terminada()).is_true()


# (6b) La que sale del tablero (sin posicion) antes de su turno tambien se
# saltea: el Tasajero pierde su unico turno de la ronda. Reescrito por
# Sistema.md 11.3 v1.3 (fila "Unidad que deja de actuar a mitad de ronda": con
# un solo turno, el ejemplo de P-012, que perdia la Cuenta, ya no aplica).
func test_fuera_del_tablero_se_saltea() -> void:
	var plantel: Plantel = _plantel(_escenario(_CARPETA + "escenario_c.json"))
	var cola: ColaIniciativa = _cola(plantel)
	assert_str(cola.siguiente(plantel).unidad_id).is_equal("zancajunco_1")

	plantel.criatura("tasajero_s1").posicion = Criatura.SIN_POSICION
	assert_array(_recorrer(cola, plantel)).contains_exactly(["ocarra_1", "rodauva_1", Maestro.ID])
	assert_bool(cola.entradas()[1].actuo).is_false()


# (6c) Una unidad que pasa a suelta a mitad de ronda (invocada) entra recien en
# la siguiente (Sistema.md 11.3, Criatura invocada). Estado cambiado a mano.
func test_invocada_entra_en_la_ronda_siguiente() -> void:
	var escenario: Dictionary = _escenario(_CARPETA_UNIDADES + "escenario_a.json")
	(escenario["tribu"] as Array)[0]["estado"] = "guardada"
	var plantel: Plantel = _plantel(escenario)
	var cola: ColaIniciativa = _cola(plantel)
	assert_array(_orden(cola)).contains_exactly(["ocarra_s1", Maestro.ID])
	assert_str(cola.siguiente(plantel).unidad_id).is_equal("ocarra_s1")

	plantel.criatura("rodauva_1").estado = Criatura.Estado.SUELTA
	assert_array(_recorrer(cola, plantel)).contains_exactly([Maestro.ID])

	cola.terminar_ronda()
	cola.empezar_ronda(plantel)
	assert_array(_orden(cola)).contains_exactly(["ocarra_s1", "rodauva_1", Maestro.ID])


# (7) El Tasajero tiene una sola entrada por ronda, con la marca y la Velocidad
# de su modo; la ronda termina despues de la ultima entrada y la siguiente
# empieza limpia. Reescrito por Sistema.md 11.2.3 v1.3 (antes: dos entradas).
func test_tasajero_una_entrada_y_fin_de_ronda() -> void:
	var plantel: Plantel = _plantel(_escenario(_CARPETA + "escenario_c.json"))
	var cola: ColaIniciativa = _cola(plantel)
	assert_int(cola.ronda).is_equal(1)

	var del_tasajero: Array[EntradaCola] = []
	for entrada in cola.entradas():
		if entrada.unidad_id == "tasajero_s1":
			del_tasajero.append(entrada)
	assert_int(del_tasajero.size()).is_equal(1)
	assert_str(del_tasajero[0].marca).is_equal("caza")
	assert_int(del_tasajero[0].velocidad).is_equal(8)

	var recorrido: Array[String] = _recorrer(cola, plantel)
	assert_int(recorrido.size()).is_equal(5)
	assert_str(recorrido[-1]).is_equal(Maestro.ID)
	assert_bool(cola.ronda_terminada()).is_true()
	assert_object(cola.siguiente(plantel)).is_null()
	for entrada in cola.entradas():
		assert_bool(entrada.actuo).is_true()

	cola.terminar_ronda()
	cola.empezar_ronda(plantel)
	assert_int(cola.ronda).is_equal(2)
	assert_bool(cola.ronda_terminada()).is_false()
	for entrada in cola.entradas():
		assert_bool(entrada.actuo).is_false()


# T35 (criterio 4): con el Tasajero en Cuenta antes de armar la ronda, entra
# con la Velocidad de Cuenta (3) y va ultimo, con su marca (Sistema.md 11.3,
# Velocidad por modo). El modo lo cambia el test a mano: el cambio es de T36.
func test_tasajero_en_cuenta_va_ultimo() -> void:
	var plantel: Plantel = _plantel(_escenario(_CARPETA + "escenario_c.json"))
	plantel.criatura("tasajero_s1").modo = "cuenta"
	var cola: ColaIniciativa = _cola(plantel)
	assert_array(_orden(cola)).contains_exactly([
		"zancajunco_1", "ocarra_1", "rodauva_1", Maestro.ID, "tasajero_s1:cuenta"])
	assert_int(cola.entradas()[-1].velocidad).is_equal(3)


# T35 (criterio 5): cambiarle el modo a mitad de ronda no reordena la ronda en
# curso; rige desde la siguiente (Sistema.md 11.2.3, Velocidad tras el cambio;
# 11.3: la cola no se rearma a mitad de ronda).
func test_cambio_de_modo_rige_desde_la_ronda_siguiente() -> void:
	var plantel: Plantel = _plantel(_escenario(_CARPETA + "escenario_c.json"))
	var cola: ColaIniciativa = _cola(plantel)
	var antes: Array[String] = _orden(cola)
	assert_str(cola.siguiente(plantel).unidad_id).is_equal("zancajunco_1")
	assert_str(cola.siguiente(plantel).unidad_id).is_equal("tasajero_s1")

	plantel.criatura("tasajero_s1").modo = "cuenta"
	assert_array(_orden(cola)).is_equal(antes)
	assert_array(_recorrer(cola, plantel)).contains_exactly(["ocarra_1", "rodauva_1", Maestro.ID])

	cola.terminar_ronda()
	cola.empezar_ronda(plantel)
	assert_array(_orden(cola)).contains_exactly([
		"zancajunco_1", "ocarra_1", "rodauva_1", Maestro.ID, "tasajero_s1:cuenta"])


# (8) El mismo plantel da la misma cola, y la cola no usa azar (Sistema.md 10.1).
func test_misma_cola_y_sin_azar() -> void:
	var escenario: Dictionary = _escenario(_CARPETA + "escenario_c.json")
	var primera: Array[String] = _orden(_cola(_plantel(escenario)))
	var plantel: Plantel = _plantel(escenario)
	assert_array(_orden(_cola(plantel))).is_equal(primera)
	assert_array(_orden(_cola(plantel))).is_equal(primera)

	for ruta in _FUENTES:
		var fuente: String = FileAccess.get_file_as_string(ruta)
		assert_str(fuente).is_not_empty()
		for prohibido in _AZAR_PROHIBIDO:
			assert_bool(fuente.contains(prohibido)).override_failure_message(ruta + " usa " + prohibido).is_false()
