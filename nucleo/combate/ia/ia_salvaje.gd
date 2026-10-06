# Sistema.md 11.8 v1.3: la IA de las salvajes; la atacante nocturna usa la misma
# (9.2, punto 3). Para el turno de la unidad devuelve las acciones que va a
# jugar, sin aplicar nada y sin azar. Recorre la lista de 11.8 en orden, un paso
# por funcion; el primero que decide, gana. El Tasajero la recorre en su unico
# turno de la ronda (Sistema.md 11.2.3), con el modo y el tablero de ese momento.
# Los rasgos se reconocen por su efecto o por los numeros del modo, nunca por id.
class_name IASalvaje
extends RefCounted

# Criterios de desempate para elegir objetivo (11.8 y S-19, P-020).
enum Criterio { MENOS_VIDA, MAS_CERCANA, ANTES_EN_COLA }
# Remate: menos vida -> mas cercana -> antes en la cola (tabla de 11.8).
const _DESEMPATE_REMATE: Array[Criterio] = [Criterio.MENOS_VIDA, Criterio.MAS_CERCANA, Criterio.ANTES_EN_COLA]
# Cercana y acercarse: mas cercana -> menos vida -> antes en la cola (paso 6, S-19, P-020).
# Lectura declarada P-027: tambien desempata "la enemiga de pie mas cercana" de
# la retirada de la Cuenta y del surco.
const _DESEMPATE_CERCANA: Array[Criterio] = [Criterio.MAS_CERCANA, Criterio.MENOS_VIDA, Criterio.ANTES_EN_COLA]
# Lectura declarada P-026: que presas elige el Tasajero en Caza y en que orden
# las ataca, el criterio de S-23: menos vida -> antes en la cola.
const _DESEMPATE_PRESAS: Array[Criterio] = [Criterio.MENOS_VIDA, Criterio.ANTES_EN_COLA]
# Sistema.md 11.2.3: en Caza ataca a lo sumo a dos presas, un ataque a cada una.
const _PRESAS_POR_CASILLA: int = 2

const _EFECTO_ERIZARSE: String = "erizarse"


# cola: la de la ronda en curso, para "la que actua antes en la cola" (P-021).
static func decidir(turno: Turno, plantel: Plantel, cola: ColaIniciativa) -> DecisionIA:
	var orden: Dictionary = _orden(cola, plantel)
	var decision: DecisionIA = _paso_huida(turno, plantel)
	if decision == null:
		decision = _paso_encono(turno, plantel)
	if decision == null:
		decision = _paso_erizarse(turno, plantel)
	if decision == null:
		var opciones: Array[OpcionAtaque] = _opciones(turno, plantel)
		if _en_caza(turno, plantel):
			decision = _paso_caza(turno, plantel, opciones, orden)
		else:
			decision = _paso_remate(turno, plantel, opciones, orden)
			if decision == null:
				decision = _paso_cercana(turno, plantel, opciones, orden)
		if decision == null:
			decision = _paso_prepararse(turno, plantel, orden)
		if decision == null:
			decision = _paso_acercarse(turno, plantel, orden)
	# Paso 2: el cambio de modo ya lo hizo el inicio del turno (T36); la IA juega
	# con el modo que quedo y lo dice en la explicacion.
	var unidad: Criatura = plantel.criatura(turno.unidad_id)
	decision.modo = unidad.modo
	decision.cambio_modo = turno.cambio_modo.duplicate()
	return decision


# Paso 1, lugar vacio: la huida con vida <= 25% es de T25 (11.7).
static func _paso_huida(_turno: Turno, _plantel: Plantel) -> DecisionIA:
	return null


# Paso 3, lugar vacio: la enconada va por su rival (10.5), T19/T20. En Caza,
# solo el primero de sus dos ataques va a la rival; el segundo sigue el 6b. La
# regla de la acobardada (no terminar mas cerca de su rival) tambien es de T19/T20.
static func _paso_encono(_turno: Turno, _plantel: Plantel) -> DecisionIA:
	return null


# Paso 4: con el rasgo (por efecto, no por id), vida <= umbral de la ficha y una
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
	for id_enemiga in _enemigas(unidad.bando, plantel, false):
		if Tablero.distancia(unidad.posicion, _posicion(id_enemiga, plantel)) == 1:
			adyacente = true
	if not adyacente:
		return null
	var decision: DecisionIA = DecisionIA.new(DecisionIA.Paso.ERIZARSE)
	decision.casilla = unidad.posicion
	decision.acciones.append(Accion.erizarse())
	decision.acciones.append(Accion.terminar())
	return decision


