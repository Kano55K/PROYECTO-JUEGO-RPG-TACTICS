extends GdUnitTestSuite

# Arquitectura.md B.4 (T31, sesion 1): EdicionEscenario edita una copia del
# escenario sin tocar el original ni el archivo, toma los rangos y los toggles
# del esquema y valida con el Cargador (mismo validador y mismos chequeos
# cruzados). Con fixtures (A.6).
const _ESCENARIO: String = "res://pruebas/fixtures/parametros/escenario_parametros.json"
const _CARPETA_ESQUEMA_REAL: String = "res://datos"
const _CARPETA_ESQUEMA_OTRO: String = "res://pruebas/fixtures/parametros/esquema_otro"
const _CARPETA_MANA: String = "res://pruebas/fixtures/cargador/escenario_mana_entrada"


func _esquema(carpeta: String) -> Dictionary:
	var lectura: Dictionary = Cargador.new().esquema_resuelto(carpeta, "escenario")
	assert_array(lectura["errores"] as Array).override_failure_message(str(lectura["errores"])).is_empty()
	return lectura["esquema"]


func _escenario() -> Dictionary:
	var lectura: Dictionary = LectorFixture.leer(_ESCENARIO, "escenario")
	assert_array(lectura["errores"] as Array).override_failure_message(str(lectura["errores"])).is_empty()
	return lectura["datos"]


func _datos() -> Dictionary:
	var lectura: Dictionary = DatosFixture.cargar()
	assert_array(lectura["errores"] as Array).override_failure_message(str(lectura["errores"])).is_empty()
	return lectura["datos"]


func _edicion(carpeta_esquema: String = _CARPETA_ESQUEMA_REAL) -> EdicionEscenario:
	return EdicionEscenario.new(_escenario(), _datos(), _esquema(carpeta_esquema))


func _rutas(edicion: EdicionEscenario) -> Array:
	var rutas: Array = []
	for campo in edicion.campos():
		rutas.append(campo["ruta"])
	return rutas


func _campo(edicion: EdicionEscenario, ruta: String) -> Dictionary:
	for campo in edicion.campos():
		if campo["ruta"] == ruta:
			return campo
	return {}


# El diccionario que guarda el campo final de una ruta del test
# ("maestro.vida", "tribu.<id>.lealtad"), para armar lo esperado a mano.
func _contenedor(escenario: Dictionary, partes: PackedStringArray) -> Dictionary:
	if partes.size() == 1:
		return escenario
	if partes.size() == 2:
		if not escenario.has(partes[0]):
			escenario[partes[0]] = {}
		return escenario[partes[0]]
	for unidad in (escenario[partes[0]] as Array):
		if (unidad as Dictionary)["id"] == partes[1]:
			return unidad
	return {}


func _poner(escenario: Dictionary, ruta: String, valor: Variant) -> void:
	var partes: PackedStringArray = ruta.split(".")
	_contenedor(escenario, partes)[partes[partes.size() - 1]] = valor


func _leer(escenario: Dictionary, ruta: String) -> Variant:
	var partes: PackedStringArray = ruta.split(".")
	return _contenedor(escenario, partes).get(partes[partes.size() - 1])


# Lee un archivo de una carpeta de fixtures con el esquema de esa carpeta.
func _leer_con_esquema(carpeta: String, archivo: String, nombre_esquema: String) -> Dictionary:
	var esquema: Dictionary = Cargador.new().esquema_resuelto(carpeta, nombre_esquema)["esquema"]
	var valor: Variant = JSON.parse_string(FileAccess.get_file_as_string(carpeta.path_join(archivo)))
	var lectura: Dictionary = Validador.new().validar(valor, esquema, archivo)
	assert_array(lectura["errores"] as Array).override_failure_message(str(lectura["errores"])).is_empty()
	return lectura["datos"]


