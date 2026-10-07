# Arquitectura.md B.3.1 (T42) y D-003: la cuenta de la camara de la vista de
# combate, sin nodos. Todo en coordenadas del lienzo: los limites salen de
# map_to_local de las esquinas del tablero, nunca de un tamanio de casilla.
# Es presentacion, no reglas: el nucleo no sabe que hay camara.
class_name EncuadreCamara
extends RefCounted


# El rectangulo entre dos esquinas (en cualquier orden), agrandado por margen
# de cada lado.
static func limites(esquina_a: Vector2, esquina_b: Vector2, margen: float) -> Rect2:
	var rectangulo: Rect2 = Rect2(esquina_a, Vector2.ZERO).expand(esquina_b)
	return rectangulo.grow(margen)


static func acotar_zoom(zoom: float, minimo: float, maximo: float) -> float:
	return clampf(zoom, minimo, maximo)


# El centro de la camara para que el area visible (viewport / zoom) no salga de
# los limites. Si en un eje el area es mas grande que los limites, queda
# centrada en ese eje.
static func acotar_centro(centro: Vector2, visible: Vector2, rectangulo: Rect2) -> Vector2:
	return Vector2(_acotar_eje(centro.x, visible.x, rectangulo.position.x, rectangulo.end.x),
			_acotar_eje(centro.y, visible.y, rectangulo.position.y, rectangulo.end.y))


# Si los limites entran enteros en el viewport con ese zoom.
static func entra_entero(rectangulo: Rect2, viewport: Vector2, zoom: float) -> bool:
	var visible: Vector2 = viewport / zoom
	return visible.x >= rectangulo.size.x and visible.y >= rectangulo.size.y


# Al abrir un escenario. Si el tablero entra entero con el zoom minimo, se
# encuadra entero, con el zoom mas cercano a 1 que lo sigue mostrando entero.
# Si no, se centra en el Maestro (centro_maestro: Vector2, o null si no esta en
# el tablero) con zoom 1, acotados. Devuelve {"centro": Vector2, "zoom": float}.
static func inicial(rectangulo: Rect2, viewport: Vector2, zoom_minimo: float, zoom_maximo: float,
		centro_maestro: Variant) -> Dictionary:
	if entra_entero(rectangulo, viewport, zoom_minimo):
		var ajuste: float = minf(viewport.x / rectangulo.size.x, viewport.y / rectangulo.size.y)
		var zoom: float = acotar_zoom(minf(1.0, ajuste), zoom_minimo, zoom_maximo)
		return {"centro": rectangulo.get_center(), "zoom": zoom}
	var zoom_maestro: float = acotar_zoom(1.0, zoom_minimo, zoom_maximo)
	var centro: Vector2 = rectangulo.get_center() if centro_maestro == null else centro_maestro
	return {"centro": acotar_centro(centro, viewport / zoom_maestro, rectangulo), "zoom": zoom_maestro}


static func _acotar_eje(centro: float, visible: float, desde: float, hasta: float) -> float:
	if visible >= hasta - desde:
		return (desde + hasta) / 2.0
	return clampf(centro, desde + visible / 2.0, hasta - visible / 2.0)
