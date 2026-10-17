# Sistema.md 11.5, 6 (rescate y Las caidas), 3.2 (Quema) y 5.2: lo que pasa con la tribu
# al terminar el combate. Corre una sola vez por combate (Plantel.cerrado).
# Toca a la tribu y, con la derrota o la huida, a la atacante nocturna, que se va
# (P-024, S-66). Con la victoria, su destino es una decision aparte (9.3, T30): la
# deja pendiente y no aplica la lealtad de la noche hasta que se decida (S-65).
# Las salvajes no cambian.
class_name Cierre
extends RefCounted

# Nombres de evento: claves de tablas/lealtad.json eventos (P-019).
const _MOTIVO_VICTORIA: String = "victoria"
const _MOTIVO_MUERTE: String = "muerte_en_el_grupo"
const _MOTIVO_MUERTE_AFINES: String = "muerte_en_el_grupo_afines"
const _MOTIVO_RESCATE: String = "rescate"

# Sistema.md 6 (T29): la eleccion de la rescatista. Es la misma instancia que
# ContextoCombate.rescate, la de la consulta Combate.rescatista_ahora.
var rescate: Rescate
var _vida_tras_caida: int
var _lealtad_por_victoria: int
var _tabla_lealtad: Dictionary
var _relaciones: Relaciones


# tabla_combate y tabla_lealtad: contenido de tablas/combate.json y tablas/lealtad.json.
static func desde_datos(tabla_combate: Dictionary, tabla_lealtad: Dictionary, relaciones: Relaciones) -> Cierre:
	var cierre: Cierre = Cierre.new()
	cierre._vida_tras_caida = tabla_combate["vida_tras_caida"]
	cierre._lealtad_por_victoria = (tabla_lealtad["eventos"] as Dictionary)[_MOTIVO_VICTORIA]
	cierre._tabla_lealtad = tabla_lealtad
	cierre._relaciones = relaciones
	cierre.rescate = Rescate.desde_datos(tabla_lealtad)
	return cierre


# surcos: los del combate, para cerrar los de la atacante que se va (11.2.1). Sin
# ellos (tests del cierre suelto), unos vacios.
func cerrar(plantel: Plantel, fin: FinCombate.Fin, surcos: Surcos = null) -> ResultadoCierre:
	var motivo: ResultadoCierre.Motivo = _motivo_rechazo(plantel, fin)
	if motivo != ResultadoCierre.Motivo.NINGUNO:
		return ResultadoCierre.new(false, motivo, fin)
	var resultado: ResultadoCierre = ResultadoCierre.new(true, motivo, fin)
	var acumulador: AcumuladorLealtad = AcumuladorLealtad.desde_datos(_tabla_lealtad)
	if fin == FinCombate.Fin.VICTORIA:
		_victoria(plantel, resultado, acumulador)
		var atacante: Criatura = atacante_caida(plantel)
		if atacante != null:
			resultado.destino_pendiente = atacante.id
	else:
		# Derrota por caida (6) o huida (11.7, T28): las caidas mueren igual.
		_derrota(plantel, resultado, acumulador)
		_atacantes_se_van(plantel, resultado, Surcos.new() if surcos == null else surcos)
	# Sistema.md 5.2 y S-65 (T30): con el destino pendiente, la noche sigue abierta.
	if resultado.destino_pendiente.is_empty():
		resultado.lealtad = acumulador.aplicar(plantel.criaturas())
	else:
		resultado.acumulador = acumulador
	# Sistema.md 11.2.2, Fin del combate: se borran el estado oculto y el bono.
	Junco.limpiar(plantel)
	# Sistema.md 10.5, Fin del combate: el Encono vuelve a 0 (todos los bandos).
	for criatura in plantel.criaturas():
		criatura.encono = 0
	plantel.cerrado = true
	return resultado


func _motivo_rechazo(plantel: Plantel, fin: FinCombate.Fin) -> ResultadoCierre.Motivo:
	if plantel.cerrado:
		return ResultadoCierre.Motivo.YA_CERRADO
	if fin == FinCombate.Fin.EN_CURSO:
		return ResultadoCierre.Motivo.COMBATE_EN_CURSO
	if fin != FinCombate.evaluar(plantel):
		return ResultadoCierre.Motivo.FIN_NO_COINCIDE
	return ResultadoCierre.Motivo.NINGUNO


# Sistema.md 11.5: las caidas se levantan con la vida de combate.json, en su
# casilla. 5.2: +1 a las sueltas al terminar (de pie, levantadas e invocadas,
# T26); las guardadas no.
func _victoria(plantel: Plantel, resultado: ResultadoCierre, acumulador: AcumuladorLealtad) -> void:
	for criatura in _tribu(plantel, Criatura.Estado.CAIDA):
		criatura.estado = Criatura.Estado.SUELTA
		criatura.vida = _vida_tras_caida
		resultado.levantadas.append(criatura.id)
	for criatura in _tribu(plantel, Criatura.Estado.SUELTA):
		acumulador.anotar(criatura.id, _lealtad_por_victoria, _MOTIVO_VICTORIA)


