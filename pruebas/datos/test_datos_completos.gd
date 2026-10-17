extends GdUnitTestSuite

# Arquitectura.md B.2 (T04, criterio de terminado): toda la carpeta datos/
# carga sin errores con el Cargador de T03. Este test queda para siempre.
# Ademas fija lo que pide Sistema.md 11.9 de los escenarios: semillas
# compartidas entre variantes, D con balanza 4 y el ataque nocturno de G.
const _CARPETA_DATOS: String = "res://datos"
const _FIXTURE_EJEMPLO_A2: String = "res://pruebas/fixtures/esquemas/escenario_ejemplo_a2.json"

const _ESCENARIOS: Array[String] = [
	"a_dia_1", "b_muro", "c_tasajero", "d_rivales_normal", "d_rivales_hambriento",
	"e_cobardia", "e_cobardia_afines", "f_rescate",
	"g_ataque_nocturno", "h_soplo",
]

# Aviso de A.2.1 para una clave de textos/es.json que el codigo no usa (todavia ninguna).
const _AVISO_CLAVE_SOBRANTE: String = "una clave usada por el codigo"


func _cargar() -> Dictionary:
	return Cargador.new().cargar_carpeta(_CARPETA_DATOS)


func _escenario(id: String) -> Dictionary:
	var datos: Dictionary = _cargar()["datos"]
	return datos["escenarios/%s.json" % [id]]


func test_datos_cargan_sin_errores() -> void:
	var resultado: Dictionary = _cargar()
	var errores: Array[Dictionary] = resultado["errores"]
	assert_array(errores).override_failure_message(str(errores)).is_empty()
	assert_object(resultado["datos"]).is_not_null()
	# Solo se esperan avisos de claves de texto sobrantes.
	var avisos: Array[Dictionary] = resultado["avisos"]
	for aviso in avisos:
		assert_str(aviso["archivo"] as String).override_failure_message(str(aviso)).is_equal("textos/es.json")
		assert_str(aviso["esperado"] as String).override_failure_message(str(aviso)).is_equal(_AVISO_CLAVE_SOBRANTE)


# Reescrito por A.9, T31: son 10 (se borro d_rivales_balanza4.json).
func test_estan_los_diez_escenarios() -> void:
	var datos: Dictionary = _cargar()["datos"]
	var encontrados: Array[String] = []
	for ruta in datos.keys():
		if (ruta as String).begins_with("escenarios/"):
			encontrados.append((ruta as String).get_file().get_basename())
	encontrados.sort()
	var esperados: Array[String] = _ESCENARIOS.duplicate()
	esperados.sort()
	assert_array(encontrados).is_equal(esperados)


# Arquitectura.md A.2: a_dia_1 es el ejemplo de escenario, copiado tal cual.
# Salvo la _nota, que T05 actualiza por P-009 (A.9, fila A). Reescrito en T43
# por Sistema.md 11.9 v1.6: el ejemplo es del tablero de 8 x 8 y A pasa a
# 12 x 12 con posiciones nuevas (A.2 y B.3.1), asi que tampoco se comparan el
# tablero ni las posiciones (ni sus _nota); lo verifica pruebas/datos/test_contacto.gd.
func test_a_dia_1_es_el_ejemplo_de_a2() -> void:
	var ejemplo: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(_FIXTURE_EJEMPLO_A2))
	var archivo: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(_CARPETA_DATOS.path_join("escenarios/a_dia_1.json")))
	for escenario: Dictionary in [ejemplo, archivo]:
		escenario.erase("_nota")
		escenario.erase("tablero")
		var unidades: Array = [escenario["maestro"]]
		unidades.append_array(escenario["tribu"])
		unidades.append_array(escenario["enemigas"])
		for unidad: Dictionary in unidades:
			unidad.erase("posicion")
			unidad.erase("_nota")
	assert_dict(archivo).is_equal(ejemplo)


# Sistema.md 11.9: las variantes que se comparan comparten semilla.
func test_semillas_compartidas() -> void:
	assert_int(_escenario("h_soplo")["semilla"] as int).is_equal(_escenario("c_tasajero")["semilla"] as int)
	var semilla_d: int = _escenario("d_rivales_normal")["semilla"] as int
	assert_int(_escenario("d_rivales_hambriento")["semilla"] as int).is_equal(semilla_d)
	# Reescrito por A.9, T31: D con balanza 4 es la variante del panel.
	var balanza4: Dictionary = VariantesEscenario.escenario(_cargar()["datos"], VariantesEscenario.D_BALANZA_4)
	assert_int(balanza4["semilla"] as int).is_equal(semilla_d)
	assert_int(_escenario("e_cobardia_afines")["semilla"] as int).is_equal(_escenario("e_cobardia")["semilla"] as int)


# Arquitectura.md B.2 (T04): D con balanza 4. Reescrito por A.9, T31: el archivo
# temporal d_rivales_balanza4.json se borro y la variante se arma con
# EdicionEscenario (VariantesEscenario), como en el panel.
func test_d_balanza4_es_d_normal_con_balanza_4() -> void:
	var normal: Dictionary = _escenario("d_rivales_normal").duplicate(true)
	var balanza4: Dictionary = VariantesEscenario.escenario(_cargar()["datos"], VariantesEscenario.D_BALANZA_4)
	assert_int((balanza4["maestro"] as Dictionary)["balanza"] as int).is_equal(4)
	for escenario in [normal, balanza4]:
		(escenario as Dictionary).erase("id")
		(escenario as Dictionary).erase("_nota")
		((escenario as Dictionary)["maestro"] as Dictionary).erase("balanza")
	assert_dict(balanza4).is_equal(normal)


# Sistema.md 9.2 y 2.4, Arquitectura.md A.7: golpe inicial de la atacante
# y maná de entrada a la mitad (8 / 2 = 4 con la balanza 2).
func test_g_ataque_nocturno() -> void:
	var g: Dictionary = _escenario("g_ataque_nocturno")
	assert_str(g["tipo"] as String).is_equal("nocturno")
	var maestro: Dictionary = g["maestro"]
	assert_int(maestro["mana_entrada"] as int).is_equal(4)
	assert_int(maestro["hambre"] as int).is_equal(3)
	var enemigas: Array = g["enemigas"]
	assert_int(enemigas.size()).is_equal(1)
	var atacante: Dictionary = enemigas[0]
	assert_str(atacante["especie"] as String).is_equal("ocarra")
	assert_str(atacante["comportamiento"] as String).is_equal("atacante_nocturna")
	assert_int(atacante["hambre"] as int).is_equal(9)
	assert_str(g["golpe_inicial"] as String).is_equal(atacante["id"] as String)
	var especies_tribu: Array[String] = []
	for criatura in (g["tribu"] as Array):
		especies_tribu.append((criatura as Dictionary)["especie"] as String)
		assert_int((criatura as Dictionary)["lealtad"] as int).is_equal(8)
	assert_array(especies_tribu).contains_exactly_in_any_order(["rodauva", "zancajunco"])
	assert_int(g["pergaminos_en_blanco"] as int).is_equal(1)


func test_golpe_inicial_null_salvo_g() -> void:
	for id in _ESCENARIOS:
		if id == "g_ataque_nocturno":
			continue
		assert_object(_escenario(id)["golpe_inicial"]).override_failure_message(id).is_null()