# Paso 5: si puede tumbar a alguna este turno, va por esa. Desempate: menos vida
# actual -> mas cercana -> antes en la cola (11.8).
static func _paso_remate(turno: Turno, plantel: Plantel, opciones: Array[OpcionAtaque], orden: Dictionary) -> DecisionIA:
	var tumbables: Array[OpcionAtaque] = []
	for opcion in opciones:
		if opcion.puede_tumbar():
			tumbables.append(opcion)
	if tumbables.is_empty():
		return null
	var objetivo_id: String = _elegir_objetivo(_candidatas(tumbables), _DESEMPATE_REMATE, orden)
	return _atacar(DecisionIA.Paso.REMATE, turno, plantel, tumbables, objetivo_id, orden)


# Paso 6: la mas cercana que puede alcanzar; si empatan, la de menos vida, y
# despues antes en la cola (S-19, P-020).
static func _paso_cercana(turno: Turno, plantel: Plantel, opciones: Array[OpcionAtaque], orden: Dictionary) -> DecisionIA:
	if opciones.is_empty():
		return null
	var objetivo_id: String = _elegir_objetivo(_candidatas(opciones), _DESEMPATE_CERCANA, orden)
	return _atacar(DecisionIA.Paso.CERCANA, turno, plantel, opciones, objetivo_id, orden)


# Sistema.md 11.2.3: el modo da mas de un ataque y no parte el movimiento (Caza).
static func _en_caza(turno: Turno, plantel: Plantel) -> bool:
	var unidad: Criatura = plantel.criatura(turno.unidad_id)
	return turno.ataques_restantes >= _PRESAS_POR_CASILLA and not unidad.especie.movimiento_partido(unidad.modo)


# Paso 6b, Tasajero en Caza (reemplaza a 5 y 6). Por cada casilla a la que
# llega (incluida la suya), sus presas: las enemigas que golpea desde ahi y que
# la consulta unica acepta (las opciones ya pasan por ella). Con 2 o mas, un
# ataque a cada una de las 2 elegidas (P-026: menos vida -> antes en la cola);
# con 1, los dos ataques a esa. Si el primero tumba a la unica presa, el segundo
# se pierde (S-23): se planea uno solo. Desempates de la tabla de 11.8: junto a
# 2 presas > 1 -> la que tumba a alguien -> menos vida sumada -> menos pasos ->
# orden de lectura. "Prefiere repartir antes que ejecutar".
static func _paso_caza(turno: Turno, plantel: Plantel, opciones: Array[OpcionAtaque], orden: Dictionary) -> DecisionIA:
	var por_casilla: Dictionary = {}
	for opcion in opciones:
		if not por_casilla.has(opcion.casilla):
			var nueva: Array[OpcionAtaque] = []
			por_casilla[opcion.casilla] = nueva
		var de_la_casilla: Array[OpcionAtaque] = por_casilla[opcion.casilla]
		de_la_casilla.append(opcion)
	var mejor_golpes: Array[OpcionAtaque] = []
	var mejor_clave: Array = []
	for casilla: Vector2i in por_casilla.keys():
		var presas: Array[OpcionAtaque] = _presas_elegidas(por_casilla[casilla], orden)
		var golpes: Array[OpcionAtaque] = presas.duplicate()
		var tumba: bool = false
		var vida_sumada: int = 0
		for presa in presas:
			tumba = tumba or presa.puede_tumbar()
			vida_sumada += presa.vida_objetivo
		if presas.size() == 1:
			# Los dos golpes a la misma presa dan lo mismo: entre uno y otro no
			# cambia nada de lo que entra en el danio, solo la vida.
			tumba = presas[0].danio * 2 >= presas[0].vida_objetivo
			if not presas[0].puede_tumbar():
				golpes.append(presas[0])
		var clave: Array = [-presas.size(), -int(tumba), vida_sumada, presas[0].pasos, casilla.y, casilla.x]
		if mejor_clave.is_empty() or _menor(clave, mejor_clave):
			mejor_clave = clave
			mejor_golpes = golpes
	if mejor_golpes.is_empty():
		return null
	var decision: DecisionIA = DecisionIA.new(DecisionIA.Paso.CAZA)
	decision.casilla = mejor_golpes[0].casilla
	if decision.casilla != plantel.criatura(turno.unidad_id).posicion:
		decision.acciones.append(Accion.mover(decision.casilla))
	for golpe in mejor_golpes:
		decision.sumar_ataque(golpe.objetivo_id, golpe.danio)
	decision.acciones.append(Accion.terminar())
	return decision


