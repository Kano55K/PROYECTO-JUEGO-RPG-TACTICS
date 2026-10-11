# Arquitectura.md B.2 (T13): la vista del combate, cenital y con placeholders.
# Arma el combate (la IA juega hasta el primer turno del jugador) y se redibuja
# entera desde el nucleo: no guarda copias del estado de reglas. Casilla <->
# pantalla solo con map_to_local / local_to_map (A.3): T32 cambia solo el
# tileset. El mouse sale de sus eventos, nunca del cursor del sistema (D-006).
# Sesion 2: el jugador juega con el mouse (InterpreteClic y botones),
# ve las marcas, el desglose de previsualizar_ataque y los sucesos del registro;
# al terminar, se guardan solos la grabacion y el registro y se ve el resultado.
class_name VistaCombate
extends Node2D

# El jugador pidio volver al selector desde la pantalla de resultado.
signal volver

const _ESCENA_FICHA: PackedScene = preload("res://pantalla/combate/ficha_unidad.tscn")
const _FUENTE_CASILLAS: int = 0
const _CASILLA_CLARA: Vector2i = Vector2i(0, 0)
const _CASILLA_OSCURA: Vector2i = Vector2i(1, 0)
const _FUENTE_MARCAS: int = 1
const _MARCA_MOVER: Vector2i = Vector2i(0, 0)
const _MARCA_OBJETIVO: Vector2i = Vector2i(1, 0)
# T40: surcos con el color del bando de su duenio, zona de Caza y casillas para cavar.
const _MARCA_SURCO_TRIBU: Vector2i = Vector2i(2, 0)
const _MARCA_SURCO_ENEMIGA: Vector2i = Vector2i(3, 0)
const _MARCA_ZONA: Vector2i = Vector2i(4, 0)
const _MARCA_CAVAR: Vector2i = Vector2i(5, 0)
# T40, sesion 2: el destino de cada paso de la IA.
const _MARCA_DESTINO: Vector2i = Vector2i(6, 0)
# T41: las unidades que darian afinidad desde la casilla bajo el mouse.
const _MARCA_AFIN: Vector2i = Vector2i(7, 0)
# T18: las rivales que darian riesgo de incidente desde la casilla bajo el mouse.
const _MARCA_RIVAL: Vector2i = Vector2i(8, 0)
# T19: las rivales enemigas que la harian tirar Encono o cobardia desde ahi.
const _MARCA_RIVAL_ENEMIGA: Vector2i = Vector2i(9, 0)
# T17: las aliadas que se pueden Secundar (la misma marca de "elegir" que cavar).
const _MARCA_ALIADA: Vector2i = _MARCA_CAVAR
# T22: las objetivos del hechizo elegido (la misma marca de "elegir") y, con el
# mouse sobre una, los destinos de la Lanzadera (la marca de destino).
const _MARCA_OBJETIVO_HECHIZO: Vector2i = _MARCA_CAVAR
const _MARCA_DESTINO_HECHIZO: Vector2i = _MARCA_DESTINO
# T24: las objetivos del sellado (la misma marca de "elegir").
const _MARCA_OBJETIVO_SELLAR: Vector2i = _MARCA_CAVAR
const _TEXTOS: String = "textos/es.json"
const _TABLA_HAMBRE: String = "tablas/hambre.json"
const _TABLA_LEALTAD: String = "tablas/lealtad.json"
const _ACCION_DEPURACION: String = "depuracion"
const _ACCION_SELECCIONAR: String = "seleccionar"
# T22: el clic derecho (atraer con la Lanzadera).
const _ACCION_SELECCIONAR_ALTERNO: String = "seleccionar_alterno"
const _ACCION_ZONA: String = "zona"
const _ACCION_SALTAR: String = "saltar"
# T42: la camara (D-003).
const _ACCION_CAMARA_ARRIBA: String = "camara_arriba"
const _ACCION_CAMARA_ABAJO: String = "camara_abajo"
const _ACCION_CAMARA_IZQUIERDA: String = "camara_izquierda"
const _ACCION_CAMARA_DERECHA: String = "camara_derecha"
const _ACCION_CAMARA_ACERCAR: String = "camara_acercar"
const _ACCION_CAMARA_ALEJAR: String = "camara_alejar"
const _ACCION_CAMARA_ARRASTRAR: String = "camara_arrastrar"
const _PREFIJO_BOTON_ACTIVA: String = "Activa_"
const _NOMBRE_BOTON_SECUNDAR: String = "Secundar"
const _PREFIJO_BOTON_HECHIZO: String = "Hechizo_"
const _NOMBRE_BOTON_SELLAR: String = "Sellar"
# Presentacion: la oculta sigue visible para el jugador, a media transparencia.
const _ALFA_OCULTA: float = 0.45
const _CARPETA_REGISTROS: String = "res://registros"
# Presentacion: cuantas lineas de sucesos se ven a la vez.
const _SUCESOS_VISIBLES: int = 12
const _COLOR_ACTUAL: Color = Color(1.0, 0.85, 0.3)
const _COLOR_ACTUO: Color = Color(0.6, 0.6, 0.6)
const _COLOR_PENDIENTE: Color = Color(1, 1, 1)
const _MARCA_ACTUAL: String = "> "

# T40, sesion 2: segundos entre los pasos de la IA. Es presentacion, no un dato
# de balance; con 0 no se anima (los tests la ponen en 0).
@export var pausa_ia: float = 0.4
# T42 (D-003): la camara. Es presentacion, no datos de balance. El zoom de
# Camera2D: mas grande = mas cerca. paso_zoom se suma al acercar y se resta al
# alejar; velocidad_camara en pixeles de pantalla por segundo; margen en
# pixeles del lienzo alrededor del tablero.
@export var zoom_minimo: float = 0.5
@export var zoom_maximo: float = 2.0
@export var paso_zoom: float = 0.25
@export var velocidad_camara: float = 600.0
@export var margen: float = 64.0

