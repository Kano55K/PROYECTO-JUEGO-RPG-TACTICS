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