# Sistema.md 6, 11.5 y 11.7: las caidas mueren y su pergamino arde (3.2). 5.2 y
# P-001: por cada muerta, cada suelta pierde lo de afines si su especie se lleva
# bien con la de la muerta (10.8) y lo general si no. Las guardadas no se tocan.
# Con la huida nadie recibe el +1: las sueltas de pie se van con el Maestro.
# Sistema.md 6 (T29): si cayo el Maestro, la rescatista se elige antes de todo
# cambio de lealtad (S-62) y su +2 va al mismo acumulador (suma y recorte unicos,
# 5.2); sin rescatista, permadeath. La huida no rescata.
func _derrota(plantel: Plantel, resultado: ResultadoCierre, acumulador: AcumuladorLealtad) -> void:
	resultado.maestro_caido = plantel.maestro.caido
	var eventos: Dictionary = _tabla_lealtad["eventos"]
	if plantel.maestro.caido:
		resultado.rescatista = rescate.elegir(plantel)
		resultado.permadeath = resultado.rescatista.is_empty()
		if not resultado.permadeath:
			acumulador.anotar(resultado.rescatista, eventos[_MOTIVO_RESCATE], _MOTIVO_RESCATE)
	var muertas: Array[Criatura] = caidas_que_mueren(plantel)
	for muerta in muertas:
		muerta.estado = Criatura.Estado.MUERTA
		plantel.pergamino(muerta.pergamino_id).arder()
		muerta.pergamino_id = ""
		resultado.muertas.append(muerta.id)
	var sueltas: Array[Criatura] = _tribu(plantel, Criatura.Estado.SUELTA)
	for muerta in muertas:
		for suelta in sueltas:
			if _relaciones.relacion(muerta.especie.id(), suelta.especie.id()) == Relaciones.Relacion.BIEN:
				acumulador.anotar(suelta.id, eventos[_MOTIVO_MUERTE_AFINES], _MOTIVO_MUERTE_AFINES)
			else:
				acumulador.anotar(suelta.id, eventos[_MOTIVO_MUERTE], _MOTIVO_MUERTE)


# Sistema.md 9.2 paso 6 (P-024) y S-66 (T30): con la derrota o la huida, la
# atacante nocturna del tablero, de pie o caida, se va: su pergamino arde y sale
# del tablero por la unica salida (VidaCero.sacar_del_tablero). Va despues de
# _motivo_rechazo: sacarla antes podria cambiar el fin que da el Plantel. Su ida
# no anota lealtad (el acumulador solo recorre a la tribu).
func _atacantes_se_van(plantel: Plantel, resultado: ResultadoCierre, surcos: Surcos) -> void:
	for criatura in plantel.criaturas():
		if criatura.comportamiento != Criatura.Comportamiento.ATACANTE_NOCTURNA:
			continue
		if criatura.estado != Criatura.Estado.SUELTA and criatura.estado != Criatura.Estado.CAIDA:
			continue
		if not criatura.pergamino_id.is_empty():
			plantel.pergamino(criatura.pergamino_id).arder()
			criatura.pergamino_id = ""
		VidaCero.sacar_del_tablero(criatura, surcos)
		resultado.se_fueron.append(criatura.id)


# Sistema.md 9.3 (T30): la atacante nocturna caida que espera su destino tras la
# victoria, o null. Es el unico criterio: lo usan el Cierre y ResultadoCombate.
static func atacante_caida(plantel: Plantel) -> Criatura:
	for criatura in plantel.criaturas():
		if criatura.comportamiento == Criatura.Comportamiento.ATACANTE_NOCTURNA \
				and criatura.estado == Criatura.Estado.CAIDA:
			return criatura
	return null


# Sistema.md 6 y 11.7: las que mueren si el combate se pierde o se huye, las
# caidas de la tribu (siempre en el tablero), en su orden. La usa tambien la
# previsualizacion de la huida (T28), con el Plantel de ahora.
static func caidas_que_mueren(plantel: Plantel) -> Array[Criatura]:
	return _tribu(plantel, Criatura.Estado.CAIDA)


# Las de la tribu en ese estado, en su orden.
static func _tribu(plantel: Plantel, estado: Criatura.Estado) -> Array[Criatura]:
	var resultado: Array[Criatura] = []
	for criatura in plantel.criaturas():
		if criatura.bando == Criatura.Bando.TRIBU and criatura.estado == estado:
			resultado.append(criatura)
	return resultado
