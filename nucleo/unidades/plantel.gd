# Contenedor de las entidades de un combate: el Maestro, las criaturas (la tribu
# en su orden y despues las enemigas) y los pergaminos. Es el unico que guarda
# los objetos; las entidades se apuntan por id y se buscan aca (Arquitectura.md A.5).
# Tablero, semilla, golpe inicial y toggles son de T12.
class_name Plantel
extends RefCounted

const _FORMATO_ID_PERGAMINO: String = "pergamino_%d"

const _ESTADOS: Dictionary = {
	"suelta": Criatura.Estado.SUELTA,
	"guardada": Criatura.Estado.GUARDADA,
}
const _COMPORTAMIENTOS: Dictionary = {
	"salvaje": Criatura.Comportamiento.SALVAJE,
	"atacante_nocturna": Criatura.Comportamiento.ATACANTE_NOCTURNA,
}

var maestro: Maestro
# El cierre ya corrio (T10): se ejecuta una sola vez por combate. Estado del
# combate: no viene del escenario.
var cerrado: bool = false
var _criaturas: Array[Criatura] = []
var _pergaminos: Array[Pergamino] = []


# Recibe lo que entrega Cargador.cargar_carpeta()["datos"] y un escenario (A.7).
static func desde_datos(datos: Dictionary, escenario: Dictionary) -> Plantel:
	var especies: Dictionary = {}
	for ruta in datos.keys():
		if (ruta as String).begins_with("especies/"):
			var especie: Especie = Especie.new(datos[ruta])
			especies[especie.id()] = especie
	var tabla_balanza: TablaBalanza = TablaBalanza.new(datos["tablas/balanza.json"])
	return desde_escenario(escenario, especies, tabla_balanza, datos["maestro.json"])


# escenario ya validado por el Cargador: especies e ids no se vuelven a chequear.
# especies: id de especie -> Especie. ficha_maestro: contenido de maestro.json.
# null en el escenario = valor por defecto (A.7).
static func desde_escenario(escenario: Dictionary, especies: Dictionary, tabla_balanza: TablaBalanza, ficha_maestro: Dictionary) -> Plantel:
	var plantel: Plantel = Plantel.new()
	plantel.maestro = _crear_maestro(escenario["maestro"], tabla_balanza, ficha_maestro)

	# Sistema.md 3.2 y 9.2: ocupan pergamino la tribu (suelta o guardada) y la
	# atacante nocturna; las salvajes no. Ids en orden: tribu, atacantes, en blanco.
	var ocupantes: Array[Criatura] = []
	for datos_criatura in (escenario["tribu"] as Array):
		var criatura: Criatura = _crear_criatura(datos_criatura, especies, Criatura.Bando.TRIBU)
		criatura.estado = _ESTADOS[datos_criatura["estado"]]
		criatura.lealtad = datos_criatura["lealtad"]
		plantel._criaturas.append(criatura)
		ocupantes.append(criatura)
	for datos_criatura in (escenario["enemigas"] as Array):
		var criatura: Criatura = _crear_criatura(datos_criatura, especies, Criatura.Bando.ENEMIGA)
		criatura.comportamiento = _COMPORTAMIENTOS[datos_criatura["comportamiento"]]
		plantel._criaturas.append(criatura)
		if criatura.comportamiento == Criatura.Comportamiento.ATACANTE_NOCTURNA:
			ocupantes.append(criatura)

	for criatura in ocupantes:
		var pergamino: Pergamino = plantel._nuevo_pergamino()
		pergamino.ocupar(criatura.id)
		criatura.pergamino_id = pergamino.id
	for _i in range(escenario["pergaminos_en_blanco"] as int):
		plantel._nuevo_pergamino()
	return plantel


func criatura(id_criatura: String) -> Criatura:
	for c in _criaturas:
		if c.id == id_criatura:
			return c
	return null


func criaturas() -> Array[Criatura]:
	return _criaturas.duplicate()


func pergamino(id_pergamino: String) -> Pergamino:
	for p in _pergaminos:
		if p.id == id_pergamino:
			return p
	return null


func pergaminos() -> Array[Pergamino]:
	return _pergaminos.duplicate()


