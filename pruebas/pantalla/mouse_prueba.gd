class_name MousePrueba
extends RefCounted

# T24-ajustes (D-012): el unico camino del mouse de los tests.
# - Input.parse_input_event toma la posicion en coordenadas de la ventana y le
#   aplica la inversa de Viewport.get_final_transform(); los tests la calculan
#   en coordenadas del viewport. Se convierte con la transformacion de ese
#   momento: GdUnit4 minimiza y restaura la ventana entre runners, y mientras no
#   vuelve a 1152 x 648 la transformacion no es la identidad.
# - Los eventos llevan un device propio, y la vista se configura para aceptar
#   solo ese: el cursor real de la maquina y el warp_mouse del runner de escenas
#   llegan con el device del mouse de Godot y no pisan la posicion del test.
# D-006: parse_input_event + flush, sin await entre el evento y la comprobacion.
const DISPOSITIVO: int = 7


static func preparar(vista: VistaCombate) -> void:
	vista.dispositivo_mouse = DISPOSITIVO


# Copia del evento en coordenadas de ventana: la posicion por `final` y el
# relative por su parte lineal (sin traslacion), con el device pedido.
# global_position no cambia: Godot tampoco la convierte al despacharlo.
static func a_ventana(evento: InputEventMouse, final: Transform2D, dispositivo: int) -> InputEventMouse:
	var copia: InputEventMouse = evento.duplicate()
	copia.device = dispositivo
	copia.position = final * evento.position
	if copia is InputEventMouseMotion:
		var movimiento: InputEventMouseMotion = copia
		movimiento.relative = final.basis_xform(movimiento.relative)
	return copia


# Manda un evento de mouse con la posicion del viewport. La ventana es la
# principal (la que recibe parse_input_event), y su transformacion se lee aca.
static func mandar(evento: InputEventMouse, dispositivo: int = DISPOSITIVO) -> void:
	var ventana: Window = (Engine.get_main_loop() as SceneTree).root
	Input.parse_input_event(a_ventana(evento, ventana.get_final_transform(), dispositivo))
	Input.flush_buffered_events()


static func mover_a(posicion: Vector2, dispositivo: int = DISPOSITIVO) -> void:
	var evento: InputEventMouseMotion = InputEventMouseMotion.new()
	evento.position = posicion
	evento.global_position = posicion
	mandar(evento, dispositivo)


# Apretar y soltar en la misma posicion.
static func clic_en(posicion: Vector2, boton: MouseButton = MOUSE_BUTTON_LEFT,
		mascara: int = MOUSE_BUTTON_MASK_LEFT, dispositivo: int = DISPOSITIVO) -> void:
	var evento: InputEventMouseButton = InputEventMouseButton.new()
	evento.button_index = boton
	evento.button_mask = mascara
	evento.position = posicion
	evento.global_position = posicion
	evento.pressed = true
	mandar(evento, dispositivo)
	var suelto: InputEventMouseButton = evento.duplicate()
	suelto.button_mask = 0
	suelto.pressed = false
	mandar(suelto, dispositivo)
