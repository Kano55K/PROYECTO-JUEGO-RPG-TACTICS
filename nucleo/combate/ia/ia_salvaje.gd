# Sistema.md 11.8 v1.3: la IA de las salvajes; la atacante nocturna usa la misma
# (9.2, punto 3). Para el turno de la unidad devuelve las acciones que va a
# jugar, sin aplicar nada y sin azar. Recorre la lista de 11.8 en orden, un paso
# por funcion; el primero que decide, gana. El Tasajero la recorre en su unico
# turno de la ronda (Sistema.md 11.2.3), con el modo y el tablero de ese momento.
# Los rasgos se reconocen por su efecto o por los numeros del modo, nunca por id.
# D-005 (T20): la IA nunca recalcula una restriccion del turno (la obligacion de
# la enconada, la acobardada, la accion perdida). Lee el estado del Turno
# (enconada) y toma sus casillas y objetivos de sus consultas: pasos_para_mover,
# casillas_para_mover, previsualizar_ataque, puede_terminar, casillas_para_cavar
# y casillas_para_retirarse.
class_name IASalvaje
extends RefCounted

# Criterios de desempate para elegir objetivo (11.8 y S-19, P-020; PUEDE_TUMBAR, 10.5).
enum Criterio { PUEDE_TUMBAR, MENOS_VIDA, MAS_CERCANA, ANTES_EN_COLA }
# Sistema.md 10.5, salvaje enconada con varias rivales: puede tumbar -> menos
# vida -> mas cercana -> antes en la cola.
const _DESEMPATE_ENCONO: Array[Criterio] = [Criterio.PUEDE_TUMBAR, Criterio.MENOS_VIDA, Criterio.MAS_CERCANA,
		Criterio.ANTES_EN_COLA]
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
	# Paso 1: la huida ya la tiro el inicio del turno (T25, Huida). Una salvaje que
	# huyo no llega aca: su turno termino.
	var decision: DecisionIA = _paso_encono(turno, plantel, orden)
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


# Paso 3 (Sistema.md 10.5 y 11.8, T20): la enconada va por su rival y no corren
# los pasos 4 a 8. Las opciones ya vienen del Turno: en el primer ataque solo
# acepta a las rivales del chequeo, y solo casillas desde donde golpea a alguna
# (S-35). Elige la rival con los desempates de 10.5 y la ataca desde la casilla
# de la tabla de 11.8 (si puede tumbarla, entre las que la tumban, como el
# remate); en Cuenta, la de menos pasos y la retirada. Si no tiene opciones (no
# la alcanza), se acerca (S-43). En Caza, S-42.
# La acobardada y la distraida no pasan por aca: los pasos 4 a 8 ya toman sus
# casillas y objetivos del Turno.
static func _paso_encono(turno: Turno, plantel: Plantel, orden: Dictionary) -> DecisionIA:
	if not turno.enconada:
		return null
	var opciones: Array[OpcionAtaque] = _opciones(turno, plantel)
	if opciones.is_empty():
		return _encono_acercarse(turno, plantel)
	var rival_id: String = _elegir_objetivo(_candidatas(opciones), _DESEMPATE_ENCONO, orden)
	var de_la_rival: Array[OpcionAtaque] = []
	var la_tumban: Array[OpcionAtaque] = []
	for opcion in opciones:
		if opcion.objetivo_id == rival_id:
			de_la_rival.append(opcion)
			if opcion.puede_tumbar():
				la_tumban.append(opcion)
	if _en_caza(turno, plantel):
		return _encono_caza(turno, plantel, de_la_rival, orden)
	return _atacar(DecisionIA.Paso.ENCONO, turno, plantel, la_tumban if not la_tumban.is_empty() else de_la_rival,
			rival_id, orden)