var _combate: Combate = null
var _armador: ArmadorTextos = null
var _estados: EstadosUnidad = null
var _avisos_carga: Array[Dictionary] = []
var _carpeta_registros: String = _CARPETA_REGISTROS
# Lineas de sucesos ya armadas y cuantas lineas del registro ya se leyeron.
var _sucesos: Array[String] = []
var _lineas_leidas: int = 0
# Ruta (sin extension) de lo guardado al terminar; "" mientras no se guardo.
var _guardado: String = ""
var _desglose_mostrado: Dictionary = {}
# La casilla bajo el mouse la ultima vez, para no rearmar el desglose en cada pixel.
var _casilla_mouse: Vector2i = Criatura.SIN_POSICION
# D-006: la posicion (en el viewport) del ultimo InputEventMouse recibido, y si
# llego alguno.
var _posicion_mouse: Vector2 = Vector2.ZERO
var _hay_mouse: bool = false
# T40, estado de la interfaz (no de reglas): el modo "elegir casilla" de Cavar,
# si la zona de Caza se ve, y el tooltip y el aviso que se muestran.
var _eligiendo_cavar: bool = false
# T17: el modo "elegir aliada" de Secundar y la aliada bajo el mouse ("" si
# ninguna), cuya cola resultante se muestra.
var _eligiendo_aliada: bool = false
var _aliada_previa: String = ""
# T22: el hechizo cuyo modo "elegir objetivo" esta puesto ("" si ninguno) y lo
# que se muestra con el mouse sobre una objetivo: {sentido: {evento, destaparia}}.
var _hechizo_elegido: String = ""
var _hechizo_mostrado: Dictionary = {}
# T24: el modo "elegir objetivo" de Sellar y lo que se muestra con el mouse sobre
# una objetivo: {objetivo, porcentaje, costo, previa}, o {}.
var _sellando: bool = false
var _sellado_mostrado: Dictionary = {}
var _zona_visible: bool = true
var _tooltip_mostrado: Array[String] = []
var _aviso_mostrado: String = ""
# T40, sesion 2: los pasos de la IA que faltan mostrar (SecuenciaIA) y si hay
# una secuencia en curso.
var _secuencia: Array[Dictionary] = []
var _en_secuencia: bool = false
# T42: el rectangulo (en el lienzo) del que no sale lo que se ve.
var _limites: Rect2 = Rect2()

@onready var _tablero: TileMapLayer = $Tablero
@onready var _capa_surcos: TileMapLayer = $Tablero/Surcos
@onready var _capa_zona: TileMapLayer = $Tablero/Zona
@onready var _marcas: TileMapLayer = $Tablero/Marcas
@onready var _capa_afines: TileMapLayer = $Tablero/Afines
@onready var _capa_rivales: TileMapLayer = $Tablero/Rivales
@onready var _capa_rivales_enemigas: TileMapLayer = $Tablero/RivalesEnemigas
@onready var _capa_destinos: TileMapLayer = $Tablero/DestinosHechizo
@onready var _unidades: Node2D = $Tablero/Unidades
@onready var _camara: Camera2D = $Camara
@onready var _mensaje: Label = $Interfaz/Mensaje
@onready var _ronda: Label = $Interfaz/Ronda
@onready var _cola: VBoxContainer = $Interfaz/Cola
@onready var _panel_turno: Label = $Interfaz/PanelTurno
@onready var _panel_desglose: Label = $Interfaz/PanelDesglose
@onready var _texto_sucesos: Label = $Interfaz/Sucesos
@onready var _botones: HBoxContainer = $Interfaz/Botones
@onready var _boton_terminar: Button = $Interfaz/Botones/BotonTerminar
@onready var _panel_unidad: Label = $Interfaz/PanelUnidad
@onready var _aviso: Label = $Interfaz/Aviso
@onready var _pantalla_resultado: Control = $Interfaz/PantallaResultado
@onready var _texto_resultado: Label = $Interfaz/PantallaResultado/Contenido/TextoResultado
@onready var _boton_volver: Button = $Interfaz/PantallaResultado/Contenido/BotonVolver
@onready var _depuracion: TextEdit = $Interfaz/PanelDepuracion
@onready var _pausa: Timer = $PausaIA


func _ready() -> void:
	_boton_terminar.pressed.connect(pulsar_terminar)
	_boton_volver.pressed.connect(volver.emit)
	_pausa.timeout.connect(_siguiente_paso)


# escenario y datos: los del Cargador. avisos_carga: sus avisos, para el panel
# de depuracion. carpeta_registros: donde se guardan la grabacion y el registro
# al terminar ("" = res://registros).
func empezar(escenario: Dictionary, datos: Dictionary, avisos_carga: Array[Dictionary] = [],
		carpeta_registros: String = "") -> void:
	_avisos_carga = avisos_carga
	if not carpeta_registros.is_empty():
		_carpeta_registros = carpeta_registros
	var contexto: ContextoCombate = ContextoCombate.armar(escenario, datos)
	if not contexto.valido:
		# Pantalla de desarrollo: muestra el motivo tecnico.
		_mostrar_mensaje("El escenario %s no se puede armar: %s" % [escenario.get("id", ""),
				ContextoCombate.Motivo.keys()[contexto.motivo]])
		return
	_combate = Combate.empezar(contexto)
	_armador = ArmadorTextos.desde_datos(datos[_TEXTOS], contexto.azar_textos)
	_estados = EstadosUnidad.desde_datos(datos[_TABLA_HAMBRE], datos[_TABLA_LEALTAD])
	_despues_de_un_cambio()
	_encuadrar()
	for aviso in _avisos_armador():
		print("[textos] ", aviso)


# null si el escenario no se pudo armar.
func combate() -> Combate:
	return _combate


func tablero() -> TileMapLayer:
	return _tablero


func camara() -> Camera2D:
	return _camara


# T42: los limites de la camara (las esquinas del tablero mas el margen).
func limites_camara() -> Rect2:
	return _limites


# T42: la casilla bajo el mouse la ultima vez que se miro (hover). D-006: sale
# de _casilla_del_mouse; sin ningun evento del mouse, Criatura.SIN_POSICION.
func casilla_bajo_mouse() -> Vector2i:
	return _casilla_mouse


# T42: mueve la camara (en pixeles del lienzo), acotada a los limites. Anda
# tambien durante la secuencia de la IA: solo mira.
func mover_camara(desplazamiento: Vector2) -> void:
	if _combate == null:
		return
	_camara.global_position += desplazamiento
	_acotar_camara()


func acercar() -> void:
	_cambiar_zoom(paso_zoom)


func alejar() -> void:
	_cambiar_zoom(-paso_zoom)