# Un valor distinto del actual, valido para el tipo del campo.
func _otro_valor(campo: Dictionary, actual: Variant) -> Variant:
	match campo["tipo"]:
		EdicionEscenario.TIPO_BOOLEANO:
			return not bool(actual)
		EdicionEscenario.TIPO_OPCION:
			for opcion in campo["opciones"]:
				if opcion != actual:
					return opcion
	return 1 if actual == null else int(actual) + 1


# (1) La lista de campos editables, y cambiar cada uno cambia solo ese campo en
# la copia; el original y el archivo no cambian. Pasar a guardada tambien
# deja la posicion en null (P-023): es la unica excepcion.
func test_1_cada_campo_cambia_solo_ese_campo() -> void:
	var original: Dictionary = _escenario()
	var copia_original: Dictionary = original.duplicate(true)
	var archivo_antes: String = FileAccess.get_file_as_string(_ESCENARIO)
	var edicion: EdicionEscenario = EdicionEscenario.new(original, _datos(), _esquema(_CARPETA_ESQUEMA_REAL))

	assert_array(_rutas(edicion)).contains_exactly([
		"semilla",
		"maestro.balanza", "maestro.poder", "maestro.regeneracion", "maestro.vida",
		"maestro.mana_entrada", "maestro.hambre", "maestro.enfermedades",
		"tribu.rodauva_1.estado", "tribu.rodauva_1.lealtad", "tribu.rodauva_1.hambre",
		"tribu.rodauva_1.enfermedades", "tribu.rodauva_1.vida",
		"tribu.ocarra_1.estado", "tribu.ocarra_1.lealtad", "tribu.ocarra_1.hambre",
		"tribu.ocarra_1.enfermedades", "tribu.ocarra_1.vida",
		"enemigas.ocarra_s1.vida",
		"pergaminos_en_blanco",
		"toggles.afines_contra_cobardia",
	])

	for campo in edicion.campos():
		var ruta: String = campo["ruta"]
		if ruta == "tribu.ocarra_1.estado":
			continue  # Sin posicion en el archivo: no se puede soltar (test 4).
		var sola: EdicionEscenario = EdicionEscenario.new(original, _datos(), _esquema(_CARPETA_ESQUEMA_REAL))
		var nuevo: Variant = _otro_valor(campo, sola.valor(ruta))
		assert_str(sola.cambiar(ruta, nuevo)).override_failure_message(ruta).is_empty()
		assert_that(sola.valor(ruta)).override_failure_message(ruta).is_equal(nuevo)

		var esperado: Dictionary = copia_original.duplicate(true)
		_poner(esperado, ruta, nuevo)
		if ruta == "tribu.rodauva_1.estado":
			_poner(esperado, "tribu.rodauva_1.posicion", null)
		assert_dict(sola.escenario()).override_failure_message(ruta).is_equal(esperado)
		assert_bool(sola.difiere()).override_failure_message(ruta).is_true()

	assert_dict(original).is_equal(copia_original)
	assert_str(FileAccess.get_file_as_string(_ESCENARIO)).is_equal(archivo_antes)
	assert_bool(edicion.difiere()).is_false()


# (1) Un campo que no esta en la lista no se edita, con motivo.
func test_1_campo_no_editable() -> void:
	var edicion: EdicionEscenario = _edicion()
	for ruta in ["id", "tipo", "golpe_inicial", "tablero.ancho", "maestro.posicion",
			"tribu.rodauva_1.especie", "tribu.rodauva_1.posicion", "enemigas.ocarra_s1.especie",
			"tribu.no_existe.lealtad"]:
		assert_str(edicion.cambiar(ruta, 1)).override_failure_message(ruta) \
				.is_equal(EdicionEscenario.MOTIVO_CAMPO_NO_EDITABLE)
	assert_bool(edicion.difiere()).is_false()


# (1) Volver al valor del archivo deja de diferir.
func test_1_volver_al_valor_del_archivo_no_difiere() -> void:
	var edicion: EdicionEscenario = _edicion()
	edicion.cambiar("semilla", 6)
	assert_bool(edicion.difiere()).is_true()
	edicion.cambiar("semilla", 5)
	assert_bool(edicion.difiere()).is_false()