# Lectura declarada S-43: la enconada que no alcanza a su rival va a una casilla
# que el Turno le permite (las de menor distancia a la rival mas cercana, S-35)
# -> orden de lectura, como Acercarse. Si el Turno la deja terminar sin moverse
# (ninguna casilla la acerca), no se mueve.
static func _encono_acercarse(turno: Turno, plantel: Plantel) -> DecisionIA:
	var decision: DecisionIA = DecisionIA.new(DecisionIA.Paso.ENCONO)
	decision.casilla = plantel.criatura(turno.unidad_id).posicion
	if not turno.puede_terminar():
		var casillas: Array[Vector2i] = turno.casillas_para_mover()
		if not casillas.is_empty():
			var mejor: Vector2i = casillas[0]
			for casilla in casillas:
				if _menor([casilla.y, casilla.x], [mejor.y, mejor.x]):
					mejor = casilla
			decision.casilla = mejor
			decision.acciones.append(Accion.mover(mejor))
	decision.acciones.append(Accion.terminar())
	return decision


# Sistema.md 10.5 (Tasajero enconado en Caza) y lectura declarada S-42: la rival
# ya esta elegida; la casilla, entre las que la golpean, con la clave del 6b. El
# primer ataque va a la rival; el segundo, a la otra presa de esa casilla de menos
# vida -> antes en la cola (P-026), que el Turno acepta despues del primero
# (previsualizar_ataque con tras_primer_ataque); sin otra presa, a la rival, y si
# el primero la tumba, se pierde. El segundo golpe a la rival tambien sale de
# previsualizar_ataque con tras_primer_ataque: lleva el punto de Encono del
# primero (T20, sesion 2), y "tumba" de la clave suma los dos.
static func _encono_caza(turno: Turno, plantel: Plantel, de_la_rival: Array[OpcionAtaque],
		orden: Dictionary) -> DecisionIA:
	var mejor_golpes: Array[OpcionAtaque] = []
	var mejor_clave: Array = []
	for primero in de_la_rival:
		var otras: Array[OpcionAtaque] = []
		for id_objetivo in _ids(plantel):
			if id_objetivo == primero.objetivo_id:
				continue
			var otra: OpcionAtaque = _opcion(turno, plantel, primero.casilla, primero.pasos, id_objetivo, true)
			if otra != null:
				otras.append(otra)
		var presas: Array[OpcionAtaque] = [primero]
		var golpes: Array[OpcionAtaque] = [primero]
		if not otras.is_empty():
			var segunda: OpcionAtaque = _presas_elegidas(otras, orden)[0]
			presas.append(segunda)
			golpes.append(segunda)
		elif not primero.puede_tumbar():
			var otra_vez: OpcionAtaque = _opcion(turno, plantel, primero.casilla, primero.pasos, primero.objetivo_id, true)
			if otra_vez != null:
				golpes.append(otra_vez)
		var clave: Array = _clave_caza(presas, golpes, primero.casilla)
		if mejor_clave.is_empty() or _menor(clave, mejor_clave):
			mejor_clave = clave
			mejor_golpes = golpes
	return _decision_caza(DecisionIA.Paso.ENCONO, plantel.criatura(turno.unidad_id).posicion, mejor_golpes)


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
		# Los dos golpes a la misma presa dan lo mismo: entre uno y otro no
		# cambia nada de lo que entra en el danio, solo la vida.
		if presas.size() == 1 and not presas[0].puede_tumbar():
			golpes.append(presas[0])
		var clave: Array = _clave_caza(presas, golpes, casilla)
		if mejor_clave.is_empty() or _menor(clave, mejor_clave):
			mejor_clave = clave
			mejor_golpes = golpes
	if mejor_golpes.is_empty():
		return null
	return _decision_caza(DecisionIA.Paso.CAZA, plantel.criatura(turno.unidad_id).posicion, mejor_golpes)


# Tabla de 11.8, Casilla del Tasajero en Caza (paso 6b): junto a 2 presas > 1 ->
# la que tumba a alguien -> menos vida sumada -> menos pasos -> orden de lectura.
# Con una sola presa, "tumba" suma el danio de sus golpes (golpes: los planeados,
# en orden). La comparten el 6b y la Caza enconada (S-42).
static func _clave_caza(presas: Array[OpcionAtaque], golpes: Array[OpcionAtaque], casilla: Vector2i) -> Array:
	var tumba: bool = false
	var vida_sumada: int = 0
	for presa in presas:
		tumba = tumba or presa.puede_tumbar()
		vida_sumada += presa.vida_objetivo
	if presas.size() == 1:
		var suma: int = 0
		for golpe in golpes:
			suma += golpe.danio
		tumba = suma >= presas[0].vida_objetivo
	return [-presas.size(), -int(tumba), vida_sumada, presas[0].pasos, casilla.y, casilla.x]


