# Arquitectura.md A.6 y A.7: reproduce una Grabacion con los datos que recibe.
# Mismo escenario + mismas acciones del jugador = mismo registro, porque las
# tiradas salen de la semilla y la IA del estado. Se puede detener en la accion
# N (base del guardado de suspension de 0b): el estado justo despues de aplicar
# la N-esima accion del jugador y de jugar los turnos de la IA que siguen.
class_name Reproductor
extends RefCounted

# El combate reproducido (null si el escenario no se pudo armar).
var combate: Combate = null
# La huella de los datos no es la de la grabacion: se avisa y se sigue.
var aviso_huella: bool = false
# "" si todo salio bien.
var error: String = ""
# N (desde 1) de la accion de la grabacion que fallo; 0 si ninguna.
var accion_con_error: int = 0


# datos: con la forma de Cargador.cargar_carpeta()["datos"]. hasta_n: cuantas
# acciones del jugador aplicar; -1 = todas. N = 0 es antes de la primera.
static func reproducir(grabacion: Grabacion, datos: Dictionary, hasta_n: int = -1) -> Reproductor:
	var reproduccion: Reproductor = Reproductor.new()
	var total: int = grabacion.acciones.size()
	if hasta_n > total:
		reproduccion.error = "la grabacion tiene %d acciones y se pidio hasta la %d" % [total, hasta_n]
		return reproduccion
	var contexto: ContextoCombate = ContextoCombate.armar(grabacion.escenario, datos)
	if not contexto.valido:
		reproduccion.error = "escenario rechazado: " + ContextoCombate.Motivo.keys()[contexto.motivo]
		return reproduccion
	reproduccion.aviso_huella = contexto.huella != grabacion.huella
	reproduccion.combate = Combate.empezar(contexto)
	if not reproduccion.combate.error().is_empty():
		reproduccion.error = reproduccion.combate.error()
		return reproduccion
	var cantidad: int = total if hasta_n < 0 else hasta_n
	for indice in range(cantidad):
		var problema: String = reproduccion._aplicar(grabacion.acciones[indice])
		if not problema.is_empty():
			reproduccion.accion_con_error = indice + 1
			reproduccion.error = "accion %d: %s" % [indice + 1, problema]
			return reproduccion
	return reproduccion


# "" si la accion se aplico; si no, por que no.
func _aplicar(grabada: Dictionary) -> String:
	if not combate.esperando_jugador():
		return "el combate no espera una accion del jugador"
	if combate.turno_actual().unidad_id != grabada["unidad"]:
		return "es el turno de %s, no de %s" % [combate.turno_actual().unidad_id, grabada["unidad"]]
	var accion: Accion = Accion.desde_diccionario(grabada["accion"])
	if accion == null:
		return "accion ilegible: " + str(grabada["accion"])
	var resultado: ResultadoAccion = combate.aplicar(accion)
	if not resultado.valida:
		return "rechazada (%s): %s" % [ResultadoAccion.Motivo.keys()[resultado.motivo], str(grabada["accion"])]
	return combate.error()
