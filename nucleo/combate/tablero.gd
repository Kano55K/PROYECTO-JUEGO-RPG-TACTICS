# Sistema.md 11.3: el tablero y su geometria. Solo consultas: reciben el Plantel
# y nunca lo modifican (mover y gastar turnos es de T08). Coordenadas de grilla
# [x, y], con y = 0 arriba. "Aliada" y "enemiga" son relativas al bando que se
# pasa: el de quien mueve o golpea.
class_name Tablero
extends RefCounted

# Orden de lectura: arriba, izquierda, derecha, abajo.
const _DIRECCIONES: Array[Vector2i] = [Vector2i.UP, Vector2i.LEFT, Vector2i.RIGHT, Vector2i.DOWN]

var ancho: int
var alto: int
# Filas del borde de cada bando para el despliegue (tablas/combate.json).
var despliegue_filas: int


func _init(ancho_tablero: int, alto_tablero: int, filas_despliegue: int) -> void:
	ancho = ancho_tablero
	alto = alto_tablero
	despliegue_filas = filas_despliegue


# tablero_escenario: {ancho, alto} del escenario. tabla_combate: tablas/combate.json.
static func desde_datos(tablero_escenario: Dictionary, tabla_combate: Dictionary) -> Tablero:
	return Tablero.new(tablero_escenario["ancho"], tablero_escenario["alto"], tabla_combate["despliegue_filas"])


func dentro(casilla: Vector2i) -> bool:
	return casilla.x >= 0 and casilla.x < ancho and casilla.y >= 0 and casilla.y < alto


# Sistema.md 11.3: todas las distancias son Manhattan.
static func distancia(a: Vector2i, b: Vector2i) -> int:
	return absi(a.x - b.x) + absi(a.y - b.y)


# Sistema.md 11.3, Adyacencia: las 4 ortogonales, dentro del tablero.
func vecinas(casilla: Vector2i) -> Array[Vector2i]:
	var resultado: Array[Vector2i] = []
	for direccion in _DIRECCIONES:
		var vecina: Vector2i = casilla + direccion
		if dentro(vecina):
			resultado.append(vecina)
	return resultado


func adyacentes(a: Vector2i, b: Vector2i) -> bool:
	return distancia(a, b) == 1


# Sistema.md 11.3, Movimiento: camino ortogonal de hasta `movimiento` pasos (BFS).
# Se pasa por aliadas y caidas propias, nunca por enemigas; no se termina en una
# casilla ocupada. Incluye `desde` (quedarse quieto). Orden de lectura.
func alcanzables(desde: Vector2i, movimiento: int, bando: Criatura.Bando, plantel: Plantel) -> Array[Vector2i]:
	var resultado: Array[Vector2i] = []
	resultado.assign(pasos_hasta(desde, movimiento, bando, plantel).keys())
	return _en_orden_de_lectura(resultado)


# Las mismas casillas que `alcanzables`, cada una con los pasos del camino mas
# corto (`desde` vale 0). La IA la usa para "la de menos movimiento" (11.8).
func pasos_hasta(desde: Vector2i, movimiento: int, bando: Criatura.Bando, plantel: Plantel) -> Dictionary:
	var ocupantes: Dictionary = _ocupantes(plantel)
	var pasos: Dictionary = {desde: 0}
	var frontera: Array[Vector2i] = [desde]
	while not frontera.is_empty():
		var actual: Vector2i = frontera.pop_front()
		if pasos[actual] == movimiento:
			continue
		for vecina in vecinas(actual):
			if pasos.has(vecina):
				continue
			if ocupantes.has(vecina) and ocupantes[vecina] != bando:
				continue
			pasos[vecina] = pasos[actual] + 1
			frontera.append(vecina)

	var resultado: Dictionary = {}
	for casilla in pasos.keys():
		if casilla == desde or not ocupantes.has(casilla):
			resultado[casilla] = pasos[casilla]
	return resultado


# Misma fila o misma columna (y casillas distintas).
func en_linea(a: Vector2i, b: Vector2i) -> bool:
	return a != b and (a.x == b.x or a.y == b.y)


# Las casillas entre a y b en linea recta, sin los extremos. Vacio si no estan en linea.
func casillas_entre(a: Vector2i, b: Vector2i) -> Array[Vector2i]:
	var resultado: Array[Vector2i] = []
	if not en_linea(a, b):
		return resultado
	var paso: Vector2i = (b - a).sign()
	var casilla: Vector2i = a + paso
	while casilla != b:
		resultado.append(casilla)
		casilla += paso
	return resultado


# Sistema.md 11.3, Alcance 2 (y la Lanzadera en T22): la linea la bloquea una
# enemiga en una casilla intermedia; una aliada no.
func linea_bloqueada(a: Vector2i, b: Vector2i, bando: Criatura.Bando, plantel: Plantel) -> bool:
	var ocupantes: Dictionary = _ocupantes(plantel)
	for casilla in casillas_entre(a, b):
		if ocupantes.has(casilla) and ocupantes[casilla] != bando:
			return true
	return false


# Sistema.md 11.1 y 11.3: casillas a las que se puede golpear desde `desde`.
# Alcance 1: las adyacentes. Mas alcance: ademas en linea recta, por encima de
# aliadas y nunca de enemigas. Son casillas, no objetivos (eso es T08).
func golpeables(desde: Vector2i, alcance: int, bando: Criatura.Bando, plantel: Plantel) -> Array[Vector2i]:
	var resultado: Array[Vector2i] = []
	for direccion in _DIRECCIONES:
		for distancia_linea in range(1, alcance + 1):
			var casilla: Vector2i = desde + direccion * distancia_linea
			if not dentro(casilla):
				break
			if not linea_bloqueada(desde, casilla, bando, plantel):
				resultado.append(casilla)
	return _en_orden_de_lectura(resultado)


# Sistema.md 11.3, Despliegue: las filas del borde de cada bando. La tribu,
# abajo; las enemigas, arriba (posiciones de A.9, P-007).
func despliegue(bando: Criatura.Bando) -> Array[Vector2i]:
	var resultado: Array[Vector2i] = []
	for y in range(alto):
		var de_la_tribu: bool = y >= alto - despliegue_filas
		var de_las_enemigas: bool = y < despliegue_filas
		if (bando == Criatura.Bando.TRIBU and de_la_tribu) or (bando == Criatura.Bando.ENEMIGA and de_las_enemigas):
			for x in range(ancho):
				resultado.append(Vector2i(x, y))
	return resultado


# Casilla -> bando de la unidad que la ocupa: el Maestro (de la tribu) y las
# criaturas en el tablero, de pie o caidas. Las guardadas no ocupan casilla.
func _ocupantes(plantel: Plantel) -> Dictionary:
	var ocupantes: Dictionary = {}
	if plantel.maestro.posicion != Criatura.SIN_POSICION:
		ocupantes[plantel.maestro.posicion] = Criatura.Bando.TRIBU
	for criatura in plantel.criaturas():
		if criatura.estado != Criatura.Estado.GUARDADA and criatura.posicion != Criatura.SIN_POSICION:
			ocupantes[criatura.posicion] = criatura.bando
	return ocupantes


static func _en_orden_de_lectura(casillas: Array[Vector2i]) -> Array[Vector2i]:
	var ordenadas: Array[Vector2i] = casillas.duplicate()
	ordenadas.sort_custom(func(a: Vector2i, b: Vector2i) -> bool: return a.y < b.y or (a.y == b.y and a.x < b.x))
	return ordenadas
