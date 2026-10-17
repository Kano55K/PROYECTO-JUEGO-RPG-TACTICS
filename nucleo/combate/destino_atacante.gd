# Sistema.md 9.3, 4.4, 2.3 y 5.2 (T30): el destino de la atacante nocturna caida
# tras la victoria, sin estado. El estado (quien espera, si ya fallo un sellado y
# el acumulador de la noche que dejo abierto el Cierre) es del Combate. Los
# numeros salen de CostosMana (fila de resellar, con el descuento), Sellado
# (primer tramo y lealtad al resellar), tablas/lealtad.json (perdon_a_leales,
# comer_atacante y el piso de Neutral) y tablas/combate.json (vida al resellar,
# P-046). La opcion se reconoce por su nombre, nunca por la especie.
class_name DestinoAtacante
extends RefCounted

const OPCION_PERDONAR: String = "perdonar"
const OPCION_SELLAR: String = "sellar"
const OPCION_COMER: String = "comer"
const OPCIONES: Array[String] = [OPCION_PERDONAR, OPCION_SELLAR, OPCION_COMER]
# Arquitectura.md A.7: el resultado del evento `destino_atacante`.
const RESULTADO_PERDONADA: String = "perdonada"
const RESULTADO_SELLADA: String = "sellada"
const RESULTADO_SELLADO_FALLIDO: String = "sellado_fallido"
const RESULTADO_COMIDA: String = "comida"
# A.7 y D-007: el motivo del evento `mana` que paga el resellado.
const MOTIVO_RESELLAR: String = "resellar"

# Nombres de evento: claves de tablas/lealtad.json eventos.
const _MOTIVO_PERDON: String = "perdon_a_leales"
const _MOTIVO_COMER: String = "comer_atacante"

var _costos: CostosMana
var _sellado: Sellado
var _vida: int = 0
var _perdon: int = 0
var _comer: int = 0
var _neutral_desde: int = 0


# null si falta un dato: sin valores por defecto (leccion de T09 y T37).
# costos y sellado: los de ReglasCombate, o null si no se pudieron armar.
static func desde_datos(tabla_combate: Dictionary, tabla_lealtad: Dictionary, costos: CostosMana,
		sellado: Sellado) -> DestinoAtacante:
	var eventos: Dictionary = tabla_lealtad.get("eventos", {})
	if costos == null or sellado == null or not tabla_combate.has("vida_al_resellar") \
			or not eventos.has(_MOTIVO_PERDON) or not eventos.has(_MOTIVO_COMER) \
			or not tabla_lealtad.has("neutral_desde"):
		return null
	var regla: DestinoAtacante = DestinoAtacante.new()
	regla._costos = costos
	regla._sellado = sellado
	regla._vida = tabla_combate["vida_al_resellar"]
	regla._perdon = eventos[_MOTIVO_PERDON]
	regla._comer = eventos[_MOTIVO_COMER]
	regla._neutral_desde = tabla_lealtad["neutral_desde"]
	return regla


# Sistema.md 4.4 y 2.3: el costo de invocar su rango, con la fila de resellar.
func costo(especie: Especie, maestro: Maestro) -> int:
	return _costos.resellar(especie, maestro)


# Sistema.md 4.4: la fila de vida <= 25 % de su rango.
func porcentaje(especie: Especie) -> int:
	return _sellado.porcentaje_resellar(especie)


# Sistema.md 4.4: la lealtad con la que vuelve, con el ajuste de la balanza.
func lealtad_resellar(maestro: Maestro) -> int:
	return _sellado.lealtad_resellar(maestro)


# P-046: la vida con la que queda guardada.
func vida() -> int:
	return _vida


# El unico chequeo del destino (el _motivo_destino del plan de T30), compartido
# por la accion, la consulta y la previsualizacion. atacante_id: la que espera, o
# "" si ninguna. En este orden: hay una pendiente, la opcion existe y, para
# sellar, que no haya fallado ya (4.4), un pergamino en blanco y el mana del costo.
func motivo(opcion: String, atacante_id: String, plantel: Plantel, sellar_fallido: bool) -> ResultadoAccion.Motivo:
	if atacante_id.is_empty():
		return ResultadoAccion.Motivo.SIN_DESTINO_PENDIENTE
	if not OPCIONES.has(opcion):
		return ResultadoAccion.Motivo.OPCION_INVALIDA
	if opcion == OPCION_SELLAR:
		if sellar_fallido:
			return ResultadoAccion.Motivo.SELLAR_YA_FALLO
		if plantel.pergamino_en_blanco() == null:
			return ResultadoAccion.Motivo.SIN_PERGAMINO
		if plantel.maestro.mana < costo(plantel.criatura(atacante_id).especie, plantel.maestro):
			return ResultadoAccion.Motivo.MANA_INSUFICIENTE
	return ResultadoAccion.Motivo.NINGUNO


