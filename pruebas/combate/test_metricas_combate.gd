extends GdUnitTestSuite

# Arquitectura.md B.3 (T23) y D-011: MetricasCombate.calcular sobre registros
# armados a mano (listas de eventos con el formato de A.7). Sistema.md 11.9,
# "Metricas por combate". Tests (3) a (7) del criterio de terminado.

# Un escenario minimo: MetricasCombate solo lee los ids de cada bando y, desde
# T25 (metrica 8), el comportamiento de las enemigas. La especie `cardo` no
# existe en ningun dato: las activas salen del tipo de accion.
const _ESCENARIO: Dictionary = {
	"tribu": [{"id": "cardo_1", "especie": "cardo"}, {"id": "ocarra_1", "especie": "ocarra"}],
	"enemigas": [{"id": "ocarra_s1", "especie": "ocarra", "comportamiento": "salvaje"},
			{"id": "tasajero_s1", "especie": "tasajero", "comportamiento": "salvaje"},
			{"id": "atacante_1", "especie": "ocarra", "comportamiento": "atacante_nocturna"}],
}


# Arma un registro: cada evento recibe su `n` y, si no la trae, la ronda en curso.
func _registro(eventos: Array) -> Array[Dictionary]:
	var lineas: Array[Dictionary] = []
	var ronda: int = 0
	for evento in eventos:
		var linea: Dictionary = (evento as Dictionary).duplicate(true)
		if linea["tipo"] == "ronda":
			ronda += 1
		if not linea.has("ronda"):
			linea["ronda"] = ronda
		linea["n"] = lineas.size()
		lineas.append(linea)
	return lineas


func _ataque(atacante: String, objetivo: String, fuentes: Array = []) -> Dictionary:
	var modificadores: Array = []
	for fuente in fuentes:
		modificadores.append({"fuente": fuente, "tipo": "plano", "valor": 10, "detalle": "x"})
	return {"tipo": "ataque", "atacante": atacante, "objetivo": objetivo, "eslabon": null,
			"vida_antes": 50, "vida_despues": 40, "desglose": {"base": 10, "modificadores": modificadores,
			"porcentaje_total": 0, "tras_porcentajes": 10, "planos_total": 0, "minimo_aplicado": false, "total": 10}}


func _accion(unidad: String, tipo: String) -> Dictionary:
	return {"tipo": "accion", "unidad": unidad, "origen": "jugador", "accion": {"tipo": tipo}, "paso": null}


func _calcular(eventos: Array) -> Dictionary:
	return MetricasCombate.calcular(_ESCENARIO, _registro(eventos))


func _cierre(muertas: Array = []) -> Array:
	return [{"tipo": "fin", "desenlace": "victoria"},
			{"tipo": "cierre", "levantadas": [], "muertas": muertas, "pergaminos_ardidos": [], "lealtad": []}]


# (3) Metrica 1: primer ataque en la ronda 2 -> rondas de pelea = totales - 1.
func test_metrica_1_primer_ataque_en_la_ronda_2() -> void:
	var metricas: Dictionary = _calcular([{"tipo": "inicio"}, {"tipo": "ronda"}, {"tipo": "fin_ronda"},
			{"tipo": "ronda"}, _ataque("tasajero_s1", "ocarra_1"), {"tipo": "fin_ronda"},
			{"tipo": "ronda"}, {"tipo": "fin_ronda"}, {"tipo": "ronda"}] + _cierre())
	assert_dict(metricas["rondas"]).is_equal({"totales": 4, "primer_ataque": 2, "de_pelea": 3})


# (3) Un Martillazo (un `ataque` detras de su `accion` de hechizo) en la ronda 1
# la hace ronda 1.
func test_metrica_1_martillazo_en_la_ronda_1() -> void:
	var metricas: Dictionary = _calcular([{"tipo": "ronda"},
			{"tipo": "accion", "unidad": Maestro.ID, "origen": "jugador", "paso": null,
					"accion": {"tipo": "hechizo", "hechizo": "martillazo", "objetivo": "ocarra_s1"}},
			{"tipo": "mana", "unidad": Maestro.ID, "de": 8, "a": 6, "motivo": "hechizo"},
			_ataque(Maestro.ID, "ocarra_s1"), {"tipo": "fin_ronda"}, {"tipo": "ronda"}] + _cierre())
	assert_dict(metricas["rondas"]).is_equal({"totales": 2, "primer_ataque": 1, "de_pelea": 2})


