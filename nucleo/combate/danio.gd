# Sistema.md 11.4: la unica funcion de danio de un ataque. En T08 da el Danio
# base (la ficha, o la balanza para el Maestro) con el minimo del paso 4. T09
# suma porcentajes y planos (incluido el -50% de Erizarse) sin cambiar quien la llama.
class_name Danio
extends RefCounted

var danio_minimo: int


func _init(minimo: int) -> void:
	danio_minimo = minimo


# tabla_combate: tablas/combate.json.
static func desde_datos(tabla_combate: Dictionary) -> Danio:
	return Danio.new(tabla_combate["danio_minimo"])


# No modifica el Plantel: sirve igual para validar y para aplicar un ataque.
# El objetivo lo usa T09 (Lomo de tierra, Erizarse).
func calcular(atacante_id: String, _objetivo_id: String, plantel: Plantel) -> int:
	return maxi(danio_minimo, _base(atacante_id, plantel))


# Sistema.md 11.2: el Maestro pega el de su balanza (1.2); una criatura, el de su ficha.
func _base(atacante_id: String, plantel: Plantel) -> int:
	if atacante_id == Maestro.ID:
		return plantel.maestro.danio_cuerpo()
	return plantel.criatura(atacante_id).especie.danio()
