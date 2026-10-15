# Arquitectura.md D-015 (T33, sesion 3): lo que hace herramientas/informe_playtest.gd.
# Lee los resultados (<nombre>_resultado.json) de una carpeta y sus fichas de
# playtest (<nombre>_playtest.json), y escribe en la misma carpeta el informe
# (informe_playtest.json: grupos, alarmas, comparaciones, informativas y avisos)
# y una fila por combate (informe_playtest.csv). Las cuentas son todas de
# AlarmasPlaytest; aca solo se leen archivos, se aplanan metricas y se escribe.
# Separado del script de consola para probarlo sin lanzar Godot.
class_name SalidaInformePlaytest
extends RefCounted

const ARCHIVO_JSON: String = "informe_playtest.json"
const ARCHIVO_CSV: String = "informe_playtest.csv"
const AVISO_SIN_FICHA: String = "sin_ficha"
const AVISO_FICHA_INVALIDA: String = "ficha_invalida"
const AVISO_RESULTADO_INVALIDO: String = "resultado_invalido"

# Las columnas del CSV, fijas y en este orden. Las listas de las metricas van
# como cantidades; null, como celda vacia.
const COLUMNAS: Array[String] = [
	"archivo", "escenario", "variante", "semilla", "indice_semilla", "jugador", "desenlace",
	"rondas_totales", "rondas_primer_ataque", "rondas_de_pelea", "secundar_usos",
	"eslabones_cadenas", "eslabones_suma", "eslabones_maximo",
	"incidentes_tribu_distraida", "incidentes_tribu_golpe", "incidentes_enemigas_distraida",
	"incidentes_enemigas_golpe", "encono_tribu", "encono_enemigas",
	"cobardia_tribu_acobardada", "cobardia_tribu_resistida", "cobardia_enemigas_acobardada",
	"cobardia_enemigas_resistida", "sellados_intentos", "sellados_logrados",
	"capturas_perdidas_huida", "capturas_perdidas_cero", "caidas", "caidas_guardadas", "muertes",
	"rescatista", "distancia_maestro_turnos", "distancia_maestro_suma",
	"activas_erizarse", "activas_cavar", "activas_hacerse_junco", "activas_surcos", "activas_ocultos",
	"activas_destapes_contacto", "activas_bonos_cobrados", "activas_bonos_perdidos",
	"activas_cambios_modo", "activas_encierros", "activas_invocaciones", "destino_atacante",
]
# Celda de la variante desconocida (resultado sin ficha) y de la columna
# rescatista cuando el Maestro cayo sin nadie que lo rescate.
const VARIANTE_DESCONOCIDA: String = "?"
const PERMADEATH: String = "permadeath"
# El .import que deja el CSV como archivo comun (sin el importador de
# traducciones de Godot), cuando se escribe dentro del proyecto (registros/).
const IMPORT_SIN_IMPORTAR: String = "[remap]\n\nimporter=\"keep\"\n"

const _CARPETA_ESQUEMAS: String = "res://datos"
const _SUFIJO_RESULTADO: String = GuardadoCombate.SUFIJO_RESULTADO
const _SUFIJO_PLAYTEST: String = GuardadoCombate.SUFIJO_PLAYTEST


# Los resultados de la carpeta, en orden de nombre, validados contra su esquema
# (asi los numeros son int). Devuelve {resultados, fichas, archivos, avisos}:
# archivos = el nombre sin el sufijo. Un resultado roto se saltea con su aviso;
# uno sin ficha (o con la ficha rota) va con FichaPlaytest.desconocida.
static func leer(carpeta: String, semillas_playtest: Array) -> Dictionary:
	var lectura: Dictionary = {"resultados": [] as Array[Dictionary], "fichas": [] as Array[Dictionary],
			"archivos": [] as Array[String], "avisos": [] as Array[Dictionary]}
	if not DirAccess.dir_exists_absolute(carpeta):
		return lectura
	var cargador: Cargador = Cargador.new()
	var esquema_resultado: Dictionary = cargador.esquema_resuelto(_CARPETA_ESQUEMAS, "resultado")["esquema"]
	var esquema_ficha: Dictionary = cargador.esquema_resuelto(_CARPETA_ESQUEMAS, "playtest")["esquema"]
	var nombres: Array = Array(DirAccess.get_files_at(carpeta))
	nombres.sort()
	for nombre in nombres:
		if not (nombre as String).ends_with(_SUFIJO_RESULTADO):
			continue
		var resultado: Variant = _leer_json(carpeta.path_join(nombre), esquema_resultado)
		if resultado == null:
			(lectura["avisos"] as Array).append({"tipo": AVISO_RESULTADO_INVALIDO, "archivo": nombre})
			continue
		var base: String = (nombre as String).trim_suffix(_SUFIJO_RESULTADO)
		var ficha: Variant = null
		var ruta_ficha: String = carpeta.path_join(base + _SUFIJO_PLAYTEST)
		if FileAccess.file_exists(ruta_ficha):
			ficha = _leer_json(ruta_ficha, esquema_ficha)
			if ficha == null:
				(lectura["avisos"] as Array).append({"tipo": AVISO_FICHA_INVALIDA, "archivo": base + _SUFIJO_PLAYTEST})
		else:
			(lectura["avisos"] as Array).append({"tipo": AVISO_SIN_FICHA, "archivo": nombre})
		if ficha == null:
			ficha = FichaPlaytest.desconocida(resultado, semillas_playtest)
		(lectura["resultados"] as Array).append(resultado)
		(lectura["fichas"] as Array).append(ficha)
		(lectura["archivos"] as Array).append(base)
	return lectura


