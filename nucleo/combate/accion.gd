# Sistema.md 11.3, Turno de una unidad: una accion del turno, como dato. Son las
# mismas para el jugador y para la IA (T11), y asi las graba el registro (T12).
class_name Accion
extends RefCounted

# Hechizo, sellar, guardar, invocar y huir son tipos nuevos en T22, T24 y T26 a T28.
enum Tipo { MOVER, ATACAR, ERIZARSE, TERMINAR }

var tipo: Tipo
# Solo para MOVER: la casilla de destino.
var casilla: Vector2i = Criatura.SIN_POSICION
# Solo para ATACAR: el id de la unidad objetivo.
var objetivo_id: String = ""


func _init(tipo_accion: Tipo) -> void:
	tipo = tipo_accion


static func mover(destino: Vector2i) -> Accion:
	var accion: Accion = Accion.new(Tipo.MOVER)
	accion.casilla = destino
	return accion


static func atacar(id_objetivo: String) -> Accion:
	var accion: Accion = Accion.new(Tipo.ATACAR)
	accion.objetivo_id = id_objetivo
	return accion


static func erizarse() -> Accion:
	return Accion.new(Tipo.ERIZARSE)


# Cierra el turno. Sin haber usado la accion, es "esperar" (P-015).
static func terminar() -> Accion:
	return Accion.new(Tipo.TERMINAR)


# Sistema.md 11.3: invocar y huir gastan el turno completo. Ningun tipo de hoy
# lo hace; los de T26 a T28 devolveran true aca.
func gasta_turno_completo() -> bool:
	return false
