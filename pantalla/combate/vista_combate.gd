# Arquitectura.md B.2 (T13): la vista del combate, cenital y con placeholders.
# Arma el combate (la IA juega hasta el primer turno del jugador) y se redibuja
# entera desde el nucleo: no guarda copias del estado de reglas. Casilla <->
# pantalla solo con map_to_local / local_to_map (A.3): T32 cambia solo el
# tileset. Sesion 2: el jugador juega con el mouse (InterpreteClic y botones),
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
const _TEXTOS: String = "textos/es.json"
const _TABLA_HAMBRE: String = "tablas/hambre.json"
const _TABLA_LEALTAD: String = "tablas/lealtad.json"
const _ACCION_DEPURACION: String = "depuracion"
const _ACCION_SELECCIONAR: String = "seleccionar"
const _ACCION_ZONA: String = "zona"
const _PREFIJO_BOTON_ACTIVA: String = "Activa_"
# Presentacion: la oculta sigue visible para el jugador, a media transparencia.
const _ALFA_OCULTA: float = 0.45
const _CARPETA_REGISTROS: String = "res://registros"
# Presentacion: cuantas lineas de sucesos se ven a la vez.
const _SUCESOS_VISIBLES: int = 12
const _COLOR_ACTUAL: Color = Color(1.0, 0.85, 0.3)
const _COLOR_ACTUO: Color = Color(0.6, 0.6, 0.6)
const _COLOR_PENDIENTE: Color = Color(1, 1, 1)
const _MARCA_ACTUAL: String = "> "

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
# T40, estado de la interfaz (no de reglas): el modo "elegir casilla" de Cavar,
# si la zona de Caza se ve, y el tooltip y el aviso que se muestran.
var _eligiendo_cavar: bool = false
var _zona_visible: bool = true
var _tooltip_mostrado: Array[String] = []
var _aviso_mostrado: String = ""

@onready var _tablero: TileMapLayer = $Tablero
@onready var _capa_surcos: TileMapLayer = $Tablero/Surcos
@onready var _capa_zona: TileMapLayer = $Tablero/Zona
@onready var _marcas: TileMapLayer = $Tablero/Marcas
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


func _ready() -> void:
	_boton_terminar.pressed.connect(pulsar_terminar)
	_boton_volver.pressed.connect(volver.emit)


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
	for aviso in _avisos_armador():
		print("[textos] ", aviso)


# null si el escenario no se pudo armar.
func combate() -> Combate:
	return _combate


func tablero() -> TileMapLayer:
	return _tablero


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
# Devuelve true si se aplico.
func clic_casilla(casilla: Vector2i) -> bool:
	if _combate == null or not _combate.esperando_jugador():
		return false
	var accion: Accion = InterpreteClic.accion(_combate.turno_actual(), _combate.instantanea(), casilla, _eligiendo_cavar)
	if accion == null:
		return false
	return _aplicar(accion)


# El mouse sobre una casilla: con una objetivo atacable, el desglose de
# previsualizar_ataque desde donde esta la unidad. T40: con una unidad, su
# tooltip; en una casilla para moverse que la dejaria junto a una oculta
# enemiga, el aviso (Combate.destaparia).
func sobre_casilla(casilla: Vector2i) -> void:
	_desglose_mostrado = {}
	_tooltip_mostrado = []
	_aviso_mostrado = ""
	if _combate == null:
		return
	var foto: Dictionary = _combate.instantanea()
	var lectura: LecturaCombate = LecturaCombate.new(_combate, _armador, _estados)
	var unidad: String = _unidad_en(foto, casilla)
	if not unidad.is_empty():
		_tooltip_mostrado = lectura.tooltip_unidad(unidad)
	if _combate.esperando_jugador():
		var turno: Turno = _combate.turno_actual()
		var objetivo: String = InterpreteClic.objetivo_en(turno, foto, casilla)
		if not objetivo.is_empty():
			var vista_previa: ResultadoAccion = turno.previsualizar_ataque(_casilla_de(foto, turno.unidad_id), objetivo)
			if vista_previa.valida:
				_desglose_mostrado = vista_previa.desglose.a_diccionario()
		elif not _eligiendo_cavar and turno.casillas_para_mover().has(casilla) \
				and not _combate.destaparia(turno.unidad_id, casilla).is_empty():
			_aviso_mostrado = _armador.armar(ClavesTextos.AVISO_DESTAPAR)
	_dibujar_desglose()
	_dibujar_tooltip()


# Las lineas del tooltip que se ve ahora, o [].
func tooltip_mostrado() -> Array[String]:
	return _tooltip_mostrado.duplicate()


# El aviso de destapar que se ve ahora, o "".
func aviso_mostrado() -> String:
	return _aviso_mostrado