# El informe: {partidas, grupos, comparaciones, informativas, avisos} (los de
# AlarmasPlaytest despues de los de la lectura).
static func informe(lectura: Dictionary, datos: Dictionary) -> Dictionary:
	var calculo: Dictionary = AlarmasPlaytest.calcular(lectura["resultados"], lectura["fichas"], datos)
	var avisos: Array = (lectura["avisos"] as Array).duplicate(true)
	avisos.append_array(calculo["avisos"] as Array)
	return {"partidas": (lectura["resultados"] as Array).size(), "grupos": calculo["grupos"],
			"comparaciones": calculo["comparaciones"], "informativas": calculo["informativas"], "avisos": avisos}


# Las lineas del CSV: la cabecera y una fila por combate, en el orden de la lectura.
static func filas_csv(lectura: Dictionary) -> Array[String]:
	var filas: Array[String] = [",".join(COLUMNAS)]
	for i in range((lectura["resultados"] as Array).size()):
		var celdas: PackedStringArray = []
		for valor in _fila(lectura["archivos"][i], lectura["resultados"][i], lectura["fichas"][i]):
			celdas.append(_celda(valor))
		filas.append(",".join(celdas))
	return filas


# Por grupo: partidas, jugadores y las alarmas que saltaron; despues las
# comparaciones, las informativas y los avisos.
static func resumen(informe_armado: Dictionary, carpeta: String) -> Array[String]:
	var lineas: Array[String] = ["Informe de playtest: %d combates en %s" % [informe_armado["partidas"], carpeta]]
	for grupo in (informe_armado["grupos"] as Array):
		var saltaron: Array[String] = []
		for alarma in (grupo["alarmas"] as Array):
			if alarma["estado"] == AlarmasPlaytest.ESTADO_ALARMA:
				saltaron.append(alarma["id"])
		lineas.append("%s (%s): %d partidas, %d jugadores. Alarmas que saltaron: %s" % [grupo["escenario"],
				_texto_variante(grupo["variante"]), grupo["partidas"], grupo["jugadores"],
				"ninguna" if saltaron.is_empty() else ", ".join(saltaron)])
	for comparacion in (informe_armado["comparaciones"] as Array):
		lineas.append("%s (%s contra %s): %s" % [comparacion["id"], comparacion["escenario"],
				comparacion["comparado_con"], comparacion["estado"]])
	for informativa in (informe_armado["informativas"] as Array):
		lineas.append("%s (%s contra %s): %s" % [informativa["id"], informativa["escenario"],
				informativa["comparado_con"], informativa["resultado"]])
	lineas.append("Avisos: %d" % (informe_armado["avisos"] as Array).size())
	for aviso in (informe_armado["avisos"] as Array):
		lineas.append("  " + JSON.stringify(aviso, "", true))
	return lineas


# Lee la carpeta y escribe los dos archivos en ella. Sin resultados (o sin la
# carpeta) no escribe nada y lo dice. Devuelve {escritas, resumen}.
static func escribir(carpeta: String, datos: Dictionary) -> Dictionary:
	var semillas: Array = (datos.get(AlarmasPlaytest.ARCHIVO, {}) as Dictionary).get("semillas", [])
	var lectura: Dictionary = leer(carpeta, semillas)
	var escritas: Array[String] = []
	if (lectura["resultados"] as Array).is_empty():
		var lineas: Array[String] = ["No hay resultados (*%s) en %s: no se escribio el informe." % [
				_SUFIJO_RESULTADO, carpeta]]
		for aviso in (lectura["avisos"] as Array):
			lineas.append("  " + JSON.stringify(aviso, "", true))
		return {"escritas": escritas, "resumen": lineas}
	var armado: Dictionary = informe(lectura, datos)
	var ruta_json: String = carpeta.path_join(ARCHIVO_JSON)
	var ruta_csv: String = carpeta.path_join(ARCHIVO_CSV)
	if _escribir(ruta_json, JSON.stringify(armado, "\t", true)):
		escritas.append(ruta_json)
	if _escribir(ruta_csv, "\n".join(filas_csv(lectura)) + "\n"):
		escritas.append(ruta_csv)
		# Dentro del proyecto, el editor importaria el CSV como traducciones.
		if dentro_del_proyecto(carpeta):
			_escribir(ruta_csv + ".import", IMPORT_SIN_IMPORTAR)
	return {"escritas": escritas, "resumen": resumen(armado, carpeta)}


# Si la carpeta esta dentro del proyecto (res://, o su ruta absoluta).
static func dentro_del_proyecto(carpeta: String) -> bool:
	return ProjectSettings.localize_path(carpeta).begins_with("res://")


