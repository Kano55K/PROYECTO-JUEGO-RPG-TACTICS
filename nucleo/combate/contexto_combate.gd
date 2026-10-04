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
}

# Arquitectura.md A.8: nombres de sistema para derivar los generadores.
const SISTEMA_COMBATE: String = "combate"
const SISTEMA_TEXTOS: String = "textos"

var valido: bool = false
var motivo: Motivo = Motivo.NINGUNO

var escenario_id: String
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
var danio: Danio
var cierre: Cierre
var relaciones: Relaciones
# Huella de los datos (A.7). La calcula HuellaDatos (T12, sesion 2); hasta
# entonces queda vacia.
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
	contexto.tipo = escenario["tipo"]
	contexto.semilla = escenario["semilla"]
	contexto.tablero = Tablero.desde_datos(escenario["tablero"], tabla_combate)
	contexto.plantel = Plantel.desde_datos(datos, escenario)
	if escenario.get("golpe_inicial") != null:
		contexto.golpe_inicial = escenario["golpe_inicial"]
	contexto.toggles = escenario.get("toggles", {}).duplicate(true)
	contexto.azar_combate = GeneradorAzar.derivado(contexto.semilla, SISTEMA_COMBATE)
	contexto.azar_textos = GeneradorAzar.derivado(contexto.semilla, SISTEMA_TEXTOS)
	contexto.danio = Danio.desde_datos(tabla_combate, datos["tablas/hambre.json"])
	contexto.relaciones = Relaciones.new(datos["relaciones.json"])
	contexto.cierre = Cierre.desde_datos(tabla_combate, datos["tablas/lealtad.json"], contexto.relaciones)
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