# (2) Rangos desde el esquema real: balanza 1..5, lealtad 0..10, vida y
# mana_entrada con "por defecto"; el maximo de mana_entrada es la reserva de la
# balanza actual (tablas/balanza.json).
func test_2_rangos_del_esquema_real() -> void:
	var edicion: EdicionEscenario = _edicion()
	var balanza: Dictionary = _campo(edicion, "maestro.balanza")
	assert_str(balanza["tipo"]).is_equal(EdicionEscenario.TIPO_ENTERO)
	assert_that(balanza["minimo"]).is_equal(1)
	assert_that(balanza["maximo"]).is_equal(5)
	assert_bool(balanza["admite_nulo"]).is_false()
	var lealtad: Dictionary = _campo(edicion, "tribu.rodauva_1.lealtad")
	assert_that(lealtad["minimo"]).is_equal(0)
	assert_that(lealtad["maximo"]).is_equal(10)
	var semilla: Dictionary = _campo(edicion, "semilla")
	assert_that(semilla["minimo"]).is_equal(0)
	assert_that(semilla["maximo"]).is_null()
	for ruta in ["maestro.vida", "maestro.mana_entrada", "tribu.rodauva_1.vida", "enemigas.ocarra_s1.vida"]:
		assert_bool(_campo(edicion, ruta)["admite_nulo"]).override_failure_message(ruta).is_true()
	var estado: Dictionary = _campo(edicion, "tribu.rodauva_1.estado")
	assert_str(estado["tipo"]).is_equal(EdicionEscenario.TIPO_OPCION)
	assert_array(estado["opciones"]).contains_exactly(["suelta", "guardada"])

	# balanza_1_2.json: reserva 8 con la balanza 2 y 10 con la 4.
	assert_that(_campo(edicion, "maestro.mana_entrada")["maximo"]).is_equal(8)
	edicion.cambiar("maestro.balanza", 4)
	assert_that(_campo(edicion, "maestro.mana_entrada")["maximo"]).is_equal(10)


# (2) Con otro esquema, el limite cambia sin tocar codigo, y un valor fuera de
# rango da error con campo y valor esperado.
func test_2_rangos_de_otro_esquema() -> void:
	var edicion: EdicionEscenario = _edicion(_CARPETA_ESQUEMA_OTRO)
	assert_that(_campo(edicion, "maestro.balanza")["maximo"]).is_equal(3)
	assert_array(edicion.validar()).is_empty()

	assert_str(edicion.cambiar("maestro.balanza", 4)).is_empty()
	assert_that(edicion.valor("maestro.balanza")).is_equal(4)
	var errores: Array[Dictionary] = edicion.validar()
	assert_int(errores.size()).override_failure_message(str(errores)).is_equal(1)
	assert_str(errores[0]["campo"]).is_equal("maestro.balanza")
	assert_str(errores[0]["ruta"]).is_equal("maestro.balanza")
	assert_str(errores[0]["esperado"]).is_equal("menor o igual a 3")
	assert_that(errores[0]["recibido"]).is_equal(4)


# (2) El error de una criatura de la lista sale con la ruta por id.
func test_2_error_de_una_criatura_lleva_su_ruta() -> void:
	var edicion: EdicionEscenario = _edicion()
	edicion.cambiar("tribu.ocarra_1.lealtad", 11)
	var errores: Array[Dictionary] = edicion.validar()
	assert_int(errores.size()).override_failure_message(str(errores)).is_equal(1)
	assert_str(errores[0]["ruta"]).is_equal("tribu.ocarra_1.lealtad")
	assert_str(errores[0]["esperado"]).is_equal("menor o igual a 10")