# Foto del estado para comparar (tests, reproductor de T12): solo enteros,
# textos, booleanos, null, listas y diccionarios. Criaturas en el orden del Plantel.
func instantanea() -> Dictionary:
	var lista_criaturas: Array = []
	for c in _criaturas:
		lista_criaturas.append({
			"id": c.id,
			"estado": nombre_estado(c.estado),
			"vida": c.vida,
			"lealtad": c.lealtad,
			"posicion": casilla_a_lista(c.posicion),
			"erizada": c.erizada,
			"ya_ataco": c.ya_ataco,
			"pergamino": c.pergamino_id,
		})
	var lista_pergaminos: Array = []
	for p in _pergaminos:
		lista_pergaminos.append({
			"id": p.id,
			"estado": (Pergamino.Estado.keys()[p.estado] as String).to_lower(),
			"ocupante": p.ocupante_id,
		})
	return {
		"maestro": {
			"vida": maestro.vida,
			"posicion": casilla_a_lista(maestro.posicion),
			"caido": maestro.caido,
		},
		"criaturas": lista_criaturas,
		"pergaminos": lista_pergaminos,
		"cerrado": cerrado,
	}


# "suelta", "guardada", "caida", "fuera", "muerta".
static func nombre_estado(estado: Criatura.Estado) -> String:
	return (Criatura.Estado.keys()[estado] as String).to_lower()


# [x, y], o null si no esta en el tablero.
static func casilla_a_lista(casilla: Vector2i) -> Variant:
	if casilla == Criatura.SIN_POSICION:
		return null
	return [casilla.x, casilla.y]


func _nuevo_pergamino() -> Pergamino:
	var nuevo: Pergamino = Pergamino.new(_FORMATO_ID_PERGAMINO % [_pergaminos.size() + 1])
	_pergaminos.append(nuevo)
	return nuevo


static func _crear_maestro(datos_maestro: Dictionary, tabla_balanza: TablaBalanza, ficha_maestro: Dictionary) -> Maestro:
	var nuevo: Maestro = Maestro.new(tabla_balanza, datos_maestro["balanza"])
	nuevo.poder = datos_maestro["poder"]
	nuevo.regeneracion = datos_maestro["regeneracion"]
	# vida null: la vida maxima de la balanza, que ya pone _init.
	if datos_maestro.get("vida") != null:
		nuevo.vida = datos_maestro["vida"]
	# hambre null: la inicial de maestro.json (Sistema.md 11.9).
	if datos_maestro.get("hambre") != null:
		nuevo.hambre = datos_maestro["hambre"]
	else:
		nuevo.hambre = (ficha_maestro["iniciales"] as Dictionary)["hambre"]
	nuevo.enfermedades = datos_maestro.get("enfermedades", 0)
	nuevo.movimiento = ficha_maestro["movimiento"]
	nuevo.alcance = ficha_maestro["alcance"]
	nuevo.velocidad = ficha_maestro["velocidad"]
	nuevo.posicion = _posicion(datos_maestro.get("posicion"))
	# Tal cual llega: se resuelve en T21.
	nuevo.mana_entrada = datos_maestro.get("mana_entrada")
	return nuevo


# Campos comunes a la tribu y a las enemigas.
static func _crear_criatura(datos_criatura: Dictionary, especies: Dictionary, bando: Criatura.Bando) -> Criatura:
	var nueva: Criatura = Criatura.new(datos_criatura["id"], especies[datos_criatura["especie"]], bando)
	# vida null: la de la ficha, que ya pone _init (Sistema.md 7.8).
	if datos_criatura.get("vida") != null:
		nueva.vida = datos_criatura["vida"]
	# En las enemigas solo lo trae la atacante (Sistema.md 9.1).
	nueva.hambre = datos_criatura.get("hambre", 0)
	nueva.enfermedades = datos_criatura.get("enfermedades", 0)
	nueva.posicion = _posicion(datos_criatura.get("posicion"))
	return nueva


# posicion null o ausente: la ubica el jugador en el despliegue.
static func _posicion(valor: Variant) -> Vector2i:
	if valor == null:
		return Criatura.SIN_POSICION
	var par: Array = valor
	return Vector2i(par[0], par[1])