# (3) El choque de la Lanzadera no es un ataque; sin ataques, null y 0.
func test_metrica_1_lanzadera_no_es_ataque() -> void:
	var metricas: Dictionary = _calcular([{"tipo": "ronda"},
			{"tipo": "lanzadera", "objetivo": "ocarra_s1", "sentido": "empujar", "desde": [1, 1], "hasta": null,
					"choque": true, "contra": "tasajero_s1", "danio": 10, "vida_antes": 50, "vida_despues": 40},
			{"tipo": "fin_ronda"}, {"tipo": "ronda"}] + _cierre())
	assert_dict(metricas["rondas"]).is_equal({"totales": 2, "primer_ataque": null, "de_pelea": 0})
	# Sin rondas (un combate que termina antes de la ronda 1).
	assert_dict(_calcular([{"tipo": "inicio"}] + _cierre())["rondas"]) \
			.is_equal({"totales": 0, "primer_ataque": null, "de_pelea": 0})


# (4) Metricas 2 a 6 con los dos bandos.
func test_metricas_2_a_6() -> void:
	var metricas: Dictionary = _calcular([{"tipo": "ronda"},
			{"tipo": "secundar", "unidad": "ocarra_1", "detras_de": "cardo_1", "lugar": 2},
			{"tipo": "secundar", "unidad": Maestro.ID, "detras_de": "cardo_1", "lugar": 3},
			# 3: una cadena de 1 eslabon no cuenta.
			{"tipo": "cadena_cortada", "objetivo": "ocarra_s1", "eslabones": 1, "participantes": ["ocarra_1"],
					"motivo": "enemiga"},
			{"tipo": "cadena_cortada", "objetivo": "ocarra_s1", "eslabones": 3,
					"participantes": ["ocarra_1", "cardo_1", Maestro.ID], "motivo": "fin_ronda"},
			{"tipo": "cadena_cortada", "objetivo": "tasajero_s1", "eslabones": 2,
					"participantes": ["ocarra_1", "cardo_1"], "motivo": "objetivo_fuera"},
			# 4
			{"tipo": "incidente", "unidad": "ocarra_1", "rivales": ["cardo_1"], "porcentaje": 5,
					"resultado": "distraida", "objetivo": null},
			{"tipo": "incidente", "unidad": "ocarra_1", "rivales": ["cardo_1"], "porcentaje": 5,
					"resultado": "golpe", "objetivo": "cardo_1"},
			{"tipo": "incidente", "unidad": "ocarra_s1", "rivales": ["tasajero_s1"], "porcentaje": 5,
					"resultado": "golpe", "objetivo": "tasajero_s1"},
			# 5: la enconada segura (sin tirada) cuenta; la no_enconada no.
			{"tipo": "chequeo_rival", "unidad": "ocarra_1", "tipo_chequeo": "encono", "rivales": ["tasajero_s1"],
					"porcentaje": 100, "tiro": false, "resultado": "enconada"},
			{"tipo": "chequeo_rival", "unidad": "ocarra_1", "tipo_chequeo": "encono", "rivales": ["tasajero_s1"],
					"porcentaje": 20, "tiro": true, "resultado": "no_enconada"},
			{"tipo": "chequeo_rival", "unidad": "ocarra_s1", "tipo_chequeo": "encono", "rivales": ["cardo_1"],
					"porcentaje": 20, "tiro": true, "resultado": "enconada"},
			# 6: la cobardia de una salvaje va a las enemigas.
			{"tipo": "chequeo_rival", "unidad": "cardo_1", "tipo_chequeo": "cobardia", "rivales": ["tasajero_s1"],
					"porcentaje": 25, "tiro": true, "resultado": "acobardada"},
			{"tipo": "chequeo_rival", "unidad": "cardo_1", "tipo_chequeo": "cobardia", "rivales": ["tasajero_s1"],
					"porcentaje": 25, "tiro": true, "resultado": "resistida", "sostenida_por": null},
			{"tipo": "chequeo_rival", "unidad": "tasajero_s1", "tipo_chequeo": "cobardia", "rivales": ["cardo_1"],
					"porcentaje": 25, "tiro": true, "resultado": "acobardada"},
	] + _cierre())
	assert_dict(metricas["secundar"]).is_equal({"usos": 2})
	assert_dict(metricas["eslabones"]).is_equal({"cadenas": 2, "suma": 5, "maximo": 3})
	assert_dict(metricas["incidentes"]).is_equal({"tribu": {"distraida": 1, "golpe": 1},
			"enemigas": {"distraida": 0, "golpe": 1}})
	assert_dict(metricas["encono"]).is_equal({"tribu": 1, "enemigas": 1})
	assert_dict(metricas["cobardia"]).is_equal({"tribu": {"acobardada": 1, "resistida": 1},
			"enemigas": {"acobardada": 1, "resistida": 0}})
	# Sin cadenas de 2 o mas: todo en 0.
	assert_dict(_calcular([{"tipo": "ronda"}] + _cierre())["eslabones"]) \
			.is_equal({"cadenas": 0, "suma": 0, "maximo": 0})


