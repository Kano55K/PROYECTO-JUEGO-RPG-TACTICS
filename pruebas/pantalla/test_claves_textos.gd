extends GdUnitTestSuite

# Arquitectura.md A.2.1 y B.2 (T13): la lista de claves que usa la pantalla,
# armada con constantes mas las claves por especie, rasgo, estado de hambre y
# evento de lealtad de los datos (fixtures, A.6).
const _PATRON_CLAVE: String = "^[a-z0-9_]+(\\.[a-z0-9_]+)*$"


func test_claves_usadas() -> void:
	var lectura: Dictionary = DatosFixture.cargar()
	assert_array(lectura["errores"]).is_empty()
	var claves: Array[String] = ClavesTextos.usadas(lectura["datos"])
	assert_array(claves).contains(ClavesTextos.FIJAS)
	assert_array(claves).contains(["lealtad.estado.desleal", "lealtad.estado.dudosa",
			"lealtad.estado.neutral", "lealtad.estado.leal"])
	for especie in ["ocarra", "rodauva", "surcon", "tasajero", "zancajunco"]:
		assert_array(claves).contains(["especie.%s.nombre" % especie])
	# Rasgos de la v1.3 (Sistema.md 11.2, 11.2.1): el surco reemplaza a Lomo de tierra.
	for rasgo in ["erizarse", "alabarda", "surco", "hacerse_junco", "caza_y_cuenta"]:
		assert_array(claves).contains(["rasgo.%s.nombre" % rasgo, "rasgo.%s.tooltip" % rasgo])
	assert_array(claves).not_contains(["rasgo.lomo_de_tierra.nombre"])
	for estado in ["suelta", "guardada", "caida", "fuera", "muerta"]:
		assert_array(claves).contains(["estado.%s" % estado])
	# Sesion 2: un motivo por evento de lealtad.json (P-019), sin la _nota.
	assert_array(claves).contains(["lealtad.motivo.victoria", "lealtad.motivo.muerte_en_el_grupo",
			"resultado.desenlace.victoria", "resultado.desenlace.derrota_por_caida", "desglose.fuente.combo"])
	assert_array(claves).not_contains(["lealtad.motivo._nota"])
	for estado in ["saciado", "normal", "hambriento", "famelico"]:
		assert_array(claves).contains(["hambre.estado.%s" % estado])

	var patron: RegEx = RegEx.create_from_string(_PATRON_CLAVE)
	var vistas: Dictionary = {}
	for clave in claves:
		assert_object(patron.search(clave)).override_failure_message(clave).is_not_null()
		assert_bool(vistas.has(clave)).override_failure_message("repetida: " + clave).is_false()
		vistas[clave] = true


# T40 (tests 8 y 9): las claves de los rasgos de la v1.3, los modos y sus
# cambios desde los datos, y las variantes de concordancia de A.2.1 que estan
# en el archivo de textos (las que faltan son opcionales: no se piden). La
# clave de paso desglose.fuente.modo ya no se pide.
func test_claves_de_rasgos_y_variantes() -> void:
	var lectura: Dictionary = DatosFixture.cargar()
	assert_array(lectura["errores"]).is_empty()
	var datos: Dictionary = lectura["datos"]
	var textos: Dictionary = LectorFixture.leer("res://pruebas/fixtures/pantalla/es_rasgos.json", "textos")
	assert_array(textos["errores"]).is_empty()
	datos["textos/es.json"] = textos["datos"]
	var claves: Array[String] = ClavesTextos.usadas(datos)

	assert_array(claves).contains(["accion.cavar", "marca.oculto", "marca.bono", "suceso.surco.cavar",
			"suceso.surco.cerrar", "suceso.oculto", "suceso.destape.mover", "suceso.destape.atacar",
			"suceso.destape.contacto", "suceso.pierde_bono", "aviso.cuenta.umbral", "aviso.destapar"])
	assert_array(claves).contains(["iniciativa.caza", "iniciativa.cuenta", "suceso.cuenta.cambio"])
	assert_array(claves).not_contains(["suceso.caza.cambio", "desglose.fuente.modo"])
	# Variantes que estan en el archivo.
	assert_array(claves).contains(["hambre.estado.saciado.surcon", "hambre.estado.saciado.maestro",
			"estado.caida.surcon", "marca.caida.surcon"])
	# Variantes que no estan: no se piden.
	assert_array(claves).not_contains(["hambre.estado.saciado.rodauva", "lealtad.estado.dudosa.surcon",
			"marca.caida.rodauva"])
	var vistas: Dictionary = {}
	for clave in claves:
		assert_bool(vistas.has(clave)).override_failure_message("repetida: " + clave).is_false()
		vistas[clave] = true