# Moverse a la casilla de los golpes (si no es la suya), los golpes en orden y terminar.
static func _decision_caza(paso: DecisionIA.Paso, origen: Vector2i, golpes: Array[OpcionAtaque]) -> DecisionIA:
	var decision: DecisionIA = DecisionIA.new(paso)
	decision.casilla = golpes[0].casilla
	if decision.casilla != origen:
		decision.acciones.append(Accion.mover(decision.casilla))
	for golpe in golpes:
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
	var opciones: Array[OpcionAtaque] = []
	var pasos: Dictionary = turno.pasos_para_mover()
	for casilla: Vector2i in pasos.keys():
		for id_objetivo in _ids(plantel):
			var opcion: OpcionAtaque = _opcion(turno, plantel, casilla, pasos[casilla], id_objetivo, false)
			if opcion != null:
				opciones.append(opcion)
	return opciones


# El ataque desde `casilla` a `id_objetivo` si el Turno lo acepta (previsualizar_ataque;
# tras_primer_ataque, el segundo de Caza), o null.
static func _opcion(turno: Turno, plantel: Plantel, casilla: Vector2i, pasos: int, id_objetivo: String,
		tras_primer_ataque: bool) -> OpcionAtaque:
	var resultado: ResultadoAccion = turno.previsualizar_ataque(casilla, id_objetivo, tras_primer_ataque)
	if not resultado.valida:
		return null
	var posicion: Vector2i = _posicion(id_objetivo, plantel)
	return OpcionAtaque.new(casilla, pasos, id_objetivo, resultado.danio, _vida(id_objetivo, plantel),
			Tablero.distancia(plantel.criatura(turno.unidad_id).posicion, posicion), Tablero.distancia(casilla, posicion))


# Todas las unidades, en el orden del Plantel: el Maestro y despues las criaturas.
static func _ids(plantel: Plantel) -> Array[String]:
	var ids: Array[String] = [Maestro.ID]
	for criatura in plantel.criaturas():
		ids.append(criatura.id)
	return ids


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
# aleja, no se mueve: SIN_POSICION. Las casillas son las que el Turno permite
# despues del golpe (casillas_para_retirarse, D-005: el Encono y la cobardia).
static func _retirada(turno: Turno, plantel: Plantel, elegida: OpcionAtaque, orden: Dictionary) -> Vector2i:
	var desde: Vector2i = elegida.casilla
	var sin: String = elegida.objetivo_id if elegida.puede_tumbar() else ""
	var cercana_id: String = _enemiga_mas_cercana(desde, plantel.criatura(turno.unidad_id).bando, plantel, orden, sin)
	if cercana_id.is_empty():
		return Criatura.SIN_POSICION
	var hasta: Vector2i = _posicion(cercana_id, plantel)
	var mejor: Vector2i = desde
	for casilla: Vector2i in turno.casillas_para_retirarse(desde, elegida.objetivo_id).keys():
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


# Una candidata por objetivo: los datos de la objetivo son los mismos en todas sus
# opciones. tumba: si alguna de sus opciones la tumba (turno completo, S-8).
static func _candidatas(opciones: Array[OpcionAtaque]) -> Array[Dictionary]:
	var por_id: Dictionary = {}
	var candidatas: Array[Dictionary] = []
	for opcion in opciones:
		if not por_id.has(opcion.objetivo_id):
			var candidata: Dictionary = _candidata(opcion.objetivo_id, opcion.vida_objetivo, opcion.distancia_objetivo)
			por_id[opcion.objetivo_id] = candidata
			candidatas.append(candidata)
		if opcion.puede_tumbar():
			(por_id[opcion.objetivo_id] as Dictionary)["tumba"] = true
	return candidatas


static func _candidata(id_objetivo: String, vida: int, distancia: int) -> Dictionary:
	return {"id": id_objetivo, "vida": vida, "distancia": distancia, "tumba": false}


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
			Criterio.PUEDE_TUMBAR:
				clave.append(-int(candidata["tumba"]))
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