# (5) Metrica 13: solo desde la ronda del primer ataque, y sin los null.
func test_metrica_13_desde_el_primer_ataque() -> void:
	var metricas: Dictionary = _calcular([{"tipo": "ronda"},
			{"tipo": "fin_turno", "unidad": Maestro.ID, "posicion": [5, 10]},
			{"tipo": "distancia_maestro", "distancia": 8},
			{"tipo": "fin_ronda"}, {"tipo": "ronda"},
			_ataque("tasajero_s1", "cardo_1"),
			{"tipo": "fin_turno", "unidad": Maestro.ID, "posicion": [5, 9]},
			{"tipo": "distancia_maestro", "distancia": 2},
			{"tipo": "fin_ronda"}, {"tipo": "ronda"},
			{"tipo": "fin_turno", "unidad": Maestro.ID, "posicion": [5, 9]},
			{"tipo": "distancia_maestro", "distancia": 3},
			{"tipo": "fin_ronda"}, {"tipo": "ronda"},
			{"tipo": "fin_turno", "unidad": Maestro.ID, "posicion": [5, 9]},
			{"tipo": "distancia_maestro", "distancia": null}] + _cierre())
	assert_dict(metricas["distancia_maestro"]).is_equal({"turnos": 2, "suma": 5})
	# Sin ataques, ningun turno cuenta.
	var sin_ataques: Dictionary = _calcular([{"tipo": "ronda"}, {"tipo": "distancia_maestro", "distancia": 4}]
			+ _cierre())
	assert_dict(sin_ataques["distancia_maestro"]).is_equal({"turnos": 0, "suma": 0})


