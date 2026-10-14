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


# T32 (D-013): la vista del tablero. Por defecto isometrica; `--vista=cenital`
# es la de desarrollo. Un valor desconocido se devuelve tal cual: lo rechaza
# VistasTablero.
func test_vista_por_defecto_es_isometrica() -> void:
	assert_str(ArgumentosPantalla.vista(PackedStringArray())).is_equal(VistasTablero.ISOMETRICA)
	assert_str(ArgumentosPantalla.vista(PackedStringArray(["--datos=res://y", "--vista="]))).is_equal(VistasTablero.ISOMETRICA)


func test_vista_por_linea_de_comandos() -> void:
	assert_str(ArgumentosPantalla.vista(PackedStringArray(["--datos=res://y", "--vista=cenital"]))).is_equal(VistasTablero.CENITAL)
	assert_str(ArgumentosPantalla.vista(PackedStringArray(["--vista=rara"]))).is_equal("rara")


func test_vistas_tablero() -> void:
	assert_bool(VistasTablero.existe(VistasTablero.ISOMETRICA)).is_true()
	assert_bool(VistasTablero.existe(VistasTablero.CENITAL)).is_true()
	assert_bool(VistasTablero.existe("rara")).is_false()
	assert_str(VistasTablero.error(VistasTablero.CENITAL)).is_empty()
	assert_str(VistasTablero.error("rara")).contains("rara").contains(VistasTablero.ISOMETRICA).contains(VistasTablero.CENITAL)
	assert_object(VistasTablero.tile_set("rara")).is_null()
	assert_int(VistasTablero.tile_set(VistasTablero.ISOMETRICA).tile_shape).is_equal(TileSet.TILE_SHAPE_ISOMETRIC)
	assert_int(VistasTablero.tile_set(VistasTablero.ISOMETRICA).tile_layout).is_equal(TileSet.TILE_LAYOUT_DIAMOND_DOWN)
	assert_int(VistasTablero.tile_set(VistasTablero.CENITAL).tile_shape).is_equal(TileSet.TILE_SHAPE_SQUARE)
