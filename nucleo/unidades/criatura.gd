# Una criatura en el combate: instancia de una especie, de la tribu o enemiga.
# Apunta a otras entidades por id (pergamino_id), nunca guardando el objeto
# (Arquitectura.md A.5). La especie si se comparte, de solo lectura.
# Los cambios por regla (danio, lealtad, hambre, estado) llegan en T08-T10, T14 y T24-T27.
class_name Criatura
extends RefCounted

enum Bando { TRIBU, ENEMIGA }
# Sistema.md 3.1 y 11.5
enum Estado { SUELTA, GUARDADA, CAIDA }
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
# Solo tiene sentido en la tribu: la obediencia de las enemigas es de T14 (10.7).
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
# Sistema.md 11.2, Hacerse junco: true desde que aplico su primer ataque del
# combate (T09). Estado del combate: no viene del escenario.
var ya_ataco: bool = false


func _init(id_criatura: String, especie_criatura: Especie, bando_criatura: Bando) -> void:
	id = id_criatura
	especie = especie_criatura
	bando = bando_criatura
	vida = vida_max_real()


# Sistema.md 7.8: la vida maxima real de una criatura es la de su ficha.
func vida_max_real() -> int:
	return especie.vida()