# (6) Metrica 14: activas por tipo de accion (cardo_1 es de una especie que no
# existe), bonos cobrados y perdidos, cambio de modo con su ronda y encierros.
func test_metrica_14_activas_y_terreno() -> void:
	var metricas: Dictionary = _calcular([{"tipo": "ronda"},
			_accion("cardo_1", "erizarse"), _accion("cardo_1", "erizarse"),
			_accion("tasajero_s1", "cavar"), {"tipo": "surco", "unidad": "tasajero_s1", "casilla": [2, 2]},
			_accion("ocarra_1", "hacerse_junco"), {"tipo": "oculto", "unidad": "ocarra_1"},
			_accion("ocarra_1", "terminar"),
			{"tipo": "destape", "unidad": "ocarra_1", "motivo": "contacto", "por": "ocarra_s1"},
			{"tipo": "destape", "unidad": "ocarra_1", "motivo": "atacar"},
			{"tipo": "fin_turno", "unidad": "tasajero_s1", "posicion": [3, 3]},
			{"tipo": "encierro", "unidad": "tasajero_s1", "casilla": [3, 3]},
			{"tipo": "fin_ronda"}, {"tipo": "ronda"},
			{"tipo": "cambio_modo", "unidad": "tasajero_s1", "de": "caza", "a": "cuenta"},
			_ataque("ocarra_1", "ocarra_s1", ["rasgo_atacante", "afinidad"]),
			_ataque("ocarra_1", "ocarra_s1", ["afinidad"]),
			{"tipo": "bono_perdido", "unidad": "ocarra_1", "atacante": "ocarra_s1"},
			{"tipo": "encierro", "unidad": Maestro.ID, "casilla": [0, 0]},
			{"tipo": "encierro", "unidad": "tasajero_s1", "casilla": [3, 3]}] + _cierre())
	var activas: Dictionary = metricas["activas"]
	assert_array(activas["usos"]).is_equal([
		{"unidad": "cardo_1", "erizarse": 2, "cavar": 0, "hacerse_junco": 0},
		{"unidad": "ocarra_1", "erizarse": 0, "cavar": 0, "hacerse_junco": 1},
		{"unidad": "tasajero_s1", "erizarse": 0, "cavar": 1, "hacerse_junco": 0},
	])
	assert_int(activas["surcos"]).is_equal(1)
	assert_int(activas["ocultos"]).is_equal(1)
	assert_int(activas["destapes_contacto"]).is_equal(1)
	assert_int(activas["bonos_cobrados"]).is_equal(1)
	assert_int(activas["bonos_perdidos"]).is_equal(1)
	assert_array(activas["cambios_modo"]).is_equal([{"unidad": "tasajero_s1", "de": "caza", "a": "cuenta", "ronda": 2}])
	assert_array(activas["encierros"]).is_equal([{"unidad": Maestro.ID, "turnos": 1},
			{"unidad": "tasajero_s1", "turnos": 2}])


# T45 (D-016, P-052; Sistema.md 11.9 v1.8): metrica 14, invocaciones por unidad
# ({unidad: cantidad}) desde los eventos `invocacion`, en el orden del
# escenario y solo las invocadas. Sin invocaciones, {}.
func test_metrica_14_invocaciones() -> void:
	var metricas: Dictionary = _calcular([{"tipo": "ronda"},
			{"tipo": "invocacion", "unidad": "ocarra_1", "casilla": [1, 1]},
			{"tipo": "invocacion", "unidad": "cardo_1", "casilla": [1, 2]},
			{"tipo": "fin_ronda"}, {"tipo": "ronda"},
			{"tipo": "invocacion", "unidad": "ocarra_1", "casilla": [1, 1]}] + _cierre())
	var invocaciones: Dictionary = metricas["activas"]["invocaciones"]
	assert_dict(invocaciones).is_equal({"cardo_1": 1, "ocarra_1": 2})
	assert_array(invocaciones.keys()).is_equal(["cardo_1", "ocarra_1"])
	assert_dict(_calcular([{"tipo": "ronda"}] + _cierre())["activas"]["invocaciones"]).is_empty()


