extends GdUnitTestSuite

# Arquitectura.md B.4 (T45), punto 5: Mundo.md 1.5 v1.5 con datos/textos/es.json
# real. La pantalla arma panel.rescatista, resultado.rescatista y
# resultado.atacante_pendiente como "etiqueta: nombre", y los titulos de lista
# del resultado sin datos (LecturaCombate): ninguno de esos textos tiene hueco.
# huida.salvaje.se_queda existe, asi que el suceso de la salvaje que se queda sale.
const _CARPETA_DATOS: String = "res://datos"
const _SIN_HUECO: Array[String] = [
	ClavesTextos.PANEL_RESCATISTA, ClavesTextos.RESULTADO_RESCATISTA, ClavesTextos.RESULTADO_ATACANTE_PENDIENTE,
	ClavesTextos.RESULTADO_MUERTAS, ClavesTextos.RESULTADO_LEVANTADAS, ClavesTextos.RESULTADO_CAIDAS_GUARDADAS,
	ClavesTextos.RESULTADO_CAPTURAS,
]


func test_etiquetas_y_titulos_sin_hueco() -> void:
	var carga: Dictionary = Cargador.new().cargar_carpeta(_CARPETA_DATOS)
	var errores: Array[Dictionary] = carga["errores"]
	assert_array(errores).override_failure_message(str(errores)).is_empty()
	var textos: Dictionary = carga["datos"]["textos/es.json"]
	for clave in _SIN_HUECO:
		assert_bool(textos.has(clave)).override_failure_message(clave).is_true()
		assert_str(textos[clave] as String).override_failure_message(clave).not_contains("{")
	var armador: ArmadorTextos = ArmadorTextos.desde_datos(textos, GeneradorAzar.new(1))
	assert_bool(armador.tiene(ClavesTextos.HUIDA_SE_QUEDA)).is_true()
	assert_array(ClavesTextos.usadas(carga["datos"])).contains([ClavesTextos.HUIDA_SE_QUEDA,
			ClavesTextos.AVISO_SELLAR_SIN_PROBABILIDAD])