func fichas() -> Array[FichaUnidad]:
	var lista: Array[FichaUnidad] = []
	for hijo in _unidades.get_children():
		lista.append(hijo as FichaUnidad)
	return lista


# Las filas de la cola tal como se ven (Label con meta unidad_id, marca y actual).
func filas_cola() -> Array[Label]:
	var lista: Array[Label] = []
	for hijo in _cola.get_children():
		if hijo.has_meta("unidad_id"):
			lista.append(hijo as Label)
	return lista


# Un clic en una casilla: la Accion que da el InterpreteClic, si hay alguna.
# Devuelve true si se aplico. T22: alterno es el clic derecho (`seleccionar_alterno`).
func clic_casilla(casilla: Vector2i, alterno: bool = false) -> bool:
	if _combate == null or _en_secuencia or not _combate.esperando_jugador():
		return false
	var accion: Accion = InterpreteClic.accion(_combate.turno_actual(), _combate.instantanea(), casilla, _eligiendo_cavar,
			_eligiendo_aliada, _hechizo_elegido, alterno, _sellando)
	if accion == null:
		return false
	return _aplicar(accion)


# El mouse sobre una casilla: con una objetivo atacable, el desglose de
# previsualizar_ataque desde donde esta la unidad. T40: con una unidad, su
# tooltip; en una casilla para moverse que la dejaria junto a una oculta
# enemiga, el aviso (Combate.destaparia). T41: en una casilla para moverse o en
# la propia, se marcan las unidades que le darian afinidad desde ahi
# (Combate.afines_desde) y, si hay alguna, el aviso suma afinidad.tooltip. T18:
# ahi mismo, las rivales del incidente (Combate.incidente_en) e incidente.tooltip.
# T19: y las rivales enemigas del Encono o la cobardia (Combate.rival_en).
func sobre_casilla(casilla: Vector2i) -> void:
	_desglose_mostrado = {}
	_hechizo_mostrado = {}
	_sellado_mostrado = {}
	_tooltip_mostrado = []
	_aviso_mostrado = ""
	_capa_afines.clear()
	_capa_rivales.clear()
	_capa_rivales_enemigas.clear()
	_capa_destinos.clear()
	# Durante la secuencia de la IA, nada: el nucleo ya esta en el estado final y
	# las fichas todavia no.
	if _combate == null or _en_secuencia:
		return
	var foto: Dictionary = _combate.instantanea()
	var lectura: LecturaCombate = LecturaCombate.new(_combate, _armador, _estados)
	var unidad: String = _unidad_en(foto, casilla)
	if not unidad.is_empty():
		_tooltip_mostrado = lectura.tooltip_unidad(unidad)
	if _combate.esperando_jugador():
		var turno: Turno = _combate.turno_actual()
		var objetivo: String = InterpreteClic.objetivo_en(turno, foto, casilla)
		if not _hechizo_elegido.is_empty():
			_mostrar_hechizo(turno, foto, casilla)
		elif _sellando:
			_mostrar_sellado(turno, foto, casilla)
		elif _eligiendo_aliada:
			# T17: sobre una aliada valida, la cola muestra el orden que quedaria.
			var aliada: String = InterpreteClic.aliada_en(turno, foto, casilla)
			if aliada != _aliada_previa:
				_aliada_previa = aliada
				_dibujar_cola(lectura)
		elif not objetivo.is_empty():
			var vista_previa: ResultadoAccion = turno.previsualizar_ataque(_casilla_de(foto, turno.unidad_id), objetivo)
			if vista_previa.valida:
				_desglose_mostrado = vista_previa.desglose.a_diccionario()
		elif not _eligiendo_cavar:
			var para_mover: bool = turno.casillas_para_mover().has(casilla)
			var avisos: Array[String] = []
			if para_mover and not _combate.destaparia(turno.unidad_id, casilla).is_empty():
				avisos.append(_armador.armar(ClavesTextos.AVISO_DESTAPAR))
			if para_mover or casilla == _casilla_de(foto, turno.unidad_id):
				var afines: Array[String] = _combate.afines_desde(turno.unidad_id, casilla)
				for afin in afines:
					_capa_afines.set_cell(_casilla_de(foto, afin), _FUENTE_MARCAS, _MARCA_AFIN)
				if not afines.is_empty():
					avisos.append(_armador.armar(ClavesTextos.AFINIDAD_TOOLTIP))
				# T18 (Sistema.md 10.4: "la probabilidad se muestra en la casilla
				# antes de mover"): el % de incidente parada ahi y sus rivales. Con
				# 0 % no hay riesgo: no se marca nada.
				var incidente: Dictionary = _combate.incidente_en(turno.unidad_id, casilla)
				if incidente["porcentaje"] > 0:
					for rival in incidente["rivales"]:
						_capa_rivales.set_cell(_casilla_de(foto, rival), _FUENTE_MARCAS, _MARCA_RIVAL)
					avisos.append(_armador.armar(ClavesTextos.INCIDENTE_TOOLTIP,
							{"porcentaje": incidente["porcentaje"]}))
				# T19 (Sistema.md 10.5 y 10.6): el chequeo de rival enemiga que tiraria
				# al empezar su turno ahi (Combate.rival_en). Con 0 %, nada.
				var rival: Dictionary = _combate.rival_en(turno.unidad_id, casilla)
				if rival["porcentaje"] > 0:
					for rival_id in rival["rivales"]:
						_capa_rivales_enemigas.set_cell(_casilla_de(foto, rival_id), _FUENTE_MARCAS,
								_MARCA_RIVAL_ENEMIGA)
					var clave_rival: String = ClavesTextos.ENCONO_TOOLTIP \
							if rival["tipo"] == ChequeoRival.TIPO_ENCONO else ClavesTextos.COBARDIA_TOOLTIP
					avisos.append(_armador.armar(clave_rival, {"porcentaje": rival["porcentaje"]}))
			_aviso_mostrado = "\n".join(avisos)
	_dibujar_desglose()
	_dibujar_tooltip()


