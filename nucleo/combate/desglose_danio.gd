# El resultado de Danio.calcular, paso por paso de Sistema.md 11.4. Lo leen la
# pantalla (T13) y el registro (T12).
class_name DesgloseDanio
extends RefCounted

# Ficha, o balanza del Maestro.
var base: int = 0
# Primero los porcentajes y despues los planos, cada uno con su fuente.
var modificadores: Array[ModificadorDanio] = []
var porcentaje_total: int = 0
# Paso 2. Puede quedar en 0 o menos: el unico recorte es el minimo del paso 4 (P-017).
var tras_porcentajes: int = 0
var planos_total: int = 0
# true si el paso 4 subio el danio al minimo.
var minimo_aplicado: bool = false
var total: int = 0
