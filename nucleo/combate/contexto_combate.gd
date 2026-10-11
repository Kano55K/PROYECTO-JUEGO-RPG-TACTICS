# Arquitectura.md A.7: la entrada del combate, armada desde un escenario (en 0a,
# un archivo; en 0b, la partida) y los datos cargados (T03). Junta lo que el
# bucle necesita: tablero, Plantel, generadores derivados de la semilla (A.8) y
# las reglas ya creadas. No juega nada: eso es Combate.
class_name ContextoCombate
extends RefCounted

enum Motivo {
	NINGUNO,
	# Una unidad del tablero sin posicion: el despliegue manual no es de 0a (A-1).
	DESPLIEGUE_NO_IMPLEMENTADO,
	# D-008 (T22): una regla de ReglasCombate no se pudo armar (falta su archivo o un
	# dato); su nombre queda en regla_faltante.
	REGLA_FALTANTE,
}

# Arquitectura.md A.8: nombres de sistema para derivar los generadores.
const SISTEMA_COMBATE: String = "combate"
const SISTEMA_TEXTOS: String = "textos"

var valido: bool = false
var motivo: Motivo = Motivo.NINGUNO
# Con REGLA_FALTANTE, el nombre de la regla (ReglasCombate.falta); si no, "".
var regla_faltante: String = ""

var escenario_id: String
# Copia del escenario tal como se juega: lo guarda la Grabacion (A.7).
var escenario: Dictionary = {}
# "test", "nodo", "emboscada" o "nocturno", tal cual el escenario.
var tipo: String
var semilla: int
var tablero: Tablero
var plantel: Plantel
# id de la atacante del golpe inicial, o "" si no hay (A.7). Lo resuelve T30.
var golpe_inicial: String = ""
var toggles: Dictionary = {}
# Generadores separados: una frase nueva no cambia las tiradas del combate (A.2.1).
var azar_combate: GeneradorAzar
var azar_textos: GeneradorAzar
var cierre: Cierre
var relaciones: Relaciones
# Sistema.md 5.4 (T14): se pregunta, nunca se guarda. La leen la pantalla y T15 a T20.
var obediencia: Obediencia
# Sistema.md 7.2 (T14): la usa el Combate al cerrar cada ronda.
var hambre_combate: HambreCombate
# D-008 (T21-ajustes): las reglas sin estado, armadas una vez. Las recibe el Turno.
var reglas: ReglasCombate
# Acceso de lectura a cada regla de `reglas`, para el Combate y los tests. Con
# el contexto sin armar (no valido), null, como antes de D-008.
var danio: Danio:
	get: return null if reglas == null else reglas.danio
# Sistema.md 2.1 y 2.2 (T21): la regeneracion de mana del Maestro. La aplica el Turno.
var regeneracion_mana: RegeneracionMana:
	get: return null if reglas == null else reglas.regeneracion_mana
# Sistema.md 10.3 (T15): la usa el Turno para el aporte de afinidad.
var afinidad: Afinidad:
	get: return null if reglas == null else reglas.afinidad
# Sistema.md 10.2 y 1.3 (T16): la regla del bono de combo. La cadena es del Combate.
var combo: Combo:
	get: return null if reglas == null else reglas.combo
# Sistema.md 10.4 y 1.3 (T18): la regla del incidente. La aplica el Turno con azar_combate.
var incidente: Incidente:
	get: return null if reglas == null else reglas.incidente
# Sistema.md 10.5, 10.6 y 1.3 (T19): el chequeo de rival enemiga. Lo aplica el Turno con azar_combate.
var chequeo_rival: ChequeoRival:
	get: return null if reglas == null else reglas.chequeo_rival
# Sistema.md 1.6 (T22): los hechizos del Maestro. Los lanza el Turno.
var hechizos: Hechizos:
	get: return null if reglas == null else reglas.hechizos
# Huella de los datos (A.7, HuellaDatos): va en el evento `inicio` y en la Grabacion.
var huella: String = ""