# T22: con el mouse sobre una objetivo del hechizo elegido, lo que haria en cada
# sentido (Turno.previsualizar_hechizo): el desglose si es un ataque; si no, su
# evento y las ocultas que destaparia, y el destino sin choque marcado.
func _mostrar_hechizo(turno: Turno, foto: Dictionary, casilla: Vector2i) -> void:
	var objetivo: String = InterpreteClic.objetivo_hechizo_en(turno, foto, casilla, _hechizo_elegido)
	if objetivo.is_empty():
		return
	for sentido in turno.sentidos_para_hechizo(_hechizo_elegido, objetivo):
		var previa: ResultadoAccion = turno.previsualizar_hechizo(_hechizo_elegido, objetivo, sentido)
		if not previa.valida:
			continue
		if previa.desglose != null:
			_desglose_mostrado = previa.desglose.a_diccionario()
			continue
		_hechizo_mostrado[sentido] = {"evento": previa.evento.duplicate(true), "destaparia": previa.destaparia.duplicate(),
				"previa": previa}
		var hasta: Variant = previa.evento.get("hasta")
		if hasta != null:
			_capa_destinos.set_cell(Vector2i(hasta[0], hasta[1]), _FUENTE_MARCAS, _MARCA_DESTINO_HECHIZO)


# T22: lo que se muestra del hechizo con el mouse sobre una objetivo, por
# sentido ("" si no tiene): {evento, destaparia}, o {}. El desglose de un ataque
# va en desglose_mostrado().
func hechizo_mostrado() -> Dictionary:
	var mostrado: Dictionary = {}
	for sentido in _hechizo_mostrado.keys():
		mostrado[sentido] = {"evento": _hechizo_mostrado[sentido]["evento"].duplicate(true),
				"destaparia": _hechizo_mostrado[sentido]["destaparia"].duplicate()}
	return mostrado


# T22: las casillas marcadas como destino de la Lanzadera ahora.
func casillas_destino_hechizo() -> Array[Vector2i]:
	return _capa_destinos.get_used_cells()


# Las lineas del tooltip que se ve ahora, o [].
func tooltip_mostrado() -> Array[String]:
	return _tooltip_mostrado.duplicate()


# El aviso que se ve ahora (destapar y afinidad, una linea cada uno), o "".
func aviso_mostrado() -> String:
	return _aviso_mostrado


# T41: las casillas de las unidades marcadas como afines ahora.
func casillas_afines() -> Array[Vector2i]:
	return _capa_afines.get_used_cells()


# T18: las casillas de las rivales marcadas por riesgo de incidente ahora.
func casillas_rivales() -> Array[Vector2i]:
	return _capa_rivales.get_used_cells()


# T19: las casillas de las rivales enemigas marcadas por Encono o cobardia ahora.
func casillas_rivales_enemigas() -> Array[Vector2i]:
	return _capa_rivales_enemigas.get_used_cells()


# T40: el boton de una activa (LecturaCombate.ACTIVA_*). Cavar no aplica nada:
# entra (o sale) del modo "elegir casilla". Devuelve true si hizo algo.
func pulsar_activa(tipo: String) -> bool:
	if _combate == null or _en_secuencia or not _combate.esperando_jugador():
		return false
	match tipo:
		LecturaCombate.ACTIVA_ERIZARSE:
			return _aplicar(Accion.erizarse())
		LecturaCombate.ACTIVA_HACERSE_JUNCO:
			return _aplicar(Accion.hacerse_junco())
		LecturaCombate.ACTIVA_CAVAR:
			_eligiendo_cavar = not _eligiendo_cavar
			_eligiendo_aliada = false
			_aliada_previa = ""
			_hechizo_elegido = ""
			_sellando = false
			redibujar()
			return true
	return false


# T22: el boton de un hechizo no aplica nada: entra (o sale) del modo "elegir
# objetivo" de ese hechizo. Solo si Turno.motivo_hechizo lo deja (salir, siempre).
# Devuelve true si hizo algo.
func pulsar_hechizo(hechizo_id: String) -> bool:
	if _combate == null or _en_secuencia or not _combate.esperando_jugador():
		return false
	if _hechizo_elegido == hechizo_id:
		_hechizo_elegido = ""
	elif _combate.turno_actual().motivo_hechizo(hechizo_id) == ResultadoAccion.Motivo.NINGUNO:
		_hechizo_elegido = hechizo_id
	else:
		return false
	_eligiendo_cavar = false
	_eligiendo_aliada = false
	_aliada_previa = ""
	_sellando = false
	redibujar()
	return true


# T24: el boton Sellar no aplica nada: entra (o sale) del modo "elegir objetivo".
# Solo si Turno.motivo_sellar lo deja (salir, siempre). Devuelve true si hizo algo.
func pulsar_sellar() -> bool:
	if _combate == null or _en_secuencia or not _combate.esperando_jugador():
		return false
	if not _sellando and _combate.turno_actual().motivo_sellar() != ResultadoAccion.Motivo.NINGUNO:
		return false
	_sellando = not _sellando
	_eligiendo_cavar = false
	_eligiendo_aliada = false
	_aliada_previa = ""
	_hechizo_elegido = ""
	redibujar()
	return true


func eligiendo_sellar() -> bool:
	return _sellando


# T24: lo que se muestra con el mouse sobre una objetivo del sellado
# (Turno.previsualizar_sellar): {objetivo, porcentaje, costo}, o {}.
func sellado_mostrado() -> Dictionary:
	if _sellado_mostrado.is_empty():
		return {}
	return {"objetivo": _sellado_mostrado["objetivo"], "porcentaje": _sellado_mostrado["porcentaje"],
			"costo": _sellado_mostrado["costo"]}


# T24: con el mouse sobre una objetivo del sellado, el % y el costo que da el nucleo.
func _mostrar_sellado(turno: Turno, foto: Dictionary, casilla: Vector2i) -> void:
	var objetivo: String = InterpreteClic.objetivo_sellar_en(turno, foto, casilla)
	if objetivo.is_empty():
		return
	var previa: ResultadoAccion = turno.previsualizar_sellar(objetivo)
	if previa.valida:
		_sellado_mostrado = {"objetivo": objetivo, "porcentaje": previa.porcentaje, "costo": previa.costo,
				"previa": previa}


# T22: el hechizo cuyo modo esta puesto, o "".
func hechizo_elegido() -> String:
	return _hechizo_elegido


func eligiendo_cavar() -> bool:
	return _eligiendo_cavar


