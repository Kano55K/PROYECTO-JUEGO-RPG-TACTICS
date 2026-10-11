extends GdUnitTestSuite

# Arquitectura.md B.3 (T22, sesion 2), criterios 1 y 4: LecturaCombate arma los
# botones de los hechizos desde los datos y las consultas del Turno, y los
# sucesos de `lanzadera` (segun `contra`, P-042) y `remiendo`. Fixtures (A.6):
# escenario_hechizos_combate.json (la Rodauva juega y termina; despues, el
# Maestro [3,6] con el Surcon salvaje [3,3] a 3) y es_rasgos.json mas copias
# textuales de datos/textos/es.json. Sistema.md 1.6 y 2.3.
const _ESCENARIO: String = "res://pruebas/fixtures/combate/escenario_hechizos_combate.json"
const _TEXTOS: String = "res://pruebas/fixtures/pantalla/es_rasgos.json"
const _HECHIZOS_OTRO_ID: String = "res://pruebas/fixtures/pantalla/hechizos.json"
const _MAESTRO_OTRO_ID: String = "res://pruebas/fixtures/pantalla/maestro_hechizos.json"
# Copias textuales de datos/textos/es.json v1.3.
const _TEXTOS_HECHIZOS: Dictionary = {
	"hechizo.martillazo.nombre": "Martillazo",
	"hechizo.martillazo.tooltip": "Lo que los Nueve modelaron también se abolla.",
	"hechizo.lanzadera.nombre": "Lanzadera",
	"hechizo.lanzadera.tooltip": "Va y vuelve, como la lanzadera en el telar.",
	"hechizo.remiendo.nombre": "Remiendo",
	"hechizo.remiendo.tooltip": "Un remiendo cierra lo abierto. No levanta lo caído.",
	"lanzadera.choque": "{unidad} sale despedid{unidad_o} y se lleva por delante {a_otra}.",
	"lanzadera.choque.contra_maestro": "{unidad} sale despedid{unidad_o} y se te viene encima.",
	"accion.mover": "Mover",
	"panel.mana": "Maná",
}

var _combate: Combate


# El combate en el turno del Maestro (la Rodauva termina sin hacer nada).
# otro_id: con el fixture de hechizos de otro id (pedrada).
func _lectura(otro_id: bool = false) -> LecturaCombate:
	var lectura: Dictionary = DatosFixture.cargar()
	assert_array(lectura["errores"]).is_empty()
	var datos: Dictionary = lectura["datos"]
	if otro_id:
		datos["hechizos.json"] = LectorFixture.leer(_HECHIZOS_OTRO_ID, "hechizos")["datos"]
		datos["maestro.json"] = LectorFixture.leer(_MAESTRO_OTRO_ID, "maestro")["datos"]
	var textos: Dictionary = LectorFixture.leer(_TEXTOS, "textos")["datos"]
	textos.merge(_TEXTOS_HECHIZOS, true)
	var escenario: Dictionary = LectorFixture.leer(_ESCENARIO, "escenario")["datos"]
	var contexto: ContextoCombate = ContextoCombate.armar(escenario, datos)
	assert_bool(contexto.valido).is_true()
	_combate = Combate.empezar(contexto)
	assert_str(_combate.turno_actual().unidad_id).is_equal("rodauva_1")
	assert_bool(_combate.aplicar(Accion.terminar()).valida).is_true()
	assert_str(_combate.turno_actual().unidad_id).is_equal(Maestro.ID)
	return LecturaCombate.new(_combate, ArmadorTextos.desde_datos(textos, contexto.azar_textos),
			EstadosUnidad.desde_datos(datos["tablas/hambre.json"], datos["tablas/lealtad.json"]))


func _boton(lectura: LecturaCombate, hechizo_id: String) -> Dictionary:
	for boton in lectura.botones_hechizos():
		if boton["id"] == hechizo_id:
			return boton
	return {}


# Criterio 1: un boton por hechizo del Maestro, en su orden, con el nombre y el
# costo; habilitado segun Turno.motivo_hechizo. Fuera del turno del Maestro, ninguno.
func test_botones_desde_los_datos() -> void:
	var lectura: LecturaCombate = _lectura()
	var ids: Array = lectura.botones_hechizos().map(func(boton: Dictionary) -> String: return boton["id"])
	assert_array(ids).is_equal(["martillazo", "lanzadera", "remiendo"])
	var martillazo: Dictionary = _boton(lectura, "martillazo")
	assert_str(martillazo["texto"]).is_equal("Martillazo (2 Maná)")
	assert_str(martillazo["tooltip"]).is_equal("Lo que los Nueve modelaron también se abolla.")
	assert_bool(martillazo["habilitado"]).is_true()
	assert_str(_boton(lectura, "remiendo")["texto"]).is_equal("Remiendo (4 Maná)")
	assert_bool(_combate.aplicar(Accion.terminar()).valida).is_true()
	assert_str(_combate.turno_actual().unidad_id).is_not_equal(Maestro.ID)
	assert_array(lectura.botones_hechizos()).is_empty()


