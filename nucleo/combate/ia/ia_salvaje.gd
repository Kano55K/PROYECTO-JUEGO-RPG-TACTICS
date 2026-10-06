# Sistema.md 11.8: la IA de las salvajes; la atacante nocturna usa la misma
# (9.2, punto 3). Para el turno de la unidad devuelve las acciones que va a
# jugar, sin aplicar nada y sin azar. Recorre la lista de 11.8 en orden, un paso
# por funcion; el primero que decide, gana. El Tasajero la recorre en su unico
# turno de la ronda (Sistema.md 11.2.3), con el tablero de ese momento.
class_name IASalvaje
extends RefCounted

# Criterios de desempate para elegir objetivo (11.8 y S-19, P-020).
enum Criterio { MENOS_VIDA, MAS_CERCANA, ANTES_EN_COLA }
# Remate: menos vida -> mas cercana -> antes en la cola (tabla de 11.8).
const _DESEMPATE_REMATE: Array[Criterio] = [Criterio.MENOS_VIDA, Criterio.MAS_CERCANA, Criterio.ANTES_EN_COLA]
# Cercana y acercarse: mas cercana -> menos vida -> antes en la cola (paso 5, S-19, P-020).
const _DESEMPATE_CERCANA: Array[Criterio] = [Criterio.MAS_CERCANA, Criterio.MENOS_VIDA, Criterio.ANTES_EN_COLA]

const _EFECTO_ERIZARSE: String = "erizarse"


# cola: la de la ronda en curso, para "la que actua antes en la cola" (P-021).
static func decidir(turno: Turno, plantel: Plantel, cola: ColaIniciativa) -> DecisionIA:
	var orden: Dictionary = _orden(cola, plantel)
	var decision: DecisionIA = _paso_huida(turno, plantel)
	if decision == null:
		decision = _paso_encono(turno, plantel)
	if decision == null:
		decision = _paso_erizarse(turno, plantel)
	if decision != null:
		return decision
	var opciones: Array[OpcionAtaque] = _opciones(turno, plantel)
	decision = _paso_remate(turno, plantel, opciones, orden)
	if decision == null:
		decision = _paso_cercana(turno, plantel, opciones, orden)
	if decision == null:
		decision = _paso_acercarse(turno, plantel, orden)
	return decision


# Paso 1, lugar vacio: la huida con vida <= 25% es de T25 (11.7).
static func _paso_huida(_turno: Turno, _plantel: Plantel) -> DecisionIA:
	return null


# Paso 2, lugar vacio: la enconada va por su rival (10.5), T19/T20. La regla de
# la acobardada (no terminar mas cerca de su rival) tambien es de T19/T20.
static func _paso_encono(_turno: Turno, _plantel: Plantel) -> DecisionIA:
	return null


# Paso 3: con el rasgo (por efecto, no por id), vida <= umbral de la ficha y una
# enemiga de pie adyacente, se eriza sin moverse. En enteros: vida * 100 <=
# vida maxima * umbral. Una caida adyacente no cuenta (P-022).
static func _paso_erizarse(turno: Turno, plantel: Plantel) -> DecisionIA:
	var unidad: Criatura = plantel.criatura(turno.unidad_id)
	var rasgo: Dictionary = unidad.especie.rasgo()
	if rasgo["efecto"] != _EFECTO_ERIZARSE or not turno.puede_erizarse():
		return null
	if unidad.vida * 100 > unidad.vida_max_real() * int(rasgo["umbral_vida_pct"]):
		return null
	var adyacente: bool = false
	for id_enemiga in _enemigas_de_pie(unidad.bando, plantel):
		if Tablero.distancia(unidad.posicion, _posicion(id_enemiga, plantel)) == 1:
			adyacente = true
	if not adyacente:
		return null
	var decision: DecisionIA = DecisionIA.new(DecisionIA.Paso.ERIZARSE)
	decision.casilla = unidad.posicion
	decision.acciones.append(Accion.erizarse())
	decision.acciones.append(Accion.terminar())
	return decision


# Paso 4: si puede tumbar a alguna este turno, va por esa. Desempate: menos vida
# actual -> mas cercana -> antes en la cola (11.8).
static func _paso_remate(turno: Turno, plantel: Plantel, opciones: Array[OpcionAtaque], orden: Dictionary) -> DecisionIA:
	var tumbables: Array[OpcionAtaque] = []
	for opcion in opciones:
		if opcion.puede_tumbar():
			tumbables.append(opcion)
	if tumbables.is_empty():
		return null
	var objetivo_id: String = _elegir_objetivo(_candidatas(tumbables), _DESEMPATE_REMATE, orden)
	return _atacar(DecisionIA.Paso.REMATE, turno, plantel, tumbables, objetivo_id)