# T17: el boton Secundar no aplica nada: entra (o sale) del modo "elegir
# aliada". Devuelve true si hizo algo.
func pulsar_secundar() -> bool:
	if _combate == null or _en_secuencia or not _combate.esperando_jugador():
		return false
	if not _eligiendo_aliada and _combate.turno_actual().aliadas_para_secundar().is_empty():
		return false
	_eligiendo_aliada = not _eligiendo_aliada
	_eligiendo_cavar = false
	_hechizo_elegido = ""
	_sellando = false
	_aliada_previa = ""
	redibujar()
	return true


func eligiendo_aliada() -> bool:
	return _eligiendo_aliada


func zona_visible() -> bool:
	return _zona_visible


# Las casillas marcadas como zona de Caza ahora.
func casillas_zona() -> Array[Vector2i]:
	return _capa_zona.get_used_cells()


# El desglose que se ve ahora (DesgloseDanio.a_diccionario()), o {}.
func desglose_mostrado() -> Dictionary:
	return _desglose_mostrado.duplicate(true)


func pulsar_terminar() -> bool:
	return _combate != null and not _en_secuencia and _aplicar(Accion.terminar())


func redibujar() -> void:
	var lectura: LecturaCombate = LecturaCombate.new(_combate, _armador, _estados)
	_dibujar_tablero()
	_dibujar_surcos()
	_dibujar_zona()
	_dibujar_marcas()
	_dibujar_fichas(lectura)
	_dibujar_interfaz(lectura)
	_dibujar_botones(lectura)
	_dibujar_desglose()
	_texto_sucesos.text = "\n".join(_sucesos.slice(maxi(0, _sucesos.size() - _SUCESOS_VISIBLES)))
	_dibujar_resultado(lectura)
	_dibujar_depuracion()
	if not _combate.error().is_empty():
		_mostrar_mensaje("Error del combate: " + _combate.error())


# T42: las direcciones de la camara se miran en cada frame (tecla sostenida).
func _process(delta: float) -> void:
	if _combate == null:
		return
	var direccion: Vector2 = Input.get_vector(_ACCION_CAMARA_IZQUIERDA, _ACCION_CAMARA_DERECHA,
			_ACCION_CAMARA_ARRIBA, _ACCION_CAMARA_ABAJO)
	if direccion != Vector2.ZERO:
		mover_camara(direccion * velocidad_camara * delta / _camara.zoom.x)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(_ACCION_CAMARA_ACERCAR):
		acercar()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(_ACCION_CAMARA_ALEJAR):
		alejar()
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion and Input.is_action_pressed(_ACCION_CAMARA_ARRASTRAR):
		# Arrastrar: el tablero sigue al mouse.
		mover_camara(-(event as InputEventMouseMotion).relative / _camara.zoom.x)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(_ACCION_DEPURACION):
		_depuracion.visible = not _depuracion.visible
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(_ACCION_SALTAR) and _en_secuencia:
		saltar()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(_ACCION_ZONA):
		alternar_zona()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(_ACCION_SELECCIONAR):
		clic_casilla(_casilla_del_mouse())
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(_ACCION_SELECCIONAR_ALTERNO):
		clic_casilla(_casilla_del_mouse(), true)
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion:
		var casilla: Vector2i = _casilla_del_mouse()
		if casilla != _casilla_mouse:
			_casilla_mouse = casilla
			sobre_casilla(casilla)


# D-006: la posicion del mouse sale del ultimo evento, nunca del cursor del
# sistema. Se guarda en _input (antes que _unhandled_input y tambien si un
# Control se queda con el evento); no se marca como manejado.
func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		_posicion_mouse = (event as InputEventMouse).position
		_hay_mouse = true


# D-006: la unica conversion de la posicion guardada a casilla (clic, hover y
# rehover al mover la camara). Sin ningun evento todavia, no hay casilla.
func _casilla_del_mouse() -> Vector2i:
	if not _hay_mouse:
		return Criatura.SIN_POSICION
	return _tablero.local_to_map(_tablero.get_global_transform_with_canvas().affine_inverse() * _posicion_mouse)


# T42 (D-003), al abrir: los limites salen de map_to_local de las esquinas del
# tablero del escenario. Si entra entero con el zoom minimo se encuadra entero;
# si no, se centra en el Maestro (EncuadreCamara.inicial). Despues, la camara
# solo la mueve el jugador.
func _encuadrar() -> void:
	var tablero_combate: Tablero = _combate.contexto().tablero
	var esquina_a: Vector2 = _tablero.to_global(_tablero.map_to_local(Vector2i(0, 0)))
	var esquina_b: Vector2 = _tablero.to_global(_tablero.map_to_local(
			Vector2i(tablero_combate.ancho - 1, tablero_combate.alto - 1)))
	_limites = EncuadreCamara.limites(esquina_a, esquina_b, margen)
	var centro_maestro: Variant = null
	var casilla_maestro: Vector2i = _casilla_de(_combate.instantanea(), Maestro.ID)
	if casilla_maestro != Criatura.SIN_POSICION:
		centro_maestro = _tablero.to_global(_tablero.map_to_local(casilla_maestro))
	var inicial: Dictionary = EncuadreCamara.inicial(_limites, get_viewport_rect().size, zoom_minimo, zoom_maximo,
			centro_maestro)
	_camara.zoom = Vector2.ONE * (inicial["zoom"] as float)
	_camara.global_position = inicial["centro"]
	_camara.force_update_scroll()


func _cambiar_zoom(cambio: float) -> void:
	if _combate == null:
		return
	_camara.zoom = Vector2.ONE * EncuadreCamara.acotar_zoom(_camara.zoom.x + cambio, zoom_minimo, zoom_maximo)
	_acotar_camara()


# Lo que se ve no sale de los limites. Con la camara movida y el mouse quieto,
# la casilla bajo el mouse puede cambiar: se rearma el hover.
func _acotar_camara() -> void:
	_camara.global_position = EncuadreCamara.acotar_centro(_camara.global_position,
			get_viewport_rect().size / _camara.zoom.x, _limites)
	_camara.force_update_scroll()
	var casilla: Vector2i = _casilla_del_mouse()
	if casilla != _casilla_mouse:
		_casilla_mouse = casilla
		sobre_casilla(casilla)


