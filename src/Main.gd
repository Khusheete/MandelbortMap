extends Panel

onready var mandelbrot: Node = $HPanel/Mandelbrot
onready var julia: Node = $HPanel/VPanel/Julia

#the current state of the window
# true - The mandelbrot set is on the main plot
# false - The julia set is on the main plot
var state: bool = true

func _ready():
	var os_lang: String = OS.get_locale()
	TranslationServer.set_locale(os_lang)
	
	translate_tabs()
	
	var julia_set: Vector2 = julia.render_material.get_shader_param("julia_set")
	var real_part: SpinBox = $HPanel/VPanel/UI/Separator/Tabs/Julia/Set/Real
	var img_part: SpinBox = $HPanel/VPanel/UI/Separator/Tabs/Julia/Set/Imaginary
	real_part.value = julia_set.x
	img_part.value = julia_set.y


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
	elif Input.is_action_just_pressed("help"):
		$HelpDialog.popup_centered()


func _on_Mandelbrot_gui_input(event):
	if event is InputEventMouse:
		if Input.is_action_pressed("left_mouse_click"):
			#change the julia fractal
			var mpos: Vector2 = mandelbrot.transform_pos(get_global_mouse_position())
			julia.render_material.set_shader_param("julia_set", mpos)
			var real_part: SpinBox = $HPanel/VPanel/UI/Separator/Tabs/Julia/Set/Real
			var img_part: SpinBox = $HPanel/VPanel/UI/Separator/Tabs/Julia/Set/Imaginary
			real_part.value = mpos.x
			img_part.value = mpos.y
	if event is InputEventMouseMotion:
		#update mouse position text
		var mpos: Vector2 = mandelbrot.transform_pos(get_global_mouse_position())
		var position: Label = $HPanel/VPanel/UI/Separator/Footer/MousePos
		var posStr: String = tr("MOUSE_POS")
		position.text = posStr.format({"x": mpos.x, "y": mpos.y})
		
		
		if Input.is_action_pressed("middle_mouse_click"): #move around the figure
			var mpos_0: Vector2 = mandelbrot.transform_pos(get_global_mouse_position() - event.relative)
			var dmpos: Vector2 = mpos - mpos_0
			mandelbrot.plane_center -= dmpos
	if event.is_action_pressed("scroll_up"):
		#zoom in
		var mpos: Vector2 = mandelbrot.transform_pos(get_global_mouse_position())
		mandelbrot.plane_center = mandelbrot.plane_center.linear_interpolate(mpos, 0.25)
		mandelbrot.plane_min_size *= 0.9
	if event.is_action_pressed("scroll_down"):
		#zoom out
		mandelbrot.plane_min_size *= 1.1


func _on_Julia_gui_input(event):
	if event.is_action_pressed("scroll_up"):
		#zoom in
		var mpos: Vector2 = julia.transform_pos(get_global_mouse_position())
		julia.plane_center = julia.plane_center.linear_interpolate(mpos, 0.25)
		julia.plane_min_size *= 0.9
	if event.is_action_pressed("scroll_down"):
		#zoom out
		julia.plane_min_size *= 1.1
	if event is InputEventMouseMotion:
		#update mouse position text
		var mpos: Vector2 = julia.transform_pos(get_global_mouse_position())
		var position: Label = $HPanel/VPanel/UI/Separator/Footer/MousePos
		var posStr: String = tr("MOUSE_POS")
		position.text = posStr.format({"x": mpos.x, "y": mpos.y})
		
		if Input.is_action_pressed("middle_mouse_click"): #move around the figure
			var mpos_0: Vector2 = julia.transform_pos(get_global_mouse_position() - event.relative)
			var dmpos: Vector2 = mpos - mpos_0
			julia.plane_center -= dmpos


func _on_Help_pressed():
	$HelpDialog.popup_centered()


func translate_tabs():
	var tabs: TabContainer = $HPanel/VPanel/UI/Separator/Tabs
	var tkey: Array = ["SETTINGS", "MANDELBROT", "JULIA"]
	for i in range(tabs.get_tab_count()):
		tabs.set_tab_title(i, tr(tkey[i]))



func _on_LanguageSelect_item_selected(index: int):
	var lang_select: OptionButton = $HPanel/VPanel/UI/Separator/Tabs/Settings/Language/LanguageSelect
	var lang: String = lang_select.get_item_text(index)
	
	match lang:
		"Français":
			TranslationServer.set_locale("fr")
		"English":
			TranslationServer.set_locale("en")
	
	translate_tabs()

#this is the help template
const HELP: String = \
"""{zoom}

{move}

{cview}

{cjulia}
"""

func _on_HelpDialog_about_to_show():
	var help: RichTextLabel = $HelpDialog/Help
	help.text = HELP.format({zoom = tr("HELP_ZOOM"), move = tr("HELP_MOVE_AROUND"), cview = tr("HELP_CHANGE_VIEW"), cjulia = tr("HELP_CHANGE_JULIA")})


func _on_julia_set_changed(_value: float):
	var real_part: SpinBox = $HPanel/VPanel/UI/Separator/Tabs/Julia/Set/Real
	var img_part: SpinBox = $HPanel/VPanel/UI/Separator/Tabs/Julia/Set/Imaginary
	julia.render_material.set_shader_param("julia_set", Vector2(real_part.value, img_part.value))

func set_gradient(gradient: Gradient):
	mandelbrot.color_gradient = gradient
	julia.color_gradient = gradient

func _on_GradientSelect_item_selected(index: int):
	var gradient_select: OptionButton = $HPanel/VPanel/UI/Separator/Tabs/Settings/ColorGradient/GradientSelect
	match gradient_select.get_item_text(index):
		"PURPLE_GRADIENT":
			set_gradient(preload("res://data/gradients/purple.tres"))
		"CLASSIC":
			set_gradient(preload("res://data/gradients/uf.tres"))
		"GRAYSCALE":
			set_gradient(preload("res://data/gradients/normal.tres"))
		"BLUE_GRADIENT":
			set_gradient(preload("res://data/gradients/blue.tres"))


func _on_resolution_changed(_value: int):
	var width: SpinBox = $HPanel/VPanel/UI/Separator/Tabs/Settings/Resolution/Width
	var height: SpinBox = $HPanel/VPanel/UI/Separator/Tabs/Settings/Resolution/Height
	mandelbrot.resolution = Vector2(width.value, height.value)
	julia.resolution = Vector2(width.value, height.value)
