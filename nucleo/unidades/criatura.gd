# Una criatura en el combate: instancia de una especie, de la tribu o enemiga.
# Apunta a otras entidades por id (pergamino_id), nunca guardando el objeto
# (Arquitectura.md A.5). La especie si se comparte, de solo lectura.
# Los cambios por regla (danio, lealtad, hambre, estado) llegan en T08-T10, T14 y T24-T27.
class_name Criatura
extends RefCounted

enum Bando { TRIBU, ENEMIGA }
# Sistema.md 3.1 y 11.5. FUERA: salio del tablero (la salvaje en 0; despues la
# huida, T25, y el sellado, T24). MUERTA: la caida de la tribu en la derrota
# (cierre, 11.5 y 6). Las dos existen solo durante el combate: no van a JSON.
enum Estado { SUELTA, GUARDADA, CAIDA, FUERA, MUERTA }
# NINGUNO = de la tribu. Sistema.md 10.7 (salvaje) y 9.2 (atacante nocturna).
enum Comportamiento { NINGUNO, SALVAJE, ATACANTE_NOCTURNA }

# posicion null del escenario: la ubica el jugador en el despliegue.
const SIN_POSICION: Vector2i = Vector2i(-1, -1)

var id: String
var especie: Especie
var bando: Bando
var comportamiento: Comportamiento = Comportamiento.NINGUNO
var estado: Estado = Estado.SUELTA
var vida: int
# Solo tiene sentido en la tribu: las enemigas no tienen obediencia propia (Obediencia, 10.7).
var lealtad: int = 0
var hambre: int = 0
var enfermedades: int = 0
# Coordenadas de grilla [x, y], con y = 0 arriba.
var posicion: Vector2i = SIN_POSICION
# "" = sin pergamino.
var pergamino_id: String = ""
# Sistema.md 11.2, Erizarse: hasta el inicio de su proximo turno (T08). Estado
# del combate: no viene del escenario.
var erizada: bool = false
# Sistema.md 11.2.3, Caza y cuenta: id del modo actual ("" sin modos). Arranca
# en el modo inicial; la cola lee de aca la Velocidad al armar cada ronda (11.3).
# Estado del combate: no viene del escenario.
var modo: String = ""
# Sistema.md 11.2.2, Hacerse junco. Estado del combate: no viene del escenario.
# Oculta: no es objetivo de acciones hostiles (Objetivos); sigue en su casilla.
var oculta: bool = false
# Su proximo ataque aplicado suma el bono_plano de la ficha. Es un si/no: volver
# a ocultarse con el bono no lo suma dos veces.
var bono_junco: bool = false
# Si se oculto en su turno anterior (no puede dos turnos seguidos). Lo escribe
# el fin de cada turno suyo.
var junco_turno_anterior: bool = false
# Sistema.md 10.5: el contador del Encono, de 0 al maximo de tablas/combate.json.
# Estado del combate (T19): no viene del escenario y el Cierre lo vuelve a 0.
var encono: int = 0


func _init(id_criatura: String, especie_criatura: Especie, bando_criatura: Bando) -> void:
	id = id_criatura
	especie = especie_criatura
	bando = bando_criatura
	vida = vida_max_real()
	modo = especie.modo_inicial()


# Sistema.md 7.8: la vida maxima real de una criatura es la de su ficha.
func vida_max_real() -> int:
	return especie.vida()
