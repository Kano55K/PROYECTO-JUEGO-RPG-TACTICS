# Arquitectura.md A.9 y B.4 (T31): las variantes de 11.9 que ya no tienen
# archivo se arman con EdicionEscenario sobre el escenario del disco, como en
# el panel. Hoy, D normal con balanza 4 (Sistema.md 11.9 y 14), que reemplaza a
# d_rivales_balanza4.json. La usan los tests permanentes con datos/ real.
# No extiende GdUnitTestSuite: es un ayudante, no una suite.
class_name VariantesEscenario
extends RefCounted

const D_BALANZA_4: String = "d_rivales_balanza4"

# nombre -> [escenario base, {ruta: valor}]
const _VARIANTES: Dictionary = {
	D_BALANZA_4: ["d_rivales_normal", {"maestro.balanza": 4}],
}
const _CARPETA_ESQUEMAS: String = "res://datos"


static func nombres() -> Array[String]:
	var lista: Array[String] = []
	lista.assign(_VARIANTES.keys())
	return lista


# El escenario de ese id: el archivo de datos/escenarios/, o la variante armada
# y validada. {} si no existe o la variante no valida (el test que la pide falla).
static func escenario(datos: Dictionary, escenario_id: String) -> Dictionary:
	var ruta: String = "escenarios/%s.json" % escenario_id
	if datos.has(ruta):
		return datos[ruta]
	if not _VARIANTES.has(escenario_id):
		return {}
	var base: String = _VARIANTES[escenario_id][0]
	var esquema: Dictionary = Cargador.new().esquema_resuelto(_CARPETA_ESQUEMAS, "escenario")["esquema"]
	var edicion: EdicionEscenario = EdicionEscenario.new(datos["escenarios/%s.json" % base], datos, esquema)
	var cambios: Dictionary = _VARIANTES[escenario_id][1]
	for ruta_campo: String in cambios.keys():
		if not edicion.cambiar(ruta_campo, cambios[ruta_campo]).is_empty():
			return {}
	if not edicion.validar().is_empty():
		return {}
	return edicion.escenario()