# Una accion del jugador: si el nucleo la acepta, se redibuja todo. T40, sesion
# 2: si despues jugo la IA y hay pausa, antes se muestran sus pasos de a uno.
func _aplicar(accion: Accion) -> bool:
	if not _combate.aplicar(accion).valida:
		return false
	_desglose_mostrado = {}
	_hechizo_mostrado = {}
	_tooltip_mostrado = []
	_aviso_mostrado = ""
	_eligiendo_cavar = false
	_eligiendo_aliada = false
	_aliada_previa = ""
	_hechizo_elegido = ""
	_sellando = false
	_sellado_mostrado = {}
	_casilla_mouse = Criatura.SIN_POSICION
	var pasos: Array[Dictionary] = SecuenciaIA.pasos(_combate.registro().lineas(), _lineas_leidas)
	if pausa_ia > 0.0 and not pasos.is_empty():
		_empezar_secuencia(pasos)
	else:
		_despues_de_un_cambio()
	return true


# T40, sesion 2: hay una secuencia de la IA en curso (la entrada de juego esta
# bloqueada).
func en_secuencia() -> bool:
	return _en_secuencia


# La accion `saltar`: termina la secuencia y redibuja desde el nucleo. Devuelve
# true si habia una.
func saltar() -> bool:
	if not _en_secuencia:
		return false
	_pausa.stop()
	_terminar_secuencia()
	return true


# Las fichas quedan como estaban antes de la accion; se apagan los botones, las
# marcas, la zona, el desglose y el tooltip.
func _empezar_secuencia(pasos: Array[Dictionary]) -> void:
	_secuencia = pasos
	_en_secuencia = true
	_botones.visible = false
	_marcas.clear()
	_capa_afines.clear()
	_capa_rivales.clear()
	_capa_rivales_enemigas.clear()
	_capa_destinos.clear()
	_capa_zona.clear()
	_dibujar_desglose()
	_dibujar_tooltip()
	_siguiente_paso()


# Muestra un paso con lo que dice el registro (la unidad resaltada y su destino
# marcado) y espera la pausa. Sin pasos, termina.
func _siguiente_paso() -> void:
	if not _en_secuencia:
		return
	if _secuencia.is_empty():
		_terminar_secuencia()
		return
	var paso: Dictionary = _secuencia.pop_front()
	_marcas.clear()
	for ficha in fichas():
		ficha.modulate = Color(1, 1, 1, ficha.modulate.a)
		ficha.mostrar_marca("")
	var actua: FichaUnidad = _ficha(paso["unidad"])
	if actua != null:
		actua.modulate = Color(_COLOR_ACTUAL, actua.modulate.a)
		# T20: la que actua, enconada o acobardada en su turno (el chequeo_rival
		# del registro), lleva la marca mientras se muestran sus pasos.
		if not (paso["estado"] as String).is_empty():
			actua.mostrar_marca(LecturaCombate.new(_combate, _armador, _estados).marca_estado(paso["unidad"],
					paso["estado"]))
	if paso["tipo"] == SecuenciaIA.MOVIMIENTO:
		var hasta: Vector2i = paso["hasta"]
		_marcas.set_cell(hasta, _FUENTE_MARCAS, _MARCA_DESTINO)
		if actua != null:
			actua.position = _tablero.map_to_local(hasta)
	else:
		var objetivo: FichaUnidad = _ficha(paso["objetivo"])
		if objetivo != null:
			_marcas.set_cell(_tablero.local_to_map(objetivo.position), _FUENTE_MARCAS, _MARCA_DESTINO)
			objetivo.mostrar_vida(paso["vida_despues"])
	_pausa.start(pausa_ia)


func _terminar_secuencia() -> void:
	_secuencia = []
	_en_secuencia = false
	_despues_de_un_cambio()


func _ficha(unidad_id: String) -> FichaUnidad:
	for ficha in fichas():
		if ficha.unidad_id == unidad_id:
			return ficha
	return null


# Lo nuevo del registro pasa a los sucesos; con el combate terminado se guarda
# una sola vez. Despues, se redibuja todo desde el nucleo.
func _despues_de_un_cambio() -> void:
	var lectura: LecturaCombate = LecturaCombate.new(_combate, _armador, _estados)
	_sucesos.append_array(lectura.sucesos(_lineas_leidas))
	_lineas_leidas = _combate.registro().lineas().size()
	if _combate.terminado() and _guardado.is_empty():
		_guardado = GuardadoCombate.guardar(_combate, _carpeta_registros)
		if _guardado.is_empty():
			_mostrar_mensaje("No se pudo guardar la partida en " + _carpeta_registros)
		else:
			print("[registros] guardado: %s.json y .jsonl" % ProjectSettings.globalize_path(_guardado))
	redibujar()


# El damero es decorado: alterna las dos casillas del tileset.
func _dibujar_tablero() -> void:
	var tablero_combate: Tablero = _combate.contexto().tablero
	_tablero.clear()
	for y in range(tablero_combate.alto):
		for x in range(tablero_combate.ancho):
			var clara: bool = (x + y) % 2 == 0
			_tablero.set_cell(Vector2i(x, y), _FUENTE_CASILLAS, _CASILLA_CLARA if clara else _CASILLA_OSCURA)


# Solo en el turno del jugador: a donde puede moverse y a quien puede atacar.
# T40: eligiendo donde cavar, solo las casillas de casillas_para_cavar.
func _dibujar_marcas() -> void:
	_marcas.clear()
	# T41: las de afinidad son del hover; el proximo movimiento del mouse las rearma.
	_capa_afines.clear()
	_capa_rivales.clear()
	_capa_rivales_enemigas.clear()
	_capa_destinos.clear()
	if not _combate.esperando_jugador():
		return
	var turno: Turno = _combate.turno_actual()
	# T22: eligiendo la objetivo de un hechizo, solo las de objetivos_para_hechizo.
	if not _hechizo_elegido.is_empty():
		var foto_hechizo: Dictionary = _combate.instantanea()
		for objetivo in turno.objetivos_para_hechizo(_hechizo_elegido):
			_marcas.set_cell(_casilla_de(foto_hechizo, objetivo), _FUENTE_MARCAS, _MARCA_OBJETIVO_HECHIZO)
		return
	# T24: eligiendo la objetivo del sellado, solo las de objetivos_para_sellar.
	if _sellando:
		var foto_sellar: Dictionary = _combate.instantanea()
		for objetivo in turno.objetivos_para_sellar():
			_marcas.set_cell(_casilla_de(foto_sellar, objetivo), _FUENTE_MARCAS, _MARCA_OBJETIVO_SELLAR)
		return
	if _eligiendo_cavar:
		for casilla in turno.casillas_para_cavar():
			_marcas.set_cell(casilla, _FUENTE_MARCAS, _MARCA_CAVAR)
		return
	var foto: Dictionary = _combate.instantanea()
	# T17: eligiendo a quien Secundar, solo las aliadas de aliadas_para_secundar.
	if _eligiendo_aliada:
		for aliada in turno.aliadas_para_secundar():
			_marcas.set_cell(_casilla_de(foto, aliada), _FUENTE_MARCAS, _MARCA_ALIADA)
		return
	for casilla in turno.casillas_para_mover():
		_marcas.set_cell(casilla, _FUENTE_MARCAS, _MARCA_MOVER)
	for objetivo in turno.objetivos_para_atacar():
		_marcas.set_cell(_casilla_de(foto, objetivo), _FUENTE_MARCAS, _MARCA_OBJETIVO)


