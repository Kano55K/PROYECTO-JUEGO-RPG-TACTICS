# Sistema.md 11.4: la unica funcion de danio de un ataque. Suma los porcentajes,
# los aplica al Danio base redondeando hacia abajo, suma los planos y pone el
# minimo. Calcula sola Saciado, enfermedades y los rasgos; combo, afinidad,
# Encono y cobardia llegan como aportes externos (T15, T16, T19).
class_name Danio
extends RefCounted

const _EFECTO_ERIZARSE: String = "erizarse"

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
	return calcular_con_base(_base(atacante_id, plantel), atacante_id, objetivo_id, plantel, aportes)


# El mismo calculo con otro Danio base: el del Martillazo (Sistema.md 1.6, T22),
# que reemplaza al de la ficha o la balanza. El resto de 11.4 es el del ataque.
func calcular_con_base(base: int, atacante_id: String, objetivo_id: String, plantel: Plantel,
		aportes: Array[ModificadorDanio] = []) -> DesgloseDanio:
	var desglose: DesgloseDanio = DesgloseDanio.new()
	desglose.base = base
	var objetivo: Criatura = plantel.criatura(objetivo_id)

	var porcentajes: Array[ModificadorDanio] = []
	var planos: Array[ModificadorDanio] = []
	_hambre_y_enfermedades(atacante_id, plantel, porcentajes)
	if objetivo != null:
		_rasgo_objetivo(objetivo, porcentajes)
		_modo(objetivo, objetivo.especie.recibido_pct(objetivo.modo), ModificadorDanio.Tipo.PORCENTAJE, porcentajes)
	var atacante: Criatura = plantel.criatura(atacante_id)
	if atacante != null:
		_modo(atacante, atacante.especie.danio_plano(atacante.modo), ModificadorDanio.Tipo.PLANO, planos)
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
	var estado: Dictionary = EstadosUnidad.fila_hambre(_estados_hambre, hambre)
	if estado.get("danio_pct", 0) != 0:
		porcentajes.append(ModificadorDanio.new(ModificadorDanio.Fuente.HAMBRE,
				ModificadorDanio.Tipo.PORCENTAJE, estado["danio_pct"], estado["id"]))
	for i in enfermedades:
		porcentajes.append(ModificadorDanio.new(ModificadorDanio.Fuente.ENFERMEDAD,
				ModificadorDanio.Tipo.PORCENTAJE, _enfermedad_pct))


# Sistema.md 11.2: rasgos de la objetivo, por su efecto en la ficha. Erizarse:
# -50% mientras esta erizada. Desde la v1.3 ningun rasgo da un plano pasivo (el
# surco reemplaza a Lomo de tierra, 11.2.1).
func _rasgo_objetivo(objetivo: Criatura, porcentajes: Array[ModificadorDanio]) -> void:
	var rasgo: Dictionary = objetivo.especie.rasgo()
	if rasgo["efecto"] == _EFECTO_ERIZARSE and objetivo.erizada:
		porcentajes.append(ModificadorDanio.new(ModificadorDanio.Fuente.RASGO_OBJETIVO,
				ModificadorDanio.Tipo.PORCENTAJE, rasgo["danio_recibido_pct"], rasgo["id"]))


# Sistema.md 11.2.2 y 11.4 paso 3: el bono de Hacerse junco de la atacante, por
# su efecto en la ficha, con el id del rasgo como detalle. Aca solo se suma: se
# cobra al aplicar el ataque (Turno, Junco), asi validar y previsualizar no lo gastan.
func _rasgo_atacante(atacante: Criatura, planos: Array[ModificadorDanio]) -> void:
	var rasgo: Dictionary = atacante.especie.rasgo()
	if rasgo["efecto"] == Junco.EFECTO and atacante.bono_junco:
		planos.append(ModificadorDanio.new(ModificadorDanio.Fuente.RASGO_ATACANTE,
				ModificadorDanio.Tipo.PLANO, rasgo["bono_plano"], rasgo["id"]))


# Sistema.md 11.2.3 y 11.4: el del modo actual, con el id del modo como detalle.
# El % recibido es de la objetivo (paso 1, +25% en Caza); el plano, de la
# atacante (paso 3, -1 en Cuenta). Sin modos los dos valen 0 y no se agregan.
func _modo(criatura: Criatura, valor: int, tipo: ModificadorDanio.Tipo, lista: Array[ModificadorDanio]) -> void:
	if valor != 0:
		lista.append(ModificadorDanio.new(ModificadorDanio.Fuente.MODO, tipo, valor, criatura.modo))