# escenario: ya validado por el Cargador. datos: Cargador.cargar_carpeta()["datos"].
# Si no vale, solo `valido` y `motivo` tienen sentido.
static func armar(escenario: Dictionary, datos: Dictionary) -> ContextoCombate:
	var contexto: ContextoCombate = ContextoCombate.new()
	if _falta_posicion(escenario):
		contexto.motivo = Motivo.DESPLIEGUE_NO_IMPLEMENTADO
		return contexto
	var tabla_combate: Dictionary = datos["tablas/combate.json"]
	contexto.escenario_id = escenario["id"]
	contexto.escenario = escenario.duplicate(true)
	contexto.huella = HuellaDatos.calcular(datos)
	contexto.tipo = escenario["tipo"]
	contexto.semilla = escenario["semilla"]
	contexto.tablero = Tablero.desde_datos(escenario["tablero"], tabla_combate)
	contexto.plantel = Plantel.desde_datos(datos, escenario)
	if escenario.get("golpe_inicial") != null:
		contexto.golpe_inicial = escenario["golpe_inicial"]
	contexto.toggles = escenario.get("toggles", {}).duplicate(true)
	contexto.azar_combate = GeneradorAzar.derivado(contexto.semilla, SISTEMA_COMBATE)
	contexto.azar_textos = GeneradorAzar.derivado(contexto.semilla, SISTEMA_TEXTOS)
	var regla_danio: Danio = Danio.desde_datos(tabla_combate, datos["tablas/hambre.json"])
	contexto.relaciones = Relaciones.new(datos["relaciones.json"])
	contexto.cierre = Cierre.desde_datos(tabla_combate, datos["tablas/lealtad.json"], contexto.relaciones)
	contexto.obediencia = Obediencia.desde_datos(datos["tablas/hambre.json"], datos["tablas/lealtad.json"], tabla_combate)
	contexto.hambre_combate = HambreCombate.desde_datos(datos["tablas/hambre.json"])
	var regla_mana: RegeneracionMana = RegeneracionMana.desde_datos(datos["tablas/hambre.json"])
	var regla_afinidad: Afinidad = Afinidad.desde_datos(tabla_combate, contexto.relaciones, contexto.obediencia)
	var arrimo: Arrimo = Arrimo.desde_datos(datos["tablas/arrimo.json"])
	var regla_combo: Combo = Combo.desde_datos(tabla_combate, arrimo, regla_afinidad)
	var regla_incidente: Incidente = Incidente.desde_datos(tabla_combate, arrimo, contexto.relaciones,
			contexto.obediencia)
	var regla_chequeo: ChequeoRival = ChequeoRival.desde_datos(tabla_combate, arrimo, contexto.relaciones,
			contexto.obediencia, regla_afinidad, contexto.toggles.get("afines_contra_cobardia", false))
	var regla_hechizos: Hechizos = Hechizos.desde_datos(datos.get("hechizos.json", {}), datos["maestro.json"])
	contexto.reglas = ReglasCombate.new(regla_danio, regla_afinidad, regla_combo, regla_incidente, regla_chequeo,
			regla_mana, regla_hechizos)
	# D-008: sin todas las reglas el combate no se arma (hallazgo de la revision de T21-ajustes).
	if not contexto.reglas.falta.is_empty():
		contexto.motivo = Motivo.REGLA_FALTANTE
		contexto.regla_faltante = contexto.reglas.falta
		return contexto
	contexto.valido = true
	return contexto


# Las unidades que van al tablero (Maestro, tribu suelta y enemigas) necesitan
# posicion; una guardada no ocupa casilla y va con null (P-023, lectura declarada).
static func _falta_posicion(escenario: Dictionary) -> bool:
	if (escenario["maestro"] as Dictionary).get("posicion") == null:
		return true
	for criatura in (escenario["tribu"] as Array):
		if criatura["estado"] != "guardada" and criatura.get("posicion") == null:
			return true
	for criatura in (escenario["enemigas"] as Array):
		if criatura.get("posicion") == null:
			return true
	return false
