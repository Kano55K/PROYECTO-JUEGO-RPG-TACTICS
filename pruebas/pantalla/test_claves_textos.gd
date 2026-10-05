extends GdUnitTestSuite

# Arquitectura.md A.2.1 y B.2 (T13): la lista de claves que usa la pantalla,
# armada con constantes mas una clave por especie y por estado de hambre de los
# datos (fixtures, A.6).
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
	for estado in ["saciado", "normal", "hambriento", "famelico"]:
		assert_array(claves).contains(["hambre.estado.%s" % estado])

	var patron: RegEx = RegEx.create_from_string(_PATRON_CLAVE)
	var vistas: Dictionary = {}
	for clave in claves:
		assert_object(patron.search(clave)).override_failure_message(clave).is_not_null()
		assert_bool(vistas.has(clave)).override_failure_message("repetida: " + clave).is_false()
		vistas[clave] = true
