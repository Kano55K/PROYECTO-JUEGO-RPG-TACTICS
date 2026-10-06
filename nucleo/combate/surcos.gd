# Sistema.md 11.2.1, El surco: los surcos del combate. El dueno es el Combate
# (Arquitectura.md B.2.1, T37); el Tablero los recibe por parametro y el Turno
# los cava. Cada surco apunta a su Surcon por id (A.5). Lleva un historial de
# cambios que el Combate vuelca al registro, como las tiradas: las reglas nunca
# escriben el registro.
class_name Surcos
extends RefCounted

# Sistema.md 11.2.1: el efecto de rasgo que cava y pisa surcos. Nunca se mira el id.
const EFECTO: String = "surco"
# Arquitectura.md A.7: motivos del evento surco_cerrado.
const MOTIVO_TOPE: String = "tope"
const MOTIVO_DUENIO_FUERA: String = "duenio_fuera"

# {casilla: Vector2i, duenio_id: String, orden: int}, del mas viejo al mas nuevo.
var _surcos: Array[Dictionary] = []
# Contador del combate: el orden en que se cavo cada surco (desde 1).
var _ultimo_orden: int = 0
# Eventos `surco` y `surco_cerrado` (A.7), en el orden en que pasaron.
var _historial: Array[Dictionary] = []


# Sistema.md 11.2.1, Transito: una unidad cuya especie tiene el efecto surco, de
# cualquier bando. El Maestro no.
static func es_surcon(unidad_id: String, plantel: Plantel) -> bool:
	var criatura: Criatura = plantel.criatura(unidad_id)
	return criatura != null and criatura.especie.rasgo()["efecto"] == EFECTO


func hay_en(casilla: Vector2i) -> bool:
	for surco in _surcos:
		if surco["casilla"] == casilla:
			return true
	return false


# Las casillas de los surcos de un Surcon, del mas viejo al mas nuevo.
func de(duenio_id: String) -> Array[Vector2i]:
	var resultado: Array[Vector2i] = []
	for surco in _surcos:
		if surco["duenio_id"] == duenio_id:
			resultado.append(surco["casilla"])
	return resultado


# Sistema.md 11.2.1, Tope: si el dueno pasa de `tope`, se cierra su mas viejo.
# Primero se cava y despues se cierra. Las comprobaciones de donde son del Turno.
func cavar(casilla: Vector2i, duenio_id: String, tope: int) -> void:
	_ultimo_orden += 1
	_surcos.append({"casilla": casilla, "duenio_id": duenio_id, "orden": _ultimo_orden})
	_historial.append({"tipo": "surco", "unidad": duenio_id, "casilla": Plantel.casilla_a_lista(casilla)})
	var propios: Array[Vector2i] = de(duenio_id)
	if propios.size() > tope:
		_cerrar(propios[0], MOTIVO_TOPE)


# Sistema.md 11.2.1, Duracion: todos los surcos de un Surcon se cierran cuando
# sale del tablero. La unica funcion para eso: hoy la llama VidaCero (fuera);
# despues guardar, huir y sellar (T24 a T28). Caido no se llama.
func cerrar_de(duenio_id: String) -> void:
	for casilla in de(duenio_id):
		_cerrar(casilla, MOTIVO_DUENIO_FUERA)


# Copia de los eventos, para que el Combate vuelque los nuevos al registro.
func historial() -> Array[Dictionary]:
	return _historial.duplicate(true)


# Arquitectura.md A.7: los surcos del combate, del mas viejo al mas nuevo.
func instantanea() -> Array:
	var resultado: Array = []
	for surco in _surcos:
		resultado.append({"casilla": Plantel.casilla_a_lista(surco["casilla"]),
				"duenio": surco["duenio_id"], "orden": surco["orden"]})
	return resultado


func _cerrar(casilla: Vector2i, motivo: String) -> void:
	for indice in range(_surcos.size()):
		var surco: Dictionary = _surcos[indice]
		if surco["casilla"] == casilla:
			_surcos.remove_at(indice)
			_historial.append({"tipo": "surco_cerrado", "casilla": Plantel.casilla_a_lista(casilla),
					"duenio": surco["duenio_id"], "motivo": motivo})
			return
