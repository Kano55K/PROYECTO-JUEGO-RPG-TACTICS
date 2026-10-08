# Sistema.md 11.5, 6 (Las caidas), 3.2 (Quema) y 5.2: lo que pasa con la tribu
# al terminar el combate. Corre una sola vez por combate (Plantel.cerrado).
# Solo toca a la tribu: la atacante caida es de T30 y las salvajes no cambian.
class_name Cierre
extends RefCounted

# Nombres de evento: claves de tablas/lealtad.json eventos (P-019).
const _MOTIVO_VICTORIA: String = "victoria"
const _MOTIVO_MUERTE: String = "muerte_en_el_grupo"
const _MOTIVO_MUERTE_AFINES: String = "muerte_en_el_grupo_afines"

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
	return cierre


func cerrar(plantel: Plantel, fin: FinCombate.Fin) -> ResultadoCierre:
	var motivo: ResultadoCierre.Motivo = _motivo_rechazo(plantel, fin)
	if motivo != ResultadoCierre.Motivo.NINGUNO:
		return ResultadoCierre.new(false, motivo, fin)
	var resultado: ResultadoCierre = ResultadoCierre.new(true, motivo, fin)
	var acumulador: AcumuladorLealtad = AcumuladorLealtad.desde_datos(_tabla_lealtad)
	if fin == FinCombate.Fin.VICTORIA:
		_victoria(plantel, resultado, acumulador)
	else:
		_derrota(plantel, resultado, acumulador)
	resultado.lealtad = acumulador.aplicar(plantel.criaturas())
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
	if fin == FinCombate.Fin.HUIDA:
		return ResultadoCierre.Motivo.NO_IMPLEMENTADO
	if fin != FinCombate.evaluar(plantel):
		return ResultadoCierre.Motivo.FIN_NO_COINCIDE
	return ResultadoCierre.Motivo.NINGUNO


# Sistema.md 11.5: las caidas se levantan con la vida de combate.json, en su
# casilla. 5.2: +1 a las sueltas al terminar (de pie y levantadas; las invocadas,
# cuando exista invocar); las guardadas no.
func _victoria(plantel: Plantel, resultado: ResultadoCierre, acumulador: AcumuladorLealtad) -> void:
	for criatura in _tribu(plantel, Criatura.Estado.CAIDA):
		criatura.estado = Criatura.Estado.SUELTA
		criatura.vida = _vida_tras_caida
		resultado.levantadas.append(criatura.id)
	for criatura in _tribu(plantel, Criatura.Estado.SUELTA):
		acumulador.anotar(criatura.id, _lealtad_por_victoria, _MOTIVO_VICTORIA)


# Sistema.md 6 y 11.5: las caidas mueren y su pergamino arde (3.2). 5.2 y P-001:
# por cada muerta, cada suelta pierde lo de afines si su especie se lleva bien
# con la de la muerta (10.8) y lo general si no. Las guardadas no se tocan.
func _derrota(plantel: Plantel, resultado: ResultadoCierre, acumulador: AcumuladorLealtad) -> void:
	resultado.maestro_caido = plantel.maestro.caido
	var muertas: Array[Criatura] = _tribu(plantel, Criatura.Estado.CAIDA)
	for muerta in muertas:
		muerta.estado = Criatura.Estado.MUERTA
		plantel.pergamino(muerta.pergamino_id).arder()
		muerta.pergamino_id = ""
		resultado.muertas.append(muerta.id)
	var eventos: Dictionary = _tabla_lealtad["eventos"]
	var sueltas: Array[Criatura] = _tribu(plantel, Criatura.Estado.SUELTA)
	for muerta in muertas:
		for suelta in sueltas:
			if _relaciones.relacion(muerta.especie.id(), suelta.especie.id()) == Relaciones.Relacion.BIEN:
				acumulador.anotar(suelta.id, eventos[_MOTIVO_MUERTE_AFINES], _MOTIVO_MUERTE_AFINES)
			else:
				acumulador.anotar(suelta.id, eventos[_MOTIVO_MUERTE], _MOTIVO_MUERTE)


# Las de la tribu en ese estado, en su orden.
static func _tribu(plantel: Plantel, estado: Criatura.Estado) -> Array[Criatura]:
	var resultado: Array[Criatura] = []
	for criatura in plantel.criaturas():
		if criatura.bando == Criatura.Bando.TRIBU and criatura.estado == estado:
			resultado.append(criatura)
	return resultado
