extends GdUnitTestSuite

# Arquitectura.md B.2 (T02): misma semilla -> misma secuencia; otra semilla -> otra secuencia;
# dos generadores con la misma semilla no se interfieren.
const CANTIDAD_TIRADAS: int = 1000


func test_misma_semilla_da_la_misma_secuencia_de_mil_tiradas() -> void:
	var generador_a: GeneradorAzar = GeneradorAzar.new(12345)
	var generador_b: GeneradorAzar = GeneradorAzar.new(12345)
	var secuencia_a: Array[int] = []
	var secuencia_b: Array[int] = []
	for i in range(CANTIDAD_TIRADAS):
		secuencia_a.append(generador_a.entero(0, 999999))
		secuencia_b.append(generador_b.entero(0, 999999))
	assert_array(secuencia_a).is_equal(secuencia_b)


func test_otra_semilla_da_otra_secuencia() -> void:
	var generador_a: GeneradorAzar = GeneradorAzar.new(1)
	var generador_b: GeneradorAzar = GeneradorAzar.new(2)
	var secuencia_a: Array[int] = []
	var secuencia_b: Array[int] = []
	for i in range(CANTIDAD_TIRADAS):
		secuencia_a.append(generador_a.entero(0, 999999))
		secuencia_b.append(generador_b.entero(0, 999999))
	assert_array(secuencia_a).is_not_equal(secuencia_b)


func test_dos_generadores_con_la_misma_semilla_no_se_interfieren() -> void:
	var referencia: GeneradorAzar = GeneradorAzar.new(777)
	var secuencia_referencia: Array[int] = []
	for i in range(CANTIDAD_TIRADAS):
		secuencia_referencia.append(referencia.entero(0, 999999))

	var generador_a: GeneradorAzar = GeneradorAzar.new(777)
	var generador_b: GeneradorAzar = GeneradorAzar.new(777)
	var secuencia_a: Array[int] = []
	var secuencia_b: Array[int] = []
	for i in range(CANTIDAD_TIRADAS):
		# Intercaladas: una tirada de A y una de B, para comprobar que no comparten estado.
		secuencia_a.append(generador_a.entero(0, 999999))
		secuencia_b.append(generador_b.entero(0, 999999))

	assert_array(secuencia_a).is_equal(secuencia_referencia)
	assert_array(secuencia_b).is_equal(secuencia_referencia)


func test_historial_registra_cada_tirada() -> void:
	var generador: GeneradorAzar = GeneradorAzar.new(42)
	var resultados: Array[int] = []
	for i in range(CANTIDAD_TIRADAS):
		resultados.append(generador.entero(0, 10))

	var historial: Array[Dictionary] = generador.historial()
	assert_int(historial.size()).is_equal(CANTIDAD_TIRADAS)
	for i in range(CANTIDAD_TIRADAS):
		assert_int(historial[i]["resultado"] as int).is_equal(resultados[i])