# Las presas de una casilla a las que ataca, en el orden de sus ataques: las 2
# primeras por menos vida -> antes en la cola (P-026).
static func _presas_elegidas(de_la_casilla: Array[OpcionAtaque], orden: Dictionary) -> Array[OpcionAtaque]:
	var ordenadas: Array[OpcionAtaque] = de_la_casilla.duplicate()
	ordenadas.sort_custom(func(a: OpcionAtaque, b: OpcionAtaque) -> bool:
		return _menor(_clave_objetivo(_candidata(a.objetivo_id, a.vida_objetivo, a.distancia_objetivo), _DESEMPATE_PRESAS, orden),
				_clave_objetivo(_candidata(b.objetivo_id, b.vida_objetivo, b.distancia_objetivo), _DESEMPATE_PRESAS, orden)))
	return ordenadas.slice(0, _PRESAS_POR_CASILLA)


# Paso 7, prepararse: no puede atacar a nadie este turno, ni moviendose.
#   - Con el efecto ocultarse, sin el bono y si Hacerse junco vale (no se oculto
#     el turno anterior, no se movio, sin enemiga de pie adyacente): se oculta
#     sin moverse (11.2.2).
#   - Con el efecto surco y menos surcos que su tope: cava en la casilla valida
#     mas cercana a la enemiga de pie mas cercana -> orden de lectura (11.2.1).
#     Una oculta no cuenta como "mas cercana". Sin casilla valida, sigue al 8.
static func _paso_prepararse(turno: Turno, plantel: Plantel, orden: Dictionary) -> DecisionIA:
	var unidad: Criatura = plantel.criatura(turno.unidad_id)
	if Junco.es_junco(unidad.id, plantel):
		if unidad.bono_junco or not turno.validar(Accion.hacerse_junco()).valida:
			return null
		var oculta: DecisionIA = DecisionIA.new(DecisionIA.Paso.PREPARARSE)
		oculta.casilla = unidad.posicion
		oculta.acciones.append(Accion.hacerse_junco())
		oculta.acciones.append(Accion.terminar())
		return oculta
	if not Surcos.es_surcon(unidad.id, plantel) or turno.surcos_propios().size() >= int(unidad.especie.rasgo()["tope"]):
		return null
	var casillas: Array[Vector2i] = turno.casillas_para_cavar()
	var cercana_id: String = _enemiga_mas_cercana(unidad.posicion, unidad.bando, plantel, orden, "")
	if casillas.is_empty() or cercana_id.is_empty():
		return null
	var hasta: Vector2i = _posicion(cercana_id, plantel)
	var mejor: Vector2i = casillas[0]
	for casilla in casillas:
		if _menor([Tablero.distancia(casilla, hasta), casilla.y, casilla.x], [Tablero.distancia(mejor, hasta), mejor.y, mejor.x]):
			mejor = casilla
	var cava: DecisionIA = DecisionIA.new(DecisionIA.Paso.PREPARARSE)
	cava.objetivo_id = cercana_id
	cava.casilla = unidad.posicion
	cava.acciones.append(Accion.cavar(mejor))
	cava.acciones.append(Accion.terminar())
	return cava


# Paso 8: no alcanza a nadie. Va hacia la enemiga mas cercana que puede ser su
# objetivo (-> menos vida -> antes en la cola), a la casilla alcanzable mas
# cercana a ella (-> orden de lectura). Si ninguna la acerca, no se mueve. Una
# oculta no es objetivo (11.2.2): no va hacia ella.
static func _paso_acercarse(turno: Turno, plantel: Plantel, orden: Dictionary) -> DecisionIA:
	var unidad: Criatura = plantel.criatura(turno.unidad_id)
	var decision: DecisionIA = DecisionIA.new(DecisionIA.Paso.ACERCARSE)
	decision.casilla = unidad.posicion
	var candidatas: Array[Dictionary] = []
	for id_enemiga in _enemigas(unidad.bando, plantel, true):
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
# (incluida la suya) contra cada unidad. Turno descarta aliadas y lo que la
# consulta unica rechaza (Objetivos): nadie apunta a una caida (11.8) ni a una
# oculta (11.2.2).
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


# Las acciones de un ataque a `objetivo_id`, desde la mejor casilla entre las
# opciones. Con movimiento partido (Tasajero en Cuenta, 11.8): golpea desde la
# casilla de menos pasos -> orden de lectura, y despues se retira.
static func _atacar(paso: DecisionIA.Paso, turno: Turno, plantel: Plantel, opciones: Array[OpcionAtaque],
		objetivo_id: String, orden: Dictionary) -> DecisionIA:
	var unidad: Criatura = plantel.criatura(turno.unidad_id)
	var partido: bool = unidad.especie.movimiento_partido(unidad.modo)
	var de_la_objetivo: Array[OpcionAtaque] = []
	for opcion in opciones:
		if opcion.objetivo_id == objetivo_id:
			de_la_objetivo.append(opcion)
	var elegida: OpcionAtaque = _casilla_de_menos_pasos(de_la_objetivo) if partido \
			else _mejor_casilla(de_la_objetivo, unidad.posicion)
	var decision: DecisionIA = DecisionIA.new(paso)
	decision.casilla = elegida.casilla
	if elegida.casilla != unidad.posicion:
		decision.acciones.append(Accion.mover(elegida.casilla))
	decision.sumar_ataque(objetivo_id, elegida.danio)
	if partido:
		decision.retirada = _retirada(turno, plantel, elegida, orden)
		if decision.retirada != Criatura.SIN_POSICION:
			decision.acciones.append(Accion.mover(decision.retirada))
	decision.acciones.append(Accion.terminar())
	return decision