# (7) Metricas 9 y 11 en una victoria (con una caida que se levanta) y en una
# derrota con muertas (el Maestro cae: P-043); 12 (T29), y 7 vacia (T24).
# T27: la 10 deja de estar en null; sin eventos guardado_caida, lista vacia.
# T25: la 8 cuenta a la Ocarra salvaje que sale del tablero sin huida ni sellado
# delante (cero); en la derrota, vacia.
func test_metricas_9_y_11() -> void:
	var victoria: Dictionary = _calcular([{"tipo": "ronda"}, {"tipo": "fin_ronda"}, {"tipo": "ronda"},
			{"tipo": "estado", "unidad": "ocarra_1", "de": "suelta", "a": "caida"},
			{"tipo": "estado", "unidad": "ocarra_s1", "de": "suelta", "a": "caida"},
			{"tipo": "estado", "unidad": "ocarra_s1", "de": "caida", "a": "fuera"},
			{"tipo": "fin", "desenlace": "victoria"},
			{"tipo": "cierre", "levantadas": ["ocarra_1"], "muertas": [], "pergaminos_ardidos": [], "lealtad": []}])
	assert_array(victoria["caidas"]).is_equal([{"unidad": "ocarra_1", "ronda": 2}, {"unidad": "ocarra_s1", "ronda": 2}])
	assert_array(victoria["muertes"]).is_empty()

	var derrota: Dictionary = _calcular([{"tipo": "ronda"},
			{"tipo": "estado", "unidad": "cardo_1", "de": "suelta", "a": "caida"},
			{"tipo": "fin_ronda"}, {"tipo": "ronda"},
			{"tipo": "estado", "unidad": Maestro.ID, "de": "en_pie", "a": "caido"},
			{"tipo": "fin", "desenlace": "derrota_por_caida"},
			{"tipo": "rescate", "rescatista": null, "permadeath": true},
			{"tipo": "cierre", "levantadas": [], "muertas": ["cardo_1", "ocarra_1"], "pergaminos_ardidos": [],
					"lealtad": []}])
	assert_array(derrota["caidas"]).is_equal([{"unidad": "cardo_1", "ronda": 1}, {"unidad": Maestro.ID, "ronda": 2}])
	assert_array(derrota["muertes"]).is_equal([{"unidad": "cardo_1", "causa": "derrota_por_caida"},
			{"unidad": "ocarra_1", "causa": "derrota_por_caida"}])
	# T24 (D-011): la metrica 7 deja de estar en null; sin eventos sellado, lista vacia.
	assert_array(victoria["capturas_perdidas"]).is_equal([{"unidad": "ocarra_s1", "motivo": "cero", "ronda": 2}])
	assert_array(derrota["capturas_perdidas"]).is_empty()
	for metricas in [victoria, derrota]:
		assert_array(metricas["sellados"]).is_empty()
		assert_array(metricas["caidas_guardadas"]).is_empty()
	# Reescrito en T29 (A.7 y D-011, metrica 12): la derrota trae el evento rescate
	# (sin rescatista); en la victoria sigue en null.
	assert_object(victoria["rescate"]).is_null()
	assert_dict(derrota["rescate"]).is_equal({"rescatista": null})


# T29 (Sistema.md 11.9, metrica 12; A.7): desde el evento rescate. Con rescatista,
# su id; sin evento (el Maestro no cayo), null.
func test_metrica_12_rescate() -> void:
	var con_rescate: Dictionary = _calcular([{"tipo": "ronda"},
			{"tipo": "estado", "unidad": Maestro.ID, "de": "en_pie", "a": "caido"},
			{"tipo": "fin", "desenlace": "derrota_por_caida"},
			{"tipo": "rescate", "rescatista": "cardo_1", "permadeath": false},
			{"tipo": "cierre", "levantadas": [], "muertas": [], "pergaminos_ardidos": [], "lealtad": []}])
	assert_dict(con_rescate["rescate"]).is_equal({"rescatista": "cardo_1"})
	var huida: Dictionary = _calcular([{"tipo": "ronda"}, {"tipo": "fin_ronda"},
			{"tipo": "fin", "desenlace": "huida"},
			{"tipo": "cierre", "levantadas": [], "muertas": [], "pergaminos_ardidos": [], "lealtad": []}])
	assert_object(huida["rescate"]).is_null()