# Paso 5: la mas cercana que puede alcanzar; si empatan, la de menos vida, y
# despues antes en la cola (S-19, P-020).
static func _paso_cercana(turno: Turno, plantel: Plantel, opciones: Array[OpcionAtaque], orden: Dictionary) -> DecisionIA:
	if opciones.is_empty():
		return null
	var objetivo_id: String = _elegir_objetivo(_candidatas(opciones), _DESEMPATE_CERCANA, orden)
	return _atacar(DecisionIA.Paso.CERCANA, turno, plantel, opciones, objetivo_id)


# Paso 6: no alcanza a nadie. Va hacia la enemiga de pie mas cercana (-> menos
# vida -> antes en la cola), a la casilla alcanzable mas cercana a ella (->
# orden de lectura). Si ninguna la acerca, no se mueve.
static func _paso_acercarse(turno: Turno, plantel: Plantel, orden: Dictionary) -> DecisionIA:
	var unidad: Criatura = plantel.criatura(turno.unidad_id)
	var decision: DecisionIA = DecisionIA.new(DecisionIA.Paso.ACERCARSE)
	decision.casilla = unidad.posicion
	var candidatas: Array[Dictionary] = []
	for id_enemiga in _enemigas_de_pie(unidad.bando, plantel):
		candidatas.append(_candidata(id_enemiga, _vida(id_enemiga, plantel),
				Tablero.distancia(unidad.posicion, _posicion(id_enemiga, plantel))))
	if not candidatas.is_empty():
		decision.objetivo_id = _elegir_objetivo(candidatas, _DESEMPATE_CERCANA, orden)
		var hasta: Vector2i = _posicion(decision.objetivo_id, plantel)
		var mejor: Vector2i = unidad.posicion
		for casilla: Vector2i in turno.pasos_para_mover().keys():
			if _menor([Tablero.distancia(casilla, hasta), casilla.y, casilla.x],
					[Tablero.distancia(mejor, hasta), mejor.y, mejor.x]):
				mejor = casilla
		if Tablero.distancia(mejor, hasta) < Tablero.distancia(unidad.posicion, hasta):
			decision.casilla = mejor
			decision.acciones.append(Accion.mover(mejor))
	decision.acciones.append(Accion.terminar())
	return decision


# Todos los ataques del turno completo (S-8): cada casilla a la que llega
# (incluida la suya) contra cada unidad. Turno descarta aliadas, caidas y las
# que no estan en el tablero: nadie apunta a una caida (11.8).
static func _opciones(turno: Turno, plantel: Plantel) -> Array[OpcionAtaque]:
	var origen: Vector2i = plantel.criatura(turno.unidad_id).posicion
	var ids: Array[String] = [Maestro.ID]
	for criatura in plantel.criaturas():
		ids.append(criatura.id)
	var opciones: Array[OpcionAtaque] = []
	var pasos: Dictionary = turno.pasos_para_mover()
	for casilla: Vector2i in pasos.keys():
		for id_objetivo in ids:
			var resultado: ResultadoAccion = turno.previsualizar_ataque(casilla, id_objetivo)
			if resultado.valida:
				var posicion: Vector2i = _posicion(id_objetivo, plantel)
				opciones.append(OpcionAtaque.new(casilla, pasos[casilla], id_objetivo, resultado.danio,
						_vida(id_objetivo, plantel), Tablero.distancia(origen, posicion), Tablero.distancia(casilla, posicion)))
	return opciones


# Las acciones de un ataque a `objetivo_id`, desde la mejor casilla entre las opciones.
static func _atacar(paso: DecisionIA.Paso, turno: Turno, plantel: Plantel, opciones: Array[OpcionAtaque], objetivo_id: String) -> DecisionIA:
	var origen: Vector2i = plantel.criatura(turno.unidad_id).posicion
	var de_la_objetivo: Array[OpcionAtaque] = []
	for opcion in opciones:
		if opcion.objetivo_id == objetivo_id:
			de_la_objetivo.append(opcion)
	var elegida: OpcionAtaque = _mejor_casilla(de_la_objetivo, origen)
	var decision: DecisionIA = DecisionIA.new(paso)
	decision.objetivo_id = objetivo_id
	decision.casilla = elegida.casilla
	decision.danio_previsto = elegida.danio
	if elegida.casilla != origen:
		decision.acciones.append(Accion.mover(elegida.casilla))
	decision.acciones.append(Accion.atacar(objetivo_id))
	decision.acciones.append(Accion.terminar())
	return decision