# T40: el boton de una activa (LecturaCombate.ACTIVA_*). Cavar no aplica nada:
# entra (o sale) del modo "elegir casilla". Devuelve true si hizo algo.
func pulsar_activa(tipo: String) -> bool:
	if _combate == null or not _combate.esperando_jugador():
		return false
	match tipo:
		LecturaCombate.ACTIVA_ERIZARSE:
			return _aplicar(Accion.erizarse())
		LecturaCombate.ACTIVA_HACERSE_JUNCO:
			return _aplicar(Accion.hacerse_junco())
		LecturaCombate.ACTIVA_CAVAR:
			_eligiendo_cavar = not _eligiendo_cavar
			redibujar()
			return true
	return false


func eligiendo_cavar() -> bool:
	return _eligiendo_cavar


func zona_visible() -> bool:
	return _zona_visible


# Las casillas marcadas como zona de Caza ahora.
func casillas_zona() -> Array[Vector2i]:
	return _capa_zona.get_used_cells()


# El desglose que se ve ahora (DesgloseDanio.a_diccionario()), o {}.
func desglose_mostrado() -> Dictionary:
	return _desglose_mostrado.duplicate(true)


func pulsar_terminar() -> bool:
	return _combate != null and _aplicar(Accion.terminar())


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


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(_ACCION_DEPURACION):
		_depuracion.visible = not _depuracion.visible
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(_ACCION_ZONA):
		alternar_zona()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(_ACCION_SELECCIONAR):
		clic_casilla(_casilla_del_mouse())
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion:
		var casilla: Vector2i = _casilla_del_mouse()
		if casilla != _casilla_mouse:
			_casilla_mouse = casilla
			sobre_casilla(casilla)


func _casilla_del_mouse() -> Vector2i:
	return _tablero.local_to_map(_tablero.get_local_mouse_position())


# Una accion del jugador: si el nucleo la acepta, se redibuja todo.
func _aplicar(accion: Accion) -> bool:
	if not _combate.aplicar(accion).valida:
		return false
	_desglose_mostrado = {}
	_tooltip_mostrado = []
	_aviso_mostrado = ""
	_eligiendo_cavar = false
	_casilla_mouse = Criatura.SIN_POSICION
	_despues_de_un_cambio()
	return true


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
	var esquina_a: Vector2 = _tablero.map_to_local(Vector2i(0, 0))
	var esquina_b: Vector2 = _tablero.map_to_local(Vector2i(tablero_combate.ancho - 1, tablero_combate.alto - 1))
	_camara.global_position = _tablero.to_global((esquina_a + esquina_b) / 2.0)


# Solo en el turno del jugador: a donde puede moverse y a quien puede atacar.
# T40: eligiendo donde cavar, solo las casillas de casillas_para_cavar.
func _dibujar_marcas() -> void:
	_marcas.clear()
	if not _combate.esperando_jugador():
		return
	var turno: Turno = _combate.turno_actual()
	if _eligiendo_cavar:
		for casilla in turno.casillas_para_cavar():
			_marcas.set_cell(casilla, _FUENTE_MARCAS, _MARCA_CAVAR)
		return
	for casilla in turno.casillas_para_mover():
		_marcas.set_cell(casilla, _FUENTE_MARCAS, _MARCA_MOVER)
	var foto: Dictionary = _combate.instantanea()
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
	if _combate != null:
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
	for hijo in _cola.get_children():
		_cola.remove_child(hijo)
		hijo.queue_free()
	var titulo: Label = Label.new()
	titulo.text = lectura.titulo_cola()
	_cola.add_child(titulo)
	for fila in lectura.filas_cola():
		var etiqueta: Label = Label.new()
		var actual: bool = fila["actual"]
		etiqueta.text = (_MARCA_ACTUAL if actual else "") + (fila["texto"] as String)
		etiqueta.modulate = _COLOR_ACTUAL if actual else (_COLOR_ACTUO if fila["actuo"] else _COLOR_PENDIENTE)
		etiqueta.set_meta("unidad_id", fila["unidad_id"])
		etiqueta.set_meta("marca", fila["marca"])
		etiqueta.set_meta("actual", actual)
		_cola.add_child(etiqueta)
	_panel_turno.text = "\n".join(lectura.panel_turno())


func _dibujar_botones(lectura: LecturaCombate) -> void:
	var esperando: bool = _combate.esperando_jugador()
	_botones.visible = esperando
	if not esperando:
		return
	_boton_terminar.text = lectura.texto_terminar()
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


func _dibujar_desglose() -> void:
	_panel_desglose.visible = not _desglose_mostrado.is_empty()
	if _panel_desglose.visible:
		var lectura: LecturaCombate = LecturaCombate.new(_combate, _armador, _estados)
		_panel_desglose.text = "\n".join(lectura.desglose(_desglose_mostrado, _combate.turno_actual().unidad_id))


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