# T40 (Sistema.md 11.2.1): cada surco con el color del bando de su duenio.
func _dibujar_surcos() -> void:
	_capa_surcos.clear()
	var plantel: Plantel = _combate.contexto().plantel
	for surco in _combate.instantanea()["surcos"]:
		var duenio: String = surco["duenio"]
		var de_la_tribu: bool = duenio == Maestro.ID or plantel.criatura(duenio).bando == Criatura.Bando.TRIBU
		_capa_surcos.set_cell(Vector2i(surco["casilla"][0], surco["casilla"][1]), _FUENTE_MARCAS,
				_MARCA_SURCO_TRIBU if de_la_tribu else _MARCA_SURCO_ENEMIGA)


# T40, zona de Caza (Sistema.md 11.2.3 y 15): en el turno del jugador, lo que
# amenaza cada enemiga de pie que todavia puede cambiar de modo (vida_de_cambio
# no es null: tiene modos y no paso al final, o sea, esta en Caza). La calcula
# el nucleo (zona_amenaza); la accion `zona` la oculta y la muestra.
func _dibujar_zona() -> void:
	_capa_zona.clear()
	if not _zona_visible or not _combate.esperando_jugador():
		return
	var plantel: Plantel = _combate.contexto().plantel
	for criatura in plantel.criaturas():
		if criatura.bando == Criatura.Bando.TRIBU or not Objetivos.de_pie(criatura.id, plantel) \
				or _combate.vida_de_cambio(criatura.id) == null:
			continue
		for casilla in _combate.zona_amenaza(criatura.id):
			_capa_zona.set_cell(casilla, _FUENTE_MARCAS, _MARCA_ZONA)


func alternar_zona() -> void:
	_zona_visible = not _zona_visible
	# Durante la secuencia de la IA, se ve en el redibujo final.
	if _combate != null and not _en_secuencia:
		_dibujar_zona()


func _dibujar_tooltip() -> void:
	_panel_unidad.visible = not _tooltip_mostrado.is_empty()
	_panel_unidad.text = "\n".join(_tooltip_mostrado)
	_aviso.visible = not _aviso_mostrado.is_empty()
	_aviso.text = _aviso_mostrado


func _dibujar_fichas(lectura: LecturaCombate) -> void:
	for hijo in _unidades.get_children():
		_unidades.remove_child(hijo)
		hijo.queue_free()
	for datos_ficha in lectura.fichas():
		var ficha: FichaUnidad = _ESCENA_FICHA.instantiate()
		_unidades.add_child(ficha)
		ficha.mostrar(datos_ficha)
		ficha.position = _tablero.map_to_local(datos_ficha["casilla"])
		ficha.modulate.a = _ALFA_OCULTA if datos_ficha["oculta"] else 1.0


func _dibujar_interfaz(lectura: LecturaCombate) -> void:
	_ronda.text = lectura.texto_ronda()
	_dibujar_cola(lectura)
	_panel_turno.text = "\n".join(lectura.panel_turno())


# La cola de la ronda; T17: con una aliada bajo el mouse en el modo Secundar, la
# cola que quedaria (LecturaCombate.filas_cola_si_secunda).
func _dibujar_cola(lectura: LecturaCombate) -> void:
	for hijo in _cola.get_children():
		_cola.remove_child(hijo)
		hijo.queue_free()
	var titulo: Label = Label.new()
	titulo.text = lectura.titulo_cola()
	_cola.add_child(titulo)
	var filas: Array[Dictionary] = lectura.filas_cola()
	if _eligiendo_aliada and not _aliada_previa.is_empty():
		filas = lectura.filas_cola_si_secunda(_aliada_previa)
	for fila in filas:
		var etiqueta: Label = Label.new()
		var actual: bool = fila["actual"]
		etiqueta.text = (_MARCA_ACTUAL if actual else "") + (fila["texto"] as String)
		etiqueta.modulate = _COLOR_ACTUAL if actual else (_COLOR_ACTUO if fila["actuo"] else _COLOR_PENDIENTE)
		etiqueta.set_meta("unidad_id", fila["unidad_id"])
		etiqueta.set_meta("marca", fila["marca"])
		etiqueta.set_meta("actual", actual)
		_cola.add_child(etiqueta)