# Criterio 1: con el fixture de otro id, su boton sale de los datos, con su
# costo (el nombre falta en los textos: [FALTA]).
func test_boton_de_otro_id() -> void:
	var lectura: LecturaCombate = _lectura(true)
	var ids: Array = lectura.botones_hechizos().map(func(boton: Dictionary) -> String: return boton["id"])
	assert_array(ids).is_equal(["pedrada", "lanzadera", "remiendo"])
	var pedrada: Dictionary = _boton(lectura, "pedrada")
	assert_str(pedrada["texto"]).is_equal("[FALTA: hechizo.pedrada.nombre] (3 Maná)")
	assert_bool(pedrada["habilitado"]).is_true()


# Criterio 1: sin mana, con la accion usada y sin objetivos, deshabilitado y el
# tooltip suma el motivo (claves propuestas: [FALTA]).
func test_botones_deshabilitados_con_su_motivo() -> void:
	var lectura: LecturaCombate = _lectura()
	_combate.contexto().plantel.maestro.mana = 3
	var remiendo: Dictionary = _boton(lectura, "remiendo")
	assert_bool(remiendo["habilitado"]).is_false()
	assert_str(remiendo["tooltip"]).is_equal("Un remiendo cierra lo abierto. No levanta lo caído.\n"
			+ "[FALTA: aviso.hechizo.mana_insuficiente]")
	assert_bool(_boton(lectura, "martillazo")["habilitado"]).is_true()

	# Sin objetivos: la Lanzadera no llega al Surcon (a 3) y la Rodauva [2,6] se
	# aleja a [0,0].
	_combate.contexto().plantel.criatura("rodauva_1").posicion = Vector2i(0, 0)
	var lanzadera: Dictionary = _boton(lectura, "lanzadera")
	assert_bool(lanzadera["habilitado"]).is_false()
	assert_str(lanzadera["tooltip"]).ends_with("\n[FALTA: aviso.hechizo.sin_objetivos]")

	assert_bool(_combate.aplicar(Accion.hechizo("martillazo", "surcon_s1")).valida).is_true()
	for boton in lectura.botones_hechizos():
		assert_bool(boton["habilitado"]).is_false()
		assert_str(boton["tooltip"]).ends_with("\n[FALTA: aviso.hechizo.accion_usada]")


# Criterio 4: el nombre del hechizo en la linea de la accion, y una linea por
# cada caso de `lanzadera` y por el `remiendo`, con su clave.
func test_sucesos_de_hechizos() -> void:
	var lectura: LecturaCombate = _lectura()
	assert_array(lectura.suceso({"tipo": "accion", "unidad": Maestro.ID,
			"accion": {"tipo": "hechizo", "hechizo": "lanzadera", "objetivo": "rodauva_1", "sentido": "empujar"}})) \
			.is_equal(["Maestro · Lanzadera"])
	var base: Dictionary = {"tipo": "lanzadera", "objetivo": "surcon_s1", "sentido": "empujar", "desde": [3, 3]}
	var sin_choque: Dictionary = base.merged({"hasta": [3, 2], "choque": false, "danio": 0, "vida_antes": 24,
			"vida_despues": 24})
	assert_array(lectura.suceso(sin_choque)).is_equal(["Surcón · Mover"])
	var choque: Dictionary = base.merged({"hasta": null, "choque": true, "danio": 1, "vida_antes": 24,
			"vida_despues": 23})
	assert_array(lectura.suceso(choque.merged({"contra": "rodauva_1"}))).is_equal(
			["El Surcón sale despedido y se lleva por delante a la Rodauva. (−1 · Vida: 24 → 23)"])
	assert_array(lectura.suceso(choque.merged({"contra": Maestro.ID}))).is_equal(
			["El Surcón sale despedido y se te viene encima. (−1 · Vida: 24 → 23)"])
	assert_array(lectura.suceso(choque.merged({"contra": null}))).is_equal(
			["[FALTA: lanzadera.choque.obstaculo] (−1 · Vida: 24 → 23)"])
	assert_array(lectura.suceso({"tipo": "remiendo", "objetivo": Maestro.ID, "de": 6, "a": 10})).is_equal(
			["Maestro · Vida: 6 → 10"])


# Criterio 4: los sucesos que da el combate al aplicar los hechizos de verdad.
func test_sucesos_del_combate() -> void:
	var lectura: LecturaCombate = _lectura()
	var desde: int = _combate.registro().lineas().size()
	assert_bool(_combate.aplicar(Accion.hechizo("lanzadera", "rodauva_1", "empujar")).valida).is_true()
	assert_array(lectura.sucesos(desde)).contains_exactly(["Maestro · Lanzadera", "Rodauva · Mover"])
