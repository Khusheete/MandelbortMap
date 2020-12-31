extends Panel

onready var mandelbrot: Node = $HPanel/Mandelbrot
onready var julia: Node = $HPanel/VPanel/Julia

#the current state of the window
# true - The mandelbrot set is on the main plot
# false - The julia set is on the main plot
var state: bool = true

func _ready():
	pass


func _input(event: InputEvent):
	if !event.is_echo() && event.is_action_pressed("switch"):

		if state:
			$HPanel.remove_child(mandelbrot)
			$HPanel/VPanel.remove_child(julia)
			$HPanel.add_child(julia)
			$HPanel.move_child(julia, 0)
			$HPanel/VPanel.add_child(mandelbrot)
		else:
			$HPanel.remove_child(julia)
			$HPanel/VPanel.remove_child(mandelbrot)
			$HPanel.add_child(mandelbrot)
			$HPanel.move_child(mandelbrot, 0)
			$HPanel/VPanel.add_child(julia)

		state = !state


func _on_Mandelbrot_gui_input(event):
	if event is InputEventMouse:
		if Input.is_action_pressed("left_mouse_click"):
			var mpos: Vector2 = mandelbrot.transform_pos(get_global_mouse_position())
			julia.render_material.set_shader_param("julia_set", mpos)
	if event is InputEventMouseMotion:
		if Input.is_action_pressed("middle_mouse_click"):
			var mpos_1: Vector2 = mandelbrot.transform_pos(get_global_mouse_position())
			var mpos_0: Vector2 = mandelbrot.transform_pos(get_global_mouse_position() - event.relative)
			var dmpos: Vector2 = mpos_1 - mpos_0
			mandelbrot.plane_center -= dmpos
	if event.is_action_pressed("scroll_up"):
		var mpos: Vector2 = mandelbrot.transform_pos(get_global_mouse_position())
		mandelbrot.plane_center = mandelbrot.plane_center.linear_interpolate(mpos, 0.25)
		mandelbrot.plane_min_size *= 0.9
	if event.is_action_pressed("scroll_down"):
		mandelbrot.plane_min_size *= 1.1


func _on_Julia_gui_input(event):
	if event.is_action_pressed("scroll_up"):
		var mpos: Vector2 = julia.transform_pos(get_global_mouse_position())
		julia.plane_center = julia.plane_center.linear_interpolate(mpos, 0.25)
		julia.plane_min_size *= 0.9
	if event.is_action_pressed("scroll_down"):
		julia.plane_min_size *= 1.1
	if event is InputEventMouseMotion:
		if Input.is_action_pressed("middle_mouse_click"):
			var mpos_1: Vector2 = julia.transform_pos(get_global_mouse_position())
			var mpos_0: Vector2 = julia.transform_pos(get_global_mouse_position() - event.relative)
			var dmpos: Vector2 = mpos_1 - mpos_0
			julia.plane_center -= dmpos
