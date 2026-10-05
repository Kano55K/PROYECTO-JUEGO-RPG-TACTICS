extends GdUnitTestSuite

# Arquitectura.md B.2 (T13): la carpeta de datos por defecto es res://datos, y
# por linea de comandos `-- --datos=<carpeta>`.


func test_sin_argumentos_usa_datos() -> void:
	assert_str(ArgumentosPantalla.carpeta_datos(PackedStringArray())).is_equal("res://datos")


func test_datos_por_linea_de_comandos() -> void:
	assert_str(ArgumentosPantalla.carpeta_datos(PackedStringArray(["--datos=res://pruebas/x"]))).is_equal("res://pruebas/x")
	assert_str(ArgumentosPantalla.carpeta_datos(PackedStringArray(["--otra=1", "--datos=res://y"]))).is_equal("res://y")


func test_otros_argumentos_se_ignoran() -> void:
	assert_str(ArgumentosPantalla.carpeta_datos(PackedStringArray(["--otra=1", "--datos="]))).is_equal("res://datos")