# T27 (Sistema.md 11.9, metrica 10; A.7): cada guardado_caida en orden, con su
# ronda. Una caida guardada cuenta; otra que no se guardo (y muere en el cierre),
# no.
func test_metrica_10_caidas_guardadas() -> void:
	var metricas: Dictionary = _calcular([{"tipo": "ronda"},
			{"tipo": "estado", "unidad": "cardo_1", "de": "suelta", "a": "caida"},
			{"tipo": "estado", "unidad": "ocarra_1", "de": "suelta", "a": "caida"},
			{"tipo": "fin_ronda"}, {"tipo": "ronda"},
			{"tipo": "accion", "unidad": Maestro.ID, "origen": "jugador",
					"accion": {"tipo": "guardar_caida", "objetivo": "cardo_1"}, "paso": null},
			{"tipo": "mana", "unidad": Maestro.ID, "de": 8, "a": 6, "motivo": "guardar_caida"},
			{"tipo": "estado", "unidad": "cardo_1", "de": "caida", "a": "guardada"},
			{"tipo": "guardado_caida", "unidad": "cardo_1", "vida": 10},
			{"tipo": "estado", "unidad": Maestro.ID, "de": "en_pie", "a": "caido"},
			{"tipo": "fin", "desenlace": "derrota_por_caida"},
			{"tipo": "cierre", "levantadas": [], "muertas": ["ocarra_1"], "pergaminos_ardidos": [], "lealtad": []}])
	assert_array(metricas["caidas_guardadas"]).is_equal([{"unidad": "cardo_1", "ronda": 2}])
	assert_array(metricas["muertes"]).is_equal([{"unidad": "ocarra_1", "causa": "derrota_por_caida"}])


# T25 (Sistema.md 11.9, metrica 8; A.7): una salvaje que huye (huida con huye y
# despues su estado fuera), una que llega a 0 (estado fuera sin huida delante) y
# una sellada (sellado logrado delante) que no cuenta. Una huida que no sale no
# marca a nadie. Las de la tribu y la atacante nocturna no son capturas.
func test_metrica_8_capturas_perdidas() -> void:
	var metricas: Dictionary = _calcular([{"tipo": "ronda"},
			{"tipo": "huida", "unidad": "tasajero_s1", "porcentaje": 25, "tiro": 90, "resultado": "se_queda"},
			_ataque("cardo_1", "tasajero_s1"),
			{"tipo": "estado", "unidad": "tasajero_s1", "de": "suelta", "a": "fuera"},
			{"tipo": "huida", "unidad": "ocarra_s1", "porcentaje": 50, "tiro": 3, "resultado": "huye"},
			{"tipo": "estado", "unidad": "ocarra_s1", "de": "suelta", "a": "fuera"},
			{"tipo": "fin_ronda"}, {"tipo": "ronda"},
			{"tipo": "estado", "unidad": "atacante_1", "de": "suelta", "a": "fuera"},
			{"tipo": "estado", "unidad": "cardo_1", "de": "suelta", "a": "fuera"},
			{"tipo": "fin", "desenlace": "victoria"}])
	assert_array(metricas["capturas_perdidas"]).is_equal([
		{"unidad": "tasajero_s1", "motivo": "cero", "ronda": 1},
		{"unidad": "ocarra_s1", "motivo": "huida", "ronda": 1},
	])
	var con_sellado: Dictionary = _calcular([{"tipo": "ronda"},
			{"tipo": "sellado", "objetivo": "ocarra_s1", "porcentaje": 50, "tiro": 10, "resultado": "logrado",
					"pergamino": "pergamino_2"},
			{"tipo": "estado", "unidad": "ocarra_s1", "de": "suelta", "a": "fuera"},
			_ataque("cardo_1", "tasajero_s1"),
			{"tipo": "estado", "unidad": "tasajero_s1", "de": "suelta", "a": "fuera"},
			{"tipo": "fin", "desenlace": "victoria"}])
	assert_array(con_sellado["capturas_perdidas"]).is_equal([{"unidad": "tasajero_s1", "motivo": "cero", "ronda": 1}])
	# Un sellado fallido no la salva: si despues llega a 0, es una captura perdida.
	var fallido: Dictionary = _calcular([{"tipo": "ronda"},
			{"tipo": "sellado", "objetivo": "ocarra_s1", "porcentaje": 50, "tiro": 90, "resultado": "fallido",
					"pergamino": null},
			_ataque("cardo_1", "ocarra_s1"),
			{"tipo": "estado", "unidad": "ocarra_s1", "de": "suelta", "a": "fuera"}])
	assert_array(fallido["capturas_perdidas"]).is_equal([{"unidad": "ocarra_s1", "motivo": "cero", "ronda": 1}])