# T19, sesion 2 (Mundo.md 9.2 v1.2 y 5): las claves del Encono y la cobardia. Las
# reacciones por par (encono.<especie>.<rival>), por especie (cobardia.<especie>)
# y cobardia.resiste.<especie> se piden solo si estan en el archivo.
# Reescrito en T44 por Mundo.md 9.2 v1.3 y Arquitectura.md A.7 (sostenida_por):
# cobardia.resiste.maestro y cobardia.resiste.afin pasan a ser claves fijas (antes
# se afirmaba que no se pedian); siguen sin ser variantes de cobardia.resiste.
func test_claves_del_encono_y_la_cobardia() -> void:
	var lectura: Dictionary = DatosFixture.cargar()
	assert_array(lectura["errores"]).is_empty()
	var datos: Dictionary = lectura["datos"]
	datos["textos/es.json"] = {"encono.ocarra.zancajunco": "x", "encono.tasajero.rodauva": "x",
			"cobardia.rodauva": "x", "cobardia.resiste.rodauva": "x", "cobardia.resiste.maestro": "x",
			"marca.enconada.tasajero": "x"}
	var claves: Array[String] = ClavesTextos.usadas(datos)
	assert_array(claves).contains(["encono.tooltip", "cobardia.tooltip", "encono.inicio", "encono.sube",
			"cobardia.inicio", "cobardia.resiste", "marca.enconada", "marca.acobardada", "panel.encono",
			"aviso.terminar.debe_atacar_rival", "aviso.terminar.debe_acercarse", "cobardia.resiste.maestro",
			"cobardia.resiste.afin"])
	assert_array(claves).contains(["encono.ocarra.zancajunco", "encono.tasajero.rodauva", "cobardia.rodauva",
			"cobardia.resiste.rodauva", "marca.enconada.tasajero"])
	assert_array(claves).not_contains(["encono.ocarra.ocarra", "cobardia.ocarra"])


# T44 (Mundo.md 9.2 v1.3, A.7): las variantes por especie de quien la sostuvo se
# piden solo si estan en el archivo.
func test_claves_de_quien_sostuvo() -> void:
	var lectura: Dictionary = DatosFixture.cargar()
	assert_array(lectura["errores"]).is_empty()
	var datos: Dictionary = lectura["datos"]
	datos["textos/es.json"] = {"cobardia.resiste.maestro.surcon": "x", "cobardia.resiste.afin.rodauva": "x"}
	var claves: Array[String] = ClavesTextos.usadas(datos)
	assert_array(claves).contains(["cobardia.resiste.maestro", "cobardia.resiste.afin",
			"cobardia.resiste.maestro.surcon", "cobardia.resiste.afin.rodauva"])
	assert_array(claves).not_contains(["cobardia.resiste.maestro.rodauva", "cobardia.resiste.afin.surcon"])


# T22 (sesion 2): por cada hechizo del Maestro (maestro.json), su nombre y su
# tooltip, y el rotulo de cada modo de hechizos.json; con el fixture de otro id,
# las de ese id. Los choques de la Lanzadera y los motivos de los botones son fijos.
func test_claves_de_hechizos_desde_los_datos() -> void:
	var lectura: Dictionary = DatosFixture.cargar()
	assert_array(lectura["errores"]).is_empty()
	var datos: Dictionary = lectura["datos"]
	var claves: Array[String] = ClavesTextos.usadas(datos)
	for hechizo in ["martillazo", "lanzadera", "remiendo"]:
		assert_array(claves).contains(["hechizo.%s.nombre" % hechizo, "hechizo.%s.tooltip" % hechizo])
	assert_array(claves).contains(["hechizo.sentido.empujar", "hechizo.sentido.atraer", "lanzadera.choque",
			"lanzadera.choque.contra_maestro", "lanzadera.choque.obstaculo", "aviso.hechizo.mana_insuficiente",
			"aviso.hechizo.accion_usada", "aviso.hechizo.sin_objetivos"])
	# Ninguna variante por especie del choque esta en los textos: no se pide.
	assert_array(claves).not_contains(["lanzadera.choque.ocarra"])

	datos["hechizos.json"] = LectorFixture.leer("res://pruebas/fixtures/pantalla/hechizos.json", "hechizos")["datos"]
	datos["maestro.json"] = LectorFixture.leer("res://pruebas/fixtures/pantalla/maestro_hechizos.json",
			"maestro")["datos"]
	claves = ClavesTextos.usadas(datos)
	assert_array(claves).contains(["hechizo.pedrada.nombre", "hechizo.pedrada.tooltip"])
	assert_array(claves).not_contains(["hechizo.martillazo.nombre"])
	# Con una variante en el archivo de textos, se pide.
	datos["textos/es.json"] = {"lanzadera.choque.ocarra": "La Ocarra sale volando."}
	assert_array(ClavesTextos.usadas(datos)).contains(["lanzadera.choque.ocarra"])
