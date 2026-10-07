extends GdUnitTestSuite

# Arquitectura.md B.3.1 (T42) y D-003: la cuenta de limites y zoom de la camara,
# sin nodos. Los numeros son de presentacion (pixeles), inventados para el test.
const _VIEWPORT: Vector2 = Vector2(400, 200)


func _limites() -> Rect2:
	# Esquinas (centros de casilla) en (0,0) y (600,300), margen 50.
	return EncuadreCamara.limites(Vector2(0, 0), Vector2(600, 300), 50.0)


func test_limites_son_las_esquinas_con_margen() -> void:
	assert_object(_limites()).is_equal(Rect2(-50, -50, 700, 400))
	# Las esquinas en cualquier orden dan lo mismo.
	assert_object(EncuadreCamara.limites(Vector2(600, 300), Vector2(0, 0), 50.0)).is_equal(Rect2(-50, -50, 700, 400))


func test_acotar_zoom() -> void:
	assert_float(EncuadreCamara.acotar_zoom(0.1, 0.5, 2.0)).is_equal(0.5)
	assert_float(EncuadreCamara.acotar_zoom(5.0, 0.5, 2.0)).is_equal(2.0)
	assert_float(EncuadreCamara.acotar_zoom(1.25, 0.5, 2.0)).is_equal(1.25)


# El area visible (400 x 200 con zoom 1) no sale de los limites en ninguna de
# las cuatro direcciones.
func test_acotar_centro_en_las_cuatro_direcciones() -> void:
	var limites: Rect2 = _limites()
	# Izquierda y arriba: el borde visible queda en -50.
	assert_vector(EncuadreCamara.acotar_centro(Vector2(-1000, -1000), _VIEWPORT, limites)).is_equal(Vector2(150, 50))
	# Derecha y abajo: el borde visible queda en 650 y 350.
	assert_vector(EncuadreCamara.acotar_centro(Vector2(1000, 1000), _VIEWPORT, limites)).is_equal(Vector2(450, 250))
	# Adentro, no cambia.
	assert_vector(EncuadreCamara.acotar_centro(Vector2(300, 150), _VIEWPORT, limites)).is_equal(Vector2(300, 150))


# Si el area visible es mas grande que los limites en un eje, queda centrada en
# ese eje.
func test_acotar_centro_con_area_mas_grande() -> void:
	var limites: Rect2 = _limites()
	var visible: Vector2 = Vector2(1000, 200)
	assert_vector(EncuadreCamara.acotar_centro(Vector2(-1000, -1000), visible, limites)).is_equal(Vector2(300, 50))


func test_entra_entero() -> void:
	var limites: Rect2 = _limites()
	# 700 x 400 con un viewport de 400 x 200: entra con zoom 0,5, no con 0,6.
	assert_bool(EncuadreCamara.entra_entero(limites, _VIEWPORT, 0.5)).is_true()
	assert_bool(EncuadreCamara.entra_entero(limites, _VIEWPORT, 0.6)).is_false()


# Entra entero con el zoom minimo: centro de los limites, con el zoom mas
# cercano a 1 que lo muestra entero.
func test_inicial_encuadra_si_entra() -> void:
	var limites: Rect2 = _limites()
	var inicial: Dictionary = EncuadreCamara.inicial(limites, _VIEWPORT, 0.25, 2.0, Vector2(0, 300))
	assert_vector(inicial["centro"]).is_equal(Vector2(300, 150))
	assert_float(inicial["zoom"]).is_equal_approx(0.5, 0.0001)
	# Si entra con zoom 1, no se agranda.
	var grande: Dictionary = EncuadreCamara.inicial(limites, Vector2(1400, 800), 0.25, 2.0, Vector2(0, 300))
	assert_float(grande["zoom"]).is_equal(1.0)
	assert_vector(grande["centro"]).is_equal(Vector2(300, 150))


# No entra con el zoom minimo: centro en el Maestro, con zoom 1 acotado, y el
# centro acotado a los limites.
func test_inicial_centra_en_el_maestro_si_no_entra() -> void:
	var limites: Rect2 = _limites()
	var inicial: Dictionary = EncuadreCamara.inicial(limites, _VIEWPORT, 0.6, 2.0, Vector2(0, 300))
	assert_float(inicial["zoom"]).is_equal(1.0)
	assert_vector(inicial["centro"]).is_equal(Vector2(150, 250))
	# Sin Maestro en el tablero: centro de los limites.
	var sin_maestro: Dictionary = EncuadreCamara.inicial(limites, _VIEWPORT, 0.6, 2.0, null)
	assert_vector(sin_maestro["centro"]).is_equal(Vector2(300, 150))
	# Con el minimo por encima de 1, el zoom es el minimo.
	var minimo: Dictionary = EncuadreCamara.inicial(limites, _VIEWPORT, 1.5, 2.0, Vector2(0, 300))
	assert_float(minimo["zoom"]).is_equal(1.5)