# (3) mana_entrada mayor que la reserva: el mismo error que da el cargador con
# un archivo asi (pruebas/fixtures/cargador/escenario_mana_entrada/mayor.json,
# balanza 2 y mana 9). Bajar la balanza no recorta el mana en silencio.
func test_3_mana_entrada_como_el_cargador() -> void:
	var carga: Dictionary = Cargador.new().cargar_carpeta(_CARPETA_MANA)
	var errores_carga: Array = carga["errores"]
	assert_int(errores_carga.size()).override_failure_message(str(errores_carga)).is_equal(1)
	var del_cargador: Dictionary = errores_carga[0]

	var datos: Dictionary = {"tablas/balanza.json": _leer_con_esquema(_CARPETA_MANA, "tablas/balanza.json", "balanza")}
	var igual: Dictionary = _leer_con_esquema(_CARPETA_MANA, "escenarios/igual.json", "escenario")
	var edicion: EdicionEscenario = EdicionEscenario.new(igual, datos, _esquema(_CARPETA_MANA))
	assert_array(edicion.validar()).is_empty()

	# igual.json: balanza 4 y mana 10. Al bajar a 2 (reserva 8) es un error y el
	# mana sigue en 10.
	edicion.cambiar("maestro.balanza", 2)
	assert_that(edicion.valor("maestro.mana_entrada")).is_equal(10)
	var errores: Array[Dictionary] = edicion.validar()
	assert_int(errores.size()).override_failure_message(str(errores)).is_equal(1)
	assert_str(errores[0]["ruta"]).is_equal("maestro.mana_entrada")
	assert_str(errores[0]["esperado"]).is_equal(del_cargador["esperado"])

	# Con el mismo valor que mayor.json, el mismo error salvo el archivo.
	edicion.cambiar("maestro.mana_entrada", 9)
	errores = edicion.validar()
	assert_int(errores.size()).is_equal(1)
	for clave in ["campo", "esperado", "recibido"]:
		assert_that(errores[0][clave]).override_failure_message(clave).is_equal(del_cargador[clave])


# (4) Guardada: posicion en null. Suelta: vuelve la del archivo. Sin posicion
# en el archivo no se puede soltar, con motivo, y nada cambia.
func test_4_guardada_y_suelta() -> void:
	var edicion: EdicionEscenario = _edicion()
	assert_str(edicion.cambiar("tribu.rodauva_1.estado", "guardada")).is_empty()
	assert_that(_leer(edicion.escenario(), "tribu.rodauva_1.posicion")).is_null()
	assert_array(edicion.validar()).is_empty()
	assert_str(edicion.cambiar("tribu.rodauva_1.estado", "suelta")).is_empty()
	assert_that(_leer(edicion.escenario(), "tribu.rodauva_1.posicion")).is_equal([2, 6])
	assert_bool(edicion.difiere()).is_false()

	assert_str(edicion.cambiar("tribu.ocarra_1.estado", "suelta")) \
			.is_equal(EdicionEscenario.MOTIVO_SIN_POSICION_EN_ARCHIVO)
	assert_that(edicion.valor("tribu.ocarra_1.estado")).is_equal("guardada")
	assert_bool(edicion.difiere()).is_false()


# (5) Toggles: todos los del esquema real, y con otro esquema aparece uno mas
# sin codigo nuevo.
func test_5_toggles_del_esquema() -> void:
	var toggles_real: Array = []
	for ruta in _rutas(_edicion()):
		if (ruta as String).begins_with("toggles."):
			toggles_real.append(ruta)
	assert_array(toggles_real).contains_exactly(["toggles.afines_contra_cobardia"])

	var edicion: EdicionEscenario = _edicion(_CARPETA_ESQUEMA_OTRO)
	var toggles_otro: Array = []
	for ruta in _rutas(edicion):
		if (ruta as String).begins_with("toggles."):
			toggles_otro.append(ruta)
	assert_array(toggles_otro).contains_exactly(["toggles.afines_contra_cobardia", "toggles.toggle_prueba"])
	assert_str(_campo(edicion, "toggles.toggle_prueba")["tipo"]).is_equal(EdicionEscenario.TIPO_BOOLEANO)
	assert_str(edicion.cambiar("toggles.toggle_prueba", true)).is_empty()
	assert_bool(edicion.valor("toggles.toggle_prueba")).is_true()
	assert_array(edicion.validar()).is_empty()