static func _casilla_de_menos_pasos(opciones: Array[OpcionAtaque]) -> OpcionAtaque:
	var mejor: OpcionAtaque = null
	for opcion in opciones:
		if mejor == null or _menor([opcion.pasos, opcion.casilla.y, opcion.casilla.x], [mejor.pasos, mejor.casilla.y, mejor.casilla.x]):
			mejor = opcion
	return mejor


# Sistema.md 11.8, Retirada del Tasajero en Cuenta: despues de golpear desde
# `elegida`, con los pasos que le quedan, a la casilla alcanzable mas lejana
# (Manhattan) de la enemiga de pie mas cercana -> orden de lectura. La objetivo
# no cuenta si el golpe la tumba, ni una oculta (11.2.2). Si ninguna casilla lo
# aleja, no se mueve: SIN_POSICION.
static func _retirada(turno: Turno, plantel: Plantel, elegida: OpcionAtaque, orden: Dictionary) -> Vector2i:
	var desde: Vector2i = elegida.casilla
	var sin: String = elegida.objetivo_id if elegida.puede_tumbar() else ""
	var cercana_id: String = _enemiga_mas_cercana(desde, plantel.criatura(turno.unidad_id).bando, plantel, orden, sin)
	if cercana_id.is_empty():
		return Criatura.SIN_POSICION
	var hasta: Vector2i = _posicion(cercana_id, plantel)
	var mejor: Vector2i = desde
	for casilla: Vector2i in turno.pasos_para_retirarse(desde).keys():
		if _menor([-Tablero.distancia(casilla, hasta), casilla.y, casilla.x],
				[-Tablero.distancia(mejor, hasta), mejor.y, mejor.x]):
			mejor = casilla
	if Tablero.distancia(mejor, hasta) > Tablero.distancia(desde, hasta):
		return mejor
	return Criatura.SIN_POSICION


# La enemiga de pie mas cercana a `desde` que la consulta unica acepta (sin
# ocultas), menos `sin_id`. Empate: menos vida -> antes en la cola (lectura
# declarada P-027). "" si no hay ninguna.
static func _enemiga_mas_cercana(desde: Vector2i, bando: Criatura.Bando, plantel: Plantel, orden: Dictionary,
		sin_id: String) -> String:
	var candidatas: Array[Dictionary] = []
	for id_enemiga in _enemigas(bando, plantel, true):
		if id_enemiga != sin_id:
			candidatas.append(_candidata(id_enemiga, _vida(id_enemiga, plantel),
					Tablero.distancia(desde, _posicion(id_enemiga, plantel))))
	if candidatas.is_empty():
		return ""
	return _elegir_objetivo(candidatas, _DESEMPATE_CERCANA, orden)


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


# Ids de las unidades del otro bando, en el orden del Plantel (el Maestro
# primero). objetivo: solo las que la consulta unica acepta para un ataque; si
# no, las de pie en el tablero (ocultas incluidas).
static func _enemigas(bando: Criatura.Bando, plantel: Plantel, objetivo: bool) -> Array[String]:
	var ids: Array[String] = []
	var todas: Array[String] = []
	if bando != Criatura.Bando.TRIBU:
		todas.append(Maestro.ID)
	for criatura in plantel.criaturas():
		if criatura.bando != bando:
			todas.append(criatura.id)
	for id_unidad in todas:
		if (objetivo and Objetivos.puede_ser_objetivo(id_unidad, Objetivos.Clase.HOSTIL, plantel)) \
				or (not objetivo and Objetivos.de_pie(id_unidad, plantel)):
			ids.append(id_unidad)
	return ids


static func _posicion(id_unidad: String, plantel: Plantel) -> Vector2i:
	if id_unidad == Maestro.ID:
		return plantel.maestro.posicion
	return plantel.criatura(id_unidad).posicion


static func _vida(id_unidad: String, plantel: Plantel) -> int:
	if id_unidad == Maestro.ID:
		return plantel.maestro.vida
	return plantel.criatura(id_unidad).vida
