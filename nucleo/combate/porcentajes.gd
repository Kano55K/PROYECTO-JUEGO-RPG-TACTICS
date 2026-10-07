# Sistema.md 8.4 y 11.4: los porcentajes se suman y se aplican de una vez,
# redondeando hacia abajo. Sin minimo: el del danio lo pone Danio; la
# recoleccion de 0b reusa esta funcion y puede dar 0 (K-05).
class_name Porcentajes
extends RefCounted

const _CIEN: int = 100


# valor modificado por porcentaje (en puntos, con signo): +50 = x1,5; -125 = x(-0,25).
# Solo enteros. La division entera de GDScript trunca hacia 0: con un numerador
# negativo y no exacto, eso redondea hacia arriba, asi que el piso se corrige a mano.
static func aplicar(valor: int, porcentaje: int) -> int:
	var numerador: int = valor * (_CIEN + porcentaje)
	var cociente: int = numerador / _CIEN
	if numerador % _CIEN != 0 and numerador < 0:
		cociente -= 1
	return cociente


# Sistema.md 10.4 (T18): una tirada en porcentaje con el generador que se pasa
# (el de combate, A.8). Sale si el entero de 1 a 100 es <= porcentaje. Una sola
# tirada: quien llama decide no tirar con 0 % (no consume el generador).
static func tirar(azar: GeneradorAzar, porcentaje: int) -> bool:
	return azar.entero(1, _CIEN) <= porcentaje