# Calcular sin aplicar (aplica false) o aplicar: la misma cuenta. acumulador: el
# de la noche, que el Cierre dejo abierto con la victoria (S-65); el destino suma
# ahi sus anotaciones y lo aplica una sola vez. "Leal" se mide con la lealtad de
# ahora, antes de los cambios de la noche. Las sueltas son las de la tribu al
# terminar (con las levantadas). En las tres salidas su pergamino arde (al
# aplicar la primera, tambien si el sellado falla: 4.4, "su pergamino ya ardio").
#   perdonar: queda fuera; +1 a las leales.
#   comer: queda muerta; -2 a todas, incluidas sus afines, sin el -3 (P-002).
#   sellar: paga el mana; con % > 0, una tirada; con 0, falla sin tirar (como
#     S-50). Si sale, guardada de la tribu en el pergamino en blanco, con la
#     lealtad y la vida al resellar. Si falla, sigue caida: la noche no se cierra.
# Al validar, lealtad son los cambios que quedarian si la salida es final (en
# sellar, si sale).
func resolver(opcion: String, atacante_id: String, plantel: Plantel, acumulador: AcumuladorLealtad,
		sellar_fallido: bool, azar: GeneradorAzar, surcos: Surcos, aplica: bool) -> ResultadoAccion:
	var motivo_rechazo: ResultadoAccion.Motivo = motivo(opcion, atacante_id, plantel, sellar_fallido)
	if motivo_rechazo != ResultadoAccion.Motivo.NINGUNO:
		return ResultadoAccion.rechazada(motivo_rechazo)
	var atacante: Criatura = plantel.criatura(atacante_id)
	var maestro: Maestro = plantel.maestro
	var resultado: ResultadoAccion = ResultadoAccion.aceptada()
	var anotaciones: Array[AnotacionLealtad] = _anotaciones(opcion, plantel)
	if opcion == OPCION_SELLAR:
		resultado.costo = costo(atacante.especie, maestro)
		resultado.porcentaje = porcentaje(atacante.especie)
		if resultado.costo != 0:
			resultado.mana = {"de": maestro.mana, "a": maestro.mana - resultado.costo}
	if not aplica:
		resultado.lealtad = acumulador.calcular(plantel.criaturas(), anotaciones)
		return resultado

	if not atacante.pergamino_id.is_empty():
		plantel.pergamino(atacante.pergamino_id).arder()
		atacante.pergamino_id = ""
	var cierra_la_noche: bool = true
	var nombre_resultado: String = ""
	match opcion:
		OPCION_PERDONAR:
			VidaCero.sacar_del_tablero(atacante, surcos)
			nombre_resultado = RESULTADO_PERDONADA
		OPCION_COMER:
			VidaCero.sacar_del_tablero(atacante, surcos)
			atacante.estado = Criatura.Estado.MUERTA
			nombre_resultado = RESULTADO_COMIDA
		OPCION_SELLAR:
			maestro.mana -= resultado.costo
			cierra_la_noche = (resultado.porcentaje as int) > 0 and Porcentajes.tirar(azar, resultado.porcentaje)
			if cierra_la_noche:
				_resellar(atacante, plantel, surcos)
				nombre_resultado = RESULTADO_SELLADA
			else:
				nombre_resultado = RESULTADO_SELLADO_FALLIDO
	if cierra_la_noche:
		for anotacion in anotaciones:
			acumulador.anotar(anotacion.criatura_id, anotacion.cambio, anotacion.motivo)
		resultado.lealtad = acumulador.aplicar(plantel.criaturas())
	resultado.evento = {"tipo": "destino_atacante", "atacante": atacante_id, "opcion": opcion,
			"resultado": nombre_resultado, "lealtad": ResultadoCombate.cambios_a_lista(resultado.lealtad)}
	return resultado


# Sistema.md 9.3 y 5.2: lo que anota la opcion, por suelta de la tribu, en su orden.
func _anotaciones(opcion: String, plantel: Plantel) -> Array[AnotacionLealtad]:
	var anotaciones: Array[AnotacionLealtad] = []
	var umbral: int = plantel.maestro.fila_balanza()["umbral_rescate"]
	for criatura in plantel.criaturas():
		if criatura.bando != Criatura.Bando.TRIBU or criatura.estado != Criatura.Estado.SUELTA:
			continue
		if opcion == OPCION_COMER:
			anotaciones.append(AnotacionLealtad.new(criatura.id, _comer, _MOTIVO_COMER))
		elif opcion == OPCION_PERDONAR \
				and EstadosUnidad.corte(criatura.lealtad, _neutral_desde, umbral) == EstadosUnidad.Corte.LEAL:
			anotaciones.append(AnotacionLealtad.new(criatura.id, _perdon, _MOTIVO_PERDON))
	return anotaciones


# Sistema.md 4.4: vuelve guardada de la tribu, en el primer pergamino en blanco,
# fuera del tablero (sus surcos se cierran), con la lealtad y la vida al resellar.
func _resellar(atacante: Criatura, plantel: Plantel, surcos: Surcos) -> void:
	var pergamino: Pergamino = plantel.pergamino_en_blanco()
	pergamino.ocupar(atacante.id)
	atacante.pergamino_id = pergamino.id
	atacante.bando = Criatura.Bando.TRIBU
	atacante.comportamiento = Criatura.Comportamiento.NINGUNO
	atacante.estado = Criatura.Estado.GUARDADA
	atacante.posicion = Criatura.SIN_POSICION
	atacante.erizada = false
	surcos.cerrar_de(atacante.id)
	atacante.lealtad = lealtad_resellar(plantel.maestro)
	atacante.vida = _vida
