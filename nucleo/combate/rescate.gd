# Sistema.md 6 (T29): quien rescata al Maestro cuando cae. Sin estado. Es la unica
# eleccion de la rescatista: la usan el Cierre y Combate.rescatista_ahora (D-005).
# Lectura declarada S-62: mira la lealtad del momento en que se pregunta (antes
# de los cambios del cierre). Nunca mira la obediencia (5.4).
class_name Rescate
extends RefCounted

var _neutral_desde: int


# tabla_lealtad: tablas/lealtad.json (el piso de Neutral de los cortes, P-003).
static func desde_datos(tabla_lealtad: Dictionary) -> Rescate:
	var rescate: Rescate = Rescate.new()
	rescate._neutral_desde = tabla_lealtad["neutral_desde"]
	return rescate


# Sistema.md 6: suelta, de pie en el tablero (Objetivos.de_pie: la oculta cuenta;
# no las caidas, guardadas ni las que salieron), de la tribu y Leal: lealtad real
# >= umbral de rescate de la balanza del Maestro (5.1, EstadosUnidad.corte).
func es_candidata(criatura: Criatura, plantel: Plantel) -> bool:
	if criatura.bando != Criatura.Bando.TRIBU or not Objetivos.de_pie(criatura.id, plantel):
		return false
	var umbral: int = plantel.maestro.fila_balanza()["umbral_rescate"]
	return EstadosUnidad.corte(criatura.lealtad, _neutral_desde, umbral) == EstadosUnidad.Corte.LEAL


# Sistema.md 6, eleccion: mayor lealtad real -> mas cercana al Maestro (Manhattan
# desde su casilla, la de la caida si cayo) -> orden de la tribu. El id, o "" si
# no hay ninguna (permadeath).
func elegir(plantel: Plantel) -> String:
	var elegida: Criatura = null
	var distancia_elegida: int = 0
	for criatura in plantel.criaturas():
		if not es_candidata(criatura, plantel):
			continue
		var distancia: int = Tablero.distancia(criatura.posicion, plantel.maestro.posicion)
		if elegida == null or criatura.lealtad > elegida.lealtad \
				or (criatura.lealtad == elegida.lealtad and distancia < distancia_elegida):
			elegida = criatura
			distancia_elegida = distancia
	return "" if elegida == null else elegida.id
