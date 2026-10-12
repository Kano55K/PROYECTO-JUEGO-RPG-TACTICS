# Arquitectura.md A.11, D-008 (T21-ajustes): las reglas sin estado del combate,
# en un solo objeto. Las arma ContextoCombate una vez y el Turno las recibe
# enteras. El estado (Plantel, Surcos, Cadena, cola), el Tablero y el generador
# de azar no van aca: siguen como parametros propios.
# Una regla nueva (desde T22) se suma como campo, en _init y en REGLAS.
class_name ReglasCombate
extends RefCounted

# Las reglas que se revisan al crear, en el orden de _init.
const REGLAS: Array[String] = ["danio", "afinidad", "combo", "incidente", "chequeo_rival", "regeneracion_mana",
		"hechizos", "sellado", "huida", "costos_mana"]

var danio: Danio
var afinidad: Afinidad
var combo: Combo
var incidente: Incidente
var chequeo_rival: ChequeoRival
var regeneracion_mana: RegeneracionMana
# Sistema.md 1.6 (T22): los hechizos del Maestro.
var hechizos: Hechizos
# Sistema.md 4.1 a 4.3 (T24): sellar en combate.
var sellado: Sellado
# Sistema.md 11.7 (T25): la huida de las salvajes al inicio de su turno.
var huida: Huida
# Sistema.md 2.3 (T26): los costos de mana con descuento (sellar e invocar).
var costos_mana: CostosMana
# La primera regla que llego nula, o "" si estan todas. Sin valores por defecto:
# una regla que falta falla al crear, con su nombre (leccion de T09 y T37).
var falta: String = ""


func _init(regla_danio: Danio, regla_afinidad: Afinidad, regla_combo: Combo, regla_incidente: Incidente,
		regla_chequeo: ChequeoRival, regla_mana: RegeneracionMana, regla_hechizos: Hechizos,
		regla_sellado: Sellado, regla_huida: Huida, regla_costos: CostosMana) -> void:
	danio = regla_danio
	afinidad = regla_afinidad
	combo = regla_combo
	incidente = regla_incidente
	chequeo_rival = regla_chequeo
	regeneracion_mana = regla_mana
	hechizos = regla_hechizos
	sellado = regla_sellado
	huida = regla_huida
	costos_mana = regla_costos
	for nombre in REGLAS:
		if get(nombre) == null:
			falta = nombre
			push_error("ReglasCombate: falta la regla " + nombre)
			return