func _dibujar_botones(lectura: LecturaCombate) -> void:
	var esperando: bool = _combate.esperando_jugador()
	_botones.visible = esperando
	if not esperando:
		return
	# T19: segun Turno.puede_terminar, con el motivo de la obligacion (S-35).
	var datos_terminar: Dictionary = lectura.boton_terminar()
	_boton_terminar.text = datos_terminar["texto"]
	_boton_terminar.disabled = not datos_terminar["habilitado"]
	_boton_terminar.tooltip_text = datos_terminar["motivo"]
	# T40: un boton por activa, armados desde el efecto (LecturaCombate).
	for hijo in _botones.get_children():
		if hijo != _boton_terminar:
			_botones.remove_child(hijo)
			hijo.queue_free()
	for datos_boton in lectura.botones_activas():
		var boton: Button = Button.new()
		var tipo: String = datos_boton["tipo"]
		boton.name = _PREFIJO_BOTON_ACTIVA + tipo
		boton.text = datos_boton["texto"]
		boton.tooltip_text = datos_boton["tooltip"]
		boton.disabled = not datos_boton["habilitado"]
		boton.toggle_mode = tipo == LecturaCombate.ACTIVA_CAVAR
		boton.button_pressed = boton.toggle_mode and _eligiendo_cavar
		boton.pressed.connect(pulsar_activa.bind(tipo))
		_botones.add_child(boton)
		_botones.move_child(boton, _boton_terminar.get_index())
	# T22: un boton por hechizo, armados desde los datos (LecturaCombate).
	for datos_hechizo in lectura.botones_hechizos():
		var id_hechizo: String = datos_hechizo["id"]
		var boton_hechizo: Button = Button.new()
		boton_hechizo.name = _PREFIJO_BOTON_HECHIZO + id_hechizo
		boton_hechizo.text = datos_hechizo["texto"]
		boton_hechizo.tooltip_text = datos_hechizo["tooltip"]
		boton_hechizo.disabled = not datos_hechizo["habilitado"]
		boton_hechizo.toggle_mode = true
		boton_hechizo.button_pressed = _hechizo_elegido == id_hechizo
		boton_hechizo.pressed.connect(pulsar_hechizo.bind(id_hechizo))
		_botones.add_child(boton_hechizo)
		_botones.move_child(boton_hechizo, _boton_terminar.get_index())
	# T17: Secundar, solo si hay alguna aliada a la que se pueda Secundar.
	# T24: el boton Sellar, solo en el turno del Maestro (LecturaCombate.boton_sellar).
	var datos_sellar: Dictionary = lectura.boton_sellar()
	if not datos_sellar.is_empty():
		var boton_sellar: Button = Button.new()
		boton_sellar.name = _NOMBRE_BOTON_SELLAR
		boton_sellar.text = datos_sellar["texto"]
		boton_sellar.tooltip_text = datos_sellar["tooltip"]
		boton_sellar.disabled = not datos_sellar["habilitado"] and not _sellando
		boton_sellar.toggle_mode = true
		boton_sellar.button_pressed = _sellando
		boton_sellar.pressed.connect(pulsar_sellar)
		_botones.add_child(boton_sellar)
		_botones.move_child(boton_sellar, _boton_terminar.get_index())
	var datos_secundar: Dictionary = lectura.boton_secundar()
	if not datos_secundar.is_empty():
		var boton_secundar: Button = Button.new()
		boton_secundar.name = _NOMBRE_BOTON_SECUNDAR
		boton_secundar.text = datos_secundar["texto"]
		boton_secundar.toggle_mode = true
		boton_secundar.button_pressed = _eligiendo_aliada
		boton_secundar.pressed.connect(pulsar_secundar)
		_botones.add_child(boton_secundar)
		_botones.move_child(boton_secundar, _boton_terminar.get_index())


# El desglose de un ataque o, T22, lo que haria el hechizo (LecturaCombate.vista_previa_hechizo).
func _dibujar_desglose() -> void:
	_panel_desglose.visible = not _desglose_mostrado.is_empty() or not _hechizo_mostrado.is_empty() \
			or not _sellado_mostrado.is_empty()
	if not _panel_desglose.visible:
		return
	var lectura: LecturaCombate = LecturaCombate.new(_combate, _armador, _estados)
	# T24: el % y el mana del sellado (LecturaCombate.vista_previa_sellar).
	if not _sellado_mostrado.is_empty():
		_panel_desglose.text = "\n".join(lectura.vista_previa_sellar(_sellado_mostrado["previa"],
				_sellado_mostrado["objetivo"]))
		return
	if not _desglose_mostrado.is_empty():
		_panel_desglose.text = "\n".join(lectura.desglose(_desglose_mostrado, _combate.turno_actual().unidad_id))
		return
	var previas: Dictionary = {}
	for sentido in _hechizo_mostrado.keys():
		previas[sentido] = _hechizo_mostrado[sentido]["previa"]
	_panel_desglose.text = "\n".join(lectura.vista_previa_hechizo(previas))


# A.7: la pantalla de resultado desde ResultadoCombate.a_diccionario().
func _dibujar_resultado(lectura: LecturaCombate) -> void:
	var resultado: ResultadoCombate = _combate.resultado()
	_pantalla_resultado.visible = resultado != null
	if resultado == null:
		return
	_texto_resultado.text = "\n".join(lectura.resultado(resultado.a_diccionario()))
	_boton_volver.text = _armador.armar(ClavesTextos.RESULTADO_VOLVER)


# Pantalla de desarrollo: registro crudo y avisos, con ids y datos tecnicos.
func _dibujar_depuracion() -> void:
	var lineas: Array[String] = ["== registro =="]
	lineas.append_array(_combate.registro().lineas_json())
	lineas.append("== avisos de la carga (%d) ==" % _avisos_carga.size())
	for aviso in _avisos_carga:
		lineas.append(str(aviso))
	var avisos_textos: Array[String] = _avisos_armador()
	lineas.append("== avisos de textos (%d) ==" % avisos_textos.size())
	lineas.append_array(avisos_textos)
	_depuracion.text = "\n".join(lineas)


# Los avisos del armador sin repetidos: cada redibujo vuelve a pedir los textos.
func _avisos_armador() -> Array[String]:
	var vistos: Array[String] = []
	for aviso in _armador.avisos():
		var texto: String = str(aviso)
		if not vistos.has(texto):
			vistos.append(texto)
	return vistos


# La unidad en el tablero (de pie o caida) que ocupa la casilla, o "".
func _unidad_en(foto: Dictionary, casilla: Vector2i) -> String:
	var lista: Array = [casilla.x, casilla.y]
	if foto["maestro"]["posicion"] == lista:
		return Maestro.ID
	for criatura in foto["criaturas"]:
		if criatura["posicion"] == lista and criatura["estado"] in ["suelta", "caida"]:
			return criatura["id"]
	return ""


# La casilla de una unidad segun instantanea().
func _casilla_de(foto: Dictionary, unidad_id: String) -> Vector2i:
	var posicion: Variant = null
	if unidad_id == Maestro.ID:
		posicion = foto["maestro"]["posicion"]
	else:
		for criatura in foto["criaturas"]:
			if criatura["id"] == unidad_id:
				posicion = criatura["posicion"]
	if posicion == null:
		return Criatura.SIN_POSICION
	return Vector2i(posicion[0], posicion[1])


func _mostrar_mensaje(texto: String) -> void:
	_mensaje.text = texto
	_mensaje.visible = true
	push_warning(texto)
