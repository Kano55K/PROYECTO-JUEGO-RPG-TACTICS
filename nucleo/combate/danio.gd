# Sistema.md 11.4: la unica funcion de danio de un ataque. Suma los porcentajes,
# los aplica al Danio base redondeando hacia abajo, suma los planos y pone el
# minimo. Calcula sola Saciado, enfermedades y los rasgos; combo, afinidad,
# Encono y cobardia llegan como aportes externos (T15, T16, T19).
class_name Danio
extends RefCounted

var danio_minimo: int
var _enfermedad_pct: int
# Estados de tablas/hambre.json.
var _estados_hambre: Array = []


func _init(minimo: int, enfermedad_pct: int, estados_hambre: Array) -> void:
	danio_minimo = minimo
	_enfermedad_pct = enfermedad_pct
	_estados_hambre = estados_hambre


# tabla_combate: tablas/combate.json. tabla_hambre: tablas/hambre.json, obligatoria
# (Saciado, 7.1): sin sus estados devuelve null, sin valor por defecto (T12).
static func desde_datos(tabla_combate: Dictionary, tabla_hambre: Dictionary) -> Danio:
	if not tabla_hambre.has("estados"):
		return null
	return Danio.new(tabla_combate["danio_minimo"], tabla_combate["enfermedad_danio_pct"],
			tabla_hambre["estados"])


# No modifica el Plantel: sirve igual para validar y para aplicar un ataque.
func calcular(atacante_id: String, objetivo_id: String, plantel: Plantel,
		aportes: Array[ModificadorDanio] = []) -> DesgloseDanio:
	var desglose: DesgloseDanio = DesgloseDanio.new()
	desglose.base = _base(atacante_id, plantel)
	var atacante: Criatura = plantel.criatura(atacante_id)
	var objetivo: Criatura = plantel.criatura(objetivo_id)

	var porcentajes: Array[ModificadorDanio] = []
	var planos: Array[ModificadorDanio] = []
	_hambre_y_enfermedades(atacante_id, plantel, porcentajes)
	if objetivo != null:
		_rasgo_objetivo(objetivo, porcentajes, planos)
	if atacante != null:
		_rasgo_atacante(atacante, planos)
	for aporte in aportes:
		if aporte.tipo == ModificadorDanio.Tipo.PORCENTAJE:
			porcentajes.append(aporte)
		else:
			planos.append(aporte)

	# Paso 1 y 2
	for modificador in porcentajes:
		desglose.porcentaje_total += modificador.valor
	desglose.tras_porcentajes = Porcentajes.aplicar(desglose.base, desglose.porcentaje_total)
	# Paso 3
	for modificador in planos:
		desglose.planos_total += modificador.valor
	# Paso 4
	var sin_minimo: int = desglose.tras_porcentajes + desglose.planos_total
	desglose.minimo_aplicado = sin_minimo < danio_minimo
	desglose.total = maxi(danio_minimo, sin_minimo)

	desglose.modificadores.append_array(porcentajes)
	desglose.modificadores.append_array(planos)
	return desglose


# Sistema.md 11.2, Hacerse junco: el bono es del primer ataque del combate. Lo
# llama Turno solo al aplicar un ataque valido, nunca al validar.
func registrar_ataque(atacante_id: String, plantel: Plantel) -> void:
	var atacante: Criatura = plantel.criatura(atacante_id)
	if atacante != null:
		atacante.ya_ataco = true


# Sistema.md 11.2: el Maestro pega el de su balanza (1.2); una criatura, el de su ficha.
func _base(atacante_id: String, plantel: Plantel) -> int:
	if atacante_id == Maestro.ID:
		return plantel.maestro.danio_cuerpo()
	return plantel.criatura(atacante_id).especie.danio()


# Sistema.md 7.1 (Saciado, derivado del hambre) y 8.2 (cada enfermedad suma su
# porcentaje). Solo el Maestro y la tribu: las enemigas no tienen hambre ni
# enfermedades en el escenario (S-17, P-016).
func _hambre_y_enfermedades(atacante_id: String, plantel: Plantel, porcentajes: Array[ModificadorDanio]) -> void:
	var hambre: int
	var enfermedades: int
	if atacante_id == Maestro.ID:
		hambre = plantel.maestro.hambre
		enfermedades = plantel.maestro.enfermedades
	else:
		var atacante: Criatura = plantel.criatura(atacante_id)
		if atacante.bando != Criatura.Bando.TRIBU:
			return
		hambre = atacante.hambre
		enfermedades = atacante.enfermedades
	var estado: Dictionary = _estado_hambre(hambre)
	if estado.get("danio_pct", 0) != 0:
		porcentajes.append(ModificadorDanio.new(ModificadorDanio.Fuente.HAMBRE,
				ModificadorDanio.Tipo.PORCENTAJE, estado["danio_pct"], estado["id"]))
	for i in enfermedades:
		porcentajes.append(ModificadorDanio.new(ModificadorDanio.Fuente.ENFERMEDAD,
				ModificadorDanio.Tipo.PORCENTAJE, _enfermedad_pct))


func _estado_hambre(hambre: int) -> Dictionary:
	for estado in _estados_hambre:
		if hambre >= estado["desde"] and hambre <= estado["hasta"]:
			return estado
	return {}


# Sistema.md 11.2: rasgos de la objetivo, por su efecto en la ficha. Erizarse
# (-50% mientras esta erizada) y Lomo de tierra (-1 a cada golpe).
func _rasgo_objetivo(objetivo: Criatura, porcentajes: Array[ModificadorDanio], planos: Array[ModificadorDanio]) -> void:
	var rasgo: Dictionary = objetivo.especie.rasgo()
	match rasgo["efecto"]:
		"accion_defensa":
			if objetivo.erizada:
				porcentajes.append(ModificadorDanio.new(ModificadorDanio.Fuente.RASGO_OBJETIVO,
						ModificadorDanio.Tipo.PORCENTAJE, rasgo["danio_recibido_pct"], rasgo["id"]))
		"reduccion_plana":
			planos.append(ModificadorDanio.new(ModificadorDanio.Fuente.RASGO_OBJETIVO,
					ModificadorDanio.Tipo.PLANO, rasgo["danio_recibido_plano"], rasgo["id"]))


# Sistema.md 11.2: rasgos de la atacante, por su efecto. Hacerse junco: +2 si
# todavia no aplico ningun ataque en este combate.
func _rasgo_atacante(atacante: Criatura, planos: Array[ModificadorDanio]) -> void:
	var rasgo: Dictionary = atacante.especie.rasgo()
	if rasgo["efecto"] == "primer_ataque" and not atacante.ya_ataco:
		planos.append(ModificadorDanio.new(ModificadorDanio.Fuente.RASGO_ATACANTE,
				ModificadorDanio.Tipo.PLANO, rasgo["danio_plano"], rasgo["id"]))