# Sistema.md 11.8, Casilla desde donde golpear: si ya alcanza desde donde esta,
# no se mueve -> la mas lejana a la objetivo (la de Alcance 2 prefiere la
# distancia 2; con Alcance 1 todas estan a 1) -> menos pasos -> orden de lectura.
static func _mejor_casilla(opciones: Array[OpcionAtaque], origen: Vector2i) -> OpcionAtaque:
	var mejor: OpcionAtaque = null
	for opcion in opciones:
		if opcion.casilla == origen:
			return opcion
		if mejor == null or _menor(_clave_casilla(opcion), _clave_casilla(mejor)):
			mejor = opcion
	return mejor


static func _clave_casilla(opcion: OpcionAtaque) -> Array:
	return [-opcion.distancia_golpe, opcion.pasos, opcion.casilla.y, opcion.casilla.x]


# Una candidata por objetivo: los datos de la objetivo son los mismos en todas sus opciones.
static func _candidatas(opciones: Array[OpcionAtaque]) -> Array[Dictionary]:
	var vistas: Dictionary = {}
	var candidatas: Array[Dictionary] = []
	for opcion in opciones:
		if not vistas.has(opcion.objetivo_id):
			vistas[opcion.objetivo_id] = true
			candidatas.append(_candidata(opcion.objetivo_id, opcion.vida_objetivo, opcion.distancia_objetivo))
	return candidatas


static func _candidata(id_objetivo: String, vida: int, distancia: int) -> Dictionary:
	return {"id": id_objetivo, "vida": vida, "distancia": distancia}


# La primera segun los criterios, en orden. El orden de la cola es total (ver
# _orden), asi que no quedan empates.
static func _elegir_objetivo(candidatas: Array[Dictionary], criterios: Array[Criterio], orden: Dictionary) -> String:
	var mejor: Dictionary = {}
	for candidata in candidatas:
		if mejor.is_empty() or _menor(_clave_objetivo(candidata, criterios, orden), _clave_objetivo(mejor, criterios, orden)):
			mejor = candidata
	return mejor["id"]


static func _clave_objetivo(candidata: Dictionary, criterios: Array[Criterio], orden: Dictionary) -> Array:
	var clave: Array = []
	for criterio in criterios:
		match criterio:
			Criterio.MENOS_VIDA:
				clave.append(candidata["vida"])
			Criterio.MAS_CERCANA:
				clave.append(candidata["distancia"])
			Criterio.ANTES_EN_COLA:
				clave.append(orden[candidata["id"]])
	return clave


# Id -> lugar en la cola de la ronda entera, por su primera entrada, tambien si
# ya actuo (P-021). La que no esta en la cola va al final, en el orden del
# Plantel (decision tecnica: en 0a no pasa).
static func _orden(cola: ColaIniciativa, plantel: Plantel) -> Dictionary:
	var orden: Dictionary = {}
	var entradas: Array[EntradaCola] = cola.entradas()
	for indice in range(entradas.size()):
		if not orden.has(entradas[indice].unidad_id):
			orden[entradas[indice].unidad_id] = indice
	var siguiente: int = entradas.size()
	var ids: Array[String] = [Maestro.ID]
	for criatura in plantel.criaturas():
		ids.append(criatura.id)
	for id_unidad in ids:
		if not orden.has(id_unidad):
			orden[id_unidad] = siguiente
			siguiente += 1
	return orden


# Comparacion lexicografica de dos claves de enteros del mismo largo.
static func _menor(a: Array, b: Array) -> bool:
	for indice in range(a.size()):
		if a[indice] != b[indice]:
			return a[indice] < b[indice]
	return false


# Ids de las unidades de pie en el tablero del otro bando: el Maestro y las sueltas.
static func _enemigas_de_pie(bando: Criatura.Bando, plantel: Plantel) -> Array[String]:
	var ids: Array[String] = []
	if bando != Criatura.Bando.TRIBU and not plantel.maestro.caido \
			and plantel.maestro.posicion != Criatura.SIN_POSICION:
		ids.append(Maestro.ID)
	for criatura in plantel.criaturas():
		if criatura.bando != bando and criatura.estado == Criatura.Estado.SUELTA \
				and criatura.posicion != Criatura.SIN_POSICION:
			ids.append(criatura.id)
	return ids


static func _posicion(id_unidad: String, plantel: Plantel) -> Vector2i:
	if id_unidad == Maestro.ID:
		return plantel.maestro.posicion
	return plantel.criatura(id_unidad).posicion


static func _vida(id_unidad: String, plantel: Plantel) -> int:
	if id_unidad == Maestro.ID:
		return plantel.maestro.vida
	return plantel.criatura(id_unidad).vida