# --- Ayudantes ---------------------------------------------------------------

# El contenido validado, o null si no es JSON o no valida. JSON.new().parse no
# escribe en la consola (JSON.parse_string si): el archivo roto ya va como aviso.
static func _leer_json(ruta: String, esquema: Dictionary) -> Variant:
	var lector: JSON = JSON.new()
	if lector.parse(FileAccess.get_file_as_string(ruta)) != OK:
		return null
	var validacion: Dictionary = Validador.new().validar(lector.data, esquema, ruta.get_file())
	if not (validacion["errores"] as Array).is_empty():
		return null
	return validacion["datos"]


static func _fila(archivo: String, resultado: Dictionary, ficha: Dictionary) -> Array:
	var m: Dictionary = resultado["metricas"]
	var activas: Dictionary = m["activas"]
	var rescatista: Variant = null
	if m["rescate"] != null:
		rescatista = PERMADEATH if m["rescate"]["rescatista"] == null else m["rescate"]["rescatista"]
	var destino: Variant = null
	if resultado["destino_atacante"] != null:
		destino = resultado["destino_atacante"]["primera_opcion"]
	return [
		archivo, ficha["escenario"], _celda_variante(ficha["variante"]), ficha["semilla"],
		ficha["indice_semilla"], ficha["jugador"], resultado["desenlace"],
		m["rondas"]["totales"], m["rondas"]["primer_ataque"], m["rondas"]["de_pelea"], m["secundar"]["usos"],
		m["eslabones"]["cadenas"], m["eslabones"]["suma"], m["eslabones"]["maximo"],
		m["incidentes"]["tribu"]["distraida"], m["incidentes"]["tribu"]["golpe"],
		m["incidentes"]["enemigas"]["distraida"], m["incidentes"]["enemigas"]["golpe"],
		m["encono"]["tribu"], m["encono"]["enemigas"],
		m["cobardia"]["tribu"]["acobardada"], m["cobardia"]["tribu"]["resistida"],
		m["cobardia"]["enemigas"]["acobardada"], m["cobardia"]["enemigas"]["resistida"],
		_cantidad(m["sellados"]), _cuenta(m["sellados"], "logrado", true),
		_cuenta(m["capturas_perdidas"], "motivo", MetricasCombate.MOTIVO_HUIDA),
		_cuenta(m["capturas_perdidas"], "motivo", MetricasCombate.MOTIVO_CERO),
		_cantidad(m["caidas"]), _cantidad(m["caidas_guardadas"]), _cantidad(m["muertes"]),
		rescatista, m["distancia_maestro"]["turnos"], m["distancia_maestro"]["suma"],
		_suma(activas["usos"], MetricasCombate.ACTIVAS[0]), _suma(activas["usos"], MetricasCombate.ACTIVAS[1]),
		_suma(activas["usos"], MetricasCombate.ACTIVAS[2]), activas["surcos"], activas["ocultos"],
		activas["destapes_contacto"], activas["bonos_cobrados"], activas["bonos_perdidos"],
		_cantidad(activas["cambios_modo"]), _suma(activas["encierros"], "turnos"),
		_suma_valores(activas["invocaciones"]), destino,
	]


# Las metricas de T24 a T29 pueden faltar (null) en resultados viejos.
static func _cantidad(lista: Variant) -> Variant:
	return null if lista == null else (lista as Array).size()


static func _cuenta(lista: Variant, campo: String, valor: Variant) -> Variant:
	if lista == null:
		return null
	return (lista as Array).filter(func(fila: Dictionary) -> bool: return fila[campo] == valor).size()


static func _suma(lista: Variant, campo: String) -> Variant:
	if lista == null:
		return null
	var total: int = 0
	for fila in (lista as Array):
		total += fila[campo] as int
	return total


# T45 (D-016): la suma de los valores de un {unidad: cantidad}.
static func _suma_valores(por_unidad: Dictionary) -> int:
	var total: int = 0
	for cantidad in por_unidad.values():
		total += cantidad as int
	return total


static func _celda_variante(variante: Variant) -> String:
	if variante == null:
		return VARIANTE_DESCONOCIDA
	if (variante as Dictionary).is_empty():
		return ""
	return JSON.stringify(variante, "", true)


static func _texto_variante(variante: Variant) -> String:
	if variante == null:
		return "variante desconocida"
	if (variante as Dictionary).is_empty():
		return "sin cambios"
	return JSON.stringify(variante, "", true)


# RFC 4180: entre comillas si lleva coma, comillas o salto de linea.
static func _celda(valor: Variant) -> String:
	if valor == null:
		return ""
	var texto: String = str(valor)
	if texto.contains(",") or texto.contains("\"") or texto.contains("\n"):
		return "\"%s\"" % texto.replace("\"", "\"\"")
	return texto


static func _escribir(ruta: String, contenido: String) -> bool:
	var archivo: FileAccess = FileAccess.open(ruta, FileAccess.WRITE)
	if archivo == null:
		printerr("No se pudo escribir " + ruta)
		return false
	archivo.store_string(contenido)
	archivo.close()
	return true
