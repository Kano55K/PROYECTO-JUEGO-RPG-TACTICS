# Arquitectura.md A.6 y A.11 (T43, T19, T20): el jugador que espera, para los
# tests con datos/ real que juegan escenarios enteros (test_contacto.gd y
# test_robustez_ia.gd). Solo termina, salvo lo minimo que obliga una regla.
class_name JugadorEsperando
extends RefCounted


# CLAUDE.md, "Test de contacto" (excepcion autorizada en T19; A.11): si una regla
# no deja terminar el turno (una enconada, S-35), juega lo minimo que obliga:
# ataca a la primera objetivo que acepta el nucleo o, si no puede, se mueve a la
# primera casilla que acepta. Todo sale de las consultas del Turno. Devuelve ""
# si el turno quedo listo para terminar (o termino el combate), o que fallo.
static func lo_obligado(combate: Combate) -> String:
	var turno: Turno = combate.turno_actual()
	while not turno.puede_terminar():
		var accion: Accion = null
		if not turno.objetivos_para_atacar().is_empty():
			accion = Accion.atacar(turno.objetivos_para_atacar()[0])
		elif not turno.casillas_para_mover().is_empty():
			accion = Accion.mover(turno.casillas_para_mover()[0])
		if accion == null:
			return "turno sin salida"
		var resultado: ResultadoAccion = combate.aplicar(accion)
		if not resultado.valida:
			return "%s rechazada: %s" % [Accion.Tipo.keys()[accion.tipo], ResultadoAccion.Motivo.keys()[resultado.motivo]]
		if combate.terminado():
			return ""
	return ""
