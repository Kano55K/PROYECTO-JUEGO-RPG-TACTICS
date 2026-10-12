# Sistema.md 11.7 y 11.3 paso 2 (T25): la huida de las salvajes al inicio de su
# turno, sin estado. El % de cada especie sale de su ficha (huida_pct); el umbral
# de vida y el +25 de la acobardada, de tablas/combate.json (huida_salvaje); el
# tope del Encono, de encono.max_puntos. La tirada la pide el Turno; el registro
# lo escribe el Combate.
class_name Huida
extends RefCounted

# Arquitectura.md A.7: el resultado del evento `huida`.
const RESULTADO_HUYE: String = "huye"
const RESULTADO_SE_QUEDA: String = "se_queda"

const _CIEN: int = 100

var _umbral_vida_pct: int = 0
var _acobardada_pts: int = 0
var _maximo_encono: int = 0


# null si falta un dato: sin valores por defecto (leccion de T09 y T37).
static func desde_datos(tabla_combate: Dictionary) -> Huida:
	var huida_salvaje: Dictionary = tabla_combate.get("huida_salvaje", {})
	var encono: Dictionary = tabla_combate.get("encono", {})
	if not huida_salvaje.has("umbral_vida_pct") or not huida_salvaje.has("acobardada_pts") \
			or not encono.has("max_puntos"):
		return null
	var regla: Huida = Huida.new()
	regla._umbral_vida_pct = huida_salvaje["umbral_vida_pct"]
	regla._acobardada_pts = huida_salvaje["acobardada_pts"]
	regla._maximo_encono = encono["max_puntos"]
	return regla


# Sistema.md 11.7: el % de huida de la unidad. 0 si no es una salvaje de pie
# (la tribu, el Maestro y la atacante nocturna no huyen: 9.2, punto 5), si su
# vida supera el umbral (comparando en enteros: vida x 100 <= umbral x vida_max)
# o si cuenta como enconada ("no huye"). Si no, el de su ficha, mas el de la
# acobardada si `acobardada`, recortado a 100.
# S-52: en el paso 2 de 11.3 cuenta como enconada la que tiene el Encono en el
# maximo (quedaria enconada sin tirar, ChequeoRival).
func porcentaje(unidad_id: String, plantel: Plantel, acobardada: bool) -> int:
	var criatura: Criatura = plantel.criatura(unidad_id)
	if criatura == null or criatura.comportamiento != Criatura.Comportamiento.SALVAJE \
			or not Objetivos.de_pie(unidad_id, plantel):
		return 0
	if criatura.vida * _CIEN > _umbral_vida_pct * criatura.vida_max_real():
		return 0
	if criatura.encono >= _maximo_encono:
		return 0
	var resultado: int = criatura.especie.huida_pct()
	if acobardada:
		resultado += _acobardada_pts
	return mini(_CIEN, resultado)


# Lectura S-52: con el orden de 11.3 (huida en el paso 2, chequeo de rival en el
# 3), al empezar el turno nunca esta acobardada. Es el unico lugar de esa
# lectura: lo usan el Turno y la consulta de la pantalla (Combate.porcentaje_huida).
func porcentaje_al_empezar(unidad_id: String, plantel: Plantel) -> int:
	return porcentaje(unidad_id, plantel, false)


# Sistema.md 11.7: una tirada con el generador de combate. {} con 0 % (no toca el
# generador); si no, {porcentaje, tiro, resultado}.
func tirar(unidad_id: String, plantel: Plantel, azar: GeneradorAzar) -> Dictionary:
	var valor: int = porcentaje_al_empezar(unidad_id, plantel)
	if valor == 0:
		return {}
	var tiro: int = Porcentajes.tiro(azar)
	return {"porcentaje": valor, "tiro": tiro,
			"resultado": RESULTADO_HUYE if Porcentajes.sale(tiro, valor) else RESULTADO_SE_QUEDA}
